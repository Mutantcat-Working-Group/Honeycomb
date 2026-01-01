#include "OpenAIClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

OpenAIClient::OpenAIClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_apiUrl("https://api.openai.com")
    , m_model("gpt-3.5-turbo")
    , m_temperature(0.7)
    , m_maxTokens(2048)
    , m_isLoading(false)
{
}

OpenAIClient::~OpenAIClient()
{
    stopGeneration();
}

QString OpenAIClient::apiUrl() const { return m_apiUrl; }
void OpenAIClient::setApiUrl(const QString &url)
{
    if (m_apiUrl != url) {
        m_apiUrl = url;
        emit apiUrlChanged();
    }
}

QString OpenAIClient::apiKey() const { return m_apiKey; }
void OpenAIClient::setApiKey(const QString &key)
{
    if (m_apiKey != key) {
        m_apiKey = key;
        emit apiKeyChanged();
    }
}

QString OpenAIClient::model() const { return m_model; }
void OpenAIClient::setModel(const QString &model)
{
    if (m_model != model) {
        m_model = model;
        qDebug() << "[OpenAIClient] Model set to:" << m_model;
        emit modelChanged();
    }
}

double OpenAIClient::temperature() const { return m_temperature; }
void OpenAIClient::setTemperature(double temp)
{
    if (!qFuzzyCompare(m_temperature, temp)) {
        m_temperature = temp;
        emit temperatureChanged();
    }
}

int OpenAIClient::maxTokens() const { return m_maxTokens; }
void OpenAIClient::setMaxTokens(int tokens)
{
    if (m_maxTokens != tokens) {
        m_maxTokens = tokens;
        emit maxTokensChanged();
    }
}

bool OpenAIClient::isLoading() const { return m_isLoading; }

QStringList OpenAIClient::chatHistory() const { return m_chatHistory; }

void OpenAIClient::sendMessage(const QString &message)
{
    if (message.trimmed().isEmpty()) {
        emit errorOccurred("消息不能为空");
        return;
    }
    
    if (m_apiUrl.trimmed().isEmpty()) {
        emit errorOccurred("请填写 API URL");
        return;
    }
    
    if (m_apiKey.trimmed().isEmpty()) {
        emit errorOccurred("请填写 API Key");
        return;
    }
    
    if (m_model.trimmed().isEmpty()) {
        emit errorOccurred("请填写模型名称");
        return;
    }

    if (m_isLoading) {
        return;
    }

    // 添加用户消息到历史
    m_messages.append(qMakePair(QString("user"), message));
    m_chatHistory.append("user:" + message);
    emit chatHistoryChanged();

    // 准备请求 - 智能处理 URL
    QString urlStr = m_apiUrl;
    // 如果用户输入的 URL 已经包含完整路径，则直接使用
    if (!urlStr.contains("/v1/chat/completions")) {
        if (!urlStr.endsWith("/")) urlStr += "/";
        urlStr += "v1/chat/completions";
    }
    
    QUrl url(urlStr);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_apiKey).toUtf8());

    // 构建消息数组
    QJsonArray messagesArray;
    for (const auto &msg : m_messages) {
        QJsonObject msgObj;
        msgObj["role"] = msg.first;
        msgObj["content"] = msg.second;
        messagesArray.append(msgObj);
    }

    QJsonObject requestBody;
    requestBody["model"] = m_model;
    requestBody["messages"] = messagesArray;
    requestBody["temperature"] = m_temperature;
    requestBody["max_tokens"] = m_maxTokens;
    requestBody["stream"] = true;

    QByteArray data = QJsonDocument(requestBody).toJson();
    qDebug() << "[OpenAIClient] Sending request to:" << urlStr;
    qDebug() << "[OpenAIClient] Model:" << m_model;

    m_currentReply = m_networkManager->post(request, data);
    connect(m_currentReply, &QNetworkReply::readyRead, this, &OpenAIClient::onReadyRead);
    connect(m_currentReply, &QNetworkReply::finished, this, &OpenAIClient::onFinished);

    m_isLoading = true;
    emit isLoadingChanged();
    m_currentResponse.clear();
    m_sseBuffer.clear();
}

void OpenAIClient::onReadyRead()
{
    if (!m_currentReply) return;

    m_sseBuffer += QString::fromUtf8(m_currentReply->readAll());
    
    // 处理 SSE 数据
    QStringList lines = m_sseBuffer.split('\n');
    m_sseBuffer.clear();
    
    for (int i = 0; i < lines.size(); ++i) {
        QString line = lines[i];
        
        // 如果是最后一行且不为空，可能是不完整的数据，保留到缓冲区
        if (i == lines.size() - 1 && !line.isEmpty() && !line.startsWith("data:")) {
            m_sseBuffer = line;
            continue;
        }
        
        if (line.startsWith("data:")) {
            QString jsonStr = line.mid(5).trimmed();
            
            if (jsonStr == "[DONE]") {
                continue;
            }
            
            QJsonDocument doc = QJsonDocument::fromJson(jsonStr.toUtf8());
            if (doc.isObject()) {
                QJsonObject obj = doc.object();
                QJsonArray choices = obj["choices"].toArray();
                if (!choices.isEmpty()) {
                    QJsonObject choice = choices[0].toObject();
                    QJsonObject delta = choice["delta"].toObject();
                    QString content = delta["content"].toString();
                    if (!content.isEmpty()) {
                        m_currentResponse += content;
                        emit streamingText(content);
                    }
                }
            }
        }
    }
}

void OpenAIClient::onFinished()
{
    if (!m_currentReply) return;

    QNetworkReply::NetworkError error = m_currentReply->error();
    
    if (error != QNetworkReply::NoError && error != QNetworkReply::OperationCanceledError) {
        QString errorMsg = m_currentReply->errorString();
        QByteArray responseData = m_currentReply->readAll();
        
        // 尝试解析错误响应
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            if (obj.contains("error")) {
                QJsonObject errObj = obj["error"].toObject();
                errorMsg = errObj["message"].toString();
            }
        }
        
        emit errorOccurred(errorMsg);
    }
    
    // 保存助手回复到历史
    if (!m_currentResponse.isEmpty()) {
        m_messages.append(qMakePair(QString("assistant"), m_currentResponse));
        m_chatHistory.append("assistant:" + m_currentResponse);
        emit chatHistoryChanged();
    }
    
    emit streamingFinished();
    
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
    m_isLoading = false;
    emit isLoadingChanged();
}

void OpenAIClient::stopGeneration()
{
    if (m_currentReply) {
        m_currentReply->abort();
    }
}

void OpenAIClient::clearChat()
{
    m_messages.clear();
    m_chatHistory.clear();
    m_currentResponse.clear();
    emit chatHistoryChanged();
}

void OpenAIClient::testConnection()
{
    if (m_apiUrl.trimmed().isEmpty()) {
        emit errorOccurred("请填写 API URL");
        return;
    }
    
    if (m_apiKey.trimmed().isEmpty()) {
        emit errorOccurred("请填写 API Key");
        return;
    }
    
    if (m_model.trimmed().isEmpty()) {
        emit errorOccurred("请填写模型名称");
        return;
    }

    // 智能处理 URL
    QString urlStr = m_apiUrl;
    if (!urlStr.contains("/v1/chat/completions")) {
        if (!urlStr.endsWith("/")) urlStr += "/";
        urlStr += "v1/chat/completions";
    }
    
    QUrl url(urlStr);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer %1").arg(m_apiKey).toUtf8());

    QJsonObject requestBody;
    requestBody["model"] = m_model;
    requestBody["messages"] = QJsonArray({QJsonObject{{"role", "user"}, {"content", "Hi"}}});
    requestBody["max_tokens"] = 5;

    QByteArray data = QJsonDocument(requestBody).toJson();
    qDebug() << "[OpenAIClient] Testing connection to:" << urlStr;
    qDebug() << "[OpenAIClient] Using model:" << m_model;

    QNetworkReply *reply = m_networkManager->post(request, data);
    
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        QByteArray responseData = reply->readAll();
        
        if (reply->error() != QNetworkReply::NoError) {
            QString errorMsg = reply->errorString();
            QJsonDocument doc = QJsonDocument::fromJson(responseData);
            if (doc.isObject()) {
                QJsonObject obj = doc.object();
                if (obj.contains("error")) {
                    QJsonObject errObj = obj["error"].toObject();
                    errorMsg = errObj["message"].toString();
                }
            }
            emit errorOccurred(QString("连接失败: %1").arg(errorMsg));
        } else {
            QJsonDocument doc = QJsonDocument::fromJson(responseData);
            QString info = QString("连接成功!\n请求模型: %1").arg(m_model);
            if (doc.isObject()) {
                QJsonObject obj = doc.object();
                if (obj.contains("model")) {
                    info += QString("\n响应模型: %1").arg(obj["model"].toString());
                }
            }
            emit testSuccess(info);
        }
        
        reply->deleteLater();
    });
}
