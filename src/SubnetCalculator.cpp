#include "SubnetCalculator.h"
#include <QStringList>

SubnetCalculator::SubnetCalculator(QObject *parent)
    : QObject(parent)
    , m_ipAddress("192.168.1.100")
    , m_subnetMask("255.255.255.0")
    , m_result("")
{
}

void SubnetCalculator::setIpAddress(const QString &ip)
{
    if (m_ipAddress != ip) {
        m_ipAddress = ip;
        emit ipAddressChanged();
    }
}

void SubnetCalculator::setSubnetMask(const QString &mask)
{
    if (m_subnetMask != mask) {
        m_subnetMask = mask;
        emit subnetMaskChanged();
    }
}

void SubnetCalculator::calculate()
{
    m_result = "";

    if (!isValidIpAddress(m_ipAddress)) {
        m_result = tr("错误: IP地址格式不正确");
        emit resultChanged();
        return;
    }

    if (!isValidSubnetMask(m_subnetMask)) {
        m_result = tr("错误: 子网掩码格式不正确");
        emit resultChanged();
        return;
    }

    quint32 ip = ipToInt(m_ipAddress);
    quint32 mask = ipToInt(m_subnetMask);
    int cidr = maskToCidr(m_subnetMask);

    quint32 network = ip & mask;
    quint32 broadcast = network | (~mask);
    quint32 firstHost = network + 1;
    quint32 lastHost = broadcast - 1;
    quint32 totalHosts = (~mask) - 1;
    quint32 wildcardMask = ~mask;

    QString networkAddr = intToIp(network);
    QString broadcastAddr = intToIp(broadcast);
    QString firstHostAddr = intToIp(firstHost);
    QString lastHostAddr = intToIp(lastHost);
    QString wildcardMaskAddr = intToIp(wildcardMask);

    QString ipClass;
    quint8 firstOctet = (ip >> 24) & 0xFF;
    if (firstOctet >= 1 && firstOctet <= 126) {
        ipClass = "A";
    } else if (firstOctet >= 128 && firstOctet <= 191) {
        ipClass = "B";
    } else if (firstOctet >= 192 && firstOctet <= 223) {
        ipClass = "C";
    } else if (firstOctet >= 224 && firstOctet <= 239) {
        ipClass = "D (多播)";
    } else {
        ipClass = "E (保留)";
    }

    QString ipType;
    if ((firstOctet == 10) ||
        (firstOctet == 172 && ((ip >> 16) & 0xFF) >= 16 && ((ip >> 16) & 0xFF) <= 31) ||
        (firstOctet == 192 && ((ip >> 16) & 0xFF) == 168)) {
        ipType = tr("私有地址");
    } else if (firstOctet == 127) {
        ipType = tr("回环地址");
    } else {
        ipType = tr("公网地址");
    }

    m_result = QString(
        "═══════════════════════════════════════\n"
        "  IP地址信息\n"
        "═══════════════════════════════════════\n"
        "IP地址:        %1\n"
        "子网掩码:      %2\n"
        "CIDR表示法:    %3/%4\n"
        "IP类别:        %5\n"
        "IP类型:        %6\n"
        "\n"
        "═══════════════════════════════════════\n"
        "  网络信息\n"
        "═══════════════════════════════════════\n"
        "网络地址:      %7\n"
        "广播地址:      %8\n"
        "通配符掩码:    %9\n"
        "\n"
        "═══════════════════════════════════════\n"
        "  主机信息\n"
        "═══════════════════════════════════════\n"
        "第一个可用IP:  %10\n"
        "最后一个可用IP: %11\n"
        "可用主机数:    %12\n"
        "总主机数:      %13\n"
    ).arg(m_ipAddress)
     .arg(m_subnetMask)
     .arg(networkAddr)
     .arg(cidr)
     .arg(ipClass)
     .arg(ipType)
     .arg(networkAddr)
     .arg(broadcastAddr)
     .arg(wildcardMaskAddr)
     .arg(firstHostAddr)
     .arg(lastHostAddr)
     .arg(totalHosts)
     .arg(totalHosts + 2);

    emit resultChanged();
}

void SubnetCalculator::clear()
{
    m_ipAddress = "192.168.1.100";
    m_subnetMask = "255.255.255.0";
    m_result = "";
    emit ipAddressChanged();
    emit subnetMaskChanged();
    emit resultChanged();
}

bool SubnetCalculator::isValidIpAddress(const QString &ip)
{
    QStringList parts = ip.split('.');
    if (parts.size() != 4) return false;

    for (const QString &part : parts) {
        bool ok;
        int num = part.toInt(&ok);
        if (!ok || num < 0 || num > 255) return false;
    }
    return true;
}

bool SubnetCalculator::isValidSubnetMask(const QString &mask)
{
    if (!isValidIpAddress(mask)) return false;

    quint32 maskInt = ipToInt(mask);
    
    if (maskInt == 0) return false;
    
    quint32 inverted = ~maskInt;
    return (inverted & (inverted + 1)) == 0;
}

quint32 SubnetCalculator::ipToInt(const QString &ip)
{
    QStringList parts = ip.split('.');
    if (parts.size() != 4) return 0;

    quint32 result = 0;
    result |= (parts[0].toUInt() << 24);
    result |= (parts[1].toUInt() << 16);
    result |= (parts[2].toUInt() << 8);
    result |= parts[3].toUInt();
    return result;
}

QString SubnetCalculator::intToIp(quint32 ip)
{
    return QString("%1.%2.%3.%4")
        .arg((ip >> 24) & 0xFF)
        .arg((ip >> 16) & 0xFF)
        .arg((ip >> 8) & 0xFF)
        .arg(ip & 0xFF);
}

int SubnetCalculator::maskToCidr(const QString &mask)
{
    quint32 maskInt = ipToInt(mask);
    return countBits(maskInt);
}

QString SubnetCalculator::cidrToMask(int cidr)
{
    if (cidr < 0 || cidr > 32) return "0.0.0.0";
    
    quint32 mask = 0;
    for (int i = 0; i < cidr; i++) {
        mask |= (1 << (31 - i));
    }
    return intToIp(mask);
}

int SubnetCalculator::countBits(quint32 value)
{
    int count = 0;
    while (value) {
        count += value & 1;
        value >>= 1;
    }
    return count;
}
