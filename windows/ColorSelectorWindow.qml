import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: colorSelectorWindow
    width: 450
    height: 450
    minimumWidth: 400
    minimumHeight: 450
    title: I18n.t("toolColorSelect")
    flags: Qt.Window
    modality: Qt.NonModal
    
    property color selectedColor: "#165DFF"
    
    ColorSelector {
        id: colorSelector
        onCurrentColorChanged: {
            selectedColor = colorSelector.currentColor
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
                    text: I18n.t("toolColorSelect")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolColorSelectDesc") || "点击色块选择颜色"
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
            
            // 色块（正方形）
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 150
                Layout.preferredWidth: 150
                width: 150
                height: 150
                color: selectedColor
                border.color: "#333"
                border.width: 2
                radius: 6
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorSelector.openColorDialog(selectedColor, null)
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
                    
                    // 当前颜色值标签
                    Text {
                        text: I18n.t("currentColorValue") || "当前颜色值"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#333"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    // 颜色值显示框
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#f9f9f9"
                        border.color: "#d0d0d0"
                        border.width: 1
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: selectedColor.toString().toUpperCase()
                            font.pixelSize: 13
                            font.family: "Consolas, Microsoft YaHei"
                            color: "#333"
                        }
                    }
                    
                    // 复制颜色值按钮
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        text: copyButtonText
                        onClicked: {
                            copyToClipboard(selectedColor.toString().toUpperCase())
                            copyButtonText = I18n.t("copied") || "已复制"
                            copyTimer.start()
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
                        
                        property string copyButtonText: I18n.t("copyColorValue") || "复制颜色值"
                        
                        Timer {
                            id: copyTimer
                            interval: 1500
                            onTriggered: parent.copyButtonText = I18n.t("copyColorValue") || "复制颜色值"
                        }
                    }
                    
                    Item {
                        Layout.fillHeight: true
                    }
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
}

