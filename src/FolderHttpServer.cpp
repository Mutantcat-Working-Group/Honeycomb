#include "FolderHttpServer.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QMimeDatabase>
#include <QDateTime>
#include <QFileDialog>
#include <QUrl>

FolderHttpServer::FolderHttpServer(QObject *parent)
    : QObject(parent)
    , m_server(new QTcpServer(this))
    , m_port(8080)
    , m_isRunning(false)
    , m_requestCount(0)
{
    connect(m_server, &QTcpServer::newConnection, this, &FolderHttpServer::onNewConnection);
}

FolderHttpServer::~FolderHttpServer()
{
    stopServer();
}

QString FolderHttpServer::folderPath() const
{
    return m_folderPath;
}

void FolderHttpServer::setFolderPath(const QString &path)
{
    QString localPath = path;
    // 处理 file:/// URL 格式
    if (localPath.startsWith("file:///")) {
        localPath = QUrl(localPath).toLocalFile();
    }
    
    if (m_folderPath != localPath) {
        m_folderPath = localPath;
        emit folderPathChanged();
    }
}

int FolderHttpServer::port() const
{
    return m_port;
}

void FolderHttpServer::setPort(int port)
{
    if (m_port != port && port > 0 && port < 65536) {
        m_port = port;
        emit portChanged();
    }
}

bool FolderHttpServer::isRunning() const
{
    return m_isRunning;
}

QString FolderHttpServer::statusMessage() const
{
    return m_statusMessage;
}

int FolderHttpServer::requestCount() const
{
    return m_requestCount;
}

void FolderHttpServer::setStatusMessage(const QString &message)
{
    if (m_statusMessage != message) {
        m_statusMessage = message;
        emit statusMessageChanged();
    }
}

bool FolderHttpServer::startServer()
{
    if (m_isRunning) {
        setStatusMessage("服务器已在运行中");
        return true;
    }

    if (m_folderPath.isEmpty()) {
        setStatusMessage("请先选择要映射的文件夹");
        emit logMessage("[错误] 未选择文件夹");
        return false;
    }

    QDir dir(m_folderPath);
    if (!dir.exists()) {
        setStatusMessage("选择的文件夹不存在");
        emit logMessage("[错误] 文件夹不存在: " + m_folderPath);
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

    QString successMsg = QString("服务器已启动 - http://localhost:%1").arg(m_port);
    setStatusMessage(successMsg);
    emit logMessage(QString("[启动] %1").arg(QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss")));
    emit logMessage(QString("[信息] 映射文件夹: %1").arg(m_folderPath));
    emit logMessage(QString("[信息] 访问地址: http://localhost:%1").arg(m_port));

    return true;
}

void FolderHttpServer::stopServer()
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

QString FolderHttpServer::selectFolder()
{
    QString folder = QFileDialog::getExistingDirectory(nullptr, "选择要映射的文件夹", 
                                                        m_folderPath.isEmpty() ? QDir::homePath() : m_folderPath);
    if (!folder.isEmpty()) {
        setFolderPath(folder);
    }
    return folder;
}

void FolderHttpServer::onNewConnection()
{
    while (m_server->hasPendingConnections()) {
        QTcpSocket *socket = m_server->nextPendingConnection();
        connect(socket, &QTcpSocket::readyRead, this, &FolderHttpServer::onReadyRead);
        connect(socket, &QTcpSocket::disconnected, this, &FolderHttpServer::onDisconnected);
    }
}

void FolderHttpServer::onReadyRead()
{
    QTcpSocket *socket = qobject_cast<QTcpSocket*>(sender());
    if (!socket) return;

    QByteArray requestData = socket->readAll();
    handleRequest(socket, requestData);
}

void FolderHttpServer::onDisconnected()
{
    QTcpSocket *socket = qobject_cast<QTcpSocket*>(sender());
    if (socket) {
        socket->deleteLater();
    }
}

void FolderHttpServer::handleRequest(QTcpSocket *socket, const QByteArray &requestData)
{
    // 解析请求行
    QString request = QString::fromUtf8(requestData);
    QStringList lines = request.split("\r\n");
    if (lines.isEmpty()) {
        sendErrorResponse(socket, 400, "Bad Request", "无效的请求");
        return;
    }

    QStringList requestLine = lines[0].split(' ');
    if (requestLine.size() < 3) {
        sendErrorResponse(socket, 400, "Bad Request", "无效的请求行");
        return;
    }

    QString method = requestLine[0];
    QString path = requestLine[1];

    // 只支持 GET 和 HEAD 请求
    if (method != "GET" && method != "HEAD") {
        sendErrorResponse(socket, 405, "Method Not Allowed", "只支持 GET 和 HEAD 请求");
        return;
    }

    // URL 解码
    path = QUrl::fromPercentEncoding(path.toUtf8());

    // 安全检查：防止目录遍历攻击
    if (path.contains("..") || path.contains("//")) {
        sendErrorResponse(socket, 403, "Forbidden", "禁止访问");
        emit logMessage(QString("[拒绝] %1 - 安全检查失败").arg(path));
        return;
    }

    // 去除开头的 '/'
    QString relativePath = path.mid(1);
    
    // 构建完整文件路径
    QDir dir(m_folderPath);
    QString filePath = dir.absoluteFilePath(relativePath);
    QFileInfo fileInfo(filePath);

    // 安全检查：确保文件在目标文件夹内
    QString canonicalDir = dir.canonicalPath();
    QString canonicalFile = fileInfo.canonicalFilePath();
    if (!canonicalFile.isEmpty() && !canonicalFile.startsWith(canonicalDir)) {
        sendErrorResponse(socket, 403, "Forbidden", "禁止访问");
        emit logMessage(QString("[拒绝] %1 - 越权访问").arg(path));
        return;
    }

    // 如果请求的是目录
    if (fileInfo.isDir()) {
        // 尝试查找 index.html
        QString indexPath = dir.absoluteFilePath(relativePath + "/index.html");
        QFileInfo indexInfo(indexPath);
        if (indexInfo.exists() && indexInfo.isFile()) {
            filePath = indexPath;
            fileInfo = indexInfo;
        } else {
            // 生成目录列表
            QDir requestedDir(filePath);
            QStringList entries = requestedDir.entryList(QDir::AllEntries | QDir::NoDotAndDotDot, QDir::DirsFirst | QDir::Name);
            
            QString html = QString(
                "<!DOCTYPE html><html><head><meta charset='utf-8'>"
                "<title>目录: %1</title>"
                "<style>"
                "body{font-family:system-ui,-apple-system,sans-serif;max-width:800px;margin:40px auto;padding:0 20px;background:#f5f5f5;}"
                "h1{color:#333;border-bottom:2px solid #1976d2;padding-bottom:10px;}"
                "ul{list-style:none;padding:0;}"
                "li{padding:8px 12px;margin:4px 0;background:white;border-radius:4px;}"
                "li:hover{background:#e3f2fd;}"
                "a{text-decoration:none;color:#1976d2;}"
                ".folder::before{content:'📁 ';}"
                ".file::before{content:'📄 ';}"
                ".back{background:#fff3e0;}"
                "</style></head><body>"
                "<h1>📂 %1</h1><ul>"
            ).arg(path.isEmpty() ? "/" : path);

            // 添加返回上级目录链接
            if (!relativePath.isEmpty()) {
                QString parentPath = relativePath.contains('/') 
                    ? "/" + relativePath.left(relativePath.lastIndexOf('/'))
                    : "/";
                html += QString("<li class='back'><a href='%1'>⬆️ 返回上级目录</a></li>").arg(parentPath);
            }

            for (const QString &entry : entries) {
                QString entryPath = relativePath.isEmpty() ? entry : relativePath + "/" + entry;
                QFileInfo entryInfo(dir.absoluteFilePath(entryPath));
                QString cssClass = entryInfo.isDir() ? "folder" : "file";
                QString displayPath = "/" + entryPath + (entryInfo.isDir() ? "/" : "");
                html += QString("<li class='%1'><a href='%2'>%3</a></li>")
                    .arg(cssClass, displayPath, entry + (entryInfo.isDir() ? "/" : ""));
            }

            html += "</ul></body></html>";
            
            m_requestCount++;
            emit requestCountChanged();
            emit logMessage(QString("[200] %1 %2 (目录列表)").arg(method, path.isEmpty() ? "/" : path));
            
            sendResponse(socket, 200, "OK", "text/html; charset=utf-8", html.toUtf8());
            return;
        }
    }

    // 文件不存在
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        sendErrorResponse(socket, 404, "Not Found", "文件未找到: " + path);
        emit logMessage(QString("[404] %1 %2").arg(method, path));
        return;
    }

    // 读取文件
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        sendErrorResponse(socket, 500, "Internal Server Error", "无法读取文件");
        emit logMessage(QString("[500] %1 %2 - 无法读取").arg(method, path));
        return;
    }

    QByteArray fileData = file.readAll();
    file.close();

    // 获取 MIME 类型
    QString mimeType = getMimeType(filePath);

    m_requestCount++;
    emit requestCountChanged();
    emit logMessage(QString("[200] %1 %2 (%3 bytes)")
        .arg(method, path, QString::number(fileData.size())));

    if (method == "HEAD") {
        // HEAD 请求只返回头部
        QString header = QString(
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: %1\r\n"
            "Content-Length: %2\r\n"
            "Connection: close\r\n"
            "\r\n"
        ).arg(mimeType).arg(fileData.size());
        socket->write(header.toUtf8());
    } else {
        sendResponse(socket, 200, "OK", mimeType, fileData);
    }
    
    socket->disconnectFromHost();
}

void FolderHttpServer::sendResponse(QTcpSocket *socket, int statusCode, const QString &statusText,
                                     const QString &contentType, const QByteArray &body)
{
    QString header = QString(
        "HTTP/1.1 %1 %2\r\n"
        "Content-Type: %3\r\n"
        "Content-Length: %4\r\n"
        "Connection: close\r\n"
        "Server: Honeycomb-FolderServer/1.0\r\n"
        "\r\n"
    ).arg(statusCode).arg(statusText, contentType).arg(body.size());

    socket->write(header.toUtf8());
    socket->write(body);
    socket->disconnectFromHost();
}

void FolderHttpServer::sendErrorResponse(QTcpSocket *socket, int statusCode, 
                                          const QString &statusText, const QString &message)
{
    QString html = QString(
        "<!DOCTYPE html><html><head><meta charset='utf-8'>"
        "<title>%1 %2</title>"
        "<style>body{font-family:system-ui;text-align:center;padding:50px;background:#f5f5f5;}"
        "h1{color:#e74c3c;}</style></head>"
        "<body><h1>%1 %2</h1><p>%3</p></body></html>"
    ).arg(statusCode).arg(statusText, message);

    sendResponse(socket, statusCode, statusText, "text/html; charset=utf-8", html.toUtf8());
}

QString FolderHttpServer::getMimeType(const QString &filePath)
{
    QMimeDatabase mimeDb;
    QMimeType mimeType = mimeDb.mimeTypeForFile(filePath);
    QString mime = mimeType.name();
    
    // 对于文本文件添加 UTF-8 编码
    if (mime.startsWith("text/")) {
        mime += "; charset=utf-8";
    }
    
    return mime.isEmpty() ? "application/octet-stream" : mime;
}
