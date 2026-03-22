#include "QRCodeScanner.h"
#include <QGuiApplication>
#include <QClipboard>
#include <QScreen>
#include <QPixmap>
#include <QUrl>
#include <ZXing/ReadBarcode.h>

QRScannerImageProvider *g_qrScannerImageProvider = nullptr;

// ==================== QRScannerImageProvider ====================

QRScannerImageProvider::QRScannerImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage QRScannerImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage image = m_images.value(id, QImage());

    if (image.isNull()) {
        image = QImage(1, 1, QImage::Format_ARGB32);
        image.fill(Qt::transparent);
    }

    if (size)
        *size = image.size();

    if (requestedSize.isValid() && requestedSize != image.size())
        return image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

    return image;
}

void QRScannerImageProvider::setImage(const QString &id, const QImage &image)
{
    m_images[id] = image;
}

// ==================== QRCodeScanner ====================

QRCodeScanner::QRCodeScanner(QObject *parent)
    : QObject(parent)
    , m_imageId(0)
{
}

QString QRCodeScanner::result() const
{
    return m_result;
}

QString QRCodeScanner::imageSource() const
{
    return m_imageSource;
}

bool QRCodeScanner::hasImage() const
{
    return !m_currentImage.isNull();
}

QString QRCodeScanner::formatName() const
{
    return m_formatName;
}

void QRCodeScanner::scanFromFile(const QString &filePath)
{
    QString path = filePath;
    if (path.startsWith("file:///"))
        path = QUrl(path).toLocalFile();

    QImage image(path);
    if (image.isNull()) {
        emit scanError(QStringLiteral("\u65E0\u6CD5\u52A0\u8F7D\u56FE\u7247\u6587\u4EF6"));
        return;
    }

    updateImageSource(image);
    decodeImage(image);
}

void QRCodeScanner::scanFromClipboard()
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    QImage image = clipboard->image();

    if (image.isNull()) {
        emit scanError(QStringLiteral("\u526A\u8D34\u677F\u4E2D\u6CA1\u6709\u56FE\u7247"));
        return;
    }

    updateImageSource(image);
    decodeImage(image);
}

void QRCodeScanner::captureScreen()
{
    QScreen *screen = QGuiApplication::primaryScreen();
    if (!screen) {
        emit scanError(QStringLiteral("\u65E0\u6CD5\u83B7\u53D6\u5C4F\u5E55"));
        emit captureFinished();
        return;
    }

    QPixmap pixmap = screen->grabWindow(0);
    QImage image = pixmap.toImage();

    if (image.isNull()) {
        emit scanError(QStringLiteral("\u622A\u56FE\u5931\u8D25"));
        emit captureFinished();
        return;
    }

    updateImageSource(image);
    decodeImage(image);
    emit captureFinished();
}

void QRCodeScanner::copyResult()
{
    if (!m_result.isEmpty()) {
        QClipboard *clipboard = QGuiApplication::clipboard();
        clipboard->setText(m_result);
        emit copySuccess();
    }
}

void QRCodeScanner::updateImageSource(const QImage &image)
{
    m_currentImage = image;
    QString imageId = QString("scan_%1").arg(++m_imageId);
    if (g_qrScannerImageProvider)
        g_qrScannerImageProvider->setImage(imageId, m_currentImage);

    m_imageSource = QString("image://qrscanner/%1").arg(imageId);
    emit imageSourceChanged();
    emit hasImageChanged();
}

void QRCodeScanner::decodeImage(const QImage &image)
{
    try {
        QImage grayscale = image.convertToFormat(QImage::Format_Grayscale8);

        auto iv = ZXing::ImageView(
            grayscale.constBits(),
            grayscale.width(),
            grayscale.height(),
            ZXing::ImageFormat::Lum,
            grayscale.bytesPerLine()
        );

        // DecodeHints defaults: tryHarder=true, tryRotate=true, tryInvert=true
        ZXing::DecodeHints hints;

        auto results = ZXing::ReadBarcodes(iv, hints);

        if (results.empty()) {
            m_result = "";
            m_formatName = "";
            emit resultChanged();
            emit formatNameChanged();
            emit scanError(QStringLiteral("\u672A\u68C0\u6D4B\u5230\u4E8C\u7EF4\u7801\u6216\u6761\u7801"));
            return;
        }

        QStringList texts;
        QStringList formats;
        for (const auto &r : results) {
            texts.append(QString::fromStdString(r.text()));
            formats.append(QString::fromStdString(ZXing::ToString(r.format())));
        }

        m_result = texts.join(QStringLiteral("\n---\n"));
        m_formatName = formats.join(QStringLiteral(", "));
        emit resultChanged();
        emit formatNameChanged();
        emit scanSuccess(m_result);

    } catch (const std::exception &e) {
        m_result = "";
        m_formatName = "";
        emit resultChanged();
        emit formatNameChanged();
        emit scanError(QStringLiteral("\u89E3\u7801\u9519\u8BEF: ") + QString::fromLocal8Bit(e.what()));
    }
}
