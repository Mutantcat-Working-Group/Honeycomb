#ifndef RANDOMMIXEDGENERATOR_H
#define RANDOMMIXEDGENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>

class RandomMixedGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int length READ length WRITE setLength NOTIFY lengthChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(bool includeUpper READ includeUpper WRITE setIncludeUpper NOTIFY includeUpperChanged)
    Q_PROPERTY(bool includeLower READ includeLower WRITE setIncludeLower NOTIFY includeLowerChanged)
    Q_PROPERTY(bool includeDigits READ includeDigits WRITE setIncludeDigits NOTIFY includeDigitsChanged)

public:
    explicit RandomMixedGenerator(QObject *parent = nullptr);

    int length() const;
    void setLength(int length);

    QString result() const;

    bool includeUpper() const;
    void setIncludeUpper(bool include);

    bool includeLower() const;
    void setIncludeLower(bool include);

    bool includeDigits() const;
    void setIncludeDigits(bool include);

    Q_INVOKABLE void generate();

signals:
    void lengthChanged();
    void resultChanged();
    void includeUpperChanged();
    void includeLowerChanged();
    void includeDigitsChanged();

private:
    int m_length;
    QString m_result;
    bool m_includeUpper;
    bool m_includeLower;
    bool m_includeDigits;
};

#endif // RANDOMMIXEDGENERATOR_H
