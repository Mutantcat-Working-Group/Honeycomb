import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: wordCountWindow
    width: 850
    height: 550
    minimumWidth: 650
    minimumHeight: 400
    title: I18n.t("toolWordCount")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 统计结果
    property int charCount: 0
    property int charNoSpaceCount: 0
    property int chineseCount: 0
    property int englishCount: 0
    property int numberCount: 0
    property int spaceCount: 0
    property int lineCount: 0
    property int paragraphCount: 0
    property int wordCount: 0
    property int punctuationCount: 0
    
    // 统计函数
    function analyzeText() {
        var text = inputArea.text
        
        if (text.length === 0) {
            charCount = 0
            charNoSpaceCount = 0
            chineseCount = 0
            englishCount = 0
            numberCount = 0
            spaceCount = 0
            lineCount = 0
            paragraphCount = 0
            wordCount = 0
            punctuationCount = 0
            return
        }
        
        charCount = text.length
        
        var chinese = 0, english = 0, numbers = 0, spaces = 0, punctuation = 0
        
        for (var i = 0; i < text.length; i++) {
            var c = text.charCodeAt(i)
            var ch = text[i]
            
            if (c >= 0x4E00 && c <= 0x9FFF) chinese++
            else if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122)) english++
            else if (c >= 48 && c <= 57) numbers++
            else if (ch === ' ' || ch === '\t') spaces++
            else if ((c >= 33 && c <= 47) || (c >= 58 && c <= 64) || 
                     (c >= 91 && c <= 96) || (c >= 123 && c <= 126) ||
                     (c >= 0x3000 && c <= 0x303F) || (c >= 0xFF00 && c <= 0xFFEF)) punctuation++
        }
        
        chineseCount = chinese
        englishCount = english
        numberCount = numbers
        spaceCount = spaces
        punctuationCount = punctuation
        charNoSpaceCount = charCount - spaces - (text.match(/\n/g) || []).length - (text.match(/\r/g) || []).length
        
        var lines = text.split('\n')
        lineCount = lines.length
        
        var paras = 0
        for (var j = 0; j < lines.length; j++) {
            if (lines[j].trim().length > 0) paras++
        }
        paragraphCount = paras
        
        var words = text.match(/[a-zA-Z]+/g)
        wordCount = words ? words.length : 0
    }
    
    // 复制统计结果
    function copyStats() {
        var stats = "总字符数: " + charCount + "\n" +
                   "字符(不含空格): " + charNoSpaceCount + "\n" +
                   "中文字符: " + chineseCount + "\n" +
                   "英文字母: " + englishCount + "\n" +
                   "数字: " + numberCount + "\n" +
                   "空格: " + spaceCount + "\n" +
                   "标点符号: " + punctuationCount + "\n" +
                   "行数: " + lineCount + "\n" +
                   "段落数: " + paragraphCount + "\n" +
                   "英文单词: " + wordCount
        
        statsArea.text = stats
        statsArea.selectAll()
        statsArea.copy()
        statsArea.text = ""
        
        copyBtn.text = I18n.t("copied") || "已复制"
        copyTimer.start()
    }
    
    Timer {
        id: copyTimer
        interval: 1500
        onTriggered: copyBtn.text = I18n.t("copyStats") || "复制统计"
    }
    
    TextArea {
        id: statsArea
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
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Column {
                    spacing: 5
                    Text {
                        text: I18n.t("toolWordCount")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolWordCountDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("analyzeBtn") || "开始统计"
                    width: 100
                    height: 36
                    onClicked: analyzeText()
                    background: Rectangle {
                        color: parent.hovered ? "#006cbd" : "#0078d4"
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
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 左右主体区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20
                
                // 左侧输入区
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
                            text: (I18n.t("charCount") || "字符数") + ": " + inputArea.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: inputArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: inputArea.activeFocus ? 2 : 1
                        radius: 6
                        
                        Flickable {
                            id: inputFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: inputArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: inputArea
                                placeholderText: I18n.t("wordCountPlaceholder") || "在此粘贴或输入需要统计的文本..."
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                
                                background: null
                            }
                            
                            ScrollBar.vertical: ScrollBar { }
                        }
                    }
                    
                    Button {
                        text: I18n.t("clearInput") || "清空"
                        Layout.alignment: Qt.AlignRight
                        width: 70
                        height: 32
                        onClicked: {
                            inputArea.text = ""
                            analyzeText()
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
                }
                
                // 右侧统计结果区
                ColumnLayout {
                    Layout.preferredWidth: 160
                    Layout.maximumWidth: 160
                    Layout.fillHeight: true
                    spacing: 10
                    
                    Text {
                        text: I18n.t("statsResult") || "统计结果"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 0
                            
                            // 主要数字 - 总字符
                            Rectangle {
                                width: parent.width
                                height: 60
                                color: "#0078d4"
                                radius: 6
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    
                                    Text {
                                        text: charCount.toLocaleString()
                                        font.pixelSize: 26
                                        font.bold: true
                                        color: "white"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: I18n.t("totalChars") || "总字符"
                                        font.pixelSize: 11
                                        color: "#d9ffffff"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            
                            Item { height: 12; width: 1 }
                            
                            // 统计列表
                            Column {
                                width: parent.width
                                spacing: 6
                                
                                StatRow { label: I18n.t("charsNoSpace") || "不含空格"; value: charNoSpaceCount; dotColor: "#3498db" }
                                StatRow { label: I18n.t("chineseChars") || "中文字符"; value: chineseCount; dotColor: "#e74c3c" }
                                StatRow { label: I18n.t("englishChars") || "英文字母"; value: englishCount; dotColor: "#27ae60" }
                                StatRow { label: I18n.t("numbers") || "数字"; value: numberCount; dotColor: "#f39c12" }
                                StatRow { label: I18n.t("spaces") || "空格"; value: spaceCount; dotColor: "#95a5a6" }
                                StatRow { label: I18n.t("punctuations") || "标点符号"; value: punctuationCount; dotColor: "#9b59b6" }
                                
                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    color: "#eee"
                                }
                                
                                StatRow { label: I18n.t("lines") || "行数"; value: lineCount; dotColor: "#1abc9c" }
                                StatRow { label: I18n.t("paragraphs") || "段落数"; value: paragraphCount; dotColor: "#e67e22" }
                                StatRow { label: I18n.t("englishWords") || "英文单词"; value: wordCount; dotColor: "#2980b9" }
                            }
                        }
                    }
                    
                    Button {
                        id: copyBtn
                        text: I18n.t("copyStats") || "复制统计"
                        Layout.fillWidth: true
                        height: 32
                        enabled: charCount > 0
                        onClicked: copyStats()
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
    
    // 统计行组件
    component StatRow: RowLayout {
        property string label: ""
        property int value: 0
        property string dotColor: "#333"
        width: parent.width
        height: 24
        spacing: 8
        
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: dotColor
            Layout.alignment: Qt.AlignVCenter
        }
        
        Text {
            text: label
            font.pixelSize: 12
            color: "#666"
            Layout.fillWidth: true
        }
        
        Text {
            text: value.toLocaleString()
            font.pixelSize: 13
            font.bold: true
            color: "#333"
        }
    }
}
