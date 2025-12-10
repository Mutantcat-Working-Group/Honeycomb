import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: jsonFormatWindow
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 450
    title: I18n.t("toolJsonFormat")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // JSON 格式化函数
    function formatJson() {
        try {
            // 尝试解析 JSON
            var jsonObj = JSON.parse(jsonTextArea.text)
            
            // 格式化并设置回文本框
            jsonTextArea.text = JSON.stringify(jsonObj, null, 2)
        } catch (e) {
            // 如果解析失败，显示错误信息
            jsonTextArea.text = I18n.t("jsonFormatError") + e.message
        }
    }
    
    // 复制结果
    function copyResult() {
        if (jsonTextArea.text.length > 0) {
            jsonTextArea.selectAll()
            jsonTextArea.copy()
            jsonTextArea.deselect()
            copyBtn.text = I18n.t("copied") || "已复制"
            copyTimer.start()
        }
    }
    
    Timer {
        id: copyTimer
        interval: 1500
        onTriggered: copyBtn.text = I18n.t("jsonCopyResult") || "复制结果"
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
                        text: I18n.t("toolJsonFormat")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolJsonFormatDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 格式化按钮
                Button {
                    text: I18n.t("formatBtn")
                    width: 90
                    height: 32
                    onClicked: formatJson()
                    
                    background: Rectangle {
                        color: parent.hovered ? "#006cbd" : "#0078d4"
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
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 输入区域
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: I18n.t("inputText") || "输入文本"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: (I18n.t("jsonCharCount") || "字符数") + ": " + jsonTextArea.length
                        font.pixelSize: 12
                        color: "#888"
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: jsonTextArea.activeFocus ? "#0078d4" : "#d0d0d0"
                    border.width: jsonTextArea.activeFocus ? 2 : 1
                    radius: 6
                    
                    Flickable {
                        id: flickable
                        anchors.fill: parent
                        anchors.margins: 8
                        contentWidth: width
                        contentHeight: jsonTextArea.contentHeight
                        clip: true
                        flickableDirection: Flickable.VerticalFlick
                        
                        TextArea.flickable: TextArea {
                            id: jsonTextArea
                            placeholderText: I18n.t("jsonInputPlaceholder")
                            font.pixelSize: 14
                            font.family: "Consolas, Monaco, monospace"
                            wrapMode: TextArea.Wrap
                            selectByMouse: true
                            
                            background: null
                        }
                        
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: I18n.t("jsonClearInput")
                        width: 70
                        height: 32
                        onClicked: {
                            jsonTextArea.text = ""
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                            radius: 4
                            border.color: "#ccc"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        id: copyBtn
                        text: I18n.t("jsonCopyResult")
                        width: 90
                        height: 32
                        enabled: jsonTextArea.length > 0
                        onClicked: copyResult()
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
            }
        }
    }
}