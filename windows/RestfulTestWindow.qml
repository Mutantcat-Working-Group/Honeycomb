import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: restfulTestWindow
    width: 900
    height: 750
    title: I18n.t("toolRestfulTest")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    RestfulTest {
        id: restfulTest
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
                text: I18n.t("toolRestfulTest")
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRestfulTestDesc")
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
            
            // 请求配置区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    // 第一行：方法和URL
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("httpMethod") || "HTTP方法:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            Layout.preferredWidth: 80
                        }
                        
                        ComboBox {
                            id: methodComboBox
                            Layout.preferredWidth: 120
                            model: ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
                            currentIndex: 0
                            
                            background: Rectangle {
                                color: "white"
                                border.color: methodComboBox.focus ? "#1976d2" : "#e0e0e0"
                                border.width: methodComboBox.focus ? 2 : 1
                                radius: 4
                            }
                            
                            onCurrentTextChanged: {
                                restfulTest.method = currentText
                            }
                        }
                        
                        Text {
                            text: I18n.t("requestUrl") || "请求URL:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            Layout.preferredWidth: 80
                        }
                        
                        TextField {
                            id: urlInput
                            Layout.fillWidth: true
                            text: "https://httpbin.org/get"
                            placeholderText: I18n.t("enterRequestUrl") || "请输入请求URL..."
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: urlInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: urlInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                restfulTest.requestUrl = text
                            }
                            
                            onTextChanged: {
                                restfulTest.requestUrl = text
                            }
                        }
                    }
                    
                    // 第二行：内容类型
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("contentType") || "内容类型:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                            Layout.preferredWidth: 80
                        }
                        
                        ComboBox {
                            id: contentTypeComboBox
                            Layout.preferredWidth: 300
                            model: [
                                { text: "application/json", value: "application/json" },
                                { text: "application/x-www-form-urlencoded", value: "application/x-www-form-urlencoded" },
                                { text: "text/plain", value: "text/plain" },
                                { text: "text/html", value: "text/html" },
                                { text: "application/xml", value: "application/xml" }
                            ]
                            textRole: "text"
                            valueRole: "value"
                            currentIndex: 0
                            
                            background: Rectangle {
                                color: "white"
                                border.color: contentTypeComboBox.focus ? "#1976d2" : "#e0e0e0"
                                border.width: contentTypeComboBox.focus ? 2 : 1
                                radius: 4
                            }
                            
                            onCurrentValueChanged: {
                                restfulTest.contentType = currentValue
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("sendRequest") || "发送请求"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 32
                            enabled: !restfulTest.isLoading
                            
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
                                
                                // 添加加载指示器覆盖
                                BusyIndicator {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    running: restfulTest.isLoading
                                    visible: restfulTest.isLoading
                                    implicitWidth: 16
                                    implicitHeight: 16
                                }
                            }
                            
                            onClicked: {
                                restfulTest.sendRequest()
                            }
                        }
                    }
                    
                    // 第三行：请求头
                    ColumnLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("requestHeaders") || "请求头 (每行一个，格式: Key: Value):"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            clip: true
                            
                            TextArea {
                                id: headersInput
                                text: ""
                                placeholderText: "Authorization: Bearer token\nContent-Type: application/json"
                                font.pixelSize: 12
                                font.family: "Consolas, Monaco, monospace"
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: headersInput.focus ? "#1976d2" : "#e0e0e0"
                                    border.width: headersInput.focus ? 2 : 1
                                    radius: 4
                                }
                                
                                onTextChanged: {
                                    restfulTest.headers = text
                                }
                            }
                        }
                    }
                }
            }
            
            // 请求体区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    Text {
                        text: I18n.t("requestBody") || "请求体:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: bodyInput
                            text: ""
                            placeholderText: I18n.t("enterRequestBody") || "请输入请求体内容..."
                            font.pixelSize: 12
                            font.family: "Consolas, Monaco, monospace"
                            
                            background: Rectangle {
                                color: "white"
                                border.color: bodyInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: bodyInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            onTextChanged: {
                                restfulTest.body = text
                            }
                        }
                    }
                }
            }
            
            // 响应区域
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
                    
                    // 响应状态行
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("responseStatus") || "响应状态:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Rectangle {
                            width: 60
                            height: 24
                            radius: 4
                            color: {
                                if (restfulTest.statusCode >= 200 && restfulTest.statusCode < 300) return "#27ae60"
                                else if (restfulTest.statusCode >= 300 && restfulTest.statusCode < 400) return "#f39c12"
                                else if (restfulTest.statusCode >= 400) return "#e74c3c"
                                else return "#95a5a6"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: restfulTest.statusCode > 0 ? restfulTest.statusCode.toString() : "----"
                                color: "white"
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("clearResponse") || "清空响应"
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
                                restfulTest.clearResponse()
                            }
                        }
                    }
                    
                    // 响应选项卡
                    TabBar {
                        id: responseTabBar
                        Layout.fillWidth: true
                        
                        TabButton {
                            text: I18n.t("responseBody") || "响应体"
                        }
                        
                        TabButton {
                            text: I18n.t("responseHeaders") || "响应头"
                        }
                    }
                    
                    // 响应内容
                    StackLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: responseTabBar.currentIndex
                        
                        ScrollView {
                            clip: true
                            
                            TextArea {
                                text: restfulTest.response
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
                                    text: I18n.t("noResponse") || "暂无响应数据"
                                    font.pixelSize: 14
                                    color: "#999999"
                                    visible: restfulTest.response.length === 0
                                }
                            }
                        }
                        
                        ScrollView {
                            clip: true
                            
                            TextArea {
                                text: restfulTest.responseHeaders
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
                                    text: I18n.t("noHeaders") || "暂无响应头"
                                    font.pixelSize: 14
                                    color: "#999999"
                                    visible: restfulTest.responseHeaders.length === 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
