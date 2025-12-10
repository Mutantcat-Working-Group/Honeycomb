import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: feedbackWindow
    width: 600
    height: 400
    title: I18n.t("toolFeedback")
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
                text: I18n.t("toolFeedback")
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
            
            // 反馈内容区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: feedbackWindow.width - 60
                    spacing: 20
                    
                    // 官网地址
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
                            
                            // 图标
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: "#1976d2"
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "🌐"
                                    font.pixelSize: 20
                                }
                            }
                            
                            // 内容
                            Column {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                Text {
                                    text: I18n.t("feedbackWebsite")
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: "www.mutantcat.org"
                                    font.pixelSize: 14
                                    color: "#1976d2"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Qt.openUrlExternally("https://www.mutantcat.org")
                                    }
                                }
                            }
                        }
                    }
                    
                    // 反馈地址
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
                            
                            // 图标
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: "#1976d2"
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "📝"
                                    font.pixelSize: 20
                                }
                            }
                            
                            // 内容
                            Column {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                Text {
                                    text: I18n.t("feedbackUrl")
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: "https://www.mutantcat.org/feedback"
                                    font.pixelSize: 14
                                    color: "#1976d2"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Qt.openUrlExternally("https://www.mutantcat.org/feedback")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Github 仓库
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
                            
                            // 图标
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: "#1976d2"
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "🐙"
                                    font.pixelSize: 20
                                }
                            }
                            
                            // 内容
                            Column {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                Text {
                                    text: I18n.t("feedbackGithub")
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: "github.com/Mutantcat-Working-Group/Honeycomb"
                                    font.pixelSize: 14
                                    color: "#1976d2"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Qt.openUrlExternally("https://github.com/Mutantcat-Working-Group/Honeycomb")
                                    }
                                }
                            }
                        }
                    }
                    
                    // 反馈邮箱
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
                            
                            // 图标
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                color: "#1976d2"
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "📧"
                                    font.pixelSize: 20
                                }
                            }
                            
                            // 内容
                            Column {
                                Layout.fillWidth: true
                                spacing: 5
                                
                                Text {
                                    text: I18n.t("feedbackEmail")
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                RowLayout {
                                    width: parent.width
                                    
                                    Text {
                                        text: "feedback@mutantcat.org"
                                        font.pixelSize: 14
                                        color: "#1976d2"
                                        Layout.fillWidth: true
                                    }
                                    
                                    Button {
                                        text: I18n.t("copyBtn")
                                        Layout.alignment: Qt.AlignRight
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 12
                                            color: "#1976d2"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        background: Rectangle {
                                            color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                                            border.color: "#1976d2"
                                            border.width: 1
                                            radius: 4
                                            implicitWidth: 60
                                            implicitHeight: 28
                                        }
                                        
                                        onClicked: {
                                            hiddenTextArea.selectAll()
                                            hiddenTextArea.copy()
                                            copyNotification.visible = true
                                            copyTimer.restart()
                                        }
                                    }
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
    
    // 隐藏的文本区域用于复制
    TextArea {
        id: hiddenTextArea
        visible: false
        text: "feedback@mutantcat.org"
    }
    
    // 复制成功提示
    Rectangle {
        id: copyNotification
        anchors.centerIn: parent
        width: 150
        height: 40
        color: "#4caf50"
        radius: 6
        visible: false
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess")
            font.pixelSize: 14
            color: "white"
        }
        
        Timer {
            id: copyTimer
            interval: 2000
            onTriggered: copyNotification.visible = false
        }
    }
}