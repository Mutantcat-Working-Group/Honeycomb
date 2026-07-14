import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: sqlWindow
    width: 980
    height: 680
    minimumWidth: 820
    minimumHeight: 560
    title: I18n.t("toolSqlFormat") || "SQL格式化"
    flags: Qt.Window
    modality: Qt.NonModal

    function formatSql(sql) {
        var text = sql.replace(/\s+/g, " ").trim()
        var out = text
        var breaks = ["SELECT", "FROM", "WHERE", "LEFT JOIN", "RIGHT JOIN", "INNER JOIN", "JOIN", "GROUP BY", "ORDER BY", "HAVING", "LIMIT", "UNION", "VALUES", "SET"]
        for (var i = 0; i < breaks.length; i++) {
            var kw = breaks[i]
            out = out.replace(new RegExp("\\s+" + kw.replace(" ", "\\s+") + "\\b", "ig"), "\n" + kw)
        }
        out = out.replace(/\s*,\s*/g, ",\n    ")
        out = out.replace(/\(\s*/g, "(\n    ").replace(/\s*\)/g, "\n)")
        return out.trim()
    }

    function compressSql(sql) {
        return sql.replace(/--.*$/gm, "").replace(/\/\*[\s\S]*?\*\//g, "").replace(/\s+/g, " ").replace(/\s*([(),=<>+*/-])\s*/g, "$1").trim()
    }

    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
    }

    TextArea { id: clipboardArea; visible: false }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Column {
                Layout.fillWidth: true
                spacing: 5
                Text { text: I18n.t("toolSqlFormat") || "SQL格式化"; font.pixelSize: 22; font.bold: true; color: "#333" }
                Text { text: I18n.t("toolSqlFormatDesc") || "SQL格式化与压缩"; font.pixelSize: 13; color: "#666" }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#e0e0e0" }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "支持常见 SELECT / JOIN / WHERE / GROUP BY / ORDER BY 断行，也可压缩为单行"
                        font.pixelSize: 12
                        color: "#888"
                        wrapMode: Text.WordWrap
                    }

                    Button {
                        text: I18n.t("formatBtn") || "格式化"
                        Layout.preferredWidth: 86
                        Layout.preferredHeight: 34
                        onClicked: output.text = formatSql(input.text)
                        background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                        contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: I18n.t("compressBtn") || "压缩"
                        Layout.preferredWidth: 78
                        Layout.preferredHeight: 34
                        onClicked: output.text = compressSql(input.text)
                        background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                        contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: I18n.t("copyBtn") || "复制"
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 34
                        onClicked: copyToClipboard(output.text)
                        background: Rectangle { color: parent.hovered ? "#f5f5f5" : "white"; border.color: "#d0d0d0"; border.width: 1; radius: 4 }
                        contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                    Button {
                        text: I18n.t("clearBtn") || "清空"
                        Layout.preferredWidth: 72
                        Layout.preferredHeight: 34
                        onClicked: {
                            input.text = ""
                            output.text = ""
                        }
                        background: Rectangle { color: parent.hovered ? "#f5f5f5" : "white"; border.color: "#d0d0d0"; border.width: 1; radius: 4 }
                        contentItem: Text { text: parent.text; color: "#333"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10
                        Text { text: "输入 SQL"; font.pixelSize: 14; font.bold: true; color: "#333" }
                        TextArea {
                            id: input
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "select id,name from users where status=1 order by id desc limit 10"
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 13
                            font.family: "Consolas, Monaco, Microsoft YaHei, monospace"
                            background: Rectangle { color: "#fbfbfb"; border.color: input.activeFocus ? "#0078d4" : "#edf0f2"; border.width: input.activeFocus ? 2 : 1; radius: 4 }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10
                        Text { text: "输出结果"; font.pixelSize: 14; font.bold: true; color: "#333" }
                        TextArea {
                            id: output
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            readOnly: true
                            selectByMouse: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 13
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
