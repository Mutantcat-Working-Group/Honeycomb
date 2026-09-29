#ifndef GAMEASSETGENERATOR_H
#define GAMEASSETGENERATOR_H

#include <QImage>
#include <QObject>
#include <QString>

// 游戏开发资产生成后端：目前提供「黑白透明遮罩」底图生成。
// 用 QImage 按精确像素绘制三个横向排列的矩形（黑 / 白 / 透明），
// 既可导出 PNG，也可返回 data-url 供界面实时预览。
class GameAssetGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
public:
    explicit GameAssetGenerator(QObject *parent = nullptr);

    QString errorMessage() const;

    // 生成三色横向排列图的 data-url（image/png;base64,...），用于即时预览。
    Q_INVOKABLE QString maskDataUrl(int blackW, int blackH,
                                    int whiteW, int whiteH,
                                    int clearW, int clearH) const;

    // 生成并保存 PNG 到指定路径，成功返回 true。
    Q_INVOKABLE bool saveMask(const QString &path,
                              int blackW, int blackH,
                              int whiteW, int whiteH,
                              int clearW, int clearH);

    Q_INVOKABLE int totalWidth(int blackW, int whiteW, int clearW) const;
    Q_INVOKABLE int totalHeight(int blackH, int whiteH, int clearH) const;

signals:
    void errorMessageChanged();

private:
    bool validateRects(int blackW, int blackH, int whiteW, int whiteH,
                       int clearW, int clearH, int &outW, int &outH) const;
    QImage buildImage(int blackW, int blackH, int whiteW, int whiteH,
                      int clearW, int clearH, int outW, int outH) const;
    void setErrorMessage(const QString &message);

    QString m_errorMessage;
};

#endif // GAMEASSETGENERATOR_H
