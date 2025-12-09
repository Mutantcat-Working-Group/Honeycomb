import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: aboutWindow
    width: 500
    height: 400
    title: "关于蜂巢"
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
                text: "蜂巢工具箱是一个离线工具箱，提供了一些常用的工具。"
                font.pixelSize: 16
                color: "#333"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            
            // 官网
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "官网：www.mutantcat.org"
                font.pixelSize: 14
                color: "#666"
            }
            
            // 版本号
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "版本：1.1.20251209"
                font.pixelSize: 14
                color: "#666"
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
