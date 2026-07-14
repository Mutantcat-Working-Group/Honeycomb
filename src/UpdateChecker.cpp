#include "UpdateChecker.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QSysInfo>

namespace {
const QStringList kVersionEndpoints = {
    QStringLiteral("https://version.mutantcat.org/version.json"),
    QStringLiteral("https://version.mutantcat.org.cn/version.json")
};

QString normalized(const QString &value)
{
    QString result;
    for (const QChar character : value.toLower()) {
        if (character.isLetterOrNumber()) {
            result.append(character);
        }
    }
    return result;
}

QJsonValue valueForKey(const QJsonObject &object, const QString &key)
{
    for (auto it = object.constBegin(); it != object.constEnd(); ++it) {
        if (it.key().compare(key, Qt::CaseInsensitive) == 0) {
            return it.value();
        }
    }
    return {};
}

QString stringForKey(const QJsonObject &object, const QString &key)
{
    return valueForKey(object, key).toString().trimmed();
}

bool platformMatches(const QString &value, const QString &platform)
{
    const QString candidate = normalized(value);
    const QString requested = normalized(platform);
    if (requested == QStringLiteral("mac")) {
        return candidate == QStringLiteral("mac") || candidate == QStringLiteral("macos") || candidate == QStringLiteral("osx");
    }
    if (requested == QStringLiteral("windows")) {
        return candidate == QStringLiteral("windows") || candidate == QStringLiteral("win") || candidate.startsWith(QStringLiteral("win"));
    }
    return candidate == requested;
}

bool architectureMatches(const QString &value, const QString &architecture)
{
    const QString candidate = normalized(value);
    const QString requested = normalized(architecture);
    if (requested == QStringLiteral("arm64")) {
        return candidate.contains(QStringLiteral("arm64")) || candidate.contains(QStringLiteral("aarch64"));
    }
    if (requested == QStringLiteral("x64")) {
        return candidate.contains(QStringLiteral("x64")) || candidate.contains(QStringLiteral("x8664"))
            || candidate.contains(QStringLiteral("amd64")) || candidate.contains(QStringLiteral("intel64"));
    }
    return candidate == requested;
}

QUrl downloadUrlForEntry(const QJsonObject &entry)
{
    const QJsonObject download = valueForKey(entry, QStringLiteral("download")).toObject();
    for (const QString &key : {QStringLiteral("direct"), QStringLiteral("github")}) {
        const QString url = stringForKey(download, key);
        if (!url.isEmpty()) {
            return QUrl(url);
        }
    }
    for (auto it = download.constBegin(); it != download.constEnd(); ++it) {
        if (it.value().isString() && !it.value().toString().trimmed().isEmpty()) {
            return QUrl(it.value().toString().trimmed());
        }
    }
    return {};
}

QJsonObject matchingSoftware(const QJsonObject &root)
{
    QJsonObject software = valueForKey(root, QStringLiteral("software")).toObject();
    if (software.isEmpty()) {
        software = root;
    }
    for (auto it = software.constBegin(); it != software.constEnd(); ++it) {
        if (it.key().compare(QStringLiteral("Honeycomb"), Qt::CaseInsensitive) == 0 && it.value().isObject()) {
            return it.value().toObject();
        }
    }
    return {};
}
}

UpdateChecker::UpdateChecker(QObject *parent)
    : QObject(parent)
{
    m_timeoutTimer.setSingleShot(true);
    connect(&m_timeoutTimer, &QTimer::timeout, this, [this] {
        if (!m_reply) {
            return;
        }
        QNetworkReply *timedOutReply = m_reply;
        m_reply = nullptr;
        timedOutReply->abort();
        timedOutReply->deleteLater();
        advanceRequest();
    });
}

bool UpdateChecker::checking() const { return m_checking; }
QString UpdateChecker::status() const { return m_status; }
QString UpdateChecker::latestVersion() const { return m_latestVersion; }
bool UpdateChecker::updateAvailable() const { return m_updateAvailable; }
QUrl UpdateChecker::downloadUrl() const { return m_downloadUrl; }

void UpdateChecker::checkForUpdates()
{
    if (m_checking) {
        return;
    }
    m_latestVersion.clear();
    m_updateAvailable = false;
    m_downloadUrl = QUrl();
    emit resultChanged();
    m_endpointIndex = 0;
    m_attempt = 0;
    setChecking(true);
    setStatus(QStringLiteral("checking"));
    requestCurrentEndpoint();
}

bool UpdateChecker::isVersionNewer(const QString &candidate, const QString &current)
{
    static const QRegularExpression numberPattern(QStringLiteral("\\d+"));
    const QRegularExpressionMatchIterator candidateMatches = numberPattern.globalMatch(candidate);
    const QRegularExpressionMatchIterator currentMatches = numberPattern.globalMatch(current);
    QList<int> candidateParts;
    QList<int> currentParts;
    auto appendParts = [](QRegularExpressionMatchIterator matches, QList<int> &parts) {
        while (matches.hasNext()) {
            parts.append(matches.next().capturedView().toInt());
        }
    };
    appendParts(candidateMatches, candidateParts);
    appendParts(currentMatches, currentParts);

    if (candidateParts.isEmpty() || currentParts.isEmpty()) {
        return candidate.compare(current, Qt::CaseInsensitive) > 0;
    }
    const int count = qMax(candidateParts.size(), currentParts.size());
    for (int index = 0; index < count; ++index) {
        const int candidatePart = index < candidateParts.size() ? candidateParts.at(index) : 0;
        const int currentPart = index < currentParts.size() ? currentParts.at(index) : 0;
        if (candidatePart != currentPart) {
            return candidatePart > currentPart;
        }
    }
    return false;
}

UpdateChecker::UpdateInfo UpdateChecker::parseVersionResponse(const QByteArray &payload,
                                                               const QString &platform,
                                                               const QString &architecture)
{
    const QJsonDocument document = QJsonDocument::fromJson(payload);
    if (!document.isObject()) {
        return {};
    }
    const QJsonObject software = matchingSoftware(document.object());
    if (software.isEmpty()) {
        return {};
    }

    const QString latest = stringForKey(software, QStringLiteral("latest"));
    QJsonObject selectedEntry;
    const QJsonObject platforms = valueForKey(software, QStringLiteral("platforms")).toObject();
    for (auto it = platforms.constBegin(); it != platforms.constEnd(); ++it) {
        if (!platformMatches(it.key(), platform) || !it.value().isArray()) {
            continue;
        }
        for (const QJsonValue &entryValue : it.value().toArray()) {
            const QJsonObject entry = entryValue.toObject();
            if (!architectureMatches(stringForKey(entry, QStringLiteral("architecture")), architecture)) {
                continue;
            }
            if (selectedEntry.isEmpty() || isVersionNewer(stringForKey(entry, QStringLiteral("version")),
                                                          stringForKey(selectedEntry, QStringLiteral("version")))) {
                selectedEntry = entry;
            }
        }
    }
    if (selectedEntry.isEmpty()) {
        selectedEntry = valueForKey(software, QStringLiteral("latestEntry")).toObject();
    }

    UpdateInfo info;
    info.version = latest.isEmpty() ? stringForKey(selectedEntry, QStringLiteral("version")) : latest;
    info.downloadUrl = downloadUrlForEntry(selectedEntry);
    return info;
}

void UpdateChecker::requestCurrentEndpoint()
{
    QNetworkRequest request(QUrl(kVersionEndpoints.at(m_endpointIndex)));
    request.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("Honeycomb Update Checker"));
    m_reply = m_networkManager.get(request);
    connect(m_reply, &QNetworkReply::finished, this, [this] {
        QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
        if (!reply || reply != m_reply) {
            return;
        }
        m_timeoutTimer.stop();
        m_reply = nullptr;
        const QByteArray data = reply->readAll();
        const bool requestFailed = reply->error() != QNetworkReply::NoError;
        reply->deleteLater();
        if (requestFailed) {
            advanceRequest();
            return;
        }

        const UpdateInfo info = parseVersionResponse(data, currentPlatform(), currentArchitecture());
        if (!info.isValid()) {
            advanceRequest();
            return;
        }
        m_latestVersion = info.version;
        m_downloadUrl = info.downloadUrl;
#ifdef HONEYCOMB_VERSION
        m_updateAvailable = isVersionNewer(m_latestVersion, QStringLiteral(HONEYCOMB_VERSION));
#else
        m_updateAvailable = false;
#endif
        emit resultChanged();
        setChecking(false);
        setStatus(m_updateAvailable ? QStringLiteral("available") : QStringLiteral("latest"));
    });
    m_timeoutTimer.start(5000);
}

void UpdateChecker::advanceRequest()
{
    if (m_attempt == 0) {
        ++m_attempt;
        requestCurrentEndpoint();
        return;
    }
    ++m_endpointIndex;
    m_attempt = 0;
    if (m_endpointIndex < kVersionEndpoints.size()) {
        requestCurrentEndpoint();
        return;
    }
    finishWithError();
}

void UpdateChecker::finishWithError()
{
    m_timeoutTimer.stop();
    setChecking(false);
    setStatus(QStringLiteral("error"));
}

void UpdateChecker::setChecking(bool checking)
{
    if (m_checking == checking) {
        return;
    }
    m_checking = checking;
    emit checkingChanged();
}

void UpdateChecker::setStatus(const QString &status)
{
    if (m_status == status) {
        return;
    }
    m_status = status;
    emit statusChanged();
}

QString UpdateChecker::currentPlatform()
{
#if defined(Q_OS_MACOS)
    return QStringLiteral("mac");
#elif defined(Q_OS_WIN)
    return QStringLiteral("windows");
#else
    return QStringLiteral("linux");
#endif
}

QString UpdateChecker::currentArchitecture()
{
    const QString architecture = normalized(QSysInfo::currentCpuArchitecture());
    if (architecture.contains(QStringLiteral("arm64")) || architecture.contains(QStringLiteral("aarch64"))) {
        return QStringLiteral("arm64");
    }
    return QStringLiteral("x64");
}
