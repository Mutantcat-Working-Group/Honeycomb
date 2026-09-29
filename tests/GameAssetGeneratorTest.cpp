#include "../src/GameAssetGenerator.h"

#include <QGuiApplication>
#include <QTemporaryDir>
#include <QUrl>

#include <cstdlib>

namespace {
void require(bool condition)
{
    if (!condition) {
        std::abort();
    }
}

QColor at(const QImage &image, int x, int y)
{
    return image.pixelColor(x, y);
}

QImage decodePng(const QString &dataUrl)
{
    const QByteArray prefix = "data:image/png;base64,";
    QByteArray bytes = dataUrl.toLatin1();
    require(bytes.startsWith(prefix));
    bytes = bytes.mid(prefix.size());
    QImage image;
    require(image.loadFromData(QByteArray::fromBase64(bytes), "PNG"));
    return image;
}
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    GameAssetGenerator generator;

    // 单块与整体的像素上下限：1 放行，0 与超限拒绝
    require(generator.maskDataUrl(0, 64, 64, 64, 64, 64).isEmpty());
    require(generator.maskDataUrl(64, 0, 64, 64, 64, 64).isEmpty());
    require(generator.maskDataUrl(20000, 64, 64, 64, 64, 64).isEmpty());
    require(generator.maskDataUrl(64, 20000, 64, 64, 64, 64).isEmpty());
    require(generator.maskDataUrl(32768, 64, 32768, 64, 64, 64).isEmpty());
    require(!generator.maskDataUrl(1, 1, 1, 1, 1, 1).isEmpty());

    // 总宽等于三块之和，总高取最大值；左上角对齐
    const QImage image = decodePng(generator.maskDataUrl(10, 20, 30, 5, 7, 25));
    require(image.width() == 47);
    require(image.height() == 25);
    require(at(image, 0, 0) == QColor(0, 0, 0, 255));
    require(at(image, 9, 19) == QColor(0, 0, 0, 255));
    require(at(image, 10, 0) == QColor(255, 255, 255, 255));
    require(at(image, 39, 0) == QColor(255, 255, 255, 255));
    require(at(image, 40, 0) == QColor(0, 0, 0, 0));
    require(at(image, 46, 24) == QColor(0, 0, 0, 0));
    // 黑块高 20、白块高 5，它们下方露出的必须是透明
    require(at(image, 0, 24) == QColor(0, 0, 0, 0));
    require(at(image, 10, 5) == QColor(0, 0, 0, 0));

    QTemporaryDir dir;
    require(dir.isValid());
    const QString png = dir.filePath("mask.png");
    require(generator.saveMask(png, 8, 6, 8, 6, 8, 6));
    require(generator.errorMessage().isEmpty());

    const QImage fromDisk(png);
    require(!fromDisk.isNull());
    require(fromDisk.width() == 24);
    require(fromDisk.height() == 6);
    require(at(fromDisk, 0, 0) == QColor(0, 0, 0, 255));
    require(at(fromDisk, 8, 0) == QColor(255, 255, 255, 255));
    require(at(fromDisk, 16, 0) == QColor(0, 0, 0, 0));

    // FileDialog 交回来的 file:// URL 必须能落盘。Qt6 的 QUrl::toString()
    // 默认不解码空格，所以带空格与 %20 两种形态都要覆盖。
    const QString spaced = dir.filePath("spaced name.png");
    const QString spacedUrl = QUrl::fromLocalFile(spaced).toString();
    require(spacedUrl.contains(" "));
    require(generator.saveMask(spacedUrl, 8, 6, 8, 6, 8, 6));
    require(QFile::exists(spaced));
    require(generator.saveMask(QUrl::fromLocalFile(spaced).toString(QUrl::FullyEncoded), 8, 6, 8, 6, 8, 6));
    // QUrl::toLocalFile() 会保留 localhost 主机名，这里要按本机剥掉
    const QString localhostUrl = "file://localhost" + QUrl::fromLocalFile(spaced).path();
    require(generator.saveMask(localhostUrl, 8, 6, 8, 6, 8, 6));
    // 真正的 UNC 主机名不能抹掉，只能是因为写不进而失败
    require(!generator.saveMask("file://nosuchserver.invalid/share/a.png", 4, 4, 4, 4, 4, 4));

    // 空路径与非法尺寸拒绝
    require(!generator.saveMask("", 8, 6, 8, 6, 8, 6));
    require(!generator.saveMask(png, 0, 6, 8, 6, 8, 6));

    return 0;
}
