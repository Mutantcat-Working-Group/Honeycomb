import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: helpWindow
    width: 650
    height: 550
    minimumWidth: 500
    minimumHeight: 400
    title: I18n.t("toolHelp") || "使用帮助"
    
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
                
                // 欢迎卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: welcomeContent.height + 32
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        id: welcomeContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12
                        
                        Text {
                            text: I18n.t("helpWelcome") || "👋 欢迎使用蜂巢工具箱"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#333"
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: I18n.t("helpWelcomeDesc") || "蜂巢工具箱是一款面向开发者的离线工具集合，提供编码转换、字符处理、加密解密、随机生成等多种实用工具，无需联网即可使用。"
                            font.pixelSize: 14
                            color: "#666"
                            wrapMode: Text.Wrap
                            lineHeight: 1.5
                        }
                    }
                }
                
                // 基本操作卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: basicContent.height + 32
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        id: basicContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12
                        
                        Text {
                            text: I18n.t("helpBasic") || "📖 基本操作"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpBasic1") || "• 左侧导航栏可以切换不同的工具分类"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpBasic2") || "• 点击右侧的工具卡片即可打开对应的工具窗口"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpBasic3") || "• 每个工具都会在独立的窗口中打开，不会影响主界面"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpBasic4") || "• 同一个工具可以同时打开多个窗口，方便对比或批量处理"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpBasic5") || "• 工具窗口可以自由移动、调整大小，关闭后不影响其他窗口"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
                
                // 工具分类卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: categoryContent.height + 32
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        id: categoryContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12
                        
                        Text {
                            text: I18n.t("helpCategory") || "🗂️ 工具分类"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333"
                        }
                        
                        Grid {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 8
                            columnSpacing: 16
                            
                            Text { text: I18n.t("helpCatEncode") || "📦 编码工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatEncodeDesc") || "条形码、二维码、时间戳、进制转换等"; font.pixelSize: 12; color: "#888" }
                            
                            Text { text: I18n.t("helpCatString") || "📝 字符工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatStringDesc") || "去空格、文本对比、正则测试、大小写转换等"; font.pixelSize: 12; color: "#888" }
                            
                            Text { text: I18n.t("helpCatDev") || "🛠️ 开发工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatDevDesc") || "JSON格式化、颜色选择器、HTTP状态码等"; font.pixelSize: 12; color: "#888" }
                            
                            Text { text: I18n.t("helpCatEncrypt") || "🔐 加密工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatEncryptDesc") || "MD5、SHA1、SHA256 等哈希加密"; font.pixelSize: 12; color: "#888" }
                            
                            Text { text: I18n.t("helpCatRandom") || "🎲 随机工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatRandomDesc") || "随机数字、字符串、UUID、MAC地址等"; font.pixelSize: 12; color: "#888" }
                            
                            Text { text: I18n.t("helpCatNetwork") || "🌐 网络工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatNetworkDesc") || "WebSocket测试、子网计算器等"; font.pixelSize: 12; color: "#888" }
                            
                            Text { text: I18n.t("helpCatHardware") || "💻 硬件工具"; font.pixelSize: 13; color: "#555" }
                            Text { text: I18n.t("helpCatHardwareDesc") || "寄存器速查、电阻计算、指令集等"; font.pixelSize: 12; color: "#888" }
                        }
                    }
                }
                
                // 快捷键卡片
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: shortcutContent.height + 32
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    ColumnLayout {
                        id: shortcutContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 16
                        spacing: 12
                        
                        Text {
                            text: I18n.t("helpShortcut") || "⌨️ 常用操作"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpShortcut1") || "• 大部分工具支持 Ctrl+V 直接粘贴内容到输入框"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpShortcut2") || "• 点击「复制」按钮可将结果复制到剪贴板"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpShortcut3") || "• 部分工具支持实时转换，输入内容后自动显示结果"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: I18n.t("helpShortcut4") || "• 右上角可切换中英文界面语言"
                                font.pixelSize: 13
                                color: "#555"
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
                
                // 底部提示
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    text: I18n.t("helpFooter") || "如有问题或建议，欢迎通过「反馈建议」功能联系我们 ❤️"
                    font.pixelSize: 12
                    color: "#999"
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Item { Layout.preferredHeight: 16 }
            }
            
            ScrollBar.vertical: ScrollBar { }
        }
    }
}
