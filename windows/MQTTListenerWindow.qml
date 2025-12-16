import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: mqttListenerWindow
    width: 750
    height: 700
    title: I18n.t("toolMQTTListener") || "MQTT监听"
    flags: Qt.Window
    modality: Qt.NonModal
    
    MQTTListener {
        id: mqttListener
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text {
                text: I18n.t("toolMQTTListener") || "MQTT监听"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolMQTTListenerDesc") || "连接到MQTT Broker并订阅主题接收消息"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 230
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: I18n.t("connectionSettings") || "连接设置"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Broker地址:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        TextField {
                            id: brokerInput
                            Layout.fillWidth: true
                            text: "tcp://broker.emqx.io:1883"
                            placeholderText: "例如: tcp://broker.emqx.io:1883"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: brokerInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: brokerInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                mqttListener.brokerUrl = text
                            }
                            
                            onTextChanged: {
                                mqttListener.brokerUrl = text
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "客户端ID:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        TextField {
                            id: clientIdInput
                            Layout.fillWidth: true
                            text: mqttListener.clientId
                            placeholderText: "留空自动生成"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: clientIdInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: clientIdInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            onTextChanged: {
                                mqttListener.clientId = text
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "用户名(可选):"
                                font.pixelSize: 14
                                color: "#333333"
                            }
                            
                            TextField {
                                id: usernameInput
                                Layout.fillWidth: true
                                placeholderText: "用户名"
                                font.pixelSize: 14
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: usernameInput.focus ? "#1976d2" : "#e0e0e0"
                                    border.width: usernameInput.focus ? 2 : 1
                                    radius: 4
                                }
                                
                                onTextChanged: {
                                    mqttListener.username = text
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "密码(可选):"
                                font.pixelSize: 14
                                color: "#333333"
                            }
                            
                            TextField {
                                id: passwordInput
                                Layout.fillWidth: true
                                placeholderText: "密码"
                                font.pixelSize: 14
                                echoMode: TextInput.Password
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: passwordInput.focus ? "#1976d2" : "#e0e0e0"
                                    border.width: passwordInput.focus ? 2 : 1
                                    radius: 4
                                }
                                
                                onTextChanged: {
                                    mqttListener.password = text
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: (I18n.t("connectionStatus") || "连接状态:") + " " + mqttListener.connectionStatus
                            font.pixelSize: 14
                            font.bold: true
                            color: mqttListener.isConnected ? "#27ae60" : "#e74c3c"
                        }
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: mqttListener.isConnected ? "#27ae60" : "#e74c3c"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("connectBtn") || "连接"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: !mqttListener.isConnected
                            
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
                                mqttListener.connectToBroker()
                            }
                        }
                        
                        Button {
                            text: I18n.t("disconnectBtn") || "断开"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: mqttListener.isConnected
                            
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
                                mqttListener.disconnect()
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: I18n.t("subscriptionSettings") || "订阅设置"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "主题:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 50
                        }
                        
                        TextField {
                            id: topicInput
                            Layout.fillWidth: true
                            text: "test/topic"
                            placeholderText: "例如: test/topic, sensor/+/temperature 或 # (订阅所有主题)"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: topicInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: topicInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                mqttListener.topic = text
                            }
                            
                            onTextChanged: {
                                mqttListener.topic = text
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "QoS级别:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 80
                        }
                        
                        ComboBox {
                            id: qosCombo
                            Layout.preferredWidth: 100
                            model: ["0", "1", "2"]
                            currentIndex: 1
                            
                            onCurrentIndexChanged: {
                                mqttListener.qos = currentIndex
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("subscribeBtn") || "订阅"
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 32
                            enabled: mqttListener.isConnected && !mqttListener.isSubscribed
                            
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
                                mqttListener.subscribe()
                            }
                        }
                        
                        Button {
                            text: I18n.t("unsubscribeBtn") || "取消订阅"
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 32
                            enabled: mqttListener.isConnected && mqttListener.isSubscribed
                            
                            background: Rectangle {
                                color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#666666"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                mqttListener.unsubscribe()
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
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
                            text: I18n.t("messageLog") || "消息日志:"
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
                                mqttListener.clearLog()
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
                            text: mqttListener.messageLog
                            readOnly: true
                            wrapMode: TextArea.NoWrap
                            textFormat: TextEdit.PlainText
                            font.pixelSize: 12
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333333"
                            selectByMouse: true
                            width: logScrollView.width
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("noMessages") || "暂无消息"
                                font.pixelSize: 14
                                color: "#999999"
                                visible: mqttListener.messageLog.length === 0
                            }
                            
                            onTextChanged: {
                                if (length > 0) {
                                    cursorPosition = length
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
