import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Window
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: spriteWindow
    width: 900
    height: 720
    minimumWidth: 780
    minimumHeight: 620
    title: I18n.t("toolSpritePlayer") || "精灵图播放"
    flags: Qt.Window
    modality: Qt.NonModal

    // ===== 分割与播放状态 =====
    property string sheetPath: ""
    property int layoutMode: 0          // 0 行列网格 / 1 帧尺寸
    property int gridColumns: 4
    property int gridRows: 4
    property int frameWidth: 64
    property int frameHeight: 64
    property int spacingX: 0
    property int spacingY: 0
    property int offsetX: 0
    property int offsetY: 0
    property int frameCount: 0          // 0 = 自动
    property int direction: 0           // 0 横向排列 / 1 纵向排列（帧尺寸模式）
    property bool mirrorHorizontal: false
    property bool mirrorVertical: false
    property int fps: 12
    property real zoom: 2.0
    property int currentFrame: 0
    property bool playing: false

    function localUrl(path) {
        if (!path || path.length === 0) {
            return ""
        }
        var text = String(path).replace(/\\/g, "/")
        if (/^(https?|file|qrc|data):/i.test(text)) {
            return text
        }
        if (/^\/+[A-Za-z]:\//.test(text)) {
            text = text.replace(/^\/+/, "")
        }
        if (/^[A-Za-z]:\//.test(text)) {
            return "file:///" + text
        }
        if (/^\/\//.test(text)) {
            return "file:" + text
        }
        return "file://" + text
    }

    // FileDialog 给回来的是 file:// URL，转回本地路径再回填输入框
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

    readonly property int sheetW: sheetImage.status === Image.Ready ? sheetImage.sourceSize.width : 0
    readonly property int sheetH: sheetImage.status === Image.Ready ? sheetImage.sourceSize.height : 0

    // 总帧数
    function effectiveFrameCount() {
        if (sheetW <= 0 || sheetH <= 0) {
            return 0
        }
        if (layoutMode === 0) {
            return effectiveColumns() * effectiveRows()
        }
        if (frameCount > 0) {
            return frameCount
        }
        if (direction === 0) {
            return Math.max(1, Math.floor((sheetW - offsetX + spacingX) / (frameWidth + spacingX)))
        }
        return Math.max(1, Math.floor((sheetH - offsetY + spacingY) / (frameHeight + spacingY)))
    }

    function effectiveColumns() {
        if (layoutMode === 0) {
            return Math.max(1, gridColumns)
        }
        if (direction === 0) {
            return effectiveFrameCount()
        }
        return 1
    }

    function effectiveRows() {
        if (layoutMode === 0) {
            return Math.max(1, gridRows)
        }
        return direction === 1 ? effectiveFrameCount() : 1
    }

    // 网格模式下由原图尺寸反推单元格宽高
    function effectiveCellWidth() {
        if (layoutMode !== 0) {
            return Math.max(1, frameWidth)
        }
        if (sheetW <= 0) {
            return Math.max(1, frameWidth)
        }
        var cols = effectiveColumns()
        return Math.max(1, Math.floor((sheetW - offsetX - (cols - 1) * spacingX) / cols))
    }

    function effectiveCellHeight() {
        if (layoutMode !== 0) {
            return Math.max(1, frameHeight)
        }
        if (sheetH <= 0) {
            return Math.max(1, frameHeight)
        }
        var rows = effectiveRows()
        return Math.max(1, Math.floor((sheetH - offsetY - (rows - 1) * spacingY) / rows))
    }

    function currentFrameX() {
        var i = Math.max(0, Math.min(currentFrame, effectiveFrameCount() - 1))
        var col = i % effectiveColumns()
        var cw = effectiveCellWidth()
        var ch = effectiveCellHeight()
        if (layoutMode !== 0 && direction === 1) {
            return offsetX
        }
        return offsetX + col * (cw + spacingX)
    }

    function currentFrameY() {
        var i = Math.max(0, Math.min(currentFrame, effectiveFrameCount() - 1))
        var row = Math.floor(i / effectiveColumns())
        var ch = effectiveCellHeight()
        if (layoutMode !== 0 && direction === 0) {
            return offsetY
        }
        return offsetY + row * (ch + spacingY)
    }

    function stepFrame(delta) {
        var total = effectiveFrameCount()
        if (total <= 0) {
            return
        }
        currentFrame = ((currentFrame + delta) % total + total) % total
    }

    onFrameCountChanged: if (currentFrame >= effectiveFrameCount()) { currentFrame = 0 }

    FileDialog {
        id: openDialog
        title: I18n.t("spriteSelectImage") || "选择精灵图"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Image (*.png *.jpg *.jpeg *.bmp *.gif *.webp)", "All files (*)"]
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        onAccepted: {
            var localPath = urlToLocalPath(openDialog.selectedFile.toString())
            sheetPath = localPath
            sheetField.text = localPath
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            // ===== 标题 =====
            Column {
                Layout.fillWidth: true
                spacing: 4
                Text { text: I18n.t("toolSpritePlayer") || "精灵图播放"; font.pixelSize: 22; font.bold: true; color: "#333" }
                Text { text: I18n.t("toolSpritePlayerDesc") || "加载精灵图，配置分割并预览逐帧动画，支持水平/垂直镜像"; font.pixelSize: 13; color: "#666" }
            }

            // ===== 文件选择 =====
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: "white"
                    border.color: spriteDropArea.containsDrag ? "#1976d2" : (sheetField.activeFocus ? "#1976d2" : "#e0e0e0")
                    border.width: (spriteDropArea.containsDrag || sheetField.activeFocus) ? 2 : 1
                    radius: 4
                    TextField {
                        id: sheetField
                        anchors.fill: parent
                        anchors.margins: 1
                        placeholderText: spriteDropArea.containsDrag
                                         ? (I18n.t("spriteDropTip") || "松开后载入精灵图")
                                         : (I18n.t("spritePathPlaceholder") || "请输入图片路径，或拖入精灵图...")
                        font.pixelSize: 14
                        selectByMouse: true
                        background: null
                        onTextChanged: sheetPath = text
                        onAccepted: sheetPath = text
                    }
                    DropArea {
                        id: spriteDropArea
                        anchors.fill: parent
                        onDropped: function(drop) {
                            var path = pathFromDrop(drop)
                            sheetField.text = path
                            sheetPath = path
                            drop.accept()
                        }
                    }
                }
                Button {
                    text: I18n.t("spriteSelectImage") || "选择图片"
                    Layout.preferredWidth: 96
                    Layout.preferredHeight: 38
                    onClicked: openDialog.open()
                    background: Rectangle { color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2"); radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }

            // ===== 主体：配置 + 预览 =====
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // --- 左：分割配置 ---
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 14
                        clip: true
                        ColumnLayout {
                            width: 252
                            spacing: 10

                            Text { text: I18n.t("spriteSegment") || "分割配置"; font.pixelSize: 15; font.bold: true; color: "#333" }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteLayoutMode") || "布局模式"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                ComboBox {
                                    Layout.fillWidth: true
                                    model: [I18n.t("spriteModeGrid") || "行列网格", I18n.t("spriteModeSize") || "帧尺寸"]
                                    currentIndex: spriteWindow.layoutMode
                                    onCurrentIndexChanged: spriteWindow.layoutMode = currentIndex
                                }
                            }

                            // 网格模式参数
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: spriteWindow.layoutMode === 0
                                Text { text: I18n.t("spriteColumns") || "列数"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 1; to: 4096; value: spriteWindow.gridColumns; onValueChanged: spriteWindow.gridColumns = value }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: spriteWindow.layoutMode === 0
                                Text { text: I18n.t("spriteRows") || "行数"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 1; to: 4096; value: spriteWindow.gridRows; onValueChanged: spriteWindow.gridRows = value }
                            }

                            // 帧尺寸参数
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: spriteWindow.layoutMode === 1
                                Text { text: I18n.t("spriteFrameWidth") || "帧宽"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 1; to: 16384; value: spriteWindow.frameWidth; onValueChanged: spriteWindow.frameWidth = value }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: spriteWindow.layoutMode === 1
                                Text { text: I18n.t("spriteFrameHeight") || "帧高"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 1; to: 16384; value: spriteWindow.frameHeight; onValueChanged: spriteWindow.frameHeight = value }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: spriteWindow.layoutMode === 1
                                Text { text: I18n.t("spriteDirection") || "排列方向"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                ComboBox {
                                    Layout.fillWidth: true
                                    model: [I18n.t("spriteDirHorizontal") || "横向排列", I18n.t("spriteDirVertical") || "纵向排列"]
                                    currentIndex: spriteWindow.direction
                                    onCurrentIndexChanged: spriteWindow.direction = currentIndex
                                }
                            }

                            // 间距与偏移
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteSpacingX") || "横向间距"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 0; to: 4096; value: spriteWindow.spacingX; onValueChanged: spriteWindow.spacingX = value }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteSpacingY") || "纵向间距"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 0; to: 4096; value: spriteWindow.spacingY; onValueChanged: spriteWindow.spacingY = value }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteOffsetX") || "偏移X"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 0; to: 16384; value: spriteWindow.offsetX; onValueChanged: spriteWindow.offsetX = value }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteOffsetY") || "偏移Y"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 0; to: 16384; value: spriteWindow.offsetY; onValueChanged: spriteWindow.offsetY = value }
                            }

                            // 帧数与帧率
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteFrameCount") || "帧数"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 0; to: 100000; value: spriteWindow.frameCount; onValueChanged: spriteWindow.frameCount = value }
                            }
                            Text { text: I18n.t("spriteFrameCountAuto") || "填 0 为自动"; font.pixelSize: 11; color: "#999" }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: I18n.t("spriteFps") || "帧率 FPS"; font.pixelSize: 13; color: "#666"; Layout.preferredWidth: 64 }
                                SpinBox { Layout.fillWidth: true; from: 1; to: 60; value: spriteWindow.fps; onValueChanged: spriteWindow.fps = value }
                            }

                            // 镜像
                            Text { text: I18n.t("spriteMirror") || "镜像播放"; font.pixelSize: 13; color: "#666" }
                            CheckBox { text: I18n.t("spriteMirrorH") || "水平镜像"; checked: spriteWindow.mirrorHorizontal; onToggled: spriteWindow.mirrorHorizontal = checked }
                            CheckBox { text: I18n.t("spriteMirrorV") || "垂直镜像"; checked: spriteWindow.mirrorVertical; onToggled: spriteWindow.mirrorVertical = checked }
                        }
                    }
                }

                // --- 右：预览与播放控制 ---
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
                        spacing: 12

                        // 原图（不可见，仅用于提供源与尺寸）
                        Image {
                            id: sheetImage
                            visible: false
                            asynchronous: false
                            cache: true
                            source: spriteWindow.sheetPath.length > 0 ? spriteWindow.localUrl(spriteWindow.sheetPath) : ""
                            onStatusChanged: if (status === Image.Ready) { spriteWindow.playing = false; spriteWindow.currentFrame = 0 }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#f0f0f0"
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4
                            clip: true

                            // 棋盘格背景，凸显透明区域
                            Canvas {
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

                            Item {
                                anchors.centerIn: parent
                                width: Math.round(spriteWindow.effectiveCellWidth() * spriteWindow.zoom)
                                height: Math.round(spriteWindow.effectiveCellHeight() * spriteWindow.zoom)
                                visible: sheetImage.status === Image.Ready
                                clip: true
                                transform: Scale {
                                    xScale: spriteWindow.mirrorHorizontal ? -1 : 1
                                    yScale: spriteWindow.mirrorVertical ? -1 : 1
                                }
                                Image {
                                    x: -Math.round(spriteWindow.currentFrameX() * spriteWindow.zoom)
                                    y: -Math.round(spriteWindow.currentFrameY() * spriteWindow.zoom)
                                    width: Math.round(spriteWindow.sheetW * spriteWindow.zoom)
                                    height: Math.round(spriteWindow.sheetH * spriteWindow.zoom)
                                    source: sheetImage.source
                                    fillMode: Image.PadImage
                                    smooth: false
                                    cache: true
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: sheetImage.status !== Image.Ready
                                text: sheetImage.status === Image.Loading
                                      ? (I18n.t("spriteLoading") || "正在加载...")
                                      : (I18n.t("spriteLoadFirst") || "请先加载精灵图")
                                font.pixelSize: 14
                                color: "#888"
                            }
                        }

                        // 播放控制
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Button {
                                text: "◀"
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 34
                                enabled: sheetImage.status === Image.Ready
                                onClicked: spriteWindow.stepFrame(-1)
                                background: Rectangle { color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "white") : "#f5f5f5"; border.color: "#e0e0e0"; border.width: 1; radius: 4 }
                                contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            Button {
                                text: spriteWindow.playing ? (I18n.t("spritePause") || "暂停") : (I18n.t("spritePlay") || "播放")
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 34
                                enabled: sheetImage.status === Image.Ready
                                onClicked: spriteWindow.playing = !spriteWindow.playing
                                background: Rectangle { color: parent.enabled ? (parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")) : "#ccc"; radius: 4 }
                                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            Button {
                                text: "▶"
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 34
                                enabled: sheetImage.status === Image.Ready
                                onClicked: spriteWindow.stepFrame(1)
                                background: Rectangle { color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "white") : "#f5f5f5"; border.color: "#e0e0e0"; border.width: 1; radius: 4 }
                                contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            Text {
                                Layout.fillWidth: true
                                text: (I18n.t("spriteFrameInfo") || "帧 {0}/{1}").replace("{0}", (spriteWindow.currentFrame + 1)).replace("{1}", spriteWindow.effectiveFrameCount())
                                font.pixelSize: 13
                                color: "#555"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            Text { text: (I18n.t("spriteZoom") || "缩放") + " " + spriteWindow.zoom.toFixed(1) + "×"; font.pixelSize: 12; color: "#666" }
                            Slider {
                                Layout.preferredWidth: 120
                                from: 0.5
                                to: 6
                                stepSize: 0.5
                                value: spriteWindow.zoom
                                onValueChanged: spriteWindow.zoom = value
                            }
                        }

                        // 尺寸信息
                        Text {
                            Layout.fillWidth: true
                            visible: sheetImage.status === Image.Ready
                            text: (I18n.t("spriteSheetSize") || "原图") + ": " + spriteWindow.sheetW + "×" + spriteWindow.sheetH
                                  + "    " + (I18n.t("spriteCellSize") || "单帧") + ": "
                                  + spriteWindow.effectiveCellWidth() + "×" + spriteWindow.effectiveCellHeight()
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                }
            }
        }
    }

    Timer {
        running: spriteWindow.playing
        interval: Math.max(16, Math.round(1000 / Math.max(1, spriteWindow.fps)))
        repeat: true
        onTriggered: spriteWindow.stepFrame(1)
    }
}
