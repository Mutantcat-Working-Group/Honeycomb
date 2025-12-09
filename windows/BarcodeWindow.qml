import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: barcodeWindow
    width: 600
    height: 500
    title: I18n.t("toolBarcode")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    BarcodeGenerator {
        id: generator
        
        onSaveSuccess: function(path) {
            statusText.text = I18n.t("saveSuccess") + ": " + path
            statusText.color = "#4caf50"
        }
        
        onSaveError: function(error) {
            statusText.text = error
            statusText.color = "#f44336"
        }
        
        onCopySuccess: {
            statusText.text = I18n.t("copySuccess")
            statusText.color = "#4caf50"
        }
    }
    
    // 保存文件对话框
    FileDialog {
        id: saveDialog
        title: I18n.t("saveBarcode")
        fileMode: FileDialog.SaveFile
        nameFilters: ["PNG Image (*.png)", "JPEG Image (*.jpg)", "All files (*)"]
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        
        onAccepted: {
            generator.saveToFile(selectedFile)
        }
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
                text: I18n.t("toolBarcode")
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolBarcodeDesc")
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
                    text: I18n.t("barcodeInput") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                TextField {
                    id: textInput
                    Layout.fillWidth: true
                    placeholderText: I18n.t("barcodeInputHint")
                    horizontalAlignment: TextInput.AlignLeft
                    
                    background: Rectangle {
                        color: "white"
                        border.color: textInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: textInput.focus ? 2 : 1
                        radius: 4
                    }
                }
                
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
                        generator.text = textInput.text
                        generator.generate()
                        statusText.text = ""
                    }
                }
            }
            
            // 条形码显示区域
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
                    
                    // 按钮栏
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
                            visible: generator.hasBarcode
                            
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
                                generator.copyToClipboard()
                            }
                        }
                        
                        Button {
                            text: I18n.t("saveBtn")
                            visible: generator.hasBarcode
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "#4caf50"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#e8f5e9" : (parent.hovered ? "#f5f5f5" : "transparent")
                                border.color: "#4caf50"
                                border.width: 1
                                radius: 4
                                implicitWidth: 60
                                implicitHeight: 28
                            }
                            
                            onClicked: {
                                saveDialog.open()
                            }
                        }
                    }
                    
                    // 条形码图片显示
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        Image {
                            id: barcodeImage
                            anchors.centerIn: parent
                            source: generator.imageSource
                            fillMode: Image.PreserveAspectFit
                            cache: false
                            
                            // 限制最大尺寸
                            width: Math.min(parent.width - 20, sourceSize.width * 2)
                            height: Math.min(parent.height - 20, sourceSize.height * 2)
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: I18n.t("clickToGenerate")
                            font.pixelSize: 14
                            color: "#999"
                            visible: !generator.hasBarcode
                        }
                    }
                    
                    // 状态文字
                    Text {
                        id: statusText
                        Layout.fillWidth: true
                        font.pixelSize: 12
                        color: "#666"
                        horizontalAlignment: Text.AlignCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
