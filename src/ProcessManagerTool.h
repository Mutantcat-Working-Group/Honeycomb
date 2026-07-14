#ifndef PROCESSMANAGERTOOL_H
#define PROCESSMANAGERTOOL_H

#include <QObject>
#include <QVariantList>

class ProcessManagerTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList processes READ processes NOTIFY dataChanged)
    Q_PROPERTY(QVariantList ports READ ports NOTIFY dataChanged)
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)

public:
    explicit ProcessManagerTool(QObject *parent = nullptr);

    QVariantList processes() const;
    QVariantList ports() const;
    QString message() const;

    Q_INVOKABLE void refreshProcesses();
    Q_INVOKABLE void refreshPorts();
    Q_INVOKABLE bool killProcess(int pid);
    Q_INVOKABLE bool killPort(int port);
    Q_INVOKABLE QString platformName() const;

signals:
    void dataChanged();
    void messageChanged();

private:
    QString resolveProgram(const QString &program) const;
    QString runCommand(const QString &program, const QStringList &arguments, int timeoutMs = 5000) const;
    void setMessage(const QString &message);
    QVariantMap processByPid(int pid) const;

    QVariantList m_processes;
    QVariantList m_ports;
    QString m_message;
};

#endif // PROCESSMANAGERTOOL_H
