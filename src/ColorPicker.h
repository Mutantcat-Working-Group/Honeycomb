#ifndef COLORPICKER_H
#define COLORPICKER_H

#include <QObject>
#include <QColor>
#include <QPoint>
#include <QScreen>
#include <QGuiApplication>
#include <QWindow>

class ColorPicker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor currentColor READ currentColor NOTIFY currentColorChanged)
    Q_PROPERTY(bool isPicking READ isPicking NOTIFY isPickingChanged)
    Q_PROPERTY(QPoint cursorPosition READ cursorPosition NOTIFY cursorPositionChanged)

public:
    explicit ColorPicker(QObject *parent = nullptr);

    QColor currentColor() const;
    bool isPicking() const;
    QPoint cursorPosition() const;

    Q_INVOKABLE void startPicking(QWindow *window);
    Q_INVOKABLE void stopPicking();
    Q_INVOKABLE QColor getColorAt(int x, int y);
    Q_INVOKABLE QColor getColorAtCursor();
    Q_INVOKABLE QScreen* getScreenForWindow(QWindow *window);

signals:
    void currentColorChanged();
    void isPickingChanged();
    void cursorPositionChanged();
    void colorPicked(const QColor &color);
    void pickingCancelled();

private:
    QColor m_currentColor;
    bool m_isPicking;
    QPoint m_cursorPosition;
    QScreen *m_targetScreen;
};

#endif // COLORPICKER_H
