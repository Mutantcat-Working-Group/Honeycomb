#ifndef OPENAICLIENT_H
#define OPENAICLIENT_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>

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
    void errorOccurred(const QString &error);
    void testSuccess(const QString &info);
    void streamingText(const QString &text);
    void streamingFinished();

private slots:
    void onReadyRead();
    void onFinished();

private:
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
};

#endif // OPENAICLIENT_H
