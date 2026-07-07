#ifndef DNSLOOKUPTOOL_H
#define DNSLOOKUPTOOL_H

#include <QObject>
#include <QString>

class QDnsLookup;

class DNSLookupTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString domain READ domain WRITE setDomain NOTIFY domainChanged)
    Q_PROPERTY(QString recordType READ recordType WRITE setRecordType NOTIFY recordTypeChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit DNSLookupTool(QObject *parent = nullptr);
    ~DNSLookupTool();

    QString domain() const;
    void setDomain(const QString &domain);

    QString recordType() const;
    void setRecordType(const QString &recordType);

    QString result() const;
    QString errorMessage() const;
    bool isLoading() const;

    Q_INVOKABLE void lookup();
    Q_INVOKABLE void clear();

signals:
    void domainChanged();
    void recordTypeChanged();
    void resultChanged();
    void errorMessageChanged();
    void isLoadingChanged();

private slots:
    void onFinished();

private:
    int dnsType() const;
    void setResult(const QString &result);
    void setErrorMessage(const QString &message);
    void setIsLoading(bool isLoading);

    QDnsLookup *m_lookup;
    QString m_domain;
    QString m_recordType;
    QString m_result;
    QString m_errorMessage;
    bool m_isLoading;
};

#endif // DNSLOOKUPTOOL_H
