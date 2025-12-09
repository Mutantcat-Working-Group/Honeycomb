#include "RandomLetterGenerator.h"

RandomLetterGenerator::RandomLetterGenerator(QObject *parent)
    : QObject(parent)
    , m_length(8)
    , m_result("")
    , m_includeUpper(true)
    , m_includeLower(true)
{
}

int RandomLetterGenerator::length() const
{
    return m_length;
}

void RandomLetterGenerator::setLength(int length)
{
    if (length < 1) length = 1;
    if (length > 999) length = 999;
    
    if (m_length != length) {
        m_length = length;
        emit lengthChanged();
    }
}

QString RandomLetterGenerator::result() const
{
    return m_result;
}

bool RandomLetterGenerator::includeUpper() const
{
    return m_includeUpper;
}

void RandomLetterGenerator::setIncludeUpper(bool include)
{
    if (m_includeUpper != include) {
        m_includeUpper = include;
        emit includeUpperChanged();
    }
}

bool RandomLetterGenerator::includeLower() const
{
    return m_includeLower;
}

void RandomLetterGenerator::setIncludeLower(bool include)
{
    if (m_includeLower != include) {
        m_includeLower = include;
        emit includeLowerChanged();
    }
}

void RandomLetterGenerator::generate()
{
    QString charset;
    
    if (m_includeUpper) {
        charset += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    }
    if (m_includeLower) {
        charset += "abcdefghijklmnopqrstuvwxyz";
    }
    
    // 如果都没选，默认使用小写
    if (charset.isEmpty()) {
        charset = "abcdefghijklmnopqrstuvwxyz";
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
