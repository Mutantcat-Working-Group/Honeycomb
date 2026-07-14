import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: previewWindow
    width: 920; height: 680; minimumWidth: 760; minimumHeight: 560
    title: I18n.t("toolBase64ImagePreview") || "Base64图片预览"
    flags: Qt.Window; modality: Qt.NonModal
    property string imageSource: ""
    function preview() {
        var value = input.text.trim().replace(/\s/g, "")
        if (value.indexOf("data:image/") === 0) imageSource = value
        else imageSource = "data:image/" + formatBox.currentText + ";base64," + value
    }
    Rectangle {
        anchors.fill: parent; color: "#f9f9f9"
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 25; spacing: 18
            Text { text: I18n.t("toolBase64ImagePreview") || "Base64图片预览"; font.pixelSize: 22; font.bold: true; color: "#333"; Layout.alignment: Qt.AlignHCenter }
            Text { text: I18n.t("toolBase64ImagePreviewDesc") || "粘贴Base64或Data URL预览图片"; font.pixelSize: 13; color: "#666"; Layout.alignment: Qt.AlignHCenter }
            RowLayout {
                Layout.fillWidth: true
                ComboBox { id: formatBox; Layout.preferredWidth: 120; model: ["png", "jpeg", "webp", "gif", "bmp", "svg+xml"] }
                Button { text: I18n.t("generateBtn") || "生成"; Layout.preferredWidth: 90; onClicked: preview() }
                Button { text: I18n.t("clearBtn") || "清空"; Layout.preferredWidth: 80; onClicked: { input.text=""; imageSource="" } }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 14
                TextArea { id: input; Layout.fillWidth: true; Layout.fillHeight: true; placeholderText: "iVBORw0KGgo... 或 data:image/png;base64,..."; selectByMouse: true; wrapMode: TextArea.Wrap; font.family: "Consolas, Monaco, monospace" }
                Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: "white"; border.color: "#e0e0e0"; radius: 6; Image { anchors.fill: parent; anchors.margins: 12; source: imageSource; fillMode: Image.PreserveAspectFit; asynchronous: true } Text { anchors.centerIn: parent; text: "预览区域"; color: "#aaa"; visible: imageSource.length === 0 } }
            }
        }
    }
}
