#ifndef PASSWORDSTRENGTHGENERATOR_H
#define PASSWORDSTRENGTHGENERATOR_H

#include <QObject>
#include <QString>
#include <QRegularExpression>

class PasswordStrengthGenerator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(int score READ score NOTIFY scoreChanged)
    Q_PROPERTY(QString strengthLevel READ strengthLevel NOTIFY strengthLevelChanged)
    Q_PROPERTY(bool hasLowercase READ hasLowercase NOTIFY hasLowercaseChanged)
    Q_PROPERTY(bool hasUppercase READ hasUppercase NOTIFY hasUppercaseChanged)
    Q_PROPERTY(bool hasDigits READ hasDigits NOTIFY hasDigitsChanged)
    Q_PROPERTY(bool hasSpecialChars READ hasSpecialChars NOTIFY hasSpecialCharsChanged)
    Q_PROPERTY(int length READ length NOTIFY lengthChanged)

public:
    explicit PasswordStrengthGenerator(QObject *parent = nullptr);

    QString password() const;
    void setPassword(const QString &password);

    int score() const;
    QString strengthLevel() const;
    
    bool hasLowercase() const;
    bool hasUppercase() const;
    bool hasDigits() const;
    bool hasSpecialChars() const;
    int length() const;

    Q_INVOKABLE void analyze();

signals:
    void passwordChanged();
    void scoreChanged();
    void strengthLevelChanged();
    void hasLowercaseChanged();
    void hasUppercaseChanged();
    void hasDigitsChanged();
    void hasSpecialCharsChanged();
    void lengthChanged();

private:
    QString m_password;
    int m_score;
    QString m_strengthLevel;
    bool m_hasLowercase;
    bool m_hasUppercase;
    bool m_hasDigits;
    bool m_hasSpecialChars;
    int m_length;
    
    void updateStrengthLevel();
};

#endif // PASSWORDSTRENGTHGENERATOR_H