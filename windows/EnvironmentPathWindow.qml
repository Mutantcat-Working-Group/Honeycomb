import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: pathWindow
    width: 980
    height: 720
    minimumWidth: 820
    minimumHeight: 600
    title: I18n.t("toolEnvironmentPath") || "PATH查看器"
    flags: Qt.Window
    modality: Qt.NonModal

    EnvironmentPathTool {
        id: pathTool
    }

    property var shellOptions: ["bash/zsh", "fish", "PowerShell", "cmd"]

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

            RowLayout {
                Layout.fillWidth: true

                Column {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: I18n.t("toolEnvironmentPath") || "PATH查看器"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }

                    Text {
                        text: I18n.t("toolEnvironmentPathDesc") || "查看并检查当前系统PATH环境变量"
                        font.pixelSize: 13
                        color: "#666"
                    }
                }

                Button {
                    text: I18n.t("refreshBtn") || "刷新"
                    Layout.preferredWidth: 82
                    Layout.preferredHeight: 36
                    onClicked: pathTool.refresh()

                    background: Rectangle {
                        color: parent.hovered ? "#006cbd" : "#0078d4"
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

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [
                        { label: I18n.t("envPathPlatform") || "系统", value: pathTool.platformName },
                        { label: I18n.t("envPathSeparator") || "分隔符", value: pathTool.separator },
                        { label: I18n.t("envPathTotal") || "总数", value: pathTool.pathCount },
                        { label: I18n.t("envPathExisting") || "存在", value: pathTool.existingCount },
                        { label: I18n.t("envPathMissing") || "缺失", value: pathTool.missingCount },
                        { label: I18n.t("envPathDuplicate") || "重复", value: pathTool.duplicateCount }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 6

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: modelData.value
                                font.pixelSize: 18
                                font.bold: true
                                color: "#333"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: modelData.label
                                font.pixelSize: 12
                                color: "#888"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 112
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: I18n.t("envPathRaw") || "PATH原文"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: I18n.t("copyBtn") || "复制"
                            Layout.preferredWidth: 72
                            Layout.preferredHeight: 30
                            onClicked: copyToClipboard(pathTool.pathValue)

                            background: Rectangle {
                                color: parent.hovered ? "#006cbd" : "#0078d4"
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

                    TextArea {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: pathTool.pathValue
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextArea.Wrap
                        font.pixelSize: 12
                        font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                        background: Rectangle {
                            color: "#f8f9fa"
                            border.color: "#edf0f2"
                            radius: 4
                        }
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
                        anchors.margins: 12
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: I18n.t("envPathList") || "PATH列表"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }

                            Item { Layout.fillWidth: true }

                            Button {
                                text: I18n.t("envPathCopyLines") || "复制分行"
                                Layout.preferredWidth: 86
                                Layout.preferredHeight: 30
                                onClicked: copyToClipboard(pathTool.normalizedPathText())

                                background: Rectangle {
                                    color: parent.hovered ? "#006cbd" : "#0078d4"
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

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            color: "#0078d4"
                            radius: 4

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                Text { text: "#"; Layout.preferredWidth: 34; color: "white"; font.bold: true; font.pixelSize: 12 }
                                Text { text: I18n.t("envPathStatus") || "状态"; Layout.preferredWidth: 74; color: "white"; font.bold: true; font.pixelSize: 12 }
                                Text { text: I18n.t("filePath") || "文件路径"; Layout.fillWidth: true; color: "white"; font.bold: true; font.pixelSize: 12 }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: pathTool.entries

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 42
                                color: index % 2 === 0 ? "#ffffff" : "#fafafa"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    Text {
                                        text: modelData.index
                                        Layout.preferredWidth: 34
                                        font.pixelSize: 12
                                        color: "#666"
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 74
                                        Layout.preferredHeight: 24
                                        radius: 12
                                        color: modelData.duplicate ? "#fff3cd" : (modelData.exists ? "#e8f5e9" : "#ffebee")

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.duplicate ? (I18n.t("envPathDuplicateShort") || "重复") : (modelData.exists ? (I18n.t("envPathOk") || "正常") : (I18n.t("envPathMissingShort") || "缺失"))
                                            font.pixelSize: 11
                                            color: modelData.duplicate ? "#8a6d3b" : (modelData.exists ? "#2e7d32" : "#c62828")
                                        }
                                    }

                                    Text {
                                        text: modelData.path
                                        Layout.fillWidth: true
                                        font.pixelSize: 12
                                        font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                                        color: "#333"
                                        elide: Text.ElideMiddle
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 330
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6
                    clip: true

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 12
                        clip: true
                        contentWidth: availableWidth
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        ColumnLayout {
                            width: parent.availableWidth
                            spacing: 9

                            Text {
                                text: I18n.t("envPathCommandRef") || "设置命令参考"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }

                            TextField {
                                id: pathToAddInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                placeholderText: I18n.t("envPathAddPlaceholder") || "输入要添加的目录..."
                                selectByMouse: true
                                font.pixelSize: 13
                            }

                            ComboBox {
                                id: shellBox
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                model: shellOptions
                                currentIndex: pathTool.platformName === "Windows" ? 2 : 0
                            }

                            TextArea {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 76
                                text: pathTool.commandForShell(shellOptions[shellBox.currentIndex], pathToAddInput.text)
                                readOnly: true
                                selectByMouse: true
                                wrapMode: TextArea.Wrap
                                font.pixelSize: 12
                                font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                                background: Rectangle {
                                    color: "#f8f9fa"
                                    border.color: "#edf0f2"
                                    radius: 4
                                }
                            }

                            Button {
                                text: I18n.t("envPathCopyCommand") || "复制命令"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                onClicked: copyToClipboard(pathTool.commandForShell(shellOptions[shellBox.currentIndex], pathToAddInput.text))

                                background: Rectangle {
                                    color: parent.hovered ? "#006cbd" : "#0078d4"
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

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                color: "#e0e0e0"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("envPathTip") || "提示：应用读取的是当前进程环境变量，修改系统PATH后可能需要重启应用才能看到最新值。"
                                font.pixelSize: 12
                                color: "#888"
                                wrapMode: Text.WordWrap
                            }

                            Button {
                                text: I18n.t("envPathCopyClean") || "复制去重可用PATH"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                onClicked: copyToClipboard(pathTool.uniqueExistingPathText())

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
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: copyFeedback
        width: 160
        height: 40
        radius: 20
        color: "#333"
        opacity: 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30

        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess") || "已复制到剪贴板"
            color: "white"
            font.pixelSize: 13
        }

        function show() {
            opacity = 0.9
            feedbackTimer.restart()
        }

        Timer {
            id: feedbackTimer
            interval: 1500
            onTriggered: copyFeedback.opacity = 0
        }
    }
}
