#ifndef ENVIRONMENTPATHTOOL_H
#define ENVIRONMENTPATHTOOL_H

#include <QObject>
#include <QString>
#include <QVariantList>

class EnvironmentPathTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString pathValue READ pathValue NOTIFY pathChanged)
    Q_PROPERTY(QString separator READ separator NOTIFY pathChanged)
    Q_PROPERTY(QString platformName READ platformName CONSTANT)
    Q_PROPERTY(int pathCount READ pathCount NOTIFY pathChanged)
    Q_PROPERTY(int existingCount READ existingCount NOTIFY pathChanged)
    Q_PROPERTY(int missingCount READ missingCount NOTIFY pathChanged)
    Q_PROPERTY(int duplicateCount READ duplicateCount NOTIFY pathChanged)
    Q_PROPERTY(QVariantList entries READ pathEntries NOTIFY pathChanged)

public:
    explicit EnvironmentPathTool(QObject *parent = nullptr);

    QString pathValue() const;
    QString separator() const;
    QString platformName() const;
    int pathCount() const;
    int existingCount() const;
    int missingCount() const;
    int duplicateCount() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantList pathEntries() const;
    Q_INVOKABLE QString normalizedPathText() const;
    Q_INVOKABLE QString uniqueExistingPathText() const;
    Q_INVOKABLE QString commandForShell(const QString &shell, const QString &pathToAdd) const;

signals:
    void pathChanged();

private:
    void rebuildEntries();
    QString normalizePath(const QString &path) const;

    QString m_pathValue;
    QString m_separator;
    QVariantList m_entries;
    int m_existingCount;
    int m_missingCount;
    int m_duplicateCount;
};

#endif // ENVIRONMENTPATHTOOL_H
