#include "RestfulTest.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QHttpMultiPart>
#include <QDateTime>
#include <QDebug>

RestfulTest::RestfulTest(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_currentReply(nullptr)
    , m_requestUrl("https://httpbin.org/get")
    , m_method("GET")
    , m_headers("")
    , m_body("")
    , m_contentType("application/json")
    , m_statusCode(0)
    , m_response("")
    , m_responseHeaders("")
    , m_isLoading(false)
{
}

RestfulTest::~RestfulTest()
{
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
    }
}

QString RestfulTest::requestUrl() const
{
    return m_requestUrl;
}

void RestfulTest::setRequestUrl(const QString &url)
{
    if (m_requestUrl != url) {
        m_requestUrl = url;
        emit requestUrlChanged();
    }
}

QString RestfulTest::method() const
{
    return m_method;
}

void RestfulTest::setMethod(const QString &method)
{
    if (m_method != method) {
        m_method = method;
        emit methodChanged();
    }
}

QString RestfulTest::headers() const
{
    return m_headers;
}

void RestfulTest::setHeaders(const QString &headers)
{
    if (m_headers != headers) {
        m_headers = headers;
        emit headersChanged();
    }
}

QString RestfulTest::body() const
{
    return m_body;
}

void RestfulTest::setBody(const QString &body)
{
    if (m_body != body) {
        m_body = body;
        emit bodyChanged();
    }
}

QString RestfulTest::contentType() const
{
    return m_contentType;
}

void RestfulTest::setContentType(const QString &contentType)
{
    if (m_contentType != contentType) {
        m_contentType = contentType;
        emit contentTypeChanged();
    }
}

int RestfulTest::statusCode() const
{
    return m_statusCode;
}

QString RestfulTest::response() const
{
    return m_response;
}

QString RestfulTest::responseHeaders() const
{
    return m_responseHeaders;
}

bool RestfulTest::isLoading() const
{
    return m_isLoading;
}

void RestfulTest::sendRequest()
{
    if (m_requestUrl.isEmpty()) {
        m_response = "错误: 请求URL不能为空";
        emit responseChanged();
        return;
    }

    // 取消当前请求
    if (m_currentReply) {
        m_currentReply->abort();
        m_currentReply->deleteLater();
        m_currentReply = nullptr;
    }

    // 设置加载状态
    m_isLoading = true;
    emit isLoadingChanged();

    // 创建请求
    QNetworkRequest request;
    request.setUrl(QUrl(m_requestUrl));

    // 解析请求头
    parseHeaders(m_headers, request);

    // 设置内容类型
    if (!m_body.isEmpty()) {
        request.setHeader(QNetworkRequest::ContentTypeHeader, m_contentType);
    }

    // 发送请求
    QByteArray requestData = m_body.toUtf8();
    
    if (m_method == "GET") {
        m_currentReply = m_networkManager->get(request);
    } else if (m_method == "POST") {
        m_currentReply = m_networkManager->post(request, requestData);
    } else if (m_method == "PUT") {
        m_currentReply = m_networkManager->put(request, requestData);
    } else if (m_method == "DELETE") {
        if (!m_body.isEmpty()) {
            m_currentReply = m_networkManager->sendCustomRequest(request, "DELETE", requestData);
        } else {
            m_currentReply = m_networkManager->deleteResource(request);
        }
    } else if (m_method == "PATCH") {
        m_currentReply = m_networkManager->sendCustomRequest(request, "PATCH", requestData);
    } else if (m_method == "HEAD") {
        m_currentReply = m_networkManager->head(request);
    } else if (m_method == "OPTIONS") {
        m_currentReply = m_networkManager->sendCustomRequest(request, "OPTIONS");
    } else {
        m_currentReply = m_networkManager->get(request);
    }

    // 连接信号
    connect(m_currentReply, &QNetworkReply::finished, this, &RestfulTest::onRequestFinished);
    connect(m_currentReply, QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
            this, &RestfulTest::onRequestError);
}

void RestfulTest::clearResponse()
{
    m_statusCode = 0;
    m_response = "";
    m_responseHeaders = "";
    
    emit statusCodeChanged();
    emit responseChanged();
    emit responseHeadersChanged();
}

void RestfulTest::onRequestFinished()
{
    if (!m_currentReply) {
        return;
    }

    // 获取状态码
    m_statusCode = m_currentReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    
    // 获取响应头
    QList<QPair<QByteArray, QByteArray>> headersList = m_currentReply->rawHeaderPairs();
    m_responseHeaders = formatHeaders(headersList);
    
    // 获取响应体
    QByteArray responseData = m_currentReply->readAll();
    m_response = QString::fromUtf8(responseData);
    
    // 清理
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
    
    // 设置加载状态
    m_isLoading = false;
    
    // 发送信号
    emit statusCodeChanged();
    emit responseChanged();
    emit responseHeadersChanged();
    emit isLoadingChanged();
}

void RestfulTest::onRequestError(QNetworkReply::NetworkError error)
{
    Q_UNUSED(error)
    
    if (!m_currentReply) {
        return;
    }
    
    m_statusCode = 0;
    m_response = "网络错误: " + m_currentReply->errorString();
    m_responseHeaders = "";
    
    // 清理
    m_currentReply->deleteLater();
    m_currentReply = nullptr;
    
    // 设置加载状态
    m_isLoading = false;
    
    // 发送信号
    emit statusCodeChanged();
    emit responseChanged();
    emit responseHeadersChanged();
    emit isLoadingChanged();
}

void RestfulTest::parseHeaders(const QString &headersText, QNetworkRequest &request)
{
    QStringList lines = headersText.split('\n', Qt::SkipEmptyParts);
    
    for (const QString &line : lines) {
        QStringList parts = line.split(':', Qt::SkipEmptyParts);
        if (parts.size() >= 2) {
            QString key = parts[0].trimmed();
            QString value = parts[1].trimmed();
            
            // 处理多行头
            for (int i = 2; i < parts.size(); ++i) {
                value += ":" + parts[i].trimmed();
            }
            
            request.setRawHeader(key.toUtf8(), value.toUtf8());
        }
    }
}

QString RestfulTest::formatHeaders(const QList<QPair<QByteArray, QByteArray>> &headersList)
{
    QString result;
    
    for (const auto &header : headersList) {
        result += QString("%1: %2\n").arg(QString::fromUtf8(header.first), 
                                         QString::fromUtf8(header.second));
    }
    
    return result.trimmed();
}