#ifndef WINDOWELEMENTINSPECTOR_H
#define WINDOWELEMENTINSPECTOR_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>

// 跨平台「窗口组件选取」主类（QML 类型：WindowElementInspector）
// 平台特定后端在 WindowElementInspector_mac.mm / _win.cpp / _linux.cpp 中实现。
class WindowElementInspector : public QObject
{
    Q_OBJECT
    // 状态
    Q_PROPERTY(bool armed READ armed NOTIFY armedChanged)
    Q_PROPERTY(bool capturing READ capturing NOTIFY capturingChanged)
    Q_PROPERTY(int delayMs READ delayMs WRITE setDelayMs NOTIFY delayMsChanged)
    Q_PROPERTY(QString hotkey READ hotkey WRITE setHotkey NOTIFY hotkeyChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)
    Q_PROPERTY(bool hasAccessibility READ hasAccessibility NOTIFY hasAccessibilityChanged)
    Q_PROPERTY(bool isWayland READ isWayland CONSTANT)
    // 当前抓取到的元素
    Q_PROPERTY(QVariantMap lastPicked READ lastPicked NOTIFY lastPickedChanged)
    Q_PROPERTY(QString lastPickedJson READ lastPickedJson NOTIFY lastPickedChanged)
    // 前台应用
    Q_PROPERTY(QString foregroundApp READ foregroundApp NOTIFY foregroundAppChanged)
    Q_PROPERTY(int foregroundPid READ foregroundPid NOTIFY foregroundAppChanged)
    // 最近 5 次抓取
    Q_PROPERTY(QVariantList recent READ recent NOTIFY recentChanged)

public:
    explicit WindowElementInspector(QObject *parent = nullptr);
    ~WindowElementInspector() override;

    // Getters
    bool armed() const { return m_armed; }
    bool capturing() const { return m_capturing; }
    int delayMs() const { return m_delayMs; }
    QString hotkey() const { return m_hotkey; }
    QString lastError() const { return m_lastError; }
    bool hasAccessibility() const { return m_hasAccessibility; }
    bool isWayland() const;
    QVariantMap lastPicked() const { return m_lastPicked; }
    QString lastPickedJson() const { return m_lastPickedJson; }
    QString foregroundApp() const { return m_foregroundApp; }
    int foregroundPid() const { return m_foregroundPid; }
    QVariantList recent() const { return m_recent; }

    // Setters
    void setDelayMs(int ms);
    void setHotkey(const QString &hk);

    // ===== 抓取主流程 =====
    // 启动锚点选取：可选启动延迟，-1 使用成员 delayMs，0 立即开始。
    Q_INVOKABLE void startCapture(int delayMs = -1);
    Q_INVOKABLE void cancelCapture();
    Q_INVOKABLE void captureAtPoint(int x, int y);

    // 平台全局热键
    Q_INVOKABLE bool registerHotkey();
    Q_INVOKABLE void unregisterHotkey();

    // 平台权限（macOS 主要）
    Q_INVOKABLE void recheckPermissions();
    Q_INVOKABLE bool requestAccessibilityPermission();
    Q_INVOKABLE void openAccessibilitySettings();

    // 主动查询（非延迟、无信号），同步返回
    Q_INVOKABLE QVariantMap getElementAtPoint(int x, int y);
    Q_INVOKABLE QString getForegroundProcessName() const;
    Q_INVOKABLE QString getApplicationBundleName() const;

    // ===== 4 种格式化输出 =====
    Q_INVOKABLE QString formatNaturalLanguage(const QString &json) const;
    Q_INVOKABLE QString formatStructuredPath(const QString &json) const;
    Q_INVOKABLE QString formatJsonPretty(const QString &json) const;
    // platform: "auto" / "macos" / "windows" / "linux"
    Q_INVOKABLE QString formatExecutableScript(const QString &json, const QString &platform = "auto") const;

    // 平台后端用于写入前台信息（公开以便 .mm / _win.cpp / _linux.cpp 调用）
    void setForegroundInfo(const QString &app, int pid);

signals:
    void armedChanged();
    void capturingChanged();
    void delayMsChanged();
    void hotkeyChanged();
    void lastErrorChanged();
    void hasAccessibilityChanged();
    void lastPickedChanged();
    void foregroundAppChanged();
    void recentChanged();
    void elementPicked(const QVariantMap &info);

private slots:
    void onCaptureTimerTimeout();

private:
    void setArmed(bool armed);
    void setCapturing(bool capturing);
    void setLastError(const QString &msg);
    void setHasAccessibility(bool has);
    void setLastPicked(const QVariantMap &info);
    void setForeground(const QString &app, int pid);
    void pushRecent(const QVariantMap &info);
    // 平台实现（在 .mm / _win.cpp / _linux.cpp 中）
    void platformInit();
    void platformShutdown();
    void platformRefreshAccessibility();
    void platformOpenAccessibilitySettings();
    void platformRefreshForeground();
    QVariantMap platformGetElementAtPoint(int x, int y);
    void platformRegisterHotkey(const QString &hk);
    void platformUnregisterHotkey();
    QString currentPlatform() const; // "macos" / "windows" / "linux"

    // 状态
    bool m_armed = false;
    bool m_capturing = false;
    int m_delayMs = 300;
    QString m_hotkey = "Ctrl+Alt+I";
    QString m_lastError;
    bool m_hasAccessibility = false;
    QVariantMap m_lastPicked;
    QString m_lastPickedJson;
    QString m_foregroundApp;
    int m_foregroundPid = 0;
    QVariantList m_recent;
    class QTimer *m_captureTimer = nullptr;
    class QObject *m_platformObj = nullptr; // 平台私有句柄
};

#endif // WINDOWELEMENTINSPECTOR_H
