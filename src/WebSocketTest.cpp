#include "WebSocketTest.h"
#include <QDateTime>
#include <QDebug>

WebSocketTest::WebSocketTest(QObject *parent)
    : QObject(parent)
    , m_webSocket(new QWebSocket())
    , m_serverUrl("wss://echo.websocket.org")
    , m_messageLog("")
    , m_inputMessage("")
    , m_isConnected(false)
{
    // 连接信号槽
    connect(m_webSocket, &QWebSocket::connected, this, &WebSocketTest::onConnected);
    connect(m_webSocket, &QWebSocket::disconnected, this, &WebSocketTest::onDisconnected);
    connect(m_webSocket, &QWebSocket::textMessageReceived, this, &WebSocketTest::onTextMessageReceived);
    connect(m_webSocket, QOverload<QAbstractSocket::SocketError>::of(&QWebSocket::error), this, &WebSocketTest::onError);
}

WebSocketTest::~WebSocketTest()
{
    if (m_webSocket) {
        m_webSocket->close();
        m_webSocket->deleteLater();
    }
}

QString WebSocketTest::serverUrl() const
{
    return m_serverUrl;
}

void WebSocketTest::setServerUrl(const QString &url)
{
    if (m_serverUrl != url) {
        m_serverUrl = url;
        emit serverUrlChanged();
    }
}

bool WebSocketTest::isConnected() const
{
    return m_isConnected;
}

QString WebSocketTest::connectionStatus() const
{
    if (m_isConnected) {
        return tr("已连接");
    } else {
        return tr("未连接");
    }
}

QString WebSocketTest::messageLog() const
{
    return m_messageLog;
}

QString WebSocketTest::inputMessage() const
{
    return m_inputMessage;
}

void WebSocketTest::setInputMessage(const QString &message)
{
    if (m_inputMessage != message) {
        m_inputMessage = message;
        emit inputMessageChanged();
    }
}

void WebSocketTest::connectToServer()
{
    if (m_serverUrl.isEmpty()) {
        appendLog(tr("错误: 服务器URL不能为空"));
        return;
    }

    if (m_isConnected) {
        appendLog(tr("警告: 已经连接到服务器"));
        return;
    }

    appendLog(tr("正在连接到: %1").arg(m_serverUrl));
    m_webSocket->open(QUrl(m_serverUrl));
}

void WebSocketTest::disconnect()
{
    if (!m_isConnected) {
        appendLog(tr("警告: 未连接到服务器"));
        return;
    }

    m_webSocket->close();
}

void WebSocketTest::sendMessage()
{
    if (!m_isConnected) {
        appendLog(tr("错误: 未连接到服务器，无法发送消息"));
        return;
    }

    if (m_inputMessage.isEmpty()) {
        appendLog(tr("错误: 消息内容不能为空"));
        return;
    }

    m_webSocket->sendTextMessage(m_inputMessage);
    appendLog(m_inputMessage, true);
    
    // 清空输入框
    setInputMessage("");
}

void WebSocketTest::clearLog()
{
    m_messageLog = "";
    emit messageLogChanged();
}

void WebSocketTest::onConnected()
{
    m_isConnected = true;
    emit isConnectedChanged();
    emit connectionStatusChanged();
    appendLog(tr("连接成功"));
}

void WebSocketTest::onDisconnected()
{
    m_isConnected = false;
    emit isConnectedChanged();
    emit connectionStatusChanged();
    appendLog(tr("连接已断开"));
}

void WebSocketTest::onTextMessageReceived(const QString &message)
{
    appendLog(message, false);
}

void WebSocketTest::onError()
{
    QString errorString = m_webSocket->errorString();
    appendLog(tr("连接错误: %1").arg(errorString));
    
    if (m_isConnected) {
        m_isConnected = false;
        emit isConnectedChanged();
        emit connectionStatusChanged();
    }
}

void WebSocketTest::appendLog(const QString &message, bool isSent)
{
    QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    QString prefix = isSent ? tr("发送") : tr("接收");
    QString logEntry = QString("[%1] %2: %3").arg(timestamp, prefix, message);
    
    if (!m_messageLog.isEmpty()) {
        m_messageLog += "\n";
    }
    m_messageLog += logEntry;
    
    emit messageLogChanged();
}