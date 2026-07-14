import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: base64Window
    width: 820
    height: 640
    minimumWidth: 700
    minimumHeight: 520
    title: I18n.t("toolFileBase64") || "文件转Base64"
    flags: Qt.Window
    modality: Qt.NonModal

    property var sizeOptions: [
        { label: "1 MB", bytes: 1024 * 1024 },
        { label: "3 MB", bytes: 3 * 1024 * 1024 },
        { label: "5 MB", bytes: 5 * 1024 * 1024 },
        { label: "10 MB", bytes: 10 * 1024 * 1024 },
        { label: "20 MB", bytes: 20 * 1024 * 1024 }
    ]

    FileUtilityTool {
        id: fileTool
        maxBase64SizeBytes: sizeOptions[sizeLimitBox.currentIndex].bytes
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
        fileTool.encodeFileToBase64()
    }

    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
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
                    text: I18n.t("toolFileBase64") || "文件转Base64"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }

                Text {
                    text: I18n.t("toolFileBase64Desc") || "将小文件转换为Base64文本"
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
                        border.color: base64DropArea.containsDrag ? "#1976d2" : (filePathInput.activeFocus ? "#1976d2" : "#e0e0e0")
                        border.width: (base64DropArea.containsDrag || filePathInput.activeFocus) ? 2 : 1
                        radius: 4

                        TextField {
                            id: filePathInput
                            anchors.fill: parent
                            anchors.margins: 1
                            placeholderText: base64DropArea.containsDrag
                                             ? (I18n.t("fileBase64DropTip") || "松开后转换Base64")
                                             : (I18n.t("filePathPlaceholder") || "请输入文件完整路径，或拖入文件...")
                            font.pixelSize: 14
                            selectByMouse: true
                            onTextChanged: fileTool.filePath = text
                            onAccepted: fileTool.encodeFileToBase64()
                            background: null
                        }

                        DropArea {
                            id: base64DropArea
                            anchors.fill: parent
                            onDropped: function(drop) {
                                acceptFilePath(pathFromDrop(drop))
                                drop.accept()
                            }
                        }
                    }

                    ComboBox {
                        id: sizeLimitBox
                        Layout.preferredWidth: 105
                        Layout.preferredHeight: 38
                        model: sizeOptions.map(function(item) { return item.label })
                        currentIndex: 3
                    }

                    Button {
                        text: I18n.t("convertBtn") || "转换"
                        Layout.preferredWidth: 85
                        Layout.preferredHeight: 38
                        onClicked: fileTool.encodeFileToBase64()

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
                        Layout.preferredWidth: 75
                        Layout.preferredHeight: 38
                        onClicked: {
                            filePathInput.text = ""
                            fileTool.filePath = ""
                            fileTool.clearBase64()
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

                Text {
                    Layout.fillWidth: true
                    text: (I18n.t("fileBase64LimitTip") || "为避免卡顿，单文件大小限制：") + sizeOptions[sizeLimitBox.currentIndex].label
                    font.pixelSize: 12
                    color: "#888"
                    wrapMode: Text.WordWrap
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
                            text: I18n.t("fileBase64Result") || "Base64结果"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: I18n.t("copyBtn") || "复制"
                            enabled: fileTool.base64Result.length > 0
                            onClicked: copyToClipboard(fileTool.base64Result)

                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                                radius: 4
                                implicitWidth: 80
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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f8f9fa"
                        border.color: "#e9ecef"
                        border.width: 1
                        radius: 4

                        TextArea {
                            anchors.fill: parent
                            anchors.margins: 12
                            text: fileTool.base64Result
                            readOnly: true
                            font.pixelSize: 13
                            font.family: "Consolas, Monaco, monospace"
                            color: "#495057"
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            placeholderText: I18n.t("fileBase64ResultPlaceholder") || "转换后显示Base64文本"
                            background: null
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
}
