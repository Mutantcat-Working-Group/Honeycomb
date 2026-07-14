import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: previewWindow
    width: 980
    height: 680
    minimumWidth: 820
    minimumHeight: 560
    title: I18n.t("toolBase64ImagePreview") || "Base64图片预览"
    flags: Qt.Window
    modality: Qt.NonModal

    property string imageSource: ""
    property string statusText: ""

    function preview() {
        var value = input.text.trim()
        if (value.length === 0) {
            imageSource = ""
            statusText = "请输入 Base64 或 Data URL"
            return
        }
        value = value.replace(/\s/g, "")
        imageSource = value.indexOf("data:image/") === 0 ? value : "data:image/" + formatBox.currentText + ";base64," + value
        statusText = "已生成预览，字符数：" + value.length
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Column {
                Layout.fillWidth: true
                spacing: 5
                Text {
                    text: I18n.t("toolBase64ImagePreview") || "Base64图片预览"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolBase64ImagePreviewDesc") || "粘贴Base64或Data URL预览图片"
                    font.pixelSize: 13
                    color: "#666"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    ColumnLayout {
                        Layout.preferredWidth: 170
                        spacing: 6
                        Text { text: "图片格式"; font.pixelSize: 13; color: "#666" }
                        ComboBox {
                            id: formatBox
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            model: ["png", "jpeg", "webp", "gif", "bmp", "svg+xml"]
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: statusText.length > 0 ? statusText : "支持纯 Base64，也支持 data:image/png;base64,..."
                        font.pixelSize: 12
                        color: "#888"
                        wrapMode: Text.WordWrap
                    }

                    Button {
                        text: I18n.t("generateBtn") || "生成"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 36
                        onClicked: preview()
                        background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                        contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }

                    Button {
                        text: I18n.t("clearBtn") || "清空"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 36
                        onClicked: { input.text = ""; imageSource = ""; statusText = "" }
                        background: Rectangle { color: parent.hovered ? "#f5f5f5" : "white"; border.color: "#d0d0d0"; border.width: 1; radius: 4 }
                        contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            text: "Base64 输入"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        TextArea {
                            id: input
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "iVBORw0KGgo... 或 data:image/png;base64,..."
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 13
                            font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                            background: Rectangle {
                                color: "#fbfbfb"
                                border.color: input.activeFocus ? "#0078d4" : "#edf0f2"
                                border.width: input.activeFocus ? 2 : 1
                                radius: 4
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            text: "图片预览"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#fafafa"
                            border.color: "#edf0f2"
                            border.width: 1
                            radius: 4
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 12
                                source: imageSource
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "生成后在这里预览"
                                color: "#aaa"
                                font.pixelSize: 14
                                visible: imageSource.length === 0
                            }
                        }
                    }
                }
            }
        }
    }
}
