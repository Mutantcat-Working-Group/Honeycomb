import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: cronParserWindow
    width: 820
    height: 620
    minimumWidth: 720
    minimumHeight: 520
    title: I18n.t("toolCronParser") || "Cron表达式解析"
    flags: Qt.Window
    modality: Qt.NonModal

    property var monthNames: ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    property var weekNames: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    property var cronPresets: [
        { label: "每5分钟 工作时间", value: "*/5 9-18 * * MON-FRI" },
        { label: "每小时", value: "@hourly" },
        { label: "每天 00:00", value: "@daily" },
        { label: "每周一 00:00", value: "0 0 * * MON" },
        { label: "每月1日 00:00", value: "@monthly" },
        { label: "每年1月1日", value: "@yearly" }
    ]
    property var runCounts: [10, 20, 50]

    function expandMacro(expression) {
        var macro = expression.trim().toLowerCase()
        if (macro === "@hourly") return "0 * * * *"
        if (macro === "@daily" || macro === "@midnight") return "0 0 * * *"
        if (macro === "@weekly") return "0 0 * * 0"
        if (macro === "@monthly") return "0 0 1 * *"
        if (macro === "@yearly" || macro === "@annually") return "0 0 1 1 *"
        return expression
    }

    function parseField(text, min, max, aliases) {
        var values = {}
        var parts = text.trim().toUpperCase().split(",")
        if (parts.length === 0 || text.trim() === "") {
            throw "字段不能为空"
        }

        for (var i = 0; i < parts.length; i++) {
            var part = parts[i].trim()
            var step = 1
            if (part.indexOf("/") !== -1) {
                var stepParts = part.split("/")
                part = stepParts[0]
                step = parseInt(stepParts[1], 10)
                if (isNaN(step) || step <= 0) {
                    throw "步进值无效: " + parts[i]
                }
            }

            var start = min
            var end = max
            if (part !== "*" && part !== "") {
                if (part.indexOf("-") !== -1) {
                    var rangeParts = part.split("-")
                    start = normalizeValue(rangeParts[0], aliases)
                    end = normalizeValue(rangeParts[1], aliases)
                } else {
                    start = normalizeValue(part, aliases)
                    end = stepPartsFromPart(parts[i]) ? max : start
                }
            }

            if (start < min || end > max || start > end) {
                throw "范围无效: " + parts[i]
            }

            for (var value = start; value <= end; value += step) {
                values[value] = true
            }
        }

        return values
    }

    function stepPartsFromPart(part) {
        return part.indexOf("/") !== -1 && (part.split("/")[0] === "*" || part.split("/")[0] === "")
    }

    function normalizeValue(value, aliases) {
        var normalized = value.trim().toUpperCase()
        if (aliases && aliases[normalized] !== undefined) {
            return aliases[normalized]
        }
        var number = parseInt(normalized, 10)
        if (isNaN(number)) {
            throw "数值无效: " + value
        }
        return number
    }

    function pad(value) {
        return value < 10 ? "0" + value : "" + value
    }

    function formatDate(date) {
        return date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate())
                + " " + pad(date.getHours()) + ":" + pad(date.getMinutes())
                + " (" + weekNames[date.getDay()] + ")"
    }

    function fieldValues(values) {
        var list = []
        for (var key in values) {
            list.push(parseInt(key, 10))
        }
        list.sort(function(a, b) { return a - b })
        return list.join(", ")
    }

    function parseCron() {
        var expression = expandMacro(cronInput.text.trim().replace(/\s+/g, " "))
        var fields = expression.split(" ")
        if (fields.length !== 5) {
            resultText.text = ""
            detailText.text = "错误：请输入 5 段 Cron 表达式（分 时 日 月 周），或使用 @hourly/@daily/@weekly/@monthly/@yearly"
            return
        }

        try {
            var monthAliases = {
                JAN: 1, FEB: 2, MAR: 3, APR: 4, MAY: 5, JUN: 6,
                JUL: 7, AUG: 8, SEP: 9, OCT: 10, NOV: 11, DEC: 12
            }
            var weekAliases = {
                SUN: 0, MON: 1, TUE: 2, WED: 3, THU: 4, FRI: 5, SAT: 6
            }
            var minutes = parseField(fields[0], 0, 59)
            var hours = parseField(fields[1], 0, 23)
            var days = parseField(fields[2], 1, 31)
            var months = parseField(fields[3], 1, 12, monthAliases)
            var weekdays = parseField(fields[4].replace(/\b7\b/g, "0"), 0, 6, weekAliases)

            var hits = []
            var cursor = new Date()
            cursor.setSeconds(0)
            cursor.setMilliseconds(0)
            cursor.setMinutes(cursor.getMinutes() + 1)

            var maxChecks = 525600 * 2
            var targetCount = runCounts[countBox.currentIndex]
            for (var i = 0; i < maxChecks && hits.length < targetCount; i++) {
                var minute = cursor.getMinutes()
                var hour = cursor.getHours()
                var day = cursor.getDate()
                var month = cursor.getMonth() + 1
                var weekday = cursor.getDay()

                if (minutes[minute] && hours[hour] && days[day] && months[month] && weekdays[weekday]) {
                    hits.push(formatDate(new Date(cursor.getTime())))
                }
                cursor.setMinutes(cursor.getMinutes() + 1)
            }

            detailText.text = "展开表达式: " + expression
                    + "\n分钟: " + fieldValues(minutes)
                    + "\n小时: " + fieldValues(hours)
                    + "\n日期: " + fieldValues(days)
                    + "\n月份: " + fieldValues(months)
                    + "\n星期: " + fieldValues(weekdays)

            resultText.text = hits.length > 0 ? hits.join("\n") : "未来两年内未匹配到执行时间"
        } catch (e) {
            resultText.text = ""
            detailText.text = "错误：" + e
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: I18n.t("toolCronParser") || "Cron表达式解析"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: I18n.t("toolCronParserDesc") || "解析Cron表达式并计算最近执行时间"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 128
                color: "white"
                border.color: "#e0e0e0"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    Text {
                        text: I18n.t("cronExpression") || "Cron 表达式"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        ComboBox {
                            id: presetBox
                            Layout.preferredWidth: 165
                            Layout.preferredHeight: 36
                            model: cronPresets.map(function(item) { return item.label })
                            onActivated: function(index) {
                                cronInput.text = cronPresets[index].value
                                parseCron()
                            }
                        }

                        TextField {
                            id: cronInput
                            Layout.fillWidth: true
                            text: "*/5 9-18 * * MON-FRI"
                            placeholderText: I18n.t("cronPlaceholder") || "分 时 日 月 周，例如：*/5 9-18 * * MON-FRI"
                            font.pixelSize: 14
                            selectByMouse: true
                            onAccepted: parseCron()

                            background: Rectangle {
                                color: "white"
                                border.color: cronInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: cronInput.focus ? 2 : 1
                                radius: 4
                            }
                        }

                        Button {
                            text: I18n.t("parseBtn") || "解析"
                            Layout.preferredWidth: 96
                            Layout.preferredHeight: 36
                            onClicked: parseCron()

                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        ComboBox {
                            id: countBox
                            Layout.preferredWidth: 78
                            Layout.preferredHeight: 36
                            model: runCounts
                            currentIndex: 0
                            onActivated: parseCron()
                        }
                    }

                    Text {
                        text: I18n.t("cronSupportTip") || "支持 *、逗号、范围、步进、英文月份/星期和 @hourly/@daily/@weekly/@monthly/@yearly"
                        font.pixelSize: 12
                        color: "#777777"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: I18n.t("cronRecentRuns") || "最近执行时间"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333333"
                            }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: I18n.t("copyBtn") || "复制"
                                Layout.preferredWidth: 70
                                onClicked: {
                                    resultText.selectAll()
                                    resultText.copy()
                                    resultText.deselect()
                                }
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            TextArea {
                                id: resultText
                                readOnly: true
                                wrapMode: TextArea.Wrap
                                font.family: "Menlo"
                                font.pixelSize: 13
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    radius: 6

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: I18n.t("cronFieldDetails") || "字段解析"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333333"
                            }
                            Item { Layout.fillWidth: true }
                            Button {
                                text: I18n.t("copyBtn") || "复制"
                                Layout.preferredWidth: 70
                                onClicked: {
                                    detailText.selectAll()
                                    detailText.copy()
                                    detailText.deselect()
                                }
                            }
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            TextArea {
                                id: detailText
                                readOnly: true
                                wrapMode: TextArea.Wrap
                                font.family: "Menlo"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: parseCron()
}
