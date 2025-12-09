import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: aboutWindow
    width: 500
    height: 400
    title: I18n.t("aboutTitle")
    flags: Qt.Window
    modality: Qt.NonModal
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 20
            
            // Logo图片
            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/qt/qml/Honeycomb/assets/icons/icon.jpg"
                sourceSize.width: 100
                sourceSize.height: 100
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                fillMode: Image.PreserveAspectFit
            }
            
            // 描述文字
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: I18n.t("aboutDesc")
                font.pixelSize: 16
                color: "#333"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            
            // 官网
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: I18n.t("aboutWebsite")
                font.pixelSize: 14
                color: "#666"
            }
            
            // 版本号
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: I18n.t("aboutVersion")
                font.pixelSize: 14
                color: "#666"
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
