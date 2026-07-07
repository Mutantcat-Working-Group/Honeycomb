#include "DNSLookupTool.h"

#include <QDnsLookup>
#include <QDnsDomainNameRecord>
#include <QDnsHostAddressRecord>
#include <QDnsMailExchangeRecord>
#include <QDnsServiceRecord>
#include <QDnsTextRecord>
#include <QHostAddress>

DNSLookupTool::DNSLookupTool(QObject *parent)
    : QObject(parent)
    , m_lookup(new QDnsLookup(this))
    , m_domain("example.com")
    , m_recordType("A")
    , m_isLoading(false)
{
    connect(m_lookup, &QDnsLookup::finished, this, &DNSLookupTool::onFinished);
}

DNSLookupTool::~DNSLookupTool()
{
    if (m_lookup) {
        m_lookup->abort();
    }
}

QString DNSLookupTool::domain() const
{
    return m_domain;
}

void DNSLookupTool::setDomain(const QString &domain)
{
    const QString trimmed = domain.trimmed();
    if (m_domain != trimmed) {
        m_domain = trimmed;
        emit domainChanged();
    }
}

QString DNSLookupTool::recordType() const
{
    return m_recordType;
}

void DNSLookupTool::setRecordType(const QString &recordType)
{
    if (m_recordType != recordType) {
        m_recordType = recordType;
        emit recordTypeChanged();
    }
}

QString DNSLookupTool::result() const
{
    return m_result;
}

QString DNSLookupTool::errorMessage() const
{
    return m_errorMessage;
}

bool DNSLookupTool::isLoading() const
{
    return m_isLoading;
}

void DNSLookupTool::lookup()
{
    if (m_domain.isEmpty()) {
        setErrorMessage("域名不能为空");
        setResult("");
        return;
    }

    m_lookup->abort();
    setResult("");
    setErrorMessage("");
    setIsLoading(true);

    m_lookup->setType(static_cast<QDnsLookup::Type>(dnsType()));
    m_lookup->setName(m_domain);
    m_lookup->lookup();
}

void DNSLookupTool::clear()
{
    m_lookup->abort();
    setIsLoading(false);
    setResult("");
    setErrorMessage("");
}

void DNSLookupTool::onFinished()
{
    setIsLoading(false);

    if (m_lookup->error() != QDnsLookup::NoError) {
        setErrorMessage(m_lookup->errorString());
        setResult("");
        return;
    }

    QStringList lines;
    const QString type = m_recordType.toUpper();

    if (type == "A" || type == "AAAA") {
        const auto records = m_lookup->hostAddressRecords();
        for (const QDnsHostAddressRecord &record : records) {
            lines << QString("%1\tTTL %2\t%3")
                         .arg(record.name(), QString::number(record.timeToLive()), record.value().toString());
        }
    } else if (type == "CNAME") {
        const auto records = m_lookup->canonicalNameRecords();
        for (const QDnsDomainNameRecord &record : records) {
            lines << QString("%1\tTTL %2\t%3")
                         .arg(record.name(), QString::number(record.timeToLive()), record.value());
        }
    } else if (type == "MX") {
        const auto records = m_lookup->mailExchangeRecords();
        for (const QDnsMailExchangeRecord &record : records) {
            lines << QString("%1\tTTL %2\tpriority %3\t%4")
                         .arg(record.name(), QString::number(record.timeToLive()),
                              QString::number(record.preference()), record.exchange());
        }
    } else if (type == "NS") {
        const auto records = m_lookup->nameServerRecords();
        for (const QDnsDomainNameRecord &record : records) {
            lines << QString("%1\tTTL %2\t%3")
                         .arg(record.name(), QString::number(record.timeToLive()), record.value());
        }
    } else if (type == "PTR") {
        const auto records = m_lookup->pointerRecords();
        for (const QDnsDomainNameRecord &record : records) {
            lines << QString("%1\tTTL %2\t%3")
                         .arg(record.name(), QString::number(record.timeToLive()), record.value());
        }
    } else if (type == "SRV") {
        const auto records = m_lookup->serviceRecords();
        for (const QDnsServiceRecord &record : records) {
            lines << QString("%1\tTTL %2\tpriority %3\tweight %4\tport %5\t%6")
                         .arg(record.name(), QString::number(record.timeToLive()),
                              QString::number(record.priority()), QString::number(record.weight()),
                              QString::number(record.port()), record.target());
        }
    } else if (type == "TXT") {
        const auto records = m_lookup->textRecords();
        for (const QDnsTextRecord &record : records) {
            QStringList values;
            const auto chunks = record.values();
            for (const QByteArray &chunk : chunks) {
                values << QString::fromUtf8(chunk);
            }
            lines << QString("%1\tTTL %2\t%3")
                         .arg(record.name(), QString::number(record.timeToLive()), values.join(" "));
        }
    }

    if (lines.isEmpty()) {
        setResult("未查询到记录");
    } else {
        setResult(lines.join("\n"));
    }
}

int DNSLookupTool::dnsType() const
{
    const QString type = m_recordType.toUpper();
    if (type == "AAAA") {
        return QDnsLookup::AAAA;
    }
    if (type == "CNAME") {
        return QDnsLookup::CNAME;
    }
    if (type == "MX") {
        return QDnsLookup::MX;
    }
    if (type == "NS") {
        return QDnsLookup::NS;
    }
    if (type == "PTR") {
        return QDnsLookup::PTR;
    }
    if (type == "SRV") {
        return QDnsLookup::SRV;
    }
    if (type == "TXT") {
        return QDnsLookup::TXT;
    }
    return QDnsLookup::A;
}

void DNSLookupTool::setResult(const QString &result)
{
    if (m_result != result) {
        m_result = result;
        emit resultChanged();
    }
}

void DNSLookupTool::setErrorMessage(const QString &message)
{
    if (m_errorMessage != message) {
        m_errorMessage = message;
        emit errorMessageChanged();
    }
}

void DNSLookupTool::setIsLoading(bool isLoading)
{
    if (m_isLoading != isLoading) {
        m_isLoading = isLoading;
        emit isLoadingChanged();
    }
}
