// WindowElementInspector_mac.mm
// macOS 后端：AXUIElement + CGEventTap + AppleScript 生成
// 编译需要 ApplicationServices.framework 和 AppKit.framework
#include "WindowElementInspector.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QVariantMap>
#include <QRect>
#include <QPoint>
#include <QProcess>
#include <QGuiApplication>
#include <QHash>

#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>

namespace PlatformBackend {

static CFMachPortRef g_eventTap = nullptr;
static CFRunLoopSourceRef g_eventTapSource = nullptr;
static WindowElementInspector *g_inspector = nullptr;
static QString g_hotkeyString;
static CGEventFlags g_hotkeyModifiers = 0;
static CGKeyCode g_hotkeyKeyCode = UINT16_MAX;
static bool g_hotkeyEnabled = false;
static bool g_picking = false;

// ============================================================
// 辅助：取 AX 属性（失败返回空 QString）
// ============================================================
static QString axString(AXUIElementRef el, CFStringRef attr)
{
    CFTypeRef v = nullptr;
    if (AXUIElementCopyAttributeValue(el, attr, &v) != kAXErrorSuccess || !v) {
        return QString();
    }
    QString result;
    CFTypeID tid = CFGetTypeID(v);
    if (tid == CFStringGetTypeID()) {
        result = QString::fromCFString((CFStringRef)v);
    } else if (tid == CFNumberGetTypeID()) {
        CFNumberRef n = (CFNumberRef)v;
        double d = 0;
        if (CFNumberGetValue(n, kCFNumberDoubleType, &d)) {
            result = QString::number(d);
        }
    }
    CFRelease(v);
    return result;
}

static QRect axRect(AXUIElementRef el)
{
    QRect r;
    CFTypeRef pos = nullptr, size = nullptr;
    if (AXUIElementCopyAttributeValue(el, kAXPositionAttribute, &pos) == kAXErrorSuccess && pos) {
        CGPoint p;
        if (AXValueGetValue((AXValueRef)pos, (AXValueType)kAXValueCGPointType, &p)) {
            r.setX((int)p.x);
            r.setY((int)p.y);
        }
        CFRelease(pos);
    }
    if (AXUIElementCopyAttributeValue(el, kAXSizeAttribute, &size) == kAXErrorSuccess && size) {
        CGSize s;
        if (AXValueGetValue((AXValueRef)size, (AXValueType)kAXValueCGSizeType, &s)) {
            r.setWidth((int)s.width);
            r.setHeight((int)s.height);
        }
        CFRelease(size);
    }
    return r;
}

static QStringList axActionNames(AXUIElementRef el)
{
    QStringList result;
    CFArrayRef names = nullptr;
    if (AXUIElementCopyActionNames(el, &names) == kAXErrorSuccess && names) {
        CFIndex n = CFArrayGetCount(names);
        for (CFIndex i = 0; i < n; ++i) {
            CFStringRef s = (CFStringRef)CFArrayGetValueAtIndex(names, i);
            if (s) result << QString::fromCFString(s);
        }
        CFRelease(names);
    }
    return result;
}

// 把 AXUIElement 节点转成 QVariantMap
static QVariantMap elementToMap(AXUIElementRef el)
{
    QVariantMap m;
    if (!el) return m;
    m["name"] = axString(el, kAXTitleAttribute);
    m["value"] = axString(el, kAXValueAttribute);
    m["role"] = axString(el, kAXRoleAttribute);
    m["roleDescription"] = axString(el, kAXRoleDescriptionAttribute);
    QString desc = axString(el, kAXHelpAttribute);
    if (!desc.isEmpty()) m["help"] = desc;
    QString enabled = axString(el, kAXEnabledAttribute);
    m["enabled"] = (enabled == "1" || enabled.toLower() == "true");
    QRect r = axRect(el);
    QVariantMap rect;
    rect["x"] = r.x();
    rect["y"] = r.y();
    rect["width"] = r.width();
    rect["height"] = r.height();
    m["rect"] = rect;
    QStringList actions = axActionNames(el);
    if (!actions.isEmpty()) {
        QVariantList al;
        for (const auto &a : actions) al << a;
        m["actions"] = al;
    }
    return m;
}

// ============================================================
// init / shutdown
// ============================================================
void init(WindowElementInspector *insp)
{
    g_inspector = insp;
}

void shutdown(WindowElementInspector *insp)
{
    g_picking = false;
    g_hotkeyEnabled = false;
    if (g_eventTapSource) {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), g_eventTapSource, kCFRunLoopCommonModes);
        CFRelease(g_eventTapSource);
        g_eventTapSource = nullptr;
    }
    if (g_eventTap) {
        CFMachPortInvalidate(g_eventTap);
        CFRelease(g_eventTap);
        g_eventTap = nullptr;
    }
    if (g_inspector == insp) {
        g_inspector = nullptr;
    }
}

// ============================================================
// 权限
// ============================================================
bool refreshAccessibility(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @NO};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
}

bool requestAccessibilityPermission(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    NSDictionary *options = @{(__bridge NSString *)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
}

void openAccessibilitySettings()
{
    // 依次尝试：精确 → 隐私与安全 → 根设置页 → 命令行
    // 这样在 macOS 14/15 上 URL scheme 被拦时还能 fallback
    const char *urls[] = {
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility",
        "x-apple.systempreferences:com.apple.preference.security",
        "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension",
    };
    for (const char *u : urls) {
        if (QProcess::startDetached("open", {QString::fromUtf8(u)})) {
            return;
        }
    }
    // 最后兜底：打开系统设置 App
    QProcess::startDetached("open", {"-a", "System Settings"});
}

// ============================================================
// 前台应用
// ============================================================
void refreshForeground(WindowElementInspector *insp)
{
    if (!insp) return;
    @autoreleasepool {
        NSRunningApplication *front = [[NSWorkspace sharedWorkspace] frontmostApplication];
        if (!front) return;
        QString bundleId = QString::fromNSString(front.bundleIdentifier ?: @"");
        if (bundleId == "com.apple.accessibility.universalAccessAuthWarn") {
            return;
        }
        QString localized = QString::fromNSString(front.localizedName ?: @"");
        int pid = front.processIdentifier;
        QString display = !bundleId.isEmpty() ? bundleId : localized;
        insp->setForegroundInfo(display, pid);
    }
}

// ============================================================
// 抓取指定坐标的组件
// ============================================================
QVariantMap getElementAtPoint(int x, int y)
{
    QVariantMap info;
    @autoreleasepool {
        AXUIElementRef sys = AXUIElementCreateSystemWide();
        if (!sys) return info;
        AXUIElementRef el = nullptr;
        AXError err = AXUIElementCopyElementAtPosition(sys, (float)x, (float)y, &el);
        CFRelease(sys);
        if (err != kAXErrorSuccess || !el) {
            if (el) CFRelease(el);
            return info;
        }
        info = elementToMap(el);

        // 使用命中元素所属进程，避免把未激活的目标误标为本应用。
        pid_t targetPid = 0;
        if (AXUIElementGetPid(el, &targetPid) == kAXErrorSuccess && targetPid > 0) {
            NSRunningApplication *targetApp =
                [NSRunningApplication runningApplicationWithProcessIdentifier:targetPid];
            info["pid"] = static_cast<int>(targetPid);
            if (targetApp) {
                info["appName"] = QString::fromNSString(targetApp.localizedName ?: @"");
                info["bundleId"] = QString::fromNSString(targetApp.bundleIdentifier ?: @"");
            }
        }

        // 父链（最多 6 层）
        QVariantList chain;
        AXUIElementRef cur = el;
        for (int i = 0; i < 6; ++i) {
            CFTypeRef parent = nullptr;
            if (AXUIElementCopyAttributeValue(cur, kAXParentAttribute, &parent) != kAXErrorSuccess || !parent) {
                if (parent) CFRelease(parent);
                break;
            }
            AXUIElementRef p = (AXUIElementRef)parent;
            QVariantMap pm = elementToMap(p);
            chain.prepend(pm);
            if (cur != el) CFRelease(cur);
            cur = p;
        }
        if (cur && cur != el) CFRelease(cur);
        CFRelease(el);
        info["parentChain"] = chain;
    }
    return info;
}

// ============================================================
// 全局热键与锚点单击（macOS）—— 使用 CGEventTap
// ============================================================
static CGKeyCode keyCodeForName(const QString &name)
{
    static const QHash<QString, CGKeyCode> keyCodes = {
        {"A", 0}, {"S", 1}, {"D", 2}, {"F", 3}, {"H", 4}, {"G", 5},
        {"Z", 6}, {"X", 7}, {"C", 8}, {"V", 9}, {"B", 11}, {"Q", 12},
        {"W", 13}, {"E", 14}, {"R", 15}, {"Y", 16}, {"T", 17}, {"1", 18},
        {"2", 19}, {"3", 20}, {"4", 21}, {"6", 22}, {"5", 23}, {"9", 25},
        {"7", 26}, {"8", 28}, {"0", 29}, {"O", 31}, {"U", 32}, {"I", 34},
        {"P", 35}, {"L", 37}, {"J", 38}, {"K", 40}, {"N", 45}, {"M", 46}
    };
    return keyCodes.value(name.trimmed().toUpper(), UINT16_MAX);
}

static bool parseHotkey(const QString &hotkey)
{
    g_hotkeyModifiers = 0;
    if (hotkey.contains("Ctrl", Qt::CaseInsensitive)) g_hotkeyModifiers |= kCGEventFlagMaskControl;
    if (hotkey.contains("Alt", Qt::CaseInsensitive) || hotkey.contains("Option", Qt::CaseInsensitive))
        g_hotkeyModifiers |= kCGEventFlagMaskAlternate;
    if (hotkey.contains("Shift", Qt::CaseInsensitive)) g_hotkeyModifiers |= kCGEventFlagMaskShift;
    if (hotkey.contains("Meta", Qt::CaseInsensitive) || hotkey.contains("Cmd", Qt::CaseInsensitive) ||
        hotkey.contains("Command", Qt::CaseInsensitive) || hotkey.contains("Super", Qt::CaseInsensitive))
        g_hotkeyModifiers |= kCGEventFlagMaskCommand;
    g_hotkeyKeyCode = keyCodeForName(hotkey.section('+', -1));
    return g_hotkeyKeyCode != UINT16_MAX && g_hotkeyModifiers != 0;
}

static CGEventRef eventTapCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *userInfo)
{
    Q_UNUSED(proxy)
    Q_UNUSED(userInfo)
    if (type == kCGEventTapDisabledByTimeout || type == kCGEventTapDisabledByUserInput) {
        if (g_eventTap) CGEventTapEnable(g_eventTap, true);
        return event;
    }

    if (type == kCGEventKeyDown) {
        const CGKeyCode keyCode =
            static_cast<CGKeyCode>(CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode));
        if (g_picking && keyCode == 53) {
            g_picking = false;
            [[NSCursor arrowCursor] set];
            if (g_inspector) {
                QMetaObject::invokeMethod(g_inspector, "cancelCapture", Qt::QueuedConnection);
            }
            return nullptr;
        }

        const CGEventFlags relevantFlags = CGEventGetFlags(event) &
            (kCGEventFlagMaskControl | kCGEventFlagMaskAlternate |
             kCGEventFlagMaskShift | kCGEventFlagMaskCommand);
        if (!g_picking && g_hotkeyEnabled && g_inspector &&
            keyCode == g_hotkeyKeyCode && relevantFlags == g_hotkeyModifiers) {
            QMetaObject::invokeMethod(g_inspector, "startCapture", Qt::QueuedConnection,
                                      Q_ARG(int, 0));
            return nullptr;
        }
    }
    if (type == kCGEventLeftMouseDown && g_picking) {
        const CGPoint point = CGEventGetLocation(event);
        g_picking = false;
        [[NSCursor arrowCursor] set];
        if (g_inspector) {
            QMetaObject::invokeMethod(g_inspector, "captureAtPoint", Qt::QueuedConnection,
                                      Q_ARG(int, qRound(point.x)), Q_ARG(int, qRound(point.y)));
        }
        return nullptr;
    }
    return event;
}

static bool ensureEventTap()
{
    if (g_eventTap) {
        CGEventTapEnable(g_eventTap, true);
        return true;
    }
    const CGEventMask mask = CGEventMaskBit(kCGEventKeyDown) |
                             CGEventMaskBit(kCGEventLeftMouseDown);
    g_eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap,
                                 kCGEventTapOptionDefault, mask, eventTapCallback, nullptr);
    if (!g_eventTap) return false;
    g_eventTapSource = CFMachPortCreateRunLoopSource(nullptr, g_eventTap, 0);
    if (!g_eventTapSource) {
        CFRelease(g_eventTap);
        g_eventTap = nullptr;
        return false;
    }
    CFRunLoopAddSource(CFRunLoopGetMain(), g_eventTapSource, kCFRunLoopCommonModes);
    CGEventTapEnable(g_eventTap, true);
    return true;
}

bool registerHotkey(WindowElementInspector *insp, const QString &hk)
{
    g_inspector = insp;
    g_hotkeyString = hk;
    g_hotkeyEnabled = parseHotkey(hk) && ensureEventTap();
    return g_hotkeyEnabled;
}

void unregisterHotkey()
{
    g_hotkeyEnabled = false;
}

bool beginPicking(WindowElementInspector *insp)
{
    g_inspector = insp;
    if (!ensureEventTap()) return false;
    g_picking = true;
    [[NSCursor crosshairCursor] set];
    return true;
}

void endPicking()
{
    g_picking = false;
    [[NSCursor arrowCursor] set];
}

} // namespace PlatformBackend
