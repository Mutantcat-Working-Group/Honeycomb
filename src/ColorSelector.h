#ifndef COLORSELECTOR_H
#define COLORSELECTOR_H

#include <QObject>
#include <QColor>
#include <QWidget>

class ColorSelector : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor currentColor READ currentColor NOTIFY currentColorChanged)

public:
    explicit ColorSelector(QObject *parent = nullptr);

    QColor currentColor() const;

    Q_INVOKABLE QColor openColorDialog(QColor initialColor = Qt::white, QWidget *parent = nullptr);

signals:
    void currentColorChanged();

private:
    QColor m_currentColor;
};

#endif // COLORSELECTOR_H

