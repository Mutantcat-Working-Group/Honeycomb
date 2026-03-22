import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: trimCJKSpaceWindow
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 450
    title: I18n.t("toolTrimCJKSpace")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 去除模式
    property int trimMode: 0  // 0: 全部去除, 1: 中英空格, 2: 中数空格
    
    // 去除分隔空格函数
    function trimText() {
        var input = inputArea.text
        
        if (input.length === 0) {
            outputArea.text = ""
            return
        }
        
        var result = input
        
        switch(trimMode) {
            case 0: // 全部去除（中英 + 中数）
                result = result.replace(/([\u4e00-\u9fff])\s+([a-zA-Z])/g, "$1$2")
                result = result.replace(/([a-zA-Z])\s+([\u4e00-\u9fff])/g, "$1$2")
                result = result.replace(/([\u4e00-\u9fff])\s+([0-9])/g, "$1$2")
                result = result.replace(/([0-9])\s+([\u4e00-\u9fff])/g, "$1$2")
                break
            case 1: // 仅去除中英之间的空格
                result = result.replace(/([\u4e00-\u9fff])\s+([a-zA-Z])/g, "$1$2")
                result = result.replace(/([a-zA-Z])\s+([\u4e00-\u9fff])/g, "$1$2")
                break
            case 2: // 仅去除中数之间的空格
                result = result.replace(/([\u4e00-\u9fff])\s+([0-9])/g, "$1$2")
                result = result.replace(/([0-9])\s+([\u4e00-\u9fff])/g, "$1$2")
                break
        }
        
        outputArea.text = result
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
    
    // 统计分隔空格数量
    function countSeparatorSpaces(text) {
        var count = 0
        var m1 = text.match(/([\u4e00-\u9fff])\s+([a-zA-Z])/g)
        var m2 = text.match(/([a-zA-Z])\s+([\u4e00-\u9fff])/g)
        var m3 = text.match(/([\u4e00-\u9fff])\s+([0-9])/g)
        var m4 = text.match(/([0-9])\s+([\u4e00-\u9fff])/g)
        if (m1) count += m1.length
        if (m2) count += m2.length
        if (m3) count += m3.length
        if (m4) count += m4.length
        return count
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
                        text: I18n.t("toolTrimCJKSpace")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolTrimCJKSpaceDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 模式选择
                Row {
                    spacing: 10
                    
                    Button {
                        text: I18n.t("trimCJKAll") || "全部去除"
                        width: 90
                        height: 32
                        onClicked: trimMode = 0
                        background: Rectangle {
                            color: trimMode === 0 ? "#0078d4" : "#e0e0e0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: trimMode === 0 ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: I18n.t("trimCJKEnglish") || "中英空格"
                        width: 90
                        height: 32
                        onClicked: trimMode = 1
                        background: Rectangle {
                            color: trimMode === 1 ? "#0078d4" : "#e0e0e0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: trimMode === 1 ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: I18n.t("trimCJKDigit") || "中数空格"
                        width: 90
                        height: 32
                        onClicked: trimMode = 2
                        background: Rectangle {
                            color: trimMode === 2 ? "#0078d4" : "#e0e0e0"
                            radius: 4
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: trimMode === 2 ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
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
                        text: "\u2192"
                        width: 50
                        height: 50
                        font.pixelSize: 24
                        onClicked: trimText()
                        
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
                        ToolTip.text: I18n.t("clickToProcess") || "点击处理"
                    }
                    
                    Text {
                        text: I18n.t("clickToProcess") || "点击处理"
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
                        text: (I18n.t("trimCJKSpaceCount") || "分隔空格") + ": " + countSeparatorSpaces(inputArea.text)
                        font.pixelSize: 13
                        color: "#666"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: (I18n.t("currentMode") || "当前模式") + ": " + 
                              (trimMode === 0 ? (I18n.t("trimCJKAll") || "全部去除") :
                               trimMode === 1 ? (I18n.t("trimCJKEnglish") || "中英空格") :
                                               (I18n.t("trimCJKDigit") || "中数空格"))
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
            }
        }
    }
}
