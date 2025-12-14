import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: webSocketTestWindow
    width: 700
    height: 610
    title: I18n.t("toolWebSocketTest")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    WebSocketTest {
        id: webSocket
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
                text: I18n.t("toolWebSocketTest")
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolWebSocketTestDesc")
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
            
            // 连接设置区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#f9f9f9"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    // 服务器URL输入
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("serverUrl") || "服务器URL:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            Layout.preferredWidth: 80
                        }
                        
                        TextField {
                            id: urlInput
                            Layout.fillWidth: true
                            text: "wss://echo.websocket.org"
                            placeholderText: I18n.t("enterServerUrl") || "请输入WebSocket服务器地址..."
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: urlInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: urlInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                webSocket.serverUrl = text
                            }
                            
                            onTextChanged: {
                                webSocket.serverUrl = text
                            }
                        }
                    }
                    
                    // 连接状态和按钮
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: (I18n.t("connectionStatus") || "连接状态:") + " " + webSocket.connectionStatus
                            font.pixelSize: 14
                            font.bold: true
                            color: webSocket.isConnected ? "#27ae60" : "#e74c3c"
                        }
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: webSocket.isConnected ? "#27ae60" : "#e74c3c"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("connectBtn") || "连接"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: !webSocket.isConnected
                            
                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                webSocket.connectToServer()
                            }
                        }
                        
                        Button {
                            text: I18n.t("disconnectBtn") || "断开"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: webSocket.isConnected
                            
                            background: Rectangle {
                                color: parent.pressed ? "#d32f2f" : (parent.hovered ? "#e53935" : "#f44336")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                webSocket.disconnect()
                            }
                        }
                    }
                }
            }
            
            // 消息发送区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: "#f9f9f9"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: I18n.t("sendMessage") || "发送消息:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        TextField {
                            id: messageInput
                            Layout.fillWidth: true
                            placeholderText: I18n.t("enterMessage") || "请输入要发送的消息..."
                            font.pixelSize: 14
                            enabled: webSocket.isConnected
                            
                            background: Rectangle {
                                color: "white"
                                border.color: messageInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: messageInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            onTextChanged: {
                                webSocket.inputMessage = text
                            }
                            
                            Keys.onReturnPressed: {
                                if (webSocket.isConnected && text.length > 0) {
                                    webSocket.sendMessage()
                                }
                            }
                        }
                        
                        Button {
                            text: I18n.t("sendBtn") || "发送"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: webSocket.isConnected && messageInput.text.length > 0
                            
                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                webSocket.sendMessage()
                            }
                        }
                    }
                }
            }
            
            // 通信日志区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f9f9f9"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("communicationLog") || "通信日志:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("clearLogBtn") || "清空日志"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 28
                            
                            background: Rectangle {
                                color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#666666"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                webSocket.clearLog()
                            }
                        }
                    }
                    
                    ScrollView {
                        id: logScrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: logText
                            text: webSocket.messageLog
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 12
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333333"
                            selectByMouse: true
                            implicitWidth: parent.width
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("noLogMessages") || "暂无通信日志"
                                font.pixelSize: 14
                                color: "#999999"
                                visible: webSocket.messageLog.length === 0
                            }
                            
                            onTextChanged: {
                                // 当文本变化时，自动滚动到底部
                                if (length > 0) {
                                    cursorPosition = length
                                    logScrollView.scrollToEnd()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
