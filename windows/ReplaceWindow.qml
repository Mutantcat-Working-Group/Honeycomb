import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: replaceWindow
    width: 950
    height: 650
    minimumWidth: 750
    minimumHeight: 500
    title: I18n.t("toolReplace")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 替换模式
    property int replaceMode: 0  // 0: 普通替换, 1: 正则替换, 2: 转义字符
    
    // 替换函数
    function doReplace() {
        var input = inputArea.text
        var searchStr = searchInput.text
        var replaceStr = replaceInput.text
        
        if (input.length === 0) {
            outputArea.text = ""
            return
        }
        
        if (searchStr.length === 0 && replaceMode !== 2) {
            outputArea.text = input
            return
        }
        
        var result = ""
        
        try {
            switch(replaceMode) {
                case 0: // 普通替换 - 替换所有匹配
                    result = input.split(searchStr).join(replaceStr)
                    break
                case 1: // 正则替换
                    var regex = new RegExp(searchStr, "g")
                    result = input.replace(regex, replaceStr)
                    break
                case 2: // 转义字符处理
                    result = processEscape(input)
                    break
            }
            outputArea.text = result
        } catch (e) {
            outputArea.text = (I18n.t("regexError") || "正则表达式错误") + ": " + e.message
        }
    }
    
    // 转义字符处理
    function processEscape(text) {
        var escapeType = escapeCombo.currentIndex
        switch(escapeType) {
            case 0: // 转义 -> 实际字符
                return text.replace(/\\n/g, "\n")
                          .replace(/\\r/g, "\r")
                          .replace(/\\t/g, "\t")
                          .replace(/\\\\/g, "\\")
                          .replace(/\\"/g, "\"")
                          .replace(/\\'/g, "'")
            case 1: // 实际字符 -> 转义
                return text.replace(/\\/g, "\\\\")
                          .replace(/\n/g, "\\n")
                          .replace(/\r/g, "\\r")
                          .replace(/\t/g, "\\t")
                          .replace(/"/g, "\\\"")
                          .replace(/'/g, "\\'")
            case 2: // HTML 编码
                return text.replace(/&/g, "&amp;")
                          .replace(/</g, "&lt;")
                          .replace(/>/g, "&gt;")
                          .replace(/"/g, "&quot;")
                          .replace(/'/g, "&#39;")
            case 3: // HTML 解码
                return text.replace(/&amp;/g, "&")
                          .replace(/&lt;/g, "<")
                          .replace(/&gt;/g, ">")
                          .replace(/&quot;/g, "\"")
                          .replace(/&#39;/g, "'")
                          .replace(/&nbsp;/g, " ")
            case 4: // URL 编码
                return encodeURIComponent(text)
            case 5: // URL 解码
                return decodeURIComponent(text)
            default:
                return text
        }
    }
    
    // 统计匹配数量
    function countMatches() {
        if (replaceMode === 2 || searchInput.text.length === 0 || inputArea.text.length === 0) {
            return 0
        }
        try {
            if (replaceMode === 0) {
                return inputArea.text.split(searchInput.text).length - 1
            } else {
                var regex = new RegExp(searchInput.text, "g")
                var matches = inputArea.text.match(regex)
                return matches ? matches.length : 0
            }
        } catch (e) {
            return 0
        }
    }
    
    // 复制结果
    function copyResult() {
        if (outputArea.text.length > 0) {
            outputArea.selectAll()
            outputArea.copy()
            outputArea.deselect()
            copyBtn.text = I18n.t("copied") || "已复制"
            copyTimer.start()
        }
    }
    
    Timer {
        id: copyTimer
        interval: 1500
        onTriggered: copyBtn.text = I18n.t("copyResult") || "复制结果"
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
                        text: I18n.t("toolReplace")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolReplaceDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 模式选择
                Row {
                    spacing: 10
                    
                    Button {
                        text: I18n.t("normalReplace") || "普通替换"
                        width: 90
                        height: 32
                        onClicked: replaceMode = 0
                        background: Rectangle {
                            color: replaceMode === 0 ? "#0078d4" : "#e0e0e0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: replaceMode === 0 ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: I18n.t("regexReplace") || "正则替换"
                        width: 90
                        height: 32
                        onClicked: replaceMode = 1
                        background: Rectangle {
                            color: replaceMode === 1 ? "#0078d4" : "#e0e0e0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: replaceMode === 1 ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: I18n.t("escapeConvert") || "转义处理"
                        width: 90
                        height: 32
                        onClicked: replaceMode = 2
                        background: Rectangle {
                            color: replaceMode === 2 ? "#0078d4" : "#e0e0e0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: replaceMode === 2 ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            
            // 替换参数区域
            Rectangle {
                Layout.fillWidth: true
                height: replaceMode === 2 ? 50 : 90
                color: "#f0f0f0"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 15
                    
                    // 普通/正则替换模式的输入
                    ColumnLayout {
                        visible: replaceMode !== 2
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: I18n.t("searchFor") || "查找"
                                font.pixelSize: 13
                                color: "#333"
                                Layout.preferredWidth: 40
                            }
                            
                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: replaceMode === 1 ? 
                                    (I18n.t("regexPlaceholder") || "输入正则表达式...") :
                                    (I18n.t("searchPlaceholder") || "输入要查找的文本...")
                                font.pixelSize: 13
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: parent.activeFocus ? "#0078d4" : "#ccc"
                                    border.width: parent.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                            
                            Text {
                                text: (I18n.t("matchCount") || "匹配") + ": " + countMatches()
                                font.pixelSize: 12
                                color: "#666"
                                Layout.preferredWidth: 70
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: I18n.t("replaceWith") || "替换"
                                font.pixelSize: 13
                                color: "#333"
                                Layout.preferredWidth: 40
                            }
                            
                            TextField {
                                id: replaceInput
                                Layout.fillWidth: true
                                placeholderText: I18n.t("replacePlaceholder") || "输入替换后的文本..."
                                font.pixelSize: 13
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: parent.activeFocus ? "#0078d4" : "#ccc"
                                    border.width: parent.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                            
                            Item { Layout.preferredWidth: 70 }
                        }
                    }
                    
                    // 转义处理模式的下拉框
                    RowLayout {
                        visible: replaceMode === 2
                        Layout.fillWidth: true
                        spacing: 15
                        
                        Text {
                            text: I18n.t("escapeType") || "转义类型"
                            font.pixelSize: 13
                            color: "#333"
                        }
                        
                        ComboBox {
                            id: escapeCombo
                            Layout.preferredWidth: 200
                            model: [
                                I18n.t("escapeToChar") || "转义符 → 实际字符",
                                I18n.t("charToEscape") || "实际字符 → 转义符",
                                I18n.t("htmlEncode") || "HTML 编码",
                                I18n.t("htmlDecode") || "HTML 解码",
                                I18n.t("urlEncode") || "URL 编码",
                                I18n.t("urlDecode") || "URL 解码"
                            ]
                            
                            background: Rectangle {
                                color: "white"
                                border.color: "#ccc"
                                border.width: 1
                                radius: 4
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
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
                    Layout.preferredWidth: 1
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
                                placeholderText: I18n.t("inputPlaceholder") || "在此粘贴或输入需要处理的文本..."
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
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("clearInput") || "清空"
                            width: 70
                            height: 32
                            onClicked: {
                                inputArea.text = ""
                                outputArea.text = ""
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
                }
                
                // 中间按钮区
                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 15
                    
                    Button {
                        text: "→"
                        width: 50
                        height: 50
                        font.pixelSize: 24
                        onClicked: doReplace()
                        
                        background: Rectangle {
                            color: parent.hovered ? "#006cbd" : "#0078d4"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 24
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        ToolTip.visible: hovered
                        ToolTip.text: replaceMode === 2 ? 
                            (I18n.t("clickToConvert") || "点击转换") :
                            (I18n.t("clickToReplace") || "点击替换")
                    }
                    
                    Text {
                        text: replaceMode === 2 ? 
                            (I18n.t("clickToConvert") || "点击转换") :
                            (I18n.t("clickToReplace") || "点击替换")
                        font.pixelSize: 11
                        color: "#888"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                
                // 右侧输出区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("outputResult") || "输出结果"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + outputArea.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#fafafa"
                        border.color: "#d0d0d0"
                        border.width: 1
                        radius: 6
                        
                        Flickable {
                            id: outputFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: outputArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: outputArea
                                readOnly: true
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                placeholderText: I18n.t("outputPlaceholder") || "处理结果将显示在这里..."
                                
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
                            id: copyBtn
                            text: I18n.t("copyResult") || "复制结果"
                            width: 90
                            height: 32
                            enabled: outputArea.length > 0
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
            
            // 底部统计信息
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#f0f0f0"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    
                    Text {
                        text: replaceMode === 2 ?
                            ((I18n.t("escapeType") || "转义类型") + ": " + escapeCombo.currentText) :
                            ((I18n.t("matchCount") || "匹配数量") + ": " + countMatches())
                        font.pixelSize: 13
                        color: "#666"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: (I18n.t("currentMode") || "当前模式") + ": " + 
                              (replaceMode === 0 ? (I18n.t("normalReplace") || "普通替换") :
                               replaceMode === 1 ? (I18n.t("regexReplace") || "正则替换") :
                                                  (I18n.t("escapeConvert") || "转义处理"))
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
            }
        }
    }
}
