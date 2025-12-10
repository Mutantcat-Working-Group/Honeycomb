import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: regexWindow
    width: 850
    height: 600
    minimumWidth: 700
    minimumHeight: 500
    title: I18n.t("toolRegex")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 匹配结果
    property var matchResults: []
    property int matchCount: 0
    property bool hasError: false
    property string errorMsg: ""
    
    // 正则选项
    property bool flagGlobal: true
    property bool flagIgnoreCase: false
    property bool flagMultiline: false
    
    // 执行正则匹配
    function executeRegex() {
        hasError = false
        errorMsg = ""
        matchResults = []
        matchCount = 0
        
        var pattern = regexInput.text
        if (pattern.length === 0) {
            return
        }
        
        var flags = ""
        if (flagGlobal) flags += "g"
        if (flagIgnoreCase) flags += "i"
        if (flagMultiline) flags += "m"
        
        try {
            var regex = new RegExp(pattern, flags)
            var text = testInput.text
            var match
            var results = []
            
            if (flagGlobal) {
                while ((match = regex.exec(text)) !== null) {
                    results.push({
                        index: match.index,
                        length: match[0].length,
                        value: match[0],
                        groups: match.slice(1)
                    })
                    // 防止无限循环
                    if (match[0].length === 0) {
                        regex.lastIndex++
                    }
                }
            } else {
                match = regex.exec(text)
                if (match) {
                    results.push({
                        index: match.index,
                        length: match[0].length,
                        value: match[0],
                        groups: match.slice(1)
                    })
                }
            }
            
            matchResults = results
            matchCount = results.length
            matchListView.model = results
            
        } catch (e) {
            hasError = true
            errorMsg = e.message
            matchListView.model = []
        }
    }
    
    // 清空
    function clearAll() {
        regexInput.text = ""
        testInput.text = ""
        matchResults = []
        matchCount = 0
        hasError = false
        errorMsg = ""
        matchListView.model = []
    }
    
    // 常用正则表达式
    property var commonPatterns: [
        { name: I18n.t("regexEmail") || "邮箱", pattern: "[\\w.-]+@[\\w.-]+\\.\\w+" },
        { name: I18n.t("regexPhone") || "手机号", pattern: "1[3-9]\\d{9}" },
        { name: I18n.t("regexUrl") || "URL", pattern: "https?://[\\w.-]+(?:/[\\w./-]*)?" },
        { name: I18n.t("regexIp") || "IP地址", pattern: "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}" },
        { name: I18n.t("regexDate") || "日期", pattern: "\\d{4}-\\d{2}-\\d{2}" },
        { name: I18n.t("regexChinese") || "中文", pattern: "[\\u4e00-\\u9fa5]+" },
        { name: I18n.t("regexNumber") || "数字", pattern: "-?\\d+\\.?\\d*" },
        { name: I18n.t("regexIdCard") || "身份证", pattern: "\\d{17}[\\dXx]" }
    ]
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 顶部：正则表达式输入
            Rectangle {
                Layout.fillWidth: true
                height: 130
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("regexPattern") || "正则表达式"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // 常用正则下拉
                        ComboBox {
                            id: commonCombo
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 28
                            model: commonPatterns.map(function(p) { return p.name })
                            displayText: I18n.t("regexCommon") || "常用正则"
                            
                            onActivated: function(index) {
                                regexInput.text = commonPatterns[index].pattern
                                executeRegex()
                            }
                            
                            background: Rectangle {
                                color: "white"
                                border.color: "#d0d0d0"
                                border.width: 1
                                radius: 4
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        TextField {
                            id: regexInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            placeholderText: I18n.t("regexInputPlaceholder") || "输入正则表达式..."
                            font.pixelSize: 14
                            font.family: "Consolas, Microsoft YaHei"
                            
                            onTextChanged: executeRegex()
                            
                            background: Rectangle {
                                color: hasError ? "#fff5f5" : "#f8f8f8"
                                border.color: hasError ? "#e74c3c" : (regexInput.focus ? "#0078d4" : "#d0d0d0")
                                border.width: regexInput.focus ? 2 : 1
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: I18n.t("regexTest") || "测试"
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 36
                            onClicked: executeRegex()
                            
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
                    }
                    
                    // 正则选项
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        CheckBox {
                            id: globalCheck
                            text: "g - " + (I18n.t("regexGlobal") || "全局匹配")
                            checked: flagGlobal
                            leftPadding: 0
                            onCheckedChanged: {
                                flagGlobal = checked
                                executeRegex()
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 16
                                implicitHeight: 16
                                x: 0
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: globalCheck.checked ? "#0078d4" : "#d0d0d0"
                                color: globalCheck.checked ? "#0078d4" : "white"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: "white"
                                    font.pixelSize: 10
                                    visible: globalCheck.checked
                                }
                            }
                            
                            contentItem: Text {
                                text: globalCheck.text
                                font.pixelSize: 11
                                color: "#666"
                                leftPadding: 20
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        CheckBox {
                            id: ignoreCaseCheck
                            text: "i - " + (I18n.t("regexIgnoreCase") || "忽略大小写")
                            checked: flagIgnoreCase
                            leftPadding: 0
                            onCheckedChanged: {
                                flagIgnoreCase = checked
                                executeRegex()
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 16
                                implicitHeight: 16
                                x: 0
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: ignoreCaseCheck.checked ? "#0078d4" : "#d0d0d0"
                                color: ignoreCaseCheck.checked ? "#0078d4" : "white"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: "white"
                                    font.pixelSize: 10
                                    visible: ignoreCaseCheck.checked
                                }
                            }
                            
                            contentItem: Text {
                                text: ignoreCaseCheck.text
                                font.pixelSize: 11
                                color: "#666"
                                leftPadding: 20
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        CheckBox {
                            id: multilineCheck
                            text: "m - " + (I18n.t("regexMultiline") || "多行模式")
                            checked: flagMultiline
                            leftPadding: 0
                            onCheckedChanged: {
                                flagMultiline = checked
                                executeRegex()
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 16
                                implicitHeight: 16
                                x: 0
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: multilineCheck.checked ? "#0078d4" : "#d0d0d0"
                                color: multilineCheck.checked ? "#0078d4" : "white"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    color: "white"
                                    font.pixelSize: 10
                                    visible: multilineCheck.checked
                                }
                            }
                            
                            contentItem: Text {
                                text: multilineCheck.text
                                font.pixelSize: 11
                                color: "#666"
                                leftPadding: 20
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // 错误提示
                        Text {
                            text: hasError ? errorMsg : ""
                            font.pixelSize: 11
                            color: "#e74c3c"
                            visible: hasError
                            Layout.maximumWidth: 200
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            
            // 中部：左右布局
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                // 左侧：测试文本
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
                                text: I18n.t("regexTestText") || "测试文本"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: testInput.text.length + " " + (I18n.t("chars") || "字符")
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
                            
                            Flickable {
                                id: testFlickable
                                anchors.fill: parent
                                anchors.margins: 8
                                contentWidth: testInput.contentWidth
                                contentHeight: testInput.contentHeight
                                clip: true
                                
                                TextArea.flickable: TextArea {
                                    id: testInput
                                    placeholderText: I18n.t("regexTestPlaceholder") || "在此输入要测试的文本..."
                                    font.pixelSize: 13
                                    font.family: "Consolas, Microsoft YaHei"
                                    wrapMode: TextArea.Wrap
                                    background: null
                                    
                                    onTextChanged: executeRegex()
                                }
                                
                                ScrollBar.vertical: ScrollBar { }
                                ScrollBar.horizontal: ScrollBar { }
                            }
                        }
                    }
                }
                
                // 右侧：匹配结果
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
                                text: I18n.t("regexResults") || "匹配结果"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Rectangle {
                                width: 60
                                height: 22
                                color: matchCount > 0 ? "#d4edda" : "#f8f8f8"
                                border.color: matchCount > 0 ? "#28a745" : "#d0d0d0"
                                border.width: 1
                                radius: 11
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: matchCount + " " + (I18n.t("regexMatches") || "匹配")
                                    font.pixelSize: 11
                                    color: matchCount > 0 ? "#155724" : "#666"
                                }
                            }
                        }
                        
                        // 表头
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: "#f0f0f0"
                            radius: 4
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 0
                                
                                Text {
                                    text: "#"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#666"
                                    Layout.preferredWidth: 35
                                }
                                
                                Text {
                                    text: I18n.t("regexPosition") || "位置"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#666"
                                    Layout.preferredWidth: 60
                                }
                                
                                Text {
                                    text: I18n.t("regexMatchValue") || "匹配内容"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#666"
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        
                        // 结果列表
                        ListView {
                            id: matchListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: []
                            
                            ScrollBar.vertical: ScrollBar {
                                active: true
                            }
                            
                            delegate: Rectangle {
                                width: matchListView.width
                                height: 36
                                color: index % 2 === 0 ? "#fafafa" : "white"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 0
                                    
                                    // 序号
                                    Text {
                                        text: index + 1
                                        font.pixelSize: 12
                                        font.family: "Consolas"
                                        color: "#666"
                                        Layout.preferredWidth: 35
                                    }
                                    
                                    // 位置
                                    Text {
                                        text: modelData.index
                                        font.pixelSize: 12
                                        font.family: "Consolas"
                                        color: "#0078d4"
                                        Layout.preferredWidth: 60
                                    }
                                    
                                    // 匹配内容
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.margins: 3
                                        color: "#fff3cd"
                                        border.color: "#ffc107"
                                        border.width: 1
                                        radius: 3
                                        clip: true
                                        
                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 6
                                            anchors.rightMargin: 6
                                            text: modelData.value
                                            font.pixelSize: 12
                                            font.family: "Consolas, Microsoft YaHei"
                                            color: "#333"
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                                
                                // 底部分隔线
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: "#e8e8e8"
                                }
                            }
                            
                            // 空状态提示
                            Text {
                                anchors.centerIn: parent
                                text: regexInput.text.length === 0 ? 
                                      (I18n.t("regexEmptyHint") || "输入正则表达式开始测试") :
                                      (matchCount === 0 && !hasError ? (I18n.t("regexNoMatch") || "无匹配结果") : "")
                                font.pixelSize: 14
                                color: "#999"
                                visible: matchCount === 0 && !hasError
                            }
                        }
                    }
                }
            }
            
            // 底部提示
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "#f0f7ff"
                border.color: "#d0e4f7"
                border.width: 1
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 30
                    
                    Text {
                        text: "\\d - " + (I18n.t("regexDigit") || "数字")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    Text {
                        text: "\\w - " + (I18n.t("regexWord") || "字母数字")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    Text {
                        text: "\\s - " + (I18n.t("regexSpace") || "空白")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    Text {
                        text: ". - " + (I18n.t("regexAny") || "任意字符")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    Text {
                        text: "* - " + (I18n.t("regexZeroMore") || "0或多次")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    Text {
                        text: "+ - " + (I18n.t("regexOneMore") || "1或多次")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    Text {
                        text: "? - " + (I18n.t("regexZeroOne") || "0或1次")
                        font.pixelSize: 11
                        color: "#666"
                    }
                    
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}
