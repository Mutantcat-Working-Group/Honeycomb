#ifndef RANDOMIPV6GENERATOR_H
#define RANDOMIPV6GENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>

class RandomIpv6Generator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QString ipType READ ipType WRITE setIpType NOTIFY ipTypeChanged)
    Q_PROPERTY(QString format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit RandomIpv6Generator(QObject *parent = nullptr);

    int count() const;
    void setCount(int count);

    QString ipType() const;
    void setIpType(const QString &ipType);

    QString format() const;
    void setFormat(const QString &format);

    QString result() const;

    Q_INVOKABLE void generate();

signals:
    void countChanged();
    void ipTypeChanged();
    void formatChanged();
    void resultChanged();

private:
    int m_count;
    QString m_ipType;
    QString m_format;
    QString m_result;
    
    QString generateSingleIpv6();
    QString generateGlobalUnicast();
    QString generateLinkLocal();
    QString generateUniqueLocal();
    QString generateMulticast();
    QString formatIpv6(const QString &ipv6, const QString &format);
    QString generateRandomHexSegment(int length);
};

#endif // RANDOMIPV6GENERATOR_H