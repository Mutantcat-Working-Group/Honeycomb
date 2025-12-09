#include "QRCodeGenerator.h"
#include "../lib/qrcodegen/qrcodegen.hpp"
#include <QGuiApplication>
#include <QClipboard>
#include <QPainter>
#include <QFileInfo>
#include <QDir>

using namespace qrcodegen;

QRCodeImageProvider *g_qrcodeImageProvider = nullptr;

// ==================== QRCodeImageProvider ====================

QRCodeImageProvider::QRCodeImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage QRCodeImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage image = m_images.value(id, QImage());
    
    if (image.isNull()) {
        image = QImage(1, 1, QImage::Format_ARGB32);
        image.fill(Qt::transparent);
    }
    
    if (size) {
        *size = image.size();
    }
    
    if (requestedSize.isValid() && requestedSize != image.size()) {
        return image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::FastTransformation);
    }
    
    return image;
}

void QRCodeImageProvider::setImage(const QString &id, const QImage &image)
{
    m_images[id] = image;
}

// ==================== QRCodeGenerator ====================

QRCodeGenerator::QRCodeGenerator(QObject *parent)
    : QObject(parent)
    , m_text("")
    , m_imageId(0)
    , m_moduleSize(8)
    , m_errorCorrectionLevel(0) // L
{
}

QString QRCodeGenerator::text() const
{
    return m_text;
}

void QRCodeGenerator::setText(const QString &text)
{
    if (m_text != text) {
        m_text = text;
        emit textChanged();
    }
}

QString QRCodeGenerator::imageSource() const
{
    return m_imageSource;
}

bool QRCodeGenerator::hasQRCode() const
{
    return !m_qrcodeImage.isNull();
}

int QRCodeGenerator::moduleSize() const
{
    return m_moduleSize;
}

void QRCodeGenerator::setModuleSize(int size)
{
    if (size < 1) size = 1;
    if (size > 20) size = 20;
    if (m_moduleSize != size) {
        m_moduleSize = size;
        emit moduleSizeChanged();
    }
}

int QRCodeGenerator::errorCorrectionLevel() const
{
    return m_errorCorrectionLevel;
}

void QRCodeGenerator::setErrorCorrectionLevel(int level)
{
    if (level < 0) level = 0;
    if (level > 3) level = 3;
    if (m_errorCorrectionLevel != level) {
        m_errorCorrectionLevel = level;
        emit errorCorrectionLevelChanged();
    }
}

QImage QRCodeGenerator::getQRCodeImage() const
{
    return m_qrcodeImage;
}

void QRCodeGenerator::generate()
{
    if (m_text.isEmpty()) {
        m_qrcodeImage = QImage();
        m_imageSource = "";
        emit imageSourceChanged();
        emit hasQRCodeChanged();
        return;
    }
    
    try {
        // 将 QString 转换为 UTF-8 字节
        QByteArray utf8Data = m_text.toUtf8();
        
        // 选择纠错级别
        QrCode::Ecc ecl;
        switch (m_errorCorrectionLevel) {
            case 0: ecl = QrCode::Ecc::LOW; break;
            case 1: ecl = QrCode::Ecc::MEDIUM; break;
            case 2: ecl = QrCode::Ecc::QUARTILE; break;
            case 3: ecl = QrCode::Ecc::HIGH; break;
            default: ecl = QrCode::Ecc::LOW; break;
        }
        
        // 创建二维码 - 使用字节模式处理 UTF-8 数据
        std::vector<uint8_t> dataVec(utf8Data.begin(), utf8Data.end());
        QrCode qr = QrCode::encodeBinary(dataVec, ecl);
        
        int qrSize = qr.getSize();
        int quietZone = 4;
        int totalSize = (qrSize + quietZone * 2) * m_moduleSize;
        
        QImage image(totalSize, totalSize, QImage::Format_ARGB32);
        image.fill(Qt::white);
        
        QPainter painter(&image);
        painter.setPen(Qt::NoPen);
        painter.setBrush(Qt::black);
        
        for (int y = 0; y < qrSize; y++) {
            for (int x = 0; x < qrSize; x++) {
                if (qr.getModule(x, y)) {
                    painter.drawRect((x + quietZone) * m_moduleSize,
                                   (y + quietZone) * m_moduleSize,
                                   m_moduleSize, m_moduleSize);
                }
            }
        }
        
        painter.end();
        
        m_qrcodeImage = image;
        
        QString imageId = QString("qrcode_%1").arg(++m_imageId);
        if (g_qrcodeImageProvider) {
            g_qrcodeImageProvider->setImage(imageId, m_qrcodeImage);
        }
        
        m_imageSource = QString("image://qrcode/%1").arg(imageId);
        emit imageSourceChanged();
        emit hasQRCodeChanged();
        
    } catch (const std::exception &e) {
        m_qrcodeImage = QImage();
        m_imageSource = "";
        emit imageSourceChanged();
        emit hasQRCodeChanged();
        emit generateError(QString::fromStdString(e.what()));
    }
}

bool QRCodeGenerator::saveToFile(const QString &filePath)
{
    if (m_qrcodeImage.isNull()) {
        emit saveError("没有可保存的二维码");
        return false;
    }
    
    QString path = filePath;
    if (path.startsWith("file:///")) {
        path = path.mid(8);
    }
    
    QFileInfo fileInfo(path);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    
    if (m_qrcodeImage.save(path)) {
        emit saveSuccess(path);
        return true;
    } else {
        emit saveError("保存失败：" + path);
        return false;
    }
}

void QRCodeGenerator::copyToClipboard()
{
    if (m_qrcodeImage.isNull()) {
        return;
    }
    
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setImage(m_qrcodeImage);
    emit copySuccess();
}
