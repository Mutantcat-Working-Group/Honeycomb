import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: processWindow
    width: 980
    height: 700
    minimumWidth: 820
    minimumHeight: 560
    title: I18n.t("toolProcessManager") || "进程管理"
    flags: Qt.Window
    modality: Qt.NonModal

    ProcessManagerTool { id: processTool }

    property string filterText: ""
    property var visibleProcesses: []

    function filteredProcesses() {
        var keyword = filterText.toLowerCase()
        if (keyword.length === 0) return processTool.processes
        var rows = []
        for (var i = 0; i < processTool.processes.length; i++) {
            var row = processTool.processes[i]
            if (String(row.pid).indexOf(keyword) !== -1 || String(row.name).toLowerCase().indexOf(keyword) !== -1 || String(row.user).toLowerCase().indexOf(keyword) !== -1) {
                rows.push(row)
            }
        }
        return rows
    }

    function refreshVisibleProcesses() {
        visibleProcesses = filteredProcesses()
    }

    Component.onCompleted: refreshVisibleProcesses()

    Connections {
        target: processTool
        function onDataChanged() {
            refreshVisibleProcesses()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                Column {
                    Layout.fillWidth: true
                    spacing: 5
                    Text { text: I18n.t("toolProcessManager") || "进程管理"; font.pixelSize: 22; font.bold: true; color: "#333" }
                    Text { text: I18n.t("toolProcessManagerDesc") || "查看运行进程并结束指定进程"; font.pixelSize: 13; color: "#666" }
                }
                Text { text: processTool.platformName(); font.pixelSize: 13; color: "#888" }
            }

            RowLayout {
                Layout.fillWidth: true
                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: I18n.t("processSearchPlaceholder") || "按PID、进程名、用户过滤..."
                    selectByMouse: true
                    onTextChanged: {
                        filterText = text
                        refreshVisibleProcesses()
                    }
                }
                Button {
                    text: I18n.t("refreshBtn") || "刷新"
                    Layout.preferredWidth: 86
                    Layout.preferredHeight: 36
                    onClicked: processTool.refreshProcesses()
                    background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
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
                            Text { text: "PID"; Layout.preferredWidth: 80; color: "white"; font.bold: true }
                            Text { text: I18n.t("processName") || "进程名"; Layout.fillWidth: true; color: "white"; font.bold: true }
                            Text { text: I18n.t("processUser") || "用户"; Layout.preferredWidth: 120; color: "white"; font.bold: true }
                            Text { text: "CPU"; Layout.preferredWidth: 60; color: "white"; font.bold: true }
                            Text { text: "MEM"; Layout.preferredWidth: 70; color: "white"; font.bold: true }
                            Text { text: I18n.t("operation") || "操作"; Layout.preferredWidth: 100; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                        }
                    }

                    ListView {
                        id: processTableView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: visibleProcesses

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
                                Text { text: modelData.pid; Layout.preferredWidth: 80; color: "#333" }
                                Text { text: modelData.name; Layout.fillWidth: true; color: "#333"; elide: Text.ElideMiddle; font.family: "Consolas, Monaco, monospace" }
                                Text { text: modelData.user; Layout.preferredWidth: 120; color: "#666"; elide: Text.ElideRight }
                                Text { text: modelData.cpu; Layout.preferredWidth: 60; color: "#666" }
                                Text { text: modelData.memory; Layout.preferredWidth: 70; color: "#666" }
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
