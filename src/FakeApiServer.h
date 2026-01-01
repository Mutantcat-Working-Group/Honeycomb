#ifndef FAKEAPISERVER_H
#define FAKEAPISERVER_H

#include <QObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

class FakeApiServer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(int requestCount READ requestCount NOTIFY requestCountChanged)
    Q_PROPERTY(QVariantList routes READ routes NOTIFY routesChanged)
    Q_PROPERTY(int selectedIndex READ selectedIndex WRITE setSelectedIndex NOTIFY selectedIndexChanged)

public:
    explicit FakeApiServer(QObject *parent = nullptr);
    ~FakeApiServer();

    int port() const;
    void setPort(int port);

    bool isRunning() const;
    QString statusMessage() const;
    int requestCount() const;
    
    QVariantList routes() const;
    int selectedIndex() const;
    void setSelectedIndex(int index);

    Q_INVOKABLE bool startServer();
    Q_INVOKABLE void stopServer();
    
    // 路由管理
    Q_INVOKABLE void addRoute(const QString &path);
    Q_INVOKABLE void removeRoute(int index);
    Q_INVOKABLE void updateRoute(int index, const QVariantMap &routeData);
    Q_INVOKABLE QVariantMap getRoute(int index) const;
    Q_INVOKABLE void clearRoutes();
    
    // 导入导出
    Q_INVOKABLE QString exportRoutes() const;
    Q_INVOKABLE bool importRoutes(const QString &json);
    Q_INVOKABLE bool exportToFile(const QString &filePath) const;
    Q_INVOKABLE bool importFromFile(const QString &filePath);
    Q_INVOKABLE QString selectExportFile();
    Q_INVOKABLE QString selectImportFile();

signals:
    void portChanged();
    void isRunningChanged();
    void statusMessageChanged();
    void requestCountChanged();
    void routesChanged();
    void selectedIndexChanged();
    void logMessage(const QString &message);

private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();

private:
    void handleRequest(QTcpSocket *socket, const QByteArray &requestData);
    void sendResponse(QTcpSocket *socket, int statusCode, const QString &statusText,
                      const QString &contentType, const QByteArray &body,
                      const QMap<QString, QString> &extraHeaders = {});
    void sendErrorResponse(QTcpSocket *socket, int statusCode, const QString &message);
    void setStatusMessage(const QString &message);
    QString getMimeTypeForResponseType(const QString &responseType) const;
    int findMatchingRoute(const QString &method, const QString &path);

    QTcpServer *m_server;
    int m_port;
    bool m_isRunning;
    QString m_statusMessage;
    int m_requestCount;
    QVariantList m_routes;
    int m_selectedIndex;
};

#endif // FAKEAPISERVER_H
