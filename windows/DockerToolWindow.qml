import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: dockerWindow
    width: 980
    height: 720
    minimumWidth: 820
    minimumHeight: 600
    title: I18n.t("toolDocker") || "Docker工具"
    flags: Qt.Window
    modality: Qt.NonModal

    property var commandGroups: [
        { name: "容器", rows: [
            ["查看容器", "docker ps -a"],
            ["启动容器", "docker start <container>"],
            ["停止容器", "docker stop <container>"],
            ["进入容器", "docker exec -it <container> /bin/sh"],
            ["查看日志", "docker logs -f --tail=200 <container>"]
        ]},
        { name: "镜像", rows: [
            ["查看镜像", "docker images"],
            ["拉取镜像", "docker pull nginx:latest"],
            ["构建镜像", "docker build -t my-app:latest ."],
            ["删除镜像", "docker rmi <image>"],
            ["清理悬空镜像", "docker image prune"]
        ]},
        { name: "网络/卷/Compose", rows: [
            ["查看网络", "docker network ls"],
            ["创建网络", "docker network create app-net"],
            ["查看卷", "docker volume ls"],
            ["启动 Compose", "docker compose up -d"],
            ["停止 Compose", "docker compose down"]
        ]}
    ]

    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
    }

    function runToCompose(command) {
        var cmd = command.replace(/\\\n/g, " ").replace(/\s+/g, " ").trim()
        if (cmd.indexOf("docker run") !== 0) {
            return "# 请输入 docker run 命令"
        }
        var name = "app"
        var image = ""
        var ports = []
        var volumes = []
        var envs = []
        var rest = cmd.replace(/^docker\s+run\s+/, "")
        var parts = rest.match(/(?:[^\s"']+|"[^"]*"|'[^']*')+/g) || []
        for (var i = 0; i < parts.length; i++) {
            var part = parts[i].replace(/^['"]|['"]$/g, "")
            if (part === "-d" || part === "--rm") continue
            if (part === "--name" && i + 1 < parts.length) { name = parts[++i].replace(/^['"]|['"]$/g, ""); continue }
            if ((part === "-p" || part === "--publish") && i + 1 < parts.length) { ports.push(parts[++i].replace(/^['"]|['"]$/g, "")); continue }
            if ((part === "-v" || part === "--volume") && i + 1 < parts.length) { volumes.push(parts[++i].replace(/^['"]|['"]$/g, "")); continue }
            if ((part === "-e" || part === "--env") && i + 1 < parts.length) { envs.push(parts[++i].replace(/^['"]|['"]$/g, "")); continue }
            if (part.indexOf("-p=") === 0 || part.indexOf("--publish=") === 0) { ports.push(part.split("=").slice(1).join("=")); continue }
            if (part.indexOf("-v=") === 0 || part.indexOf("--volume=") === 0) { volumes.push(part.split("=").slice(1).join("=")); continue }
            if (part.indexOf("-e=") === 0 || part.indexOf("--env=") === 0) { envs.push(part.split("=").slice(1).join("=")); continue }
            if (part[0] !== "-" && image === "") image = part
        }
        if (image === "") image = "image:latest"
        var out = "services:\n  " + name + ":\n    image: " + image + "\n"
        if (ports.length > 0) {
            out += "    ports:\n"
            for (i = 0; i < ports.length; i++) out += "      - \"" + ports[i] + "\"\n"
        }
        if (volumes.length > 0) {
            out += "    volumes:\n"
            for (i = 0; i < volumes.length; i++) out += "      - \"" + volumes[i] + "\"\n"
        }
        if (envs.length > 0) {
            out += "    environment:\n"
            for (i = 0; i < envs.length; i++) out += "      - " + envs[i] + "\n"
        }
        out += "    restart: unless-stopped"
        return out
    }

    function composeToRun(compose) {
        var imageMatch = compose.match(/image:\s*([^\n]+)/)
        var nameMatch = compose.match(/services:\s*\n\s*([A-Za-z0-9_.-]+):/)
        var image = imageMatch ? imageMatch[1].trim() : "image:latest"
        var name = nameMatch ? nameMatch[1].trim() : "app"
        var lines = compose.split(/\r?\n/)
        var args = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line.indexOf("- \"") === 0 || line.indexOf("- '") === 0 || line.indexOf("- ") === 0) {
                var value = line.replace(/^-\s*/, "").replace(/^['"]|['"]$/g, "")
                if (value.indexOf(":") !== -1 && value.indexOf("=") === -1) args.push("-p " + value)
                if (value.indexOf("=") !== -1) args.push("-e " + value)
            }
        }
        return "docker run -d --name " + name + " " + args.join(" ") + " " + image
    }

    // 共享样式:复制按钮(扁平 + 蓝色)
    component CopyButton: Button {
        property string copyText: ""
        Layout.preferredHeight: 32
        Layout.preferredWidth: 72
        background: Rectangle {
            color: parent.pressed ? "#006cbd" : (parent.hovered ? "#1e88e5" : "#1976d2")
            radius: 4
        }
        contentItem: Text {
            text: parent.text
            color: "white"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    TextArea { id: clipboardArea; visible: false }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            Text {
                text: I18n.t("toolDocker") || "Docker工具"
                font.pixelSize: 22
                font.bold: true
                color: "#1a1a1a"
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: I18n.t("toolDockerDesc") || "Docker命令速查与Compose转换"
                font.pixelSize: 13
                color: "#777"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#e8e8e8" }

            TabBar {
                id: tabs
                Layout.fillWidth: true
                TabButton { text: I18n.t("toolDockerCheatsheet") || "命令速查" }
                TabButton { text: I18n.t("toolDockerCompose") || "Compose转换" }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: tabs.currentIndex

                // === Tab 1: 命令速查 ===
                // 用 ListView 替代 ScrollView+Repeater+ColumnLayout 嵌套,彻底避免 layout 塌缩
                ListView {
                    id: cheatsheetList
                    clip: true
                    spacing: 14
                    model: commandGroups
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Rectangle {
                        id: groupCard
                        width: cheatsheetList.width
                        // 高度由内部 ColumnLayout 通过 implicitHeight 自动算出
                        implicitHeight: groupColumn.implicitHeight + 28  // 14x2 padding
                        height: implicitHeight
                        color: "white"
                        border.color: "#e8e8e8"
                        border.width: 1
                        radius: 8

                        property var groupData: modelData

                        Column {
                            id: groupColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 14
                            spacing: 8

                            // 标题
                            Text {
                                width: parent.width
                                text: groupCard.groupData.name
                                font.pixelSize: 15
                                font.bold: true
                                color: "#1a1a1a"
                                height: 22
                                verticalAlignment: Text.AlignVCenter
                            }

                            // 命令行 Repeater(用 Item 子元素,不用 RowLayout)
                            Repeater {
                                model: groupCard.groupData.rows
                                Item {
                                    width: groupColumn.width
                                    height: 32

                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.leftMargin: 0
                                        anchors.rightMargin: 0
                                        color: index % 2 === 0 ? "transparent" : "#fafbfc"
                                        radius: 4
                                    }

                                    Text {
                                        id: nameLabel
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 120
                                        text: modelData[0]
                                        font.pixelSize: 13
                                        color: "#37474f"
                                    }

                                    Text {
                                        id: cmdLabel
                                        anchors.left: nameLabel.right
                                        anchors.leftMargin: 12
                                        anchors.right: copyBtn.left
                                        anchors.rightMargin: 12
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData[1]
                                        font.pixelSize: 13
                                        font.family: "Consolas, Monaco, monospace"
                                        color: "#455a64"
                                        elide: Text.ElideMiddle
                                    }

                                    Button {
                                        id: copyBtn
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: I18n.t("copyBtn") || "复制"
                                        width: 72
                                        height: 30
                                        onClicked: copyToClipboard(modelData[1])
                                        background: Rectangle {
                                            color: copyBtn.pressed ? "#006cbd"
                                                 : (copyBtn.hovered ? "#1e88e5" : "#1976d2")
                                            radius: 4
                                        }
                                        contentItem: Text {
                                            text: copyBtn.text
                                            color: "white"
                                            font.pixelSize: 12
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // === Tab 2: Compose 转换(上下三段布局) ===
                Rectangle {
                    color: "white"
                    border.color: "#e8e8e8"
                    border.width: 1
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        // 输入区
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "输入"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#546e7a"
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: dockerInput.text.length + " 字符"
                                    font.pixelSize: 11
                                    color: "#90a4ae"
                                    font.family: "Consolas, Monaco, monospace"
                                }
                            }

                            TextArea {
                                id: dockerInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                placeholderText: "docker run -d --name web -p 8080:80 -v ./html:/usr/share/nginx/html nginx:latest"
                                selectByMouse: true
                                wrapMode: TextArea.Wrap
                                font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                                font.pixelSize: 13
                                background: Rectangle {
                                    color: "#fbfbfb"
                                    border.color: dockerInput.activeFocus ? "#1976d2" : "#e8e8e8"
                                    border.width: dockerInput.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                        }

                        // 中间一排:转换按钮组(水平居中)
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 12

                            Button {
                                text: "run → compose"
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 34
                                onClicked: dockerOutput.text = runToCompose(dockerInput.text)
                                background: Rectangle {
                                    color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 13
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Button {
                                text: "compose → run"
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 34
                                onClicked: dockerOutput.text = composeToRun(dockerInput.text)
                                background: Rectangle {
                                    color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 13
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Button {
                                text: I18n.t("copyBtn") || "复制结果"
                                Layout.preferredWidth: 110
                                Layout.preferredHeight: 34
                                enabled: dockerOutput.text.length > 0
                                onClicked: copyToClipboard(dockerOutput.text)
                                background: Rectangle {
                                    color: parent.enabled
                                         ? (parent.pressed ? "#006cbd" : (parent.hovered ? "#1e88e5" : "#1976d2"))
                                         : "#cfd8dc"
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.parent.enabled ? "white" : "#999"
                                    font.pixelSize: 13
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // 输出区
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "输出"
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: "#546e7a"
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: dockerOutput.text.length + " 字符"
                                    font.pixelSize: 11
                                    color: "#90a4ae"
                                    font.family: "Consolas, Monaco, monospace"
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#263238"
                                radius: 4

                                ScrollView {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    clip: true
                                    ScrollBar.vertical.policy: ScrollBar.AsNeeded
                                    ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                                    TextArea {
                                        id: dockerOutput
                                        Layout.fillWidth: true
                                        readOnly: true
                                        selectByMouse: true
                                        wrapMode: TextArea.Wrap
                                        color: "#eceff1"
                                        font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                                        font.pixelSize: 13
                                        background: null
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: copyFeedback
        width: 150; height: 36; radius: 18; color: "#333"; opacity: 0
        anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 25
        Text { anchors.centerIn: parent; text: I18n.t("copySuccess") || "已复制到剪贴板"; color: "white"; font.pixelSize: 12 }
        function show() { opacity = 0.9; feedbackTimer.restart() }
        Timer { id: feedbackTimer; interval: 1500; onTriggered: copyFeedback.opacity = 0 }
    }
}
