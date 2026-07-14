import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    width: 820; height: 560; minimumWidth: 720; minimumHeight: 480
    title: I18n.t("toolLddQuick") || "快捷LDD"
    flags: Qt.Window; modality: Qt.NonModal
    function copyToClipboard(text){ clip.text=text; clip.selectAll(); clip.copy(); clip.text=""; toast.opacity=0.9; timer.restart() }
    TextArea { id: clip; visible: false }
    Rectangle {
        anchors.fill: parent; color: "#f9f9f9"
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 25; spacing: 18
            Text { text: I18n.t("toolLddQuick") || "快捷LDD"; font.pixelSize: 22; font.bold: true; color: "#333"; Layout.alignment: Qt.AlignHCenter }
            Text { text: I18n.t("toolLddQuickDesc") || "Linux/macOS动态库依赖查看命令"; font.pixelSize: 13; color: "#666"; Layout.alignment: Qt.AlignHCenter }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                TextField { id: fileInput; anchors.fill: parent; anchors.margins: 10; placeholderText: "/path/to/binary-or-library"; selectByMouse: true; background: null }
            }
            Repeater {
                model: [
                    ["Linux 查看依赖", "ldd \"" + (fileInput.text || "/path/to/app") + "\""],
                    ["Linux 缺失依赖", "ldd \"" + (fileInput.text || "/path/to/app") + "\" | grep \"not found\""],
                    ["macOS 查看依赖", "otool -L \"" + (fileInput.text || "/path/to/app") + "\""],
                    ["macOS 查找 rpath", "otool -l \"" + (fileInput.text || "/path/to/app") + "\" | grep -A2 LC_RPATH"],
                    ["macOS 修改依赖", "install_name_tool -change old.dylib new.dylib \"" + (fileInput.text || "/path/to/app") + "\""]
                ]
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 58; color: "white"; border.color: "#e0e0e0"; radius: 6
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        Text { text: modelData[0]; Layout.preferredWidth: 130; color: "#333"; font.bold: true }
                        Text { text: modelData[1]; Layout.fillWidth: true; font.family: "Consolas, Monaco, monospace"; elide: Text.ElideMiddle }
                        Button {
                            text: I18n.t("copyBtn") || "复制"
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 30
                            onClicked: copyToClipboard(modelData[1])
                            background: Rectangle { color: parent.hovered ? "#006cbd" : "#0078d4"; radius: 4 }
                            contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                }
            }
            Text { Layout.fillWidth: true; text: "说明：此工具只提供 Linux/macOS 命令参考，不在 Windows 上执行 ldd。"; color: "#888"; wrapMode: Text.WordWrap }
            Item { Layout.fillHeight: true }
        }
    }
    Rectangle { id: toast; width: 150; height: 36; radius: 18; color: "#333"; opacity: 0; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 25; Text { anchors.centerIn: parent; text: I18n.t("copySuccess") || "已复制到剪贴板"; color: "white"; font.pixelSize: 12 } Timer { id: timer; interval: 1500; onTriggered: toast.opacity=0 } }
}
