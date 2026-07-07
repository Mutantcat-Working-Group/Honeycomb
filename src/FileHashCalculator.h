#ifndef FILEHASHCALCULATOR_H
#define FILEHASHCALCULATOR_H

#include <QObject>
#include <QString>

class FileHashCalculator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QString algorithm READ algorithm WRITE setAlgorithm NOTIFY algorithmChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool uppercase READ uppercase WRITE setUppercase NOTIFY uppercaseChanged)

public:
    explicit FileHashCalculator(QObject *parent = nullptr);

    QString filePath() const;
    void setFilePath(const QString &filePath);

    QString algorithm() const;
    void setAlgorithm(const QString &algorithm);

    QString result() const;
    QString errorMessage() const;

    bool uppercase() const;
    void setUppercase(bool uppercase);

    Q_INVOKABLE void calculate();
    Q_INVOKABLE void clear();

signals:
    void filePathChanged();
    void algorithmChanged();
    void resultChanged();
    void errorMessageChanged();
    void uppercaseChanged();

private:
    int hashAlgorithm() const;
    void setResult(const QString &result);
    void setErrorMessage(const QString &message);

    QString m_filePath;
    QString m_algorithm;
    QString m_result;
    QString m_errorMessage;
    bool m_uppercase;
};

#endif // FILEHASHCALCULATOR_H
