import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: folderMappingWindow
    width: 700
    height: 600
    title: I18n.t("toolFolderMapping") || "文件夹映射"
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 窗口关闭时停止服务器
    onClosing: {
        if (httpServer.isRunning) {
            httpServer.stopServer()
        }
    }
    
    // C++ 后端实例
    FolderHttpServer {
        id: httpServer
        
        onLogMessage: function(message) {
            logModel.insert(0, {text: message})
            // 限制日志数量
            if (logModel.count > 200) {
                logModel.remove(logModel.count - 1)
            }
        }
    }
    
    // 日志模型
    ListModel {
        id: logModel
    }
    
    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog
        title: I18n.t("selectFolder") || "选择要映射的文件夹"
        onAccepted: {
            httpServer.folderPath = selectedFolder
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 标题
            Text {
                text: I18n.t("toolFolderMapping") || "文件夹映射"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolFolderMappingDesc") || "将本地文件夹映射为HTTP服务，支持局域网访问"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 配置区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    
                    // 文件夹选择
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: I18n.t("folderPath") || "文件夹路径:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        TextField {
                            id: folderInput
                            Layout.fillWidth: true
                            text: httpServer.folderPath
                            placeholderText: I18n.t("selectFolderPlaceholder") || "点击右侧按钮选择文件夹..."
                            font.pixelSize: 13
                            readOnly: httpServer.isRunning
                            
                            background: Rectangle {
                                color: httpServer.isRunning ? "#f5f5f5" : "white"
                                border.color: folderInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: folderInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            onTextChanged: {
                                if (!httpServer.isRunning) {
                                    httpServer.folderPath = text
                                }
                            }
                        }
                        
                        Button {
                            text: I18n.t("browse") || "浏览..."
                            enabled: !httpServer.isRunning
                            Layout.preferredWidth: 80
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#e3f2fd" : "white") : "#f5f5f5"
                                border.color: parent.enabled ? "#1976d2" : "#ccc"
                                border.width: 1
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#1976d2" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                folderDialog.open()
                            }
                        }
                    }
                    
                    // 端口设置
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            text: I18n.t("portNumber") || "端口号:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        SpinBox {
                            id: portInput
                            from: 1
                            to: 65535
                            value: httpServer.port
                            editable: true
                            enabled: !httpServer.isRunning
                            Layout.preferredWidth: 120
                            
                            background: Rectangle {
                                color: httpServer.isRunning ? "#f5f5f5" : "white"
                                border.color: portInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                            
                            onValueChanged: {
                                httpServer.port = value
                            }
                        }
                        
                        Text {
                            text: I18n.t("portRange") || "(范围: 1-65535，推荐 8080)"
                            font.pixelSize: 12
                            color: "#888"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // 操作按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        Button {
                            id: startBtn
                            text: httpServer.isRunning ? (I18n.t("stopServer") || "停止服务") : (I18n.t("startServer") || "启动服务")
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 36
                            
                            background: Rectangle {
                                color: {
                                    if (httpServer.isRunning) {
                                        return parent.hovered ? "#d32f2f" : "#f44336"
                                    } else {
                                        return parent.hovered ? "#388e3c" : "#4caf50"
                                    }
                                }
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                if (httpServer.isRunning) {
                                    httpServer.stopServer()
                                } else {
                                    httpServer.startServer()
                                }
                            }
                        }
                        
                        // 状态显示
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: httpServer.isRunning ? "#e8f5e9" : "#fff3e0"
                            radius: 4
                            border.color: httpServer.isRunning ? "#4caf50" : "#ff9800"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                // 状态指示灯
                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: httpServer.isRunning ? "#4caf50" : "#ff9800"
                                    
                                    SequentialAnimation on opacity {
                                        running: httpServer.isRunning
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 800 }
                                        NumberAnimation { to: 1.0; duration: 800 }
                                    }
                                }
                                
                                Text {
                                    text: httpServer.statusMessage || (I18n.t("serverStopped") || "服务未启动")
                                    font.pixelSize: 12
                                    color: httpServer.isRunning ? "#2e7d32" : "#e65100"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                
                                // 请求计数
                                Text {
                                    visible: httpServer.isRunning
                                    text: (I18n.t("requestCount") || "请求数:") + " " + httpServer.requestCount
                                    font.pixelSize: 12
                                    color: "#666"
                                }
                            }
                        }
                    }
                }
            }
            
            // 访问地址提示（运行时显示）
            Rectangle {
                visible: httpServer.isRunning
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#e3f2fd"
                radius: 6
                border.color: "#1976d2"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Text {
                        text: "🌐"
                        font.pixelSize: 24
                    }
                    
                    Column {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: I18n.t("accessUrl") || "访问地址"
                            font.pixelSize: 12
                            color: "#666"
                        }
                        
                        Text {
                            id: urlText
                            text: "http://localhost:" + httpServer.port
                            font.pixelSize: 14
                            font.bold: true
                            color: "#1976d2"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Qt.openUrlExternally(urlText.text)
                                }
                            }
                        }
                    }
                    
                    Button {
                        text: I18n.t("openInBrowser") || "在浏览器中打开"
                        Layout.preferredHeight: 32
                        
                        background: Rectangle {
                            color: parent.hovered ? "#1565c0" : "#1976d2"
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            Qt.openUrlExternally(urlText.text)
                        }
                    }
                    
                    Button {
                        text: I18n.t("copyUrl") || "复制地址"
                        Layout.preferredHeight: 32
                        
                        background: Rectangle {
                            color: parent.hovered ? "#e3f2fd" : "white"
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
                        
                        onClicked: {
                            urlText.selectAll()
                            // 复制到剪贴板
                            var textEdit = Qt.createQmlObject('import QtQuick; TextEdit { visible: false }', folderMappingWindow)
                            textEdit.text = urlText.text
                            textEdit.selectAll()
                            textEdit.copy()
                            textEdit.destroy()
                            
                            copyToast.show()
                        }
                    }
                }
            }
            
            // 日志区域标题
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: I18n.t("serverLog") || "服务日志"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("clearLog") || "清空日志"
                    Layout.preferredHeight: 28
                    
                    background: Rectangle {
                        color: parent.hovered ? "#ffebee" : "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        logModel.clear()
                    }
                }
            }
            
            // 日志列表
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1e1e1e"
                radius: 6
                
                ListView {
                    id: logListView
                    anchors.fill: parent
                    anchors.margins: 10
                    model: logModel
                    clip: true
                    spacing: 2
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        policy: ScrollBar.AsNeeded
                    }
                    
                    delegate: Text {
                        width: logListView.width
                        text: model.text
                        font.family: "Consolas, Monaco, 'Courier New', monospace"
                        font.pixelSize: 12
                        color: {
                            if (model.text.indexOf("[错误]") >= 0 || model.text.indexOf("[拒绝]") >= 0) return "#f44336"
                            if (model.text.indexOf("[404]") >= 0 || model.text.indexOf("[500]") >= 0) return "#ff9800"
                            if (model.text.indexOf("[200]") >= 0) return "#4caf50"
                            if (model.text.indexOf("[启动]") >= 0) return "#2196f3"
                            if (model.text.indexOf("[停止]") >= 0) return "#9c27b0"
                            if (model.text.indexOf("[信息]") >= 0) return "#00bcd4"
                            return "#aaa"
                        }
                        wrapMode: Text.WrapAnywhere
                    }
                    
                    // 空状态提示
                    Text {
                        visible: logModel.count === 0
                        anchors.centerIn: parent
                        text: I18n.t("noLogs") || "暂无日志，启动服务后将显示访问记录"
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
            }
        }
    }
    
    // 复制成功提示
    Rectangle {
        id: copyToast
        width: 120
        height: 36
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        color: "#323232"
        radius: 18
        opacity: 0
        visible: opacity > 0
        
        function show() {
            toastAnim.restart()
        }
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copied") || "已复制"
            font.pixelSize: 13
            color: "white"
        }
        
        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: copyToast; property: "opacity"; to: 1; duration: 150 }
            PauseAnimation { duration: 1500 }
            NumberAnimation { target: copyToast; property: "opacity"; to: 0; duration: 300 }
        }
    }
}
