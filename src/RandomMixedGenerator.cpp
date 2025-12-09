#include "RandomMixedGenerator.h"

RandomMixedGenerator::RandomMixedGenerator(QObject *parent)
    : QObject(parent)
    , m_length(8)
    , m_result("")
    , m_includeUpper(true)
    , m_includeLower(true)
    , m_includeDigits(true)
{
}

int RandomMixedGenerator::length() const
{
    return m_length;
}

void RandomMixedGenerator::setLength(int length)
{
    if (length < 1) length = 1;
    if (length > 999) length = 999;
    
    if (m_length != length) {
        m_length = length;
        emit lengthChanged();
    }
}

QString RandomMixedGenerator::result() const
{
    return m_result;
}

bool RandomMixedGenerator::includeUpper() const
{
    return m_includeUpper;
}

void RandomMixedGenerator::setIncludeUpper(bool include)
{
    if (m_includeUpper != include) {
        m_includeUpper = include;
        emit includeUpperChanged();
    }
}

bool RandomMixedGenerator::includeLower() const
{
    return m_includeLower;
}

void RandomMixedGenerator::setIncludeLower(bool include)
{
    if (m_includeLower != include) {
        m_includeLower = include;
        emit includeLowerChanged();
    }
}

bool RandomMixedGenerator::includeDigits() const
{
    return m_includeDigits;
}

void RandomMixedGenerator::setIncludeDigits(bool include)
{
    if (m_includeDigits != include) {
        m_includeDigits = include;
        emit includeDigitsChanged();
    }
}

void RandomMixedGenerator::generate()
{
    QString charset;
    
    if (m_includeUpper) {
        charset += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    }
    if (m_includeLower) {
        charset += "abcdefghijklmnopqrstuvwxyz";
    }
    if (m_includeDigits) {
        charset += "0123456789";
    }
    
    // 如果都没选，默认使用全部
    if (charset.isEmpty()) {
        charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    }
    
    QString result;
    result.reserve(m_length);
    
    int charsetLen = charset.length();
    for (int i = 0; i < m_length; ++i) {
        int index = QRandomGenerator::global()->bounded(charsetLen);
        result.append(charset.at(index));
    }
    
    m_result = result;
    emit resultChanged();
}
