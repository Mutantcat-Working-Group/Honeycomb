import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: checksumWindow
    width: 900
    height: 680
    minimumWidth: 760
    minimumHeight: 560
    title: I18n.t("toolFileChecksum") || "文件校验"
    flags: Qt.Window
    modality: Qt.NonModal

    FileUtilityTool {
        id: fileTool
    }

    function pathFromDrop(drop) {
        var value = ""
        if (drop.urls && drop.urls.length > 0) {
            value = drop.urls[0].toString()
        } else if (drop.text && drop.text.length > 0) {
            value = drop.text.trim()
        }

        value = value.replace(/\r?\n/g, "")
        try {
            value = decodeURIComponent(value)
        } catch (error) {}
        value = value.replace(/^file:\/\/localhost(?=\/)/i, "")
        value = value.replace(/^file:/i, "")
        if (/^\/+[A-Za-z]:[\\/]/.test(value)) {
            value = value.replace(/^\/+/, "")
        }
        return value
    }

    function acceptFilePath(path) {
        if (path.length === 0) {
            return
        }
        filePathInput.text = path
        fileTool.filePath = path
        fileTool.calculateAllHashes()
    }

    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
    }

    function copyAllHashes() {
        var text = "MD5: " + fileTool.md5 + "\n"
                 + "SHA1: " + fileTool.sha1 + "\n"
                 + "SHA256: " + fileTool.sha256 + "\n"
                 + "SHA384: " + fileTool.sha384 + "\n"
                 + "SHA512: " + fileTool.sha512
        copyToClipboard(text)
    }

    TextArea {
        id: clipboardArea
        visible: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 18

            Column {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: I18n.t("toolFileChecksum") || "文件校验"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }

                Text {
                    text: I18n.t("toolFileChecksumDesc") || "拖入文件一次计算多种哈希并支持比对"
                    font.pixelSize: 13
                    color: "#666"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: I18n.t("filePath") || "文件路径"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                        color: "white"
                        border.color: checksumDropArea.containsDrag ? "#1976d2" : (filePathInput.activeFocus ? "#1976d2" : "#e0e0e0")
                        border.width: (checksumDropArea.containsDrag || filePathInput.activeFocus) ? 2 : 1
                        radius: 4

                        TextField {
                            id: filePathInput
                            anchors.fill: parent
                            anchors.margins: 1
                            placeholderText: checksumDropArea.containsDrag
                                             ? (I18n.t("fileChecksumDropTip") || "松开后计算所有哈希")
                                             : (I18n.t("filePathPlaceholder") || "请输入文件完整路径，或拖入文件...")
                            font.pixelSize: 14
                            selectByMouse: true
                            onTextChanged: fileTool.filePath = text
                            onAccepted: fileTool.calculateAllHashes()
                            background: null
                        }

                        DropArea {
                            id: checksumDropArea
                            anchors.fill: parent
                            onDropped: function(drop) {
                                acceptFilePath(pathFromDrop(drop))
                                drop.accept()
                            }
                        }
                    }

                    Button {
                        text: I18n.t("calculateBtn") || "计算"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 38
                        onClicked: fileTool.calculateAllHashes()

                        background: Rectangle {
                            color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: I18n.t("clearBtn") || "清空"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 38
                        onClicked: {
                            filePathInput.text = ""
                            fileTool.filePath = ""
                            fileTool.clearHashes()
                        }

                        background: Rectangle {
                            color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#666"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: fileTool.errorMessage
                visible: fileTool.errorMessage.length > 0
                font.pixelSize: 13
                color: "#c62828"
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: I18n.t("fileChecksumResult") || "校验结果"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: I18n.t("copyAll") || "复制全部"
                            enabled: fileTool.md5.length > 0
                            onClicked: copyAllHashes()

                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                                radius: 4
                                implicitWidth: 90
                                implicitHeight: 32
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        contentWidth: availableWidth

                        ColumnLayout {
                            spacing: 8

                            HashRow { label: "MD5"; hashValue: fileTool.md5 }
                            HashRow { label: "SHA1"; hashValue: fileTool.sha1 }
                            HashRow { label: "SHA256"; hashValue: fileTool.sha256 }
                            HashRow { label: "SHA384"; hashValue: fileTool.sha384 }
                            HashRow { label: "SHA512"; hashValue: fileTool.sha512 }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: copyFeedback
        anchors.centerIn: parent
        width: 140
        height: 48
        color: "#333333"
        radius: 6
        opacity: 0
        visible: opacity > 0

        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess") || "已复制到剪贴板"
            font.pixelSize: 13
            color: "white"
        }

        function show() {
            opacity = 1
            feedbackTimer.start()
        }

        Timer {
            id: feedbackTimer
            interval: 1500
            onTriggered: copyFeedback.opacity = 0
        }
    }

    component HashRow: Rectangle {
        id: hashRow
        property string label: ""
        property string hashValue: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 82
        color: "#f8f9fa"
        border.color: "#e9ecef"
        border.width: 1
        radius: 4

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Text {
                text: hashRow.label
                Layout.preferredWidth: 62
                font.pixelSize: 13
                font.bold: true
                color: "#333"
                verticalAlignment: Text.AlignVCenter
            }

            TextArea {
                text: hashRow.hashValue
                readOnly: true
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 200
                font.pixelSize: 12
                font.family: "Consolas, Monaco, monospace"
                color: "#495057"
                selectByMouse: true
                wrapMode: TextArea.NoWrap
                placeholderText: I18n.t("fileChecksumPending") || "等待计算"
                background: null
            }

            ColumnLayout {
                Layout.preferredWidth: 240
                Layout.minimumWidth: 180
                Layout.maximumWidth: 260
                Layout.fillHeight: true
                spacing: 6

                TextField {
                    id: compareInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    placeholderText: I18n.t("fileChecksumComparePlaceholder") || "粘贴用于比对的值"
                    font.pixelSize: 12
                    selectByMouse: true
                }

                Text {
                    Layout.fillWidth: true
                    text: compareInput.text.trim().length === 0
                          ? (I18n.t("fileChecksumCompareTip") || "输入后自动比对")
                          : (compareInput.text.trim().toLowerCase() === hashRow.hashValue.toLowerCase()
                             ? (I18n.t("fileChecksumMatch") || "匹配")
                             : (I18n.t("fileChecksumMismatch") || "不匹配"))
                    font.pixelSize: 12
                    color: compareInput.text.trim().length === 0 ? "#888" : (compareInput.text.trim().toLowerCase() === hashRow.hashValue.toLowerCase() ? "#2e7d32" : "#c62828")
                }
            }

            Button {
                text: I18n.t("copyBtn") || "复制"
                enabled: hashRow.hashValue.length > 0
                Layout.preferredWidth: 70
                Layout.preferredHeight: 32
                onClicked: copyToClipboard(hashRow.hashValue)

                background: Rectangle {
                    color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
