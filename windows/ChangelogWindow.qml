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
    readonly property var tagColors: [
        "#e53935", "#00897b", "#3949ab", "#f4511e", "#8e24aa",
        "#00838f", "#43a047", "#5e35b1", "#d81b60"
    ]
    
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

                    // 更新条目 - 1.0.20260722
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 15

                            Rectangle {
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                color: changelogWindow.tagColors[0]
                                radius: 6

                                Text {
                                    anchors.centerIn: parent
                                    text: "1.0.20260722"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 5

                                Text {
                                    text: I18n.t("changelog20260722") || "新增组件选取工具"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }

                                Text {
                                    text: I18n.t("changelog20260722Desc") || "新增网页组件选取、窗口组件选取"
                                    width: parent.width
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // 更新条目 - 1.1.20260718
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
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
                                color: changelogWindow.tagColors[1]
                                radius: 6

                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260718"
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
                                    text: I18n.t("changelog20260718") || "新增工具"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }

                                Text {
                                    text: I18n.t("changelog20260718Desc") || "新增批量生成条形码到文件夹和串口调试"
                                    width: parent.width
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // 更新条目 - 1.1.20260714
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
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
                                color: changelogWindow.tagColors[2]
                                radius: 6

                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260714"
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
                                    text: I18n.t("changelog20260714") || "修复与体验优化"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }

                                Text {
                                    text: I18n.t("changelog20260714Desc") || "修复macOS进程/端口管理数据展示、PATH查看器按钮溢出等问题"
                                    width: parent.width
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // 更新条目 - 1.1.20260712
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
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
                                color: changelogWindow.tagColors[3]
                                radius: 6

                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260712"
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
                                    text: I18n.t("changelog20260712") || "修复功能页面呼出问题"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }

                                Text {
                                    text: I18n.t("changelog20260712Desc") || "修复部分功能页面无法呼出问题"
                                    width: parent.width
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // 更新条目 - 1.1.20260711
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
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
                                color: changelogWindow.tagColors[4]
                                radius: 6

                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260711"
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
                                    text: I18n.t("changelog20260711") || "处理 issue"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }

                                Text {
                                    text: I18n.t("changelog20260711Desc") || "处理 issue：#31、#32、#33"
                                    width: parent.width
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // 更新条目 - 1.1.20260707
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 92
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
                                color: changelogWindow.tagColors[5]
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260707"
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
                                    text: I18n.t("changelog20260707") || "新增开发与网络工具"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: I18n.t("changelog20260707Desc") || "新增UNIX权限矩阵、Cron表达式解析、DNS查询；优化上下文飘窗布局并支持插入AI八荣八耻"
                                    width: parent.width
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }
                    
                    // 更新条目 - 1.1.20260322
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
                                color: changelogWindow.tagColors[6]
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260322"
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
                                    text: I18n.t("changelogNewTools") || "新增工具功能"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: I18n.t("changelogNewToolsDesc") || "新增降AI功能、加解密功能、去分隔功能"
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                    
                    // 更新条目 - 1.1.20260101
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
                                color: changelogWindow.tagColors[7]
                                radius: 6
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "1.1.20260101"
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
                                    text: I18n.t("changelogAIFeature") || "增加AI功能"
                                    font.pixelSize: 16
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Text {
                                    text: I18n.t("changelogAIFeatureDesc") || "新增Agent协同、OpenAI API测试等AI相关功能"
                                    font.pixelSize: 14
                                    color: "#666"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                    
                    // 更新条目 - 1.1.20251209
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
                                color: changelogWindow.tagColors[8]
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
