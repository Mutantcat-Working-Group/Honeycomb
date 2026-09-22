#include "../src/UpdateChecker.h"

#include <QCoreApplication>

#include <cstdlib>

namespace {
void require(bool condition)
{
    if (!condition) {
        std::abort();
    }
}
}

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    require(UpdateChecker::isVersionNewer("v1.1.20260715", "1.1.20260714"));
    require(!UpdateChecker::isVersionNewer("1.1.20260714", "1.1.20260714"));

    // Versions are major.minor.YYYYMMDD, so the release date decides recency
    // even when the middle component moved backwards.
    require(UpdateChecker::isVersionNewer("1.0.20260920", "1.1.20260723"));
    require(!UpdateChecker::isVersionNewer("1.1.20260723", "1.0.20260920"));
    require(UpdateChecker::isVersionNewer("1.2.20260601", "1.1.20260523"));
    require(!UpdateChecker::isVersionNewer("1.1.20260523", "1.2.20260601"));
    require(UpdateChecker::isVersionNewer("1.0.20260921", "1.0.20260920"));
    require(!UpdateChecker::isVersionNewer("1.0.20260920", "1.0.20260921"));

    // Plain semantic versions keep their old behaviour.
    require(UpdateChecker::isVersionNewer("2.0", "1.9"));
    require(!UpdateChecker::isVersionNewer("1.9", "2.0"));
    require(UpdateChecker::isVersionNewer("1.2.4", "1.2.3"));
    require(!UpdateChecker::isVersionNewer("1.2.3", "1.2.4"));
    require(!UpdateChecker::isVersionNewer("1.0", "1.0"));

    const QByteArray payload = R"({
        "software": {
            "HONEYCOMB": {
                "latest": "1.1.20260715",
                "platforms": {
                    "MACOS": [{
                        "version": "1.1.20260715",
                        "architecture": "AArch64",
                        "download": { "GitHub": "https://example.test/release" }
                    }]
                }
            }
        }
    })";
    const UpdateChecker::UpdateInfo info = UpdateChecker::parseVersionResponse(payload, "mac", "arm64");
    require(info.isValid());
    require(info.version == "1.1.20260715");
    require(info.downloadUrl == QUrl("https://example.test/release"));

    // Guard the parser against the shapes the live endpoints really publish,
    // including "win32_x64", "x86_64 (Intel)" and "arm64 (Apple Silicon)".
    const QByteArray liveShapedPayload = R"JSON({
        "software": {
            "Honeycomb": {
                "latest": "1.1.20260723",
                "latestEntry": { "version": "1.1.20260723", "architecture": "win32_x64" },
                "platforms": {
                    "windows": [
                        { "version": "1.1.20260723", "architecture": "win32_x64",
                          "download": { "github": "https://example.test/win" } },
                        { "version": "1.1.20260722", "architecture": "win32_x64",
                          "download": { "github": "https://example.test/win-old" } }
                    ],
                    "linux": [
                        { "version": "1.1.20260723", "architecture": "linux_x64",
                          "download": { "github": "https://example.test/linux" } },
                        { "version": "1.1.20260711", "architecture": "ubuntu_x64",
                          "download": { "github": "https://example.test/ubuntu" } }
                    ],
                    "mac": [
                        { "version": "1.1.20260723", "architecture": "arm64 (Apple Silicon)",
                          "download": { "github": "https://example.test/mac-arm64" } },
                        { "version": "1.1.20260723", "architecture": "x86_64 (Intel)",
                          "download": { "github": "https://example.test/mac-x64" } },
                        { "version": "1.1.20260714", "architecture": "arm64",
                          "download": { "github": "https://example.test/mac-arm64-old" } }
                    ]
                }
            }
        }
    })JSON";
    const UpdateChecker::UpdateInfo macArm = UpdateChecker::parseVersionResponse(liveShapedPayload, "mac", "arm64");
    require(macArm.version == "1.1.20260723");
    require(macArm.downloadUrl == QUrl("https://example.test/mac-arm64"));

    const UpdateChecker::UpdateInfo macIntel = UpdateChecker::parseVersionResponse(liveShapedPayload, "mac", "x64");
    require(macIntel.version == "1.1.20260723");
    require(macIntel.downloadUrl == QUrl("https://example.test/mac-x64"));

    const UpdateChecker::UpdateInfo windows = UpdateChecker::parseVersionResponse(liveShapedPayload, "windows", "x64");
    require(windows.version == "1.1.20260723");
    require(windows.downloadUrl == QUrl("https://example.test/win"));

    // Not "linux": glibc defines that name as the literal 1, which trips the
    // Linux toolchain on CI.
    const UpdateChecker::UpdateInfo linuxInfo = UpdateChecker::parseVersionResponse(liveShapedPayload, "linux", "x64");
    require(linuxInfo.version == "1.1.20260723");
    require(linuxInfo.downloadUrl == QUrl("https://example.test/linux"));

    return 0;
}
