#ifndef OPENAICLIENT_H
#define OPENAICLIENT_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QNetworkRequest>
#include <QByteArray>

class QTimer;

class OpenAIClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiUrl READ apiUrl WRITE setApiUrl NOTIFY apiUrlChanged)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)
    Q_PROPERTY(QString model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(double temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int maxTokens READ maxTokens WRITE setMaxTokens NOTIFY maxTokensChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QStringList chatHistory READ chatHistory NOTIFY chatHistoryChanged)
    Q_PROPERTY(int usageTokens READ usageTokens NOTIFY usageChanged)
    Q_PROPERTY(QString usageCost READ usageCost NOTIFY usageChanged)

public:
    explicit OpenAIClient(QObject *parent = nullptr);
    ~OpenAIClient();

    QString apiUrl() const;
    void setApiUrl(const QString &url);

    QString apiKey() const;
    void setApiKey(const QString &key);

    QString model() const;
    void setModel(const QString &model);

    double temperature() const;
    void setTemperature(double temp);

    int maxTokens() const;
    void setMaxTokens(int tokens);

    bool isLoading() const;
    QStringList chatHistory() const;

    // 本次对话累计的 token 数和费用（费用仅在模型价格已知时给出）
    int usageTokens() const;
    QString usageCost() const;

    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE void stopGeneration();
    Q_INVOKABLE void clearChat();
    Q_INVOKABLE void testConnection();

signals:
    void apiUrlChanged();
    void apiKeyChanged();
    void modelChanged();
    void temperatureChanged();
    void maxTokensChanged();
    void isLoadingChanged();
    void chatHistoryChanged();
    void usageChanged();
    void errorOccurred(const QString &error);
    void testSuccess(const QString &info);
    void streamingText(const QString &text);
    void streamingFinished();

private slots:
    void onReadyRead();
    void onFinished();

private:
    void postCurrentRequest();
    void finishRequest();
    void recordUsage();

    QNetworkAccessManager *m_networkManager;
    QNetworkReply *m_currentReply;

    QString m_apiUrl;
    QString m_apiKey;
    QString m_model;
    double m_temperature;
    int m_maxTokens;
    bool m_isLoading;
    
    // 聊天记录: "user:xxx" 或 "assistant:xxx"
    QStringList m_chatHistory;
    // 内部消息结构
    QList<QPair<QString, QString>> m_messages;
    // 当前流式响应内容
    QString m_currentResponse;
    // SSE 缓冲区
    QString m_sseBuffer;
    // 错误响应体（HTTP 4xx/5xx 时不按 SSE 解析）
    QByteArray m_errorBody;

    // 当前请求，429/5xx 或连接断开时用于重试
    QNetworkRequest m_request;
    QByteArray m_requestBody;
    int m_attempt;
    QTimer *m_retryTimer;

    // 服务端在流中返回的 usage（没有则用 llm-cost 估算）
    qint64 m_serverPromptTokens;
    qint64 m_serverCompletionTokens;
    // 本次对话累计用量
    qint64 m_usageTokens;
    double m_usageCostUsd;
    bool m_usageCostKnown;
};

#endif // OPENAICLIENT_H
