#include "FakeApiServer.h"
#include <QFile>
#include <QFileInfo>
#include <QDateTime>
#include <QUrl>
#include <QRegularExpression>
#include <QThread>
#include <QFileDialog>
#include <QStandardPaths>

FakeApiServer::FakeApiServer(QObject *parent)
    : QObject(parent)
    , m_server(new QTcpServer(this))
    , m_port(3000)
    , m_isRunning(false)
    , m_requestCount(0)
    , m_selectedIndex(-1)
{
    connect(m_server, &QTcpServer::newConnection, this, &FakeApiServer::onNewConnection);
}

FakeApiServer::~FakeApiServer()
{
    stopServer();
}

int FakeApiServer::port() const
{
    return m_port;
}

void FakeApiServer::setPort(int port)
{
    if (m_port != port && port > 0 && port < 65536) {
        m_port = port;
        emit portChanged();
    }
}

bool FakeApiServer::isRunning() const
{
    return m_isRunning;
}

QString FakeApiServer::statusMessage() const
{
    return m_statusMessage;
}

int FakeApiServer::requestCount() const
{
    return m_requestCount;
}

QVariantList FakeApiServer::routes() const
{
    return m_routes;
}

int FakeApiServer::selectedIndex() const
{
    return m_selectedIndex;
}

void FakeApiServer::setSelectedIndex(int index)
{
    if (m_selectedIndex != index) {
        m_selectedIndex = index;
        emit selectedIndexChanged();
    }
}

void FakeApiServer::setStatusMessage(const QString &message)
{
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
    }
}

bool FakeApiServer::startServer()
{
    if (m_isRunning) {
        setStatusMessage("服务器已在运行中");
        return true;
    }

    if (m_routes.isEmpty()) {
        setStatusMessage("请先添加至少一个路由");
        emit logMessage("[错误] 未配置任何路由");
        return false;
    }

    // 尝试监听端口
    if (!m_server->listen(QHostAddress::Any, m_port)) {
        QString errorMsg;
        if (m_server->serverError() == QAbstractSocket::AddressInUseError) {
            errorMsg = QString("端口 %1 已被占用，请更换其他端口").arg(m_port);
        } else {
            errorMsg = QString("启动失败: %1").arg(m_server->errorString());
        }
        setStatusMessage(errorMsg);
        emit logMessage("[错误] " + errorMsg);
        return false;
    }

    m_isRunning = true;
    m_requestCount = 0;
    emit isRunningChanged();
    emit requestCountChanged();

    QString successMsg = QString("Fake API 已启动 - http://localhost:%1").arg(m_port);
    setStatusMessage(successMsg);
    emit logMessage(QString("[启动] %1").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")));
    emit logMessage(QString("[信息] 监听端口: %1").arg(m_port));
    emit logMessage(QString("[信息] 已配置 %1 个路由").arg(m_routes.size()));

    return true;
}

void FakeApiServer::stopServer()
{
    if (!m_isRunning) {
        return;
    }

    m_server->close();
    m_isRunning = false;
    emit isRunningChanged();

    setStatusMessage("服务器已停止");
    emit logMessage(QString("[停止] %1").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")));
}

void FakeApiServer::addRoute(const QString &path)
{
    QVariantMap route;
    route["path"] = path.isEmpty() ? "/api/new" : path;
    route["methods"] = QVariantList{"GET"};
    route["responseType"] = "json";
    route["statusCode"] = 200;
    route["responseBody"] = "{\n  \"message\": \"Hello from Fake API\",\n  \"success\": true\n}";
    route["contentType"] = "application/json";
    route["delay"] = 0;
    route["enabled"] = true;
    
    m_routes.append(route);
    emit routesChanged();
    
    // 自动选中新添加的路由
    setSelectedIndex(m_routes.size() - 1);
}

void FakeApiServer::removeRoute(int index)
{
    if (index >= 0 && index < m_routes.size()) {
        m_routes.removeAt(index);
        emit routesChanged();
        
        // 调整选中索引
        if (m_selectedIndex >= m_routes.size()) {
            setSelectedIndex(m_routes.size() - 1);
        } else if (m_selectedIndex == index) {
            setSelectedIndex(-1);
        }
    }
}

void FakeApiServer::updateRoute(int index, const QVariantMap &routeData)
{
    if (index >= 0 && index < m_routes.size()) {
        m_routes[index] = routeData;
        emit routesChanged();
    }
}

QVariantMap FakeApiServer::getRoute(int index) const
{
    if (index >= 0 && index < m_routes.size()) {
        return m_routes[index].toMap();
    }
    return QVariantMap();
}

void FakeApiServer::clearRoutes()
{
    m_routes.clear();
    m_selectedIndex = -1;
    emit routesChanged();
    emit selectedIndexChanged();
}

QString FakeApiServer::exportRoutes() const
{
    QJsonArray arr;
    for (const QVariant &route : m_routes) {
        arr.append(QJsonObject::fromVariantMap(route.toMap()));
    }
    QJsonDocument doc(arr);
    return QString::fromUtf8(doc.toJson(QJsonDocument::Indented));
}

bool FakeApiServer::importRoutes(const QString &json)
{
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8(), &error);
    
    if (error.error != QJsonParseError::NoError) {
        emit logMessage("[错误] JSON解析失败: " + error.errorString());
        return false;
    }
    
    if (!doc.isArray()) {
        emit logMessage("[错误] JSON格式错误，需要数组");
        return false;
    }
    
    QJsonArray arr = doc.array();
    m_routes.clear();
    
    for (const QJsonValue &val : arr) {
        if (val.isObject()) {
            m_routes.append(val.toObject().toVariantMap());
        }
    }
    
    emit routesChanged();
    emit logMessage(QString("[信息] 成功导入 %1 个路由").arg(m_routes.size()));
    return true;
}

bool FakeApiServer::exportToFile(const QString &filePath) const
{
    QString localPath = filePath;
    if (localPath.startsWith("file:///")) {
        localPath = QUrl(localPath).toLocalFile();
    }
    
    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }
    
    // 构建导出数据，包含端口配置
    QJsonObject root;
    root["version"] = "1.0";
    root["port"] = m_port;
    
    QJsonArray routesArr;
    for (const QVariant &route : m_routes) {
        routesArr.append(QJsonObject::fromVariantMap(route.toMap()));
    }
    root["routes"] = routesArr;
    
    QJsonDocument doc(root);
    file.write(doc.toJson(QJsonDocument::Indented));
    file.close();
    
    return true;
}

bool FakeApiServer::importFromFile(const QString &filePath)
{
    QString localPath = filePath;
    if (localPath.startsWith("file:///")) {
        localPath = QUrl(localPath).toLocalFile();
    }
    
    QFile file(localPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit logMessage("[错误] 无法打开文件: " + localPath);
        return false;
    }
    
    QByteArray data = file.readAll();
    file.close();
    
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    
    if (error.error != QJsonParseError::NoError) {
        emit logMessage("[错误] 文件解析失败: " + error.errorString());
        return false;
    }
    
    if (!doc.isObject()) {
        // 兼容旧格式（纯数组）
        if (doc.isArray()) {
            return importRoutes(QString::fromUtf8(data));
        }
        emit logMessage("[错误] 文件格式错误");
        return false;
    }
    
    QJsonObject root = doc.object();
    
    // 恢复端口配置
    if (root.contains("port")) {
        int port = root["port"].toInt();
        if (port > 0 && port < 65536) {
            m_port = port;
            emit portChanged();
        }
    }
    
    // 恢复路由
    if (root.contains("routes") && root["routes"].isArray()) {
        QJsonArray arr = root["routes"].toArray();
        m_routes.clear();
        m_selectedIndex = -1;
        
        for (const QJsonValue &val : arr) {
            if (val.isObject()) {
                m_routes.append(val.toObject().toVariantMap());
            }
        }
        
        emit routesChanged();
        emit selectedIndexChanged();
        emit logMessage(QString("[信息] 成功导入 %1 个路由，端口: %2").arg(m_routes.size()).arg(m_port));
        return true;
    }
    
    emit logMessage("[错误] 文件中未找到路由数据");
    return false;
}

QString FakeApiServer::selectExportFile()
{
    QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString filePath = QFileDialog::getSaveFileName(
        nullptr,
        "导出 Fake API 配置",
        defaultPath + "/fake-api-config.fapi",
        "Fake API 配置文件 (*.fapi);;所有文件 (*.*)"
    );
    return filePath;
}

QString FakeApiServer::selectImportFile()
{
    QString defaultPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);
    QString filePath = QFileDialog::getOpenFileName(
        nullptr,
        "导入 Fake API 配置",
        defaultPath,
        "Fake API 配置文件 (*.fapi);;所有文件 (*.*)"
    );
    return filePath;
}

void FakeApiServer::onNewConnection()
{
    while (m_server->hasPendingConnections()) {
        QTcpSocket *socket = m_server->nextPendingConnection();
        connect(socket, &QTcpSocket::readyRead, this, &FakeApiServer::onReadyRead);
        connect(socket, &QTcpSocket::disconnected, this, &FakeApiServer::onDisconnected);
    }
}

void FakeApiServer::onReadyRead()
{
    QTcpSocket *socket = qobject_cast<QTcpSocket*>(sender());
    if (!socket) return;

    QByteArray requestData = socket->readAll();
    handleRequest(socket, requestData);
}

void FakeApiServer::onDisconnected()
{
    QTcpSocket *socket = qobject_cast<QTcpSocket*>(sender());
    if (socket) {
        socket->deleteLater();
    }
}

int FakeApiServer::findMatchingRoute(const QString &method, const QString &path)
{
    for (int i = 0; i < m_routes.size(); ++i) {
        QVariantMap route = m_routes[i].toMap();
        
        if (!route["enabled"].toBool()) {
            continue;
        }
        
        QString routePath = route["path"].toString();
        QVariantList methods = route["methods"].toList();
        
        // 检查方法是否匹配
        bool methodMatch = false;
        for (const QVariant &m : methods) {
            if (m.toString().toUpper() == method.toUpper()) {
                methodMatch = true;
                break;
            }
        }
        if (!methodMatch) continue;
        
        // 简单路径匹配（支持通配符*）
        QString pattern = routePath;
        pattern.replace("*", ".*");
        QRegularExpression regex("^" + pattern + "$");
        if (regex.match(path).hasMatch()) {
            return i;
        }
        
        // 精确匹配
        if (routePath == path) {
            return i;
        }
    }
    return -1;
}

void FakeApiServer::handleRequest(QTcpSocket *socket, const QByteArray &requestData)
{
    // 解析请求行
    QString request = QString::fromUtf8(requestData);
    QStringList lines = request.split("\r\n");
    if (lines.isEmpty()) {
        sendErrorResponse(socket, 400, "Bad Request");
        return;
    }

    QStringList requestLine = lines[0].split(' ');
    if (requestLine.size() < 3) {
        sendErrorResponse(socket, 400, "Bad Request");
        return;
    }

    QString method = requestLine[0].toUpper();
    QString fullPath = requestLine[1];
    
    // 分离路径和查询参数
    QString path = fullPath;
    int queryIndex = fullPath.indexOf('?');
    if (queryIndex >= 0) {
        path = fullPath.left(queryIndex);
    }
    
    // URL 解码
    path = QUrl::fromPercentEncoding(path.toUtf8());

    // 查找匹配的路由
    int matchedIndex = findMatchingRoute(method, path);
    
    if (matchedIndex < 0) {
        // 检查是否有路径匹配但方法不匹配
        for (int i = 0; i < m_routes.size(); ++i) {
            QVariantMap route = m_routes[i].toMap();
            if (route["path"].toString() == path && route["enabled"].toBool()) {
                sendErrorResponse(socket, 405, "Method Not Allowed");
                emit logMessage(QString("[405] %1 %2 - 方法不允许").arg(method, path));
                return;
            }
        }
        
        sendErrorResponse(socket, 404, "Not Found");
        emit logMessage(QString("[404] %1 %2 - 未找到路由").arg(method, path));
        return;
    }

    QVariantMap route = m_routes[matchedIndex].toMap();
    
    // 获取响应配置
    int statusCode = route["statusCode"].toInt();
    QString responseType = route["responseType"].toString();
    QString responseBody = route["responseBody"].toString();
    QString customContentType = route["contentType"].toString();
    int delay = route["delay"].toInt();
    
    // 模拟延迟
    if (delay > 0) {
        QThread::msleep(delay);
    }
    
    // 确定 Content-Type
    QString contentType = customContentType;
    if (contentType.isEmpty()) {
        contentType = getMimeTypeForResponseType(responseType);
    }
    
    QByteArray body;
    
    if (responseType == "file") {
        // 从文件读取响应
        QString filePath = responseBody;
        QFile file(filePath);
        if (file.open(QIODevice::ReadOnly)) {
            body = file.readAll();
            file.close();
        } else {
            sendErrorResponse(socket, 500, "Cannot read response file");
            emit logMessage(QString("[500] %1 %2 - 无法读取文件: %3").arg(method, path, filePath));
            return;
        }
    } else {
        body = responseBody.toUtf8();
    }
    
    // 添加 CORS 头
    QMap<QString, QString> headers;
    headers["Access-Control-Allow-Origin"] = "*";
    headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, PATCH, OPTIONS";
    headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With";
    
    // 处理 OPTIONS 预检请求
    if (method == "OPTIONS") {
        sendResponse(socket, 204, "No Content", "", QByteArray(), headers);
        emit logMessage(QString("[204] %1 %2 - CORS预检").arg(method, path));
        return;
    }
    
    m_requestCount++;
    emit requestCountChanged();
    
    QString statusText = "OK";
    if (statusCode == 201) statusText = "Created";
    else if (statusCode == 204) statusText = "No Content";
    else if (statusCode == 400) statusText = "Bad Request";
    else if (statusCode == 401) statusText = "Unauthorized";
    else if (statusCode == 403) statusText = "Forbidden";
    else if (statusCode == 404) statusText = "Not Found";
    else if (statusCode == 500) statusText = "Internal Server Error";
    
    sendResponse(socket, statusCode, statusText, contentType, body, headers);
    emit logMessage(QString("[%1] %2 %3 (%4 bytes)")
        .arg(statusCode).arg(method, path, QString::number(body.size())));
}

QString FakeApiServer::getMimeTypeForResponseType(const QString &responseType) const
{
    if (responseType == "json") {
        return "application/json; charset=utf-8";
    } else if (responseType == "xml") {
        return "application/xml; charset=utf-8";
    } else if (responseType == "html") {
        return "text/html; charset=utf-8";
    } else if (responseType == "text") {
        return "text/plain; charset=utf-8";
    }
    return "application/octet-stream";
}

void FakeApiServer::sendResponse(QTcpSocket *socket, int statusCode, const QString &statusText,
                                  const QString &contentType, const QByteArray &body,
                                  const QMap<QString, QString> &extraHeaders)
{
    QString header = QString(
        "HTTP/1.1 %1 %2\r\n"
        "Server: Honeycomb-FakeAPI/1.0\r\n"
        "Connection: close\r\n"
    ).arg(statusCode).arg(statusText);
    
    if (!contentType.isEmpty()) {
        header += QString("Content-Type: %1\r\n").arg(contentType);
    }
    
    header += QString("Content-Length: %1\r\n").arg(body.size());
    
    for (auto it = extraHeaders.constBegin(); it != extraHeaders.constEnd(); ++it) {
        header += QString("%1: %2\r\n").arg(it.key(), it.value());
    }
    
    header += "\r\n";

    socket->write(header.toUtf8());
    if (!body.isEmpty()) {
        socket->write(body);
    }
    socket->disconnectFromHost();
}

void FakeApiServer::sendErrorResponse(QTcpSocket *socket, int statusCode, const QString &message)
{
    QString statusText;
    switch (statusCode) {
        case 400: statusText = "Bad Request"; break;
        case 404: statusText = "Not Found"; break;
        case 405: statusText = "Method Not Allowed"; break;
        case 500: statusText = "Internal Server Error"; break;
        default: statusText = "Error"; break;
    }
    
    QJsonObject json;
    json["error"] = true;
    json["status"] = statusCode;
    json["message"] = message;
    
    QByteArray body = QJsonDocument(json).toJson();
    
    QMap<QString, QString> headers;
    headers["Access-Control-Allow-Origin"] = "*";
    
    sendResponse(socket, statusCode, statusText, "application/json; charset=utf-8", body, headers);
}
