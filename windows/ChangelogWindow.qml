import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: changelogWindow
    width: 700
    height: 500
    title: I18n.t("changelogTitle")
    flags: Qt.Window
    modality: Qt.NonModal
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            // 标题
            Text {
                text: I18n.t("changelogTitle")
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#e0e0e0"
            }
            
            // 更新日志内容区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: changelogWindow.width - 60
                    spacing: 15
                    
                    // 更新条目
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15
                            
                            // 日期标签
                            Rectangle {
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                color: "#1976d2"
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20251209"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                }
                            }
                            
                            // 更新内容
                            Column {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                Text {
                                    text: I18n.t("changelogQtMigration")
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: I18n.t("changelogQtMigrationDesc")
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                    
                    // 占位空间
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}