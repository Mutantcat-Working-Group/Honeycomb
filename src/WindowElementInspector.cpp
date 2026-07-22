#include "WindowElementInspector.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QTimer>
#include <QDateTime>
#include <QGuiApplication>
#include <QCursor>
#include <QStandardPaths>
#include <QProcess>
#include <QVariantList>
#include <QVariantMap>
#include <QDebug>
#include <cmath>

// 前向声明（formatter 用到的辅助静态函数）
static QString clickActionForRole(const QString &role);
static QString appleScriptElementRef(const QJsonObject &o);

// ============================================================
// 平台后端桥接（每个平台后端文件提供以下符号）
// ============================================================
namespace PlatformBackend {
void init(WindowElementInspector *insp);
void shutdown(WindowElementInspector *insp);
bool refreshAccessibility(WindowElementInspector *insp);
bool requestAccessibilityPermission(WindowElementInspector *insp);
void openAccessibilitySettings();
void refreshForeground(WindowElementInspector *insp);
QVariantMap getElementAtPoint(int x, int y);
bool registerHotkey(WindowElementInspector *insp, const QString &hk);
void unregisterHotkey();
bool beginPicking(WindowElementInspector *insp);
void endPicking();
}

// ============================================================
// WindowElementInspector 实现
// ============================================================
WindowElementInspector::WindowElementInspector(QObject *parent)
    : QObject(parent)
{
    m_captureTimer = new QTimer(this);
    m_captureTimer->setSingleShot(true);
    m_captureTimer->setInterval(m_delayMs);
    connect(m_captureTimer, &QTimer::timeout, this, &WindowElementInspector::onCaptureTimerTimeout);

    PlatformBackend::init(this);
    // 初始化时主动刷新一次前台信息
    PlatformBackend::refreshForeground(this);
    setHasAccessibility(PlatformBackend::refreshAccessibility(this));
}

WindowElementInspector::~WindowElementInspector()
{
    PlatformBackend::shutdown(this);
}

bool WindowElementInspector::isWayland() const
{
    return qEnvironmentVariable("XDG_SESSION_TYPE") == "wayland";
}

void WindowElementInspector::setDelayMs(int ms)
{
    if (ms < 0) ms = 0;
    if (m_delayMs != ms) {
        m_delayMs = ms;
        if (m_captureTimer) m_captureTimer->setInterval(ms);
        emit delayMsChanged();
    }
}

void WindowElementInspector::setHotkey(const QString &hk)
{
    if (m_hotkey != hk) {
        m_hotkey = hk;
        emit hotkeyChanged();
    }
}

void WindowElementInspector::setArmed(bool armed)
{
    if (m_armed != armed) {
        m_armed = armed;
        emit armedChanged();
    }
}

void WindowElementInspector::setCapturing(bool capturing)
{
    if (m_capturing != capturing) {
        m_capturing = capturing;
        emit capturingChanged();
    }
}

void WindowElementInspector::setLastError(const QString &msg)
{
    if (m_lastError != msg) {
        m_lastError = msg;
        emit lastErrorChanged();
    }
}

void WindowElementInspector::setHasAccessibility(bool has)
{
    if (m_hasAccessibility != has) {
        m_hasAccessibility = has;
        emit hasAccessibilityChanged();
    }
}

void WindowElementInspector::setLastPicked(const QVariantMap &info)
{
    m_lastPicked = info;
    QJsonDocument doc(QJsonObject::fromVariantMap(info));
    m_lastPickedJson = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));
    emit lastPickedChanged();
}

void WindowElementInspector::setForeground(const QString &app, int pid)
{
    if (m_foregroundApp != app || m_foregroundPid != pid) {
        m_foregroundApp = app;
        m_foregroundPid = pid;
        emit foregroundAppChanged();
    }
}

// 公开接口：供平台后端调用以避免暴露私有 setter
void WindowElementInspector::setForegroundInfo(const QString &app, int pid)
{
    setForeground(app, pid);
}

void WindowElementInspector::pushRecent(const QVariantMap &info)
{
    // 保留最近 5 条；最近的在最前
    QVariantList list;
    list.prepend(info);
    for (int i = 0; i < m_recent.size() && list.size() < 5; ++i) {
        list.append(m_recent.at(i));
    }
    m_recent = list;
    emit recentChanged();
}

// ============================================================
// 抓取主流程
// ============================================================
void WindowElementInspector::startCapture(int delayMs)
{
    if (m_capturing) {
        setLastError(tr("已在抓取中，请先取消"));
        return;
    }
    recheckPermissions();
    if (!m_hasAccessibility) {
        setLastError(tr("请先授予辅助功能权限"));
        return;
    }
    int ms = (delayMs >= 0) ? delayMs : m_delayMs;
    if (m_captureTimer) {
        m_captureTimer->setInterval(ms);
        m_captureTimer->start();
    }
    setCapturing(true);
    setLastError(QString());
}

void WindowElementInspector::cancelCapture()
{
    if (m_captureTimer) m_captureTimer->stop();
    PlatformBackend::endPicking();
    setCapturing(false);
    setLastError(QString());
}

void WindowElementInspector::onCaptureTimerTimeout()
{
    if (!PlatformBackend::beginPicking(this)) {
        setCapturing(false);
        setLastError(tr("无法启动锚点选取，请检查系统权限"));
    }
}

void WindowElementInspector::captureAtPoint(int x, int y)
{
    if (!m_capturing) return;
    QVariantMap info = PlatformBackend::getElementAtPoint(x, y);
    PlatformBackend::endPicking();
    setCapturing(false);
    if (info.isEmpty()) {
        setLastError(tr("未能获取该位置的窗口组件信息"));
        return;
    }
    // 补全时间戳
    info["pickedAt"] = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    info["cursorX"] = x;
    info["cursorY"] = y;
    info["captureMode"] = "anchor";
    setLastPicked(info);
    pushRecent(info);
    emit elementPicked(info);
}

bool WindowElementInspector::registerHotkey()
{
    if (m_armed) return true;
    bool ok = PlatformBackend::registerHotkey(this, m_hotkey);
    setArmed(ok);
    if (!ok) setLastError(tr("注册全局热键失败：%1").arg(m_hotkey));
    else setLastError(QString());
    return ok;
}

void WindowElementInspector::unregisterHotkey()
{
    PlatformBackend::unregisterHotkey();
    setArmed(false);
}

void WindowElementInspector::recheckPermissions()
{
    PlatformBackend::refreshForeground(this);
    bool has = PlatformBackend::refreshAccessibility(this);
    setHasAccessibility(has);
}

bool WindowElementInspector::requestAccessibilityPermission()
{
    const bool has = PlatformBackend::requestAccessibilityPermission(this);
    setHasAccessibility(has);
    return has;
}

void WindowElementInspector::openAccessibilitySettings()
{
    PlatformBackend::openAccessibilitySettings();
}

QVariantMap WindowElementInspector::getElementAtPoint(int x, int y)
{
    return PlatformBackend::getElementAtPoint(x, y);
}

QString WindowElementInspector::getForegroundProcessName() const
{
    return m_foregroundApp;
}

QString WindowElementInspector::getApplicationBundleName() const
{
    return m_foregroundApp; // 平台层如果能拿到更细粒度会覆盖
}

QString WindowElementInspector::currentPlatform() const
{
#if defined(Q_OS_MACOS)
    return "macos";
#elif defined(Q_OS_WIN)
    return "windows";
#else
    return "linux";
#endif
}

// ============================================================
// 4 种格式化输出
// 全部基于传入的 QJson 字符串（QVariantMap 的 JSON 形式）
// ============================================================
static QJsonObject parseJsonObject(const QString &json)
{
    if (json.trimmed().isEmpty()) return QJsonObject();
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    if (!doc.isObject()) return QJsonObject();
    return doc.object();
}

static QString parentChainAsText(const QJsonArray &chain)
{
    // 自底向上
    QStringList parts;
    for (int i = chain.size() - 1; i >= 0; --i) {
        QJsonObject o = chain.at(i).toObject();
        QStringList attr;
        QString role = o.value("role").toString();
        if (!role.isEmpty()) attr << role;
        QString name = o.value("name").toString();
        if (!name.isEmpty()) attr << QString("text=%1").arg(name);
        QString id = o.value("automationId").toString();
        if (!id.isEmpty()) attr << QString("id=%1").arg(id);
        QString cls = o.value("className").toString();
        if (!cls.isEmpty()) attr << QString("class=%1").arg(cls);
        parts << attr.join(",");
    }
    return parts.join(" / ");
}

QString WindowElementInspector::formatNaturalLanguage(const QString &json) const
{
    QJsonObject o = parseJsonObject(json);
    if (o.isEmpty()) return QString();

    QStringList lines;
    const QString appName = o.value("appName").toString("目标应用");
    QString role = o.value("roleDescription").toString();
    if (role.isEmpty()) role = o.value("controlTypeName").toString();
    if (role.isEmpty()) role = o.value("role").toString("控件");
    lines << "【指向组件提示词】";
    lines << QString("请在桌面应用「%1」中定位以下组件，并以可访问性属性为主、屏幕坐标为辅进行操作。").arg(appName);
    const QString bundleId = o.value("bundleId").toString();
    const int pid = o.value("pid").toInt();
    if (!bundleId.isEmpty()) lines << QString("【应用标识】%1").arg(bundleId);
    if (pid > 0) lines << QString("【进程 PID】%1").arg(pid);
    lines << QString("【组件类型】%1").arg(role);
    QString name = o.value("name").toString();
    if (!name.isEmpty())
        lines << QString("【组件名称】%1").arg(name);
    QString automationId = o.value("automationId").toString();
    if (!automationId.isEmpty())
        lines << QString("【自动化标识】%1").arg(automationId);
    QString value = o.value("value").toString();
    if (!value.isEmpty())
        lines << QString("【当前值】%1").arg(value);
    QJsonObject rect = o.value("rect").toObject();
    if (!rect.isEmpty()) {
        lines << QString("【位置】x=%1 y=%2 w=%3 h=%4")
                     .arg(rect.value("x").toInt()).arg(rect.value("y").toInt())
                     .arg(rect.value("width").toInt()).arg(rect.value("height").toInt());
    }
    if (o.contains("cursorX") && o.contains("cursorY")) {
        lines << QString("【选取锚点】x=%1 y=%2")
                     .arg(o.value("cursorX").toInt()).arg(o.value("cursorY").toInt());
    }
    QJsonArray actions = o.value("actions").toArray();
    if (!actions.isEmpty()) {
        QStringList al;
        for (auto v : actions) al << v.toString();
        lines << QString("【可用动作】%1").arg(al.join("、"));
    }
    QJsonArray chain = o.value("parentChain").toArray();
    const QString path = parentChainAsText(chain);
    if (!path.isEmpty()) lines << QString("【层级路径】%1").arg(path);
    return lines.join("\n");
}

QString WindowElementInspector::formatStructuredPath(const QString &json) const
{
    QJsonObject o = parseJsonObject(json);
    if (o.isEmpty()) return QString();

    QStringList parts;
    QString app = o.value("appName").toString();
    if (!app.isEmpty()) parts << QString("Application[%1]").arg(app);

    QJsonArray chain = o.value("parentChain").toArray();
    // 自底向上
    for (int i = chain.size() - 1; i >= 0; --i) {
        QJsonObject p = chain.at(i).toObject();
        QStringList attrs;
        QString role = p.value("role").toString();
        if (role.isEmpty()) role = p.value("controlTypeName").toString();
        if (!role.isEmpty()) attrs << role;
        QString name = p.value("name").toString();
        QString id = p.value("automationId").toString();
        if (!id.isEmpty()) attrs << QString("id=%1").arg(id);
        else if (!name.isEmpty()) attrs << QString("text=%1").arg(name);
        parts << attrs.join("[") + (attrs.size() > 1 ? "]" : "");
    }

    // 加上目标本身
    QStringList selfAttrs;
    QString selfRole = o.value("role").toString();
    if (selfRole.isEmpty()) selfRole = o.value("controlTypeName").toString();
    if (!selfRole.isEmpty()) selfAttrs << selfRole;
    QString selfName = o.value("name").toString();
    QString selfId = o.value("automationId").toString();
    if (!selfId.isEmpty()) selfAttrs << QString("id=%1").arg(selfId);
    else if (!selfName.isEmpty()) selfAttrs << QString("text=%1").arg(selfName);
    parts << selfAttrs.join("");

    return parts.join(" / ");
}

QString WindowElementInspector::formatJsonPretty(const QString &json) const
{
    QJsonObject o = parseJsonObject(json);
    if (o.isEmpty()) return QString();
    QJsonDocument doc(o);
    return QString::fromUtf8(doc.toJson(QJsonDocument::Indented));
}

QString WindowElementInspector::formatExecutableScript(const QString &json, const QString &platform) const
{
    QJsonObject o = parseJsonObject(json);
    if (o.isEmpty()) return QString();
    QString pf = (platform == "auto") ? currentPlatform() : platform;

    if (pf == "macos") {
        QStringList lines;
        lines << "tell application \"System Events\"";
        QString proc = o.value("bundleId").toString();
        if (proc.isEmpty()) proc = o.value("appName").toString();
        if (!proc.isEmpty()) {
            lines << QString("\ttell process \"%1\"").arg(proc);
            // 简化的 path 生成：直接拼 window 1
            lines << "\t\ttell window 1";
            lines << QString("\t\t\t%1 %2")
                         .arg(clickActionForRole(o.value("role").toString()),
                              appleScriptElementRef(o));
            lines << "\t\tend tell";
            lines << "\tend tell";
        }
        lines << "end tell";
        return lines.join("\n");
    }
    else if (pf == "windows") {
        // PowerShell UIA snippet
        QStringList lines;
        lines << "Add-Type -AssemblyName UIAutomationClient";
        lines << "$root = [System.Windows.Automation.AutomationElement]::RootElement";
        QString id = o.value("automationId").toString();
        QString name = o.value("name").toString();
        QString cls = o.value("className").toString();
        QStringList conds;
        if (!id.isEmpty())
            conds << QString("[System.Windows.Automation.AutomationElement]::AutomationIdProperty, \"%1\"").arg(id);
        else if (!name.isEmpty())
            conds << QString("[System.Windows.Automation.AutomationElement]::NameProperty, \"%1\"").arg(name);
        else if (!cls.isEmpty())
            conds << QString("[System.Windows.Automation.AutomationElement]::ClassNameProperty, \"%1\"").arg(cls);
        QString cond = conds.value(0, "...");
        lines << QString("$cond = New-Object System.Windows.Automation.PropertyCondition(%1)").arg(cond);
        lines << "$el = $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)";
        // 动作
        QString role = o.value("role").toString();
        QString ctrlName = o.value("controlTypeName").toString();
        if (ctrlName == "Button" || role == "AXButton" || role == "Button") {
            lines << "$ip = $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)";
            lines << "$ip.Invoke()";
        } else {
            lines << "$vp = $el.GetCurrentPattern([System.Windows.Automation.ValuePattern]::Pattern)";
            lines << "if ($vp) { $vp.SetValue(\"REPLACE_ME\") }";
        }
        return lines.join("\n");
    }
    else {
        // linux: bash + xdotool + dbus-send
        QStringList lines;
        lines << "#!/usr/bin/env bash";
        lines << "set -e";
        QJsonObject rect = o.value("rect").toObject();
        int cx = rect.value("x").toInt() + rect.value("width").toInt() / 2;
        int cy = rect.value("y").toInt() + rect.value("height").toInt() / 2;
        lines << QString("xdotool mousemove %1 %2").arg(cx).arg(cy);
        lines << QString("xdotool click %1").arg(1);
        return lines.join("\n");
    }
}

static QString clickActionForRole(const QString &role)
{
    if (role == "AXButton") return "click";
    if (role == "AXCheckBox") return "click";
    if (role == "AXTextField" || role == "AXTextArea") return "set value of";
    if (role == "AXPopUpButton") return "click";
    if (role == "AXMenuItem") return "click menu item";
    return "click";
}

static QString appleScriptElementRef(const QJsonObject &o)
{
    QStringList parts;
    QString role = o.value("role").toString();
    QString name = o.value("name").toString();
    QString desc = o.value("roleDescription").toString();
    if (!name.isEmpty()) parts << QString("\"%1\"").arg(name);
    else if (!role.isEmpty()) parts << QString("%1 1").arg(role);
    if (!desc.isEmpty()) parts << QString("// %1").arg(desc);
    return parts.join(" ");
}

// ============================================================
// 平台后端实现位于 WindowElementInspector_mac.mm / _win.cpp / _linux.cpp
// 每个文件提供一个 namespace PlatformBackend { ... } 实现
// ============================================================
