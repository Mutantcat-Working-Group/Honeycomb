import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: settingsWindow
    width: 500
    height: 300
    minimumWidth: 400
    minimumHeight: 300
    title: I18n.t("toolSettings") || "软件设置"
    
    signal languageChanged(string lang)
    
    Rectangle {
        anchors.fill: parent
        color: "#f5f5f5"
        
        Flickable {
            anchors.fill: parent
            anchors.margins: 16
            contentWidth: width
            contentHeight: contentColumn.height
            clip: true
            
            ColumnLayout {
                id: contentColumn
                width: parent.width
                spacing: 16
                
                // 语言设置卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: langContent.height + 32
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        id: langContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 16
                        
                        Text {
                            text: "🌐 " + (I18n.t("settingsLanguage") || "语言设置")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333"
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: I18n.t("settingsLanguageDesc") || "选择界面显示语言，切换后需要重新打开窗口生效"
                            font.pixelSize: 13
                            color: "#666"
                            wrapMode: Text.Wrap
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: I18n.t("currentLanguage") || "当前语言"
                                font.pixelSize: 14
                                color: "#333"
                            }
                            
                            ComboBox {
                                id: langComboBox
                                Layout.preferredWidth: 200
                                model: ListModel {
                                    ListElement { text: "简体中文"; value: "zh_CN" }
                                    ListElement { text: "English"; value: "en_US" }
                                }
                                textRole: "text"
                                
                                currentIndex: I18n.currentLang === "en_US" ? 1 : 0
                                
                                delegate: ItemDelegate {
                                    width: langComboBox.width
                                    contentItem: Text {
                                        text: model.text
                                        font.pixelSize: 13
                                        color: "#333"
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    highlighted: langComboBox.highlightedIndex === index
                                }
                                
                                contentItem: Text {
                                    leftPadding: 10
                                    text: langComboBox.displayText
                                    font.pixelSize: 13
                                    color: "#333"
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: langComboBox.pressed ? "#1976d2" : "#e0e0e0"
                                    border.width: 1
                                    radius: 4
                                    implicitHeight: 36
                                }
                                
                                onCurrentIndexChanged: {
                                    var selectedLang = model.get(currentIndex).value
                                    if (I18n.currentLang !== selectedLang) {
                                        I18n.setLanguage(selectedLang)
                                        settingsWindow.languageChanged(selectedLang)
                                        // 更新当前窗口标题
                                        settingsWindow.title = I18n.t("toolSettings") || "软件设置"
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 提示卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: tipContent.height + 32
                    color: "#fff8e1"
                    border.color: "#ffe082"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        id: tipContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12
                        
                        Text {
                            text: "💡 " + (I18n.t("settingsTip") || "提示")
                            font.pixelSize: 14
                            font.bold: true
                            color: "#f57c00"
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: I18n.t("settingsTipDesc") || "语言切换后，主界面会立即更新。已打开的工具窗口需要关闭后重新打开才能看到新语言。"
                            font.pixelSize: 13
                            color: "#666"
                            wrapMode: Text.Wrap
                            lineHeight: 1.4
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
    }
}
