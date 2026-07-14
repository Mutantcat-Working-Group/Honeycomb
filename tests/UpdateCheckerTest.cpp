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

    return 0;
}
