#include "ColorSelector.h"
#include <QColorDialog>
#include <QWindow>
#include <QGuiApplication>
#include <QWidget>

ColorSelector::ColorSelector(QObject *parent)
    : QObject(parent)
    , m_currentColor(QColor("#165DFF"))
{
}

QColor ColorSelector::currentColor() const
{
    return m_currentColor;
}

QColor ColorSelector::openColorDialog(QColor initialColor, QWidget *parent)
{
    // 如果没有提供parent，创建一个临时的QWidget作为parent
    QWidget *dialogParent = parent;
    if (!dialogParent) {
        // 尝试从QML窗口获取对应的QWidget
        // 在Qt6中，QColorDialog需要QWidget*作为parent
        // 如果没有parent，可以传入nullptr，但最好有一个parent
        QWindow *window = qobject_cast<QWindow*>(this->parent());
        if (window) {
            // 在Qt6中，我们可以通过QWindow获取对应的QWidget
            // 但更简单的方法是直接使用nullptr，QColorDialog会使用默认的parent
            dialogParent = nullptr;
        }
    }
    
    // 使用静态方法打开颜色选择对话框
    QColor color = QColorDialog::getColor(initialColor, dialogParent, "选择颜色");
    
    if (color.isValid()) {
        if (m_currentColor != color) {
            m_currentColor = color;
            emit currentColorChanged();
        }
    }
    
    return color;
}

