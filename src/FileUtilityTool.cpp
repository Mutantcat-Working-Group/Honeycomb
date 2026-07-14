#include "FileUtilityTool.h"

#include <QBuffer>
#include <QByteArray>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QImageIOHandler>
#include <QImageReader>
#include <QImageWriter>
#include <QMimeDatabase>
#include <QtGlobal>

FileUtilityTool::FileUtilityTool(QObject *parent)
    : QObject(parent)
    , m_maxBase64SizeBytes(10 * 1024 * 1024)
    , m_originalSize(0)
    , m_compressedSize(0)
{
}

QString FileUtilityTool::filePath() const
{
    return m_filePath;
}

void FileUtilityTool::setFilePath(const QString &filePath)
{
    if (m_filePath != filePath) {
        m_filePath = filePath;
        emit filePathChanged();
    }
}

QString FileUtilityTool::errorMessage() const
{
    return m_errorMessage;
}

QString FileUtilityTool::md5() const
{
    return m_md5;
}

QString FileUtilityTool::sha1() const
{
    return m_sha1;
}

QString FileUtilityTool::sha256() const
{
    return m_sha256;
}

QString FileUtilityTool::sha384() const
{
    return m_sha384;
}

QString FileUtilityTool::sha512() const
{
    return m_sha512;
}

QString FileUtilityTool::base64Result() const
{
    return m_base64Result;
}

qint64 FileUtilityTool::maxBase64SizeBytes() const
{
    return m_maxBase64SizeBytes;
}

void FileUtilityTool::setMaxBase64SizeBytes(qint64 bytes)
{
    if (bytes < 1024) {
        bytes = 1024;
    }
    if (m_maxBase64SizeBytes != bytes) {
        m_maxBase64SizeBytes = bytes;
        emit maxBase64SizeBytesChanged();
    }
}

QString FileUtilityTool::imageOutputPath() const
{
    return m_imageOutputPath;
}

qint64 FileUtilityTool::originalSize() const
{
    return m_originalSize;
}

qint64 FileUtilityTool::compressedSize() const
{
    return m_compressedSize;
}

bool FileUtilityTool::calculateAllHashes()
{
    if (!validateReadableFile()) {
        clearHashes();
        return false;
    }

    m_md5 = hashFile(QCryptographicHash::Md5);
    m_sha1 = hashFile(QCryptographicHash::Sha1);
    m_sha256 = hashFile(QCryptographicHash::Sha256);
    m_sha384 = hashFile(QCryptographicHash::Sha384);
    m_sha512 = hashFile(QCryptographicHash::Sha512);
    if (m_md5.isEmpty() || m_sha1.isEmpty() || m_sha256.isEmpty() || m_sha384.isEmpty() || m_sha512.isEmpty()) {
        return false;
    }

    setErrorMessage("");
    emit hashesChanged();
    return true;
}

void FileUtilityTool::clearHashes()
{
    m_md5.clear();
    m_sha1.clear();
    m_sha256.clear();
    m_sha384.clear();
    m_sha512.clear();
    emit hashesChanged();
}

bool FileUtilityTool::encodeFileToBase64()
{
    if (!validateReadableFile()) {
        clearBase64();
        return false;
    }

    QFileInfo info(m_filePath);
    if (info.size() > m_maxBase64SizeBytes) {
        clearBase64();
        setErrorMessage(QStringLiteral("文件过大，当前限制为 %1").arg(formatFileSize(m_maxBase64SizeBytes)));
        return false;
    }

    QFile file(m_filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        clearBase64();
        setErrorMessage(QStringLiteral("文件无法读取: %1").arg(file.errorString()));
        return false;
    }

    m_base64Result = QString::fromLatin1(file.readAll().toBase64());
    setErrorMessage("");
    emit base64Changed();
    return true;
}

void FileUtilityTool::clearBase64()
{
    if (!m_base64Result.isEmpty()) {
        m_base64Result.clear();
        emit base64Changed();
    }
}

bool FileUtilityTool::compressImage(const QString &outputPath, const QString &format, int quality, int maxWidth, int maxHeight)
{
    if (!validateReadableFile()) {
        return false;
    }

    QFileInfo inputInfo(m_filePath);
    m_originalSize = inputInfo.size();
    m_compressedSize = 0;
    m_imageOutputPath.clear();

    QImageReader reader(m_filePath);
    reader.setAutoTransform(true);
    QImage image = reader.read();
    if (image.isNull()) {
        setErrorMessage(QStringLiteral("图片读取失败: %1").arg(reader.errorString()));
        emit imageCompressionChanged();
        return false;
    }

    if (maxWidth > 0 && maxHeight > 0 && (image.width() > maxWidth || image.height() > maxHeight)) {
        image = image.scaled(maxWidth, maxHeight, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    QString targetFormat = normalizedFormat(format);
    QString targetPath = outputPath.trimmed();
    if (targetPath.isEmpty()) {
        targetPath = defaultCompressedImagePath(targetFormat);
    }

    QFileInfo outputInfo(targetPath);
    if (!outputInfo.dir().exists() && !QDir().mkpath(outputInfo.absolutePath())) {
        setErrorMessage(QStringLiteral("输出目录无法创建"));
        emit imageCompressionChanged();
        return false;
    }

    QImageWriter writer(targetPath, targetFormat.toLatin1());
    if (writer.supportsOption(QImageIOHandler::Quality)) {
        writer.setQuality(qBound(1, quality, 100));
    }
    if (!writer.write(image)) {
        setErrorMessage(QStringLiteral("图片压缩失败: %1").arg(writer.errorString()));
        emit imageCompressionChanged();
        return false;
    }

    QFileInfo compressedInfo(targetPath);
    m_imageOutputPath = targetPath;
    m_compressedSize = compressedInfo.size();
    setErrorMessage("");
    emit imageCompressionChanged();
    return true;
}

QString FileUtilityTool::defaultCompressedImagePath(const QString &format) const
{
    QFileInfo info(m_filePath);
    QString targetFormat = normalizedFormat(format);
    QString suffix = targetFormat == QStringLiteral("jpeg") ? QStringLiteral("jpg") : targetFormat;
    QString baseName = info.completeBaseName().isEmpty() ? QStringLiteral("image") : info.completeBaseName();
    return info.dir().absoluteFilePath(baseName + QStringLiteral("_compressed.") + suffix);
}

QString FileUtilityTool::formatFileSize(qint64 bytes) const
{
    double value = bytes;
    QStringList units = {QStringLiteral("B"), QStringLiteral("KB"), QStringLiteral("MB"), QStringLiteral("GB")};
    int unitIndex = 0;
    while (value >= 1024.0 && unitIndex < units.size() - 1) {
        value /= 1024.0;
        ++unitIndex;
    }
    return QStringLiteral("%1 %2").arg(QString::number(value, 'f', unitIndex == 0 ? 0 : 2), units[unitIndex]);
}

QVariantMap FileUtilityTool::fileInfo()
{
    QVariantMap infoMap;
    if (!validateReadableFile()) {
        return infoMap;
    }

    QFileInfo info(m_filePath);
    QMimeDatabase mimeDatabase;
    const QMimeType mime = mimeDatabase.mimeTypeForFile(info);

    infoMap.insert(QStringLiteral("name"), info.fileName());
    infoMap.insert(QStringLiteral("baseName"), info.completeBaseName());
    infoMap.insert(QStringLiteral("suffix"), info.suffix());
    infoMap.insert(QStringLiteral("absolutePath"), info.absoluteFilePath());
    infoMap.insert(QStringLiteral("directory"), info.absolutePath());
    infoMap.insert(QStringLiteral("size"), info.size());
    infoMap.insert(QStringLiteral("sizeText"), formatFileSize(info.size()));
    infoMap.insert(QStringLiteral("mime"), mime.name());
    infoMap.insert(QStringLiteral("lastModified"), info.lastModified().toString(QStringLiteral("yyyy-MM-dd HH:mm:ss")));
    infoMap.insert(QStringLiteral("created"), info.birthTime().isValid() ? info.birthTime().toString(QStringLiteral("yyyy-MM-dd HH:mm:ss")) : QString());
    infoMap.insert(QStringLiteral("readable"), info.isReadable());
    infoMap.insert(QStringLiteral("writable"), info.isWritable());
    infoMap.insert(QStringLiteral("executable"), info.isExecutable());
    infoMap.insert(QStringLiteral("md5"), hashFile(QCryptographicHash::Md5));
    infoMap.insert(QStringLiteral("sha1"), hashFile(QCryptographicHash::Sha1));
    infoMap.insert(QStringLiteral("sha256"), hashFile(QCryptographicHash::Sha256));
    setErrorMessage(QString());
    return infoMap;
}

QStringList FileUtilityTool::supportedReadImageFormats() const
{
    QStringList formats;
    const auto supported = QImageReader::supportedImageFormats();
    for (const QByteArray &format : supported) {
        formats.append(QString::fromLatin1(format).toLower());
    }
    formats.removeDuplicates();
    formats.sort();
    return formats;
}

QStringList FileUtilityTool::supportedWriteImageFormats() const
{
    QStringList formats;
    const auto supported = QImageWriter::supportedImageFormats();
    for (const QByteArray &format : supported) {
        formats.append(QString::fromLatin1(format).toLower());
    }
    formats.removeDuplicates();
    formats.sort();
    return formats;
}

bool FileUtilityTool::validateReadableFile()
{
    if (m_filePath.trimmed().isEmpty()) {
        setErrorMessage(QStringLiteral("文件路径不能为空"));
        return false;
    }

    QFileInfo info(m_filePath);
    if (!info.exists() || !info.isFile()) {
        setErrorMessage(QStringLiteral("文件不存在"));
        return false;
    }
    if (!info.isReadable()) {
        setErrorMessage(QStringLiteral("文件无法读取"));
        return false;
    }
    return true;
}

QString FileUtilityTool::hashFile(QCryptographicHash::Algorithm algorithm)
{
    QFile file(m_filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        setErrorMessage(QStringLiteral("文件无法读取: %1").arg(file.errorString()));
        return QString();
    }

    QCryptographicHash hash(algorithm);
    while (!file.atEnd()) {
        hash.addData(file.read(1024 * 1024));
    }
    return QString::fromLatin1(hash.result().toHex());
}

void FileUtilityTool::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}

QString FileUtilityTool::normalizedFormat(const QString &format) const
{
    QString value = format.trimmed().toLower();
    if (value == QStringLiteral("jpg")) {
        return QStringLiteral("jpeg");
    }
    if (value.isEmpty()) {
        QFileInfo info(m_filePath);
        value = info.suffix().toLower();
        if (value == QStringLiteral("jpg")) {
            return QStringLiteral("jpeg");
        }
        if (!value.isEmpty()) {
            return value;
        }
        return QStringLiteral("jpeg");
    }
    return value;
}
