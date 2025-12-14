#include "RandomIpv6Generator.h"

RandomIpv6Generator::RandomIpv6Generator(QObject *parent)
    : QObject(parent)
    , m_count(1)
    , m_ipType("random")
    , m_format("full")
    , m_result("")
{
}

int RandomIpv6Generator::count() const
{
    return m_count;
}

void RandomIpv6Generator::setCount(int count)
{
    if (count < 1) count = 1;
    if (count > 100) count = 100;
    
    if (m_count != count) {
        m_count = count;
        emit countChanged();
    }
}

QString RandomIpv6Generator::ipType() const
{
    return m_ipType;
}

void RandomIpv6Generator::setIpType(const QString &ipType)
{
    if (m_ipType != ipType) {
        m_ipType = ipType;
        emit ipTypeChanged();
    }
}

QString RandomIpv6Generator::format() const
{
    return m_format;
}

void RandomIpv6Generator::setFormat(const QString &format)
{
    if (m_format != format) {
        m_format = format;
        emit formatChanged();
    }
}

QString RandomIpv6Generator::result() const
{
    return m_result;
}

void RandomIpv6Generator::generate()
{
    QStringList ipList;
    
    for (int i = 0; i < m_count; ++i) {
        QString ip = generateSingleIpv6();
        ipList.append(ip);
    }
    
    m_result = ipList.join("\n");
    emit resultChanged();
}

QString RandomIpv6Generator::generateSingleIpv6()
{
    QString ipv6;
    
    if (m_ipType == "global") {
        ipv6 = generateGlobalUnicast();
    } else if (m_ipType == "linklocal") {
        ipv6 = generateLinkLocal();
    } else if (m_ipType == "uniquelocal") {
        ipv6 = generateUniqueLocal();
    } else if (m_ipType == "multicast") {
        ipv6 = generateMulticast();
    } else {
        // 随机生成任何类型的IPv6
        int type = QRandomGenerator::global()->bounded(4);
        if (type == 0) ipv6 = generateGlobalUnicast();
        else if (type == 1) ipv6 = generateLinkLocal();
        else if (type == 2) ipv6 = generateUniqueLocal();
        else ipv6 = generateMulticast();
    }
    
    return formatIpv6(ipv6, m_format);
}

QString RandomIpv6Generator::generateGlobalUnicast()
{
    // 全局单播地址，以2000::/3开头
    QString firstSegment = "2000";
    
    // 生成剩余的7个段
    QString segments;
    for (int i = 0; i < 7; ++i) {
        segments += ":" + generateRandomHexSegment(4);
    }
    
    return firstSegment + segments;
}

QString RandomIpv6Generator::generateLinkLocal()
{
    // 链路本地地址，以fe80::/10开头
    QString ipv6 = "fe80::";
    
    // 生成剩余的6个段（实际只有4个段可用，因为::已经占用了2个段）
    for (int i = 0; i < 4; ++i) {
        if (i > 0) ipv6 += ":";
        ipv6 += generateRandomHexSegment(4);
    }
    
    return ipv6;
}

QString RandomIpv6Generator::generateUniqueLocal()
{
    // 唯一本地地址，以fc00::/7或fd00::/8开头
    QString firstSegment = QRandomGenerator::global()->bounded(2) == 0 ? "fc" : "fd";
    firstSegment += generateRandomHexSegment(2);
    
    QString ipv6 = firstSegment + "::";
    
    // 生成剩余的6个段
    for (int i = 0; i < 6; ++i) {
        if (i > 0) ipv6 += ":";
        ipv6 += generateRandomHexSegment(4);
    }
    
    return ipv6;
}

QString RandomIpv6Generator::generateMulticast()
{
    // 多播地址，以ff00::/8开头
    QString ipv6 = "ff";
    
    // 第二个字节表示标志和范围
    ipv6 += QString("%1").arg(QRandomGenerator::global()->bounded(16), 2, 16, QLatin1Char('0'));
    
    ipv6 += "::";
    
    // 生成剩余的6个段
    for (int i = 0; i < 6; ++i) {
        if (i > 0) ipv6 += ":";
        ipv6 += generateRandomHexSegment(4);
    }
    
    return ipv6;
}

QString RandomIpv6Generator::formatIpv6(const QString &ipv6, const QString &format)
{
    if (format == "compressed") {
        // 压缩格式，使用::替换连续的0段
        QString result = ipv6;
        
        // 简单的压缩实现：只压缩一个::（实际IPv6压缩更复杂）
        if (result.contains("::")) {
            return result; // 已经有::，不再处理
        }
        
        // 查找最长的连续0段进行压缩
        QStringList segments = result.split(":");
        int maxZeroStart = -1;
        int maxZeroLength = 0;
        int currentZeroStart = -1;
        int currentZeroLength = 0;
        
        for (int i = 0; i < segments.size(); ++i) {
            if (segments[i] == "0" || segments[i] == "") {
                if (currentZeroStart == -1) {
                    currentZeroStart = i;
                    currentZeroLength = 1;
                } else {
                    currentZeroLength++;
                }
            } else {
                if (currentZeroLength > maxZeroLength) {
                    maxZeroStart = currentZeroStart;
                    maxZeroLength = currentZeroLength;
                }
                currentZeroStart = -1;
                currentZeroLength = 0;
            }
        }
        
        // 检查最后一段
        if (currentZeroLength > maxZeroLength) {
            maxZeroStart = currentZeroStart;
            maxZeroLength = currentZeroLength;
        }
        
        // 如果找到连续的0段，进行压缩
        if (maxZeroLength >= 2) {
            QStringList compressed;
            for (int i = 0; i < segments.size(); ++i) {
                if (i == maxZeroStart) {
                    compressed.append("");
                    i += maxZeroLength - 1;
                } else {
                    compressed.append(segments[i]);
                }
            }
            result = compressed.join(":");
        }
        
        return result;
    } else {
        // 完整格式
        return ipv6;
    }
}

QString RandomIpv6Generator::generateRandomHexSegment(int length)
{
    QString segment;
    for (int i = 0; i < length; ++i) {
        int digit = QRandomGenerator::global()->bounded(16);
        segment += QString("%1").arg(digit, 1, 16).toLower();
    }
    return segment;
}