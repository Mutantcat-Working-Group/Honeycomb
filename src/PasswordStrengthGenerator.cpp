#include "PasswordStrengthGenerator.h"

PasswordStrengthGenerator::PasswordStrengthGenerator(QObject *parent)
    : QObject(parent)
    , m_password("")
    , m_score(0)
    , m_strengthLevel("")
    , m_hasLowercase(false)
    , m_hasUppercase(false)
    , m_hasDigits(false)
    , m_hasSpecialChars(false)
    , m_length(0)
{
}

QString PasswordStrengthGenerator::password() const
{
    return m_password;
}

void PasswordStrengthGenerator::setPassword(const QString &password)
{
    if (m_password != password) {
        m_password = password;
        emit passwordChanged();
    }
}

int PasswordStrengthGenerator::score() const
{
    return m_score;
}

QString PasswordStrengthGenerator::strengthLevel() const
{
    return m_strengthLevel;
}

bool PasswordStrengthGenerator::hasLowercase() const
{
    return m_hasLowercase;
}

bool PasswordStrengthGenerator::hasUppercase() const
{
    return m_hasUppercase;
}

bool PasswordStrengthGenerator::hasDigits() const
{
    return m_hasDigits;
}

bool PasswordStrengthGenerator::hasSpecialChars() const
{
    return m_hasSpecialChars;
}

int PasswordStrengthGenerator::length() const
{
    return m_length;
}

void PasswordStrengthGenerator::analyze()
{
    if (m_password.isEmpty()) {
        m_score = 0;
        m_strengthLevel = "";
        m_hasLowercase = false;
        m_hasUppercase = false;
        m_hasDigits = false;
        m_hasSpecialChars = false;
        m_length = 0;
        
        emit scoreChanged();
        emit strengthLevelChanged();
        emit hasLowercaseChanged();
        emit hasUppercaseChanged();
        emit hasDigitsChanged();
        emit hasSpecialCharsChanged();
        emit lengthChanged();
        return;
    }
    
    // 重置所有标志
    m_score = 0;
    m_hasLowercase = false;
    m_hasUppercase = false;
    m_hasDigits = false;
    m_hasSpecialChars = false;
    m_length = m_password.length();
    
    // 检查密码特征
    QRegularExpression lowercaseRegex("[a-z]");
    QRegularExpression uppercaseRegex("[A-Z]");
    QRegularExpression digitsRegex("[0-9]");
    QRegularExpression specialCharsRegex("[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]");
    
    m_hasLowercase = m_password.contains(lowercaseRegex);
    m_hasUppercase = m_password.contains(uppercaseRegex);
    m_hasDigits = m_password.contains(digitsRegex);
    m_hasSpecialChars = m_password.contains(specialCharsRegex);
    
    // 计算分数
    // 基础分数（长度）
    if (m_length >= 8) {
        m_score += 20;
    } else if (m_length >= 6) {
        m_score += 10;
    } else if (m_length >= 4) {
        m_score += 5;
    }
    
    // 长度加分
    if (m_length >= 12) {
        m_score += 10;
    } else if (m_length >= 10) {
        m_score += 5;
    }
    
    // 字符类型加分
    if (m_hasLowercase) {
        m_score += 15;
    }
    
    if (m_hasUppercase) {
        m_score += 15;
    }
    
    if (m_hasDigits) {
        m_score += 15;
    }
    
    if (m_hasSpecialChars) {
        m_score += 25;
    }
    
    // 确保分数不超过100
    m_score = qMin(m_score, 100);
    
    // 更新强度等级
    updateStrengthLevel();
    
    // 发送信号
    emit scoreChanged();
    emit strengthLevelChanged();
    emit hasLowercaseChanged();
    emit hasUppercaseChanged();
    emit hasDigitsChanged();
    emit hasSpecialCharsChanged();
    emit lengthChanged();
}

void PasswordStrengthGenerator::updateStrengthLevel()
{
    if (m_score < 20) {
        m_strengthLevel = "非常弱";
    } else if (m_score < 40) {
        m_strengthLevel = "弱";
    } else if (m_score < 60) {
        m_strengthLevel = "一般";
    } else if (m_score < 80) {
        m_strengthLevel = "强";
    } else {
        m_strengthLevel = "非常强";
    }
}