import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: sha1Window
    width: 600
    height: 600
    title: "SHA1 " + I18n.t("encrypt")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    SHA1Generator {
        id: generator
        
        onInputTextChanged: {
            if (autoGenerate.checked) {
                generate()
            }
        }
        
        onUppercaseChanged: {
            if (generator.inputText.length > 0) {
                generate()
            }
        }
    }
    
    function generate() {
        generator.generate()
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            // 标题
            Text {
                text: "SHA1 " + I18n.t("encrypt")
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "SHA1 " + I18n.t("encryptDesc") || "将文本转换为SHA1哈希值"
                font.pixelSize: 14
                color: "#666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 输入区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("inputText") + ":"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    CheckBox {
                        id: autoGenerate
                        text: I18n.t("autoGenerate") || "自动生成"
                        checked: true
                    }
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    clip: true
                    
                    TextArea {
                        id: inputText
                        placeholderText: I18n.t("enterTextHere") || "请输入要加密的文本..."
                        wrapMode: TextArea.Wrap
                        font.pixelSize: 14
                        color: "#333"
                        selectByMouse: true
                        
                        background: Rectangle {
                            color: "white"
                            border.color: inputText.focus ? "#1976d2" : "#e0e0e0"
                            border.width: inputText.focus ? 2 : 1
                            radius: 8
                        }
                        
                        onTextChanged: {
                            generator.inputText = text
                        }
                    }
                }
            }
            
            // 选项区域
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                CheckBox {
                    id: uppercaseCheck
                    text: I18n.t("uppercase") || "大写输出"
                    checked: false
                    
                    onCheckedChanged: {
                        generator.uppercase = checked
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("generateBtn")
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                        implicitWidth: 100
                        implicitHeight: 36
                    }
                    
                    onClicked: {
                        generate()
                    }
                }
                
                Button {
                    text: I18n.t("clearBtn") || "清空"
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                        implicitWidth: 60
                        implicitHeight: 36
                    }
                    
                    onClicked: {
                        inputText.text = ""
                        generator.inputText = ""
                    }
                }
            }
            
            // 结果显示区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "SHA1 " + I18n.t("resultLabel") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("copyBtn")
                            visible: generator.result.length > 0
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "#1976d2"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                                border.color: "#1976d2"
                                border.width: 1
                                radius: 4
                                implicitWidth: 60
                                implicitHeight: 28
                            }
                            
                            onClicked: {
                                resultText.selectAll()
                                resultText.copy()
                            }
                        }
                    }
                    
                    ScrollView {
                        id: scrollView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: resultText
                            text: generator.result
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 16
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333"
                            selectByMouse: true
                            implicitWidth: parent.width
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("enterTextToGenerate") || "请输入文本以生成SHA1哈希值"
                                font.pixelSize: 14
                                color: "#999"
                                visible: generator.result.length === 0
                            }
                        }
                    }
                }
            }
        }
    }
}