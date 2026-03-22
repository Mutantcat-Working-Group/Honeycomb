#ifndef QRCODESCANNER_H
#define QRCODESCANNER_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QQuickImageProvider>
#include <QMap>

class QRCodeScanner : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString imageSource READ imageSource NOTIFY imageSourceChanged)
    Q_PROPERTY(bool hasImage READ hasImage NOTIFY hasImageChanged)
    Q_PROPERTY(QString formatName READ formatName NOTIFY formatNameChanged)

public:
    explicit QRCodeScanner(QObject *parent = nullptr);

    QString result() const;
    QString imageSource() const;
    bool hasImage() const;
    QString formatName() const;

    Q_INVOKABLE void scanFromFile(const QString &filePath);
    Q_INVOKABLE void scanFromClipboard();
    Q_INVOKABLE void captureScreen();
    Q_INVOKABLE void copyResult();

signals:
    void resultChanged();
    void imageSourceChanged();
    void hasImageChanged();
    void formatNameChanged();
    void scanSuccess(const QString &text);
    void scanError(const QString &error);
    void copySuccess();
    void captureFinished();

private:
    void decodeImage(const QImage &image);
    void updateImageSource(const QImage &image);

    QString m_result;
    QString m_imageSource;
    QString m_formatName;
    QImage m_currentImage;
    int m_imageId;
};

// Image provider for displaying scanned images in QML
class QRScannerImageProvider : public QQuickImageProvider
{
public:
    QRScannerImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    void setImage(const QString &id, const QImage &image);

private:
    QMap<QString, QImage> m_images;
};

extern QRScannerImageProvider *g_qrScannerImageProvider;

#endif // QRCODESCANNER_H
