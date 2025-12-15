#include "MQTTPublisher.h"
#include <mqtt/async_client.h>
#include <QDateTime>

MQTTPublisher::MQTTPublisher(QObject *parent)
    : QObject(parent)
    , m_brokerUrl("tcp://broker.emqx.io:1883")
    , m_clientId("HoneycombPublisher_" + QString::number(QDateTime::currentMSecsSinceEpoch()))
    , m_topic("test/topic")
    , m_message("")
    , m_username("")
    , m_password("")
    , m_qos(1)
    , m_retained(false)
    , m_isConnected(false)
    , m_messageLog("")
    , m_messageCount(0)
{
}

MQTTPublisher::~MQTTPublisher()
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

void MQTTPublisher::setBrokerUrl(const QString &url)
{
    if (m_brokerUrl != url) {
        m_brokerUrl = url;
        emit brokerUrlChanged();
    }
}

void MQTTPublisher::setClientId(const QString &id)
{
    if (m_clientId != id) {
        m_clientId = id;
        emit clientIdChanged();
    }
}

void MQTTPublisher::setTopic(const QString &topic)
{
    if (m_topic != topic) {
        m_topic = topic;
        emit topicChanged();
    }
}

void MQTTPublisher::setMessage(const QString &message)
{
    if (m_message != message) {
        m_message = message;
        emit messageChanged();
    }
}

void MQTTPublisher::setQos(int qos)
{
    if (m_qos != qos && qos >= 0 && qos <= 2) {
        m_qos = qos;
        emit qosChanged();
    }
}

void MQTTPublisher::setRetained(bool retained)
{
    if (m_retained != retained) {
        m_retained = retained;
        emit retainedChanged();
    }
}

QString MQTTPublisher::connectionStatus() const
{
    return m_isConnected ? tr("已连接") : tr("未连接");
}

void MQTTPublisher::setUsername(const QString &username)
{
    if (m_username != username) {
        m_username = username;
        emit usernameChanged();
    }
}

void MQTTPublisher::setPassword(const QString &password)
{
    if (m_password != password) {
        m_password = password;
        emit passwordChanged();
    }
}

void MQTTPublisher::connectToBroker()
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

void MQTTPublisher::disconnect()
{
    if (!m_isConnected) {
        appendLog(tr("警告: 未连接到Broker"));
        return;
    }

    try {
        if (m_client) {
            m_client->disconnect()->wait();
            m_isConnected = false;
            emit isConnectedChanged();
            emit connectionStatusChanged();
            appendLog(tr("连接已断开"));
        }
    } catch (const mqtt::exception& exc) {
        appendLog(tr("断开连接异常: %1").arg(QString::fromStdString(exc.what())));
    }
}

void MQTTPublisher::publish()
{
    if (!m_isConnected) {
        appendLog(tr("错误: 未连接到Broker，无法发布消息"));
        return;
    }

    if (m_topic.isEmpty()) {
        appendLog(tr("错误: 主题不能为空"));
        return;
    }

    if (m_message.isEmpty()) {
        appendLog(tr("错误: 消息内容不能为空"));
        return;
    }

    try {
        auto msg = mqtt::make_message(
            m_topic.toStdString(), 
            m_message.toStdString()
        );
        msg->set_qos(m_qos);
        msg->set_retained(m_retained);

        m_client->publish(msg)->wait();
        
        QString retainedStr = m_retained ? tr("保留") : tr("不保留");
        appendLog(tr("发布成功 [主题: %1, QoS: %2, %3]: %4")
                  .arg(m_topic)
                  .arg(m_qos)
                  .arg(retainedStr)
                  .arg(m_message));

    } catch (const mqtt::exception& exc) {
        appendLog(tr("发布异常: %1").arg(QString::fromStdString(exc.what())));
    }
}

void MQTTPublisher::clearLog()
{
    m_messageLog = "";
    m_messageCount = 0;
    emit messageLogChanged();
}

void MQTTPublisher::appendLog(const QString &message)
{
    QString timestamp = QDateTime::currentDateTime().toString("hh:mm:ss.zzz");
    QString logEntry = QString("[%1] %2").arg(timestamp, message);
    
    if (!m_messageLog.isEmpty()) {
        m_messageLog += "\n";
    }
    m_messageLog += logEntry;
    m_messageCount++;
    
    // 限制日志行数，避免内存占用过大和UI卡顿
    if (m_messageCount > MAX_LOG_LINES) {
        // 删除最旧的日志行
        int firstNewline = m_messageLog.indexOf('\n');
        if (firstNewline != -1) {
            m_messageLog = m_messageLog.mid(firstNewline + 1);
            m_messageCount--;
        }
    }
    
    emit messageLogChanged();
}