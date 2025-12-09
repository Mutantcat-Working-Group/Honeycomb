#ifndef RANDOMLETTERGENERATOR_H
#define RANDOMLETTERGENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>

class RandomLetterGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int length READ length WRITE setLength NOTIFY lengthChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(bool includeUpper READ includeUpper WRITE setIncludeUpper NOTIFY includeUpperChanged)
    Q_PROPERTY(bool includeLower READ includeLower WRITE setIncludeLower NOTIFY includeLowerChanged)

public:
    explicit RandomLetterGenerator(QObject *parent = nullptr);

    int length() const;
    void setLength(int length);

    QString result() const;

    bool includeUpper() const;
    void setIncludeUpper(bool include);

    bool includeLower() const;
    void setIncludeLower(bool include);

    Q_INVOKABLE void generate();

signals:
    void lengthChanged();
    void resultChanged();
    void includeUpperChanged();
    void includeLowerChanged();

private:
    int m_length;
    QString m_result;
    bool m_includeUpper;
    bool m_includeLower;
};

#endif // RANDOMLETTERGENERATOR_H
