import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: winEncryptWindow
    width: 800
    height: 675
    minimumWidth: 700
    minimumHeight: 450
    title: I18n.t("toolWinEncrypt")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 支持的哈希算法
    property var algorithms: ["MD5", "SHA1", "SHA256", "SHA384", "SHA512"]
    property string selectedAlgorithm: "MD5"
    
    // 文件路径
    property string filePath: ""
    
    // 当文件路径或算法改变时更新命令显示
    onFilePathChanged: {
        updateCommands()
    }
    
    function updateCommands() {
        powershellArea.text = generatePowerShellCommand()
        cmdArea.text = generateCmdCommand()
    }
    
    // 生成PowerShell命令
    function generatePowerShellCommand() {
        return "Get-FileHash \"" + filePath + "\" -Algorithm " + selectedAlgorithm + " | Format-List"
    }
    
    // 生成CMD命令
    function generateCmdCommand() {
        return "certutil -hashfile \"" + filePath + "\" " + selectedAlgorithm
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
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
            spacing: 20
            
            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Column {
                    spacing: 5
                    Text {
                        text: I18n.t("toolWinEncrypt")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolWinEncryptDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 算法选择区
                Column {
                    spacing: 5
                    
                    Text {
                        text: I18n.t("winEncryptAlgorithm") || "哈希算法"
                        font.pixelSize: 13
                        color: "#666"
                    }
                    
                    Row {
                        spacing: 8
                        
                        Repeater {
                            model: algorithms
                            
                            Rectangle {
                                width: 65
                                height: 28
                                color: selectedAlgorithm === modelData ? "#1976d2" : "white"
                                border.color: "#1976d2"
                                border.width: 1
                                radius: 4
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 12
                                    color: selectedAlgorithm === modelData ? "white" : "#1976d2"
                                    font.bold: selectedAlgorithm === modelData
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        selectedAlgorithm = modelData
                                        updateCommands()
                                    }
                                }
                            }
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
            
            // 文件路径输入区
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: I18n.t("winEncryptFilePath") || "文件路径"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    TextField {
                        id: filePathInput
                        Layout.fillWidth: true
                        placeholderText: I18n.t("winEncryptFilePlaceholder") || "请输入文件完整路径..."
                        text: filePath
                        onTextChanged: filePath = text
                        
                        background: Rectangle {
                            color: "white"
                            border.color: filePathInput.activeFocus ? "#1976d2" : "#e0e0e0"
                            border.width: filePathInput.activeFocus ? 2 : 1
                            radius: 4
                        }
                    }
                    
                    Button {
                        text: I18n.t("clearBtn")
                        onClicked: {
                            filePathInput.text = ""
                            filePath = ""
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "#1976d2"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                            border.color: "#1976d2"
                            border.width: 1
                            radius: 4
                            implicitWidth: 60
                            implicitHeight: 36
                        }
                    }
                }
            }
            
            
            
            // PowerShell命令区
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            width: 20
                            height: 20
                            color: "#0078d4"
                            radius: 3
                            
                            Text {
                                anchors.centerIn: parent
                                text: "PS"
                                font.pixelSize: 10
                                font.bold: true
                                color: "white"
                            }
                        }
                        
                        Text {
                            text: I18n.t("winEncryptPowerShell") || "PowerShell 命令"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("copyBtn")
                            onClicked: {
                                copyToClipboard(generatePowerShellCommand())
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                                implicitWidth: 80
                                implicitHeight: 32
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f8f9fa"
                        border.color: "#e9ecef"
                        border.width: 1
                        radius: 4
                        
                        ScrollView {
                        
                                                    anchors.fill: parent
                        
                                                    anchors.margins: 8
                        
                                                    clip: true
                        
                                                    
                        
                                                    TextArea {
                        
                                                    
                        
                                                                                    id: powershellArea
                        
                                                    
                        
                                                                                    text: generatePowerShellCommand()
                        
                                                    
                        
                                                                                    readOnly: true
                        
                                                    
                        
                                                                                    font.pixelSize: 13
                        
                                                    
                        
                                                                                    font.family: "Consolas, Monaco, monospace"
                        
                                                    
                        
                                                                                    color: "#495057"
                        
                                                    
                        
                                                                                    selectByMouse: true
                        
                                                    
                        
                                                                                    wrapMode: TextArea.Wrap
                        
                                                    
                        
                                                                                    background: null
                        
                                                    
                        
                                                                                }
                        
                                                }
                    }
                }
            }
            
            // CMD命令区
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Rectangle {
                            width: 20
                            height: 20
                            color: "#28a745"
                            radius: 3
                            
                            Text {
                                anchors.centerIn: parent
                                text: "CMD"
                                font.pixelSize: 10
                                font.bold: true
                                color: "white"
                            }
                        }
                        
                        Text {
                            text: I18n.t("winEncryptCmd") || "CMD 命令"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("copyBtn")
                            onClicked: {
                                copyToClipboard(generateCmdCommand())
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                color: parent.pressed ? "#1e7e34" : (parent.hovered ? "#218838" : "#28a745")
                                radius: 4
                                implicitWidth: 80
                                implicitHeight: 32
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f8f9fa"
                        border.color: "#e9ecef"
                        border.width: 1
                        radius: 4
                        
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 8
                            clip: true
                            
                            TextArea {
                                id: cmdArea
                                text: generateCmdCommand()
                                readOnly: true
                                font.pixelSize: 13
                                font.family: "Consolas, Monaco, monospace"
                                color: "#495057"
                                selectByMouse: true
                                wrapMode: TextArea.Wrap
                                background: null
                                
                                
                            }
                        }
                    }
                }
            }
            
            // 说明文字
            Text {
                Layout.fillWidth: true
                text: I18n.t("winEncryptTip") || "提示：PowerShell支持所有算法，CMD在某些Windows版本中可能不支持SHA384和SHA512"
                font.pixelSize: 11
                color: "#999"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }
    
    // 复制反馈提示
    Rectangle {
        id: copyFeedback
        anchors.centerIn: parent
        width: 120
        height: 50
        color: "#333333"
        radius: 6
        opacity: 0
        visible: opacity > 0
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess") || "已复制到剪贴板"
            font.pixelSize: 14
            color: "white"
        }
        
        function show() {
            opacity = 1
            feedbackTimer.start()
        }
        
        Timer {
            id: feedbackTimer
            interval: 1500
            onTriggered: copyFeedback.opacity = 0
        }
    }
}
