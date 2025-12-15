import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: subnetCalculatorWindow
    width: 700
    height: 670
    title: I18n.t("toolSubnetCalculator") || "子网掩码计算器"
    flags: Qt.Window
    modality: Qt.NonModal
    
    SubnetCalculator {
        id: calculator
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text {
                text: I18n.t("toolSubnetCalculator") || "子网掩码计算器"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolSubnetCalculatorDesc") || "计算IP地址的网络信息和主机范围"
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
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    Text {
                        text: I18n.t("inputSettings") || "输入设置"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "IP地址:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        TextField {
                            id: ipInput
                            Layout.fillWidth: true
                            text: "192.168.1.100"
                            placeholderText: "例如: 192.168.1.100"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: ipInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: ipInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                calculator.ipAddress = text
                            }
                            
                            onTextChanged: {
                                calculator.ipAddress = text
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "子网掩码:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        TextField {
                            id: maskInput
                            Layout.fillWidth: true
                            text: "255.255.255.0"
                            placeholderText: "例如: 255.255.255.0"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: maskInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: maskInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                calculator.subnetMask = text
                            }
                            
                            onTextChanged: {
                                calculator.subnetMask = text
                            }
                        }
                        
                        ComboBox {
                            id: cidrCombo
                            Layout.preferredWidth: 80
                            model: ["/8", "/16", "/24", "/25", "/26", "/27", "/28", "/29", "/30", "/31", "/32"]
                            currentIndex: 2
                            
                            onActivated: {
                                var cidr = parseInt(currentText.substring(1));
                                var masks = {
                                    8: "255.0.0.0",
                                    16: "255.255.0.0",
                                    24: "255.255.255.0",
                                    25: "255.255.255.128",
                                    26: "255.255.255.192",
                                    27: "255.255.255.224",
                                    28: "255.255.255.240",
                                    29: "255.255.255.248",
                                    30: "255.255.255.252",
                                    31: "255.255.255.254",
                                    32: "255.255.255.255"
                                };
                                if (masks[cidr]) {
                                    maskInput.text = masks[cidr];
                                }
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("calculateBtn") || "计算"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            
                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                calculator.calculate()
                            }
                        }
                        
                        Button {
                            text: I18n.t("clearBtn") || "清空"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            
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
                                calculator.clear()
                                ipInput.text = calculator.ipAddress
                                maskInput.text = calculator.subnetMask
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
                    
                    Text {
                        text: I18n.t("calculationResult") || "计算结果"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: resultText
                            text: calculator.result
                            readOnly: true
                            wrapMode: TextArea.NoWrap
                            textFormat: TextEdit.PlainText
                            font.pixelSize: 13
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333333"
                            selectByMouse: true
                            
                            background: Rectangle {
                                color: "#f5f5f5"
                                radius: 4
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("clickCalculateToStart") || "点击「计算」按钮开始"
                                font.pixelSize: 14
                                color: "#999999"
                                visible: calculator.result.length === 0
                            }
                        }
                    }
                }
            }
        }
    }
}
