import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: fileInfoWindow
    width: 900
    height: 680
    minimumWidth: 760
    minimumHeight: 560
    title: I18n.t("toolFileInfo") || "文件信息查看"
    flags: Qt.Window
    modality: Qt.NonModal

    FileUtilityTool { id: fileTool }
    property var info: ({})

    function pathFromDrop(drop) {
        var value = drop.urls && drop.urls.length > 0 ? drop.urls[0].toString() : (drop.text || "").trim()
        value = value.replace(/\r?\n/g, "")
        try { value = decodeURIComponent(value) } catch (error) {}
        value = value.replace(/^file:\/\/localhost(?=\/)/i, "").replace(/^file:/i, "")
        if (/^\/+[A-Za-z]:[\\/]/.test(value)) value = value.replace(/^\/+/, "")
        return value
    }
    function loadInfo(path) {
        if (path.length === 0) return
        pathInput.text = path
        fileTool.filePath = path
        info = fileTool.fileInfo()
    }
    function copyToClipboard(text) {
        clipboardArea.text = text; clipboardArea.selectAll(); clipboardArea.copy(); clipboardArea.text = ""; copyFeedback.show()
    }
    function infoText() {
        return Object.keys(info).map(function(k) { return k + ": " + info[k] }).join("\n")
    }
    TextArea { id: clipboardArea; visible: false }
    Rectangle {
        anchors.fill: parent; color: "#f9f9f9"
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 25; spacing: 18
            Text { text: I18n.t("toolFileInfo") || "文件信息查看"; font.pixelSize: 22; font.bold: true; color: "#333"; Layout.alignment: Qt.AlignHCenter }
            Text { text: I18n.t("toolFileInfoDesc") || "拖入文件查看元信息与摘要"; font.pixelSize: 13; color: "#666"; Layout.alignment: Qt.AlignHCenter }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 42; color: "white"; border.color: dropArea.containsDrag ? "#1976d2" : "#e0e0e0"; radius: 4
                    TextField { id: pathInput; anchors.fill: parent; anchors.margins: 1; placeholderText: dropArea.containsDrag ? "松开后读取文件信息" : (I18n.t("filePathPlaceholder") || "请输入文件完整路径，或拖入文件..."); selectByMouse: true; background: null; onAccepted: loadInfo(text) }
                    DropArea { id: dropArea; anchors.fill: parent; onDropped: function(drop) { loadInfo(pathFromDrop(drop)); drop.accept() } }
                }
                Button {
                    text: I18n.t("calculateBtn") || "计算"
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 36
                    onClicked: loadInfo(pathInput.text)
                    background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: I18n.t("copyBtn") || "复制"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    onClicked: copyToClipboard(infoText())
                    background: Rectangle { color: parent.hovered ? "#f5f5f5" : "white"; border.color: "#d0d0d0"; border.width: 1; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                }
            }
            Text { Layout.fillWidth: true; text: fileTool.errorMessage; visible: fileTool.errorMessage.length > 0; color: "#c62828"; wrapMode: Text.WordWrap }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
            ScrollView {
                anchors.fill: parent; anchors.margins: 14; clip: true
                ColumnLayout {
                    width: fileInfoWindow.width - 98; spacing: 8
                    Repeater {
                        model: [
                            ["文件名", info.name], ["路径", info.absolutePath], ["目录", info.directory], ["扩展名", info.suffix],
                            ["大小", info.sizeText], ["MIME", info.mime], ["创建时间", info.created], ["修改时间", info.lastModified],
                            ["可读", info.readable], ["可写", info.writable], ["可执行", info.executable],
                            ["MD5", info.md5], ["SHA1", info.sha1], ["SHA256", info.sha256]
                        ]
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: modelData[0]; Layout.preferredWidth: 90; font.bold: true; color: "#333" }
                            Text { text: modelData[1] === undefined ? "" : modelData[1]; Layout.fillWidth: true; font.family: "Consolas, Monaco, monospace"; color: "#444"; wrapMode: Text.WrapAnywhere }
                        }
                    }
                }
            }
            }
        }
    }
    Rectangle { id: copyFeedback; width: 150; height: 36; radius: 18; color: "#333"; opacity: 0; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 25; Text { anchors.centerIn: parent; text: I18n.t("copySuccess") || "已复制到剪贴板"; color: "white"; font.pixelSize: 12 } function show(){ opacity=0.9; feedbackTimer.restart() } Timer { id: feedbackTimer; interval: 1500; onTriggered: copyFeedback.opacity=0 } }
}
