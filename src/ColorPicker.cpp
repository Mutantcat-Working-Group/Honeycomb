#include "ColorPicker.h"
#include <QGuiApplication>
#include <QPixmap>
#include <QImage>
#include <QRect>
#include <QCursor>

ColorPicker::ColorPicker(QObject *parent)
    : QObject(parent)
    , m_isPicking(false)
    , m_targetScreen(nullptr)
{
}

QColor ColorPicker::currentColor() const
{
    return m_currentColor;
}

bool ColorPicker::isPicking() const
{
    return m_isPicking;
}

QPoint ColorPicker::cursorPosition() const
{
    return m_cursorPosition;
}

QScreen* ColorPicker::getScreenForWindow(QWindow *window)
{
    if (!window) {
        return QGuiApplication::primaryScreen();
    }
    
    QScreen *screen = window->screen();
    if (!screen) {
        screen = QGuiApplication::primaryScreen();
    }
    
    return screen;
}

void ColorPicker::startPicking(QWindow *window)
{
    if (m_isPicking) {
        return;
    }
    
    m_targetScreen = getScreenForWindow(window);
    m_isPicking = true;
    emit isPickingChanged();
}

void ColorPicker::stopPicking()
{
    if (!m_isPicking) {
        return;
    }
    
    m_isPicking = false;
    m_targetScreen = nullptr;
    emit isPickingChanged();
}

QColor ColorPicker::getColorAt(int x, int y)
{
    if (!m_targetScreen) {
        m_targetScreen = QGuiApplication::primaryScreen();
    }
    
    if (!m_targetScreen) {
        return QColor();
    }
    
    // 获取屏幕的几何信息
    QRect screenGeometry = m_targetScreen->geometry();
    
    // 确保坐标在屏幕范围内
    if (x < screenGeometry.left() || x >= screenGeometry.right() ||
        y < screenGeometry.top() || y >= screenGeometry.bottom()) {
        return QColor();
    }
    
    // 将全局坐标转换为屏幕相对坐标
    // grabWindow使用的坐标是相对于屏幕的，而不是全局坐标
    int screenX = x - screenGeometry.left();
    int screenY = y - screenGeometry.top();
    
    // 确保坐标在有效范围内
    if (screenX < 0 || screenX >= screenGeometry.width() ||
        screenY < 0 || screenY >= screenGeometry.height()) {
        return QColor();
    }
    
    // 截取屏幕（只截取一个像素点）
    // grabWindow(0, x, y, w, h) 中，0表示桌面窗口，坐标是相对于屏幕的
    QPixmap pixmap = m_targetScreen->grabWindow(
        0,
        screenX, screenY,
        1, 1
    );
    
    if (pixmap.isNull()) {
        return QColor();
    }
    
    QImage image = pixmap.toImage();
    if (image.isNull() || image.width() == 0 || image.height() == 0) {
        return QColor();
    }
    
    QColor color = image.pixelColor(0, 0);
    
    if (color != m_currentColor) {
        m_currentColor = color;
        m_cursorPosition = QPoint(x, y);
        emit currentColorChanged();
        emit cursorPositionChanged();
    }
    
    return color;
}

QColor ColorPicker::getColorAtCursor()
{
    QPoint globalPos = QCursor::pos();
    return getColorAt(globalPos.x(), globalPos.y());
}
