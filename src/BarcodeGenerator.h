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
    Q_PROPERTY(int batchProgress READ batchProgress NOTIFY batchProgressChanged)
    Q_PROPERTY(int batchTotal READ batchTotal NOTIFY batchProgressChanged)
    Q_PROPERTY(bool batchRunning READ batchRunning NOTIFY batchRunningChanged)
    Q_PROPERTY(QString batchLastError READ batchLastError NOTIFY batchFinished)
    Q_PROPERTY(QString batchOutputDir READ batchOutputDir NOTIFY batchFinished)
    Q_PROPERTY(int batchDurationMs READ batchDurationMs NOTIFY batchDurationChanged)

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

    // 批量生成(同步循环,带可取消)。号段拼接规则:prefix + 按 endNumber 位数补零的数字。
    // 返回是否全部成功(取消视为失败,已生成数量通过 batchProgress 查看)。
    Q_INVOKABLE bool generateBatch(const QString &prefix,
                                   int startNumber,
                                   int endNumber,
                                   const QString &outputDir);

    Q_INVOKABLE void cancelBatch();
    Q_INVOKABLE void clearBatch();

    int batchProgress() const;
    int batchTotal() const;
    bool batchRunning() const;
    QString batchLastError() const;
    QString batchOutputDir() const;
    int batchDurationMs() const;

signals:
    void textChanged();
    void imageSourceChanged();
    void hasBarcodeChanged();
    void saveSuccess(const QString &path);
    void saveError(const QString &error);
    void copySuccess();
    void batchProgressChanged();
    void batchRunningChanged();
    void batchDurationChanged();
    void batchFinished(int successCount, int totalCount, const QString &dir);

private:
    QString m_text;
    QImage m_barcodeImage;
    QString m_imageSource;
    int m_imageId;

    // 批量任务状态
    int m_batchProgress;
    int m_batchTotal;
    bool m_batchRunning;
    bool m_cancelRequested;
    QString m_batchLastError;
    QString m_batchOutputDir;
    qint64 m_batchStartMs;
    int m_batchDurationMs;

    // Code 128 编码表
    QVector<QString> getCode128Patterns() const;
    int calculateChecksum(const QVector<int> &values) const;

    // 把任意文本渲染成条形码 QImage(CODE128-B)。批量与单次生成共用。
    QImage renderBarcodeImage(const QString &text) const;
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
