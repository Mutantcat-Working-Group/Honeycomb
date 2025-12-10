import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: caseConvertWindow
    width: 700
    height: 550
    minimumWidth: 600
    minimumHeight: 450
    title: I18n.t("caseConvert") || "大小写转换"
    
    property string currentMode: "upper"
    
    // 转换函数
    function convertCase(text, mode) {
        switch (mode) {
            case "upper":
                return text.toUpperCase()
            case "lower":
                return text.toLowerCase()
            case "capitalize":
                // 首字母大写
                if (text.length === 0) return ""
                return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase()
            case "titleCase":
                // 单词首字母大写 - 使用简单循环实现
                var words = text.split(/(\s+)/)
                var result = ""
                for (var i = 0; i < words.length; i++) {
                    var word = words[i]
                    if (word.length > 0 && !/^\s+$/.test(word)) {
                        result += word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
                    } else {
                        result += word
                    }
                }
                return result
            case "toggleCase":
                // 大小写互换
                var chars = text.split('')
                var toggled = ""
                for (var j = 0; j < chars.length; j++) {
                    var c = chars[j]
                    if (c === c.toUpperCase()) {
                        toggled += c.toLowerCase()
                    } else {
                        toggled += c.toUpperCase()
                    }
                }
                return toggled
            default:
                return text
        }
    }
    
    function doConvert() {
        outputArea.text = convertCase(inputArea.text, currentMode)
    }
    
    function copyOutput() {
        if (outputArea.text.length > 0) {
            outputArea.selectAll()
            outputArea.copy()
            outputArea.deselect()
        }
    }
    
    function clearAll() {
        inputArea.text = ""
        outputArea.text = ""
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // 转换模式选择卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: I18n.t("caseMode") || "转换模式:"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    // 全部大写
                    Button {
                        text: I18n.t("caseUpper") || "全部大写"
                        Layout.preferredHeight: 36
                        checkable: true
                        checked: currentMode === "upper"
                        onClicked: { currentMode = "upper"; doConvert() }
                        
                        background: Rectangle {
                            color: parent.checked ? "#0078d4" : (parent.hovered ? "#f0f0f0" : "#e8e8e8")
                            border.color: parent.checked ? "#0078d4" : "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: parent.checked ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // 全部小写
                    Button {
                        text: I18n.t("caseLower") || "全部小写"
                        Layout.preferredHeight: 36
                        checkable: true
                        checked: currentMode === "lower"
                        onClicked: { currentMode = "lower"; doConvert() }
                        
                        background: Rectangle {
                            color: parent.checked ? "#0078d4" : (parent.hovered ? "#f0f0f0" : "#e8e8e8")
                            border.color: parent.checked ? "#0078d4" : "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: parent.checked ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // 首字母大写
                    Button {
                        text: I18n.t("caseCapitalize") || "首字母大写"
                        Layout.preferredHeight: 36
                        checkable: true
                        checked: currentMode === "capitalize"
                        onClicked: { currentMode = "capitalize"; doConvert() }
                        
                        background: Rectangle {
                            color: parent.checked ? "#0078d4" : (parent.hovered ? "#f0f0f0" : "#e8e8e8")
                            border.color: parent.checked ? "#0078d4" : "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: parent.checked ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // 单词首字母大写
                    Button {
                        text: I18n.t("caseTitleCase") || "单词首字母大写"
                        Layout.preferredHeight: 36
                        checkable: true
                        checked: currentMode === "titleCase"
                        onClicked: { currentMode = "titleCase"; doConvert() }
                        
                        background: Rectangle {
                            color: parent.checked ? "#0078d4" : (parent.hovered ? "#f0f0f0" : "#e8e8e8")
                            border.color: parent.checked ? "#0078d4" : "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: parent.checked ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    // 大小写互换
                    Button {
                        text: I18n.t("caseToggle") || "大小写互换"
                        Layout.preferredHeight: 36
                        checkable: true
                        checked: currentMode === "toggleCase"
                        onClicked: { currentMode = "toggleCase"; doConvert() }
                        
                        background: Rectangle {
                            color: parent.checked ? "#0078d4" : (parent.hovered ? "#f0f0f0" : "#e8e8e8")
                            border.color: parent.checked ? "#0078d4" : "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: parent.checked ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                }
            }
            
            // 输入输出区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                
                // 输入区
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8
                        
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
                                text: inputArea.text.length + " " + (I18n.t("chars") || "字符")
                                font.pixelSize: 12
                                color: "#999"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#fafafa"
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4
                            
                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 1
                                
                                TextArea {
                                    id: inputArea
                                    placeholderText: I18n.t("casePlaceholder") || "在此输入要转换的文本..."
                                    font.pixelSize: 13
                                    font.family: "Consolas, Microsoft YaHei"
                                    wrapMode: TextArea.Wrap
                                    background: null
                                    onTextChanged: doConvert()
                                }
                            }
                        }
                    }
                }
                
                // 中间按钮区
                ColumnLayout {
                    Layout.preferredWidth: 80
                    Layout.fillHeight: true
                    spacing: 10
                    
                    Item { Layout.fillHeight: true }
                    
                    Button {
                        text: I18n.t("copy") || "复制"
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: copyOutput()
                        
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
                    
                    Button {
                        text: I18n.t("clear") || "清空"
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: clearAll()
                        
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                            border.color: "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
                
                // 输出区
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: I18n.t("outputText") || "输出结果"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: outputArea.text.length + " " + (I18n.t("chars") || "字符")
                                font.pixelSize: 12
                                color: "#999"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#f0f8ff"
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4
                            
                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 1
                                
                                TextArea {
                                    id: outputArea
                                    readOnly: true
                                    font.pixelSize: 13
                                    font.family: "Consolas, Microsoft YaHei"
                                    wrapMode: TextArea.Wrap
                                    background: null
                                    color: "#333"
                                }
                            }
                        }
                    }
                }
            }
            
            // 底部说明卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 4
                    
                    Text {
                        text: I18n.t("caseTips") || "功能说明"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: I18n.t("caseTipsContent") || "• 全部大写: hello → HELLO  • 全部小写: HELLO → hello  • 首字母大写: hello world → Hello world  • 单词首字母大写: hello world → Hello World  • 大小写互换: HeLLo → hEllO"
                        font.pixelSize: 12
                        color: "#666"
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }
}
