#include "FileHashCalculator.h"

#include <QCryptographicHash>
#include <QFile>

FileHashCalculator::FileHashCalculator(QObject *parent)
    : QObject(parent)
    , m_algorithm("MD5")
    , m_uppercase(false)
{
}

QString FileHashCalculator::filePath() const
{
    return m_filePath;
}

void FileHashCalculator::setFilePath(const QString &filePath)
{
    if (m_filePath != filePath) {
        m_filePath = filePath;
        emit filePathChanged();
    }
}

QString FileHashCalculator::algorithm() const
{
    return m_algorithm;
}

void FileHashCalculator::setAlgorithm(const QString &algorithm)
{
    if (m_algorithm != algorithm) {
        m_algorithm = algorithm;
        emit algorithmChanged();
    }
}

QString FileHashCalculator::result() const
{
    return m_result;
}

QString FileHashCalculator::errorMessage() const
{
    return m_errorMessage;
}

bool FileHashCalculator::uppercase() const
{
    return m_uppercase;
}

void FileHashCalculator::setUppercase(bool uppercase)
{
    if (m_uppercase != uppercase) {
        m_uppercase = uppercase;
        emit uppercaseChanged();
    }
}

void FileHashCalculator::calculate()
{
    if (m_filePath.trimmed().isEmpty()) {
        setResult("");
        setErrorMessage("文件路径不能为空");
        return;
    }

    QFile file(m_filePath);
    if (!file.exists()) {
        setResult("");
        setErrorMessage("文件不存在");
        return;
    }
    if (!file.open(QIODevice::ReadOnly)) {
        setResult("");
        setErrorMessage("文件无法读取: " + file.errorString());
        return;
    }

    QCryptographicHash hash(static_cast<QCryptographicHash::Algorithm>(hashAlgorithm()));
    while (!file.atEnd()) {
        hash.addData(file.read(1024 * 1024));
    }

    QString value = QString::fromLatin1(hash.result().toHex());
    if (m_uppercase) {
        value = value.toUpper();
    }

    setErrorMessage("");
    setResult(value);
}

void FileHashCalculator::clear()
{
    setFilePath("");
    setResult("");
    setErrorMessage("");
}

int FileHashCalculator::hashAlgorithm() const
{
    const QString normalized = m_algorithm.toUpper();
    if (normalized == "SHA1") {
        return QCryptographicHash::Sha1;
    }
    if (normalized == "SHA256") {
        return QCryptographicHash::Sha256;
    }
    return QCryptographicHash::Md5;
}

void FileHashCalculator::setResult(const QString &result)
{
    if (m_result != result) {
        m_result = result;
        emit resultChanged();
    }
}

void FileHashCalculator::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}
