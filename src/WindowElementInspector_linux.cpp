// WindowElementInspector_linux.cpp
// Linux 后端：AT-SPI2 over QtDBus + xdotool/dbus-send 脚本生成
#include "WindowElementInspector.h"

#if defined(Q_OS_LINUX)
#include <QJsonObject>
#include <QJsonArray>
#include <QVariantMap>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusObjectPath>
#include <QDBusArgument>
#include <QProcess>
#include <QGuiApplication>
#include <QTimer>

namespace {
QDBusInterface *g_atspiDesktop = nullptr;
bool g_atspiAvailable = false;
WindowElementInspector *g_inspector = nullptr;
QString g_hotkeyString;
QTimer *g_x11HotkeyTimer = nullptr;
}

static QString dbusPath(const QDBusObjectPath &p) { return p.path(); }
static QString dbusString(const QVariant &v) { return v.toString(); }

static QVariantMap readAccessible(const QDBusObjectPath &path, int depth = 0)
{
    QVariantMap m;
    if (depth > 6 || path.path().isEmpty()) return m;
    QDBusInterface iface("org.a11y.atspi.Registry", path.path(),
                         "org.a11y.atspi.Accessible",
                         QDBusConnection::sessionBus());
    if (!iface.isValid()) return m;

    QDBusReply<QString> nameR = iface.call("GetName");
    QDBusReply<int> roleR = iface.call("GetRole");
    QDBusReply<QString> descR = iface.call("GetDescription");
    QDBusReply<QString> appR = iface.call("GetApplication");
    QVariantMap attrMap;
    QDBusReply<QVariantMap> attrsR = iface.call("GetAttributes");
    if (attrsR.isValid()) attrMap = attrsR.value();

    m["name"] = nameR.value();
    m["role"] = QString("AT-SPI:%1").arg(roleR.value());
    m["roleDescription"] = descR.value();
    m["appName"] = appR.value();

    // 状态
    QDBusReply<QVariantList> stateR = iface.call("GetState");
    if (stateR.isValid()) {
        QVariantList st = stateR.value();
        QVariantList enabledList;
        for (int i = 0; i < st.size(); i += 2) {
            if (st.at(i).toInt() == 1) enabledList << "ENABLED";
        }
        m["state"] = st;
    }

    // 动作
    QDBusReply<int> nActionsR = iface.call("NAccessibleActions");
    if (nActionsR.isValid() && nActionsR.value() > 0) {
        QVariantList acts;
        for (int i = 0; i < nActionsR.value(); ++i) {
            QDBusReply<QString> a = iface.call("GetAccessibleActionName", i);
            if (a.isValid()) acts << a.value();
        }
        m["actions"] = acts;
    }

    // 属性 a{ss}（如坐标、class name）
    if (attrMap.contains("container-children")) {}
    QString cls = attrMap.value("class").toString();
    if (!cls.isEmpty()) m["className"] = cls;
    QString rectStr = attrMap.value("extents").toString();
    if (!rectStr.isEmpty()) {
        // 格式："x,y,width,height"
        QStringList parts = rectStr.split(',');
        if (parts.size() == 4) {
            QVariantMap rect;
            rect["x"] = parts.at(0).toInt();
            rect["y"] = parts.at(1).toInt();
            rect["width"] = parts.at(2).toInt();
            rect["height"] = parts.at(3).toInt();
            m["rect"] = rect;
        }
    }
    return m;
}

namespace PlatformBackend {

void init(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    if (!QDBusConnection::sessionBus().interface()->isServiceRegistered("org.a11y.atspi.Registry")) {
        g_atspiAvailable = false;
        return;
    }
    g_atspiDesktop = new QDBusInterface("org.a11y.atspi.Registry",
                                       "/org/a11y/atspi/accessible/root",
                                       "org.a11y.atspi.Accessible",
                                       QDBusConnection::sessionBus());
    g_atspiAvailable = (g_atspiDesktop && g_atspiDesktop->isValid());
}

void shutdown(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    if (g_atspiDesktop) { delete g_atspiDesktop; g_atspiDesktop = nullptr; }
}

bool refreshAccessibility(WindowElementInspector *insp)
{
    Q_UNUSED(insp)
    return g_atspiAvailable;
}

void openAccessibilitySettings()
{
    // 提示安装 at-spi2-core
    QProcess::startDetached("xdg-open", {"https://gitlab.gnome.org/GNOME/at-spi2-core"});
}

void refreshForeground(WindowElementInspector *insp)
{
    if (!insp || !g_atspiAvailable || !g_atspiDesktop) return;
    QDBusReply<QString> nameR = g_atspiDesktop->call("GetName");
    QDBusReply<QString> appR = g_atspiDesktop->call("GetApplication");
    QString display = !appR.value().isEmpty() ? appR.value() : nameR.value();
    insp->setForegroundInfo(display, 0);
}

QVariantMap getElementAtPoint(int x, int y)
{
    if (!g_atspiAvailable) return QVariantMap();
    QDBusInterface desktop("org.a11y.atspi.Registry", "/org/a11y/atspi/desktop",
                           "org.a11y.atspi.Desktop",
                           QDBusConnection::sessionBus());
    if (!desktop.isValid()) return QVariantMap();
    QDBusReply<QDBusObjectPath> r = desktop.call("FindAccessibleAt", x, y, "ROOT");
    if (!r.isValid() || r.value().path().isEmpty()) return QVariantMap();
    QVariantMap info = readAccessible(r.value());

    // 父链
    QVariantList chain;
    QDBusObjectPath cur = r.value();
    for (int i = 0; i < 6; ++i) {
        QDBusInterface iface("org.a11y.atspi.Registry", cur.path(),
                             "org.a11y.atspi.Accessible",
                             QDBusConnection::sessionBus());
        if (!iface.isValid()) break;
        QDBusReply<QDBusObjectPath> p = iface.call("GetParent");
        if (!p.isValid() || p.value().path().isEmpty()) break;
        QVariantMap pm = readAccessible(p.value(), i + 1);
        chain.prepend(pm);
        cur = p.value();
    }
    info["parentChain"] = chain;
    return info;
}

// X11 全局热键（需要 Xlib；简化实现：用 xdotool 轮询 + python keybind 模拟；这里仅占位）
bool registerHotkey(WindowElementInspector *insp, const QString &hk)
{
    g_inspector = insp;
    g_hotkeyString = hk;
    // Wayland 走不通：直接返回 false，让 QML 显示提示
    if (qEnvironmentVariable("XDG_SESSION_TYPE") == "wayland") {
        return false;
    }
    // 当前未安装真实的 X11 全局监听器，不能报告虚假的注册成功。
    return false;
}

void unregisterHotkey()
{
    g_inspector = nullptr;
    if (g_x11HotkeyTimer) { g_x11HotkeyTimer->stop(); delete g_x11HotkeyTimer; g_x11HotkeyTimer = nullptr; }
}

bool beginPicking(WindowElementInspector*) { return false; }
void endPicking() {}

} // namespace PlatformBackend

// 非 Linux 且非 macOS 平台（即 Windows）提供空实现以满足链接
#elif !defined(Q_OS_MACOS)
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
#endif // Q_OS_LINUX
