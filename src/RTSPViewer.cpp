#include "RTSPViewer.h"

RTSPViewer::RTSPViewer(QObject *parent)
    : QObject(parent)
    , m_rtspUrl("rtsp://")
    , m_transportProtocol("tcp")
    , m_statusMessage(tr("准备就绪"))
{
}

void RTSPViewer::setRtspUrl(const QString &url)
{
    if (m_rtspUrl != url) {
        m_rtspUrl = url;
        emit rtspUrlChanged();
    }
}

void RTSPViewer::setTransportProtocol(const QString &protocol)
{
    if (m_transportProtocol != protocol) {
        m_transportProtocol = protocol;
        emit transportProtocolChanged();
    }
}

void RTSPViewer::updateStatus(const QString &message)
{
    m_statusMessage = message;
    emit statusMessageChanged();
}