#include "RandomIpv4Generator.h"

RandomIpv4Generator::RandomIpv4Generator(QObject *parent)
    : QObject(parent)
    , m_count(1)
    , m_ipType("random")
    , m_result("")
{
}

int RandomIpv4Generator::count() const
{
    return m_count;
}

void RandomIpv4Generator::setCount(int count)
{
    if (count < 1) count = 1;
    if (count > 100) count = 100;
    
    if (m_count != count) {
        m_count = count;
        emit countChanged();
    }
}

QString RandomIpv4Generator::ipType() const
{
    return m_ipType;
}

void RandomIpv4Generator::setIpType(const QString &ipType)
{
    if (m_ipType != ipType) {
        m_ipType = ipType;
        emit ipTypeChanged();
    }
}

QString RandomIpv4Generator::result() const
{
    return m_result;
}

void RandomIpv4Generator::generate()
{
    QStringList ipList;
    
    for (int i = 0; i < m_count; ++i) {
        QString ip = generateSingleIpv4();
        ipList.append(ip);
    }
    
    m_result = ipList.join("\n");
    emit resultChanged();
}

QString RandomIpv4Generator::generateSingleIpv4()
{
    if (m_ipType == "private") {
        return generatePrivateIp();
    } else if (m_ipType == "public") {
        return generatePublicIp();
    } else if (m_ipType == "loopback") {
        return generateLoopbackIp();
    } else if (m_ipType == "multicast") {
        return generateMulticastIp();
    } else {
        // 随机生成任何类型的IP
        int type = QRandomGenerator::global()->bounded(4);
        if (type == 0) return generatePrivateIp();
        else if (type == 1) return generatePublicIp();
        else if (type == 2) return generateLoopbackIp();
        else return generateMulticastIp();
    }
}

QString RandomIpv4Generator::generatePrivateIp()
{
    // 私有IP地址范围
    // 10.0.0.0 - 10.255.255.255
    // 172.16.0.0 - 172.31.255.255
    // 192.168.0.0 - 192.168.255.255
    
    int range = QRandomGenerator::global()->bounded(3);
    
    if (range == 0) {
        // 10.x.x.x
        return QString("10.%1.%2.%3")
            .arg(QRandomGenerator::global()->bounded(256))
            .arg(QRandomGenerator::global()->bounded(256))
            .arg(QRandomGenerator::global()->bounded(256));
    } else if (range == 1) {
        // 172.16.x.x - 172.31.x.x
        return QString("172.%1.%2.%3")
            .arg(16 + QRandomGenerator::global()->bounded(16))
            .arg(QRandomGenerator::global()->bounded(256))
            .arg(QRandomGenerator::global()->bounded(256));
    } else {
        // 192.168.x.x
        return QString("192.168.%1.%2")
            .arg(QRandomGenerator::global()->bounded(256))
            .arg(QRandomGenerator::global()->bounded(256));
    }
}

QString RandomIpv4Generator::generatePublicIp()
{
    // 公共IP地址范围，排除私有地址和特殊地址
    // 1.x.x.x - 223.x.x.x (排除10.x.x.x, 172.16-31.x.x, 192.168.x.x)
    
    int firstOctet;
    do {
        firstOctet = QRandomGenerator::global()->bounded(1, 224); // 1-223
    } while (firstOctet == 10 || 
             (firstOctet == 172) || 
             (firstOctet == 192) || 
             firstOctet == 127); // 排除私有地址和回环地址
    
    return QString("%1.%2.%3.%4")
        .arg(firstOctet)
        .arg(QRandomGenerator::global()->bounded(256))
        .arg(QRandomGenerator::global()->bounded(256))
        .arg(QRandomGenerator::global()->bounded(256));
}

QString RandomIpv4Generator::generateLoopbackIp()
{
    // 回环地址范围: 127.0.0.0 - 127.255.255.255
    // 通常使用127.0.0.1
    
    // 90%概率生成127.0.0.1
    if (QRandomGenerator::global()->bounded(10) < 9) {
        return "127.0.0.1";
    }
    
    // 10%概率生成其他回环地址
    return QString("127.%1.%2.%3")
        .arg(QRandomGenerator::global()->bounded(256))
        .arg(QRandomGenerator::global()->bounded(256))
        .arg(QRandomGenerator::global()->bounded(256));
}

QString RandomIpv4Generator::generateMulticastIp()
{
    // 多播地址范围: 224.0.0.0 - 239.255.255.255
    
    return QString("%1.%2.%3.%4")
        .arg(224 + QRandomGenerator::global()->bounded(16)) // 224-239
        .arg(QRandomGenerator::global()->bounded(256))
        .arg(QRandomGenerator::global()->bounded(256))
        .arg(QRandomGenerator::global()->bounded(256));
}