#ifndef UPDATECHECKER_H
#define UPDATECHECKER_H

#include <QByteArray>
#include <QNetworkAccessManager>
#include <QPointer>
#include <QString>
#include <QTimer>
#include <QUrl>

class QNetworkReply;

class UpdateChecker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool checking READ checking NOTIFY checkingChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString latestVersion READ latestVersion NOTIFY resultChanged)
    Q_PROPERTY(bool updateAvailable READ updateAvailable NOTIFY resultChanged)
    Q_PROPERTY(QUrl downloadUrl READ downloadUrl NOTIFY resultChanged)

public:
    struct UpdateInfo {
        QString version;
        QUrl downloadUrl;

        bool isValid() const { return !version.isEmpty(); }
    };

    explicit UpdateChecker(QObject *parent = nullptr);

    bool checking() const;
    QString status() const;
    QString latestVersion() const;
    bool updateAvailable() const;
    QUrl downloadUrl() const;

    Q_INVOKABLE void checkForUpdates();

    static bool isVersionNewer(const QString &candidate, const QString &current);
    static UpdateInfo parseVersionResponse(const QByteArray &payload,
                                           const QString &platform,
                                           const QString &architecture);

signals:
    void checkingChanged();
    void statusChanged();
    void resultChanged();

private:
    void requestCurrentEndpoint();
    void advanceRequest();
    void finishWithError();
    void setChecking(bool checking);
    void setStatus(const QString &status);
    static QString currentPlatform();
    static QString currentArchitecture();

    QNetworkAccessManager m_networkManager;
    QPointer<QNetworkReply> m_reply;
    QTimer m_timeoutTimer;
    int m_endpointIndex = 0;
    int m_attempt = 0;
    bool m_checking = false;
    QString m_status = QStringLiteral("idle");
    QString m_latestVersion;
    bool m_updateAvailable = false;
    QUrl m_downloadUrl;
};

#endif
