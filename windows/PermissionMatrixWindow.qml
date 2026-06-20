import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: permissionMatrixWindow
    width: 760
    height: 540
    minimumWidth: 680
    minimumHeight: 480
    title: I18n.t("toolPermissionMatrix") || "权限矩阵"
    flags: Qt.Window
    modality: Qt.NonModal

    property var subjects: [
        { key: "owner", title: "Owner", subtitle: "文件所有者" },
        { key: "group", title: "Group", subtitle: "所属用户组" },
        { key: "others", title: "Others", subtitle: "其他用户" }
    ]
    property var operations: [
        { key: "read", title: "Read", symbol: "r", value: 4 },
        { key: "write", title: "Write", symbol: "w", value: 2 },
        { key: "execute", title: "Execute", symbol: "x", value: 1 }
    ]
    property var permissions: ({
        owner: { read: true, write: true, execute: true },
        group: { read: true, write: false, execute: true },
        others: { read: true, write: false, execute: true }
    })

    function hasPermission(subject, operation) {
        var row = permissions[subject]
        return row ? row[operation] === true : false
    }

    function setPermission(subject, operation, checked) {
        var next = {}
        for (var subjectKey in permissions) {
            var source = permissions[subjectKey]
            next[subjectKey] = {
                read: source.read === true,
                write: source.write === true,
                execute: source.execute === true
            }
        }
        if (!next[subject]) {
            next[subject] = { read: false, write: false, execute: false }
        }
        next[subject][operation] = checked
        permissions = next
    }

    function rowValue(subject) {
        var total = 0
        for (var i = 0; i < operations.length; i++) {
            var operation = operations[i]
            if (hasPermission(subject, operation.key)) {
                total += operation.value
            }
        }
        return total
    }

    function numericMode() {
        var result = ""
        for (var i = 0; i < subjects.length; i++) {
            result += rowValue(subjects[i].key).toString()
        }
        return result
    }

    function symbolicMode() {
        var result = ""
        for (var i = 0; i < subjects.length; i++) {
            var subject = subjects[i].key
            for (var j = 0; j < operations.length; j++) {
                var operation = operations[j]
                result += hasPermission(subject, operation.key) ? operation.symbol : "-"
            }
        }
        return result
    }

    function copyText() {
        return "chmod " + numericMode() + " file\n" + symbolicMode()
    }

    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
    }

    Rectangle {
        anchors.fill: parent
        color: "#f6f8fb"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 18

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: copyButton.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text {
                        text: I18n.t("toolPermissionMatrix") || "权限矩阵"
                        font.pixelSize: 24
                        font.bold: true
                        color: "#202124"
                    }

                    Text {
                        text: "Permission Matrix Table - UNIX chmod"
                        font.pixelSize: 13
                        color: "#667085"
                    }
                }

                Button {
                    id: copyButton
                    text: I18n.t("copy") || "复制"
                    width: 104
                    height: 38
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: copyToClipboard(copyText())

                    background: Rectangle {
                        implicitWidth: 104
                        implicitHeight: 38
                        radius: 8
                        color: parent.hovered ? "#1557b0" : "#1976d2"
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
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    radius: 10
                    color: numericCard.hovered ? "#f8fbff" : "#ffffff"
                    border.color: numericCard.hovered ? "#1976d2" : "#d9dee8"

                    id: numericCard
                    property bool hovered: false

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "chmod " + numericMode()
                            font.pixelSize: 24
                            font.bold: true
                            color: "#202124"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "数字权限"
                            font.pixelSize: 12
                            color: "#667085"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: numericCard.hovered = true
                        onExited: numericCard.hovered = false
                        onClicked: copyToClipboard(numericMode())
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 86
                    radius: 10
                    color: symbolicCard.hovered ? "#f8fbff" : "#ffffff"
                    border.color: symbolicCard.hovered ? "#1976d2" : "#d9dee8"

                    id: symbolicCard
                    property bool hovered: false

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: symbolicMode()
                            font.family: "Menlo"
                            font.pixelSize: 24
                            font.bold: true
                            color: "#202124"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "符号权限"
                            font.pixelSize: 12
                            color: "#667085"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: symbolicCard.hovered = true
                        onExited: symbolicCard.hovered = false
                        onClicked: copyToClipboard(symbolicMode())
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: "#ffffff"
                border.color: "#d9dee8"
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        color: "#0f172a"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 10

                            Text {
                                text: "角色 / 权限"
                                Layout.preferredWidth: 150
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                            }

                            Repeater {
                                model: operations

                                Text {
                                    text: modelData.title + " (" + modelData.value + ")"
                                    Layout.fillWidth: true
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            Text {
                                text: "值"
                                Layout.preferredWidth: 64
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    Repeater {
                        model: subjects

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: index % 2 === 0 ? "#ffffff" : "#f8fafc"
                            border.color: "#edf0f5"

                            property string subjectKey: modelData.key

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 10

                                Column {
                                    Layout.preferredWidth: 150
                                    spacing: 4

                                    Text {
                                        text: modelData.title
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "#202124"
                                    }

                                    Text {
                                        text: modelData.subtitle
                                        font.pixelSize: 12
                                        color: "#667085"
                                    }
                                }

                                Repeater {
                                    model: operations

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        CheckBox {
                                            anchors.centerIn: parent
                                            checked: hasPermission(subjectKey, modelData.key)
                                            onToggled: setPermission(subjectKey, modelData.key, checked)
                                        }
                                    }
                                }

                                Text {
                                    text: rowValue(subjectKey)
                                    Layout.preferredWidth: 64
                                    font.pixelSize: 18
                                    font.bold: true
                                    color: "#1976d2"
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: "说明：Read=4，Write=2，Execute=1；每一行相加得到 Owner / Group / Others 的 chmod 数字。"
                font.pixelSize: 12
                color: "#667085"
                wrapMode: Text.WordWrap
            }
        }
    }

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
