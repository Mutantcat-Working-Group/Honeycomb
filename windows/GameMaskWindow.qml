import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: maskWindow
    width: 860
    height: 660
    minimumWidth: 720
    minimumHeight: 560
    title: I18n.t("toolGameMask") || "黑白透明遮罩"
    flags: Qt.Window
    modality: Qt.NonModal

    // 三个矩形的像素宽高
    property int blackW: 256
    property int blackH: 256
    property int whiteW: 256
    property int whiteH: 256
    property int clearW: 256
    property int clearH: 256
    property string maskUrl: ""
    property string savedPath: ""

    readonly property int totalW: blackW + whiteW + clearW
    readonly property int totalH: Math.max(blackH, Math.max(whiteH, clearH))

    GameAssetGenerator {
        id: generator
    }

    function currentDataUrl() {
        return generator.maskDataUrl(blackW, blackH, whiteW, whiteH, clearW, clearH)
    }

    function refreshPreview() {
        maskUrl = currentDataUrl()
    }

    function saveTo(path) {
        var ok = generator.saveMask(path, blackW, blackH, whiteW, whiteH, clearW, clearH)
        if (ok) {
            savedPath = path
            toast.text = (I18n.t("gameMaskSavedTo") || "已保存到：{0}").replace("{0}", path)
        } else {
            toast.text = I18n.t("gameMaskSaveFailed") || "保存失败"
        }
        toast.show()
    }

    Component.onCompleted: refreshDebounce.start()

    // 参数变化后稍作防抖，避免频繁重建 base64
    Timer {
        id: refreshDebounce
        interval: 150
        onTriggered: maskWindow.refreshPreview()
    }

    function schedulePreview() {
        refreshDebounce.restart()
    }

    // FileDialog 给回来的是 file:// URL，转回本地路径
    function urlToLocalPath(value) {
        if (!value || value.length === 0) {
            return ""
        }
        var text = String(value)
        if (!/^file:/i.test(text)) {
            return text
        }
        var m = text.match(/^file:\/\/([^/]*)\/(.*)$/i)
        if (!m) {
            var rest = text.replace(/^file:/i, "").replace(/^\/*/, "")
            return rest.length === 0 ? "" : "/" + rest
        }
        var host = m[1]
        var tail = m[2]
        if (/^localhost$/i.test(host)) {
            return "/" + tail
        }
        if (host.length === 0) {
            // file:///x，空主机即本机；Windows 盘符不带前导斜杠
            return /^[A-Za-z]:[\\/]/.test(tail) ? tail : "/" + tail
        }
        return "//" + host + "/" + tail
    }

    FileDialog {
        id: saveDialog
        title: I18n.t("gameMaskSelectSave") || "选择保存位置"
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG Image (*.png)", "All files (*)"]
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            var path = urlToLocalPath(saveDialog.selectedFile.toString())
            if (!/\.png$/i.test(path)) {
                path += ".png"
            }
            maskWindow.saveTo(path)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            Column {
                Layout.fillWidth: true
                spacing: 4
                Text { text: I18n.t("toolGameMask") || "黑白透明遮罩"; font.pixelSize: 22; font.bold: true; color: "#333" }
                Text { text: I18n.t("toolGameMaskDesc") || "生成横向排列的黑/白/透明三色块底图，可分别指定宽高并保存为 PNG"; font.pixelSize: 13; color: "#666" }
            }

            // ===== 配置卡片 =====
            Rectangle {
                Layout.fillWidth: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                Layout.preferredHeight: 176

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    // 黑色矩形
                    MaskRectRow {
                        title: I18n.t("gameMaskBlack") || "黑色矩形"
                        swatchColor: "#000000"
                        widthValue: maskWindow.blackW
                        heightValue: maskWindow.blackH
                        onWidthEdited: function(v) { maskWindow.blackW = v; schedulePreview() }
                        onHeightEdited: function(v) { maskWindow.blackH = v; schedulePreview() }
                    }
                    // 白色矩形
                    MaskRectRow {
                        title: I18n.t("gameMaskWhite") || "白色矩形"
                        swatchColor: "#ffffff"
                        widthValue: maskWindow.whiteW
                        heightValue: maskWindow.whiteH
                        onWidthEdited: function(v) { maskWindow.whiteW = v; schedulePreview() }
                        onHeightEdited: function(v) { maskWindow.whiteH = v; schedulePreview() }
                    }
                    // 透明矩形
                    MaskRectRow {
                        title: I18n.t("gameMaskClear") || "透明矩形"
                        swatchColor: "transparent"
                        checker: true
                        widthValue: maskWindow.clearW
                        heightValue: maskWindow.clearH
                        onWidthEdited: function(v) { maskWindow.clearW = v; schedulePreview() }
                        onHeightEdited: function(v) { maskWindow.clearH = v; schedulePreview() }
                    }
                }
            }

            // ===== 预览卡片 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: I18n.t("gameMaskPreview") || "预览"; font.pixelSize: 14; font.bold: true; color: "#333" }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: (I18n.t("gameMaskTotalSize") || "输出尺寸") + ": " + maskWindow.totalW + " × " + maskWindow.totalH + " px"
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f0f0f0"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                        clip: true

                        Canvas {
                            id: checkerBg
                            anchors.fill: parent
                            onPaint: {
                                var ctx = getContext("2d")
                                var cell = 16
                                ctx.clearRect(0, 0, width, height)
                                for (var y = 0; y < height; y += cell) {
                                    for (var x = 0; x < width; x += cell) {
                                        var dark = ((x / cell | 0) + (y / cell | 0)) % 2 === 0
                                        ctx.fillStyle = dark ? "#d9d9d9" : "#ffffff"
                                        ctx.fillRect(x, y, cell, cell)
                                    }
                                }
                            }
                        }

                        Image {
                            id: previewImage
                            anchors.centerIn: parent
                            width: Math.max(24, Math.min(parent.width - 24, maskWindow.totalW))
                            height: Math.max(24, Math.min(parent.height - 24, maskWindow.totalH))
                            source: maskWindow.maskUrl
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: false
                        }
                    }
                }
            }

            // ===== 操作按钮 =====
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    Layout.fillWidth: true
                    text: maskWindow.savedPath.length > 0
                          ? (I18n.t("gameMaskSavedTo") || "已保存到：{0}").replace("{0}", maskWindow.savedPath)
                          : (I18n.t("gameMaskSaveTip") || "三个矩形横向排列，左上角对齐；总高取三者最大值")
                    font.pixelSize: 12
                    color: "#666"
                    elide: Text.ElideMiddle
                }
                Button {
                    text: I18n.t("gameMaskRefresh") || "刷新预览"
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 36
                    onClicked: maskWindow.refreshPreview()
                    background: Rectangle { color: parent.hovered ? "#f0f0f0" : "white"; border.color: "#e0e0e0"; border.width: 1; radius: 4 }
                    contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: I18n.t("gameMaskSave") || "保存 PNG"
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 36
                    onClicked: saveDialog.open()
                    background: Rectangle { color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2"); radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 14; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }

            Text {
                Layout.fillWidth: true
                text: generator.errorMessage
                visible: generator.errorMessage.length > 0
                font.pixelSize: 13
                color: "#c62828"
                wrapMode: Text.WordWrap
            }
        }
    }

    // ===== Toast =====
    Rectangle {
        id: toast
        anchors.centerIn: parent
        width: Math.min(maskWindow.width - 80, 520)
        height: 48
        color: "#333333"
        radius: 6
        opacity: 0
        visible: opacity > 0
        property alias text: toastLabel.text
        Text {
            id: toastLabel
            anchors.centerIn: parent
            width: parent.width - 24
            text: ""
            font.pixelSize: 13
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        function show() {
            opacity = 1
            toastTimer.start()
        }
        Timer {
            id: toastTimer
            interval: 2000
            onTriggered: toast.opacity = 0
        }
    }

    // 单行配置项：色块 + 宽/高
    component MaskRectRow: RowLayout {
        id: rectRow
        property string title: ""
        property color swatchColor: "transparent"
        property bool checker: false
        property int widthValue: 64
        property int heightValue: 64
        signal widthEdited(int value)
        signal heightEdited(int value)

        spacing: 10

        // 色块预览
        Rectangle {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26
            radius: 4
            color: rectRow.checker ? "transparent" : rectRow.swatchColor
            border.color: "#d0d0d0"
            border.width: 1
            Canvas {
                anchors.fill: parent
                visible: rectRow.checker
                onPaint: {
                    var ctx = getContext("2d")
                    var cell = 8
                    ctx.clearRect(0, 0, width, height)
                    for (var y = 0; y < height; y += cell) {
                        for (var x = 0; x < width; x += cell) {
                            var dark = ((x / cell | 0) + (y / cell | 0)) % 2 === 0
                            ctx.fillStyle = dark ? "#bdbdbd" : "#ffffff"
                            ctx.fillRect(x, y, cell, cell)
                        }
                    }
                }
            }
        }

        Text {
            text: rectRow.title
            font.pixelSize: 13
            color: "#333"
            Layout.preferredWidth: 88
        }

        Text { text: I18n.t("gameMaskWidth") || "宽"; font.pixelSize: 12; color: "#666" }
        SpinBox {
            Layout.preferredWidth: 108
            from: 1
            to: 16384
            value: rectRow.widthValue
            onValueChanged: rectRow.widthEdited(value)
        }
        Text { text: I18n.t("gameMaskHeight") || "高"; font.pixelSize: 12; color: "#666" }
        SpinBox {
            Layout.preferredWidth: 108
            from: 1
            to: 16384
            value: rectRow.heightValue
            onValueChanged: rectRow.heightEdited(value)
        }
        Item { Layout.fillWidth: true }
    }
}
