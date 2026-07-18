#include "SerialPortTool.h"

#include <QSerialPort>
#include <QSerialPortInfo>
#include <QDateTime>

SerialPortTool::SerialPortTool(QObject *parent)
    : QObject(parent)
    , m_port(new QSerialPort(this))
    , m_autoSendTimer(new QTimer(this))
    , m_autoHex(false)
    , m_autoNewline(false)
    , m_baudRate(9600)
    , m_dataBits(8)
    , m_stopBits(1)
    , m_parity("None")
    , m_isOpen(false)
    , m_hexReceive(false)
    , m_showTimestamp(true)
    , m_rxBytes(0)
    , m_txBytes(0)
{
    connect(m_port, &QSerialPort::readyRead, this, &SerialPortTool::handleReadyRead);
    connect(m_port, &QSerialPort::errorOccurred, this, [this](QSerialPort::SerialPortError e) {
        handleErrorOccurred(static_cast<int>(e));
    });

    m_autoSendTimer->setSingleShot(false);
    connect(m_autoSendTimer, &QTimer::timeout, this, [this]() {
        sendData(m_autoText, m_autoHex, m_autoNewline);
    });

    m_statusText = QStringLiteral("未连接");
    refreshPorts();
}

SerialPortTool::~SerialPortTool()
{
    if (m_port && m_port->isOpen()) {
        m_port->close();
    }
}

void SerialPortTool::refreshPorts()
{
    QStringList ports;
    const auto infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : infos) {
        ports << info.portName();
    }
    if (ports != m_availablePorts) {
        m_availablePorts = ports;
        emit availablePortsChanged();
    }
    // 若当前选择的端口已不存在，默认选第一个
    if (!m_availablePorts.contains(m_portName) && !m_availablePorts.isEmpty()) {
        setPortName(m_availablePorts.first());
    }
}

void SerialPortTool::setPortName(const QString &name)
{
    if (m_portName == name)
        return;
    m_portName = name;
    emit portNameChanged();
}

void SerialPortTool::setBaudRate(int rate)
{
    if (m_baudRate == rate)
        return;
    m_baudRate = rate;
    if (m_isOpen)
        m_port->setBaudRate(rate);
    emit baudRateChanged();
}

void SerialPortTool::setDataBits(int bits)
{
    if (m_dataBits == bits)
        return;
    m_dataBits = bits;
    if (m_isOpen)
        m_port->setDataBits(static_cast<QSerialPort::DataBits>(bits));
    emit dataBitsChanged();
}

void SerialPortTool::setStopBits(int bits)
{
    if (m_stopBits == bits)
        return;
    m_stopBits = bits;
    if (m_isOpen)
        m_port->setStopBits(static_cast<QSerialPort::StopBits>(bits));
    emit stopBitsChanged();
}

void SerialPortTool::setParity(const QString &parity)
{
    if (m_parity == parity)
        return;
    m_parity = parity;
    if (m_isOpen)
        applyPortSettings();
    emit parityChanged();
}

void SerialPortTool::setHexReceive(bool hex)
{
    if (m_hexReceive == hex)
        return;
    m_hexReceive = hex;
    emit hexReceiveChanged();
}

void SerialPortTool::setShowTimestamp(bool show)
{
    if (m_showTimestamp == show)
        return;
    m_showTimestamp = show;
    emit showTimestampChanged();
}

void SerialPortTool::applyPortSettings()
{
    m_port->setBaudRate(m_baudRate);
    m_port->setDataBits(static_cast<QSerialPort::DataBits>(m_dataBits));
    m_port->setStopBits(static_cast<QSerialPort::StopBits>(m_stopBits));

    QSerialPort::Parity parity = QSerialPort::NoParity;
    if (m_parity == QStringLiteral("Even"))
        parity = QSerialPort::EvenParity;
    else if (m_parity == QStringLiteral("Odd"))
        parity = QSerialPort::OddParity;
    else if (m_parity == QStringLiteral("Mark"))
        parity = QSerialPort::MarkParity;
    else if (m_parity == QStringLiteral("Space"))
        parity = QSerialPort::SpaceParity;
    m_port->setParity(parity);

    m_port->setFlowControl(QSerialPort::NoFlowControl);
}

void SerialPortTool::open()
{
    if (m_isOpen)
        return;

    if (m_portName.isEmpty()) {
        setStatus(QStringLiteral("请先选择串口"));
        return;
    }

    m_port->setPortName(m_portName);
    applyPortSettings();

    if (m_port->open(QIODevice::ReadWrite)) {
        m_isOpen = true;
        emit isOpenChanged();
        setStatus(QStringLiteral("已连接"));
        appendLog(QStringLiteral("[系统] 串口已打开: %1").arg(m_portName));
    } else {
        setStatus(QStringLiteral("打开失败: %1").arg(m_port->errorString()));
        appendLog(QStringLiteral("[错误] 打开串口失败: %1").arg(m_port->errorString()));
    }
}

void SerialPortTool::close()
{
    stopAutoSend();
    if (m_port->isOpen())
        m_port->close();
    if (m_isOpen) {
        m_isOpen = false;
        emit isOpenChanged();
    }
    setStatus(QStringLiteral("未连接"));
    appendLog(QStringLiteral("[系统] 串口已关闭"));
}

QByteArray SerialPortTool::parseHex(const QString &text, bool *ok)
{
    // 去除空格、逗号、0x 前缀等常见分隔符
    QString cleaned;
    cleaned.reserve(text.size());
    for (const QChar &c : text) {
        if (c.isSpace() || c == QLatin1Char(',') || c == QLatin1Char(';'))
            continue;
        cleaned.append(c);
    }
    if (cleaned.startsWith(QStringLiteral("0x"), Qt::CaseInsensitive))
        cleaned.remove(0, 2);

    if (cleaned.size() % 2 != 0) {
        if (ok) *ok = false;
        return QByteArray();
    }
    QByteArray out = QByteArray::fromHex(cleaned.toLatin1());
    // fromHex 遇到非法字符会跳过，长度不匹配则视为失败
    if (out.size() != cleaned.size() / 2) {
        if (ok) *ok = false;
        return QByteArray();
    }
    if (ok) *ok = true;
    return out;
}

void SerialPortTool::sendData(const QString &text, bool hex, bool appendNewline)
{
    if (!m_isOpen) {
        setStatus(QStringLiteral("串口未打开，无法发送"));
        return;
    }

    QByteArray data;
    if (hex) {
        bool ok = false;
        data = parseHex(text, &ok);
        if (!ok) {
            appendLog(QStringLiteral("[错误] HEX 格式无效: %1").arg(text));
            return;
        }
    } else {
        data = text.toUtf8();
    }

    if (appendNewline)
        data.append("\r\n");

    qint64 written = m_port->write(data);
    if (written < 0) {
        appendLog(QStringLiteral("[错误] 发送失败: %1").arg(m_port->errorString()));
        return;
    }
    m_port->flush();
    m_txBytes += written;
    emit txBytesChanged();

    QString shown = m_hexReceive ? QString::fromLatin1(data.toHex(' ')).toUpper()
                                 : QString::fromUtf8(data);
    appendLog(QStringLiteral("[发送] %1").arg(shown));
}

void SerialPortTool::startAutoSend(const QString &text, bool hex, bool appendNewline, int intervalMs)
{
    if (!m_isOpen) {
        setStatus(QStringLiteral("串口未打开，无法定时发送"));
        return;
    }
    if (intervalMs < 10)
        intervalMs = 10;
    m_autoText = text;
    m_autoHex = hex;
    m_autoNewline = appendNewline;
    m_autoSendTimer->start(intervalMs);
    appendLog(QStringLiteral("[系统] 开始定时发送，间隔 %1 ms").arg(intervalMs));
}

void SerialPortTool::stopAutoSend()
{
    if (m_autoSendTimer->isActive()) {
        m_autoSendTimer->stop();
        appendLog(QStringLiteral("[系统] 停止定时发送"));
    }
}

void SerialPortTool::handleReadyRead()
{
    const QByteArray data = m_port->readAll();
    if (data.isEmpty())
        return;

    m_rxBytes += data.size();
    emit rxBytesChanged();

    QString shown = m_hexReceive ? QString::fromLatin1(data.toHex(' ')).toUpper()
                                 : QString::fromUtf8(data);
    appendLog(QStringLiteral("[接收] %1").arg(shown));
}

void SerialPortTool::handleErrorOccurred(int error)
{
    // QSerialPort::NoError == 0
    if (error == QSerialPort::NoError)
        return;
    // 资源错误(如设备被拔出)时自动关闭
    if (error == QSerialPort::ResourceError) {
        appendLog(QStringLiteral("[错误] 设备连接中断"));
        close();
    }
}

void SerialPortTool::clearLog()
{
    if (!m_receiveLog.isEmpty()) {
        m_receiveLog.clear();
        emit receiveLogChanged();
    }
}

void SerialPortTool::resetCounters()
{
    m_rxBytes = 0;
    m_txBytes = 0;
    emit rxBytesChanged();
    emit txBytesChanged();
}

void SerialPortTool::appendLog(const QString &line)
{
    QString entry;
    if (m_showTimestamp)
        entry = QStringLiteral("[%1] %2\n")
                    .arg(QDateTime::currentDateTime().toString(QStringLiteral("HH:mm:ss.zzz")))
                    .arg(line);
    else
        entry = line + QLatin1Char('\n');

    m_receiveLog += entry;
    // 限制日志长度，防止无限增长
    if (m_receiveLog.size() > MAX_LOG_LENGTH)
        m_receiveLog = m_receiveLog.right(MAX_LOG_LENGTH * 3 / 4);

    emit receiveLogChanged();
}

void SerialPortTool::setStatus(const QString &text)
{
    if (m_statusText == text)
        return;
    m_statusText = text;
    emit statusTextChanged();
}
