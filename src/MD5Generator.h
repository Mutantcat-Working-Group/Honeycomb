#ifndef MD5GENERATOR_H
#define MD5GENERATOR_H

#include <QObject>
#include <QString>
#include <QCryptographicHash>

class MD5Generator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString inputText READ inputText WRITE setInputText NOTIFY inputTextChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(bool uppercase READ uppercase WRITE setUppercase NOTIFY uppercaseChanged)

public:
    explicit MD5Generator(QObject *parent = nullptr);

    QString inputText() const;
    void setInputText(const QString &inputText);

    QString result() const;

    bool uppercase() const;
    void setUppercase(bool uppercase);

    Q_INVOKABLE void generate();

signals:
    void inputTextChanged();
    void resultChanged();
    void uppercaseChanged();

private:
    QString m_inputText;
    QString m_result;
    bool m_uppercase;
};

#endif // MD5GENERATOR_H