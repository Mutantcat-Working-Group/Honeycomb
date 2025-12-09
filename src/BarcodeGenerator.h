#ifndef BARCODEGENERATOR_H
#define BARCODEGENERATOR_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QQuickImageProvider>

class BarcodeGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString imageSource READ imageSource NOTIFY imageSourceChanged)
    Q_PROPERTY(bool hasBarcode READ hasBarcode NOTIFY hasBarcodeChanged)

public:
    explicit BarcodeGenerator(QObject *parent = nullptr);

    QString text() const;
    void setText(const QString &text);

    QString imageSource() const;
    bool hasBarcode() const;

    Q_INVOKABLE void generate();
    Q_INVOKABLE bool saveToFile(const QString &filePath);
    Q_INVOKABLE void copyToClipboard();

    // 获取生成的条形码图像
    QImage getBarcodeImage() const;

signals:
    void textChanged();
    void imageSourceChanged();
    void hasBarcodeChanged();
    void saveSuccess(const QString &path);
    void saveError(const QString &error);
    void copySuccess();

private:
    QString m_text;
    QImage m_barcodeImage;
    QString m_imageSource;
    int m_imageId;
    
    // Code 128 编码表
    QVector<QString> getCode128Patterns() const;
    int calculateChecksum(const QVector<int> &values) const;
};

// 图像提供器，用于在 QML 中显示条形码
class BarcodeImageProvider : public QQuickImageProvider
{
public:
    BarcodeImageProvider();
    
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    
    void setImage(const QString &id, const QImage &image);
    
private:
    QMap<QString, QImage> m_images;
};

// 全局图像提供器实例
extern BarcodeImageProvider *g_barcodeImageProvider;

#endif // BARCODEGENERATOR_H
