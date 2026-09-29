#include "GameAssetGenerator.h"

#include <QUrl>
#include <QBuffer>
#include <QFileInfo>
#include <QPainter>
#include <QSaveFile>

namespace {
// 单块与整体的像素上下限，防止误输入把内存撑爆。
constexpr int kMaxSide = 16384;
constexpr int kMaxTotalWidth = 65536;
constexpr int kMinSide = 1;

// QML 的 FileDialog 交回来的是 file:// URL，这里统一成本地路径。
// 与 QRCodeGenerator::saveToFile 的处理保持一致，Windows 上前导斜杠要去掉。
// Qt 的 QUrl::toLocalFile() 会保留 localhost 主机名（//localhost/path），
// 而真正的 UNC（file://server/share）必须原样保留成 //server/share。
QString normalizeLocalPath(const QString &raw)
{
    QString path = raw.trimmed();
    if (path.startsWith(QLatin1String("file:"), Qt::CaseInsensitive)) {
        const QUrl url(path);
        QString local = url.isValid() ? url.toLocalFile() : QString();
        if (local.isEmpty()) {
            path.remove(0, 5);
        } else {
            path = local;
            if (url.host().compare(QLatin1String("localhost"), Qt::CaseInsensitive) == 0
                && path.startsWith(QLatin1String("//localhost"))) {
                path.remove(0, 11);
            }
        }
    }
    if (path.size() > 2 && path.at(0) == QLatin1Char('/') && path.at(2) == QLatin1Char(':')) {
        path.remove(0, 1);
    }
    return path;
}
}

GameAssetGenerator::GameAssetGenerator(QObject *parent)
    : QObject(parent)
{
}

QString GameAssetGenerator::errorMessage() const
{
    return m_errorMessage;
}

int GameAssetGenerator::totalWidth(int blackW, int whiteW, int clearW) const
{
    return blackW + whiteW + clearW;
}

int GameAssetGenerator::totalHeight(int blackH, int whiteH, int clearH) const
{
    int h = blackH;
    if (whiteH > h) {
        h = whiteH;
    }
    if (clearH > h) {
        h = clearH;
    }
    return h;
}

bool GameAssetGenerator::validateRects(int blackW, int blackH, int whiteW, int whiteH,
                                       int clearW, int clearH, int &outW, int &outH) const
{
    const int sides[] = {blackW, blackH, whiteW, whiteH, clearW, clearH};
    for (int value : sides) {
        if (value < kMinSide || value > kMaxSide) {
            return false;
        }
    }

    outW = totalWidth(blackW, whiteW, clearW);
    outH = totalHeight(blackH, whiteH, clearH);
    return outW <= kMaxTotalWidth && outH <= kMaxSide;
}

QImage GameAssetGenerator::buildImage(int blackW, int blackH, int whiteW, int whiteH,
                                      int clearW, int clearH, int outW, int outH) const
{
    // 预置透明底，透明矩形无需再画（保持 alpha=0）。
    QImage image(outW, outH, QImage::Format_ARGB32);
    image.fill(Qt::transparent);

    QPainter painter(&image);
    painter.setRenderHint(QPainter::Antialiasing, false);
    painter.fillRect(0, 0, blackW, blackH, Qt::black);
    painter.fillRect(blackW, 0, whiteW, whiteH, Qt::white);
    painter.fillRect(blackW + whiteW, 0, clearW, clearH, Qt::transparent);
    painter.end();

    return image;
}

QString GameAssetGenerator::maskDataUrl(int blackW, int blackH, int whiteW, int whiteH,
                                        int clearW, int clearH) const
{
    int outW = 0;
    int outH = 0;
    if (!validateRects(blackW, blackH, whiteW, whiteH, clearW, clearH, outW, outH)) {
        return QString();
    }

    QImage image = buildImage(blackW, blackH, whiteW, whiteH, clearW, clearH, outW, outH);
    QByteArray bytes;
    QBuffer buffer(&bytes);
    buffer.open(QIODevice::WriteOnly);
    if (!image.save(&buffer, "PNG")) {
        return QString();
    }
    return QStringLiteral("data:image/png;base64,") + QString::fromLatin1(bytes.toBase64());
}

bool GameAssetGenerator::saveMask(const QString &path,
                                   int blackW, int blackH, int whiteW, int whiteH,
                                   int clearW, int clearH)
{
    if (path.isEmpty()) {
        setErrorMessage(QObject::tr("保存路径为空"));
        return false;
    }

    const QString target = normalizeLocalPath(path);
    if (target.isEmpty()) {
        setErrorMessage(QObject::tr("保存路径为空"));
        return false;
    }

    int outW = 0;
    int outH = 0;
    if (!validateRects(blackW, blackH, whiteW, whiteH, clearW, clearH, outW, outH)) {
        setErrorMessage(QObject::tr("宽高需在 1~16384 之间，且总宽不超过 65536"));
        return false;
    }

    QImage image = buildImage(blackW, blackH, whiteW, whiteH, clearW, clearH, outW, outH);

    // 原子写入，避免中断时留下半个文件。
    QSaveFile file(target);
    if (!file.open(QIODevice::WriteOnly)) {
        setErrorMessage(QObject::tr("无法写入：%1").arg(target));
        return false;
    }
    if (!image.save(static_cast<QIODevice *>(&file), "PNG")) {
        file.cancelWriting();
        setErrorMessage(QObject::tr("PNG 编码失败"));
        return false;
    }
    if (!file.commit()) {
        setErrorMessage(QObject::tr("保存失败：%1").arg(target));
        return false;
    }

    setErrorMessage(QString());
    return true;
}

void GameAssetGenerator::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}
