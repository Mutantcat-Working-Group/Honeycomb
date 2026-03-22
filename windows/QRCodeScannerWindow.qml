import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: qrScannerWindow
    width: 700
    height: 650
    minimumWidth: 550
    minimumHeight: 500
    title: I18n.t("toolQRScanner")
    flags: Qt.Window
    modality: Qt.NonModal
    
    QRCodeScanner {
        id: scanner
        
        onScanSuccess: function(text) {
            statusText.text = I18n.t("qrScanResult") + " - " + scanner.formatName
            statusText.color = "#4caf50"
        }
        
        onScanError: function(error) {
            statusText.text = error
            statusText.color = "#f44336"
        }
        
        onCopySuccess: {
            copyBtn.text = I18n.t("copied") || "已复制"
            copyTimer.start()
        }
        
        onCaptureFinished: {
            qrScannerWindow.visible = true
        }
    }
    
    FileDialog {
        id: openDialog
        title: I18n.t("qrScanSelectImage")
        fileMode: FileDialog.OpenFile
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.bmp *.gif *.webp)", "All files (*)"]
        currentFolder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        
        onAccepted: {
            scanner.scanFromFile(selectedFile)
        }
    }
    
    Timer {
        id: copyTimer
        interval: 1500
        onTriggered: copyBtn.text = I18n.t("copyResult") || "复制结果"
    }
    
    Timer {
        id: screenshotTimer
        interval: 500
        onTriggered: {
            scanner.captureScreen()
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15
            
            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Column {
                    spacing: 5
                    Text {
                        text: I18n.t("toolQRScanner")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolQRScannerDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 操作按钮栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Button {
                    text: I18n.t("qrScanSelectImage") || "选择图片"
                    implicitWidth: 120
                    implicitHeight: 36
                    onClicked: openDialog.open()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: I18n.t("qrScanClipboard") || "从剪贴板"
                    implicitWidth: 120
                    implicitHeight: 36
                    onClicked: scanner.scanFromClipboard()
                    
                    background: Rectangle {
                        color: parent.pressed ? "#2e7d32" : (parent.hovered ? "#43a047" : "#4caf50")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: I18n.t("qrScanScreenshot") || "截图识别"
                    implicitWidth: 120
                    implicitHeight: 36
                    onClicked: {
                        statusText.text = ""
                        qrScannerWindow.visible = false
                        screenshotTimer.start()
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#e65100" : (parent.hovered ? "#fb8c00" : "#ff9800")
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            // 图片显示区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 200
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                Image {
                    id: scannedImage
                    anchors.fill: parent
                    anchors.margins: 10
                    source: scanner.imageSource
                    fillMode: Image.PreserveAspectFit
                    cache: false
                }
                
                Text {
                    anchors.centerIn: parent
                    text: I18n.t("qrScanNoImage") || "点击上方按钮加载或截取图片"
                    font.pixelSize: 14
                    color: "#999"
                    visible: !scanner.hasImage
                }
            }
            
            // 状态信息
            Text {
                id: statusText
                Layout.fillWidth: true
                font.pixelSize: 12
                color: "#666"
                wrapMode: Text.WordWrap
            }
            
            // 识别结果区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("qrScanResult") || "识别结果"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Text {
                        text: scanner.formatName ? ("(" + scanner.formatName + ")") : ""
                        font.pixelSize: 12
                        color: "#888"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        id: copyBtn
                        text: I18n.t("copyResult") || "复制结果"
                        implicitWidth: 90
                        implicitHeight: 30
                        enabled: scanner.result.length > 0
                        onClicked: scanner.copyResult()
                        
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 100
                    color: "#fafafa"
                    border.color: "#d0d0d0"
                    border.width: 1
                    radius: 6
                    
                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 8
                        contentWidth: width
                        contentHeight: resultArea.contentHeight
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        
                        TextArea.flickable: TextArea {
                            id: resultArea
                            text: scanner.result
                            readOnly: true
                            font.pixelSize: 14
                            font.family: "Consolas, Microsoft YaHei"
                            wrapMode: TextArea.Wrap
                            selectByMouse: true
                            placeholderText: I18n.t("qrScanNoResult") || "未检测到二维码或条码"
                            
                            background: null
                        }
                        
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
            }
        }
    }
}
