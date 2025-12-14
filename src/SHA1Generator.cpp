#include "SHA1Generator.h"

SHA1Generator::SHA1Generator(QObject *parent)
    : QObject(parent)
    , m_inputText("")
    , m_result("")
    , m_uppercase(false)
{
}

QString SHA1Generator::inputText() const
{
    return m_inputText;
}

void SHA1Generator::setInputText(const QString &inputText)
{
    if (m_inputText != inputText) {
        m_inputText = inputText;
        emit inputTextChanged();
    }
}

QString SHA1Generator::result() const
{
    return m_result;
}

bool SHA1Generator::uppercase() const
{
    return m_uppercase;
}

void SHA1Generator::setUppercase(bool uppercase)
{
    if (m_uppercase != uppercase) {
        m_uppercase = uppercase;
        emit uppercaseChanged();
    }
}

void SHA1Generator::generate()
{
    if (m_inputText.isEmpty()) {
        m_result = "";
        emit resultChanged();
        return;
    }

    QByteArray hash = QCryptographicHash::hash(m_inputText.toUtf8(), QCryptographicHash::Sha1);
    m_result = hash.toHex();
    
    if (m_uppercase) {
        m_result = m_result.toUpper();
    }
    
    emit resultChanged();
}