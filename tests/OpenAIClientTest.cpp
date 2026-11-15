#include "../src/OpenAIClient.h"

#include <QCoreApplication>
#include <QEventLoop>
#include <QHostAddress>
#include <QHash>
#include <QList>
#include <QTcpServer>
#include <QTcpSocket>
#include <QTimer>

#include <cstdlib>

namespace {
void require(bool condition)
{
    if (!condition) {
        std::abort();
    }
}

// Answers each POST with the next canned HTTP response, then closes.
class FakeChatServer : public QTcpServer
{
public:
    QList<QByteArray> responses;
    int requests = 0;

    FakeChatServer()
    {
        connect(this, &QTcpServer::newConnection, this, [this]() {
            while (QTcpSocket *socket = nextPendingConnection()) {
                connect(socket, &QTcpSocket::readyRead, this, [this, socket]() { onReadyRead(socket); });
                connect(socket, &QTcpSocket::disconnected, socket, &QObject::deleteLater);
            }
        });
    }

    QString url() const { return QString("http://127.0.0.1:%1").arg(serverPort()); }

private:
    QHash<QTcpSocket *, QByteArray> m_buffers;

    void onReadyRead(QTcpSocket *socket)
    {
        QByteArray &buffer = m_buffers[socket];
        buffer += socket->readAll();
        const int headerEnd = buffer.indexOf("\r\n\r\n");
        if (headerEnd < 0) return;
        int contentLength = 0;
        for (const QByteArray &line : buffer.left(headerEnd).split('\n')) {
            if (line.toLower().startsWith("content-length:")) {
                contentLength = line.mid(15).trimmed().toInt();
            }
        }
        if (buffer.size() < headerEnd + 4 + contentLength) return;

        m_buffers.remove(socket);
        ++requests;
        socket->write(responses.isEmpty() ? QByteArray("HTTP/1.1 500 Internal Server Error\r\nContent-Length: 0\r\nConnection: close\r\n\r\n")
                                          : responses.takeFirst());
        socket->disconnectFromHost();
    }
};

QByteArray errorResponse(int status, const QByteArray &reason, const QByteArray &extraHeaders = QByteArray())
{
    const QByteArray body = R"({"error":{"message":"upstream said no","code":"test_error"}})";
    return "HTTP/1.1 " + QByteArray::number(status) + " " + reason + "\r\n"
           "Content-Type: application/json\r\n" + extraHeaders +
           "Content-Length: " + QByteArray::number(body.size()) + "\r\n"
           "Connection: close\r\n\r\n" + body;
}

QByteArray streamResponse(bool withUsage)
{
    QByteArray body =
        "data: {\"choices\":[{\"delta\":{\"content\":\"Hel\"}}]}\n\n"
        "data: {\"choices\":[{\"delta\":{\"content\":\"lo\"}}]}\n\n";
    if (withUsage) {
        body += "data: {\"choices\":[],\"usage\":{\"prompt_tokens\":12,\"completion_tokens\":3}}\n\n";
    }
    body += "data: [DONE]\n\n";
    return "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nConnection: close\r\n\r\n" + body;
}

// Sends one message and waits for the client to finish (retries included).
void sendAndWait(OpenAIClient &client, const QString &message)
{
    QEventLoop loop;
    QObject::connect(&client, &OpenAIClient::streamingFinished, &loop, &QEventLoop::quit);
    QTimer::singleShot(10000, &loop, [&loop]() { loop.exit(1); });
    client.sendMessage(message);
    require(loop.exec() == 0);
}
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    FakeChatServer server;
    require(server.listen(QHostAddress::LocalHost));

    OpenAIClient client;
    client.setApiUrl(server.url());
    client.setApiKey("test-key");
    client.setModel("gpt-4o-mini");

    QStringList errors;
    QObject::connect(&client, &OpenAIClient::errorOccurred, [&errors](const QString &e) { errors.append(e); });

    // A 503 with Retry-After and a 502 without it are retried; the third
    // attempt streams the reply, and the usage chunk from the server is used.
    server.responses = {
        errorResponse(503, "Service Unavailable", "Retry-After: 0\r\n"),
        errorResponse(502, "Bad Gateway"),
        streamResponse(true),
    };
    sendAndWait(client, "hi");
    require(server.requests == 3);
    require(errors.isEmpty());
    require(client.chatHistory() == QStringList({"user:hi", "assistant:Hello"}));
    require(client.usageTokens() == 15);
    require(!client.usageCost().isEmpty());

    // A 400 is the caller's fault: no retry, and the server's message is shown.
    server.requests = 0;
    server.responses = { errorResponse(400, "Bad Request") };
    sendAndWait(client, "again");
    require(server.requests == 1);
    require(errors == QStringList({"upstream said no"}));
    require(client.chatHistory().size() == 3);

    // Retries stop after three attempts.
    errors.clear();
    server.requests = 0;
    server.responses = {
        errorResponse(429, "Too Many Requests", "Retry-After: 0\r\n"),
        errorResponse(429, "Too Many Requests", "Retry-After: 0\r\n"),
        errorResponse(429, "Too Many Requests", "Retry-After: 0\r\n"),
        streamResponse(false),
    };
    sendAndWait(client, "busy");
    require(server.requests == 3);
    require(errors.size() == 1);

    // Without server usage the tokens are estimated; an unpriced model shows no cost.
    client.clearChat();
    require(client.usageTokens() == 0);
    client.setModel("my-local-model");
    server.requests = 0;
    server.responses = { streamResponse(false) };
    errors.clear();
    sendAndWait(client, "hello there");
    require(server.requests == 1);
    require(errors.isEmpty());
    require(client.usageTokens() > 0);
    require(client.usageCost().isEmpty());

    return 0;
}
