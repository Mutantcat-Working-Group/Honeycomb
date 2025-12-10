import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: textDiffWindow
    width: 900
    height: 650
    minimumWidth: 750
    minimumHeight: 550
    title: I18n.t("toolTextDiff")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 差异结果
    property var diffResults: []
    property int totalLines: 0
    property int changedLines: 0
    property int addedLines: 0
    property int removedLines: 0
    
    // 比较两个文本
    function compareTexts() {
        var leftLines = leftInput.text.split("\n")
        var rightLines = rightInput.text.split("\n")
        
        diffResults = []
        changedLines = 0
        addedLines = 0
        removedLines = 0
        
        var maxLen = Math.max(leftLines.length, rightLines.length)
        totalLines = maxLen
        
        for (var i = 0; i < maxLen; i++) {
            var leftLine = i < leftLines.length ? leftLines[i] : ""
            var rightLine = i < rightLines.length ? rightLines[i] : ""
            
            var status = "equal"
            if (i >= leftLines.length) {
                status = "added"
                addedLines++
            } else if (i >= rightLines.length) {
                status = "removed"
                removedLines++
            } else if (leftLine !== rightLine) {
                status = "changed"
                changedLines++
            }
            
            if (status !== "equal") {
                diffResults.push({
                    lineNum: i + 1,
                    leftText: leftLine,
                    rightText: rightLine,
                    status: status
                })
            }
        }
        
        diffListView.model = diffResults
    }
    
    // 清空
    function clearAll() {
        leftInput.text = ""
        rightInput.text = ""
        diffResults = []
        diffListView.model = []
        totalLines = 0
        changedLines = 0
        addedLines = 0
        removedLines = 0
    }
    
    // 交换左右文本
    function swapTexts() {
        var temp = leftInput.text
        leftInput.text = rightInput.text
        rightInput.text = temp
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 顶部：左右输入区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 250
                spacing: 15
                
                // 左侧输入
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
                                text: I18n.t("diffLeftText") || "原始文本"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: leftInput.text.split("\n").length + " " + (I18n.t("lines") || "行")
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
                                id: leftFlickable
                                anchors.fill: parent
                                anchors.margins: 8
                                contentWidth: leftInput.contentWidth
                                contentHeight: leftInput.contentHeight
                                clip: true
                                
                                TextArea.flickable: TextArea {
                                    id: leftInput
                                    placeholderText: I18n.t("diffLeftPlaceholder") || "在此输入原始文本..."
                                    font.pixelSize: 13
                                    font.family: "Consolas, Microsoft YaHei"
                                    wrapMode: TextArea.NoWrap
                                    background: null
                                }
                                
                                ScrollBar.vertical: ScrollBar { }
                                ScrollBar.horizontal: ScrollBar { }
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
                        text: I18n.t("diffCompare") || "比较"
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: compareTexts()
                        
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
                        text: I18n.t("diffSwap") || "交换"
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: swapTexts()
                        
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
                
                // 右侧输入
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
                                text: I18n.t("diffRightText") || "对比文本"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                text: rightInput.text.split("\n").length + " " + (I18n.t("lines") || "行")
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
                                id: rightFlickable
                                anchors.fill: parent
                                anchors.margins: 8
                                contentWidth: rightInput.contentWidth
                                contentHeight: rightInput.contentHeight
                                clip: true
                                
                                TextArea.flickable: TextArea {
                                    id: rightInput
                                    placeholderText: I18n.t("diffRightPlaceholder") || "在此输入对比文本..."
                                    font.pixelSize: 13
                                    font.family: "Consolas, Microsoft YaHei"
                                    wrapMode: TextArea.NoWrap
                                    background: null
                                }
                                
                                ScrollBar.vertical: ScrollBar { }
                                ScrollBar.horizontal: ScrollBar { }
                            }
                        }
                    }
                }
            }
            
            // 统计信息栏
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 25
                    
                    Text {
                        text: (I18n.t("diffTotal") || "总行数") + ": " + totalLines
                        font.pixelSize: 13
                        color: "#333"
                    }
                    
                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 12
                            height: 12
                            color: "#fff3cd"
                            border.color: "#ffc107"
                            border.width: 1
                            radius: 2
                        }
                        Text {
                            text: (I18n.t("diffChanged") || "修改") + ": " + changedLines
                            font.pixelSize: 13
                            color: "#856404"
                        }
                    }
                    
                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 12
                            height: 12
                            color: "#d4edda"
                            border.color: "#28a745"
                            border.width: 1
                            radius: 2
                        }
                        Text {
                            text: (I18n.t("diffAdded") || "新增") + ": " + addedLines
                            font.pixelSize: 13
                            color: "#155724"
                        }
                    }
                    
                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 12
                            height: 12
                            color: "#f8d7da"
                            border.color: "#dc3545"
                            border.width: 1
                            radius: 2
                        }
                        Text {
                            text: (I18n.t("diffRemoved") || "删除") + ": " + removedLines
                            font.pixelSize: 13
                            color: "#721c24"
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: diffResults.length > 0 ? 
                              (I18n.t("diffFoundDiff") || "发现") + " " + diffResults.length + " " + (I18n.t("diffDiffLines") || "处差异") :
                              (totalLines > 0 ? (I18n.t("diffNoDiff") || "无差异") : "")
                        font.pixelSize: 13
                        color: diffResults.length > 0 ? "#e74c3c" : "#27ae60"
                        font.bold: true
                    }
                }
            }
            
            // 差异展示区
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    
                    Text {
                        text: I18n.t("diffDetails") || "差异详情"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    // 表头
                    Rectangle {
                        Layout.fillWidth: true
                        height: 32
                        color: "#f0f0f0"
                        radius: 4
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 0
                            
                            Text {
                                text: I18n.t("diffLineNum") || "行号"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#666"
                                Layout.preferredWidth: 50
                            }
                            
                            Text {
                                text: I18n.t("diffStatus") || "状态"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#666"
                                Layout.preferredWidth: 60
                            }
                            
                            Text {
                                text: I18n.t("diffLeftText") || "原始文本"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#666"
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: I18n.t("diffRightText") || "对比文本"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#666"
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    // 差异列表
                    ListView {
                        id: diffListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: []
                        
                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                        
                        delegate: Rectangle {
                            width: diffListView.width
                            height: 36
                            color: index % 2 === 0 ? "#fafafa" : "white"
                            
                            Rectangle {
                                anchors.fill: parent
                                color: modelData.status === "changed" ? "#fff3cd" :
                                       modelData.status === "added" ? "#d4edda" :
                                       modelData.status === "removed" ? "#f8d7da" : "transparent"
                                opacity: 0.5
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 0
                                
                                // 行号
                                Text {
                                    text: modelData.lineNum
                                    font.pixelSize: 12
                                    font.family: "Consolas"
                                    color: "#666"
                                    Layout.preferredWidth: 50
                                }
                                
                                // 状态标签
                                Rectangle {
                                    Layout.preferredWidth: 50
                                    Layout.preferredHeight: 20
                                    color: modelData.status === "changed" ? "#ffc107" :
                                           modelData.status === "added" ? "#28a745" :
                                           modelData.status === "removed" ? "#dc3545" : "#6c757d"
                                    radius: 3
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.status === "changed" ? (I18n.t("diffModified") || "修改") :
                                              modelData.status === "added" ? (I18n.t("diffNew") || "新增") :
                                              modelData.status === "removed" ? (I18n.t("diffDeleted") || "删除") : ""
                                        font.pixelSize: 10
                                        color: "white"
                                    }
                                }
                                
                                Item { width: 10 }
                                
                                // 左侧文本
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.margins: 2
                                    color: modelData.status === "removed" ? "#f8d7da" : 
                                           modelData.status === "changed" ? "#fff3cd" : "transparent"
                                    radius: 3
                                    clip: true
                                    
                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 5
                                        text: modelData.leftText || ""
                                        font.pixelSize: 12
                                        font.family: "Consolas, Microsoft YaHei"
                                        color: "#333"
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                // 右侧文本
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.margins: 2
                                    color: modelData.status === "added" ? "#d4edda" : 
                                           modelData.status === "changed" ? "#d4edda" : "transparent"
                                    radius: 3
                                    clip: true
                                    
                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 5
                                        text: modelData.rightText || ""
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
                            text: I18n.t("diffEmptyHint") || "点击「比较」按钮查看差异"
                            font.pixelSize: 14
                            color: "#999"
                            visible: diffResults.length === 0 && totalLines === 0
                        }
                    }
                }
            }
        }
    }
}
