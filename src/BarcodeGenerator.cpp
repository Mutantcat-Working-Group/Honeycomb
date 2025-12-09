#include "BarcodeGenerator.h"
#include <QGuiApplication>
#include <QClipboard>
#include <QPainter>
#include <QFileInfo>
#include <QDir>

// 全局图像提供器实例
BarcodeImageProvider *g_barcodeImageProvider = nullptr;

// ==================== BarcodeImageProvider ====================

BarcodeImageProvider::BarcodeImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage BarcodeImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
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
        return image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }
    
    return image;
}

void BarcodeImageProvider::setImage(const QString &id, const QImage &image)
{
    m_images[id] = image;
}

// ==================== BarcodeGenerator ====================

BarcodeGenerator::BarcodeGenerator(QObject *parent)
    : QObject(parent)
    , m_text("")
    , m_imageId(0)
{
}

QString BarcodeGenerator::text() const
{
    return m_text;
}

void BarcodeGenerator::setText(const QString &text)
{
    if (m_text != text) {
        m_text = text;
        emit textChanged();
    }
}

QString BarcodeGenerator::imageSource() const
{
    return m_imageSource;
}

bool BarcodeGenerator::hasBarcode() const
{
    return !m_barcodeImage.isNull();
}

QImage BarcodeGenerator::getBarcodeImage() const
{
    return m_barcodeImage;
}

// Code 128 编码模式 (Code 128B - 支持所有ASCII字符)
QVector<QString> BarcodeGenerator::getCode128Patterns() const
{
    return {
        "11011001100", "11001101100", "11001100110", "10010011000", "10010001100", // 0-4
        "10001001100", "10011001000", "10011000100", "10001100100", "11001001000", // 5-9
        "11001000100", "11000100100", "10110011100", "10011011100", "10011001110", // 10-14
        "10111001100", "10011101100", "10011100110", "11001110010", "11001011100", // 15-19
        "11001001110", "11011100100", "11001110100", "11101101110", "11101001100", // 20-24
        "11100101100", "11100100110", "11101100100", "11100110100", "11100110010", // 25-29
        "11011011000", "11011000110", "11000110110", "10100011000", "10001011000", // 30-34
        "10001000110", "10110001000", "10001101000", "10001100010", "11010001000", // 35-39
        "11000101000", "11000100010", "10110111000", "10110001110", "10001101110", // 40-44
        "10111011000", "10111000110", "10001110110", "11101110110", "11010001110", // 45-49
        "11000101110", "11011101000", "11011100010", "11011101110", "11101011000", // 50-54
        "11101000110", "11100010110", "11101101000", "11101100010", "11100011010", // 55-59
        "11101111010", "11001000010", "11110001010", "10100110000", "10100001100", // 60-64
        "10010110000", "10010000110", "10000101100", "10000100110", "10110010000", // 65-69
        "10110000100", "10011010000", "10011000010", "10000110100", "10000110010", // 70-74
        "11000010010", "11001010000", "11110111010", "11000010100", "10001111010", // 75-79
        "10100111100", "10010111100", "10010011110", "10111100100", "10011110100", // 80-84
        "10011110010", "11110100100", "11110010100", "11110010010", "11011011110", // 85-89
        "11011110110", "11110110110", "10101111000", "10100011110", "10001011110", // 90-94
        "10111101000", "10111100010", "11110101000", "11110100010", "10111011110", // 95-99
        "10111101110", "11101011110", "11110101110", "11010000100", "11010010000", // 100-104 (特殊码)
        "11010011100"  // 105: Start Code B
    };
}

int BarcodeGenerator::calculateChecksum(const QVector<int> &values) const
{
    int sum = values[0]; // Start code 的值
    for (int i = 1; i < values.size(); ++i) {
        sum += values[i] * i;
    }
    return sum % 103;
}

void BarcodeGenerator::generate()
{
    if (m_text.isEmpty()) {
        m_barcodeImage = QImage();
        m_imageSource = "";
        emit imageSourceChanged();
        emit hasBarcodeChanged();
        return;
    }

    QVector<QString> patterns = getCode128Patterns();
    QVector<int> values;
    QString barcodePattern;

    // Start Code B (值 = 104)
    values.append(104);
    barcodePattern += patterns[104];

    // 编码每个字符
    for (QChar ch : m_text) {
        int asciiValue = ch.toLatin1();
        if (asciiValue >= 32 && asciiValue <= 127) {
            int code128Value = asciiValue - 32;
            values.append(code128Value);
            barcodePattern += patterns[code128Value];
        }
    }

    // 计算校验位
    int checksum = calculateChecksum(values);
    barcodePattern += patterns[checksum];

    // Stop Code
    barcodePattern += "1100011101011"; // Stop pattern

    // 生成图像
    int moduleWidth = 2;  // 每个模块的宽度（像素）
    int height = 100;      // 条形码高度
    int quietZone = 20;    // 两侧空白区域
    int textHeight = 25;   // 文字区域高度
    
    int barcodeWidth = barcodePattern.length() * moduleWidth;
    int totalWidth = barcodeWidth + quietZone * 2;
    int totalHeight = height + textHeight;

    QImage image(totalWidth, totalHeight, QImage::Format_ARGB32);
    image.fill(Qt::white);

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing);

    // 绘制条形码
    int x = quietZone;
    for (QChar bit : barcodePattern) {
        if (bit == '1') {
            painter.fillRect(x, 0, moduleWidth, height, Qt::black);
        }
        x += moduleWidth;
    }

    // 绘制文字
    painter.setPen(Qt::black);
    QFont font("Arial", 12);
    painter.setFont(font);
    QRect textRect(0, height + 5, totalWidth, textHeight - 5);
    painter.drawText(textRect, Qt::AlignCenter, m_text);

    painter.end();

    m_barcodeImage = image;

    // 更新图像提供器
    QString imageId = QString("barcode_%1").arg(++m_imageId);
    if (g_barcodeImageProvider) {
        g_barcodeImageProvider->setImage(imageId, m_barcodeImage);
    }
    
    m_imageSource = QString("image://barcode/%1").arg(imageId);
    emit imageSourceChanged();
    emit hasBarcodeChanged();
}

bool BarcodeGenerator::saveToFile(const QString &filePath)
{
    if (m_barcodeImage.isNull()) {
        emit saveError("没有可保存的条形码");
        return false;
    }

    // 处理 file:/// URL
    QString path = filePath;
    if (path.startsWith("file:///")) {
        path = path.mid(8);
    }

    // 确保目录存在
    QFileInfo fileInfo(path);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    if (m_barcodeImage.save(path)) {
        emit saveSuccess(path);
        return true;
    } else {
        emit saveError("保存失败：" + path);
        return false;
    }
}

void BarcodeGenerator::copyToClipboard()
{
    if (m_barcodeImage.isNull()) {
        return;
    }

    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setImage(m_barcodeImage);
    emit copySuccess();
}
