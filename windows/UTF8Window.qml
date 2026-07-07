import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: utf8Window
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 500
    title: I18n.t("toolUtf8")
    flags: Qt.Window
    modality: Qt.NonModal

    property string leftText: ""
    property string rightText: ""

    function toUtf8(text) {
        return encodeURIComponent(text)
    }

    function normalizeUtf8Input(text) {
        var value = text.trim()
        if (value.indexOf("%") !== -1) {
            return value
        }
        if (value.indexOf("\\x") !== -1 || value.indexOf("\\X") !== -1) {
            return value.replace(/\\x([0-9a-fA-F]{2})/g, "%$1").replace(/\\X([0-9a-fA-F]{2})/g, "%$1")
        }
        if (/^([0-9a-fA-F]{2}[\s,]*)+$/.test(value)) {
            var parts = value.split(/[\s,]+/).filter(function(part) { return part.length > 0 })
            var result = ""
            for (var i = 0; i < parts.length; i++) {
                result += "%" + parts[i]
            }
            return result
        }
        return value
    }

    function fromUtf8(text) {
        try {
            return decodeURIComponent(normalizeUtf8Input(text))
        } catch (e) {
            return text
        }
    }

    function convertToUtf8() {
        rightText = toUtf8(leftText)
    }

    function convertToText() {
        leftText = fromUtf8(rightText)
    }

    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
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
            spacing: 15

            Column {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: I18n.t("toolUtf8")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }

                Text {
                    text: I18n.t("toolUtf8Desc")
                    font.pixelSize: 13
                    color: "#666"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: I18n.t("plainText") || "原始文本"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + leftText.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: leftArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: leftArea.activeFocus ? 2 : 1
                        radius: 6

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: leftArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick

                            TextArea.flickable: TextArea {
                                id: leftArea
                                text: leftText
                                onTextChanged: leftText = text
                                placeholderText: I18n.t("utf8PlaceholderText") || "在此输入中文或其他文本..."
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei"
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                background: null
                            }

                            ScrollBar.vertical: ScrollBar { }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        layoutDirection: "RightToLeft"

                        Button {
                            id: copyLeftBtn
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36
                            enabled: leftText.length > 0
                            onClicked: {
                                copyToClipboard(leftText)
                                text = I18n.t("copied") || "已复制"
                                copyLeftTimer.start()
                            }
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Timer {
                                id: copyLeftTimer
                                interval: 1500
                                onTriggered: copyLeftBtn.text = I18n.t("copy") || "复制"
                            }
                        }

                        Button {
                            text: I18n.t("clearBtn") || "清空"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36
                            onClicked: leftText = ""
                            background: Rectangle {
                                color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#333"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: 80
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 15

                    Button {
                        text: "→\n" + (I18n.t("toUtf8") || "转UTF8")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        enabled: leftText.length > 0
                        onClicked: convertToUtf8()
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        text: "←\n" + (I18n.t("fromUtf8") || "转文本")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        enabled: rightText.length > 0
                        onClicked: convertToText()
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: I18n.t("utf8Text") || "UTF-8 编码"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + rightText.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: rightArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: rightArea.activeFocus ? 2 : 1
                        radius: 6

                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: rightArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick

                            TextArea.flickable: TextArea {
                                id: rightArea
                                text: rightText
                                onTextChanged: rightText = text
                                placeholderText: I18n.t("utf8PlaceholderCode") || "在此输入UTF-8编码..."
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                background: null
                            }

                            ScrollBar.vertical: ScrollBar { }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        layoutDirection: "RightToLeft"

                        Button {
                            id: copyRightBtn
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36
                            enabled: rightText.length > 0
                            onClicked: {
                                copyToClipboard(rightText)
                                text = I18n.t("copied") || "已复制"
                                copyRightTimer.start()
                            }
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Timer {
                                id: copyRightTimer
                                interval: 1500
                                onTriggered: copyRightBtn.text = I18n.t("copy") || "复制"
                            }
                        }

                        Button {
                            text: I18n.t("clearBtn") || "清空"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 36
                            onClicked: rightText = ""
                            background: Rectangle {
                                color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#333"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }
        }
    }
}
