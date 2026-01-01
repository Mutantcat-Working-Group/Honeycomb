import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: openaiWindow
    width: 900
    height: 700
    title: I18n.t("toolOpenAITest") || "OpenAI API测试"
    flags: Qt.Window
    modality: Qt.NonModal
    
    OpenAIClient {
        id: client
        
        onErrorOccurred: function(error) {
            errorDialog.text = error
            errorDialog.open()
        }
        
        onTestSuccess: function(info) {
            successDialog.text = info
            successDialog.open()
        }
        
        onStreamingText: function(text) {
            // 追加流式文本到当前响应显示
            streamingContent.text += text
            // 自动滚动到底部
            Qt.callLater(function() {
                chatScrollView.contentItem.contentY = Math.max(0, chatScrollView.contentItem.contentHeight - chatScrollView.height)
            })
        }
        
        onStreamingFinished: {
            streamingContent.text = ""
        }
        
        onChatHistoryChanged: {
            Qt.callLater(function() {
                chatScrollView.contentItem.contentY = Math.max(0, chatScrollView.contentItem.contentHeight - chatScrollView.height)
            })
        }
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
    
    Dialog {
        id: successDialog
        property string text: ""
        title: I18n.t("success") || "成功"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        modal: true
        width: 350
        
        contentItem: Label {
            text: successDialog.text
            wrapMode: Text.Wrap
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 15
            
            // 左侧设置面板
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Text {
                        text: I18n.t("apiSettings") || "API 设置"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#e0e0e0"
                    }
                    
                    // API URL
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: I18n.t("apiUrl") || "API 地址"
                            font.pixelSize: 13
                            color: "#666"
                        }
                        
                        TextField {
                            id: apiUrlInput
                            Layout.fillWidth: true
                            text: "https://api.openai.com"
                            placeholderText: "https://api.openai.com"
                            font.pixelSize: 12
                            
                            background: Rectangle {
                                color: "white"
                                border.color: apiUrlInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                            
                            onTextChanged: client.apiUrl = text
                            Component.onCompleted: client.apiUrl = text
                        }
                    }
                    
                    // API Key
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: I18n.t("apiKey") || "API 密钥"
                            font.pixelSize: 13
                            color: "#666"
                        }
                        
                        TextField {
                            id: apiKeyInput
                            Layout.fillWidth: true
                            echoMode: TextInput.Password
                            placeholderText: "sk-..."
                            font.pixelSize: 12
                            
                            background: Rectangle {
                                color: "white"
                                border.color: apiKeyInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                            
                            onTextChanged: client.apiKey = text
                        }
                    }
                    
                    // Model
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: I18n.t("model") || "模型"
                            font.pixelSize: 13
                            color: "#666"
                        }
                        
                        TextField {
                            id: modelInput
                            Layout.fillWidth: true
                            text: "gpt-3.5-turbo"
                            placeholderText: I18n.t("enterModel") || "输入模型名称..."
                            font.pixelSize: 12
                            
                            background: Rectangle {
                                color: "white"
                                border.color: modelInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                            
                            onTextChanged: client.model = text
                            Component.onCompleted: client.model = text
                        }
                        
                        // 常用模型快捷选择
                        Flow {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Repeater {
                                model: ["gpt-4o", "gpt-4o-mini", "deepseek-chat", "claude-3-sonnet"]
                                
                                Rectangle {
                                    width: modelTag.width + 12
                                    height: 22
                                    radius: 11
                                    color: modelInput.text === modelData ? "#e3f2fd" : "#f5f5f5"
                                    border.color: modelInput.text === modelData ? "#1976d2" : "#e0e0e0"
                                    border.width: 1
                                    
                                    Text {
                                        id: modelTag
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 10
                                        color: modelInput.text === modelData ? "#1976d2" : "#666"
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelInput.text = modelData
                                    }
                                }
                            }
                        }
                    }
                    
                    // Temperature
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: I18n.t("temperature") || "温度"
                                font.pixelSize: 13
                                color: "#666"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: tempSlider.value.toFixed(1)
                                font.pixelSize: 13
                                color: "#1976d2"
                            }
                        }
                        
                        Slider {
                            id: tempSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 2
                            value: 0.7
                            stepSize: 0.1
                            
                            onValueChanged: client.temperature = value
                            Component.onCompleted: client.temperature = value
                        }
                    }
                    
                    // Max Tokens
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: I18n.t("maxTokens") || "最大Token"
                                font.pixelSize: 13
                                color: "#666"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: maxTokensSlider.value
                                font.pixelSize: 13
                                color: "#1976d2"
                            }
                        }
                        
                        Slider {
                            id: maxTokensSlider
                            Layout.fillWidth: true
                            from: 256
                            to: 8192
                            value: 2048
                            stepSize: 256
                            
                            onValueChanged: client.maxTokens = Math.round(value)
                            Component.onCompleted: client.maxTokens = Math.round(value)
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    // 操作按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Button {
                            Layout.fillWidth: true
                            text: I18n.t("testConnection") || "测试连接"
                            enabled: !client.isLoading
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.pressed ? "#388e3c" : (parent.hovered ? "#4caf50" : "#43a047")) : "#ccc"
                                radius: 4
                                implicitHeight: 36
                            }
                            
                            onClicked: client.testConnection()
                        }
                        
                        Button {
                            Layout.fillWidth: true
                            text: I18n.t("clearChat") || "清空对话"
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#666"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                                implicitHeight: 36
                            }
                            
                            onClicked: client.clearChat()
                        }
                    }
                }
            }
            
            // 右侧聊天区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    
                    // 聊天消息区域
                    ScrollView {
                        id: chatScrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ColumnLayout {
                            width: chatScrollView.width
                            spacing: 10
                            
                            Item { height: 15 }
                            
                            // 空状态提示
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: I18n.t("startChatHint") || "输入消息开始对话"
                                font.pixelSize: 16
                                color: "#999"
                                visible: client.chatHistory.length === 0 && !client.isLoading
                            }
                            
                            // 聊天消息列表
                            Repeater {
                                model: client.chatHistory
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 15
                                    Layout.rightMargin: 15
                                    
                                    property bool isUser: modelData.startsWith("user:")
                                    property string messageContent: {
                                        var colonIndex = modelData.indexOf(":")
                                        return colonIndex >= 0 ? modelData.substring(colonIndex + 1) : modelData
                                    }
                                    
                                    height: msgColumn.height + 20
                                    color: isUser ? "#e3f2fd" : "#f5f5f5"
                                    radius: 8
                                    
                                    ColumnLayout {
                                        id: msgColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.margins: 10
                                        spacing: 5
                                        
                                        Text {
                                            text: parent.parent.isUser ? (I18n.t("you") || "你") : "AI"
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: parent.parent.isUser ? "#1976d2" : "#666"
                                        }
                                        
                                        Text {
                                            Layout.fillWidth: true
                                            text: parent.parent.messageContent
                                            font.pixelSize: 14
                                            color: "#333"
                                            wrapMode: Text.Wrap
                                            textFormat: Text.PlainText
                                        }
                                    }
                                }
                            }
                            
                            // 流式响应显示
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.leftMargin: 15
                                Layout.rightMargin: 15
                                visible: client.isLoading
                                
                                height: streamingColumn.height + 20
                                color: "#fff3e0"
                                radius: 8
                                
                                ColumnLayout {
                                    id: streamingColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 10
                                    spacing: 5
                                    
                                    Text {
                                        text: I18n.t("aiThinking") || "AI 正在回复..."
                                        font.pixelSize: 12
                                        font.bold: true
                                        color: "#f57c00"
                                    }
                                    
                                    Text {
                                        id: streamingContent
                                        Layout.fillWidth: true
                                        text: ""
                                        font.pixelSize: 14
                                        color: "#333"
                                        wrapMode: Text.Wrap
                                        textFormat: Text.PlainText
                                    }
                                }
                            }
                            
                            Item { height: 15 }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#e0e0e0"
                    }
                    
                    // 输入区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        color: "#fafafa"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                
                                TextArea {
                                    id: messageInput
                                    placeholderText: I18n.t("enterMessage") || "输入消息..."
                                    wrapMode: TextArea.Wrap
                                    font.pixelSize: 14
                                    
                                    background: Rectangle {
                                        color: "white"
                                        border.color: messageInput.focus ? "#1976d2" : "#e0e0e0"
                                        border.width: 1
                                        radius: 6
                                    }
                                    
                                    Keys.onReturnPressed: function(event) {
                                        if (event.modifiers & Qt.ControlModifier) {
                                            sendMessage()
                                        } else {
                                            event.accepted = false
                                        }
                                    }
                                }
                            }
                            
                            ColumnLayout {
                                Layout.preferredWidth: 80
                                Layout.fillHeight: true
                                spacing: 5
                                
                                Button {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: client.isLoading ? (I18n.t("stop") || "停止") : (I18n.t("send") || "发送")
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 14
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    background: Rectangle {
                                        color: client.isLoading ? 
                                            (parent.pressed ? "#c62828" : (parent.hovered ? "#e53935" : "#d32f2f")) :
                                            (parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2"))
                                        radius: 6
                                    }
                                    
                                    onClicked: {
                                        if (client.isLoading) {
                                            client.stopGeneration()
                                        } else {
                                            sendMessage()
                                        }
                                    }
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: "Ctrl+Enter"
                                    font.pixelSize: 10
                                    color: "#999"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    function sendMessage() {
        var msg = messageInput.text.trim()
        if (msg.length > 0) {
            client.sendMessage(msg)
            messageInput.text = ""
        }
    }
}
