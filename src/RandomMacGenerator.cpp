#include "RandomMacGenerator.h"

RandomMacGenerator::RandomMacGenerator(QObject *parent)
    : QObject(parent)
    , m_count(1)
    , m_format("colon")
    , m_caseType("lower")
    , m_result("")
{
}

int RandomMacGenerator::count() const
{
    return m_count;
}

void RandomMacGenerator::setCount(int count)
{
    if (count < 1) count = 1;
    if (count > 100) count = 100;
    
    if (m_count != count) {
        m_count = count;
        emit countChanged();
    }
}



QString RandomMacGenerator::format() const
{
    return m_format;
}

void RandomMacGenerator::setFormat(const QString &format)
{
    if (m_format != format) {
        m_format = format;
        emit formatChanged();
    }
}

QString RandomMacGenerator::caseType() const
{
    return m_caseType;
}

void RandomMacGenerator::setCaseType(const QString &caseType)
{
    if (m_caseType != caseType) {
        m_caseType = caseType;
        emit caseTypeChanged();
    }
}

QString RandomMacGenerator::result() const
{
    return m_result;
}

void RandomMacGenerator::generate()
{
    QStringList macList;
    
    for (int i = 0; i < m_count; ++i) {
        QString mac = generateSingleMac();
        macList.append(mac);
    }
    
    m_result = macList.join("\n");
    emit resultChanged();
}

QString RandomMacGenerator::generateSingleMac()
{
    QString mac;
    
    // 生成6字节（12个十六进制字符）
    for (int i = 0; i < 6; ++i) {
        int byte = QRandomGenerator::global()->bounded(256);
        mac += QString("%1").arg(byte, 2, 16, QLatin1Char('0'));
    }
    
    // 应用格式和大小写
    mac = formatMacAddress(mac, m_format, m_caseType);
    
    return mac;
}

QString RandomMacGenerator::formatMacAddress(const QString &mac, const QString &format, const QString &caseType)
{
    QString formatted = mac;
    
    // 应用大小写
    if (caseType == "upper") {
        formatted = formatted.toUpper();
    } else {
        formatted = formatted.toLower();
    }
    
    // 应用分隔符
    if (format == "colon") {
        // 冒号分隔: 00:11:22:33:44:55
        QString result;
        for (int i = 0; i < formatted.length(); i += 2) {
            if (i > 0) result += ":";
            result += formatted.mid(i, 2);
        }
        return result;
    } else if (format == "hyphen") {
        // 连字符分隔: 00-11-22-33-44-55
        QString result;
        for (int i = 0; i < formatted.length(); i += 2) {
            if (i > 0) result += "-";
            result += formatted.mid(i, 2);
        }
        return result;
    } else {
        // 无分隔: 001122334455
        return formatted;
    }
}
