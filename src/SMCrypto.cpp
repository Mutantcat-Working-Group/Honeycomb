#include "SMCrypto.h"
#include <QRandomGenerator>
#include <QtEndian>

// SM4 S盒
const quint8 SMCrypto::SM4_SBOX[256] = {
    0xd6, 0x90, 0xe9, 0xfe, 0xcc, 0xe1, 0x3d, 0xb7, 0x16, 0xb6, 0x14, 0xc2, 0x28, 0xfb, 0x2c, 0x05,
    0x2b, 0x67, 0x9a, 0x76, 0x2a, 0xbe, 0x04, 0xc3, 0xaa, 0x44, 0x13, 0x26, 0x49, 0x86, 0x06, 0x99,
    0x9c, 0x42, 0x50, 0xf4, 0x91, 0xef, 0x98, 0x7a, 0x33, 0x54, 0x0b, 0x43, 0xed, 0xcf, 0xac, 0x62,
    0xe4, 0xb3, 0x1c, 0xa9, 0xc9, 0x08, 0xe8, 0x95, 0x80, 0xdf, 0x94, 0xfa, 0x75, 0x8f, 0x3f, 0xa6,
    0x47, 0x07, 0xa7, 0xfc, 0xf3, 0x73, 0x17, 0xba, 0x83, 0x59, 0x3c, 0x19, 0xe6, 0x85, 0x4f, 0xa8,
    0x68, 0x6b, 0x81, 0xb2, 0x71, 0x64, 0xda, 0x8b, 0xf8, 0xeb, 0x0f, 0x4b, 0x70, 0x56, 0x9d, 0x35,
    0x1e, 0x24, 0x0e, 0x5e, 0x63, 0x58, 0xd1, 0xa2, 0x25, 0x22, 0x7c, 0x3b, 0x01, 0x21, 0x78, 0x87,
    0xd4, 0x00, 0x46, 0x57, 0x9f, 0xd3, 0x27, 0x52, 0x4c, 0x36, 0x02, 0xe7, 0xa0, 0xc4, 0xc8, 0x9e,
    0xea, 0xbf, 0x8a, 0xd2, 0x40, 0xc7, 0x38, 0xb5, 0xa3, 0xf7, 0xf2, 0xce, 0xf9, 0x61, 0x15, 0xa1,
    0xe0, 0xae, 0x5d, 0xa4, 0x9b, 0x34, 0x1a, 0x55, 0xad, 0x93, 0x32, 0x30, 0xf5, 0x8c, 0xb1, 0xe3,
    0x1d, 0xf6, 0xe2, 0x2e, 0x82, 0x66, 0xca, 0x60, 0xc0, 0x29, 0x23, 0xab, 0x0d, 0x53, 0x4e, 0x6f,
    0xd5, 0xdb, 0x37, 0x45, 0xde, 0xfd, 0x8e, 0x2f, 0x03, 0xff, 0x6a, 0x72, 0x6d, 0x6c, 0x5b, 0x51,
    0x8d, 0x1b, 0xaf, 0x92, 0xbb, 0xdd, 0xbc, 0x7f, 0x11, 0xd9, 0x5c, 0x41, 0x1f, 0x10, 0x5a, 0xd8,
    0x0a, 0xc1, 0x31, 0x88, 0xa5, 0xcd, 0x7b, 0xbd, 0x2d, 0x74, 0xd0, 0x12, 0xb8, 0xe5, 0xb4, 0xb0,
    0x89, 0x69, 0x97, 0x4a, 0x0c, 0x96, 0x77, 0x7e, 0x65, 0xb9, 0xf1, 0x09, 0xc5, 0x6e, 0xc6, 0x84,
    0x18, 0xf0, 0x7d, 0xec, 0x3a, 0xdc, 0x4d, 0x20, 0x79, 0xee, 0x5f, 0x3e, 0xd7, 0xcb, 0x39, 0x48
};

// SM4 系统参数FK
const quint32 SMCrypto::SM4_FK[4] = {
    0xa3b1bac6, 0x56aa3350, 0x677d9197, 0xb27022dc
};

// SM4 固定参数CK
const quint32 SMCrypto::SM4_CK[32] = {
    0x00070e15, 0x1c232a31, 0x383f464d, 0x545b6269,
    0x70777e85, 0x8c939aa1, 0xa8afb6bd, 0xc4cbd2d9,
    0xe0e7eef5, 0xfc030a11, 0x181f262d, 0x343b4249,
    0x50575e65, 0x6c737a81, 0x888f969d, 0xa4abb2b9,
    0xc0c7ced5, 0xdce3eaf1, 0xf8fff6fd, 0x060d141b,
    0x22292f36, 0x3d444b52, 0x595f666d, 0x747b8289,
    0x90979ea5, 0xacb3bac1, 0xc8cfd6dd, 0xe4ebf2f9,
    0x00070e15, 0x1c232a31, 0x383f464d, 0x545b6269
};

SMCrypto::SMCrypto(QObject *parent)
    : QObject(parent)
    , m_algorithm("SM3")
    , m_mode("ECB")
    , m_uppercase(false)
{
}

QString SMCrypto::inputText() const { return m_inputText; }
void SMCrypto::setInputText(const QString &text) {
    if (m_inputText != text) {
        m_inputText = text;
        emit inputTextChanged();
    }
}

QString SMCrypto::key() const { return m_key; }
void SMCrypto::setKey(const QString &key) {
    if (m_key != key) {
        m_key = key;
        emit keyChanged();
    }
}

QString SMCrypto::iv() const { return m_iv; }
void SMCrypto::setIv(const QString &iv) {
    if (m_iv != iv) {
        m_iv = iv;
        emit ivChanged();
    }
}

QString SMCrypto::result() const { return m_result; }

QString SMCrypto::algorithm() const { return m_algorithm; }
void SMCrypto::setAlgorithm(const QString &algo) {
    if (m_algorithm != algo) {
        m_algorithm = algo;
        emit algorithmChanged();
    }
}

QString SMCrypto::mode() const { return m_mode; }
void SMCrypto::setMode(const QString &mode) {
    if (m_mode != mode) {
        m_mode = mode;
        emit modeChanged();
    }
}

bool SMCrypto::uppercase() const { return m_uppercase; }
void SMCrypto::setUppercase(bool upper) {
    if (m_uppercase != upper) {
        m_uppercase = upper;
        emit uppercaseChanged();
    }
}

void SMCrypto::clear()
{
    m_inputText.clear();
    m_key.clear();
    m_iv.clear();
    m_result.clear();
    emit inputTextChanged();
    emit keyChanged();
    emit ivChanged();
    emit resultChanged();
}

QString SMCrypto::generateKey(int length)
{
    QByteArray key;
    for (int i = 0; i < length; ++i) {
        key.append(static_cast<char>(QRandomGenerator::global()->bounded(256)));
    }
    return key.toHex();
}

QString SMCrypto::generateIV()
{
    return generateKey(16);
}

// ==================== SM3 实现 ====================

quint32 SMCrypto::rotateLeft(quint32 x, int n)
{
    return (x << n) | (x >> (32 - n));
}

quint32 SMCrypto::sm3_ff(quint32 x, quint32 y, quint32 z, int j)
{
    if (j < 16) {
        return x ^ y ^ z;
    } else {
        return (x & y) | (x & z) | (y & z);
    }
}

quint32 SMCrypto::sm3_gg(quint32 x, quint32 y, quint32 z, int j)
{
    if (j < 16) {
        return x ^ y ^ z;
    } else {
        return (x & y) | (~x & z);
    }
}

quint32 SMCrypto::sm3_p0(quint32 x)
{
    return x ^ rotateLeft(x, 9) ^ rotateLeft(x, 17);
}

quint32 SMCrypto::sm3_p1(quint32 x)
{
    return x ^ rotateLeft(x, 15) ^ rotateLeft(x, 23);
}

QByteArray SMCrypto::sm3(const QByteArray &message)
{
    // 初始值
    quint32 V[8] = {
        0x7380166f, 0x4914b2b9, 0x172442d7, 0xda8a0600,
        0xa96f30bc, 0x163138aa, 0xe38dee4d, 0xb0fb0e4e
    };
    
    // 消息填充
    QByteArray padded = message;
    quint64 bitLen = message.size() * 8;
    
    padded.append(static_cast<char>(0x80));
    while ((padded.size() % 64) != 56) {
        padded.append(static_cast<char>(0x00));
    }
    
    // 添加长度（大端）
    for (int i = 7; i >= 0; --i) {
        padded.append(static_cast<char>((bitLen >> (i * 8)) & 0xff));
    }
    
    // 分组处理
    for (int i = 0; i < padded.size(); i += 64) {
        quint32 W[68], W1[64];
        
        // 消息扩展
        for (int j = 0; j < 16; ++j) {
            W[j] = qFromBigEndian<quint32>(reinterpret_cast<const uchar*>(padded.constData() + i + j * 4));
        }
        
        for (int j = 16; j < 68; ++j) {
            W[j] = sm3_p1(W[j-16] ^ W[j-9] ^ rotateLeft(W[j-3], 15)) ^ rotateLeft(W[j-13], 7) ^ W[j-6];
        }
        
        for (int j = 0; j < 64; ++j) {
            W1[j] = W[j] ^ W[j+4];
        }
        
        // 压缩函数
        quint32 A = V[0], B = V[1], C = V[2], D = V[3];
        quint32 E = V[4], F = V[5], G = V[6], H = V[7];
        
        for (int j = 0; j < 64; ++j) {
            quint32 T = (j < 16) ? 0x79cc4519 : 0x7a879d8a;
            quint32 SS1 = rotateLeft(rotateLeft(A, 12) + E + rotateLeft(T, j % 32), 7);
            quint32 SS2 = SS1 ^ rotateLeft(A, 12);
            quint32 TT1 = sm3_ff(A, B, C, j) + D + SS2 + W1[j];
            quint32 TT2 = sm3_gg(E, F, G, j) + H + SS1 + W[j];
            D = C;
            C = rotateLeft(B, 9);
            B = A;
            A = TT1;
            H = G;
            G = rotateLeft(F, 19);
            F = E;
            E = sm3_p0(TT2);
        }
        
        V[0] ^= A; V[1] ^= B; V[2] ^= C; V[3] ^= D;
        V[4] ^= E; V[5] ^= F; V[6] ^= G; V[7] ^= H;
    }
    
    // 输出
    QByteArray result;
    for (int i = 0; i < 8; ++i) {
        quint32 be = qToBigEndian(V[i]);
        result.append(reinterpret_cast<const char*>(&be), 4);
    }
    
    return result;
}

void SMCrypto::sm3Hash()
{
    if (m_inputText.isEmpty()) {
        m_result.clear();
        emit resultChanged();
        return;
    }
    
    QByteArray hash = sm3(m_inputText.toUtf8());
    m_result = hash.toHex();
    
    if (m_uppercase) {
        m_result = m_result.toUpper();
    }
    
    emit resultChanged();
}

// ==================== SM4 实现 ====================

quint32 SMCrypto::sm4_lt(quint32 ka)
{
    quint8 a[4], b[4];
    a[0] = (ka >> 24) & 0xff;
    a[1] = (ka >> 16) & 0xff;
    a[2] = (ka >> 8) & 0xff;
    a[3] = ka & 0xff;
    
    b[0] = SM4_SBOX[a[0]];
    b[1] = SM4_SBOX[a[1]];
    b[2] = SM4_SBOX[a[2]];
    b[3] = SM4_SBOX[a[3]];
    
    quint32 bb = (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3];
    return bb ^ rotateLeft(bb, 2) ^ rotateLeft(bb, 10) ^ rotateLeft(bb, 18) ^ rotateLeft(bb, 24);
}

quint32 SMCrypto::sm4_f(quint32 x0, quint32 x1, quint32 x2, quint32 x3, quint32 rk)
{
    return x0 ^ sm4_lt(x1 ^ x2 ^ x3 ^ rk);
}

void SMCrypto::sm4_setkey(const QByteArray &key, quint32 *rk)
{
    quint32 MK[4], K[36];
    
    for (int i = 0; i < 4; ++i) {
        MK[i] = qFromBigEndian<quint32>(reinterpret_cast<const uchar*>(key.constData() + i * 4));
    }
    
    K[0] = MK[0] ^ SM4_FK[0];
    K[1] = MK[1] ^ SM4_FK[1];
    K[2] = MK[2] ^ SM4_FK[2];
    K[3] = MK[3] ^ SM4_FK[3];
    
    for (int i = 0; i < 32; ++i) {
        quint32 tmp = K[i+1] ^ K[i+2] ^ K[i+3] ^ SM4_CK[i];
        quint8 a[4], b[4];
        a[0] = (tmp >> 24) & 0xff;
        a[1] = (tmp >> 16) & 0xff;
        a[2] = (tmp >> 8) & 0xff;
        a[3] = tmp & 0xff;
        b[0] = SM4_SBOX[a[0]];
        b[1] = SM4_SBOX[a[1]];
        b[2] = SM4_SBOX[a[2]];
        b[3] = SM4_SBOX[a[3]];
        quint32 bb = (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3];
        rk[i] = K[i] ^ (bb ^ rotateLeft(bb, 13) ^ rotateLeft(bb, 23));
        K[i+4] = rk[i];
    }
}

void SMCrypto::sm4_one_round(quint32 *rk, const quint8 *input, quint8 *output)
{
    quint32 X[36];
    
    X[0] = qFromBigEndian<quint32>(input);
    X[1] = qFromBigEndian<quint32>(input + 4);
    X[2] = qFromBigEndian<quint32>(input + 8);
    X[3] = qFromBigEndian<quint32>(input + 12);
    
    for (int i = 0; i < 32; ++i) {
        X[i+4] = sm4_f(X[i], X[i+1], X[i+2], X[i+3], rk[i]);
    }
    
    quint32 Y[4] = {X[35], X[34], X[33], X[32]};
    for (int i = 0; i < 4; ++i) {
        qToBigEndian(Y[i], output + i * 4);
    }
}

QByteArray SMCrypto::pkcs7Pad(const QByteArray &data, int blockSize)
{
    int padLen = blockSize - (data.size() % blockSize);
    QByteArray padded = data;
    for (int i = 0; i < padLen; ++i) {
        padded.append(static_cast<char>(padLen));
    }
    return padded;
}

QByteArray SMCrypto::pkcs7Unpad(const QByteArray &data)
{
    if (data.isEmpty()) return data;
    int padLen = static_cast<quint8>(data.at(data.size() - 1));
    if (padLen > 16 || padLen > data.size()) return data;
    return data.left(data.size() - padLen);
}

QByteArray SMCrypto::sm4_encrypt_ecb(const QByteArray &plaintext, const QByteArray &key)
{
    quint32 rk[32];
    sm4_setkey(key, rk);
    
    QByteArray padded = pkcs7Pad(plaintext, 16);
    QByteArray result;
    
    for (int i = 0; i < padded.size(); i += 16) {
        quint8 output[16];
        sm4_one_round(rk, reinterpret_cast<const quint8*>(padded.constData() + i), output);
        result.append(reinterpret_cast<const char*>(output), 16);
    }
    
    return result;
}

QByteArray SMCrypto::sm4_decrypt_ecb(const QByteArray &ciphertext, const QByteArray &key)
{
    quint32 rk[32], rk_dec[32];
    sm4_setkey(key, rk);
    
    // 解密时密钥逆序
    for (int i = 0; i < 32; ++i) {
        rk_dec[i] = rk[31 - i];
    }
    
    QByteArray result;
    for (int i = 0; i < ciphertext.size(); i += 16) {
        quint8 output[16];
        sm4_one_round(rk_dec, reinterpret_cast<const quint8*>(ciphertext.constData() + i), output);
        result.append(reinterpret_cast<const char*>(output), 16);
    }
    
    return pkcs7Unpad(result);
}

QByteArray SMCrypto::sm4_encrypt_cbc(const QByteArray &plaintext, const QByteArray &key, const QByteArray &iv)
{
    quint32 rk[32];
    sm4_setkey(key, rk);
    
    QByteArray padded = pkcs7Pad(plaintext, 16);
    QByteArray result;
    QByteArray prevBlock = iv;
    
    for (int i = 0; i < padded.size(); i += 16) {
        QByteArray block = padded.mid(i, 16);
        // XOR with previous block
        for (int j = 0; j < 16; ++j) {
            block[j] = block[j] ^ prevBlock[j];
        }
        
        quint8 output[16];
        sm4_one_round(rk, reinterpret_cast<const quint8*>(block.constData()), output);
        prevBlock = QByteArray(reinterpret_cast<const char*>(output), 16);
        result.append(prevBlock);
    }
    
    return result;
}

QByteArray SMCrypto::sm4_decrypt_cbc(const QByteArray &ciphertext, const QByteArray &key, const QByteArray &iv)
{
    quint32 rk[32], rk_dec[32];
    sm4_setkey(key, rk);
    
    for (int i = 0; i < 32; ++i) {
        rk_dec[i] = rk[31 - i];
    }
    
    QByteArray result;
    QByteArray prevBlock = iv;
    
    for (int i = 0; i < ciphertext.size(); i += 16) {
        QByteArray block = ciphertext.mid(i, 16);
        quint8 output[16];
        sm4_one_round(rk_dec, reinterpret_cast<const quint8*>(block.constData()), output);
        
        QByteArray decrypted(reinterpret_cast<const char*>(output), 16);
        for (int j = 0; j < 16; ++j) {
            decrypted[j] = decrypted[j] ^ prevBlock[j];
        }
        
        result.append(decrypted);
        prevBlock = block;
    }
    
    return pkcs7Unpad(result);
}

void SMCrypto::sm4Encrypt()
{
    if (m_inputText.isEmpty()) {
        emit errorOccurred("请输入要加密的内容");
        return;
    }
    
    QByteArray keyBytes = QByteArray::fromHex(m_key.toLatin1());
    if (keyBytes.size() != 16) {
        emit errorOccurred("密钥长度必须为32个十六进制字符（16字节）");
        return;
    }
    
    QByteArray result;
    
    if (m_mode == "CBC") {
        QByteArray ivBytes = QByteArray::fromHex(m_iv.toLatin1());
        if (ivBytes.size() != 16) {
            emit errorOccurred("IV长度必须为32个十六进制字符（16字节）");
            return;
        }
        result = sm4_encrypt_cbc(m_inputText.toUtf8(), keyBytes, ivBytes);
    } else {
        result = sm4_encrypt_ecb(m_inputText.toUtf8(), keyBytes);
    }
    
    m_result = result.toHex();
    if (m_uppercase) {
        m_result = m_result.toUpper();
    }
    emit resultChanged();
}

void SMCrypto::sm4Decrypt()
{
    if (m_inputText.isEmpty()) {
        emit errorOccurred("请输入要解密的内容");
        return;
    }
    
    QByteArray keyBytes = QByteArray::fromHex(m_key.toLatin1());
    if (keyBytes.size() != 16) {
        emit errorOccurred("密钥长度必须为32个十六进制字符（16字节）");
        return;
    }
    
    QByteArray cipherBytes = QByteArray::fromHex(m_inputText.toLatin1());
    if (cipherBytes.size() % 16 != 0) {
        emit errorOccurred("密文长度必须是32的倍数（16字节块）");
        return;
    }
    
    QByteArray result;
    
    if (m_mode == "CBC") {
        QByteArray ivBytes = QByteArray::fromHex(m_iv.toLatin1());
        if (ivBytes.size() != 16) {
            emit errorOccurred("IV长度必须为32个十六进制字符（16字节）");
            return;
        }
        result = sm4_decrypt_cbc(cipherBytes, keyBytes, ivBytes);
    } else {
        result = sm4_decrypt_ecb(cipherBytes, keyBytes);
    }
    
    m_result = QString::fromUtf8(result);
    emit resultChanged();
}
