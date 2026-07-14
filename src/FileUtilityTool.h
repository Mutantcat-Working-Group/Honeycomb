#ifndef FILEUTILITYTOOL_H
#define FILEUTILITYTOOL_H

#include <QCryptographicHash>
#include <QObject>
#include <QString>
#include <QStringList>

class FileUtilityTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(QString md5 READ md5 NOTIFY hashesChanged)
    Q_PROPERTY(QString sha1 READ sha1 NOTIFY hashesChanged)
    Q_PROPERTY(QString sha256 READ sha256 NOTIFY hashesChanged)
    Q_PROPERTY(QString sha384 READ sha384 NOTIFY hashesChanged)
    Q_PROPERTY(QString sha512 READ sha512 NOTIFY hashesChanged)
    Q_PROPERTY(QString base64Result READ base64Result NOTIFY base64Changed)
    Q_PROPERTY(qint64 maxBase64SizeBytes READ maxBase64SizeBytes WRITE setMaxBase64SizeBytes NOTIFY maxBase64SizeBytesChanged)
    Q_PROPERTY(QString imageOutputPath READ imageOutputPath NOTIFY imageCompressionChanged)
    Q_PROPERTY(qint64 originalSize READ originalSize NOTIFY imageCompressionChanged)
    Q_PROPERTY(qint64 compressedSize READ compressedSize NOTIFY imageCompressionChanged)

public:
    explicit FileUtilityTool(QObject *parent = nullptr);

    QString filePath() const;
    void setFilePath(const QString &filePath);

    QString errorMessage() const;
    QString md5() const;
    QString sha1() const;
    QString sha256() const;
    QString sha384() const;
    QString sha512() const;
    QString base64Result() const;

    qint64 maxBase64SizeBytes() const;
    void setMaxBase64SizeBytes(qint64 bytes);

    QString imageOutputPath() const;
    qint64 originalSize() const;
    qint64 compressedSize() const;

    Q_INVOKABLE bool calculateAllHashes();
    Q_INVOKABLE void clearHashes();
    Q_INVOKABLE bool encodeFileToBase64();
    Q_INVOKABLE void clearBase64();
    Q_INVOKABLE bool compressImage(const QString &outputPath, const QString &format, int quality, int maxWidth, int maxHeight);
    Q_INVOKABLE QString defaultCompressedImagePath(const QString &format) const;
    Q_INVOKABLE QString formatFileSize(qint64 bytes) const;
    Q_INVOKABLE QStringList supportedReadImageFormats() const;
    Q_INVOKABLE QStringList supportedWriteImageFormats() const;

signals:
    void filePathChanged();
    void errorMessageChanged();
    void hashesChanged();
    void base64Changed();
    void maxBase64SizeBytesChanged();
    void imageCompressionChanged();

private:
    bool validateReadableFile();
    QString hashFile(QCryptographicHash::Algorithm algorithm);
    void setErrorMessage(const QString &message);
    QString normalizedFormat(const QString &format) const;

    QString m_filePath;
    QString m_errorMessage;
    QString m_md5;
    QString m_sha1;
    QString m_sha256;
    QString m_sha384;
    QString m_sha512;
    QString m_base64Result;
    qint64 m_maxBase64SizeBytes;
    QString m_imageOutputPath;
    qint64 m_originalSize;
    qint64 m_compressedSize;
};

#endif // FILEUTILITYTOOL_H
