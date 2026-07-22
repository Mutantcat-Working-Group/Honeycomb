import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: agentWindow
    width: 1100
    height: 750
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolAgentPrompt") || "Agent提示词"

    // 右侧预览模式：normal = 普通查看（可编辑）  markdown = MD 预览（只读渲染）
    property string previewMode: "normal"

    // 是否为 md 文件（仅 md 文件显示模式切换）
    function isMarkdownFile(path) {
        if (!path) return false
        var lower = path.toLowerCase()
        return lower.endsWith(".md") || lower.endsWith(".markdown")
    }
    
    AgentPromptManager {
        id: manager
        
        onErrorOccurred: function(error) {
            errorDialog.text = error
            errorDialog.open()
        }
        
        onSuccessMessage: function(message) {
            successTip.text = message
            successTip.visible = true
            successTimer.restart()
        }
    }
    
    Timer {
        id: successTimer
        interval: 2000
        onTriggered: successTip.visible = false
    }
    
    Dialog {
        id: errorDialog
        property string text: ""
        title: I18n.t("error") || "错误"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        modal: true
        width: 350
        contentItem: Label {
            text: errorDialog.text
            wrapMode: Text.Wrap
        }
    }
    
    // 新建文件/文件夹对话框
    Dialog {
        id: createDialog
        property string parentPath: ""
        property bool isFolder: false
        title: isFolder ? "新建文件夹" : "新建文件"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        modal: true
        width: 400
        
        contentItem: ColumnLayout {
            spacing: 15
            
            Text {
                text: isFolder ? "文件夹名称:" : "文件名称:"
                font.pixelSize: 14
                color: "#333"
            }
            
            TextField {
                id: newItemName
                Layout.fillWidth: true
                placeholderText: createDialog.isFolder ? "folder_name" : "file_name.md"
                font.pixelSize: 14
            }
        }
        
        onAccepted: {
            if (newItemName.text.trim().length > 0) {
                if (isFolder) {
                    manager.createFolder(parentPath, newItemName.text.trim())
                } else {
                    var name = newItemName.text.trim()
                    if (!name.includes(".")) name += ".md"
                    manager.createFile(parentPath, name)
                }
                newItemName.text = ""
            }
        }
    }
    
    // 重命名对话框
    Dialog {
        id: renameDialog
        property string oldPath: ""
        property string oldName: ""
        title: "重命名"
        standardButtons: Dialog.Ok | Dialog.Cancel
        anchors.centerIn: parent
        modal: true
        width: 400
        
        contentItem: ColumnLayout {
            spacing: 15
            
            Text {
                text: "新名称:"
                font.pixelSize: 14
                color: "#333"
            }
            
            TextField {
                id: renameInput
                Layout.fillWidth: true
                text: renameDialog.oldName
                font.pixelSize: 14
            }
        }
        
        onAccepted: {
            if (renameInput.text.trim().length > 0 && renameInput.text.trim() !== oldName) {
                manager.renameItem(oldPath, renameInput.text.trim())
            }
        }
    }
    
    // 生成提示词对话框
    Dialog {
        id: promptGeneratorDialog
        title: I18n.t("agentPromptGenerateTitle") || "生成提示词"
        anchors.centerIn: parent
        modal: true
        width: 600
        height: 500

        property var selectedFiles: []
        property var fileList: []

        footer: DialogButtonBox {
            Button {
                text: I18n.t("contextFloatCancel") || "取消"
                DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                onClicked: promptGeneratorDialog.reject()
            }
            Button {
                text: I18n.t("contextFloatConfirm") || "确定"
                DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                onClicked: promptGeneratorDialog.accept()
            }
        }

        contentItem: ColumnLayout {
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: I18n.t("agentPromptSelectFiles") || "请勾选需要包含在提示词中的文件："
                font.pixelSize: 14
                color: "#333"
            }

            // 全选/取消全选按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    text: I18n.t("agentSelectAll") || "全选"
                    implicitHeight: 26
                    implicitWidth: 60

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 11
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#e0e0e0" : (parent.hovered ? "#f0f0f0" : "white")
                        border.color: "#ddd"
                        border.width: 1
                        radius: 4
                    }

                    onClicked: {
                        var all = []
                        for (var i = 0; i < promptGeneratorDialog.fileList.length; i++) {
                            all.push(promptGeneratorDialog.fileList[i].path)
                        }
                        promptGeneratorDialog.selectedFiles = all
                    }
                }

                Button {
                    text: I18n.t("agentDeselectAll") || "取消全选"
                    implicitHeight: 26
                    implicitWidth: 70

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 11
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.pressed ? "#e0e0e0" : (parent.hovered ? "#f0f0f0" : "white")
                        border.color: "#ddd"
                        border.width: 1
                        radius: 4
                    }

                    onClicked: promptGeneratorDialog.selectedFiles = []
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: (I18n.t("agentSelectedFileCount") || "已选择 {0} 个文件").replace("{0}", promptGeneratorDialog.selectedFiles.length)
                    font.pixelSize: 12
                    color: "#666"
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#fafafa"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 4
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    
                    ListView {
                        id: fileSelectList
                        model: promptGeneratorDialog.fileList
                        spacing: 4
                        
                        delegate: Rectangle {
                            width: fileSelectList.width
                            height: 36
                            color: fileItemMouse.containsMouse ? "#f5f5f5" : "transparent"
                            radius: 4
                            
                            property bool isChecked: promptGeneratorDialog.selectedFiles.indexOf(modelData.path) !== -1
                            
                            MouseArea {
                                id: fileItemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    var idx = promptGeneratorDialog.selectedFiles.indexOf(modelData.path)
                                    var newList = promptGeneratorDialog.selectedFiles.slice()
                                    if (idx === -1) {
                                        newList.push(modelData.path)
                                    } else {
                                        newList.splice(idx, 1)
                                    }
                                    promptGeneratorDialog.selectedFiles = newList
                                }
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8 + modelData.depth * 20
                                anchors.rightMargin: 8
                                spacing: 8
                                
                                CheckBox {
                                    checked: parent.parent.isChecked
                                    onClicked: {
                                        var idx = promptGeneratorDialog.selectedFiles.indexOf(modelData.path)
                                        var newList = promptGeneratorDialog.selectedFiles.slice()
                                        if (idx === -1) {
                                            newList.push(modelData.path)
                                        } else {
                                            newList.splice(idx, 1)
                                        }
                                        promptGeneratorDialog.selectedFiles = newList
                                    }
                                }
                                
                                Text {
                                    text: "📄"
                                    font.pixelSize: 14
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.relativePath
                                    font.pixelSize: 13
                                    color: "#333"
                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: "💡 提示：生成的提示词将包含选中文件的内容，用于推进项目开发"
                font.pixelSize: 11
                color: "#999"
                wrapMode: Text.Wrap
            }
        }
        
        onAccepted: {
            if (selectedFiles.length === 0) {
                manager.errorOccurred("请至少选择一个文件")
                return
            }
            var prompt = manager.generatePrompt(selectedFiles)
            generatedPromptDialog.promptText = prompt
            generatedPromptDialog.open()
        }
    }
    
    // 生成的提示词显示对话框
    Dialog {
        id: generatedPromptDialog
        title: "生成的提示词"
        standardButtons: Dialog.Close
        anchors.centerIn: parent
        modal: true
        width: 700
        height: 550
        
        property string promptText: ""
        
        contentItem: ColumnLayout {
            spacing: 12
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "可复制以下提示词发送给 AI Agent："
                    font.pixelSize: 14
                    color: "#333"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "📋 复制"
                    implicitHeight: 28
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                    }
                    
                    onClicked: {
                        manager.copyToClipboard(generatedPromptDialog.promptText)
                        manager.successMessage("已复制到剪贴板")
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#fafafa"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 4
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    
                    TextArea {
                        text: generatedPromptDialog.promptText
                        font.family: "Consolas, Monaco, monospace"
                        font.pixelSize: 13
                        wrapMode: TextArea.Wrap
                        readOnly: true
                        selectByMouse: true
                        
                        background: Rectangle {
                            color: "transparent"
                        }
                    }
                }
            }
        }
    }
    
    // 初始化骨架确认对话框
    Dialog {
        id: initConfirmDialog
        title: "初始化骨架结构"
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent
        modal: true
        width: 450
        
        contentItem: ColumnLayout {
            spacing: 12
            width: parent.width
            
            Text {
                Layout.fillWidth: true
                text: "将在当前文件夹中创建 AI-First Development 协同开发的目录结构："
                font.pixelSize: 14
                color: "#333"
                wrapMode: Text.Wrap
            }
            
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: structureText.implicitHeight + 20
                color: "#f5f5f5"
                radius: 4
                
                Text {
                    id: structureText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    text: "├── project_overview.md\n├── architecture/\n├── domain/\n├── patterns/\n├── tasks/\n├── references/\n├── images/\n├── verify/\n├── prompts/\n└── directory/"
                    font.family: "Consolas, Monaco, monospace"
                    font.pixelSize: 12
                    color: "#666"
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: "⚠️ 已存在的文件/文件夹不会被覆盖"
                font.pixelSize: 12
                color: "#f57c00"
            }
        }
        
        onAccepted: manager.initializeSkeleton()
    }
    
    // 确认删除对话框
    Dialog {
        id: deleteDialog
        property string targetPath: ""
        property string targetName: ""
        title: "确认删除"
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: parent
        modal: true
        width: 400
        
        contentItem: Text {
            text: "确定要删除 \"" + deleteDialog.targetName + "\" 吗？\n此操作不可撤销。"
            font.pixelSize: 14
            color: "#333"
            wrapMode: Text.Wrap
        }
        
        onAccepted: {
            manager.deleteItem(targetPath)
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            // 左侧文件树
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    // 标题和选择按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "📁 " + (I18n.t("agentWorkspace") || "协同文件夹")
                            font.pixelSize: 15
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        // 合并的「选择 + 刷新」按钮组
                        Rectangle {
                            id: selectGroup
                            Layout.preferredHeight: 28
                            Layout.preferredWidth: 80
                            color: selectPressed ? "#1565c0" : (selectHovered || refreshHovered ? "#1e88e5" : "#1976d2")
                            radius: 4

                            property bool selectPressed: selectMouse.pressed
                            property bool selectHovered: selectMouse.containsMouse
                            property bool refreshHovered: refreshMouse.containsMouse

                            Row {
                                anchors.fill: parent
                                spacing: 0

                                // 选择按钮区域
                                Item {
                                    id: selectBtn
                                    width: 50
                                    height: parent.height

                                    Text {
                                        anchors.centerIn: parent
                                        text: "选择"
                                        font.pixelSize: 12
                                        color: "white"
                                    }

                                    MouseArea {
                                        id: selectMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: manager.selectRootFolder()
                                    }
                                }

                                // 分隔线
                                Rectangle {
                                    width: 1
                                    height: parent.height - 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: "white"
                                    opacity: 0.4
                                }

                                // 刷新按钮区域
                                Item {
                                    id: refreshBtn
                                    width: 28
                                    height: parent.height
                                    enabled: manager.rootPath !== ""

                                    Text {
                                        anchors.centerIn: parent
                                        text: "⟳"
                                        font.pixelSize: 14
                                        color: parent.parent.enabled ? "white" : "#88ffffff"
                                    }

                                    MouseArea {
                                        id: refreshMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled: parent.parent.enabled
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: manager.refreshTree()
                                    }
                                }
                            }
                        }
                    }
                    
                    // 当前路径显示
                    Text {
                        Layout.fillWidth: true
                        text: manager.rootPath || "未选择文件夹"
                        font.pixelSize: 11
                        color: "#999"
                        elide: Text.ElideMiddle
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#e0e0e0"
                    }
                    
                    // 文件树
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ListView {
                            id: treeView
                            model: flattenTree(manager.fileTree)
                            spacing: 2
                            
                            delegate: Rectangle {
                                width: treeView.width
                                height: 32
                                color: manager.currentFilePath === modelData.path ? "#e3f2fd" : 
                                       (treeHover.containsMouse ? "#f5f5f5" : "transparent")
                                radius: 4
                                
                                MouseArea {
                                    id: treeHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    
                                    onClicked: function(mouse) {
                                        if (mouse.button === Qt.LeftButton) {
                                            manager.currentFilePath = modelData.path
                                        } else if (mouse.button === Qt.RightButton) {
                                            treeContextMenu.targetPath = modelData.path
                                            treeContextMenu.targetName = modelData.name
                                            treeContextMenu.isDir = modelData.isDir
                                            treeContextMenu.popup()
                                        }
                                    }
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8 + modelData.depth * 16
                                    anchors.rightMargin: 8
                                    spacing: 6
                                    
                                    Text {
                                        text: modelData.isImageFolder ? "🖼️" : 
                                              (modelData.isDir ? "📁" : "📄")
                                        font.pixelSize: 14
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.pixelSize: 13
                                        color: "#333"
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                    
                    // 快捷操作按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: manager.rootPath !== ""
                        
                        Button {
                            Layout.fillWidth: true
                            text: "+ 文件"
                            implicitHeight: 30

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "#666"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e8e8e8" : (parent.hovered ? "#f0f0f0" : "white")
                                border.color: "#ddd"
                                border.width: 1
                                radius: 4
                            }
                            
                            onClicked: {
                                createDialog.parentPath = manager.rootPath
                                createDialog.isFolder = false
                                createDialog.open()
                            }
                        }
                        
                        Button {
                            Layout.fillWidth: true
                            text: "+ 文件夹"
                            implicitHeight: 30

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "#666"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e8e8e8" : (parent.hovered ? "#f0f0f0" : "white")
                                border.color: "#ddd"
                                border.width: 1
                                radius: 4
                            }
                            
                            onClicked: {
                                createDialog.parentPath = manager.rootPath
                                createDialog.isFolder = true
                                createDialog.open()
                            }
                        }
                    }
                    
                    // 初始化骨架按钮
                    Button {
                        Layout.fillWidth: true
                        text: "🚀 初始化骨架"
                        implicitHeight: 32
                        visible: manager.rootPath !== ""

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#e65100" : (parent.hovered ? "#ff9800" : "#fb8c00")
                            radius: 4
                        }
                        
                        onClicked: initConfirmDialog.open()
                    }
                    
                    // 生成提示词按钮
                    Button {
                        Layout.fillWidth: true
                        text: "✨ 生成提示词"
                        implicitHeight: 32
                        visible: manager.rootPath !== ""

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#5e35b1" : (parent.hovered ? "#7e57c2" : "#673ab7")
                            radius: 4
                        }
                        
                        onClicked: {
                            promptGeneratorDialog.selectedFiles = []
                            promptGeneratorDialog.fileList = manager.getSelectableFiles()
                            promptGeneratorDialog.open()
                        }
                    }
                }
            }
            
            // 右侧内容区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    // 文件路径标题
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: manager.currentFilePath ?
                                  (manager.isImageFolder ? "🖼️ " : "📄 ") +
                                  manager.currentFilePath.split("/").pop().split("\\").pop() :
                                  "选择文件查看内容"
                            font.pixelSize: 15
                            font.bold: true
                            color: "#333"
                        }

                        Item { Layout.fillWidth: true }

                        // MD 文件查看模式切换
                        Rectangle {
                            id: previewToggle
                            visible: !manager.isImageFolder && agentWindow.isMarkdownFile(manager.currentFilePath)
                            Layout.preferredHeight: 28
                            Layout.preferredWidth: 140
                            color: "#f5f5f5"
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4

                            property string mode: agentWindow.previewMode

                            // 左半：普通查看
                            Item {
                                anchors.left: parent.left
                                width: parent.width / 2
                                height: parent.height

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    radius: 3
                                    color: previewToggle.mode === "normal" ? "white" : "transparent"
                                    border.color: previewToggle.mode === "normal" ? "#1976d2" : "transparent"
                                    border.width: 1
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: I18n.t("agentPreviewNormal") || "普通查看"
                                    font.pixelSize: 12
                                    color: previewToggle.mode === "normal" ? "#1976d2" : "#666"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: agentWindow.previewMode = "normal"
                                }
                            }

                            // 右半：MD 预览
                            Item {
                                anchors.right: parent.right
                                width: parent.width / 2
                                height: parent.height

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    radius: 3
                                    color: previewToggle.mode === "markdown" ? "white" : "transparent"
                                    border.color: previewToggle.mode === "markdown" ? "#1976d2" : "transparent"
                                    border.width: 1
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: I18n.t("agentPreviewMarkdown") || "MD 预览"
                                    font.pixelSize: 12
                                    color: previewToggle.mode === "markdown" ? "#1976d2" : "#666"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: agentWindow.previewMode = "markdown"
                                }
                            }
                        }

                        Button {
                            text: "💾 保存"
                            visible: !manager.isImageFolder && manager.currentFilePath !== ""
                            implicitHeight: 30

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#388e3c" : (parent.hovered ? "#4caf50" : "#43a047")
                                radius: 4
                            }

                            onClicked: manager.saveCurrentFile()
                        }

                        Button {
                            text: "📂 打开目录"
                            visible: manager.currentFilePath !== ""
                            implicitHeight: 30

                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "#666"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                color: parent.pressed ? "#e0e0e0" : (parent.hovered ? "#f0f0f0" : "white")
                                border.color: "#ddd"
                                border.width: 1
                                radius: 4
                            }

                            onClicked: manager.openInExplorer(manager.currentFilePath)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#e0e0e0"
                    }

                    // 内容区域 - 文本编辑器 / Markdown 预览 / 图片管理器
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: {
                            if (manager.isImageFolder) return imageManagerComponent
                            if (agentWindow.isMarkdownFile(manager.currentFilePath) && agentWindow.previewMode === "markdown") return markdownPreviewComponent
                            return textEditorComponent
                        }
                    }
                }
            }
        }
        
        // 成功提示
        Rectangle {
            id: successTip
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            width: tipText.width + 40
            height: 40
            color: "#4caf50"
            radius: 20
            visible: false
            
            property string text: ""
            
            Text {
                id: tipText
                anchors.centerIn: parent
                text: successTip.text
                font.pixelSize: 14
                color: "white"
            }
        }
    }
    
    // 文本编辑器组件
    Component {
        id: textEditorComponent

        ScrollView {
            clip: true

            TextArea {
                id: contentEditor
                text: manager.currentFileContent
                font.family: "Consolas, Monaco, monospace"
                font.pixelSize: 14
                wrapMode: TextArea.Wrap
                placeholderText: "选择一个文件开始编辑..."

                background: Rectangle {
                    color: "#fafafa"
                    border.color: contentEditor.focus ? "#1976d2" : "#e0e0e0"
                    border.width: 1
                    radius: 4
                }

                onTextChanged: {
                    if (text !== manager.currentFileContent) {
                        manager.currentFileContent = text
                    }
                }
            }
        }
    }

    // Markdown 预览组件（只读）
    Component {
        id: markdownPreviewComponent

        Rectangle {
            color: "#fafafa"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 4

            ScrollView {
                anchors.fill: parent
                anchors.margins: 14
                clip: true

                Text {
                    id: mdRenderer
                    width: parent.width
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    text: agentWindow.markdownToHtml(manager.currentFileContent)
                    font.pixelSize: 14
                    color: "#333"
                    // 链接点击：在外部浏览器打开
                    onLinkActivated: function(link) {
                        Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
    
    // 图片管理器组件
    Component {
        id: imageManagerComponent
        
        Rectangle {
            color: "#fafafa"
            radius: 4
            border.color: "#e0e0e0"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                
                // 操作栏
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Button {
                        text: "📋 从剪切板粘贴"
                        implicitHeight: 32

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                            radius: 4
                        }
                        
                        onClicked: manager.pasteImageFromClipboard()
                    }
                    
                    Text {
                        text: "或拖拽图片到下方区域"
                        font.pixelSize: 12
                        color: "#999"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: "共 " + manager.currentImages.length + " 张图片"
                        font.pixelSize: 12
                        color: "#666"
                    }
                }
                
                // 图片网格 + 拖放区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: imageDropArea.containsDrag ? "#e3f2fd" : "white"
                    border.color: imageDropArea.containsDrag ? "#1976d2" : "#e0e0e0"
                    border.width: imageDropArea.containsDrag ? 2 : 1
                    radius: 8
                    
                    DropArea {
                        id: imageDropArea
                        anchors.fill: parent
                        
                        onDropped: function(drop) {
                            if (drop.hasUrls) {
                                manager.addImagesFromUrls(drop.urls)
                            }
                        }
                    }
                    
                    // 空状态
                    Text {
                        anchors.centerIn: parent
                        text: "📷\n\n拖拽图片到这里\n或点击上方按钮粘贴"
                        font.pixelSize: 14
                        color: "#999"
                        horizontalAlignment: Text.AlignHCenter
                        visible: manager.currentImages.length === 0
                    }
                    
                    // 图片网格
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        visible: manager.currentImages.length > 0
                        
                        GridView {
                            id: imageGrid
                            cellWidth: 160
                            cellHeight: 180
                            model: manager.currentImages
                            
                            delegate: Rectangle {
                                width: 150
                                height: 170
                                color: imageItemHover.containsMouse ? "#f5f5f5" : "white"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 6
                                
                                MouseArea {
                                    id: imageItemHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.RightButton
                                    
                                    onClicked: function(mouse) {
                                        if (mouse.button === Qt.RightButton) {
                                            imageContextMenu.imagePath = modelData
                                            imageContextMenu.popup()
                                        }
                                    }
                                }
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 6
                                    
                                    Image {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        source: "file:///" + modelData
                                        fillMode: Image.PreserveAspectFit
                                        asynchronous: true
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.split("/").pop().split("\\").pop()
                                        font.pixelSize: 11
                                        color: "#666"
                                        elide: Text.ElideMiddle
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 文件树右键菜单
    Menu {
        id: treeContextMenu
        property string targetPath: ""
        property string targetName: ""
        property bool isDir: false
        
        MenuItem {
            text: "新建文件"
            visible: treeContextMenu.isDir
            height: visible ? implicitHeight : 0
            onTriggered: {
                createDialog.parentPath = treeContextMenu.targetPath
                createDialog.isFolder = false
                createDialog.open()
            }
        }
        
        MenuItem {
            text: "新建文件夹"
            visible: treeContextMenu.isDir
            height: visible ? implicitHeight : 0
            onTriggered: {
                createDialog.parentPath = treeContextMenu.targetPath
                createDialog.isFolder = true
                createDialog.open()
            }
        }
        
        MenuSeparator { 
            visible: treeContextMenu.isDir
            height: visible ? implicitHeight : 0
        }
        
        MenuItem {
            text: "重命名"
            onTriggered: {
                renameDialog.oldPath = treeContextMenu.targetPath
                renameDialog.oldName = treeContextMenu.targetName
                renameDialog.open()
            }
        }
        
        MenuItem {
            text: "删除"
            onTriggered: {
                deleteDialog.targetPath = treeContextMenu.targetPath
                deleteDialog.targetName = treeContextMenu.targetName
                deleteDialog.open()
            }
        }
        
        MenuSeparator {}
        
        MenuItem {
            text: "在资源管理器中打开"
            onTriggered: manager.openInExplorer(treeContextMenu.targetPath)
        }
    }
    
    // 图片右键菜单
    Menu {
        id: imageContextMenu
        property string imagePath: ""
        
        MenuItem {
            text: "复制绝对路径"
            onTriggered: manager.copyToClipboard(manager.getAbsolutePath(imageContextMenu.imagePath))
        }
        
        MenuItem {
            text: "复制相对路径"
            onTriggered: manager.copyToClipboard(manager.getRelativePath(imageContextMenu.imagePath))
        }
        
        MenuSeparator {}
        
        MenuItem {
            text: "在资源管理器中打开"
            onTriggered: manager.openInExplorer(imageContextMenu.imagePath)
        }
        
        MenuSeparator {}
        
        MenuItem {
            text: "删除"
            onTriggered: manager.deleteImage(imageContextMenu.imagePath)
        }
    }
    
    // 辅助函数：将树形结构扁平化用于ListView显示
    function flattenTree(tree) {
        var result = []
        for (var i = 0; i < tree.length; i++) {
            var item = tree[i]
            result.push(item)
            if (item.isDir && item.children && item.children.length > 0) {
                var children = flattenTree(item.children)
                for (var j = 0; j < children.length; j++) {
                    result.push(children[j])
                }
            }
        }
        return result
    }

    // HTML 特殊字符转义
    function escapeHtml(s) {
        if (!s) return ""
        return s.replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/\"/g, "&quot;")
    }

    // 行内 Markdown 解析：粗体、斜体、删除线、行内代码、链接、图片
    function inlineMd(text) {
        if (!text) return ""
        var s = escapeHtml(text)
        // 行内代码先处理，避免被其他规则干扰
        s = s.replace(/`([^`]+)`/g, '<code style="background-color:#f0f0f0;padding:1px 4px;border-radius:3px;font-family:Consolas,Monaco,monospace;color:#c7254e;">$1</code>')
        // 图片 ![alt](url)
        s = s.replace(/!\[([^\]]*)\]\(([^)\s]+)\)/g, '<img alt="$1" src="$2" style="max-width:100%;"/>')
        // 链接 [text](url)
        s = s.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, '<a href="$2" style="color:#1976d2;text-decoration:none;">$1</a>')
        // 粗体 **text** 或 __text__
        s = s.replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>')
        s = s.replace(/__([^_]+)__/g, '<b>$1</b>')
        // 斜体 *text* 或 _text_
        s = s.replace(/(^|[^*])\*([^*\n]+)\*/g, '$1<i>$2</i>')
        s = s.replace(/(^|[^_])_([^_\n]+)_/g, '$1<i>$2</i>')
        // 删除线 ~~text~~
        s = s.replace(/~~([^~]+)~~/g, '<s>$1</s>')
        return s
    }

    // Markdown -> HTML 转换（覆盖常用语法）
    function markdownToHtml(md) {
        if (!md) return ""
        var lines = md.split(/\r?\n/)
        var html = []
        var i = 0
        var inUl = false, inOl = false, inCode = false, inBq = false
        var codeBuf = []

        function closeLists() {
            if (inUl) { html.push("</ul>"); inUl = false }
            if (inOl) { html.push("</ol>"); inOl = false }
        }
        function closeBq() {
            if (inBq) { html.push("</blockquote>"); inBq = false }
        }

        while (i < lines.length) {
            var line = lines[i]
            // 代码块围栏
            if (/^\s*```/.test(line)) {
                if (!inCode) {
                    closeLists(); closeBq()
                    inCode = true
                    codeBuf = []
                } else {
                    var lang = line.replace(/^\s*```/, "").trim()
                    var codeStyle = "display:block;background-color:#f5f5f5;border:1px solid #e0e0e0;border-radius:4px;padding:10px;font-family:Consolas,Monaco,monospace;font-size:13px;white-space:pre-wrap;word-wrap:break-word;color:#333;"
                    html.push('<pre style="' + codeStyle + '"><code>' + escapeHtml(codeBuf.join("\n")) + '</code></pre>')
                    inCode = false
                }
                i++; continue
            }
            if (inCode) { codeBuf.push(line); i++; continue }

            // 空行：关闭当前段落
            if (/^\s*$/.test(line)) {
                closeLists(); closeBq()
                i++; continue
            }

            // 标题 ######
            var h = /^(#{1,6})\s+(.*)$/.exec(line)
            if (h) {
                closeLists(); closeBq()
                var level = h[1].length
                var sizes = ["24px", "21px", "18px", "16px", "15px", "14px"]
                var style = "color:#222;margin:12px 0 6px 0;font-weight:bold;line-height:1.3;font-size:" + sizes[level - 1] + ";"
                html.push('<h' + level + ' style="' + style + '">' + inlineMd(h[2]) + '</h' + level + '>')
                i++; continue
            }

            // 水平线
            if (/^\s*([-*_])\1{2,}\s*$/.test(line)) {
                closeLists(); closeBq()
                html.push('<hr style="border:none;border-top:1px solid #e0e0e0;margin:12px 0;"/>')
                i++; continue
            }

            // 引用
            var bq = /^\s*>\s?(.*)$/.exec(line)
            if (bq) {
                closeLists()
                if (!inBq) { html.push('<blockquote style="margin:6px 0;padding:6px 12px;border-left:4px solid #1976d2;background-color:#f5f9fd;color:#555;">'); inBq = true }
                html.push(inlineMd(bq[1]) + "<br/>")
                i++
                // 连续引用已在循环里累积；若下一行不是引用，下一次空行/标题会关闭
                continue
            }

            // 无序列表
            var ul = /^\s*[-*+]\s+(.*)$/.exec(line)
            if (ul) {
                closeBq()
                if (!inUl) { html.push('<ul style="margin:6px 0;padding-left:24px;color:#333;">'); inUl = true }
                if (inOl) { html.push("</ol>"); inOl = false }
                html.push('<li style="margin:2px 0;">' + inlineMd(ul[1]) + '</li>')
                i++; continue
            }

            // 有序列表
            var ol = /^\s*\d+\.\s+(.*)$/.exec(line)
            if (ol) {
                closeBq()
                if (!inOl) { html.push('<ol style="margin:6px 0;padding-left:24px;color:#333;">'); inOl = true }
                if (inUl) { html.push("</ul>"); inUl = false }
                html.push('<li style="margin:2px 0;">' + inlineMd(ol[1]) + '</li>')
                i++; continue
            }

            // 表格（简化：仅支持 | 表头 | 表格 | 分隔行 |...|）
            if (/^\s*\|.*\|\s*$/.test(line) && i + 1 < lines.length && /^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)+\|?\s*$/.test(lines[i + 1])) {
                closeLists(); closeBq()
                var headerCells = line.replace(/^\s*\|/, "").replace(/\|\s*$/, "").split("|")
                var alignCells = lines[i + 1].replace(/^\s*\|/, "").replace(/\|\s*$/, "").split("|")
                var tStyle = "border-collapse:collapse;margin:8px 0;width:100%;font-size:13px;"
                var thStyle = "border:1px solid #e0e0e0;padding:6px 10px;background-color:#f5f5f5;text-align:left;font-weight:bold;"
                var tdStyle = "border:1px solid #e0e0e0;padding:6px 10px;"
                html.push('<table style="' + tStyle + '"><thead><tr>')
                for (var c = 0; c < headerCells.length; c++) {
                    html.push('<th style="' + thStyle + '">' + inlineMd(headerCells[c].trim()) + '</th>')
                }
                html.push('</tr></thead><tbody>')
                i += 2
                while (i < lines.length && /^\s*\|.*\|\s*$/.test(lines[i]) && !/^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)+\|?\s*$/.test(lines[i])) {
                    var row = lines[i].replace(/^\s*\|/, "").replace(/\|\s*$/, "").split("|")
                    html.push('<tr>')
                    for (var k = 0; k < row.length; k++) {
                        html.push('<td style="' + tdStyle + '">' + inlineMd(row[k].trim()) + '</td>')
                    }
                    html.push('</tr>')
                    i++
                }
                html.push('</tbody></table>')
                continue
            }

            // 普通段落：聚合连续非空非特殊行
            var paraLines = [line]
            i++
            while (i < lines.length
                   && !/^\s*$/.test(lines[i])
                   && !/^#{1,6}\s+/.test(lines[i])
                   && !/^\s*```/.test(lines[i])
                   && !/^\s*[-*+]\s+/.test(lines[i])
                   && !/^\s*\d+\.\s+/.test(lines[i])
                   && !/^\s*>\s?/.test(lines[i])
                   && !/^\s*\|.*\|\s*$/.test(lines[i])
                   && !/^\s*([-*_])\1{2,}\s*$/.test(lines[i])) {
                paraLines.push(lines[i])
                i++
            }
            closeLists(); closeBq()
            html.push('<p style="margin:6px 0;line-height:1.6;color:#333;">' + inlineMd(paraLines.join("<br/>")) + '</p>')
        }

        closeLists(); closeBq()
        return html.join("")
    }
}
