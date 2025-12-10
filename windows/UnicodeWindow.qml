import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: unicodeWindow
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 500
    title: I18n.t("toolUnicode")
    flags: Qt.Window
    modality: Qt.NonModal
    
    property string leftText: ""
    property string rightText: ""
    
    // 中文转Unicode
    function toUnicode(text) {
        var result = ""
        for (var i = 0; i < text.length; i++) {
            var code = text.charCodeAt(i)
            result += "\\u" + ("0000" + code.toString(16).toUpperCase()).slice(-4)
        }
        return result
    }
    
    // Unicode转中文
    function fromUnicode(text) {
        try {
            // 支持 \uXXXX 和 \UXXXXXXXX 格式
            var result = text.replace(/\\u([0-9a-fA-F]{4})/g, function(match, code) {
                return String.fromCharCode(parseInt(code, 16))
            })
            
            // 支持 &#xXXXX; 格式
            result = result.replace(/&#x([0-9a-fA-F]+);/g, function(match, code) {
                return String.fromCharCode(parseInt(code, 16))
            })
            
            // 支持 &#XXXXX; 格式
            result = result.replace(/&#(\d+);/g, function(match, code) {
                return String.fromCharCode(parseInt(code, 10))
            })
            
            // 支持 U+XXXX 格式
            result = result.replace(/U\+([0-9a-fA-F]{4,6})/g, function(match, code) {
                return String.fromCharCode(parseInt(code, 16))
            })
            
            return result
        } catch(e) {
            console.log("Unicode decode error:", e)
            return text
        }
    }
    
    // 转换为Unicode
    function convertToUnicode() {
        rightText = toUnicode(leftText)
    }
    
    // 转换为中文
    function convertToChinese() {
        leftText = fromUnicode(rightText)
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
                    text: I18n.t("toolUnicode")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolUnicodeDesc")
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
                
                // 左侧：中文输入区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("chineseText") || "中文文本"
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
                                placeholderText: I18n.t("unicodePlaceholderChinese") || "在此输入中文文本..."
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei"
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
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // 中间转换按钮
                ColumnLayout {
                    Layout.preferredWidth: 80
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 15
                    
                    Button {
                        text: "→\n转Unicode"
                        Layout.fillWidth: true
                        height: 70
                        enabled: leftText.length > 0
                        onClicked: convertToUnicode()
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
                        text: "←\n转中文"
                        Layout.fillWidth: true
                        height: 70
                        enabled: rightText.length > 0
                        onClicked: convertToChinese()
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
                
                // 右侧：Unicode输出区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("unicodeText") || "Unicode 编码"
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
                                placeholderText: I18n.t("unicodePlaceholderCode") || "在此输入Unicode编码..."
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
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            // 说明文字
            Text {
                Layout.fillWidth: true
                text: I18n.t("unicodeTip") || "支持格式：\\uXXXX、&#xXXXX;、&#XXXXX;、U+XXXX"
                font.pixelSize: 11
                color: "#999"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
