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

    TextArea { id: clipboardArea; visible: false }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 18

            Text { text: I18n.t("toolDocker") || "Docker工具"; font.pixelSize: 22; font.bold: true; color: "#333"; Layout.alignment: Qt.AlignHCenter }
            Text { text: I18n.t("toolDockerDesc") || "Docker命令速查与Compose转换"; font.pixelSize: 13; color: "#666"; Layout.alignment: Qt.AlignHCenter }

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

                ScrollView {
                    clip: true
                    ColumnLayout {
                        width: dockerWindow.width - 70
                        spacing: 14
                        Repeater {
                            model: commandGroups
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: modelData.rows.length * 46 + 50
                                color: "white"
                                border.color: "#e0e0e0"
                                radius: 6
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8
                                    Text { text: modelData.name; font.pixelSize: 15; font.bold: true; color: "#333" }
                                    Repeater {
                                        model: modelData.rows
                                        RowLayout {
                                            Layout.fillWidth: true
                                            Text { text: modelData[0]; Layout.preferredWidth: 120; font.pixelSize: 13; color: "#333" }
                                            Text { text: modelData[1]; Layout.fillWidth: true; font.pixelSize: 13; font.family: "Consolas, Monaco, monospace"; color: "#444"; elide: Text.ElideMiddle }
                                            Button {
                                                text: I18n.t("copyBtn") || "复制"
                                                Layout.preferredWidth: 64
                                                Layout.preferredHeight: 30
                                                onClicked: copyToClipboard(modelData[1])
                                                background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                                                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14
                        TextArea {
                            id: dockerInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "docker run -d --name web -p 8080:80 -v ./html:/usr/share/nginx/html nginx:latest"
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                            background: Rectangle { color: "#fbfbfb"; border.color: dockerInput.activeFocus ? "#0078d4" : "#edf0f2"; border.width: dockerInput.activeFocus ? 2 : 1; radius: 4 }
                        }
                        ColumnLayout {
                            Layout.preferredWidth: 150
                            Button {
                                text: "run -> compose"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                onClicked: dockerOutput.text = runToCompose(dockerInput.text)
                                background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            Button {
                                text: "compose -> run"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                onClicked: dockerOutput.text = composeToRun(dockerInput.text)
                                background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            Button {
                                text: I18n.t("copyBtn") || "复制"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                onClicked: copyToClipboard(dockerOutput.text)
                                background: Rectangle { color: parent.hovered ? "#f5f5f5" : "white"; border.color: "#d0d0d0"; border.width: 1; radius: 4 }
                                contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                            Item { Layout.fillHeight: true }
                        }
                        TextArea {
                            id: dockerOutput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            readOnly: true
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                            background: Rectangle { color: "#fbfbfb"; border.color: "#edf0f2"; border.width: 1; radius: 4 }
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
