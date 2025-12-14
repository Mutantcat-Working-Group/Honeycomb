import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: passwordStrengthWindow
    width: 600
    height: 550
    minimumWidth: 600
    minimumHeight: 550
    title: I18n.t("toolPwdStrength")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // C++ 后端实例
    PasswordStrengthGenerator {
        id: generator
    }
    
    function analyze() {
        generator.password = passwordInput.text
        generator.analyze()
    }
    
    function getStrengthColor(score) {
        if (score < 20) return "#e74c3c"      // 红色 - 非常弱
        else if (score < 40) return "#e67e22" // 橙色 - 弱
        else if (score < 60) return "#f39c12" // 黄色 - 一般
        else if (score < 80) return "#27ae60" // 绿色 - 强
        else return "#2ecc71"                  // 亮绿色 - 非常强
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 标题
            Text {
                text: I18n.t("toolPwdStrength")
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolPwdStrengthDesc")
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 输入区域
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: I18n.t("inputPassword") || "输入密码:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    TextField {
                        id: passwordInput
                        Layout.fillWidth: true
                        placeholderText: I18n.t("enterPasswordHere") || "请输入要分析的密码..."
                        echoMode: TextInput.Password
                        font.pixelSize: 14
                        
                        background: Rectangle {
                            color: "#f9f9f9"
                            border.color: passwordInput.focus ? "#1976d2" : "#e0e0e0"
                            border.width: passwordInput.focus ? 2 : 1
                            radius: 4
                        }
                        
                        Keys.onReturnPressed: analyze()
                    }
                    
                    CheckBox {
                        id: showPasswordCheck
                        text: I18n.t("showPassword") || "显示密码"
                        checked: false
                        
                        onCheckedChanged: {
                            passwordInput.echoMode = checked ? TextInput.Normal : TextInput.Password
                        }
                    }
                }
            }
            
            // 强度显示区域
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#f9f9f9"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("strengthScore") || "强度得分:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Text {
                            text: generator.score + "/100"
                            font.pixelSize: 18
                            font.bold: true
                            color: getStrengthColor(generator.score)
                        }
                        
                        Text {
                            text: generator.strengthLevel
                            font.pixelSize: 16
                            font.bold: true
                            color: getStrengthColor(generator.score)
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // 进度条
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 10
                        visible: generator.score > 0
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#e0e0e0"
                            radius: 5
                        }
                        
                        Rectangle {
                            width: parent.width * (generator.score / 100.0)
                            height: parent.height
                            color: getStrengthColor(generator.score)
                            radius: 5
                            
                            Behavior on width {
                                NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                            }
                        }
                    }
                }
            }
            
            // 密码特征区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f9f9f9"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12
                    
                    Text {
                        text: I18n.t("passwordFeatures") || "密码特征:"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    // 特征列表
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        // 长度
                        Row {
                            spacing: 10
                            
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: generator.length >= 8 ? "#2ecc71" : 
                                       (generator.length > 0 ? "#e74c3c" : "#bdc3c7")
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: generator.length >= 8 ? "✓" : 
                                         (generator.length > 0 ? "✕" : "-")
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: (I18n.t("length") || "长度") + ": " + 
                                      (generator.length > 0 ? generator.length : "未输入")
                                font.pixelSize: 14
                                color: "#333333"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // 小写字母
                        Row {
                            spacing: 10
                            
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: generator.hasLowercase ? "#2ecc71" : 
                                       (generator.length > 0 ? "#e74c3c" : "#bdc3c7")
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: generator.hasLowercase ? "✓" : 
                                         (generator.length > 0 ? "✕" : "-")
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: I18n.t("containsLowercase") || "包含小写字母"
                                font.pixelSize: 14
                                color: "#333333"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // 大写字母
                        Row {
                            spacing: 10
                            
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: generator.hasUppercase ? "#2ecc71" : 
                                       (generator.length > 0 ? "#e74c3c" : "#bdc3c7")
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: generator.hasUppercase ? "✓" : 
                                         (generator.length > 0 ? "✕" : "-")
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: I18n.t("containsUppercase") || "包含大写字母"
                                font.pixelSize: 14
                                color: "#333333"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // 数字
                        Row {
                            spacing: 10
                            
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: generator.hasDigits ? "#2ecc71" : 
                                       (generator.length > 0 ? "#e74c3c" : "#bdc3c7")
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: generator.hasDigits ? "✓" : 
                                         (generator.length > 0 ? "✕" : "-")
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: I18n.t("containsDigits") || "包含数字"
                                font.pixelSize: 14
                                color: "#333333"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        // 特殊字符
                        Row {
                            spacing: 10
                            
                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: generator.hasSpecialChars ? "#2ecc71" : 
                                       (generator.length > 0 ? "#e74c3c" : "#bdc3c7")
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: generator.hasSpecialChars ? "✓" : 
                                         (generator.length > 0 ? "✕" : "-")
                                    color: "white"
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                            }
                            
                            Text {
                                text: I18n.t("containsSpecialChars") || "包含特殊字符 (!@#$%^&*等)"
                                font.pixelSize: 14
                                color: "#333333"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }
            
            // 按钮区域
            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("analyzeBtn") || "分析"
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: analyze()
                }
                
                Button {
                    text: I18n.t("clearBtn") || "清空"
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 32
                    
                    background: Rectangle {
                        color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#666666"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        passwordInput.text = ""
                        analyze()
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        generator.analyze()
    }
}
