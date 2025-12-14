#ifndef WEBSOCKETTEST_H
#define WEBSOCKETTEST_H

#include <QObject>
#include <QString>
#include <QWebSocket>

class WebSocketTest : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString serverUrl READ serverUrl WRITE setServerUrl NOTIFY serverUrlChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(QString messageLog READ messageLog NOTIFY messageLogChanged)
    Q_PROPERTY(QString inputMessage READ inputMessage WRITE setInputMessage NOTIFY inputMessageChanged)

public:
    explicit WebSocketTest(QObject *parent = nullptr);
    ~WebSocketTest();

    QString serverUrl() const;
    void setServerUrl(const QString &url);

    bool isConnected() const;
    QString connectionStatus() const;
    QString messageLog() const;
    QString inputMessage() const;
    void setInputMessage(const QString &message);

    Q_INVOKABLE void connectToServer();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void sendMessage();
    Q_INVOKABLE void clearLog();

signals:
    void serverUrlChanged();
    void isConnectedChanged();
    void connectionStatusChanged();
    void messageLogChanged();
    void inputMessageChanged();

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString &message);
    void onError();

private:
    void appendLog(const QString &message, bool isSent = false);

    QWebSocket *m_webSocket;
    QString m_serverUrl;
    QString m_messageLog;
    QString m_inputMessage;
    bool m_isConnected;
};

#endif // WEBSOCKETTEST_H