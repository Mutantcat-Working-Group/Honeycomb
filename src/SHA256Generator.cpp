#include "SHA256Generator.h"

SHA256Generator::SHA256Generator(QObject *parent)
    : QObject(parent)
    , m_inputText("")
    , m_result("")
    , m_uppercase(false)
{
}

QString SHA256Generator::inputText() const
{
    return m_inputText;
}

void SHA256Generator::setInputText(const QString &inputText)
{
    if (m_inputText != inputText) {
        m_inputText = inputText;
        emit inputTextChanged();
    }
}

QString SHA256Generator::result() const
{
    return m_result;
}

bool SHA256Generator::uppercase() const
{
    return m_uppercase;
}

void SHA256Generator::setUppercase(bool uppercase)
{
    if (m_uppercase != uppercase) {
        m_uppercase = uppercase;
        emit uppercaseChanged();
    }
}

void SHA256Generator::generate()
{
    if (m_inputText.isEmpty()) {
        m_result = "";
        emit resultChanged();
        return;
    }

    QByteArray hash = QCryptographicHash::hash(m_inputText.toUtf8(), QCryptographicHash::Sha256);
    m_result = hash.toHex();
    
    if (m_uppercase) {
        m_result = m_result.toUpper();
    }
    
    emit resultChanged();
}