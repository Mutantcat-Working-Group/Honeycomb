#ifndef AESCRYPTO_H
#define AESCRYPTO_H

#include <QObject>
#include <QString>
#include <QByteArray>

class AESCrypto : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString inputText READ inputText WRITE setInputText NOTIFY inputTextChanged)
    Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged)
    Q_PROPERTY(QString iv READ iv WRITE setIv NOTIFY ivChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString keySize READ keySize WRITE setKeySize NOTIFY keySizeChanged)
    Q_PROPERTY(QString mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool uppercase READ uppercase WRITE setUppercase NOTIFY uppercaseChanged)

public:
    explicit AESCrypto(QObject *parent = nullptr);

    QString inputText() const;
    void setInputText(const QString &text);

    QString key() const;
    void setKey(const QString &key);

    QString iv() const;
    void setIv(const QString &iv);

    QString result() const;

    QString keySize() const;
    void setKeySize(const QString &size);

    QString mode() const;
    void setMode(const QString &mode);

    bool uppercase() const;
    void setUppercase(bool upper);

    // AES 加解密
    Q_INVOKABLE void encrypt();
    Q_INVOKABLE void decrypt();

    // 生成随机密钥
    Q_INVOKABLE QString generateKey();
    Q_INVOKABLE QString generateIV();

    // 清空
    Q_INVOKABLE void clear();

signals:
    void inputTextChanged();
    void keyChanged();
    void ivChanged();
    void resultChanged();
    void keySizeChanged();
    void modeChanged();
    void uppercaseChanged();
    void errorOccurred(const QString &error);

private:
    // AES 核心函数
    void keyExpansion(const QByteArray &key);
    void encryptBlock(quint8 *block);
    void decryptBlock(quint8 *block);

    // AES 变换
    void subBytes(quint8 *state);
    void invSubBytes(quint8 *state);
    void shiftRows(quint8 *state);
    void invShiftRows(quint8 *state);
    void mixColumns(quint8 *state);
    void invMixColumns(quint8 *state);
    void addRoundKey(quint8 *state, const quint8 *roundKey);

    quint8 xtime(quint8 x);
    quint8 multiply(quint8 x, quint8 y);

    // PKCS7 填充
    QByteArray pkcs7Pad(const QByteArray &data, int blockSize);
    QByteArray pkcs7Unpad(const QByteArray &data);

    // ECB 模式
    QByteArray encryptECB(const QByteArray &plaintext, const QByteArray &key);
    QByteArray decryptECB(const QByteArray &ciphertext, const QByteArray &key);

    // CBC 模式
    QByteArray encryptCBC(const QByteArray &plaintext, const QByteArray &key, const QByteArray &iv);
    QByteArray decryptCBC(const QByteArray &ciphertext, const QByteArray &key, const QByteArray &iv);

    QString m_inputText;
    QString m_key;
    QString m_iv;
    QString m_result;
    QString m_keySize;  // "128", "192", "256"
    QString m_mode;     // "ECB", "CBC"
    bool m_uppercase;

    // AES 轮密钥 (字节形式，最多 14 轮 + 1，每轮 16 字节)
    quint8 m_roundKeys[240];
    int m_nr;                 // 轮数
    int m_nk;                 // 密钥字数

    // AES S盒和逆S盒
    static const quint8 SBOX[256];
    static const quint8 INV_SBOX[256];
    static const quint8 RCON[11];
};

#endif // AESCRYPTO_H
