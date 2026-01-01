#ifndef FOLDERHTTPSERVER_H
#define FOLDERHTTPSERVER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QString>

class FolderHttpServer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString folderPath READ folderPath WRITE setFolderPath NOTIFY folderPathChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(int requestCount READ requestCount NOTIFY requestCountChanged)

public:
    explicit FolderHttpServer(QObject *parent = nullptr);
    ~FolderHttpServer();

    QString folderPath() const;
    void setFolderPath(const QString &path);

    int port() const;
    void setPort(int port);

    bool isRunning() const;
    QString statusMessage() const;
    int requestCount() const;

    Q_INVOKABLE bool startServer();
    Q_INVOKABLE void stopServer();
    Q_INVOKABLE QString selectFolder();

signals:
    void folderPathChanged();
    void portChanged();
    void isRunningChanged();
    void statusMessageChanged();
    void requestCountChanged();
    void logMessage(const QString &message);

private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();

private:
    void handleRequest(QTcpSocket *socket, const QByteArray &requestData);
    void sendResponse(QTcpSocket *socket, int statusCode, const QString &statusText,
                      const QString &contentType, const QByteArray &body);
    void sendErrorResponse(QTcpSocket *socket, int statusCode, const QString &statusText,
                           const QString &message);
    QString getMimeType(const QString &filePath);
    void setStatusMessage(const QString &message);

    QTcpServer *m_server;
    QString m_folderPath;
    int m_port;
    bool m_isRunning;
    QString m_statusMessage;
    int m_requestCount;
};

#endif // FOLDERHTTPSERVER_H
