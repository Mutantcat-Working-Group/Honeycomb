#ifndef RANDOMIPV4GENERATOR_H
#define RANDOMIPV4GENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>

class RandomIpv4Generator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QString ipType READ ipType WRITE setIpType NOTIFY ipTypeChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit RandomIpv4Generator(QObject *parent = nullptr);

    int count() const;
    void setCount(int count);

    QString ipType() const;
    void setIpType(const QString &ipType);

    QString result() const;

    Q_INVOKABLE void generate();

signals:
    void countChanged();
    void ipTypeChanged();
    void resultChanged();

private:
    int m_count;
    QString m_ipType;
    QString m_result;
    
    QString generateSingleIpv4();
    QString generatePrivateIp();
    QString generatePublicIp();
    QString generateLoopbackIp();
    QString generateMulticastIp();
};

#endif // RANDOMIPV4GENERATOR_H