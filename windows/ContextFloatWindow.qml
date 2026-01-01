import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: contextFloatWindow
    width: 700
    height: 600
    minimumWidth: 500
    minimumHeight: 400
    title: I18n.t("toolContextFloat") + (windowTag.length > 0 ? " - " + windowTag : "") + (alwaysOnTop ? " [" + I18n.t("contextFloatPinned") + "]" : "")
    flags: alwaysOnTop ? (Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowStaysOnTopHint) : Qt.Window
    modality: Qt.NonModal
    
    // 窗口标签
    property string windowTag: ""
    
    // 置顶状态
    property bool alwaysOnTop: false
    
    // 撤销/重做栈
    property var undoStack: []
    property var redoStack: []
    property bool isUndoRedo: false
    property int maxUndoSteps: 50
    
    // 默认内容
    property string defaultContent: "牢记项目目标和基本要求，执行当前操作！每句话的时候我都会提醒你，请严格！

### 项目实现目标
[这里总是设计总目标]


### 计划步骤（当前在第X步）
1. 此操作暂无计划，请替我直接进行当前操作的规划

### 架构方式
- 使用XXX和XXX进行开发
- 前端引入XXX
- 后端引入XXX
- 最终CMAKE构建

### 行为约束
- 清晰逻辑，具有一定大局观
- 设计完善的项目控制台日志，方便定位问题和杜绝玄学问题
- 全局代码风格一致
- 全局页面/组件/设计风格一致
- 如果出现不可能、逻辑不自洽的操作时，不要修改代码，转而直接提示此问题无解

### 当前操作
如果App.vue检查到用户状态是未登录的时候，自动跳转到/login

### 具体要求
- 暂无具体要求

### 其他信息
- 暂无其他信息
"
    
    // 切换置顶状态
    function toggleAlwaysOnTop() {
        alwaysOnTop = !alwaysOnTop
    }
    
    // 复制全部内容
    function copyAll() {
        contextTextArea.selectAll()
        contextTextArea.copy()
        contextTextArea.deselect()
        copyBtn.text = I18n.t("copied")
        copyTimer.start()
    }
    
    // 添加到撤销栈
    function pushUndo(text) {
        if (isUndoRedo) return
        
        // 限制栈大小
        if (undoStack.length >= maxUndoSteps) {
            undoStack.shift()
        }
        undoStack.push(text)
        redoStack = [] // 清空重做栈
    }
    
    // 撤销
    function undo() {
        if (undoStack.length > 1) {
            isUndoRedo = true
            redoStack.push(undoStack.pop())
            contextTextArea.text = undoStack[undoStack.length - 1]
            isUndoRedo = false
        }
    }
    
    // 重做
    function redo() {
        if (redoStack.length > 0) {
            isUndoRedo = true
            var text = redoStack.pop()
            undoStack.push(text)
            contextTextArea.text = text
            isUndoRedo = false
        }
    }
    
    // 重置为默认内容
    function resetToDefault() {
        contextTextArea.text = defaultContent
    }
    
    Timer {
        id: copyTimer
        interval: 1500
        onTriggered: copyBtn.text = I18n.t("contextFloatCopyAll")
    }
    
    // 防抖定时器
    Timer {
        id: undoTimer
        interval: 500
        onTriggered: {
            pushUndo(contextTextArea.text)
        }
    }
    
    Component.onCompleted: {
        contextTextArea.text = defaultContent
        pushUndo(defaultContent)
    }
    
    // 快捷键
    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: undo()
    }
    
    Shortcut {
        sequence: "Ctrl+Y"
        onActivated: redo()
    }
    
    Shortcut {
        sequence: "Ctrl+Shift+Z"
        onActivated: redo()
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.bottomMargin: 20
            spacing: 15
            
            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Column {
                    spacing: 5
                    Text {
                        text: I18n.t("toolContextFloat")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolContextFloatDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 置顶按钮
                Button {
                    id: pinBtn
                    text: alwaysOnTop ? I18n.t("contextFloatUnpin") : I18n.t("contextFloatPin")
                    width: 90
                    height: 32
                    onClicked: toggleAlwaysOnTop()
                    
                    background: Rectangle {
                        color: alwaysOnTop ? (parent.hovered ? "#e65100" : "#ff6d00") : (parent.hovered ? "#006cbd" : "#0078d4")
                        radius: 4
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
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 提示信息
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Text {
                    text: "💡 " + I18n.t("contextFloatTip")
                    font.pixelSize: 12
                    color: "#888"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: I18n.t("contextFloatCharCount") + ": " + contextTextArea.length
                    font.pixelSize: 12
                    color: "#888"
                }
            }
            
            // 主编辑区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: contextTextArea.activeFocus ? "#0078d4" : "#d0d0d0"
                border.width: contextTextArea.activeFocus ? 2 : 1
                radius: 6
                
                Flickable {
                    id: flickable
                    anchors.fill: parent
                    anchors.margins: 12
                    contentWidth: width
                    contentHeight: contextTextArea.contentHeight
                    clip: true
                    flickableDirection: Flickable.VerticalFlick
                    
                    TextArea.flickable: TextArea {
                        id: contextTextArea
                        placeholderText: I18n.t("contextFloatPlaceholder")
                        font.pixelSize: 14
                        font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        
                        background: null
                        
                        onTextChanged: {
                            if (!isUndoRedo) {
                                undoTimer.restart()
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
            
            // 底部按钮栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // 窗口标签输入框
                Text {
                    text: I18n.t("contextFloatTag") + ":"
                    font.pixelSize: 13
                    color: "#666"
                    verticalAlignment: Text.AlignVCenter
                }
                
                Rectangle {
                    width: 150
                    height: 32
                    color: "white"
                    border.color: tagInput.activeFocus ? "#0078d4" : "#d0d0d0"
                    border.width: tagInput.activeFocus ? 2 : 1
                    radius: 4
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onPressed: function(mouse) {
                            tagInput.forceActiveFocus()
                            mouse.accepted = false
                        }
                    }
                    
                    TextInput {
                        id: tagInput
                        anchors.fill: parent
                        anchors.margins: 8
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: true
                        clip: true
                        
                        onTextChanged: windowTag = text
                        
                        Text {
                            anchors.fill: parent
                            text: I18n.t("contextFloatTagPlaceholder")
                            font.pixelSize: 13
                            color: "#aaa"
                            verticalAlignment: Text.AlignVCenter
                            visible: !tagInput.text && !tagInput.activeFocus
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 重置按钮
                Button {
                    text: I18n.t("contextFloatReset")
                    width: 70
                    height: 32
                    onClicked: resetDialog.open()
                    
                    background: Rectangle {
                        color: parent.hovered ? "#fff0f0" : "#e8e8e8"
                        radius: 4
                        border.color: parent.hovered ? "#ff6b6b" : "#ccc"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 13
                        color: parent.hovered ? "#d32f2f" : "#333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                // 复制全部按钮
                Button {
                    id: copyBtn
                    text: I18n.t("contextFloatCopyAll")
                    width: 90
                    height: 32
                    enabled: contextTextArea.length > 0
                    onClicked: copyAll()
                    
                    background: Rectangle {
                        color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                        radius: 4
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
        }
    }
    
    // 重置确认弹窗
    Dialog {
        id: resetDialog
        title: I18n.t("contextFloatResetTitle")
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Ok | Dialog.Cancel
        
        Text {
            text: I18n.t("contextFloatResetConfirm")
            font.pixelSize: 14
            color: "#333"
        }
        
        onAccepted: resetToDefault()
    }
}
