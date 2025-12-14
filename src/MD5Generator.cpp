#include "MD5Generator.h"

MD5Generator::MD5Generator(QObject *parent)
    : QObject(parent)
    , m_inputText("")
    , m_result("")
    , m_uppercase(false)
{
}

QString MD5Generator::inputText() const
{
    return m_inputText;
}

void MD5Generator::setInputText(const QString &inputText)
{
    if (m_inputText != inputText) {
        m_inputText = inputText;
        emit inputTextChanged();
    }
}

QString MD5Generator::result() const
{
    return m_result;
}

bool MD5Generator::uppercase() const
{
    return m_uppercase;
}

void MD5Generator::setUppercase(bool uppercase)
{
    if (m_uppercase != uppercase) {
        m_uppercase = uppercase;
        emit uppercaseChanged();
    }
}

void MD5Generator::generate()
{
    if (m_inputText.isEmpty()) {
        m_result = "";
        emit resultChanged();
        return;
    }

    QByteArray hash = QCryptographicHash::hash(m_inputText.toUtf8(), QCryptographicHash::Md5);
    m_result = hash.toHex();
    
    if (m_uppercase) {
        m_result = m_result.toUpper();
    }
    
    emit resultChanged();
}