#ifndef QRCODEGENERATOR_H
#define QRCODEGENERATOR_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QQuickImageProvider>
#include <QMap>

class QRCodeGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString imageSource READ imageSource NOTIFY imageSourceChanged)
    Q_PROPERTY(bool hasQRCode READ hasQRCode NOTIFY hasQRCodeChanged)
    Q_PROPERTY(int moduleSize READ moduleSize WRITE setModuleSize NOTIFY moduleSizeChanged)
    Q_PROPERTY(int errorCorrectionLevel READ errorCorrectionLevel WRITE setErrorCorrectionLevel NOTIFY errorCorrectionLevelChanged)

public:
    explicit QRCodeGenerator(QObject *parent = nullptr);

    QString text() const;
    void setText(const QString &text);

    QString imageSource() const;
    bool hasQRCode() const;
    
    int moduleSize() const;
    void setModuleSize(int size);
    
    int errorCorrectionLevel() const;
    void setErrorCorrectionLevel(int level);

    Q_INVOKABLE void generate();
    Q_INVOKABLE bool saveToFile(const QString &filePath);
    Q_INVOKABLE void copyToClipboard();

    QImage getQRCodeImage() const;

signals:
    void textChanged();
    void imageSourceChanged();
    void hasQRCodeChanged();
    void moduleSizeChanged();
    void errorCorrectionLevelChanged();
    void saveSuccess(const QString &path);
    void saveError(const QString &error);
    void copySuccess();
    void generateError(const QString &error);

private:
    QString m_text;
    QImage m_qrcodeImage;
    QString m_imageSource;
    int m_imageId;
    int m_moduleSize;
    int m_errorCorrectionLevel; // 0=L, 1=M, 2=Q, 3=H
};

// 图像提供器
class QRCodeImageProvider : public QQuickImageProvider
{
public:
    QRCodeImageProvider();
    
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    
    void setImage(const QString &id, const QImage &image);
    
private:
    QMap<QString, QImage> m_images;
};

extern QRCodeImageProvider *g_qrcodeImageProvider;

#endif // QRCODEGENERATOR_H
