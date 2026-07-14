import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: aboutWindow
    width: 500
    height: 460
    minimumWidth: 420
    minimumHeight: 460
    title: I18n.t("aboutTitle")
    flags: Qt.Window
    modality: Qt.NonModal

    UpdateChecker {
        id: updateChecker
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            id: aboutContent
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 40
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            spacing: 20
            
            // Logo图片
            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/qt/qml/Honeycomb/assets/icons/icon.jpg"
                sourceSize.width: 100
                sourceSize.height: 100
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                fillMode: Image.PreserveAspectFit
            }
            
            // 描述文字
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: I18n.t("aboutDesc")
                font.pixelSize: 16
                color: "#333"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            // 官网
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: I18n.t("aboutWebsite")
                font.pixelSize: 14
                color: "#666"
            }
            
            // 版本号
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: I18n.t("aboutVersion")
                font.pixelSize: 14
                color: "#666"
            }

        }

        ColumnLayout {
            id: bottomActionArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            anchors.bottomMargin: 40
            spacing: 12

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                visible: updateChecker.status !== "idle"
                text: {
                    if (updateChecker.status === "checking")
                        return I18n.t("aboutChecking")
                    if (updateChecker.status === "available")
                        return I18n.t("aboutUpdateAvailable").replace("{0}", updateChecker.latestVersion)
                    if (updateChecker.status === "latest")
                        return I18n.t("aboutLatest")
                    return I18n.t("aboutCheckFailed")
                }
                font.pixelSize: 14
                color: updateChecker.status === "available" ? "#0078d4" : "#666"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 110
                Layout.preferredHeight: 36
                visible: updateChecker.status === "available" && updateChecker.downloadUrl.toString() !== ""
                text: I18n.t("aboutOpenDownload")
                onClicked: Qt.openUrlExternally(updateChecker.downloadUrl)

                background: Rectangle {
                    color: parent.hovered ? "#f5f5f5" : "white"
                    border.color: "#d0d0d0"
                    border.width: 1
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "#333"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: checkUpdateButton
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 110
                Layout.preferredHeight: 36
                text: updateChecker.checking ? I18n.t("aboutChecking") : I18n.t("aboutCheckUpdate")
                enabled: !updateChecker.checking
                onClicked: updateChecker.checkForUpdates()

                background: Rectangle {
                    color: parent.enabled
                           ? (parent.pressed ? "#005a9e" : (parent.hovered ? "#006cbd" : "#0078d4"))
                           : "#c8c8c8"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
