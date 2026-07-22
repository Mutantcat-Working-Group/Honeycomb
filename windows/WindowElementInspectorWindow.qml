import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: rootWindow
    width: 1180
    height: 760
    minimumWidth: 980
    minimumHeight: 600
    title: I18n.t("toolWindowInspector") || "窗口组件选取"
    flags: Qt.Window
    modality: Qt.NonModal
    color: "#f4f5f7"

    // 当前选中的 Tab（0 自然语言 / 1 路径 / 2 JSON / 3 脚本）
    property int currentTab: 0
    property bool hiddenForCapture: false

    // ===== 复制到剪贴板辅助 =====
    function copyToClipboard(text) {
        clipboardHelper.text = text
        clipboardHelper.selectAll()
        clipboardHelper.copy()
    }

    TextEdit {
        id: clipboardHelper
        visible: false
    }

    // ===== 复制成功 toast =====
    Rectangle {
        id: copyToast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        width: toastLabel.implicitWidth + 48
        height: 44
        radius: 22
        color: "#4caf50"
        visible: false
        z: 200

        Row {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: "✓"
                color: "#ffffff"
                font.pixelSize: 16
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: toastLabel
                text: I18n.t("windowInspectorCopied") || "已复制到剪贴板"
                color: "#ffffff"
                font.pixelSize: 14
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Timer {
            id: toastTimer
            interval: 1600
            onTriggered: copyToast.visible = false
        }
    }

    // ===== 主布局 =====
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ============ 顶部 Header ============
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            color: "#ffffff"

            // 底部分隔线
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#e0e0e0"
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 16

                // 左侧：状态点 + 状态文字
                RowLayout {
                    spacing: 10
                    Rectangle {
                        id: statusDot
                        width: 10
                        height: 10
                        radius: 5
                        color: {
                            if (inspector.capturing) return "#f5a623"
                            if (!inspector.hasAccessibility) return "#e74c3c"
                            return "#4caf50"
                        }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                    Text {
                        text: {
                            if (inspector.capturing) return I18n.t("windowInspectorStatusPicking") || "单击目标组件，Esc 取消"
                            if (!inspector.hasAccessibility) return I18n.t("windowInspectorStatusDenied") || "辅助功能权限未授权"
                            return I18n.t("windowInspectorStatusIdle") || "就绪"
                        }
                        font.pixelSize: 14
                        font.bold: true
                        color: "#1f2937"
                    }
                    Text {
                        text: {
                            if (inspector.foregroundApp.length > 0)
                                return "  ·  " + inspector.foregroundApp + "  (PID: " + inspector.foregroundPid + ")"
                            return ""
                        }
                        font.pixelSize: 12
                        color: "#6b7280"
                    }
                }

                Item { Layout.fillWidth: true }

                // 右侧：主操作按钮组
                RowLayout {
                    spacing: 8
                    // 取消（次按钮）
                    Button {
                        text: I18n.t("windowInspectorCancel") || "取消"
                        implicitHeight: 34
                        leftPadding: 16
                        rightPadding: 16
                        enabled: inspector.capturing
                        onClicked: inspector.cancelCapture()
                        background: Rectangle {
                            radius: 6
                            color: !parent.enabled ? "#f5f5f5"
                                   : (parent.hovered ? "#f0f0f0" : "#ffffff")
                            border.color: "#cccccc"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#333333" : "#c0c0c0"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    // 选取锚点（主按钮）
                    Button {
                        id: startCaptureButton
                        text: inspector.capturing
                              ? (I18n.t("windowInspectorStatusPicking") || "单击目标组件，Esc 取消")
                              : (I18n.t("windowInspectorPickAnchor") || "选取锚点")
                        implicitHeight: 34
                        leftPadding: 18
                        rightPadding: 18
                        enabled: !inspector.capturing && inspector.hasAccessibility
                        onClicked: inspector.startCapture()
                        background: Rectangle {
                            radius: 6
                            color: !parent.enabled ? "#cccccc"
                                   : (parent.hovered ? "#006cbd" : "#0078d4")
                        }
                        contentItem: Row {
                            spacing: 6
                            anchors.centerIn: parent
                            Text {
                                text: "⌖"
                                color: "#ffffff"
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: startCaptureButton.text
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
        }

        // ============ 主体 ============
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // ============ 左侧：设置 + 最近 ============
            Rectangle {
                Layout.preferredWidth: 320
                Layout.fillHeight: true
                color: "#ffffff"
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: "#e0e0e0"
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // ===== 权限提示卡片（条件显示）=====
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: permCol.implicitHeight + 24
                        visible: !inspector.hasAccessibility
                        color: "#fffbeb"
                        border.color: "#fcd34d"
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            id: permCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Text {
                                    text: "⚠"
                                    font.pixelSize: 14
                                    color: "#b45309"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    text: I18n.t("windowInspectorPermTitle") || "需要辅助功能权限"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#92400e"
                                    Layout.fillWidth: true
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: I18n.t("windowInspectorPermDesc") || "macOS 需要在「系统设置 → 隐私与安全性 → 辅助功能」中勾选本应用。"
                                font.pixelSize: 11
                                color: "#92400e"
                                lineHeight: 1.4
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Item { Layout.fillWidth: true }
                                Button {
                                    text: I18n.t("windowInspectorPermRecheck") || "重新检查"
                                    implicitHeight: 26
                                    onClicked: inspector.recheckPermissions()
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? "#fde68a" : "#fef3c7"
                                        border.color: "#fcd34d"
                                        border.width: 1
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#92400e"
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                Button {
                                    text: I18n.t("windowInspectorPermOpen") || "打开设置"
                                    implicitHeight: 26
                                    onClicked: inspector.openAccessibilitySettings()
                                    background: Rectangle {
                                        radius: 4
                                        color: parent.hovered ? "#006cbd" : "#0078d4"
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        color: "#ffffff"
                                        font.pixelSize: 11
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                            }
                        }
                    }

                    // ===== Wayland 提示 =====
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: wlCol.implicitHeight + 20
                        visible: inspector.isWayland
                        color: "#eff6ff"
                        border.color: "#93c5fd"
                        border.width: 1
                        radius: 8
                        RowLayout {
                            id: wlCol
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8
                            Text {
                                text: "ℹ"
                                font.pixelSize: 14
                                color: "#1e40af"
                            }
                            Text {
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                text: I18n.t("windowInspectorStatusWayland") || "检测到 Wayland：全局快捷键不可用"
                                font.pixelSize: 11
                                color: "#1e40af"
                                lineHeight: 1.4
                            }
                        }
                    }

                    // ===== 触发设置卡片 =====
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: triggerCol.implicitHeight + 24
                        color: "#fafbfc"
                        border.color: "#e5e7eb"
                        border.width: 1
                        radius: 8

                        ColumnLayout {
                            id: triggerCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 10

                            // 卡片标题
                            Text {
                                text: "⚡  " + (I18n.t("windowInspectorTrigger") || "触发方式")
                                font.pixelSize: 13
                                font.bold: true
                                color: "#1f2937"
                            }

                            // 全局热键
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: I18n.t("windowInspectorHotkey") || "全局热键"
                                    font.pixelSize: 11
                                    color: "#6b7280"
                                }
                                RowLayout {
                                    spacing: 6
                                    TextField {
                                        id: hotkeyField
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 30
                                        text: inspector.hotkey
                                        enabled: !inspector.isWayland
                                        font.pixelSize: 12
                                        color: "#1f2937"
                                        background: Rectangle {
                                            radius: 4
                                            color: "#ffffff"
                                            border.color: hotkeyField.activeFocus ? "#0078d4" : "#d1d5db"
                                            border.width: 1
                                        }
                                        leftPadding: 10
                                        onEditingFinished: inspector.hotkey = text
                                    }
                                    Button {
                                        text: I18n.t("windowInspectorRecordHotkey") || "应用"
                                        implicitHeight: 30
                                        implicitWidth: 56
                                        enabled: !inspector.isWayland
                                        onClicked: {
                                            inspector.hotkey = hotkeyField.text
                                            inspector.unregisterHotkey()
                                            inspector.registerHotkey()
                                        }
                                        background: Rectangle {
                                            radius: 4
                                            color: !parent.enabled ? "#f5f5f5"
                                                   : (parent.hovered ? "#f0f0f0" : "#ffffff")
                                            border.color: "#cccccc"
                                            border.width: 1
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            color: parent.enabled ? "#333333" : "#c0c0c0"
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: inspector.armed
                                          ? (I18n.t("windowInspectorHotkeyReady") || "快捷键已启用")
                                          : (I18n.t("windowInspectorHotkeyInactive") || "快捷键未启用")
                                    color: inspector.armed ? "#16a34a" : "#9ca3af"
                                    font.pixelSize: 10
                                }
                            }

                            // 进入选取模式前的缓冲时间
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: I18n.t("windowInspectorDelay") || "启动延迟"
                                        font.pixelSize: 11
                                        color: "#6b7280"
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: Math.round(delaySlider.value) + " ms"
                                        font.pixelSize: 11
                                        color: "#0078d4"
                                        font.bold: true
                                    }
                                }
                                Slider {
                                    id: delaySlider
                                    Layout.fillWidth: true
                                    from: 0
                                    to: 1500
                                    stepSize: 100
                                    value: inspector.delayMs
                                    onMoved: inspector.delayMs = value
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                visible: inspector.lastError.length > 0
                                text: inspector.lastError
                                color: "#dc2626"
                                wrapMode: Text.WordWrap
                                font.pixelSize: 10
                            }
                        }
                    }

                    // ===== 最近抓取 =====
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "🕐  " + (I18n.t("windowInspectorRecent") || "最近抓取")
                                font.pixelSize: 13
                                font.bold: true
                                color: "#1f2937"
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: inspector.recent.length + ""
                                font.pixelSize: 11
                                color: "#9ca3af"
                            }
                        }
                        // 空状态
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: inspector.recent.length === 0
                            color: "transparent"
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "🎯"
                                    font.pixelSize: 36
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: I18n.t("windowInspectorEmpty") || "点击「选取锚点」\n或在外部按下快捷键"
                                    horizontalAlignment: Text.AlignHCenter
                                    color: "#9ca3af"
                                    font.pixelSize: 11
                                    lineHeight: 1.4
                                }
                            }
                        }
                        // 列表
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: inspector.recent.length > 0
                            clip: true
                            model: inspector.recent
                            spacing: 6
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 52
                                color: ma.containsMouse ? "#eef4fd" : "#fafbfc"
                                border.color: ma.containsMouse ? "#93c5fd" : "#e5e7eb"
                                border.width: 1
                                radius: 6
                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        inspector.lastPicked = modelData
                                        copyToast.visible = true
                                        toastTimer.restart()
                                    }
                                }
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 2
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6
                                        Rectangle {
                                            width: 4
                                            height: 14
                                            radius: 2
                                            color: "#0078d4"
                                            visible: modelData.role || false
                                        }
                                        Text {
                                            text: modelData.name || modelData.roleDescription || (modelData.role || "未命名")
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#1f2937"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                    Text {
                                        text: (modelData.appName || "未知应用") + "  ·  " + (modelData.pickedAt || "")
                                        font.pixelSize: 10
                                        color: "#9ca3af"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ============ 右侧：Tab 输出区 ============
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Tab Bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: "#ffffff"
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: "#e0e0e0"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 0
                        Repeater {
                            model: [
                                { label: I18n.t("windowInspectorTabNatural") || "自然语言", index: 0, icon: "📝" },
                                { label: I18n.t("windowInspectorTabPath") || "结构化路径", index: 1, icon: "🔗" },
                                { label: I18n.t("windowInspectorTabJson") || "JSON", index: 2, icon: "{ }" },
                                { label: I18n.t("windowInspectorTabScript") || "可执行脚本", index: 3, icon: "⚡" }
                            ]
                            delegate: Rectangle {
                                required property var modelData
                                Layout.preferredWidth: 120
                                Layout.fillHeight: true
                                color: "transparent"
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: parent.width - 12
                                    height: 3
                                    radius: 1.5
                                    color: rootWindow.currentTab === modelData.index ? "#0078d4" : "transparent"
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: rootWindow.currentTab = modelData.index
                                }
                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: modelData.icon
                                        font.pixelSize: 13
                                        color: rootWindow.currentTab === modelData.index ? "#0078d4" : "#9ca3af"
                                    }
                                    Text {
                                        text: modelData.label
                                        font.pixelSize: 13
                                        font.bold: rootWindow.currentTab === modelData.index
                                        color: rootWindow.currentTab === modelData.index ? "#0078d4" : "#6b7280"
                                    }
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                // Tab 内容
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: rootWindow.currentTab

                    // ===== Tab 0: 自然语言 =====
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#f4f5f7"
                                ScrollView {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    TextArea {
                                        id: naturalText
                                        readOnly: true
                                        selectByMouse: true
                                        wrapMode: TextArea.Wrap
                                        font.pixelSize: 14
                                        font.family: Qt.platform.os === "osx" ? "Menlo" : "Consolas"
                                        color: "#1f2937"
                                        text: rootWindow.currentTab === 0 && inspector.lastPickedJson.length > 0
                                              ? inspector.formatNaturalLanguage(inspector.lastPickedJson)
                                              : ""
                                        background: Rectangle {
                                            color: "transparent"
                                            border.color: naturalText.activeFocus ? "#0078d4" : "#e5e7eb"
                                            border.width: 1
                                            radius: 8
                                        }
                                    }
                                }
                            }
                            // 空状态
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: naturalText.text.length === 0
                                color: "#f4f5f7"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 14
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "📝"
                                        font.pixelSize: 56
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: I18n.t("windowInspectorEmpty") || "尚未抓取组件"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#6b7280"
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredWidth: 320
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: I18n.t("windowInspectorEmptyHint") || "进入选取模式后单击目标组件，按 Esc 可取消"
                                        color: "#9ca3af"
                                        font.pixelSize: 12
                                        lineHeight: 1.5
                                    }
                                }
                            }
                        }
                    }

                    // ===== Tab 1: 结构化路径 =====
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#f4f5f7"
                                ScrollView {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    TextArea {
                                        id: pathText
                                        readOnly: true
                                        selectByMouse: true
                                        wrapMode: TextArea.WrapAnywhere
                                        font.family: Qt.platform.os === "osx" ? "Menlo" : "Consolas"
                                        font.pixelSize: 13
                                        color: "#1f2937"
                                        text: rootWindow.currentTab === 1 && inspector.lastPickedJson.length > 0
                                              ? inspector.formatStructuredPath(inspector.lastPickedJson)
                                              : ""
                                        background: Rectangle {
                                            color: "#ffffff"
                                            border.color: pathText.activeFocus ? "#0078d4" : "#e5e7eb"
                                            border.width: 1
                                            radius: 8
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: pathText.text.length === 0
                                color: "#f4f5f7"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 14
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "🔗"; font.pixelSize: 56 }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "路径生成器"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#6b7280"
                                    }
                                }
                            }
                        }
                    }

                    // ===== Tab 2: JSON =====
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#f4f5f7"
                                ScrollView {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    TextArea {
                                        id: jsonText
                                        readOnly: true
                                        selectByMouse: true
                                        wrapMode: TextArea.NoWrap
                                        font.family: Qt.platform.os === "osx" ? "Menlo" : "Consolas"
                                        font.pixelSize: 12
                                        color: "#1f2937"
                                        text: rootWindow.currentTab === 2 && inspector.lastPickedJson.length > 0
                                              ? inspector.formatJsonPretty(inspector.lastPickedJson)
                                              : ""
                                        background: Rectangle {
                                            color: "#ffffff"
                                            border.color: jsonText.activeFocus ? "#0078d4" : "#e5e7eb"
                                            border.width: 1
                                            radius: 8
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: jsonText.text.length === 0
                                color: "#f4f5f7"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 14
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "{ }"; font.pixelSize: 56; color: "#cbd5e1" }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "JSON 视图"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#6b7280"
                                    }
                                }
                            }
                        }
                    }

                    // ===== Tab 3: 可执行脚本 =====
                    Item {
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#f4f5f7"
                                ScrollView {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    TextArea {
                                        id: scriptText
                                        readOnly: true
                                        selectByMouse: true
                                        wrapMode: TextArea.NoWrap
                                        font.family: Qt.platform.os === "osx" ? "Menlo" : "Consolas"
                                        font.pixelSize: 12
                                        color: "#1f2937"
                                        text: rootWindow.currentTab === 3 && inspector.lastPickedJson.length > 0
                                              ? inspector.formatExecutableScript(inspector.lastPickedJson, "auto")
                                              : ""
                                        background: Rectangle {
                                            color: "#1f2937"
                                            border.color: scriptText.activeFocus ? "#0078d4" : "#374151"
                                            border.width: 1
                                            radius: 8
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: scriptText.text.length === 0
                                color: "#f4f5f7"
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 14
                                    Text { Layout.alignment: Qt.AlignHCenter; text: "⚡"; font.pixelSize: 56 }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        text: "可执行脚本生成器"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#6b7280"
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignHCenter
                                        Layout.preferredWidth: 360
                                        horizontalAlignment: Text.AlignHCenter
                                        wrapMode: Text.WordWrap
                                        text: "自动按平台生成 AppleScript / PowerShell / bash 脚本"
                                        color: "#9ca3af"
                                        font.pixelSize: 12
                                        lineHeight: 1.5
                                    }
                                }
                            }
                        }
                    }
                }

                // ===== 底部复制栏（固定在右下）=====
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    color: "#ffffff"
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: 1
                        color: "#e0e0e0"
                    }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 8
                        Text {
                            text: {
                                if (rootWindow.currentTab === 0) return "💡  " + (I18n.t("windowInspectorHintNatural") || "可直接喂给 AI Agent，让它理解你的操作意图")
                                if (rootWindow.currentTab === 1) return "💡  " + (I18n.t("windowInspectorHintPath") || "结构化路径，AI 可直接解析为 XPath/UI 选择器")
                                if (rootWindow.currentTab === 2) return "💡  " + (I18n.t("windowInspectorHintJson") || "完整属性快照，便于调试和自动化脚本生成")
                                return "💡  " + (I18n.t("windowInspectorHintScript") || "按当前平台生成可执行脚本，可直接运行")
                            }
                            font.pixelSize: 12
                            color: "#6b7280"
                            Layout.fillWidth: true
                        }
                        Button {
                            text: "📋  " + (I18n.t("windowInspectorCopied") || "复制到剪贴板")
                            implicitHeight: 32
                            enabled: {
                                if (rootWindow.currentTab === 0) return naturalText.text.length > 0
                                if (rootWindow.currentTab === 1) return pathText.text.length > 0
                                if (rootWindow.currentTab === 2) return jsonText.text.length > 0
                                return scriptText.text.length > 0
                            }
                            onClicked: {
                                var t = ""
                                if (rootWindow.currentTab === 0) t = naturalText.text
                                else if (rootWindow.currentTab === 1) t = pathText.text
                                else if (rootWindow.currentTab === 2) t = jsonText.text
                                else t = scriptText.text
                                rootWindow.copyToClipboard(t)
                                copyToast.visible = true
                                toastTimer.restart()
                            }
                            background: Rectangle {
                                radius: 4
                                color: !parent.enabled ? "#cccccc"
                                       : (parent.hovered ? "#006cbd" : "#0078d4")
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }

    // ===== 主对象 =====
    WindowElementInspector {
        id: inspector
    }

    // 周期性轮询权限状态（每 1.5s），用户切到系统设置授权后回到应用，状态自动更新
    Timer {
        id: permPollTimer
        interval: 1500
        repeat: true
        running: rootWindow.visible
        onTriggered: inspector.recheckPermissions()
    }
    Component.onCompleted: {
        inspector.recheckPermissions()
        if (inspector.hasAccessibility && !inspector.isWayland)
            inspector.registerHotkey()
    }

    // 当抓到新元素时，默认切到「自然语言」Tab + 自动复制
    Connections {
        target: inspector
        function onHasAccessibilityChanged() {
            if (inspector.hasAccessibility && !inspector.armed && !inspector.isWayland)
                inspector.registerHotkey()
        }
        function onCapturingChanged() {
            if (inspector.capturing) {
                rootWindow.hiddenForCapture = true
                if (rootWindow.visible) {
                    rootWindow.hide()
                }
            } else if (rootWindow.hiddenForCapture) {
                rootWindow.hiddenForCapture = false
                rootWindow.show()
                rootWindow.raise()
                rootWindow.requestActivate()
            }
        }
        function onElementPicked(info) {
            if (!rootWindow.visible) {
                rootWindow.show()
                rootWindow.raise()
                rootWindow.requestActivate()
            }
            rootWindow.currentTab = 0
            var txt = inspector.formatNaturalLanguage(inspector.lastPickedJson)
            rootWindow.copyToClipboard(txt)
            copyToast.visible = true
            toastTimer.restart()
        }
    }
}
