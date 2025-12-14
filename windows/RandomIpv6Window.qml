import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: randomIpv6Window
    width: 600
    height: 550
    title: I18n.t("toolRandomIpv6")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    RandomIpv6Generator {
        id: generator
        count: parseInt(countInput.text) || 1
        ipType: ipTypeComboBox.currentValue
        format: formatComboBox.currentValue
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 标题
            Text {
                text: I18n.t("toolRandomIpv6")
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRandomIpv6Desc")
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
            
            // 设置区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                // 生成数量
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("generateCount") || "生成数量:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        Layout.preferredWidth: 80
                    }
                    
                    TextField {
                        id: countInput
                        Layout.preferredWidth: 150
                        text: "1"
                        placeholderText: "1-100"
                        validator: IntValidator { bottom: 1; top: 100 }
                        horizontalAlignment: TextInput.AlignCenter
                        
                        background: Rectangle {
                            color: "#f9f9f9"
                            border.color: countInput.focus ? "#1976d2" : "#e0e0e0"
                            border.width: countInput.focus ? 2 : 1
                            radius: 4
                        }
                    }
                    
                    Text {
                        text: "个"
                        font.pixelSize: 14
                        color: "#666666"
                    }
                    
                    Item { Layout.fillWidth: true }
                }
                
                // IP类型选择
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("ipType") || "IP类型:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        Layout.preferredWidth: 80
                    }
                    
                    ComboBox {
                        id: ipTypeComboBox
                        Layout.preferredWidth: 200
                        model: [
                            { text: I18n.t("random") || "随机", value: "random" },
                            { text: I18n.t("globalUnicast") || "全局单播", value: "global" },
                            { text: I18n.t("linkLocal") || "链路本地", value: "linklocal" },
                            { text: I18n.t("uniqueLocal") || "唯一本地", value: "uniquelocal" },
                            { text: I18n.t("multicast") || "多播", value: "multicast" }
                        ]
                        textRole: "text"
                        valueRole: "value"
                        
                        background: Rectangle {
                            color: "#f9f9f9"
                            border.color: ipTypeComboBox.focus ? "#1976d2" : "#e0e0e0"
                            border.width: ipTypeComboBox.focus ? 2 : 1
                            radius: 4
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                }
                
                // 格式选择
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("format") || "格式:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        Layout.preferredWidth: 80
                    }
                    
                    ComboBox {
                        id: formatComboBox
                        Layout.preferredWidth: 200
                        model: [
                            { text: I18n.t("fullFormat") || "完整格式", value: "full" },
                            { text: I18n.t("compressedFormat") || "压缩格式", value: "compressed" }
                        ]
                        textRole: "text"
                        valueRole: "value"
                        
                        background: Rectangle {
                            color: "#f9f9f9"
                            border.color: formatComboBox.focus ? "#1976d2" : "#e0e0e0"
                            border.width: formatComboBox.focus ? 2 : 1
                            radius: 4
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                }
            }
            
            // 按钮区域
            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("generateBtn") || "生成"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        generator.count = parseInt(countInput.text) || 1
                        generator.ipType = ipTypeComboBox.currentValue
                        generator.format = formatComboBox.currentValue
                        generator.generate()
                    }
                }
                
                Button {
                    text: I18n.t("clearBtn") || "清空"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        generator.result = ""
                    }
                }
            }
            
            // 结果显示区域
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
                            text: I18n.t("resultLabel") || "结果:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("copyBtn") || "复制"
                            visible: generator.result.length > 0
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 28
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                                border.color: "#1976d2"
                                border.width: 1
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "#1976d2"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                resultText.selectAll()
                                resultText.copy()
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: resultText
                            text: generator.result
                            readOnly: true
                            wrapMode: TextArea.NoWrap
                            font.pixelSize: 14
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333333"
                            selectByMouse: true
                            implicitWidth: parent.width
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("clickToGenerate") || "点击上方按钮生成"
                                font.pixelSize: 14
                                color: "#999999"
                                visible: generator.result.length === 0
                            }
                        }
                    }
                }
            }
        }
    }
}