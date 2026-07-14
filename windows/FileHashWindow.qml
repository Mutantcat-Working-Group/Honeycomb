import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: fileHashWindow
    width: 760
    height: 560
    minimumWidth: 680
    minimumHeight: 480
    title: algorithm + " " + (I18n.t("fileHash") || "文件哈希")
    flags: Qt.Window
    modality: Qt.NonModal

    property string algorithm: "MD5"

    FileHashCalculator {
        id: calculator
        algorithm: fileHashWindow.algorithm

        onUppercaseChanged: {
            if (result.length > 0) {
                calculate()
            }
        }
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
        } catch (error) {
            // 文件名可以包含裸 %，解码失败时保留原路径。
        }

        // file:///C:/、file:/C:/ 和 file:///C:\ 均归一为 Windows 本地路径。
        // 仅移除 file:，这样 file://server/share 仍会保留 UNC 的 //server/share。
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
        calculator.filePath = path
        calculator.calculate()
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
                    text: algorithm + " " + (I18n.t("fileHash") || "文件哈希")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }

                Text {
                    text: I18n.t("fileHashDesc") || "拖入文件或输入路径后计算文件哈希"
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
                        border.color: fileDropArea.containsDrag ? "#1976d2" : (filePathInput.activeFocus ? "#1976d2" : "#e0e0e0")
                        border.width: (fileDropArea.containsDrag || filePathInput.activeFocus) ? 2 : 1
                        radius: 4

                        TextField {
                            id: filePathInput
                            anchors.fill: parent
                            anchors.margins: 1
                            placeholderText: fileDropArea.containsDrag
                                             ? (I18n.t("fileHashDropTip") || "松开后计算文件哈希")
                                             : (I18n.t("filePathPlaceholder") || "请输入文件完整路径，或拖入文件...")
                            font.pixelSize: 14
                            selectByMouse: true
                            onTextChanged: calculator.filePath = text
                            onAccepted: calculator.calculate()
                            background: null
                        }

                        DropArea {
                            id: fileDropArea
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
                        onClicked: calculator.calculate()

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
                            calculator.clear()
                        }

                        background: Rectangle {
                            color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#666666"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    text: I18n.t("uppercase") || "大写输出"
                    checked: false
                    onCheckedChanged: calculator.uppercase = checked
                }

                Item { Layout.fillWidth: true }
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
                            text: algorithm + " " + (I18n.t("resultLabel") || "结果") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: I18n.t("copyBtn") || "复制"
                            visible: calculator.result.length > 0
                            onClicked: copyToClipboard(calculator.result)

                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                                implicitWidth: 80
                                implicitHeight: 32
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "white"
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
                            text: calculator.errorMessage.length > 0 ? calculator.errorMessage : calculator.result
                            readOnly: true
                            font.pixelSize: 14
                            font.family: "Consolas, Monaco, monospace"
                            color: calculator.errorMessage.length > 0 ? "#c62828" : "#495057"
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            placeholderText: I18n.t("fileHashResultPlaceholder") || "拖入文件或点击计算后显示结果"
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
        width: 120
        height: 50
        color: "#333333"
        radius: 6
        opacity: 0
        visible: opacity > 0

        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess") || "已复制到剪贴板"
            font.pixelSize: 14
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
