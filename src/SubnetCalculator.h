#ifndef SUBNETCALCULATOR_H
#define SUBNETCALCULATOR_H

#include <QObject>
#include <QString>

class SubnetCalculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ipAddress READ ipAddress WRITE setIpAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(QString subnetMask READ subnetMask WRITE setSubnetMask NOTIFY subnetMaskChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit SubnetCalculator(QObject *parent = nullptr);

    QString ipAddress() const { return m_ipAddress; }
    void setIpAddress(const QString &ip);

    QString subnetMask() const { return m_subnetMask; }
    void setSubnetMask(const QString &mask);

    QString result() const { return m_result; }

    Q_INVOKABLE void calculate();
    Q_INVOKABLE void clear();

signals:
    void ipAddressChanged();
    void subnetMaskChanged();
    void resultChanged();

private:
    bool isValidIpAddress(const QString &ip);
    bool isValidSubnetMask(const QString &mask);
    quint32 ipToInt(const QString &ip);
    QString intToIp(quint32 ip);
    int maskToCidr(const QString &mask);
    QString cidrToMask(int cidr);
    int countBits(quint32 value);

    QString m_ipAddress;
    QString m_subnetMask;
    QString m_result;
};

#endif // SUBNETCALCULATOR_H
