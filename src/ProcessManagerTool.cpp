#include "ProcessManagerTool.h"

#include <QProcess>
#include <QRegularExpression>
#include <QSet>
#include <QFileInfo>
#include <QtGlobal>

ProcessManagerTool::ProcessManagerTool(QObject *parent)
    : QObject(parent)
{
    refreshProcesses();
    refreshPorts();
}

QVariantList ProcessManagerTool::processes() const
{
    return m_processes;
}

QVariantList ProcessManagerTool::ports() const
{
    return m_ports;
}

QString ProcessManagerTool::message() const
{
    return m_message;
}

QString ProcessManagerTool::platformName() const
{
#if defined(Q_OS_WIN)
    return QStringLiteral("Windows");
#elif defined(Q_OS_MACOS)
    return QStringLiteral("macOS");
#elif defined(Q_OS_LINUX)
    return QStringLiteral("Linux");
#else
    return QStringLiteral("Unix-like");
#endif
}

void ProcessManagerTool::refreshProcesses()
{
    m_processes.clear();
#if defined(Q_OS_WIN)
    const QString output = runCommand(QStringLiteral("tasklist"), {QStringLiteral("/FO"), QStringLiteral("CSV"), QStringLiteral("/NH")});
    const QStringList lines = output.split(QRegularExpression(QStringLiteral("[\r\n]+")), Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        QStringList parts;
        QRegularExpression re(QStringLiteral("\"([^\"]*)\""));
        auto it = re.globalMatch(line);
        while (it.hasNext()) {
            parts.append(it.next().captured(1));
        }
        if (parts.size() < 5) {
            continue;
        }
        QVariantMap row;
        row.insert(QStringLiteral("pid"), parts.at(1).toInt());
        row.insert(QStringLiteral("name"), parts.at(0));
        row.insert(QStringLiteral("user"), parts.at(2));
        row.insert(QStringLiteral("cpu"), QString());
        row.insert(QStringLiteral("memory"), parts.at(4));
        m_processes.append(row);
    }
#else
    const QString output = runCommand(QStringLiteral("ps"), {QStringLiteral("-axo"), QStringLiteral("pid=,user=,pcpu=,pmem=,comm=")});
    const QStringList lines = output.split(QRegularExpression(QStringLiteral("[\r\n]+")), Qt::SkipEmptyParts);
    QRegularExpression re(QStringLiteral("^\\s*(\\d+)\\s+(\\S+)\\s+(\\S+)\\s+(\\S+)\\s+(.+)$"));
    for (const QString &line : lines) {
        auto match = re.match(line);
        if (!match.hasMatch()) {
            continue;
        }
        QVariantMap row;
        row.insert(QStringLiteral("pid"), match.captured(1).toInt());
        row.insert(QStringLiteral("user"), match.captured(2));
        row.insert(QStringLiteral("cpu"), match.captured(3));
        row.insert(QStringLiteral("memory"), match.captured(4));
        row.insert(QStringLiteral("name"), match.captured(5));
        m_processes.append(row);
    }
#endif
    setMessage(QStringLiteral("已加载进程：%1").arg(m_processes.size()));
    emit dataChanged();
}

void ProcessManagerTool::refreshPorts()
{
    m_ports.clear();
#if defined(Q_OS_WIN)
    const QString output = runCommand(QStringLiteral("netstat"), {QStringLiteral("-ano")});
    const QStringList lines = output.split(QRegularExpression(QStringLiteral("[\r\n]+")), Qt::SkipEmptyParts);
    QRegularExpression re(QStringLiteral("^\\s*TCP\\s+\\S+:(\\d+)\\s+\\S+\\s+LISTENING\\s+(\\d+)"), QRegularExpression::CaseInsensitiveOption);
    for (const QString &line : lines) {
        auto match = re.match(line);
        if (!match.hasMatch()) {
            continue;
        }
        const int pid = match.captured(2).toInt();
        const QVariantMap proc = processByPid(pid);
        QVariantMap row;
        row.insert(QStringLiteral("port"), match.captured(1).toInt());
        row.insert(QStringLiteral("pid"), pid);
        row.insert(QStringLiteral("protocol"), QStringLiteral("TCP"));
        row.insert(QStringLiteral("command"), proc.value(QStringLiteral("name")).toString());
        row.insert(QStringLiteral("address"), QStringLiteral("LISTENING"));
        m_ports.append(row);
    }
#else
    const QString output = runCommand(QStringLiteral("lsof"), {QStringLiteral("-nP"), QStringLiteral("-iTCP"), QStringLiteral("-sTCP:LISTEN")});
    const QStringList lines = output.split(QRegularExpression(QStringLiteral("[\r\n]+")), Qt::SkipEmptyParts);
    QRegularExpression portRe(QStringLiteral("(.+):(\\d+)\\s+\\(LISTEN\\)$"));
    QSet<QString> seen;
    for (int i = 1; i < lines.size(); ++i) {
        const QStringList parts = lines.at(i).simplified().split(QLatin1Char(' '));
        if (parts.size() < 9) {
            continue;
        }
        const QString name = parts.mid(8).join(QStringLiteral(" "));
        auto match = portRe.match(name);
        if (!match.hasMatch()) {
            continue;
        }
        const QString key = parts.at(1) + QStringLiteral(":") + match.captured(2);
        if (seen.contains(key)) {
            continue;
        }
        seen.insert(key);
        QString command = parts.at(0);
        command.replace(QStringLiteral("\\x20"), QStringLiteral(" "));
        QVariantMap row;
        row.insert(QStringLiteral("command"), command);
        row.insert(QStringLiteral("pid"), parts.at(1).toInt());
        row.insert(QStringLiteral("protocol"), QStringLiteral("TCP"));
        row.insert(QStringLiteral("address"), match.captured(1));
        row.insert(QStringLiteral("port"), match.captured(2).toInt());
        m_ports.append(row);
    }
#endif
    setMessage(QStringLiteral("已加载监听端口：%1").arg(m_ports.size()));
    emit dataChanged();
}

bool ProcessManagerTool::killProcess(int pid)
{
    if (pid <= 0) {
        setMessage(QStringLiteral("PID无效"));
        return false;
    }
#if defined(Q_OS_WIN)
    const QString output = runCommand(QStringLiteral("taskkill"), {QStringLiteral("/PID"), QString::number(pid), QStringLiteral("/F")});
#else
    const QString output = runCommand(QStringLiteral("kill"), {QStringLiteral("-9"), QString::number(pid)});
#endif
    Q_UNUSED(output)
    setMessage(QStringLiteral("已发送结束进程指令: %1").arg(pid));
    refreshProcesses();
    refreshPorts();
    return true;
}

bool ProcessManagerTool::killPort(int port)
{
    if (port <= 0) {
        setMessage(QStringLiteral("端口无效"));
        return false;
    }
    refreshPorts();
    bool killed = false;
    QSet<int> pids;
    for (const QVariant &item : m_ports) {
        const QVariantMap row = item.toMap();
        if (row.value(QStringLiteral("port")).toInt() == port) {
            pids.insert(row.value(QStringLiteral("pid")).toInt());
        }
    }
    for (int pid : pids) {
        if (killProcess(pid)) {
            killed = true;
        }
    }
    if (!killed) {
        setMessage(QStringLiteral("没有找到占用端口 %1 的进程").arg(port));
    }
    return killed;
}

QString ProcessManagerTool::runCommand(const QString &program, const QStringList &arguments, int timeoutMs) const
{
    QProcess process;
    process.start(resolveProgram(program), arguments);
    if (!process.waitForFinished(timeoutMs)) {
        process.kill();
        process.waitForFinished(1000);
    }
    return QString::fromLocal8Bit(process.readAllStandardOutput()) + QString::fromLocal8Bit(process.readAllStandardError());
}

QString ProcessManagerTool::resolveProgram(const QString &program) const
{
#if defined(Q_OS_MACOS)
    if (program == QStringLiteral("ps")) {
        return QStringLiteral("/bin/ps");
    }
    if (program == QStringLiteral("lsof")) {
        return QStringLiteral("/usr/sbin/lsof");
    }
    if (program == QStringLiteral("kill")) {
        return QStringLiteral("/bin/kill");
    }
#elif defined(Q_OS_LINUX)
    if (program == QStringLiteral("ps") && QFileInfo::exists(QStringLiteral("/bin/ps"))) {
        return QStringLiteral("/bin/ps");
    }
    if (program == QStringLiteral("lsof") && QFileInfo::exists(QStringLiteral("/usr/bin/lsof"))) {
        return QStringLiteral("/usr/bin/lsof");
    }
    if (program == QStringLiteral("kill") && QFileInfo::exists(QStringLiteral("/bin/kill"))) {
        return QStringLiteral("/bin/kill");
    }
#endif
    return program;
}

void ProcessManagerTool::setMessage(const QString &message)
{
    if (m_message != message) {
        m_message = message;
        emit messageChanged();
    }
}

QVariantMap ProcessManagerTool::processByPid(int pid) const
{
    for (const QVariant &item : m_processes) {
        const QVariantMap row = item.toMap();
        if (row.value(QStringLiteral("pid")).toInt() == pid) {
            return row;
        }
    }
    return QVariantMap();
}
