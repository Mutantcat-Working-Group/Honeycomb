#ifndef RTSPVIEWER_H
#define RTSPVIEWER_H

#include <QObject>
#include <QString>

class RTSPViewer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString rtspUrl READ rtspUrl WRITE setRtspUrl NOTIFY rtspUrlChanged)
    Q_PROPERTY(QString transportProtocol READ transportProtocol WRITE setTransportProtocol NOTIFY transportProtocolChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)

public:
    explicit RTSPViewer(QObject *parent = nullptr);

    QString rtspUrl() const { return m_rtspUrl; }
    void setRtspUrl(const QString &url);

    QString transportProtocol() const { return m_transportProtocol; }
    void setTransportProtocol(const QString &protocol);

    QString statusMessage() const { return m_statusMessage; }

    Q_INVOKABLE void updateStatus(const QString &message);

signals:
    void rtspUrlChanged();
    void transportProtocolChanged();
    void statusMessageChanged();

private:
    
    QString m_rtspUrl;
    QString m_transportProtocol;
    QString m_statusMessage;
};

#endif // RTSPVIEWER_H
