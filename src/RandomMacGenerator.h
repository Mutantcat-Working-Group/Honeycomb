#ifndef RANDOMMACGENERATOR_H
#define RANDOMMACGENERATOR_H

#include <QObject>
#include <QString>
#include <QRandomGenerator>

class RandomMacGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QString format READ format WRITE setFormat NOTIFY formatChanged)
    Q_PROPERTY(QString caseType READ caseType WRITE setCaseType NOTIFY caseTypeChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit RandomMacGenerator(QObject *parent = nullptr);

    int count() const;
    void setCount(int count);

    QString format() const;
    void setFormat(const QString &format);

    QString caseType() const;
    void setCaseType(const QString &caseType);

    QString result() const;

    Q_INVOKABLE void generate();

signals:
    void countChanged();
    void formatChanged();
    void caseTypeChanged();
    void resultChanged();

private:
    int m_count;
    QString m_format;
    QString m_caseType;
    QString m_result;
    
    QString generateSingleMac();
    QString formatMacAddress(const QString &mac, const QString &format, const QString &caseType);
};

#endif // RANDOMMACGENERATOR_H