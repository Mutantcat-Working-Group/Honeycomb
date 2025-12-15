import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: registerRangeWindow
    width: 950
    height: 650
    title: I18n.t("toolRegisterRange") || "寄存器寻址范围"
    flags: Qt.Window
    modality: Qt.NonModal
    
    property var registerData: [
        {
            bits: "8位",
            name: "AL/AH/BL/BH/CL/CH/DL/DH",
            range: "0 ~ 255",
            maxValue: "255 (0xFF)",
            signedRange: "-128 ~ 127",
            application: "字节操作、字符处理"
        },
        {
            bits: "16位",
            name: "AX/BX/CX/DX/SI/DI/BP/SP",
            range: "0 ~ 65,535",
            maxValue: "65,535 (0xFFFF)",
            signedRange: "-32,768 ~ 32,767",
            application: "16位系统、DOS程序、实模式"
        },
        {
            bits: "32位",
            name: "EAX/EBX/ECX/EDX/ESI/EDI/EBP/ESP",
            range: "0 ~ 4,294,967,295",
            maxValue: "4,294,967,295 (0xFFFFFFFF)",
            signedRange: "-2,147,483,648 ~ 2,147,483,647",
            application: "32位系统、x86架构、保护模式"
        },
        {
            bits: "64位",
            name: "RAX/RBX/RCX/RDX/RSI/RDI/RBP/RSP/R8~R15",
            range: "0 ~ 18,446,744,073,709,551,615",
            maxValue: "2^64-1 (0xFFFFFFFFFFFFFFFF)",
            signedRange: "-9,223,372,036,854,775,808 ~ 9,223,372,036,854,775,807",
            application: "64位系统、x64架构、大内存寻址"
        }
    ]
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text {
                text: I18n.t("toolRegisterRange") || "寄存器寻址范围"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRegisterRangeDesc") || "不同位数通用寄存器的寻址范围和最大值"
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
                        text: I18n.t("registerInfo") || "寄存器信息"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 15
                            
                            Repeater {
                                model: registerData
                                
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 180
                                    color: "#f8f9fa"
                                    border.color: "#dee2e6"
                                    border.width: 1
                                    radius: 6
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 15
                                        spacing: 8
                                        
                                        RowLayout {
                                            Layout.fillWidth: true
                                            
                                            Rectangle {
                                                width: 60
                                                height: 28
                                                color: "#1976d2"
                                                radius: 4
                                                
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.bits
                                                    font.pixelSize: 14
                                                    font.bold: true
                                                    color: "white"
                                                }
                                            }
                                            
                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "#333333"
                                                font.family: "Consolas, Monaco, monospace"
                                            }
                                            
                                            Item { Layout.fillWidth: true }
                                        }
                                        
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: "#dee2e6"
                                        }
                                        
                                        GridLayout {
                                            Layout.fillWidth: true
                                            columns: 2
                                            rowSpacing: 8
                                            columnSpacing: 20
                                            
                                            Text {
                                                text: "无符号范围:"
                                                font.pixelSize: 13
                                                color: "#495057"
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: modelData.range
                                                font.pixelSize: 13
                                                color: "#212529"
                                                font.family: "Consolas, Monaco, monospace"
                                                Layout.fillWidth: true
                                            }
                                            
                                            Text {
                                                text: "有符号范围:"
                                                font.pixelSize: 13
                                                color: "#495057"
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: modelData.signedRange
                                                font.pixelSize: 13
                                                color: "#212529"
                                                font.family: "Consolas, Monaco, monospace"
                                                Layout.fillWidth: true
                                            }
                                            
                                            Text {
                                                text: "最大值:"
                                                font.pixelSize: 13
                                                color: "#495057"
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: modelData.maxValue
                                                font.pixelSize: 13
                                                color: "#212529"
                                                font.family: "Consolas, Monaco, monospace"
                                                Layout.fillWidth: true
                                            }
                                            
                                            Text {
                                                text: "应用范围:"
                                                font.pixelSize: 13
                                                color: "#495057"
                                                font.bold: true
                                            }
                                            
                                            Text {
                                                text: modelData.application
                                                font.pixelSize: 13
                                                color: "#212529"
                                                Layout.fillWidth: true
                                                wrapMode: Text.WordWrap
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
