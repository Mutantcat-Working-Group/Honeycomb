#ifndef SMCRYPTO_H
#define SMCRYPTO_H

#include <QObject>
#include <QString>
#include <QByteArray>

class SMCrypto : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString inputText READ inputText WRITE setInputText NOTIFY inputTextChanged)
    Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged)
    Q_PROPERTY(QString iv READ iv WRITE setIv NOTIFY ivChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString algorithm READ algorithm WRITE setAlgorithm NOTIFY algorithmChanged)
    Q_PROPERTY(QString mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool uppercase READ uppercase WRITE setUppercase NOTIFY uppercaseChanged)

public:
    explicit SMCrypto(QObject *parent = nullptr);

    QString inputText() const;
    void setInputText(const QString &text);

    QString key() const;
    void setKey(const QString &key);

    QString iv() const;
    void setIv(const QString &iv);

    QString result() const;

    QString algorithm() const;
    void setAlgorithm(const QString &algo);

    QString mode() const;
    void setMode(const QString &mode);

    bool uppercase() const;
    void setUppercase(bool upper);

    // SM3 哈希
    Q_INVOKABLE void sm3Hash();
    
    // SM4 加解密
    Q_INVOKABLE void sm4Encrypt();
    Q_INVOKABLE void sm4Decrypt();
    
    // 生成随机密钥
    Q_INVOKABLE QString generateKey(int length = 16);
    Q_INVOKABLE QString generateIV();
    
    // 清空
    Q_INVOKABLE void clear();

signals:
    void inputTextChanged();
    void keyChanged();
    void ivChanged();
    void resultChanged();
    void algorithmChanged();
    void modeChanged();
    void uppercaseChanged();
    void errorOccurred(const QString &error);

private:
    // SM3 内部函数
    QByteArray sm3(const QByteArray &message);
    quint32 sm3_ff(quint32 x, quint32 y, quint32 z, int j);
    quint32 sm3_gg(quint32 x, quint32 y, quint32 z, int j);
    quint32 sm3_p0(quint32 x);
    quint32 sm3_p1(quint32 x);
    quint32 rotateLeft(quint32 x, int n);
    
    // SM4 内部函数
    QByteArray sm4_encrypt_ecb(const QByteArray &plaintext, const QByteArray &key);
    QByteArray sm4_decrypt_ecb(const QByteArray &ciphertext, const QByteArray &key);
    QByteArray sm4_encrypt_cbc(const QByteArray &plaintext, const QByteArray &key, const QByteArray &iv);
    QByteArray sm4_decrypt_cbc(const QByteArray &ciphertext, const QByteArray &key, const QByteArray &iv);
    void sm4_setkey(const QByteArray &key, quint32 *rk);
    void sm4_one_round(quint32 *rk, const quint8 *input, quint8 *output);
    quint32 sm4_lt(quint32 ka);
    quint32 sm4_f(quint32 x0, quint32 x1, quint32 x2, quint32 x3, quint32 rk);
    
    // PKCS7 填充
    QByteArray pkcs7Pad(const QByteArray &data, int blockSize);
    QByteArray pkcs7Unpad(const QByteArray &data);

    QString m_inputText;
    QString m_key;
    QString m_iv;
    QString m_result;
    QString m_algorithm;  // "SM3", "SM4"
    QString m_mode;       // "ECB", "CBC"
    bool m_uppercase;
    
    // SM4 S盒
    static const quint8 SM4_SBOX[256];
    // SM4 系统参数FK
    static const quint32 SM4_FK[4];
    // SM4 固定参数CK
    static const quint32 SM4_CK[32];
};

#endif // SMCRYPTO_H
