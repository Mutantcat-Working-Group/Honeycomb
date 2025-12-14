#ifndef RESTFULTEST_H
#define RESTFULTEST_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class RestfulTest : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString requestUrl READ requestUrl WRITE setRequestUrl NOTIFY requestUrlChanged)
    Q_PROPERTY(QString method READ method WRITE setMethod NOTIFY methodChanged)
    Q_PROPERTY(QString headers READ headers WRITE setHeaders NOTIFY headersChanged)
    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(QString contentType READ contentType WRITE setContentType NOTIFY contentTypeChanged)
    Q_PROPERTY(int statusCode READ statusCode NOTIFY statusCodeChanged)
    Q_PROPERTY(QString response READ response NOTIFY responseChanged)
    Q_PROPERTY(QString responseHeaders READ responseHeaders NOTIFY responseHeadersChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit RestfulTest(QObject *parent = nullptr);
    ~RestfulTest();

    QString requestUrl() const;
    void setRequestUrl(const QString &url);

    QString method() const;
    void setMethod(const QString &method);

    QString headers() const;
    void setHeaders(const QString &headers);

    QString body() const;
    void setBody(const QString &body);

    QString contentType() const;
    void setContentType(const QString &contentType);

    int statusCode() const;
    QString response() const;
    QString responseHeaders() const;
    bool isLoading() const;

    Q_INVOKABLE void sendRequest();
    Q_INVOKABLE void clearResponse();

signals:
    void requestUrlChanged();
    void methodChanged();
    void headersChanged();
    void bodyChanged();
    void contentTypeChanged();
    void statusCodeChanged();
    void responseChanged();
    void responseHeadersChanged();
    void isLoadingChanged();

private slots:
    void onRequestFinished();
    void onRequestError(QNetworkReply::NetworkError error);

private:
    void parseHeaders(const QString &headersText, QNetworkRequest &request);
    QString formatHeaders(const QList<QPair<QByteArray, QByteArray>> &headersList);
    void appendLog(const QString &message, bool isRequest = false);

    QNetworkAccessManager *m_networkManager;
    QNetworkReply *m_currentReply;
    
    QString m_requestUrl;
    QString m_method;
    QString m_headers;
    QString m_body;
    QString m_contentType;
    
    int m_statusCode;
    QString m_response;
    QString m_responseHeaders;
    bool m_isLoading;
};

#endif // RESTFULTEST_H