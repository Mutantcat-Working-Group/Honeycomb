import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: goCrossWindow
    width: 1100
    height: 700
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolGoCross")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // Go交叉编译数据
    property var crossCompileData: {
        "Windows系统编译命令": [
            {os: "windows", arch: "amd64", command: "GOOS=windows GOARCH=amd64 go build"},
            {os: "windows", arch: "386", command: "GOOS=windows GOARCH=386 go build"},
            {os: "windows", arch: "arm64", command: "GOOS=windows GOARCH=arm64 go build"},
            {os: "windows", arch: "arm", command: "GOOS=windows GOARCH=arm go build"}
        ],
        "macOS系统编译命令": [
            {os: "darwin", arch: "amd64", command: "GOOS=darwin GOARCH=amd64 go build"},
            {os: "darwin", arch: "arm64", command: "GOOS=darwin GOARCH=arm64 go build"},
            {os: "darwin", arch: "386", command: "GOOS=darwin GOARCH=386 go build"}
        ],
        "Linux系统编译命令": [
            {os: "linux", arch: "amd64", command: "GOOS=linux GOARCH=amd64 go build"},
            {os: "linux", arch: "386", command: "GOOS=linux GOARCH=386 go build"},
            {os: "linux", arch: "arm64", command: "GOOS=linux GOARCH=arm64 go build"},
            {os: "linux", arch: "arm", command: "GOOS=linux GOARCH=arm go build"},
            {os: "linux", arch: "ppc64", command: "GOOS=linux GOARCH=ppc64 go build"},
            {os: "linux", arch: "ppc64le", command: "GOOS=linux GOARCH=ppc64le go build"},
            {os: "linux", arch: "mips", command: "GOOS=linux GOARCH=mips go build"},
            {os: "linux", arch: "mipsle", command: "GOOS=linux GOARCH=mipsle go build"},
            {os: "linux", arch: "mips64", command: "GOOS=linux GOARCH=mips64 go build"},
            {os: "linux", arch: "mips64le", command: "GOOS=linux GOARCH=mips64le go build"},
            {os: "linux", arch: "s390x", command: "GOOS=linux GOARCH=s390x go build"}
        ],
        "其他操作系统编译命令": [
            {os: "freebsd", arch: "amd64", command: "GOOS=freebsd GOARCH=amd64 go build"},
            {os: "freebsd", arch: "386", command: "GOOS=freebsd GOARCH=386 go build"},
            {os: "freebsd", arch: "arm64", command: "GOOS=freebsd GOARCH=arm64 go build"},
            {os: "openbsd", arch: "amd64", command: "GOOS=openbsd GOARCH=amd64 go build"},
            {os: "openbsd", arch: "386", command: "GOOS=openbsd GOARCH=386 go build"},
            {os: "openbsd", arch: "arm64", command: "GOOS=openbsd GOARCH=arm64 go build"},
            {os: "netbsd", arch: "amd64", command: "GOOS=netbsd GOARCH=amd64 go build"},
            {os: "netbsd", arch: "386", command: "GOOS=netbsd GOARCH=386 go build"},
            {os: "netbsd", arch: "arm64", command: "GOOS=netbsd GOARCH=arm64 go build"},
            {os: "dragonfly", arch: "amd64", command: "GOOS=dragonfly GOARCH=amd64 go build"},
            {os: "solaris", arch: "amd64", command: "GOOS=solaris GOARCH=amd64 go build"},
            {os: "android", arch: "arm64", command: "GOOS=android GOARCH=arm64 go build"},
            {os: "android", arch: "arm", command: "GOOS=android GOARCH=arm go build"},
            {os: "android", arch: "amd64", command: "GOOS=android GOARCH=amd64 go build"},
            {os: "android", arch: "386", command: "GOOS=android GOARCH=386 go build"},
            {os: "ios", arch: "arm64", command: "GOOS=ios GOARCH=arm64 go build"},
            {os: "js", arch: "wasm", command: "GOOS=js GOARCH=wasm go build"},
            {os: "plan9", arch: "amd64", command: "GOOS=plan9 GOARCH=amd64 go build"},
            {os: "plan9", arch: "386", command: "GOOS=plan9 GOARCH=386 go build"}
        ]
    }
    
    // 将Bash格式转换为Cmd格式
    function convertToCmd(bashCommand) {
        // 匹配 GOOS=xxx GOARCH=xxx go build 格式
        var match = bashCommand.match(/GOOS=(\w+)\s+GOARCH=(\w+)\s+(.+)/)
        if (match) {
            return "set GOOS=" + match[1] + "&&set GOARCH=" + match[2] + "&&" + match[3]
        }
        return bashCommand
    }
    
    // 将Bash格式转换为PowerShell格式
    function convertToPowerShell(bashCommand) {
        // 匹配 GOOS=xxx GOARCH=xxx go build 格式
        var match = bashCommand.match(/GOOS=(\w+)\s+GOARCH=(\w+)\s+(.+)/)
        if (match) {
            return '$env:GOOS="' + match[1] + '";$env:GOARCH="' + match[2] + '";' + match[3]
        }
        return bashCommand
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolGoCross")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolGoCrossDesc") || "跨平台编译参考"
                    font.pixelSize: 13
                    color: "#666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 内容区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: goCrossWindow.width - 50
                    spacing: 25
                    
                    // 遍历每个分类
                    Repeater {
                        id: categoryRepeater
                        model: Object.keys(crossCompileData)
                        
                        ColumnLayout {
                            id: categoryColumn
                            Layout.fillWidth: true
                            spacing: 12
                            
                            property string categoryName: modelData
                            
                            // 分类标题
                            Text {
                                text: categoryColumn.categoryName
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333"
                                Layout.leftMargin: 5
                            }
                            
                            // 表格容器
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: crossCompileData[categoryColumn.categoryName].length * 42 + 40
                                color: "white"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 6
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    spacing: 0
                                    
                                    // 表头
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#0078d4"
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 15
                                            anchors.rightMargin: 15
                                            spacing: 15
                                            
                                            Text {
                                                text: "GOOS"
                                                Layout.preferredWidth: 120
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: "GOARCH"
                                                Layout.preferredWidth: 120
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("compileCommand") || "编译命令"
                                                Layout.fillWidth: true
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("operation") || "操作"
                                                Layout.preferredWidth: 220
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                    
                                    // 表格内容
                                    Column {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        
                                        Repeater {
                                            model: crossCompileData[categoryColumn.categoryName]
                                            
                                            Rectangle {
                                                width: parent.width
                                                height: 42
                                                color: index % 2 === 0 ? "#ffffff" : "#f8f8f8"
                                                
                                                // 鼠标悬停效果
                                                Rectangle {
                                                    anchors.fill: parent
                                                    color: "#e8f4fd"
                                                    opacity: mouseArea.containsMouse ? 1 : 0
                                                    Behavior on opacity { NumberAnimation { duration: 100 } }
                                                }
                                                
                                                MouseArea {
                                                    id: mouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                }
                                                
                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 15
                                                    anchors.rightMargin: 15
                                                    spacing: 15
                                                    
                                                    // GOOS
                                                    Text {
                                                        text: modelData.os
                                                        Layout.preferredWidth: 120
                                                        font.pixelSize: 13
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#333"
                                                    }
                                                    
                                                    // GOARCH
                                                    Text {
                                                        text: modelData.arch
                                                        Layout.preferredWidth: 120
                                                        font.pixelSize: 13
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#333"
                                                    }
                                                    
                                                    // 编译命令
                                                    Text {
                                                        text: modelData.command
                                                        Layout.fillWidth: true
                                                        font.pixelSize: 12
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#666"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 操作按钮组
                                                    RowLayout {
                                                        Layout.preferredWidth: 220
                                                        Layout.preferredHeight: 30
                                                        spacing: 8
                                                        
                                                        // Cmd按钮
                                                        Button {
                                                            Layout.preferredWidth: 62
                                                            Layout.preferredHeight: 30
                                                            text: "Cmd"
                                                            onClicked: {
                                                                var cmdCommand = convertToCmd(modelData.command)
                                                                copyToClipboard(cmdCommand)
                                                            }
                                                            background: Rectangle {
                                                                color: parent.hovered ? "#005a9e" : "#0078d4"
                                                                radius: 5
                                                                border.color: parent.hovered ? "#004578" : "#006cbd"
                                                                border.width: 1
                                                                Behavior on color {
                                                                    ColorAnimation { duration: 150 }
                                                                }
                                                            }
                                                            contentItem: Text {
                                                                text: parent.text
                                                                font.pixelSize: 12
                                                                font.bold: true
                                                                color: "white"
                                                                horizontalAlignment: Text.AlignHCenter
                                                                verticalAlignment: Text.AlignVCenter
                                                            }
                                                        }
                                                        
                                                        // PowerShell按钮
                                                        Button {
                                                            Layout.preferredWidth: 80
                                                            Layout.preferredHeight: 30
                                                            text: "PowerShell"
                                                            onClicked: {
                                                                var psCommand = convertToPowerShell(modelData.command)
                                                                copyToClipboard(psCommand)
                                                            }
                                                            background: Rectangle {
                                                                color: parent.hovered ? "#005a9e" : "#0078d4"
                                                                radius: 5
                                                                border.color: parent.hovered ? "#004578" : "#006cbd"
                                                                border.width: 1
                                                                Behavior on color {
                                                                    ColorAnimation { duration: 150 }
                                                                }
                                                            }
                                                            contentItem: Text {
                                                                text: parent.text
                                                                font.pixelSize: 12
                                                                font.bold: true
                                                                color: "white"
                                                                horizontalAlignment: Text.AlignHCenter
                                                                verticalAlignment: Text.AlignVCenter
                                                            }
                                                        }
                                                        
                                                        // Bash按钮
                                                        Button {
                                                            Layout.preferredWidth: 62
                                                            Layout.preferredHeight: 30
                                                            text: "Bash"
                                                            onClicked: {
                                                                copyToClipboard(modelData.command)
                                                            }
                                                            background: Rectangle {
                                                                color: parent.hovered ? "#005a9e" : "#0078d4"
                                                                radius: 5
                                                                border.color: parent.hovered ? "#004578" : "#006cbd"
                                                                border.width: 1
                                                                Behavior on color {
                                                                    ColorAnimation { duration: 150 }
                                                                }
                                                            }
                                                            contentItem: Text {
                                                                text: parent.text
                                                                font.pixelSize: 12
                                                                font.bold: true
                                                                color: "white"
                                                                horizontalAlignment: Text.AlignHCenter
                                                                verticalAlignment: Text.AlignVCenter
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
                    }
                }
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
            text: I18n.t("copied") || "已复制"
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
    
    TextArea {
        id: clipboardArea
        visible: false
    }
}

