import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: sqlWindow
    width: 920
    height: 680
    minimumWidth: 760
    minimumHeight: 560
    title: I18n.t("toolSqlFormat") || "SQL格式化"
    flags: Qt.Window
    modality: Qt.NonModal

    property var keywords: ["SELECT","FROM","WHERE","JOIN","LEFT JOIN","RIGHT JOIN","INNER JOIN","OUTER JOIN","GROUP BY","ORDER BY","HAVING","LIMIT","VALUES","SET","AND","OR","UNION","INSERT","UPDATE","DELETE","CREATE","ALTER","DROP"]

    function formatSql(sql) {
        var text = sql.replace(/\s+/g, " ").trim()
        var upper = text.toUpperCase()
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
            anchors.margins: 25
            spacing: 18
            Text { text: I18n.t("toolSqlFormat") || "SQL格式化"; font.pixelSize: 22; font.bold: true; color: "#333"; Layout.alignment: Qt.AlignHCenter }
            Text { text: I18n.t("toolSqlFormatDesc") || "SQL格式化与压缩"; font.pixelSize: 13; color: "#666"; Layout.alignment: Qt.AlignHCenter }
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14
                TextArea {
                    id: input
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "select id,name from users where status=1 order by id desc limit 10"
                    selectByMouse: true
                    wrapMode: TextArea.Wrap
                    font.family: "Consolas, Monaco, monospace"
                }
                ColumnLayout {
                    Layout.preferredWidth: 120
                    Button { text: I18n.t("formatBtn") || "格式化"; Layout.fillWidth: true; onClicked: output.text = formatSql(input.text) }
                    Button { text: I18n.t("compressBtn") || "压缩"; Layout.fillWidth: true; onClicked: output.text = compressSql(input.text) }
                    Button { text: I18n.t("copyBtn") || "复制"; Layout.fillWidth: true; onClicked: copyToClipboard(output.text) }
                    Button { text: I18n.t("clearBtn") || "清空"; Layout.fillWidth: true; onClicked: { input.text = ""; output.text = "" } }
                    Item { Layout.fillHeight: true }
                }
                TextArea {
                    id: output
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextArea.Wrap
                    font.family: "Consolas, Monaco, monospace"
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
