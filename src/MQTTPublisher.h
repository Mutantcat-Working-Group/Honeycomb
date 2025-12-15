#ifndef MQTTPUBLISHER_H
#define MQTTPUBLISHER_H

#include <QObject>
#include <QString>
#include <memory>

namespace mqtt {
    class async_client;
}

class MQTTPublisher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString brokerUrl READ brokerUrl WRITE setBrokerUrl NOTIFY brokerUrlChanged)
    Q_PROPERTY(QString clientId READ clientId WRITE setClientId NOTIFY clientIdChanged)
    Q_PROPERTY(QString topic READ topic WRITE setTopic NOTIFY topicChanged)
    Q_PROPERTY(QString message READ message WRITE setMessage NOTIFY messageChanged)
    Q_PROPERTY(int qos READ qos WRITE setQos NOTIFY qosChanged)
    Q_PROPERTY(bool retained READ retained WRITE setRetained NOTIFY retainedChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(QString messageLog READ messageLog NOTIFY messageLogChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)

public:
    explicit MQTTPublisher(QObject *parent = nullptr);
    ~MQTTPublisher();

    QString brokerUrl() const { return m_brokerUrl; }
    void setBrokerUrl(const QString &url);

    QString clientId() const { return m_clientId; }
    void setClientId(const QString &id);

    QString topic() const { return m_topic; }
    void setTopic(const QString &topic);

    QString message() const { return m_message; }
    void setMessage(const QString &message);

    int qos() const { return m_qos; }
    void setQos(int qos);

    bool retained() const { return m_retained; }
    void setRetained(bool retained);

    bool isConnected() const { return m_isConnected; }
    QString connectionStatus() const;
    QString messageLog() const { return m_messageLog; }

    QString username() const { return m_username; }
    void setUsername(const QString &username);

    QString password() const { return m_password; }
    void setPassword(const QString &password);

    Q_INVOKABLE void connectToBroker();
    Q_INVOKABLE void disconnect();
    Q_INVOKABLE void publish();
    Q_INVOKABLE void clearLog();

signals:
    void brokerUrlChanged();
    void clientIdChanged();
    void topicChanged();
    void messageChanged();
    void qosChanged();
    void retainedChanged();
    void isConnectedChanged();
    void connectionStatusChanged();
    void messageLogChanged();
    void usernameChanged();
    void passwordChanged();

private:
    void appendLog(const QString &message);

    std::shared_ptr<mqtt::async_client> m_client;
    
    QString m_brokerUrl;
    QString m_clientId;
    QString m_topic;
    QString m_message;
    QString m_username;
    QString m_password;
    int m_qos;
    bool m_retained;
    bool m_isConnected;
    QString m_messageLog;
    int m_messageCount;
    static const int MAX_LOG_LINES = 1000;
};

#endif // MQTTPUBLISHER_H
