#include "RandomNumberGenerator.h"

RandomNumberGenerator::RandomNumberGenerator(QObject *parent)
    : QObject(parent)
    , m_length(8)
    , m_result("")
{
}

int RandomNumberGenerator::length() const
{
    return m_length;
}

void RandomNumberGenerator::setLength(int length)
{
    if (length < 1) length = 1;
    if (length > 100) length = 100;
    
    if (m_length != length) {
        m_length = length;
        emit lengthChanged();
    }
}

QString RandomNumberGenerator::result() const
{
    return m_result;
}

void RandomNumberGenerator::generate()
{
    QString result;
    result.reserve(m_length);
    
    for (int i = 0; i < m_length; ++i) {
        int digit = QRandomGenerator::global()->bounded(10);
        result.append(QString::number(digit));
    }
    
    m_result = result;
    emit resultChanged();
}
