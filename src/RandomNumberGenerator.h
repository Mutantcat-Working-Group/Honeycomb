#ifndef RANDOMNUMBERGENERATOR_H
#define RANDOMNUMBERGENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>

class RandomNumberGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int length READ length WRITE setLength NOTIFY lengthChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit RandomNumberGenerator(QObject *parent = nullptr);

    int length() const;
    void setLength(int length);

    QString result() const;

    Q_INVOKABLE void generate();

signals:
    void lengthChanged();
    void resultChanged();

private:
    int m_length;
    QString m_result;
};

#endif // RANDOMNUMBERGENERATOR_H
