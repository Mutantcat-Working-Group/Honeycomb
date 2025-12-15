#include "MQTTListener.h"
#include <mqtt/async_client.h>
#include <QDateTime>

MQTTListener::MQTTListener(QObject *parent)
    : QObject(parent)
    , m_brokerUrl("tcp://broker.emqx.io:1883")
    , m_clientId("HoneycombClient_" + QString::number(QDateTime::currentMSecsSinceEpoch()))
    , m_topic("test/topic")
    , m_username("")
    , m_password("")
    , m_qos(1)
    , m_isConnected(false)
    , m_isSubscribed(false)
    , m_messageLog("")
    , m_receiveTimer(new QTimer(this))
{
    connect(m_receiveTimer, &QTimer::timeout, this, [this]() {
        if (!m_isConnected || !m_isSubscribed || !m_client) return;
        
        try {
            auto msg = m_client->try_consume_message_for(std::chrono::milliseconds(100));
            if (msg) {
                QString topic = QString::fromStdString(msg->get_topic());
                QString payload = QString::fromStdString(msg->to_string());
                appendLog(tr("收到消息 [%1]: %2").arg(topic, payload));
            }
        } catch (...) {
        }
    });
}

MQTTListener::~MQTTListener()
{
    if (m_client) {
        try {
            if (m_client->is_connected()) {
                m_client->disconnect()->wait();
            }
        } catch (...) {
        }
    }
}

void MQTTListener::setBrokerUrl(const QString &url)
{
    if (m_brokerUrl != url) {
        m_brokerUrl = url;
        emit brokerUrlChanged();
    }
}

void MQTTListener::setClientId(const QString &id)
{
    if (m_clientId != id) {
        m_clientId = id;
        emit clientIdChanged();
    }
}

void MQTTListener::setTopic(const QString &topic)
{
    if (m_topic != topic) {
        m_topic = topic;
        emit topicChanged();
    }
}

void MQTTListener::setQos(int qos)
{
    if (m_qos != qos && qos >= 0 && qos <= 2) {
        m_qos = qos;
        emit qosChanged();
    }
}

QString MQTTListener::connectionStatus() const
{
    return m_isConnected ? tr("已连接") : tr("未连接");
}

void MQTTListener::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit usernameChanged();
    }
}

void MQTTListener::setPassword(const QString &password)
{
    if (m_password != password) {
        m_password = password;
        emit passwordChanged();
    }
}

void MQTTListener::connectToBroker()
{
    if (m_brokerUrl.isEmpty()) {
        appendLog(tr("错误: Broker地址不能为空"));
        return;
    }

    if (m_isConnected) {
        appendLog(tr("警告: 已经连接到Broker"));
        return;
    }

    try {
        appendLog(tr("正在连接到: %1").arg(m_brokerUrl));
        
        m_client = std::make_shared<mqtt::async_client>(
            m_brokerUrl.toStdString(), 
            m_clientId.toStdString()
        );

        mqtt::connect_options connOpts;
        connOpts.set_keep_alive_interval(20);
        connOpts.set_clean_session(true);

        if (!m_username.isEmpty()) {
            connOpts.set_user_name(m_username.toStdString());
            if (!m_password.isEmpty()) {
                connOpts.set_password(m_password.toStdString());
            }
        }

        auto tok = m_client->connect(connOpts);
        tok->wait();
        
        m_isConnected = true;
        emit isConnectedChanged();
        emit connectionStatusChanged();
        appendLog(tr("连接成功"));

    } catch (const mqtt::exception& exc) {
        appendLog(tr("连接异常: %1").arg(QString::fromStdString(exc.what())));
        m_isConnected = false;
        emit isConnectedChanged();
        emit connectionStatusChanged();
    }
}

void MQTTListener::disconnect()
{
    if (!m_isConnected) {
        appendLog(tr("警告: 未连接到Broker"));
        return;
    }

    try {
        // 停止定时器
        m_receiveTimer->stop();
        
        if (m_client) {
            if (m_isSubscribed) {
                m_client->stop_consuming();
            }
            m_client->disconnect()->wait();
            m_isConnected = false;
            m_isSubscribed = false;
            emit isConnectedChanged();
            emit isSubscribedChanged();
            emit connectionStatusChanged();
            appendLog(tr("连接已断开"));
        }
    } catch (const mqtt::exception& exc) {
        appendLog(tr("断开连接异常: %1").arg(QString::fromStdString(exc.what())));
    }
}

void MQTTListener::subscribe()
{
    if (!m_isConnected) {
        appendLog(tr("错误: 未连接到Broker，无法订阅"));
        return;
    }

    if (m_isSubscribed) {
        appendLog(tr("警告: 已经订阅了主题"));
        return;
    }

    if (m_topic.isEmpty()) {
        appendLog(tr("错误: 主题不能为空"));
        return;
    }

    try {
        appendLog(tr("正在订阅主题: %1 (QoS: %2)").arg(m_topic).arg(m_qos));
        
        m_client->start_consuming();
        m_client->subscribe(m_topic.toStdString(), m_qos)->wait();
        
        m_isSubscribed = true;
        emit isSubscribedChanged();
        
        appendLog(tr("订阅成功，等待消息..."));
        
        // 启动定时器接收消息
        m_receiveTimer->start(100);
        
    } catch (const mqtt::exception& exc) {
        appendLog(tr("订阅异常: %1").arg(QString::fromStdString(exc.what())));
    }
}

void MQTTListener::unsubscribe()
{
    if (!m_isConnected) {
        appendLog(tr("错误: 未连接到Broker，无法取消订阅"));
        return;
    }

    if (!m_isSubscribed) {
        appendLog(tr("警告: 未订阅任何主题"));
        return;
    }

    if (m_topic.isEmpty()) {
        appendLog(tr("错误: 主题不能为空"));
        return;
    }

    try {
        // 停止定时器
        m_receiveTimer->stop();
        
        m_client->unsubscribe(m_topic.toStdString())->wait();
        m_client->stop_consuming();
        
        m_isSubscribed = false;
        emit isSubscribedChanged();
        
        appendLog(tr("已取消订阅主题: %1").arg(m_topic));
    } catch (const mqtt::exception& exc) {
        appendLog(tr("取消订阅异常: %1").arg(QString::fromStdString(exc.what())));
    }
}

void MQTTListener::clearLog()
{
    m_messageLog = "";
    emit messageLogChanged();
}

void MQTTListener::appendLog(const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    QString logEntry = QString("[%1] %2").arg(timestamp, message);
    
    if (!m_messageLog.isEmpty()) {
        m_messageLog += "\n";
    }
    m_messageLog += logEntry;
    
    emit messageLogChanged();
}
