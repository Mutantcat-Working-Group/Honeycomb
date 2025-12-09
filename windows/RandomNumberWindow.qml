import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: randomNumberWindow
    width: 500
    height: 400
    title: I18n.t("toolRandomNum")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    RandomNumberGenerator {
        id: generator
        length: parseInt(lengthInput.text) || 8
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
                text: I18n.t("toolRandomNum")
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRandomNumDesc")
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
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: I18n.t("randomNumLength") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                TextField {
                    id: lengthInput
                    Layout.preferredWidth: 100
                    text: "8"
                    placeholderText: "1-999"
                    validator: IntValidator { bottom: 1; top: 999 }
                    horizontalAlignment: TextInput.AlignCenter
                    
                    background: Rectangle {
                        color: "white"
                        border.color: lengthInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: lengthInput.focus ? 2 : 1
                        radius: 4
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
                        generator.length = parseInt(lengthInput.text) || 8
                        generator.generate()
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
                            text: I18n.t("resultLabel") + ":"
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
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        
                        Component.onCompleted: {
                            ScrollBar.vertical.width = 4
                        }
                        
                        TextArea {
                            id: resultText
                            text: generator.result
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 18
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333"
                            selectByMouse: true
                            implicitWidth: parent.width
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("clickToGenerate")
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
