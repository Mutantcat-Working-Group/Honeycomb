// WindowElementInspector_win.cpp
// Windows 后端：UI Automation (COM) + RegisterHotKey + PowerShell 脚本生成
#include "WindowElementInspector.h"

#include <QJsonObject>
#include <QJsonArray>
#include <QVariantMap>
#include <QProcess>
#include <QGuiApplication>
#include <QAbstractNativeEventFilter>
#include <QRect>

#if defined(Q_OS_WIN)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <combaseapi.h>
#include <UIAutomation.h>

// ============================================================
// 全局
// ============================================================
namespace {
IUIAutomation *g_automation = nullptr;
WindowElementInspector *g_inspector = nullptr;
int g_hotkeyId = 1;
QString g_hotkeyString;
HHOOK g_mouseHook = nullptr;
HHOOK g_keyboardHook = nullptr;
bool g_picking = false;

void clearPickingHooks()
{
    g_picking = false;
    if (g_mouseHook) { UnhookWindowsHookEx(g_mouseHook); g_mouseHook = nullptr; }
    if (g_keyboardHook) { UnhookWindowsHookEx(g_keyboardHook); g_keyboardHook = nullptr; }
    SetCursor(LoadCursor(nullptr, IDC_ARROW));
}

LRESULT CALLBACK mouseHookProc(int code, WPARAM wParam, LPARAM lParam)
{
    if (code >= 0 && g_picking && wParam == WM_LBUTTONDOWN) {
        const auto *data = reinterpret_cast<MSLLHOOKSTRUCT *>(lParam);
        g_picking = false;
        if (g_inspector && data) {
            QMetaObject::invokeMethod(g_inspector, "captureAtPoint", Qt::QueuedConnection,
                                      Q_ARG(int, data->pt.x), Q_ARG(int, data->pt.y));
        }
        return 1;
    }
    return CallNextHookEx(g_mouseHook, code, wParam, lParam);
}

LRESULT CALLBACK keyboardHookProc(int code, WPARAM wParam, LPARAM lParam)
{
    if (code >= 0 && g_picking && (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN)) {
        const auto *data = reinterpret_cast<KBDLLHOOKSTRUCT *>(lParam);
        if (data && data->vkCode == VK_ESCAPE) {
            g_picking = false;
            if (g_inspector) {
                QMetaObject::invokeMethod(g_inspector, "cancelCapture", Qt::QueuedConnection);
            }
            return 1;
        }
    }
    return CallNextHookEx(g_keyboardHook, code, wParam, lParam);
}

class HotkeyEventFilter : public QAbstractNativeEventFilter
{
public:
    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override
    {
        Q_UNUSED(eventType)
        Q_UNUSED(result)
        MSG *msg = static_cast<MSG *>(message);
        if (msg && msg->message == WM_HOTKEY && msg->wParam == (WPARAM)g_hotkeyId) {
            if (g_inspector) {
                QMetaObject::invokeMethod(g_inspector, "startCapture", Q_ARG(int, 0));
            }
            return true;
        }
        return false;
    }
};
QSharedPointer<HotkeyEventFilter> g_filter;
}

// ============================================================
// UIA ControlType → 名字
// ============================================================
static QString controlTypeName(int t)
{
    switch (t) {
    case UIA_ButtonControlTypeId: return "Button";
    case UIA_CalendarControlTypeId: return "Calendar";
    case UIA_CheckBoxControlTypeId: return "CheckBox";
    case UIA_ComboBoxControlTypeId: return "ComboBox";
    case UIA_DataItemControlTypeId: return "DataItem";
    case UIA_DocumentControlTypeId: return "Document";
    case UIA_EditControlTypeId: return "Edit";
    case UIA_GroupControlTypeId: return "Group";
    case UIA_HyperlinkControlTypeId: return "Hyperlink";
    case UIA_ImageControlTypeId: return "Image";
    case UIA_ListControlTypeId: return "List";
    case UIA_ListItemControlTypeId: return "ListItem";
    case UIA_MenuControlTypeId: return "Menu";
    case UIA_MenuBarControlTypeId: return "MenuBar";
    case UIA_MenuItemControlTypeId: return "MenuItem";
    case UIA_PaneControlTypeId: return "Pane";
    case UIA_ProgressBarControlTypeId: return "ProgressBar";
    case UIA_RadioButtonControlTypeId: return "RadioButton";
    case UIA_ScrollBarControlTypeId: return "ScrollBar";
    case UIA_SliderControlTypeId: return "Slider";
    case UIA_SpinnerControlTypeId: return "Spinner";
    case UIA_StatusBarControlTypeId: return "StatusBar";
    case UIA_TabControlTypeId: return "Tab";
    case UIA_TabItemControlTypeId: return "TabItem";
    case UIA_TableControlTypeId: return "Table";
    case UIA_TextControlTypeId: return "Text";
    case UIA_TreeControlTypeId: return "Tree";
    case UIA_TreeItemControlTypeId: return "TreeItem";
    case UIA_WindowControlTypeId: return "Window";
    default: return QString::number(t);
    }
}

static QString uiaString(IUIAutomationElement *el, PROPERTYID prop)
{
    if (!el) return QString();
    VARIANT v;
    VariantInit(&v);
    if (SUCCEEDED(el->GetCurrentPropertyValue(prop, &v)) && V_VT(&v) == VT_BSTR) {
        QString s = QString::fromWCharArray(V_BSTR(&v));
        VariantClear(&v);
        return s;
    }
    VariantClear(&v);
    return QString();
}

static QRect uiaRect(IUIAutomationElement *el)
{
    if (!el) return QRect();
    RECT r;
    if (SUCCEEDED(el->get_CurrentBoundingRectangle(&r))) {
        return QRect(r.left, r.top, r.right - r.left, r.bottom - r.top);
    }
    return QRect();
}

static QVariantMap elementToMap(IUIAutomationElement *el)
{
    QVariantMap m;
    if (!el) return m;
    m["name"] = uiaString(el, UIA_NamePropertyId);
    m["automationId"] = uiaString(el, UIA_AutomationIdPropertyId);
    m["className"] = uiaString(el, UIA_ClassNamePropertyId);
    m["frameworkId"] = uiaString(el, UIA_FrameworkIdPropertyId);
    m["help"] = uiaString(el, UIA_HelpTextPropertyId);
    int ct = 0;
    if (SUCCEEDED(el->get_CurrentControlType(&ct))) {
        m["controlType"] = ct;
        m["controlTypeName"] = controlTypeName(ct);
    }
    QRect r = uiaRect(el);
    QVariantMap rect;
    rect["x"] = r.x();
    rect["y"] = r.y();
    rect["width"] = r.width();
    rect["height"] = r.height();
    m["rect"] = rect;

    // 模式（动作）
    QStringList patterns;
    QVariantList actions;
    IUIAutomationInvokePattern *ip = nullptr;
    if (SUCCEEDED(el->GetCurrentPattern(UIA_InvokePatternId, (IUnknown**)&ip)) && ip) {
        patterns << "Invoke";
        actions << "Invoke";
        ip->Release();
    }
    IUIAutomationValuePattern *vp = nullptr;
    if (SUCCEEDED(el->GetCurrentPattern(UIA_ValuePatternId, (IUnknown**)&vp)) && vp) {
        BSTR bv;
        if (SUCCEEDED(vp->get_CurrentValue(&bv)) && bv) {
            m["value"] = QString::fromWCharArray(bv);
            SysFreeString(bv);
        }
        patterns << "Value";
        actions << "SetValue";
        vp->Release();
    }
    IUIAutomationTogglePattern *tp = nullptr;
    if (SUCCEEDED(el->GetCurrentPattern(UIA_TogglePatternId, (IUnknown**)&tp)) && tp) {
        patterns << "Toggle";
        actions << "Toggle";
        tp->Release();
    }
    if (!actions.isEmpty()) m["actions"] = actions;
    return m;
}

// ============================================================
// 后端接口
// ============================================================
namespace PlatformBackend {

void init(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
    CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
    if (!g_automation) {
        CoCreateInstance(CLSID_CUIAutomation, nullptr, CLSCTX_INPROC_SERVER,
                         IID_PPV_ARGS(&g_automation));
    }
}

void shutdown(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    clearPickingHooks();
    if (g_automation) { g_automation->Release(); g_automation = nullptr; }
    CoUninitialize();
}

bool refreshAccessibility(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    // UIA 在 Windows 上无需权限
    return g_automation != nullptr;
}

void openAccessibilitySettings()
{
    // 启动设置 → 辅助功能
    QProcess::startDetached("control", {"/name", "Microsoft.EaseOfAccess"});
}

void refreshForeground(WindowElementInspector *insp)
{
    if (!insp || !g_automation) return;
    IUIAutomationElement *root = nullptr;
    if (FAILED(g_automation->GetRootElement(&root)) || !root) return;
    IUIAutomationElement *focused = nullptr;
    if (SUCCEEDED(g_automation->GetFocusedElement(&focused)) && focused) {
        QString name = uiaString(focused, UIA_NamePropertyId);
        int pid = 0;
        focused->get_CurrentProcessId(&pid);
        insp->setForegroundInfo(name, pid);
        focused->Release();
    }
    root->Release();
}

QVariantMap getElementAtPoint(int x, int y)
{
    if (!g_automation) return QVariantMap();
    POINT pt = {x, y};
    IUIAutomationElement *el = nullptr;
    if (FAILED(g_automation->ElementFromPoint(pt, &el)) || !el) return QVariantMap();
    QVariantMap info = elementToMap(el);

    // 父链 6 层
    QVariantList chain;
    IUIAutomationElement *cur = el;
    cur->AddRef();
    for (int i = 0; i < 6; ++i) {
        IUIAutomationTreeWalker *walker = nullptr;
        if (FAILED(g_automation->get_RawViewWalker(&walker)) || !walker) break;
        IUIAutomationElement *parent = nullptr;
        if (FAILED(walker->GetParentElement(cur, &parent)) || !parent) {
            walker->Release();
            break;
        }
        QVariantMap pm = elementToMap(parent);
        chain.prepend(pm);
        walker->Release();
        cur->Release();
        cur = parent;
    }
    if (cur) cur->Release();
    el->Release();
    info["parentChain"] = chain;
    return info;
}

bool registerHotkey(WindowElementInspector *insp, const QString &hk)
{
    g_inspector = insp;
    g_hotkeyString = hk;
    // 解析修饰键 + 主键（简化支持 Ctrl+Alt+I）
    UINT mods = 0;
    if (hk.contains("Ctrl", Qt::CaseInsensitive)) mods |= MOD_CONTROL;
    if (hk.contains("Alt", Qt::CaseInsensitive)) mods |= MOD_ALT;
    if (hk.contains("Shift", Qt::CaseInsensitive)) mods |= MOD_SHIFT;
    if (hk.contains("Win", Qt::CaseInsensitive) || hk.contains("Super", Qt::CaseInsensitive)) mods |= MOD_WIN;
    // 主键：取最后一个字符
    QString keyPart = hk.section('+', -1).trimmed();
    if (keyPart.isEmpty()) return false;
    UINT vk = 0;
    if (keyPart.length() == 1) {
        QChar c = keyPart.at(0).toUpper();
        vk = c.toLatin1();
    } else if (keyPart.toLower() == "i") vk = 'I';
    else if (keyPart.toLower() == "p") vk = 'P';
    else vk = keyPart.at(0).toUpper().toLatin1();
    if (vk == 0) return false;
    if (!RegisterHotKey(nullptr, g_hotkeyId, mods, vk)) {
        return false;
    }
    if (!g_filter) {
        g_filter = QSharedPointer<HotkeyEventFilter>::create();
        QGuiApplication::instance()->installNativeEventFilter(g_filter.data());
    }
    return true;
}

void unregisterHotkey()
{
    UnregisterHotKey(nullptr, g_hotkeyId);
    g_inspector = nullptr;
}

bool beginPicking(WindowElementInspector *insp)
{
    g_inspector = insp;
    clearPickingHooks();
    g_picking = true;
    HINSTANCE module = GetModuleHandle(nullptr);
    g_mouseHook = SetWindowsHookEx(WH_MOUSE_LL, mouseHookProc, module, 0);
    g_keyboardHook = SetWindowsHookEx(WH_KEYBOARD_LL, keyboardHookProc, module, 0);
    if (!g_mouseHook || !g_keyboardHook) {
        clearPickingHooks();
        return false;
    }
    SetCursor(LoadCursor(nullptr, IDC_CROSS));
    return true;
}

void endPicking()
{
    clearPickingHooks();
}

} // namespace PlatformBackend
#endif // Q_OS_WIN

// 非 Windows 平台提供空实现以满足链接（macOS 由 .mm 提供，所以只在 Linux 等下生效）
#if !defined(Q_OS_WIN) && !defined(Q_OS_MACOS)
#include <QVariantMap>
#include <QString>

namespace PlatformBackend {
void init(WindowElementInspector*) {}
void shutdown(WindowElementInspector*) {}
bool refreshAccessibility(WindowElementInspector*) { return false; }
void openAccessibilitySettings() {}
void refreshForeground(WindowElementInspector*) {}
QVariantMap getElementAtPoint(int, int) { return {}; }
bool registerHotkey(WindowElementInspector*, const QString&) { return false; }
void unregisterHotkey() {}
bool beginPicking(WindowElementInspector*) { return false; }
void endPicking() {}
} // namespace PlatformBackend
#endif
