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
                        
                        Button {
                            text: "选择"
                            implicitWidth: 50
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
                            
                            onClicked: manager.selectRootFolder()
                        }
                        
                        Button {
                            text: "⟳"
                            implicitWidth: 28
                            implicitHeight: 28
                            enabled: manager.rootPath !== ""
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                color: parent.enabled ? "#666" : "#ccc"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e0e0e0" : (parent.hovered ? "#f0f0f0" : "transparent")
                                radius: 4
                            }
                            
                            onClicked: manager.refreshTree()
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
                        
                        Button {
                            text: "💾 保存"
                            visible: !manager.isImageFolder && manager.currentFilePath !== ""
                            implicitHeight: 30
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
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
                    
                    // 内容区域 - 文本编辑器或图片管理器
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: manager.isImageFolder ? imageManagerComponent : textEditorComponent
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
}
