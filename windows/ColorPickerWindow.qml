import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: colorPickerWindow
    width: 550
    height: 520
    minimumWidth: 500
    minimumHeight: 450
    title: I18n.t("toolColorPicker")
    flags: Qt.Window
    modality: Qt.NonModal
    
    property color pickedColor: "#000000"
    property bool isPicking: false
    
    ColorPicker {
        id: colorPicker
        onCurrentColorChanged: {
            if (isPicking) {
                pickedColor = currentColor
            }
        }
        onPickingCancelled: {
            stopPicking()
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolColorPicker")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolColorPickerDesc")
                    font.pixelSize: 13
                    color: "#666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 色块显示区
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                Layout.bottomMargin: 5
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // 色块
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: pickedColor
                        border.color: "#333"
                        border.width: 2
                        radius: 6
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            
                            Text {
                                text: pickedColor.toString().toUpperCase()
                                font.pixelSize: 18
                                font.bold: true
                                font.family: "Consolas, Microsoft YaHei"
                                color: (pickedColor.r * 0.299 + pickedColor.g * 0.587 + pickedColor.b * 0.114) > 0.5 ? "#000000" : "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: "RGB(" + Math.round(pickedColor.r * 255) + ", " + 
                                      Math.round(pickedColor.g * 255) + ", " + 
                                      Math.round(pickedColor.b * 255) + ")"
                                font.pixelSize: 11
                                font.family: "Consolas, Microsoft YaHei"
                                color: (pickedColor.r * 0.299 + pickedColor.g * 0.587 + pickedColor.b * 0.114) > 0.5 ? "#000000" : "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    // 按钮
                    Button {
                        text: isPicking ? I18n.t("stopPicking") : I18n.t("startPicking")
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        onClicked: {
                            if (isPicking) {
                                stopPicking()
                            } else {
                                startPicking()
                            }
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#006cbd" : "#0078d4"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            
            // 颜色信息区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    
                    // HEX 颜色项
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 6
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 12
                            
                            Text {
                                text: I18n.t("colorHex")
                                font.pixelSize: 13
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 140
                            }
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 36
                                color: "#f9f9f9"
                                border.color: "#d0d0d0"
                                border.width: 1
                                radius: 4
                                
                                Text {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    text: pickedColor.toString().toUpperCase()
                                    font.pixelSize: 13
                                    font.family: "Consolas, Microsoft YaHei"
                                    color: "#333"
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            Button {
                                text: I18n.t("copy")
                                Layout.preferredWidth: 65
                                Layout.preferredHeight: 36
                                onClicked: {
                                    copyToClipboard(pickedColor.toString().toUpperCase())
                                    text = I18n.t("copied")
                                    copyTimer1.start()
                                }
                                background: Rectangle {
                                    color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                                    radius: 4
                                    border.color: "#ccc"
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 12
                                    color: "#333"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                Timer {
                                    id: copyTimer1
                                    interval: 1500
                                    onTriggered: parent.text = I18n.t("copy")
                                }
                            }
                        }
                    }
                    
                    // RGB 颜色项
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        Layout.bottomMargin: 20
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 6
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Text {
                                text: I18n.t("colorRGB")
                                font.pixelSize: 13
                                font.bold: true
                                color: "#333"
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                // R 值
                                RowLayout {
                                    spacing: 6
                                    Text { 
                                        text: "R:"; 
                                        font.pixelSize: 13; 
                                        color: "#e74c3c"; 
                                        font.bold: true; 
                                        Layout.preferredWidth: 25 
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 70
                                        Layout.preferredHeight: 36
                                        color: "#f9f9f9"
                                        border.color: "#d0d0d0"
                                        border.width: 1
                                        radius: 4
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            text: Math.round(pickedColor.r * 255).toString()
                                            font.pixelSize: 13
                                            font.family: "Consolas"
                                            color: "#333"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                                
                                // G 值
                                RowLayout {
                                    spacing: 6
                                    Text { 
                                        text: "G:"; 
                                        font.pixelSize: 13; 
                                        color: "#27ae60"; 
                                        font.bold: true; 
                                        Layout.preferredWidth: 25 
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 70
                                        Layout.preferredHeight: 36
                                        color: "#f9f9f9"
                                        border.color: "#d0d0d0"
                                        border.width: 1
                                        radius: 4
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            text: Math.round(pickedColor.g * 255).toString()
                                            font.pixelSize: 13
                                            font.family: "Consolas"
                                            color: "#333"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                                
                                // B 值
                                RowLayout {
                                    spacing: 6
                                    Text { 
                                        text: "B:"; 
                                        font.pixelSize: 13; 
                                        color: "#3498db"; 
                                        font.bold: true; 
                                        Layout.preferredWidth: 25 
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 70
                                        Layout.preferredHeight: 36
                                        color: "#f9f9f9"
                                        border.color: "#d0d0d0"
                                        border.width: 1
                                        radius: 4
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 8
                                            anchors.rightMargin: 8
                                            text: Math.round(pickedColor.b * 255).toString()
                                            font.pixelSize: 13
                                            font.family: "Consolas"
                                            color: "#333"
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: I18n.t("copy")
                                    Layout.preferredWidth: 65
                                    Layout.preferredHeight: 36
                                    onClicked: {
                                        var rgbText = "rgb(" + Math.round(pickedColor.r * 255) + ", " + 
                                                      Math.round(pickedColor.g * 255) + ", " + 
                                                      Math.round(pickedColor.b * 255) + ")"
                                        copyToClipboard(rgbText)
                                        text = I18n.t("copied")
                                        copyTimer2.start()
                                    }
                                    background: Rectangle {
                                        color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                                        radius: 4
                                        border.color: "#ccc"
                                        border.width: 1
                                    }
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
                                        color: "#333"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    Timer {
                                        id: copyTimer2
                                        interval: 1500
                                        onTriggered: parent.text = I18n.t("copy")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 全屏取色覆盖层
    Window {
        id: pickerOverlay
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
        color: "#00000000"  // 完全透明
        visible: false
        
        // 颜色显示框（左上角或右上角）
        Rectangle {
            id: colorDisplayBox
            width: 150
            height: 80
            visible: isPicking
            color: "#e0000000"
            radius: 4
            border.color: "#ffffff"
            border.width: 1
            z: 101
            
            x: {
                if (!isPicking) return 0
                var mouseX = mouseArea.mouseX
                var screenWidth = pickerOverlay.width
                // 如果鼠标在左半屏，显示在右上角；否则显示在左上角
                return mouseX < screenWidth / 2 ? screenWidth - width - 10 : 10
            }
            y: 10
            
            Column {
                anchors.centerIn: parent
                spacing: 5
                
                Rectangle {
                    width: 60
                    height: 30
                    color: pickedColor
                    border.color: "#ffffff"
                    border.width: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: pickedColor.toString().toUpperCase()
                    font.pixelSize: 12
                    font.family: "Consolas"
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "RGB(" + Math.round(pickedColor.r * 255) + "," + 
                          Math.round(pickedColor.g * 255) + "," + 
                          Math.round(pickedColor.b * 255) + ")"
                    font.pixelSize: 10
                    font.family: "Consolas"
                    color: "#ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: isPicking ? Qt.CrossCursor : Qt.ArrowCursor
            
            onPositionChanged: function(mouse) {
                if (isPicking) {
                    colorPickerWindow.updateColorAtMouse()
                }
            }
            
            onEntered: {
                if (isPicking) {
                    colorPickerWindow.updateColorAtMouse()
                }
            }
            
            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton && isPicking) {
                    // 左键点击，确认取色
                    stopPicking()
                } else if (mouse.button === Qt.RightButton && isPicking) {
                    // 右键点击，取消取色
                    stopPicking()
                }
            }
        }
        
        // 定时器用于定期更新颜色（确保实时更新）
        Timer {
            id: colorUpdateTimer
            interval: 16  // 约60fps
            running: isPicking
            repeat: true
            onTriggered: {
                if (isPicking) {
                    colorPickerWindow.updateColorAtMouse()
                }
            }
        }
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
    }
    
    TextArea {
        id: clipboardArea
        visible: false
    }
    
    // 更新鼠标位置的颜色
    function updateColorAtMouse() {
        if (!isPicking) return
        
        // 直接使用光标位置获取颜色（更可靠）
        var color = colorPicker.getColorAtCursor()
        if (color && color.toString() !== "invalid") {
            pickedColor = color
        }
    }
    
    function startPicking() {
        if (isPicking) return
        
        // 隐藏主窗口
        colorPickerWindow.hide()
        
        // 获取当前窗口所在的屏幕
        var screen = colorPickerWindow.screen
        if (!screen) {
            screen = Qt.application.screens[0]
        }
        
        if (!screen) {
            console.log("无法获取屏幕信息")
            colorPickerWindow.show()
            return
        }
        
        // 设置覆盖层为全屏
        pickerOverlay.screen = screen
        
        // 使用 Screen 的几何属性
        var geom = screen.geometry
        if (geom) {
            pickerOverlay.x = Number(geom.x) || 0
            pickerOverlay.y = Number(geom.y) || 0
            pickerOverlay.width = Number(geom.width) || Number(screen.width) || 1920
            pickerOverlay.height = Number(geom.height) || Number(screen.height) || 1080
        } else {
            // 如果 geometry 不可用，使用屏幕的 width 和 height
            pickerOverlay.x = 0
            pickerOverlay.y = 0
            pickerOverlay.width = Number(screen.width) || 1920
            pickerOverlay.height = Number(screen.height) || 1080
        }
        
        // 启动取色
        colorPicker.startPicking(colorPickerWindow)
        isPicking = true
        
        // 显示覆盖层
        pickerOverlay.visible = true
        pickerOverlay.show()
        pickerOverlay.requestActivate()
    }
    
    function stopPicking() {
        if (!isPicking) return
        
        isPicking = false
        colorPicker.stopPicking()
        pickerOverlay.visible = false
        pickerOverlay.hide()
        
        // 显示主窗口
        colorPickerWindow.show()
        colorPickerWindow.requestActivate()
    }
}
