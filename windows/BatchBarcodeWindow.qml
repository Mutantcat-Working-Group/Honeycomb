import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: batchWindow
    width: 640
    height: 620
    minimumWidth: 560
    minimumHeight: 540
    title: I18n.t("toolBatchBarcode") || "批量条形码生成"
    flags: Qt.Window
    modality: Qt.NonModal

    // 完成时结果快照
    property var lastResult: ({ ok: 0, total: 0, dir: "", durationMs: 0, succeeded: false })

    BarcodeGenerator {
        id: batchGen

        onBatchFinished: function(successCount, totalCount, dir) {
            // 用 C++ 端算好的真实耗时(QElapsedTimer)
            var dur = batchGen.batchDurationMs
            var isFail = totalCount > 0 && successCount < totalCount

            // 校验失败 / 无效入参
            if (totalCount === 0) {
                showFeedback(batchGen.batchLastError || "参数无效", "error")
                return
            }

            batchWindow.lastResult = {
                ok: successCount,
                total: totalCount,
                dir: dir,
                durationMs: dur,
                succeeded: !isFail
            }
            progressCard.state = "done"
            if (!isFail) {
                showFeedback(I18n.t("saveSuccess") || "保存成功", "success")
            } else {
                showFeedback(batchGen.batchLastError || "已取消", "warn")
            }
        }
    }

    FolderDialog {
        id: dirDialog
        title: I18n.t("batchBarcodeSelectDir") || "选择文件夹"
        onAccepted: {
            var path = selectedFolder.toString()
            try { path = decodeURIComponent(path) } catch (e) {}
            path = path.replace(/^file:\/\/localhost(?=\/)/i, "")
            path = path.replace(/^file:/i, "")
            if (/^\/+[A-Za-z]:[\\/]/.test(path)) {
                path = path.replace(/^\/+/, "")
            }
            outputDirInput.text = path
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            // === 标题区 ===
            Column {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: I18n.t("toolBatchBarcode") || "批量条形码生成"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#1a1a1a"
                }

                Text {
                    text: I18n.t("toolBatchBarcodeDesc") || "按号段批量生成条形码并保存到文件夹"
                    font.pixelSize: 13
                    color: "#777"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e8e8e8"
            }

            // === 输入表单 ===
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 10

                Text {
                    text: I18n.t("batchBarcodePrefix") || "前缀(可选)"
                    font.pixelSize: 13
                    color: "#333"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: 72
                }

                TextField {
                    id: prefixInput
                    Layout.fillWidth: true
                    placeholderText: "如 AB(可留空)"
                    font.pixelSize: 13
                    selectByMouse: true
                    background: Rectangle {
                        color: "white"
                        border.color: prefixInput.activeFocus ? "#1976d2" : "#e0e0e0"
                        border.width: prefixInput.activeFocus ? 2 : 1
                        radius: 4
                    }
                }

                Text {
                    text: I18n.t("batchBarcodeStart") || "起始号"
                    font.pixelSize: 13
                    color: "#333"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                TextField {
                    id: startInput
                    Layout.fillWidth: true
                    placeholderText: "纯数字,如 1"
                    font.pixelSize: 13
                    inputMethodHints: Qt.ImhDigitsOnly
                    selectByMouse: true
                    background: Rectangle {
                        color: "white"
                        border.color: startInput.activeFocus ? "#1976d2" : "#e0e0e0"
                        border.width: startInput.activeFocus ? 2 : 1
                        radius: 4
                    }
                }

                Text {
                    text: I18n.t("batchBarcodeEnd") || "结束号"
                    font.pixelSize: 13
                    color: "#333"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                TextField {
                    id: endInput
                    Layout.fillWidth: true
                    placeholderText: "纯数字,如 5000"
                    font.pixelSize: 13
                    inputMethodHints: Qt.ImhDigitsOnly
                    selectByMouse: true
                    background: Rectangle {
                        color: "white"
                        border.color: endInput.activeFocus ? "#1976d2" : "#e0e0e0"
                        border.width: endInput.activeFocus ? 2 : 1
                        radius: 4
                    }
                }

                Text {
                    text: I18n.t("batchBarcodeOutputDir") || "输出文件夹"
                    font.pixelSize: 13
                    color: "#333"
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: outputDirInput
                        Layout.fillWidth: true
                        placeholderText: "/path/to/output"
                        font.pixelSize: 13
                        selectByMouse: true
                        background: Rectangle {
                            color: "white"
                            border.color: outputDirInput.activeFocus ? "#1976d2" : "#e0e0e0"
                            border.width: outputDirInput.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }

                    Button {
                        text: I18n.t("batchBarcodeSelectDir") || "选择文件夹"
                        Layout.preferredHeight: 32

                        background: Rectangle {
                            color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "white")
                            border.color: "#1976d2"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "#1976d2"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: dirDialog.open()
                    }
                }
            }

            // === 号段预览(常驻,放在进度卡片上方) ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: previewText.isError ? "#fdecea" : "#e8f0fe"
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: previewText.isError ? "#c62828" : "#1976d2"
                        Text {
                            anchors.centerIn: parent
                            text: previewText.isError ? "!" : "i"
                            color: "white"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    Text {
                        id: previewText
                        Layout.fillWidth: true
                        font.pixelSize: 12
                        color: "#37474f"
                        wrapMode: Text.NoWrap
                        elide: Text.ElideMiddle

                        property bool isError: false

                        Component.onCompleted: update()

                        function update() {
                            var s = parseInt(startInput.text)
                            var e = parseInt(endInput.text)
                            isError = false
                            if (isNaN(s) || isNaN(e) || s <= 0 || e <= 0) {
                                text = I18n.t("batchBarcodeEmptyHint") || "请在上方填写起始号和结束号"
                                return
                            }
                            if (s > e) {
                                text = I18n.t("batchBarcodeInvalidRange") || "起始号必须小于等于结束号"
                                isError = true
                                return
                            }
                            var width = String(e).length
                            var p = prefixInput.text
                            var first = p + (Array(width + 1).join("0") + s).slice(-width)
                            var last = p + (Array(width + 1).join("0") + e).slice(-width)
                            text = (I18n.t("batchBarcodeCountPreview") || "将生成 %1 张,文件名 %2 ~ %3")
                                .replace("%1", e - s + 1)
                                .replace("%2", first)
                                .replace("%3", last)
                        }
                    }
                }
            }

            // === 进度 + 操作区(状态机: idle / running / done) ===
            Rectangle {
                id: progressCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e8e8e8"
                border.width: 1
                radius: 8

                state: "idle"
                states: [
                    State { name: "idle" },
                    State { name: "running" },
                    State {
                        name: "done"
                        PropertyChanges { target: resultStats; opacity: 1; visible: true }
                    }
                ]

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    // === 第一段:进度数字 + 进度条 ===
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: I18n.t("fileChecksumResult") || "生成进度"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#37474f"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: batchGen.batchProgress + " / " + batchGen.batchTotal
                                font.pixelSize: 13
                                color: "#546e7a"
                                font.family: "Consolas, Monaco, monospace"
                            }
                        }

                        ProgressBar {
                            id: progressBar
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            from: 0
                            to: batchGen.batchTotal > 0 ? batchGen.batchTotal : 1
                            value: batchGen.batchProgress
                        }
                    }

                    // === 第二段:操作按钮(一行,两端对齐) ===
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#f0f3f5"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Button {
                            id: startButton
                            text: I18n.t("batchBarcodeStartBtn") || "开始生成"
                            Layout.preferredWidth: 132
                            Layout.preferredHeight: 40
                            enabled: !batchGen.batchRunning
                                  && startInput.text.length > 0
                                  && endInput.text.length > 0
                                  && outputDirInput.text.length > 0

                            background: Rectangle {
                                color: !parent.enabled ? "#cfd8dc"
                                     : (parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2"))
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                progressCard.state = "running"
                                batchGen.generateBatch(
                                    prefixInput.text,
                                    parseInt(startInput.text),
                                    parseInt(endInput.text),
                                    outputDirInput.text
                                )
                            }
                        }

                        Button {
                            id: cancelButton
                            text: I18n.t("batchBarcodeCancelBtn") || "取消"
                            Layout.preferredWidth: 96
                            Layout.preferredHeight: 40
                            visible: batchGen.batchRunning

                            background: Rectangle {
                                color: parent.pressed ? "#c62828" : (parent.hovered ? "#ef5350" : "#f44336")
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: batchGen.cancelBatch()
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            id: retryButton
                            text: I18n.t("batchBarcodeRetry") || "再次生成"
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 96
                            visible: !batchGen.batchRunning && progressCard.state === "done"
                            background: Rectangle {
                                color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f7fa" : "white")
                                border.color: "#1976d2"
                                border.width: 1
                                radius: 6
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#1976d2"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                progressCard.state = "idle"
                                batchGen.clearBatch()
                            }
                        }
                    }

                    // === 第三段:结果统计区(只在 done 状态显示) ===
                    Rectangle {
                        id: resultStats
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        opacity: 0
                        visible: false

                        Behavior on opacity {
                            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            // 顶部小标题行
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Rectangle {
                                    width: 4
                                    height: 14
                                    color: batchWindow.lastResult.succeeded ? "#2e7d32" : "#ef6c00"
                                    radius: 2
                                }

                                Text {
                                    text: batchWindow.lastResult.succeeded
                                          ? (I18n.t("batchBarcodeSuccessTitle") || "生成完成")
                                          : (I18n.t("batchBarcodePartialTitle") || "部分完成")
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: batchWindow.lastResult.succeeded ? "#2e7d32" : "#ef6c00"
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: formatDuration(batchWindow.lastResult.durationMs)
                                    font.pixelSize: 12
                                    color: "#78909c"
                                    font.family: "Consolas, Monaco, monospace"
                                }
                            }

                            // 成功 / 失败 双卡片(等高)
                            GridLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 72
                                columns: 2
                                rowSpacing: 0
                                columnSpacing: 12

                                StatTile {
                                    title: "成功"
                                    value: batchWindow.lastResult.ok
                                    accent: "#2e7d32"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }

                                StatTile {
                                    title: "失败"
                                    value: batchWindow.lastResult.total - batchWindow.lastResult.ok
                                    accent: "#c62828"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }

                            // 输出目录
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                color: "#f5f7fa"
                                radius: 4

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 8

                                    Text {
                                        text: "📁"
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: batchWindow.lastResult.dir
                                        font.pixelSize: 12
                                        color: "#455a64"
                                        font.family: "Consolas, Monaco, monospace"
                                        elide: Text.ElideMiddle
                                        wrapMode: Text.NoWrap
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // === Toast:从底部滑入的彩条 ===
    Rectangle {
        id: feedback
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 60, labelText.implicitWidth + 56)
        height: 42
        radius: 21
        opacity: 0
        visible: opacity > 0
        z: 100

        property string tone: "success"
        color: feedback.tone === "success" ? "#2e7d32"
             : feedback.tone === "warn"    ? "#ef6c00"
             : feedback.tone === "error"   ? "#c62828"
             : "#37474f"

        Text {
            id: labelText
            anchors.centerIn: parent
            text: feedback.message
            color: "white"
            font.pixelSize: 13
            font.bold: true
        }

        property string message: ""

        function show(msg, tone) {
            message = msg
            feedback.tone = tone || "success"
            opacity = 0
            animIn.restart()
        }

        SequentialAnimation on opacity {
            id: animIn
            running: false
            NumberAnimation { from: 0.0; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
            PauseAnimation  { duration: 1800 }
            NumberAnimation { from: 1.0; to: 0.0; duration: 320; easing.type: Easing.InCubic }
            onFinished: feedback.message = ""
        }
    }

    function showFeedback(msg, tone) {
        feedback.show(msg, tone)
    }

    function formatDuration(ms) {
        if (ms <= 0) return "—"
        if (ms < 1000) return ms + " ms"
        var sec = ms / 1000
        if (sec < 60) return sec.toFixed(1) + " 秒"
        var m = Math.floor(sec / 60)
        var s = Math.round(sec % 60)
        return m + " 分 " + s + " 秒"
    }

    // === 单个统计方块 ===
    component StatTile: Rectangle {
        id: tile
        property string title: ""
        property var value: 0
        property color accent: "#1976d2"
        property bool isText: false

        color: "#fafbfc"
        radius: 6
        border.color: Qt.lighter(accent, 1.7)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            Text {
                text: tile.title
                font.pixelSize: 11
                color: "#78909c"
                Layout.fillWidth: true
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: tile.isText ? tile.value : String(tile.value)
                font.pixelSize: tile.isText ? 18 : 22
                font.bold: true
                color: tile.accent
            }
        }
    }

    // 实时刷新数量预览
    Connections {
        target: prefixInput
        function onTextChanged() { previewText.update() }
    }
    Connections {
        target: startInput
        function onTextChanged() { previewText.update() }
    }
    Connections {
        target: endInput
        function onTextChanged() { previewText.update() }
    }
}