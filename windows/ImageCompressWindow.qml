import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: imageCompressWindow
    width: 860
    height: 680
    minimumWidth: 760
    minimumHeight: 560
    title: I18n.t("toolImageCompress") || "图片压缩"
    flags: Qt.Window
    modality: Qt.NonModal

    property var formatOptions: ["jpeg", "png", "bmp"]
    property var qualityOptions: [
        { label: I18n.t("imageQualityTiny") || "极限压缩", quality: 25 },
        { label: I18n.t("imageQualityLow") || "低质量", quality: 40 },
        { label: I18n.t("imageQualityMedium") || "中等质量", quality: 55 },
        { label: I18n.t("imageQualityBalanced") || "均衡", quality: 70 },
        { label: I18n.t("imageQualityHigh") || "高质量", quality: 82 },
        { label: I18n.t("imageQualityVeryHigh") || "超高质量", quality: 92 },
        { label: I18n.t("imageQualityOriginal") || "接近原图", quality: 100 }
    ]
    property var sizeOptions: [
        { label: I18n.t("imageSizeOriginal") || "保持原尺寸", width: 0, height: 0 },
        { label: "3840px", width: 3840, height: 3840 },
        { label: "2560px", width: 2560, height: 2560 },
        { label: "1920px", width: 1920, height: 1920 },
        { label: "1600px", width: 1600, height: 1600 },
        { label: "1280px", width: 1280, height: 1280 },
        { label: "1024px", width: 1024, height: 1024 },
        { label: "800px", width: 800, height: 800 }
    ]

    FileUtilityTool {
        id: fileTool
    }

    Component.onCompleted: {
        var supported = fileTool.supportedWriteImageFormats()
        var preferred = ["jpeg", "jpg", "png", "webp", "bmp", "tiff"]
        var available = []
        for (var i = 0; i < preferred.length; ++i) {
            if (supported.indexOf(preferred[i]) !== -1 && available.indexOf(preferred[i]) === -1) {
                available.push(preferred[i])
            }
        }
        formatOptions = available.length > 0 ? available : supported
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

    function selectedFormat() {
        return formatOptions[formatBox.currentIndex]
    }

    function selectedQuality() {
        return qualityOptions[qualityBox.currentIndex].quality
    }

    function selectedMaxWidth() {
        return sizeOptions[sizeBox.currentIndex].width
    }

    function selectedMaxHeight() {
        return sizeOptions[sizeBox.currentIndex].height
    }

    function refreshOutputPath() {
        if (filePathInput.text.length > 0) {
            fileTool.filePath = filePathInput.text
            outputPathInput.text = fileTool.defaultCompressedImagePath(selectedFormat())
        }
    }

    function acceptFilePath(path) {
        if (path.length === 0) {
            return
        }
        filePathInput.text = path
        fileTool.filePath = path
        refreshOutputPath()
    }

    function compress() {
        fileTool.filePath = filePathInput.text
        fileTool.compressImage(outputPathInput.text, selectedFormat(), selectedQuality(), selectedMaxWidth(), selectedMaxHeight())
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
                    text: I18n.t("toolImageCompress") || "图片压缩"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }

                Text {
                    text: I18n.t("toolImageCompressDesc") || "支持多格式图片压缩与尺寸限制"
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
                spacing: 14

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    color: "white"
                    border.color: imageDropArea.containsDrag ? "#1976d2" : (filePathInput.activeFocus ? "#1976d2" : "#e0e0e0")
                    border.width: (imageDropArea.containsDrag || filePathInput.activeFocus) ? 2 : 1
                    radius: 4

                    TextField {
                        id: filePathInput
                        anchors.fill: parent
                        anchors.margins: 1
                        placeholderText: imageDropArea.containsDrag
                                         ? (I18n.t("imageCompressDropTip") || "松开后填入图片路径")
                                         : (I18n.t("imagePathPlaceholder") || "请输入图片完整路径，或拖入图片...")
                        font.pixelSize: 14
                        selectByMouse: true
                        onTextChanged: fileTool.filePath = text
                        onAccepted: refreshOutputPath()
                        background: null
                    }

                    DropArea {
                        id: imageDropArea
                        anchors.fill: parent
                        onDropped: function(drop) {
                            acceptFilePath(pathFromDrop(drop))
                            drop.accept()
                        }
                    }
                }

                Button {
                    text: I18n.t("generateBtn") || "生成"
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 38
                    onClicked: refreshOutputPath()

                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                Layout.preferredHeight: 178

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        ColumnLayout {
                            Layout.preferredWidth: 140
                            spacing: 6
                            Text { text: I18n.t("imageOutputFormat") || "输出格式"; font.pixelSize: 13; color: "#666" }
                            ComboBox {
                                id: formatBox
                                Layout.fillWidth: true
                                model: formatOptions
                                currentIndex: 0
                                onCurrentIndexChanged: refreshOutputPath()
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 170
                            spacing: 6
                            Text { text: I18n.t("imageQualityLevel") || "压缩档位"; font.pixelSize: 13; color: "#666" }
                            ComboBox {
                                id: qualityBox
                                Layout.fillWidth: true
                                model: qualityOptions.map(function(item) { return item.label })
                                currentIndex: 3
                            }
                        }

                        ColumnLayout {
                            Layout.preferredWidth: 150
                            spacing: 6
                            Text { text: I18n.t("imageMaxSize") || "最大边长"; font.pixelSize: 13; color: "#666" }
                            ComboBox {
                                id: sizeBox
                                Layout.fillWidth: true
                                model: sizeOptions.map(function(item) { return item.label })
                                currentIndex: 0
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: I18n.t("compressBtn") || "压缩"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 38
                            Layout.alignment: Qt.AlignBottom
                            onClicked: compress()

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
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: I18n.t("imageOutputPath") || "输出路径"
                            font.pixelSize: 13
                            color: "#666"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            color: "#f8f9fa"
                            border.color: outputPathInput.activeFocus ? "#1976d2" : "#e9ecef"
                            border.width: outputPathInput.activeFocus ? 2 : 1
                            radius: 4

                            TextField {
                                id: outputPathInput
                                anchors.fill: parent
                                anchors.margins: 1
                                placeholderText: I18n.t("imageOutputPathPlaceholder") || "留空时自动生成"
                                font.pixelSize: 13
                                selectByMouse: true
                                background: null
                            }
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
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: I18n.t("imageCompressResult") || "压缩结果"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: I18n.t("copyPath") || "复制路径"
                            enabled: fileTool.imageOutputPath.length > 0
                            onClicked: copyToClipboard(fileTool.imageOutputPath)

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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f8f9fa"
                        border.color: "#e9ecef"
                        border.width: 1
                        radius: 4

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Text {
                                text: fileTool.imageOutputPath.length > 0
                                      ? (I18n.t("imageOutputPath") || "输出路径") + ": " + fileTool.imageOutputPath
                                      : (I18n.t("imageCompressResultPlaceholder") || "压缩后显示输出文件和体积变化")
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                color: fileTool.imageOutputPath.length > 0 ? "#333" : "#888"
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: fileTool.imageOutputPath.length > 0
                                      ? (I18n.t("imageOriginalSize") || "原始大小") + ": " + fileTool.formatFileSize(fileTool.originalSize)
                                        + "    " + (I18n.t("imageCompressedSize") || "压缩后") + ": " + fileTool.formatFileSize(fileTool.compressedSize)
                                      : ""
                                Layout.fillWidth: true
                                font.pixelSize: 13
                                color: "#666"
                            }

                            Text {
                                text: fileTool.imageOutputPath.length > 0 && fileTool.originalSize > 0
                                      ? (I18n.t("imageSaved") || "节省") + ": " + Math.max(0, Math.round((1 - fileTool.compressedSize / fileTool.originalSize) * 100)) + "%"
                                      : ""
                                Layout.fillWidth: true
                                font.pixelSize: 18
                                font.bold: true
                                color: "#2e7d32"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (I18n.t("imageFormatTip") || "读取格式") + ": " + fileTool.supportedReadImageFormats().join(", ")
                                font.pixelSize: 12
                                color: "#888"
                                wrapMode: Text.WordWrap
                            }
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
