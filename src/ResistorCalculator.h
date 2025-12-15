#ifndef RESISTORCALCULATOR_H
#define RESISTORCALCULATOR_H

#include <QObject>
#include <QString>
#include <QMap>

class ResistorCalculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int bandCount READ bandCount WRITE setBandCount NOTIFY bandCountChanged)
    Q_PROPERTY(int band1 READ band1 WRITE setBand1 NOTIFY band1Changed)
    Q_PROPERTY(int band2 READ band2 WRITE setBand2 NOTIFY band2Changed)
    Q_PROPERTY(int band3 READ band3 WRITE setBand3 NOTIFY band3Changed)
    Q_PROPERTY(int band4 READ band4 WRITE setBand4 NOTIFY band4Changed)
    Q_PROPERTY(int band5 READ band5 WRITE setBand5 NOTIFY band5Changed)
    Q_PROPERTY(int band6 READ band6 WRITE setBand6 NOTIFY band6Changed)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit ResistorCalculator(QObject *parent = nullptr);

    int bandCount() const;
    void setBandCount(int count);

    int band1() const;
    void setBand1(int value);

    int band2() const;
    void setBand2(int value);

    int band3() const;
    void setBand3(int value);

    int band4() const;
    void setBand4(int value);

    int band5() const;
    void setBand5(int value);

    int band6() const;
    void setBand6(int value);

    QString result() const;

    Q_INVOKABLE void calculate();
    Q_INVOKABLE QString getColorName(int colorIndex);
    Q_INVOKABLE QString getColorHex(int colorIndex);

signals:
    void bandCountChanged();
    void band1Changed();
    void band2Changed();
    void band3Changed();
    void band4Changed();
    void band5Changed();
    void band6Changed();
    void resultChanged();

private:
    int m_bandCount;
    int m_band1;
    int m_band2;
    int m_band3;
    int m_band4;
    int m_band5;
    int m_band6;
    QString m_result;

    QMap<int, int> digitValues;
    QMap<int, double> multiplierValues;
    QMap<int, double> toleranceValues;
    QMap<int, double> tempCoeffValues;
    QMap<int, QString> colorNames;
    QMap<int, QString> colorHexes;

    void initializeMaps();
    QString formatResistance(double resistance);
    QString formatTolerance(double tolerance);
    QString formatTempCoeff(double tempCoeff);
};

#endif // RESISTORCALCULATOR_H
