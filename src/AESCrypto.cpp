#include "AESCrypto.h"
#include <QRandomGenerator>

// AES S盒
const quint8 AESCrypto::SBOX[256] = {
    0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
    0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
    0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
    0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
    0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
    0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
    0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
    0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
    0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
    0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
    0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
    0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
    0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
    0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
    0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
    0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
};

// AES 逆S盒
const quint8 AESCrypto::INV_SBOX[256] = {
    0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
    0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
    0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
    0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
    0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
    0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
    0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
    0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
    0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
    0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
    0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
    0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
    0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
    0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
    0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
};

// AES Rcon
const quint8 AESCrypto::RCON[11] = {
    0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
};

AESCrypto::AESCrypto(QObject *parent)
    : QObject(parent)
    , m_keySize("128")
    , m_mode("ECB")
    , m_uppercase(false)
    , m_nr(10)
    , m_nk(4)
{
}

QString AESCrypto::inputText() const { return m_inputText; }
void AESCrypto::setInputText(const QString &text) {
    if (m_inputText != text) {
        m_inputText = text;
        emit inputTextChanged();
    }
}

QString AESCrypto::key() const { return m_key; }
void AESCrypto::setKey(const QString &key) {
    if (m_key != key) {
        m_key = key;
        emit keyChanged();
    }
}

QString AESCrypto::iv() const { return m_iv; }
void AESCrypto::setIv(const QString &iv) {
    if (m_iv != iv) {
        m_iv = iv;
        emit ivChanged();
    }
}

QString AESCrypto::result() const { return m_result; }

QString AESCrypto::keySize() const { return m_keySize; }
void AESCrypto::setKeySize(const QString &size) {
    if (m_keySize != size) {
        m_keySize = size;
        // 更新轮数和密钥字数
        if (size == "128") { m_nr = 10; m_nk = 4; }
        else if (size == "192") { m_nr = 12; m_nk = 6; }
        else if (size == "256") { m_nr = 14; m_nk = 8; }
        emit keySizeChanged();
    }
}

QString AESCrypto::mode() const { return m_mode; }
void AESCrypto::setMode(const QString &mode) {
    if (m_mode != mode) {
        m_mode = mode;
        emit modeChanged();
    }
}

bool AESCrypto::uppercase() const { return m_uppercase; }
void AESCrypto::setUppercase(bool upper) {
    if (m_uppercase != upper) {
        m_uppercase = upper;
        emit uppercaseChanged();
    }
}

void AESCrypto::clear()
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

QString AESCrypto::generateKey()
{
    int keyLen = 16;  // 默认 AES-128
    if (m_keySize == "192") keyLen = 24;
    else if (m_keySize == "256") keyLen = 32;

    QByteArray key;
    for (int i = 0; i < keyLen; ++i) {
        key.append(static_cast<char>(QRandomGenerator::global()->bounded(256)));
    }
    return key.toHex();
}

QString AESCrypto::generateIV()
{
    QByteArray iv;
    for (int i = 0; i < 16; ++i) {
        iv.append(static_cast<char>(QRandomGenerator::global()->bounded(256)));
    }
    return iv.toHex();
}

// ==================== AES 核心实现 ====================

quint8 AESCrypto::xtime(quint8 x)
{
    return ((x << 1) ^ (((x >> 7) & 1) * 0x1b));
}

quint8 AESCrypto::multiply(quint8 x, quint8 y)
{
    return (((y & 1) * x) ^
            ((y >> 1 & 1) * xtime(x)) ^
            ((y >> 2 & 1) * xtime(xtime(x))) ^
            ((y >> 3 & 1) * xtime(xtime(xtime(x)))) ^
            ((y >> 4 & 1) * xtime(xtime(xtime(xtime(x))))));
}

void AESCrypto::subBytes(quint8 *state)
{
    for (int i = 0; i < 16; ++i) {
        state[i] = SBOX[state[i]];
    }
}

void AESCrypto::invSubBytes(quint8 *state)
{
    for (int i = 0; i < 16; ++i) {
        state[i] = INV_SBOX[state[i]];
    }
}

void AESCrypto::shiftRows(quint8 *state)
{
    quint8 temp;

    // Row 1: shift left by 1
    temp = state[1];
    state[1] = state[5];
    state[5] = state[9];
    state[9] = state[13];
    state[13] = temp;

    // Row 2: shift left by 2
    temp = state[2];
    state[2] = state[10];
    state[10] = temp;
    temp = state[6];
    state[6] = state[14];
    state[14] = temp;

    // Row 3: shift left by 3
    temp = state[15];
    state[15] = state[11];
    state[11] = state[7];
    state[7] = state[3];
    state[3] = temp;
}

void AESCrypto::invShiftRows(quint8 *state)
{
    quint8 temp;

    // Row 1: shift right by 1
    temp = state[13];
    state[13] = state[9];
    state[9] = state[5];
    state[5] = state[1];
    state[1] = temp;

    // Row 2: shift right by 2
    temp = state[2];
    state[2] = state[10];
    state[10] = temp;
    temp = state[6];
    state[6] = state[14];
    state[14] = temp;

    // Row 3: shift right by 3
    temp = state[3];
    state[3] = state[7];
    state[7] = state[11];
    state[11] = state[15];
    state[15] = temp;
}

void AESCrypto::mixColumns(quint8 *state)
{
    quint8 temp[4];

    for (int c = 0; c < 4; ++c) {
        int col = c * 4;
        temp[0] = state[col];
        temp[1] = state[col + 1];
        temp[2] = state[col + 2];
        temp[3] = state[col + 3];

        // MixColumns 系数: 2, 3, 1, 1
        state[col]     = xtime(temp[0]) ^ multiply(temp[1], 0x03) ^ temp[2] ^ temp[3];
        state[col + 1] = temp[0] ^ xtime(temp[1]) ^ multiply(temp[2], 0x03) ^ temp[3];
        state[col + 2] = temp[0] ^ temp[1] ^ xtime(temp[2]) ^ multiply(temp[3], 0x03);
        state[col + 3] = multiply(temp[0], 0x03) ^ temp[1] ^ temp[2] ^ xtime(temp[3]);
    }
}

void AESCrypto::invMixColumns(quint8 *state)
{
    quint8 temp[4];

    for (int c = 0; c < 4; ++c) {
        int col = c * 4;
        temp[0] = state[col];
        temp[1] = state[col + 1];
        temp[2] = state[col + 2];
        temp[3] = state[col + 3];

        state[col]     = multiply(temp[0], 0x0e) ^ multiply(temp[1], 0x0b) ^ multiply(temp[2], 0x0d) ^ multiply(temp[3], 0x09);
        state[col + 1] = multiply(temp[0], 0x09) ^ multiply(temp[1], 0x0e) ^ multiply(temp[2], 0x0b) ^ multiply(temp[3], 0x0d);
        state[col + 2] = multiply(temp[0], 0x0d) ^ multiply(temp[1], 0x09) ^ multiply(temp[2], 0x0e) ^ multiply(temp[3], 0x0b);
        state[col + 3] = multiply(temp[0], 0x0b) ^ multiply(temp[1], 0x0d) ^ multiply(temp[2], 0x09) ^ multiply(temp[3], 0x0e);
    }
}

void AESCrypto::addRoundKey(quint8 *state, const quint8 *roundKey)
{
    for (int i = 0; i < 16; ++i) {
        state[i] ^= roundKey[i];
    }
}

void AESCrypto::keyExpansion(const QByteArray &key)
{
    int i, j;
    quint8 temp[4];
    int keyBytes = m_nk * 4;

    // 复制原始密钥
    for (i = 0; i < keyBytes; ++i) {
        m_roundKeys[i] = static_cast<quint8>(key[i]);
    }

    // 扩展密钥
    for (i = m_nk; i < 4 * (m_nr + 1); ++i) {
        for (j = 0; j < 4; ++j) {
            temp[j] = m_roundKeys[(i - 1) * 4 + j];
        }

        if (i % m_nk == 0) {
            // RotWord
            quint8 k = temp[0];
            temp[0] = temp[1];
            temp[1] = temp[2];
            temp[2] = temp[3];
            temp[3] = k;

            // SubWord
            for (j = 0; j < 4; ++j) {
                temp[j] = SBOX[temp[j]];
            }

            // XOR with Rcon
            temp[0] ^= RCON[i / m_nk];
        } else if (m_nk > 6 && i % m_nk == 4) {
            // SubWord for AES-256
            for (j = 0; j < 4; ++j) {
                temp[j] = SBOX[temp[j]];
            }
        }

        for (j = 0; j < 4; ++j) {
            m_roundKeys[i * 4 + j] = m_roundKeys[(i - m_nk) * 4 + j] ^ temp[j];
        }
    }
}

void AESCrypto::encryptBlock(quint8 *block)
{
    addRoundKey(block, m_roundKeys);

    for (int round = 1; round < m_nr; ++round) {
        subBytes(block);
        shiftRows(block);
        mixColumns(block);
        addRoundKey(block, m_roundKeys + round * 16);
    }

    subBytes(block);
    shiftRows(block);
    addRoundKey(block, m_roundKeys + m_nr * 16);
}

void AESCrypto::decryptBlock(quint8 *block)
{
    addRoundKey(block, m_roundKeys + m_nr * 16);

    for (int round = m_nr - 1; round > 0; --round) {
        invShiftRows(block);
        invSubBytes(block);
        addRoundKey(block, m_roundKeys + round * 16);
        invMixColumns(block);
    }

    invShiftRows(block);
    invSubBytes(block);
    addRoundKey(block, m_roundKeys);
}

QByteArray AESCrypto::pkcs7Pad(const QByteArray &data, int blockSize)
{
    int padLen = blockSize - (data.size() % blockSize);
    QByteArray padded = data;
    for (int i = 0; i < padLen; ++i) {
        padded.append(static_cast<char>(padLen));
    }
    return padded;
}

QByteArray AESCrypto::pkcs7Unpad(const QByteArray &data)
{
    if (data.isEmpty()) return data;
    int padLen = static_cast<quint8>(data.at(data.size() - 1));
    if (padLen > 16 || padLen > data.size()) return data;
    return data.left(data.size() - padLen);
}

QByteArray AESCrypto::encryptECB(const QByteArray &plaintext, const QByteArray &key)
{
    keyExpansion(key);

    QByteArray padded = pkcs7Pad(plaintext, 16);
    QByteArray result;

    for (int i = 0; i < padded.size(); i += 16) {
        quint8 block[16];
        for (int j = 0; j < 16; ++j) {
            block[j] = static_cast<quint8>(padded[i + j]);
        }
        encryptBlock(block);
        result.append(reinterpret_cast<const char*>(block), 16);
    }

    return result;
}

QByteArray AESCrypto::decryptECB(const QByteArray &ciphertext, const QByteArray &key)
{
    keyExpansion(key);

    QByteArray result;

    for (int i = 0; i < ciphertext.size(); i += 16) {
        quint8 block[16];
        for (int j = 0; j < 16; ++j) {
            block[j] = static_cast<quint8>(ciphertext[i + j]);
        }
        decryptBlock(block);
        result.append(reinterpret_cast<const char*>(block), 16);
    }

    return pkcs7Unpad(result);
}

QByteArray AESCrypto::encryptCBC(const QByteArray &plaintext, const QByteArray &key, const QByteArray &iv)
{
    keyExpansion(key);

    QByteArray padded = pkcs7Pad(plaintext, 16);
    QByteArray result;
    QByteArray prevBlock = iv;

    for (int i = 0; i < padded.size(); i += 16) {
        quint8 block[16];
        for (int j = 0; j < 16; ++j) {
            block[j] = static_cast<quint8>(padded[i + j]) ^ static_cast<quint8>(prevBlock[j]);
        }
        encryptBlock(block);
        result.append(reinterpret_cast<const char*>(block), 16);
        prevBlock = result.right(16);
    }

    return result;
}

QByteArray AESCrypto::decryptCBC(const QByteArray &ciphertext, const QByteArray &key, const QByteArray &iv)
{
    keyExpansion(key);

    QByteArray result;
    QByteArray prevBlock = iv;

    for (int i = 0; i < ciphertext.size(); i += 16) {
        quint8 block[16];
        QByteArray currentBlock = ciphertext.mid(i, 16);

        for (int j = 0; j < 16; ++j) {
            block[j] = static_cast<quint8>(currentBlock[j]);
        }
        decryptBlock(block);

        for (int j = 0; j < 16; ++j) {
            block[j] ^= static_cast<quint8>(prevBlock[j]);
        }

        result.append(reinterpret_cast<const char*>(block), 16);
        prevBlock = currentBlock;
    }

    return pkcs7Unpad(result);
}

void AESCrypto::encrypt()
{
    if (m_inputText.isEmpty()) {
        emit errorOccurred(tr("请输入要加密的内容"));
        return;
    }

    QByteArray keyBytes = QByteArray::fromHex(m_key.toLatin1());
    int expectedKeyLen = m_keySize == "128" ? 16 : (m_keySize == "192" ? 24 : 32);

    if (keyBytes.size() != expectedKeyLen) {
        emit errorOccurred(tr("密钥长度必须为%1字节（%2个十六进制字符）").arg(expectedKeyLen).arg(expectedKeyLen * 2));
        return;
    }

    QByteArray result;

    if (m_mode == "CBC") {
        QByteArray ivBytes = QByteArray::fromHex(m_iv.toLatin1());
        if (ivBytes.size() != 16) {
            emit errorOccurred(tr("IV长度必须为16字节（32个十六进制字符）"));
            return;
        }
        result = encryptCBC(m_inputText.toUtf8(), keyBytes, ivBytes);
    } else {
        result = encryptECB(m_inputText.toUtf8(), keyBytes);
    }

    m_result = result.toHex();
    if (m_uppercase) {
        m_result = m_result.toUpper();
    }
    emit resultChanged();
}

void AESCrypto::decrypt()
{
    if (m_inputText.isEmpty()) {
        emit errorOccurred(tr("请输入要解密的内容"));
        return;
    }

    QByteArray keyBytes = QByteArray::fromHex(m_key.toLatin1());
    int expectedKeyLen = m_keySize == "128" ? 16 : (m_keySize == "192" ? 24 : 32);

    if (keyBytes.size() != expectedKeyLen) {
        emit errorOccurred(tr("密钥长度必须为%1字节（%2个十六进制字符）").arg(expectedKeyLen).arg(expectedKeyLen * 2));
        return;
    }

    QByteArray cipherBytes = QByteArray::fromHex(m_inputText.toLatin1());
    if (cipherBytes.size() % 16 != 0) {
        emit errorOccurred(tr("密文长度必须是32的倍数（16字节块）"));
        return;
    }

    QByteArray result;

    if (m_mode == "CBC") {
        QByteArray ivBytes = QByteArray::fromHex(m_iv.toLatin1());
        if (ivBytes.size() != 16) {
            emit errorOccurred(tr("IV长度必须为16字节（32个十六进制字符）"));
            return;
        }
        result = decryptCBC(cipherBytes, keyBytes, ivBytes);
    } else {
        result = decryptECB(cipherBytes, keyBytes);
    }

    m_result = QString::fromUtf8(result);
    emit resultChanged();
}
