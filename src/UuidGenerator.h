#ifndef UUIDGENERATOR_H
#define UUIDGENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>
#include <QUuid>

class UuidGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QString version READ version WRITE setVersion NOTIFY versionChanged)
    Q_PROPERTY(QString format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit UuidGenerator(QObject *parent = nullptr);

    int count() const;
    void setCount(int count);

    QString version() const;
    void setVersion(const QString &version);

    QString format() const;
    void setFormat(const QString &format);

    QString result() const;

    Q_INVOKABLE void generate();

signals:
    void countChanged();
    void versionChanged();
    void formatChanged();
    void resultChanged();

private:
    int m_count;
    QString m_version;
    QString m_format;
    QString m_result;
    
    QString generateSingleUuid();
    QString formatUuid(const QString &uuid, const QString &format);
};

#endif // UUIDGENERATOR_H