#include "EnvironmentPathTool.h"

#include <QDir>
#include <QFileInfo>
#include <QProcessEnvironment>
#include <QSet>
#include <QtGlobal>

EnvironmentPathTool::EnvironmentPathTool(QObject *parent)
    : QObject(parent)
    , m_separator(QString(QDir::listSeparator()))
    , m_existingCount(0)
    , m_missingCount(0)
    , m_duplicateCount(0)
{
    refresh();
}

QString EnvironmentPathTool::pathValue() const
{
    return m_pathValue;
}

QString EnvironmentPathTool::separator() const
{
    return m_separator;
}

QString EnvironmentPathTool::platformName() const
{
#if defined(Q_OS_WIN)
    return QStringLiteral("Windows");
#elif defined(Q_OS_MACOS)
    return QStringLiteral("macOS");
#elif defined(Q_OS_LINUX)
    return QStringLiteral("Linux");
#elif defined(Q_OS_FREEBSD)
    return QStringLiteral("FreeBSD");
#else
    return QStringLiteral("Unix-like");
#endif
}

int EnvironmentPathTool::pathCount() const
{
    return m_entries.size();
}

int EnvironmentPathTool::existingCount() const
{
    return m_existingCount;
}

int EnvironmentPathTool::missingCount() const
{
    return m_missingCount;
}

int EnvironmentPathTool::duplicateCount() const
{
    return m_duplicateCount;
}

void EnvironmentPathTool::refresh()
{
    m_pathValue = QProcessEnvironment::systemEnvironment().value(QStringLiteral("PATH"));
    m_separator = QString(QDir::listSeparator());
    rebuildEntries();
    emit pathChanged();
}

QVariantList EnvironmentPathTool::pathEntries() const
{
    return m_entries;
}

QString EnvironmentPathTool::normalizedPathText() const
{
    QStringList lines;
    for (const QVariant &entryVariant : m_entries) {
        const QVariantMap entry = entryVariant.toMap();
        lines.append(entry.value(QStringLiteral("path")).toString());
    }
    return lines.join(QStringLiteral("\n"));
}

QString EnvironmentPathTool::uniqueExistingPathText() const
{
    QStringList lines;
    for (const QVariant &entryVariant : m_entries) {
        const QVariantMap entry = entryVariant.toMap();
        if (entry.value(QStringLiteral("exists")).toBool() && !entry.value(QStringLiteral("duplicate")).toBool()) {
            lines.append(entry.value(QStringLiteral("path")).toString());
        }
    }
    return lines.join(m_separator);
}

QString EnvironmentPathTool::commandForShell(const QString &shell, const QString &pathToAdd) const
{
    QString path = pathToAdd.trimmed();
    if (path.isEmpty()) {
#if defined(Q_OS_WIN)
        path = QStringLiteral("C:\\Tools\\bin");
#else
        path = QStringLiteral("/usr/local/bin");
#endif
    }

    const QString shellKey = shell.trimmed().toLower();
    if (shellKey == QStringLiteral("powershell")) {
        return QStringLiteral("$env:Path = \"%1;\" + $env:Path").arg(path);
    }
    if (shellKey == QStringLiteral("cmd")) {
        return QStringLiteral("set PATH=%1;%PATH%").arg(path);
    }
    if (shellKey == QStringLiteral("fish")) {
        return QStringLiteral("set -gx PATH %1 $PATH").arg(path);
    }
    return QStringLiteral("export PATH=\"%1:$PATH\"").arg(path);
}

void EnvironmentPathTool::rebuildEntries()
{
    m_entries.clear();
    m_existingCount = 0;
    m_missingCount = 0;
    m_duplicateCount = 0;

    QSet<QString> seen;
    const QStringList parts = m_pathValue.split(QDir::listSeparator(), Qt::KeepEmptyParts);
    for (int i = 0; i < parts.size(); ++i) {
        const QString path = parts.at(i).trimmed();
        if (path.isEmpty()) {
            continue;
        }

        const QString normalized = normalizePath(path);
        const bool duplicate = seen.contains(normalized);
        seen.insert(normalized);

        QFileInfo info(path);
        const bool exists = info.exists() && info.isDir();
        if (exists) {
            ++m_existingCount;
        } else {
            ++m_missingCount;
        }
        if (duplicate) {
            ++m_duplicateCount;
        }

        QVariantMap entry;
        entry.insert(QStringLiteral("index"), m_entries.size() + 1);
        entry.insert(QStringLiteral("path"), path);
        entry.insert(QStringLiteral("exists"), exists);
        entry.insert(QStringLiteral("duplicate"), duplicate);
        entry.insert(QStringLiteral("writable"), exists && info.isWritable());
        m_entries.append(entry);
    }
}

QString EnvironmentPathTool::normalizePath(const QString &path) const
{
    QString value = QDir::cleanPath(path.trimmed());
#if defined(Q_OS_WIN)
    value = value.toLower();
#endif
    return value;
}
