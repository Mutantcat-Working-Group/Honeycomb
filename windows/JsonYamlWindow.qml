import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: jsonYamlWindow
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 500
    title: I18n.t("toolJsonYaml")
    flags: Qt.Window
    modality: Qt.NonModal
    
    property string leftText: ""
    property string rightText: ""
    
    // 创建JsonYamlConverter实例
    JsonYamlConverter {
        id: jsonYamlConverter
    }
    
    // JSON转YAML
    function jsonToYaml(jsonText) {
        try {
            return jsonYamlConverter.jsonToYaml(jsonText)
        } catch(e) {
            console.log("JSON to YAML conversion error:", e)
            return "错误: " + e.toString()
        }
    }
    
    // YAML转JSON
    function yamlToJson(yamlText) {
        try {
            return jsonYamlConverter.yamlToJson(yamlText)
        } catch(e) {
            console.log("YAML to JSON conversion error:", e)
            return "错误: " + e.toString()
        }
    }
    
    // 转换为YAML
    function convertToYaml() {
        rightText = jsonToYaml(leftText)
    }
    
    // 转换为JSON
    function convertToJson() {
        leftText = yamlToJson(rightText)
    }
    
    // 格式化JSON
    function formatJson() {
        try {
            leftText = jsonYamlConverter.formatJson(leftText)
        } catch(e) {
            console.log("JSON format error:", e)
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
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolJsonYaml")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolJsonYamlDesc")
                    font.pixelSize: 13
                    color: "#666"
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 左右转换区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                // 左侧：JSON输入区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 300
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "JSON"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + leftText.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: leftArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: leftArea.activeFocus ? 2 : 1
                        radius: 6
                        
                        Flickable {
                            id: leftFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: leftArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: leftArea
                                text: leftText
                                onTextChanged: leftText = text
                                placeholderText: "在此输入JSON文本..."
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
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
                        layoutDirection: "RightToLeft"
                        
                        Button {
                            id: copyLeftBtn
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 80
                            height: 36
                            enabled: leftText.length > 0
                            onClicked: {
                                copyToClipboard(leftText)
                                text = I18n.t("copied") || "已复制"
                                copyLeftTimer.start()
                            }
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Timer {
                                id: copyLeftTimer
                                interval: 1500
                                onTriggered: copyLeftBtn.text = I18n.t("copy") || "复制"
                            }
                        }

                        Button {
                            text: I18n.t("formatBtn") || "格式化"
                            Layout.preferredWidth: 80
                            height: 36
                            enabled: leftText.length > 0
                            onClicked: formatJson()
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Button {
                            text: I18n.t("clear") || "清空"
                            Layout.preferredWidth: 80
                            height: 36
                            onClicked: leftText = ""
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
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // 中间转换按钮
                ColumnLayout {
                    Layout.preferredWidth: 80
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 15
                    
                    Button {
                        text: "→\n转YAML"
                        Layout.fillWidth: true
                        height: 70
                        enabled: leftText.length > 0
                        onClicked: convertToYaml()
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: "←\n转JSON"
                        Layout.fillWidth: true
                        height: 70
                        enabled: rightText.length > 0
                        onClicked: convertToJson()
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 6
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
                
                // 右侧：YAML输出区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 300
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "YAML"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + rightText.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: rightArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: rightArea.activeFocus ? 2 : 1
                        radius: 6
                        
                        Flickable {
                            id: rightFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: rightArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: rightArea
                                text: rightText
                                onTextChanged: rightText = text
                                placeholderText: "在此输入YAML文本..."
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
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
                        layoutDirection: "RightToLeft"
                         
                        Button {
                            id: copyRightBtn
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 80
                            height: 36
                            enabled: rightText.length > 0
                            onClicked: {
                                copyToClipboard(rightText)
                                text = I18n.t("copied") || "已复制"
                                copyRightTimer.start()
                            }
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Timer {
                                id: copyRightTimer
                                interval: 1500
                                onTriggered: copyRightBtn.text = I18n.t("copy") || "复制"
                            }
                        }

                        Button {
                            text: I18n.t("clear") || "清空"
                            Layout.preferredWidth: 80
                            height: 36
                            onClicked: rightText = ""
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
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            // 说明文字
            Text {
                Layout.fillWidth: true
                text: "支持标准JSON和YAML格式的相互转换"
                font.pixelSize: 11
                color: "#999"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}