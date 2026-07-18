#ifndef SERIALPORTTOOL_H
#define SERIALPORTTOOL_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>

class QSerialPort;

// 串口调试工具后端
// 基于 Qt SerialPort 模块，提供端口扫描、打开/关闭、收发数据(HEX/文本)、日志等能力
class SerialPortTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QString portName READ portName WRITE setPortName NOTIFY portNameChanged)
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)
    Q_PROPERTY(int dataBits READ dataBits WRITE setDataBits NOTIFY dataBitsChanged)
    Q_PROPERTY(int stopBits READ stopBits WRITE setStopBits NOTIFY stopBitsChanged)
    Q_PROPERTY(QString parity READ parity WRITE setParity NOTIFY parityChanged)
    Q_PROPERTY(bool isOpen READ isOpen NOTIFY isOpenChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    Q_PROPERTY(QString receiveLog READ receiveLog NOTIFY receiveLogChanged)
    // 显示/输入模式
    Q_PROPERTY(bool hexReceive READ hexReceive WRITE setHexReceive NOTIFY hexReceiveChanged)
    Q_PROPERTY(bool showTimestamp READ showTimestamp WRITE setShowTimestamp NOTIFY showTimestampChanged)
    // 统计
    Q_PROPERTY(qint64 rxBytes READ rxBytes NOTIFY rxBytesChanged)
    Q_PROPERTY(qint64 txBytes READ txBytes NOTIFY txBytesChanged)

public:
    explicit SerialPortTool(QObject *parent = nullptr);
    ~SerialPortTool();

    QStringList availablePorts() const { return m_availablePorts; }

    QString portName() const { return m_portName; }
    void setPortName(const QString &name);

    int baudRate() const { return m_baudRate; }
    void setBaudRate(int rate);

    int dataBits() const { return m_dataBits; }
    void setDataBits(int bits);

    int stopBits() const { return m_stopBits; }
    void setStopBits(int bits);

    QString parity() const { return m_parity; }
    void setParity(const QString &parity);

    bool isOpen() const { return m_isOpen; }
    QString statusText() const { return m_statusText; }
    QString receiveLog() const { return m_receiveLog; }

    bool hexReceive() const { return m_hexReceive; }
    void setHexReceive(bool hex);

    bool showTimestamp() const { return m_showTimestamp; }
    void setShowTimestamp(bool show);

    qint64 rxBytes() const { return m_rxBytes; }
    qint64 txBytes() const { return m_txBytes; }

    // 刷新可用串口列表
    Q_INVOKABLE void refreshPorts();
    // 打开 / 关闭串口
    Q_INVOKABLE void open();
    Q_INVOKABLE void close();
    // 发送数据；hex=true 时按十六进制字符串解析；appendNewline 追加 \r\n
    Q_INVOKABLE void sendData(const QString &text, bool hex, bool appendNewline);
    // 定时循环发送控制
    Q_INVOKABLE void startAutoSend(const QString &text, bool hex, bool appendNewline, int intervalMs);
    Q_INVOKABLE void stopAutoSend();
    // 清空接收日志与统计
    Q_INVOKABLE void clearLog();
    Q_INVOKABLE void resetCounters();

signals:
    void availablePortsChanged();
    void portNameChanged();
    void baudRateChanged();
    void dataBitsChanged();
    void stopBitsChanged();
    void parityChanged();
    void isOpenChanged();
    void statusTextChanged();
    void receiveLogChanged();
    void hexReceiveChanged();
    void showTimestampChanged();
    void rxBytesChanged();
    void txBytesChanged();

private slots:
    void handleReadyRead();
    void handleErrorOccurred(int error);

private:
    void appendLog(const QString &line);
    void setStatus(const QString &text);
    void applyPortSettings();
    static QByteArray parseHex(const QString &text, bool *ok);

    QSerialPort *m_port;
    QTimer *m_autoSendTimer;
    // 定时发送缓存参数
    QString m_autoText;
    bool m_autoHex;
    bool m_autoNewline;

    QStringList m_availablePorts;
    QString m_portName;
    int m_baudRate;
    int m_dataBits;
    int m_stopBits;
    QString m_parity;
    bool m_isOpen;
    QString m_statusText;
    QString m_receiveLog;
    bool m_hexReceive;
    bool m_showTimestamp;
    qint64 m_rxBytes;
    qint64 m_txBytes;

    static const int MAX_LOG_LENGTH = 200000;
};

#endif // SERIALPORTTOOL_H
