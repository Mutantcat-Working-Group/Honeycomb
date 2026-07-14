import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: portWindow
    width: 920
    height: 660
    minimumWidth: 780
    minimumHeight: 540
    title: I18n.t("toolPortManager") || "端口管理"
    flags: Qt.Window
    modality: Qt.NonModal

    ProcessManagerTool { id: processTool }
    property int targetPort: {
        var value = parseInt(portInput.text, 10)
        return isNaN(value) ? 0 : value
    }
    property var visiblePorts: []

    function filteredPorts() {
        if (!targetPort || targetPort <= 0) return processTool.ports
        var rows = []
        for (var i = 0; i < processTool.ports.length; i++) {
            if (processTool.ports[i].port === targetPort) rows.push(processTool.ports[i])
        }
        return rows
    }

    function refreshVisiblePorts() {
        visiblePorts = filteredPorts()
    }

    Component.onCompleted: refreshVisiblePorts()

    Connections {
        target: processTool
        function onDataChanged() {
            refreshVisiblePorts()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 16

            Text { text: I18n.t("toolPortManager") || "端口管理"; font.pixelSize: 22; font.bold: true; color: "#333"; Layout.alignment: Qt.AlignHCenter }
            Text { text: I18n.t("toolPortManagerDesc") || "查看端口占用并快捷结束占用进程"; font.pixelSize: 13; color: "#666"; Layout.alignment: Qt.AlignHCenter }

            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: portInput
                    Layout.fillWidth: true
                    placeholderText: I18n.t("portInputPlaceholder") || "输入端口号，例如 8080；留空显示所有监听端口"
                    selectByMouse: true
                    inputMethodHints: Qt.ImhDigitsOnly
                    onTextChanged: refreshVisiblePorts()
                }
                Button {
                    text: I18n.t("refreshBtn") || "刷新"
                    Layout.preferredWidth: 86
                    Layout.preferredHeight: 36
                    onClicked: processTool.refreshPorts()
                    background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
                Button {
                    text: I18n.t("killPort") || "释放端口"
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    enabled: targetPort > 0
                    onClicked: processTool.killPort(targetPort)
                    background: Rectangle { color: parent.enabled ? (parent.hovered ? "#d32f2f" : "#f44336") : "#cccccc"; radius: 4 }
                    contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }

            Text { Layout.fillWidth: true; text: processTool.message; visible: processTool.message.length > 0; color: "#666"; wrapMode: Text.WordWrap }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 1
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: "#0078d4"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            Text { text: I18n.t("portLabel") || "端口"; Layout.preferredWidth: 80; color: "white"; font.bold: true }
                            Text { text: "PID"; Layout.preferredWidth: 80; color: "white"; font.bold: true }
                            Text { text: I18n.t("processName") || "进程名"; Layout.fillWidth: true; color: "white"; font.bold: true }
                            Text { text: I18n.t("listenAddress") || "监听地址"; Layout.preferredWidth: 180; color: "white"; font.bold: true }
                            Text { text: I18n.t("operation") || "操作"; Layout.preferredWidth: 100; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        }
                    }

                    ListView {
                        id: portTableView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: visiblePorts

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 42
                            color: index % 2 === 0 ? "#ffffff" : "#fafafa"
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12
                                Text { text: modelData.port; Layout.preferredWidth: 80; color: "#333" }
                                Text { text: modelData.pid; Layout.preferredWidth: 80; color: "#333" }
                                Text { text: modelData.command; Layout.fillWidth: true; color: "#333"; elide: Text.ElideMiddle; font.family: "Consolas, Monaco, monospace" }
                                Text { text: modelData.address; Layout.preferredWidth: 180; color: "#666"; elide: Text.ElideMiddle }
                                Button {
                                    text: I18n.t("killProcess") || "结束"
                                    Layout.preferredWidth: 88
                                    Layout.preferredHeight: 30
                                    onClicked: processTool.killProcess(modelData.pid)
                                    background: Rectangle { color: parent.hovered ? "#fff0f0" : "white"; border.color: parent.hovered ? "#d32f2f" : "#d0d0d0"; border.width: 1; radius: 4 }
                                    contentItem: Text { text: parent.text; color: parent.hovered ? "#d32f2f" : "#333"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
