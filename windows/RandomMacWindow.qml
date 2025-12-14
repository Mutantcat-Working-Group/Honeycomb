import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: randomMacWindow
    width: 600
    height: 550
    title: I18n.t("toolRandomMac")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    RandomMacGenerator {
        id: generator
        count: parseInt(countInput.text) || 1
        format: formatComboBox.currentValue
        caseType: caseComboBox.currentValue
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
                text: I18n.t("toolRandomMac")
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRandomMacDesc")
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
                            { text: I18n.t("colonFormat") || "冒号分隔 (00:11:22)", value: "colon" },
                            { text: I18n.t("hyphenFormat") || "连字符分隔 (00-11-22)", value: "hyphen" },
                            { text: I18n.t("noFormat") || "无分隔 (001122)", value: "none" }
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
                
                // 大小写选择
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("caseType") || "大小写:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333333"
                        Layout.preferredWidth: 80
                    }
                    
                    ComboBox {
                        id: caseComboBox
                        Layout.preferredWidth: 200
                        model: [
                            { text: I18n.t("lowercase") || "小写 (aa:bb:cc)", value: "lower" },
                            { text: I18n.t("uppercase") || "大写 (AA:BB:CC)", value: "upper" }
                        ]
                        textRole: "text"
                        valueRole: "value"
                        
                        background: Rectangle {
                            color: "#f9f9f9"
                            border.color: caseComboBox.focus ? "#1976d2" : "#e0e0e0"
                            border.width: caseComboBox.focus ? 2 : 1
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
                        generator.format = formatComboBox.currentValue
                        generator.caseType = caseComboBox.currentValue
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