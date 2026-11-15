#include "OpenAIClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QRandomGenerator>
#include <QTimer>

#include <string>
#include <utility>
#include <vector>

#define LLM_RETRY_IMPLEMENTATION
#include "../lib/llm-retry/llm_retry.hpp"
#define LLM_COST_IMPLEMENTATION
#include "../lib/llm-cost/llm_cost.hpp"

namespace {

// 429/5xx 或连接断开且尚未收到任何内容时重试：最多 3 次，500ms 起指数退避
const llm::RetryConfig kRetryConfig;

// 智能处理 URL：如果用户输入的 URL 已经包含完整路径，则直接使用
QString chatCompletionsUrl(QString urlStr)
{
    if (!urlStr.contains("/v1/chat/completions")) {
        if (!urlStr.endsWith("/")) urlStr += "/";
        urlStr += "v1/chat/completions";
    }
    return urlStr;
}

// 值得再试一次的网络错误：连接被拒绝、断开或超时
bool isTransientNetworkError(QNetworkReply::NetworkError error)
{
    switch (error) {
    case QNetworkReply::ConnectionRefusedError:
    case QNetworkReply::RemoteHostClosedError:
    case QNetworkReply::TimeoutError:
    case QNetworkReply::TemporaryNetworkFailureError:
    case QNetworkReply::NetworkSessionFailedError:
    case QNetworkReply::ProxyConnectionClosedError:
    case QNetworkReply::ProxyTimeoutError:
        return true;
    default:
        return false;
    }
}

// 按模型名查找 llm-cost 内置价格，未知模型返回 nullptr（只统计 token）
const llm::Model *findPricedModel(const QString &name)
{
    static const llm::Model *const kModels[] = {
        &llm::models::GPT6_ASTRA, &llm::models::GPT6_SOL, &llm::models::GPT6_LUNA,
        &llm::models::GPT4O, &llm::models::GPT4O_MINI, &llm::models::GPT4_TURBO,
        &llm::models::CLAUDE_FABLE_5_1, &llm::models::CLAUDE_OPUS_5_5, &llm::models::CLAUDE_SONNET_5,
        &llm::models::CLAUDE_OPUS, &llm::models::CLAUDE_SONNET, &llm::models::CLAUDE_HAIKU,
    };
    const std::string id = name.trimmed().toLower().toStdString();
    const llm::Model *best = nullptr;
    for (const llm::Model *m : kModels) {
        // 允许带日期后缀的名称，如 gpt-4o-2024-08-06；取最长前缀，避免 gpt-4o-mini 匹配到 gpt-4o
        if (id.rfind(m->name, 0) == 0 && (!best || m->name.size() > best->name.size())) {
            best = m;
        }
    }
    return best;
}

} // namespace

OpenAIClient::OpenAIClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_apiUrl("https://api.openai.com")
    , m_model("gpt-3.5-turbo")
    , m_temperature(0.7)
    , m_maxTokens(2048)
    , m_isLoading(false)
    , m_attempt(0)
    , m_retryTimer(new QTimer(this))
    , m_serverPromptTokens(-1)
    , m_serverCompletionTokens(-1)
    , m_usageTokens(0)
    , m_usageCostUsd(0.0)
    , m_usageCostKnown(true)
{
    m_retryTimer->setSingleShot(true);
    connect(m_retryTimer, &QTimer::timeout, this, &OpenAIClient::postCurrentRequest);
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

int OpenAIClient::usageTokens() const { return static_cast<int>(m_usageTokens); }

QString OpenAIClient::usageCost() const
{
    if (m_usageTokens == 0 || !m_usageCostKnown) return QString();
    return QString::fromStdString(llm::format_cost(m_usageCostUsd));
}

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
    const QString urlStr = chatCompletionsUrl(m_apiUrl);
    
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

    m_request = request;
    m_requestBody = QJsonDocument(requestBody).toJson();
    qDebug() << "[OpenAIClient] Sending request to:" << urlStr;
    qDebug() << "[OpenAIClient] Model:" << m_model;

    m_attempt = 0;
    postCurrentRequest();

    m_isLoading = true;
    emit isLoadingChanged();
}

void OpenAIClient::postCurrentRequest()
{
    ++m_attempt;
    m_currentResponse.clear();
    m_sseBuffer.clear();
    m_errorBody.clear();
    m_serverPromptTokens = -1;
    m_serverCompletionTokens = -1;

    m_currentReply = m_networkManager->post(m_request, m_requestBody);
    connect(m_currentReply, &QNetworkReply::readyRead, this, &OpenAIClient::onReadyRead);
    connect(m_currentReply, &QNetworkReply::finished, this, &OpenAIClient::onFinished);
}

void OpenAIClient::onReadyRead()
{
    if (!m_currentReply) return;

    // HTTP 错误时响应体是 JSON 错误信息而不是 SSE，留给 onFinished 解析
    if (m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() >= 400) {
        m_errorBody += m_currentReply->readAll();
        return;
    }

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
                // 部分服务在最后一个数据块里带 usage，有则以它为准
                const QJsonObject usage = obj["usage"].toObject();
                if (usage.contains("prompt_tokens")) {
                    m_serverPromptTokens = usage["prompt_tokens"].toInteger();
                    m_serverCompletionTokens = usage["completion_tokens"].toInteger();
                }
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
        QByteArray responseData = m_errorBody + m_currentReply->readAll();
        const int status = m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QString errorCode;
        
        // 尝试解析错误响应
        QJsonDocument doc = QJsonDocument::fromJson(responseData);
        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            if (obj.contains("error")) {
                QJsonObject errObj = obj["error"].toObject();
                errorMsg = errObj["message"].toString();
                errorCode = errObj["code"].toString();
            }
        }
        
        // 还没收到任何内容时，429/5xx 和连接断开按 llm-retry 的退避策略重试；
        // 额度用尽（insufficient_quota）的 429 重试也没用，直接报错
        bool retryable = m_currentResponse.isEmpty() && m_attempt < kRetryConfig.max_attempts;
        if (status >= 400) {
            retryable = retryable
                && llm::detail::is_retryable_code(status, kRetryConfig.retry_on_http_codes)
                && errorCode != "insufficient_quota";
        } else {
            retryable = retryable && isTransientNetworkError(error);
        }

        double delayMs = llm::detail::compute_delay_ms(m_attempt, kRetryConfig);
        bool hasRetryAfter = false;
        const double retryAfter = m_currentReply->rawHeader("Retry-After").toDouble(&hasRetryAfter);
        if (hasRetryAfter && retryAfter >= 0.0) {
            // 服务端给了等待时间就照办，超过上限则不再等待
            delayMs = retryAfter * 1000.0;
            retryable = retryable && delayMs <= kRetryConfig.max_delay_ms;
        } else {
            const double jitter = kRetryConfig.jitter_factor;
            delayMs *= 1.0 - jitter + 2.0 * jitter * QRandomGenerator::global()->generateDouble();
        }

        if (retryable) {
            qDebug() << "[OpenAIClient] Attempt" << m_attempt << "failed (" << status << errorMsg
                     << "), retrying in" << qRound(delayMs) << "ms";
            m_currentReply->deleteLater();
            m_currentReply = nullptr;
            m_retryTimer->start(qRound(delayMs));
            return;
        }

        emit errorOccurred(errorMsg);
    }
    
    finishRequest();
}

void OpenAIClient::finishRequest()
{
    // 保存助手回复到历史
    if (!m_currentResponse.isEmpty()) {
        recordUsage();
        m_messages.append(qMakePair(QString("assistant"), m_currentResponse));
        m_chatHistory.append("assistant:" + m_currentResponse);
        emit chatHistoryChanged();
    }
    
    emit streamingFinished();
    
    if (m_currentReply) {
        m_currentReply->deleteLater();
        m_currentReply = nullptr;
    }
    m_isLoading = false;
    emit isLoadingChanged();
}

void OpenAIClient::recordUsage()
{
    const llm::Model *priced = findPricedModel(m_model);
    const llm::Model model = priced ? *priced
                                    : llm::Model{m_model.toStdString(), llm::Provider::OpenAI, 0.0, 0.0, 0};

    qint64 promptTokens = m_serverPromptTokens;
    qint64 completionTokens = m_serverCompletionTokens;
    if (promptTokens < 0) {
        // 服务端没有返回 usage：用 llm-cost 估算本轮请求（不含本次回复）和回复的 token
        std::vector<std::pair<std::string, std::string>> messages;
        messages.reserve(m_messages.size());
        for (const auto &msg : m_messages) {
            messages.emplace_back(msg.first.toStdString(), msg.second.toStdString());
        }
        promptTokens = static_cast<qint64>(llm::count_messages(messages, model).tokens);
        completionTokens = static_cast<qint64>(llm::count(m_currentResponse.toStdString(), model).tokens);
    }

    m_usageTokens += promptTokens + completionTokens;
    if (priced) {
        m_usageCostUsd += promptTokens / 1000.0 * priced->input_cost_per_1k
                        + completionTokens / 1000.0 * priced->output_cost_per_1k;
    } else {
        m_usageCostKnown = false;
    }
    emit usageChanged();
}

void OpenAIClient::stopGeneration()
{
    if (m_currentReply) {
        m_currentReply->abort();
    } else if (m_retryTimer->isActive()) {
        // 正在等待重试：取消重试，结束本次请求
        m_retryTimer->stop();
        finishRequest();
    }
}

void OpenAIClient::clearChat()
{
    m_messages.clear();
    m_chatHistory.clear();
    m_currentResponse.clear();
    m_usageTokens = 0;
    m_usageCostUsd = 0.0;
    m_usageCostKnown = true;
    emit chatHistoryChanged();
    emit usageChanged();
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
    const QString urlStr = chatCompletionsUrl(m_apiUrl);
    
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
