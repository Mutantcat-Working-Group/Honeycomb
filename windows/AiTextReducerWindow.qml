import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: aiTextReducerWindow
    width: 1000
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    title: I18n.t("toolAiTextReducer")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 状态：0 = 输入阶段，1 = 对照编辑阶段
    property int currentStep: 0
    
    // 段落数据
    property var paragraphs: []
    
    // 解析原文为段落数组
    function parseText(text) {
        // 按换行符分割，过滤掉空行
        var lines = text.split(/\r?\n/)
        var result = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.length > 0) {
                result.push({
                    original: lines[i], // 保留原始格式（包括空格）
                    rewritten: ""
                })
            }
        }
        return result
    }
    
    // 统计字符数（不含空白）
    function countChars(text) {
        if (!text) return 0
        return text.replace(/\s/g, '').length
    }
    
    // 开始对照编辑
    function startComparison() {
        if (originalInput.text.trim().length === 0) {
            return
        }
        paragraphs = parseText(originalInput.text)
        if (paragraphs.length > 0) {
            currentStep = 1
            paragraphModel.clear()
            for (var i = 0; i < paragraphs.length; i++) {
                paragraphModel.append({
                    originalText: paragraphs[i].original,
                    rewrittenText: ""
                })
            }
        }
    }
    
    // 返回输入阶段
    function backToInput() {
        currentStep = 0
    }
    
    // 清空所有
    function clearAll() {
        originalInput.text = ""
        paragraphs = []
        paragraphModel.clear()
        currentStep = 0
    }
    
    // 复制所有重写后的文本
    function copyAllRewritten() {
        var result = []
        for (var i = 0; i < paragraphModel.count; i++) {
            var item = paragraphModel.get(i)
            if (item.rewrittenText && item.rewrittenText.trim().length > 0) {
                result.push(item.rewrittenText)
            } else {
                result.push(item.originalText) // 如果没有重写，使用原文
            }
        }
        clipboard.text = result.join("\n\n")
        copyNotification.visible = true
        notificationTimer.restart()
    }
    
    // 剪贴板
    Text {
        id: clipboard
        visible: false
    }
    
    // 复制成功提示
    Rectangle {
        id: copyNotification
        anchors.centerIn: parent
        width: 150
        height: 40
        color: "#333"
        radius: 8
        visible: false
        z: 100
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess") || "已复制到剪贴板"
            color: "white"
            font.pixelSize: 14
        }
        
        Timer {
            id: notificationTimer
            interval: 1500
            onTriggered: copyNotification.visible = false
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        // 阶段0：输入原文
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            visible: currentStep === 0
            
            // 标题说明
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    
                    Text {
                        text: I18n.t("aiReducerTitle") || "对照降AI"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333"
                    }
                    
                    Text {
                        text: I18n.t("aiReducerDesc") || "将AI生成的文本粘贴到下方，点击确定后进行对照重写"
                        font.pixelSize: 13
                        color: "#666"
                    }
                    
                    Item { Layout.fillWidth: true }
                }
            }
            
            // 输入区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("aiReducerOriginal") || "原文输入"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: countChars(originalInput.text) + " " + (I18n.t("chars") || "字符")
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
                            id: inputFlickable
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: originalInput.contentWidth
                            contentHeight: originalInput.contentHeight
                            clip: true
                            
                            TextArea.flickable: TextArea {
                                id: originalInput
                                placeholderText: I18n.t("aiReducerPlaceholder") || "请在此粘贴AI生成的文本，每段文字用空行分隔..."
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei, Consolas"
                                wrapMode: TextArea.Wrap
                                background: null
                                selectByMouse: true
                            }
                            
                            ScrollBar.vertical: ScrollBar { }
                            ScrollBar.horizontal: ScrollBar { }
                        }
                    }
                }
            }
            
            // 底部按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("clear") || "清空"
                    Layout.preferredWidth: 80
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
                
                Button {
                    text: I18n.t("aiReducerConfirm") || "确定"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    enabled: originalInput.text.trim().length > 0
                    onClicked: startComparison()
                    
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
        
        // 阶段1：对照编辑
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            visible: currentStep === 1
            
            // 顶部标题栏
            Rectangle {
                Layout.fillWidth: true
                height: 50
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    
                    Text {
                        text: I18n.t("aiReducerCompare") || "对照编辑"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333"
                    }
                    
                    Text {
                        text: (I18n.t("aiReducerParagraphs") || "共") + " " + paragraphModel.count + " " + (I18n.t("aiReducerParagraphUnit") || "段")
                        font.pixelSize: 13
                        color: "#666"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: I18n.t("aiReducerBack") || "返回修改"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 32
                        onClicked: backToInput()
                        
                        background: Rectangle {
                            color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                            border.color: "#ccc"
                            border.width: 1
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: I18n.t("aiReducerCopyResult") || "复制结果"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 32
                        onClicked: copyAllRewritten()
                        
                        background: Rectangle {
                            color: parent.hovered ? "#006cbd" : "#0078d4"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            
            // 对照编辑区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                // 表头
                Rectangle {
                    id: headerRow
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 0
                    height: 40
                    color: "#f8f8f8"
                    radius: 8
                    
                    // 遮盖底部圆角
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 10
                        color: "#f8f8f8"
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: parent.height
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("aiReducerOriginalCol") || "原文（AI生成）"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#555"
                            }
                        }
                        
                        Rectangle {
                            width: 1
                            height: parent.height - 10
                            color: "#e0e0e0"
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: parent.height
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("aiReducerRewrittenCol") || "重写（降低AI率）"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#555"
                            }
                        }
                    }
                }
                
                // 段落列表
                ListView {
                    id: paragraphListView
                    anchors.top: headerRow.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 0
                    clip: true
                    model: ListModel {
                        id: paragraphModel
                    }
                    spacing: 0
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                    }
                    
                    delegate: Rectangle {
                        id: delegateItem
                        width: paragraphListView.width
                        height: Math.max(120, Math.max(originalContent.implicitHeight, rewrittenContent.implicitHeight) + 50)
                        color: index % 2 === 0 ? "#fafafa" : "white"
                        
                        // 分隔线
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: "#e8e8e8"
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            // 左侧：原文
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "white"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 6
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4
                                    
                                    // 段落序号
                                    Text {
                                        text: "#" + (index + 1)
                                        font.pixelSize: 11
                                        color: "#0078d4"
                                        font.bold: true
                                    }
                                    
                                    // 原文内容
                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        
                                        TextArea {
                                            id: originalContent
                                            text: model.originalText
                                            font.pixelSize: 13
                                            font.family: "Microsoft YaHei, Consolas"
                                            wrapMode: TextArea.Wrap
                                            readOnly: true
                                            background: null
                                            color: "#333"
                                        }
                                    }
                                    
                                    // 字数统计
                                    Text {
                                        Layout.alignment: Qt.AlignRight
                                        text: countChars(model.originalText) + " " + (I18n.t("chars") || "字符")
                                        font.pixelSize: 11
                                        color: "#999"
                                    }
                                }
                            }
                            
                            // 中间分隔
                            Rectangle {
                                width: 1
                                Layout.fillHeight: true
                                color: "#e0e0e0"
                            }
                            
                            // 右侧：重写
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "white"
                                border.color: "#4caf50"
                                border.width: 2
                                radius: 6
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4
                                    
                                    // 段落序号
                                    RowLayout {
                                        spacing: 6
                                        
                                        Text {
                                            text: "#" + (index + 1)
                                            font.pixelSize: 11
                                            color: "#4caf50"
                                            font.bold: true
                                        }
                                        
                                        Rectangle {
                                            width: 8
                                            height: 8
                                            radius: 4
                                            color: model.rewrittenText && model.rewrittenText.trim().length > 0 ? "#4caf50" : "#ddd"
                                        }
                                        
                                        Text {
                                            text: model.rewrittenText && model.rewrittenText.trim().length > 0 ? (I18n.t("aiReducerEdited") || "已编辑") : (I18n.t("aiReducerPending") || "待编辑")
                                            font.pixelSize: 10
                                            color: model.rewrittenText && model.rewrittenText.trim().length > 0 ? "#4caf50" : "#999"
                                        }
                                    }
                                    
                                    // 重写内容
                                    ScrollView {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true
                                        
                                        TextArea {
                                            id: rewrittenContent
                                            placeholderText: I18n.t("aiReducerRewritePlaceholder") || "在此输入理解后的文本..."
                                            font.pixelSize: 13
                                            font.family: "Microsoft YaHei, Consolas"
                                            wrapMode: TextArea.Wrap
                                            background: null
                                            color: "#333"
                                            selectByMouse: true
                                            
                                            onTextChanged: {
                                                // 更新模型数据
                                                paragraphModel.setProperty(index, "rewrittenText", text)
                                            }
                                            
                                            Component.onCompleted: {
                                                text = Qt.binding(function() { return model.rewrittenText })
                                            }
                                        }
                                    }
                                    
                                    // 字数统计
                                    Text {
                                        Layout.alignment: Qt.AlignRight
                                        text: countChars(model.rewrittenText) + " " + (I18n.t("chars") || "字符")
                                        font.pixelSize: 11
                                        color: model.rewrittenText && model.rewrittenText.trim().length > 0 ? "#4caf50" : "#999"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
