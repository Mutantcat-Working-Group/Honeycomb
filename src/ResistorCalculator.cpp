#include "ResistorCalculator.h"
#include <cmath>

ResistorCalculator::ResistorCalculator(QObject *parent)
    : QObject(parent)
    , m_bandCount(4)
    , m_band1(0)
    , m_band2(0)
    , m_band3(0)
    , m_band4(5)
    , m_band5(0)
    , m_band6(0)
    , m_result("")
{
    initializeMaps();
}

void ResistorCalculator::initializeMaps()
{
    digitValues[0] = 0;
    digitValues[1] = 1;
    digitValues[2] = 2;
    digitValues[3] = 3;
    digitValues[4] = 4;
    digitValues[5] = 5;
    digitValues[6] = 6;
    digitValues[7] = 7;
    digitValues[8] = 8;
    digitValues[9] = 9;

    multiplierValues[0] = 1;
    multiplierValues[1] = 10;
    multiplierValues[2] = 100;
    multiplierValues[3] = 1000;
    multiplierValues[4] = 10000;
    multiplierValues[5] = 100000;
    multiplierValues[6] = 1000000;
    multiplierValues[7] = 10000000;
    multiplierValues[8] = 0.1;
    multiplierValues[9] = 0.01;

    toleranceValues[5] = 0.5;
    toleranceValues[6] = 0.25;
    toleranceValues[7] = 0.1;
    toleranceValues[8] = 0.05;
    toleranceValues[1] = 1.0;
    toleranceValues[2] = 2.0;
    toleranceValues[4] = 4.0;
    toleranceValues[10] = 5.0;
    toleranceValues[11] = 10.0;
    toleranceValues[12] = 20.0;

    tempCoeffValues[1] = 100;
    tempCoeffValues[2] = 50;
    tempCoeffValues[3] = 15;
    tempCoeffValues[4] = 25;
    tempCoeffValues[7] = 10;
    tempCoeffValues[8] = 5;

    colorNames[0] = "黑色";
    colorNames[1] = "棕色";
    colorNames[2] = "红色";
    colorNames[3] = "橙色";
    colorNames[4] = "黄色";
    colorNames[5] = "绿色";
    colorNames[6] = "蓝色";
    colorNames[7] = "紫色";
    colorNames[8] = "灰色";
    colorNames[9] = "白色";
    colorNames[10] = "金色";
    colorNames[11] = "银色";
    colorNames[12] = "无色";

    colorHexes[0] = "#000000";
    colorHexes[1] = "#8B4513";
    colorHexes[2] = "#FF0000";
    colorHexes[3] = "#FFA500";
    colorHexes[4] = "#FFFF00";
    colorHexes[5] = "#00FF00";
    colorHexes[6] = "#0000FF";
    colorHexes[7] = "#8B00FF";
    colorHexes[8] = "#808080";
    colorHexes[9] = "#FFFFFF";
    colorHexes[10] = "#FFD700";
    colorHexes[11] = "#C0C0C0";
    colorHexes[12] = "#F5F5DC";
}

int ResistorCalculator::bandCount() const
{
    return m_bandCount;
}

void ResistorCalculator::setBandCount(int count)
{
    if (m_bandCount != count) {
        m_bandCount = count;
        emit bandCountChanged();
        calculate();
    }
}

int ResistorCalculator::band1() const
{
    return m_band1;
}

void ResistorCalculator::setBand1(int value)
{
    if (m_band1 != value) {
        m_band1 = value;
        emit band1Changed();
        calculate();
    }
}

int ResistorCalculator::band2() const
{
    return m_band2;
}

void ResistorCalculator::setBand2(int value)
{
    if (m_band2 != value) {
        m_band2 = value;
        emit band2Changed();
        calculate();
    }
}

int ResistorCalculator::band3() const
{
    return m_band3;
}

void ResistorCalculator::setBand3(int value)
{
    if (m_band3 != value) {
        m_band3 = value;
        emit band3Changed();
        calculate();
    }
}

int ResistorCalculator::band4() const
{
    return m_band4;
}

void ResistorCalculator::setBand4(int value)
{
    if (m_band4 != value) {
        m_band4 = value;
        emit band4Changed();
        calculate();
    }
}

int ResistorCalculator::band5() const
{
    return m_band5;
}

void ResistorCalculator::setBand5(int value)
{
    if (m_band5 != value) {
        m_band5 = value;
        emit band5Changed();
        calculate();
    }
}

int ResistorCalculator::band6() const
{
    return m_band6;
}

void ResistorCalculator::setBand6(int value)
{
    if (m_band6 != value) {
        m_band6 = value;
        emit band6Changed();
        calculate();
    }
}

QString ResistorCalculator::result() const
{
    return m_result;
}

void ResistorCalculator::calculate()
{
    double resistance = 0;
    QString toleranceStr = "";
    QString tempCoeffStr = "";

    if (m_bandCount == 3) {
        int digit1 = digitValues.value(m_band1, 0);
        int digit2 = digitValues.value(m_band2, 0);
        double multiplier = multiplierValues.value(m_band3, 1);
        
        resistance = (digit1 * 10 + digit2) * multiplier;
        toleranceStr = "±20%";
    }
    else if (m_bandCount == 4) {
        int digit1 = digitValues.value(m_band1, 0);
        int digit2 = digitValues.value(m_band2, 0);
        double multiplier = multiplierValues.value(m_band3, 1);
        double tolerance = toleranceValues.value(m_band4, 20.0);
        
        resistance = (digit1 * 10 + digit2) * multiplier;
        toleranceStr = formatTolerance(tolerance);
    }
    else if (m_bandCount == 5) {
        int digit1 = digitValues.value(m_band1, 0);
        int digit2 = digitValues.value(m_band2, 0);
        int digit3 = digitValues.value(m_band3, 0);
        double multiplier = multiplierValues.value(m_band4, 1);
        double tolerance = toleranceValues.value(m_band5, 20.0);
        
        resistance = (digit1 * 100 + digit2 * 10 + digit3) * multiplier;
        toleranceStr = formatTolerance(tolerance);
    }
    else if (m_bandCount == 6) {
        int digit1 = digitValues.value(m_band1, 0);
        int digit2 = digitValues.value(m_band2, 0);
        int digit3 = digitValues.value(m_band3, 0);
        double multiplier = multiplierValues.value(m_band4, 1);
        double tolerance = toleranceValues.value(m_band5, 20.0);
        double tempCoeff = tempCoeffValues.value(m_band6, 0);
        
        resistance = (digit1 * 100 + digit2 * 10 + digit3) * multiplier;
        toleranceStr = formatTolerance(tolerance);
        tempCoeffStr = formatTempCoeff(tempCoeff);
    }

    QString resistanceStr = formatResistance(resistance);
    
    m_result = "阻值: " + resistanceStr;
    if (!toleranceStr.isEmpty()) {
        m_result += "\n误差: " + toleranceStr;
    }
    if (!tempCoeffStr.isEmpty()) {
        m_result += "\n温度系数: " + tempCoeffStr;
    }
    
    emit resultChanged();
}

QString ResistorCalculator::formatResistance(double resistance)
{
    if (resistance >= 1000000) {
        return QString::number(resistance / 1000000, 'f', 2) + " MΩ";
    } else if (resistance >= 1000) {
        return QString::number(resistance / 1000, 'f', 2) + " kΩ";
    } else {
        return QString::number(resistance, 'f', 2) + " Ω";
    }
}

QString ResistorCalculator::formatTolerance(double tolerance)
{
    return "±" + QString::number(tolerance, 'f', 2) + "%";
}

QString ResistorCalculator::formatTempCoeff(double tempCoeff)
{
    return QString::number(tempCoeff, 'f', 0) + " ppm/°C";
}

QString ResistorCalculator::getColorName(int colorIndex)
{
    return colorNames.value(colorIndex, "未知");
}

QString ResistorCalculator::getColorHex(int colorIndex)
{
    return colorHexes.value(colorIndex, "#CCCCCC");
}
