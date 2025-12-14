#include "UuidGenerator.h"

UuidGenerator::UuidGenerator(QObject *parent)
    : QObject(parent)
    , m_count(1)
    , m_version("4")
    , m_format("lowercase")
    , m_result("")
{
}

int UuidGenerator::count() const
{
    return m_count;
}

void UuidGenerator::setCount(int count)
{
    if (count < 1) count = 1;
    if (count > 100) count = 100;
    
    if (m_count != count) {
        m_count = count;
        emit countChanged();
    }
}

QString UuidGenerator::version() const
{
    return m_version;
}

void UuidGenerator::setVersion(const QString &version)
{
    if (m_version != version) {
        m_version = version;
        emit versionChanged();
    }
}

QString UuidGenerator::format() const
{
    return m_format;
}

void UuidGenerator::setFormat(const QString &format)
{
    if (m_format != format) {
        m_format = format;
        emit formatChanged();
    }
}

QString UuidGenerator::result() const
{
    return m_result;
}

void UuidGenerator::generate()
{
    QStringList uuidList;
    
    for (int i = 0; i < m_count; ++i) {
        QString uuid = generateSingleUuid();
        uuidList.append(uuid);
    }
    
    m_result = uuidList.join("\n");
    emit resultChanged();
}

QString UuidGenerator::generateSingleUuid()
{
    QUuid uuid;
    
    if (m_version == "1") {
        // 生成版本1 UUID (基于时间戳和MAC地址)
        // Qt没有直接提供版本1 UUID的生成方法，这里使用版本4并模拟版本1的格式
        uuid = QUuid::createUuid();
        
        // 为了模拟版本1，我们可以修改UUID字符串的第13位为1
        QString uuidStr = uuid.toString(QUuid::WithoutBraces);
        if (uuidStr.length() >= 14) {
            // 修改版本位为1 (位置13，0-based索引为12)
            uuidStr[12] = '1';
            uuid = QUuid::fromString(uuidStr);
        }
    } else if (m_version == "4") {
        // 生成版本4 UUID (随机)
        uuid = QUuid::createUuid();
    } else {
        // 默认使用版本4
        uuid = QUuid::createUuid();
    }
    
    return formatUuid(uuid.toString(QUuid::WithoutBraces), m_format);
}

QString UuidGenerator::formatUuid(const QString &uuid, const QString &format)
{
    if (format == "uppercase") {
        return uuid.toUpper();
    } else {
        // 默认为小写格式
        return uuid.toLower();
    }
}