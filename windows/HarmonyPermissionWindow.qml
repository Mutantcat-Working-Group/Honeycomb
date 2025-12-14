import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: harmonyPermissionWindow
    width: 1100
    height: 700
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolHarmonyPermission")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // HarmonyOS权限数据
    property var permissionData: {
        "网络权限": [
            {name: "ohos.permission.INTERNET", desc: "允许应用打开网络套接字，进行网络连接", permission: "ohos.permission.INTERNET"},
            {name: "ohos.permission.GET_NETWORK_INFO", desc: "允许应用获取网络连接信息", permission: "ohos.permission.GET_NETWORK_INFO"},
            {name: "ohos.permission.SET_NETWORK_INFO", desc: "允许应用设置网络连接信息", permission: "ohos.permission.SET_NETWORK_INFO"}
        ],
        "位置权限": [
            {name: "ohos.permission.LOCATION", desc: "允许应用获取设备位置信息", permission: "ohos.permission.LOCATION"},
            {name: "ohos.permission.LOCATION_IN_BACKGROUND", desc: "允许应用在后台获取设备位置信息", permission: "ohos.permission.LOCATION_IN_BACKGROUND"},
            {name: "ohos.permission.APPROXIMATELY_LOCATION", desc: "允许应用获取设备大致位置信息", permission: "ohos.permission.APPROXIMATELY_LOCATION"}
        ],
        "相机权限": [
            {name: "ohos.permission.CAMERA", desc: "允许应用使用相机设备", permission: "ohos.permission.CAMERA"},
            {name: "ohos.permission.MICROPHONE", desc: "允许应用使用麦克风设备", permission: "ohos.permission.MICROPHONE"}
        ],
        "存储权限": [
            {name: "ohos.permission.READ_MEDIA", desc: "允许应用读取用户媒体文件", permission: "ohos.permission.READ_MEDIA"},
            {name: "ohos.permission.WRITE_MEDIA", desc: "允许应用写入用户媒体文件", permission: "ohos.permission.WRITE_MEDIA"},
            {name: "ohos.permission.READ_IMAGEVIDEO", desc: "允许应用读取图片和视频文件", permission: "ohos.permission.READ_IMAGEVIDEO"},
            {name: "ohos.permission.WRITE_IMAGEVIDEO", desc: "允许应用写入图片和视频文件", permission: "ohos.permission.WRITE_IMAGEVIDEO"},
            {name: "ohos.permission.READ_AUDIO", desc: "允许应用读取音频文件", permission: "ohos.permission.READ_AUDIO"},
            {name: "ohos.permission.WRITE_AUDIO", desc: "允许应用写入音频文件", permission: "ohos.permission.WRITE_AUDIO"}
        ],
        "联系人权限": [
            {name: "ohos.permission.READ_CONTACTS", desc: "允许应用读取用户联系人数据", permission: "ohos.permission.READ_CONTACTS"},
            {name: "ohos.permission.WRITE_CONTACTS", desc: "允许应用写入用户联系人数据", permission: "ohos.permission.WRITE_CONTACTS"}
        ],
        "电话权限": [
            {name: "ohos.permission.ANSWER_CALL", desc: "允许应用接听电话", permission: "ohos.permission.ANSWER_CALL"},
            {name: "ohos.permission.MANAGE_VOICEMAIL", desc: "允许应用管理语音邮件", permission: "ohos.permission.MANAGE_VOICEMAIL"},
            {name: "ohos.permission.READ_CALL_LOG", desc: "允许应用读取通话记录", permission: "ohos.permission.READ_CALL_LOG"},
            {name: "ohos.permission.WRITE_CALL_LOG", desc: "允许应用写入通话记录", permission: "ohos.permission.WRITE_CALL_LOG"}
        ],
        "短信权限": [
            {name: "ohos.permission.SEND_MESSAGES", desc: "允许应用发送短信", permission: "ohos.permission.SEND_MESSAGES"},
            {name: "ohos.permission.RECEIVE_MESSAGES", desc: "允许应用接收短信", permission: "ohos.permission.RECEIVE_MESSAGES"},
            {name: "ohos.permission.READ_MESSAGES", desc: "允许应用读取短信", permission: "ohos.permission.READ_MESSAGES"}
        ],
        "日历权限": [
            {name: "ohos.permission.READ_CALENDAR", desc: "允许应用读取用户日历数据", permission: "ohos.permission.READ_CALENDAR"},
            {name: "ohos.permission.WRITE_CALENDAR", desc: "允许应用写入用户日历数据", permission: "ohos.permission.WRITE_CALENDAR"}
        ],
        "通知权限": [
            {name: "ohos.permission.NOTIFICATION_CONTROLLER", desc: "允许应用发送通知", permission: "ohos.permission.NOTIFICATION_CONTROLLER"},
            {name: "ohos.permission.PUBLISH_AGENT_REMINDER", desc: "允许应用发布提醒代理", permission: "ohos.permission.PUBLISH_AGENT_REMINDER"}
        ],
        "系统权限": [
            {name: "ohos.permission.SYSTEM_FLOAT_WINDOW", desc: "允许应用显示悬浮窗", permission: "ohos.permission.SYSTEM_FLOAT_WINDOW"},
            {name: "ohos.permission.INSTALL_BUNDLE", desc: "允许应用安装应用包", permission: "ohos.permission.INSTALL_BUNDLE"},
            {name: "ohos.permission.MANAGE_LOCAL_ACCOUNTS", desc: "允许应用管理系统账户", permission: "ohos.permission.MANAGE_LOCAL_ACCOUNTS"},
            {name: "ohos.permission.CONTROL_WIFI", desc: "允许应用控制WiFi连接", permission: "ohos.permission.CONTROL_WIFI"},
            {name: "ohos.permission.CHANGE_ABILITY_ENABLED_STATE", desc: "允许应用更改Ability启用状态", permission: "ohos.permission.CHANGE_ABILITY_ENABLED_STATE"}
        ],
        "设备信息权限": [
            {name: "ohos.permission.GET_BUNDLE_INFO", desc: "允许应用获取应用包信息", permission: "ohos.permission.GET_BUNDLE_INFO"},
            {name: "ohos.permission.GET_BUNDLE_INFO_PRIVILEGED", desc: "允许应用获取应用包信息（特权）", permission: "ohos.permission.GET_BUNDLE_INFO_PRIVILEGED"},
            {name: "ohos.permission.GET_SENSITIVE_PERMISSIONS", desc: "允许应用获取敏感权限信息", permission: "ohos.permission.GET_SENSITIVE_PERMISSIONS"},
            {name: "ohos.permission.GET_INSTALLED_BUNDLE_LIST", desc: "允许应用获取已安装应用列表", permission: "ohos.permission.GET_INSTALLED_BUNDLE_LIST"}
        ],
        "其他权限": [
            {name: "ohos.permission.BLUETOOTH", desc: "允许应用使用蓝牙功能", permission: "ohos.permission.BLUETOOTH"},
            {name: "ohos.permission.USE_BLUETOOTH", desc: "允许应用使用蓝牙", permission: "ohos.permission.USE_BLUETOOTH"},
            {name: "ohos.permission.MANAGE_BLUETOOTH", desc: "允许应用管理蓝牙", permission: "ohos.permission.MANAGE_BLUETOOTH"},
            {name: "ohos.permission.DISTRIBUTED_DATASYNC", desc: "允许应用进行分布式数据同步", permission: "ohos.permission.DISTRIBUTED_DATASYNC"},
            {name: "ohos.permission.ACTIVITY_MOTION", desc: "允许应用访问活动运动数据", permission: "ohos.permission.ACTIVITY_MOTION"}
        ]
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 20
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolHarmonyPermission")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolHarmonyPermissionDesc") || "HarmonyOS权限参照表"
                    font.pixelSize: 13
                    color: "#666"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 内容区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: harmonyPermissionWindow.width - 50
                    spacing: 25
                    
                    // 遍历每个分类
                    Repeater {
                        id: categoryRepeater
                        model: Object.keys(permissionData)
                        
                        ColumnLayout {
                            id: categoryColumn
                            Layout.fillWidth: true
                            spacing: 12
                            
                            property string categoryName: modelData
                            
                            // 分类标题
                            Text {
                                text: categoryColumn.categoryName
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333"
                                Layout.leftMargin: 5
                            }
                            
                            // 表格容器
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: permissionData[categoryColumn.categoryName].length * 42 + 40
                                color: "white"
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 6
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    spacing: 0
                                    
                                    // 表头
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#0078d4"
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 15
                                            anchors.rightMargin: 15
                                            spacing: 15
                                            
                                            Text {
                                                text: I18n.t("permissionName") || "权限名称"
                                                Layout.preferredWidth: 300
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("permissionDesc") || "权限描述"
                                                Layout.fillWidth: true
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("operation") || "操作"
                                                Layout.preferredWidth: 80
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                    
                                    // 表格内容
                                    Column {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        
                                        Repeater {
                                            model: permissionData[categoryColumn.categoryName]
                                            
                                            Rectangle {
                                                width: parent.width
                                                height: 42
                                                color: index % 2 === 0 ? "#ffffff" : "#f8f8f8"
                                                
                                                // 鼠标悬停效果
                                                Rectangle {
                                                    anchors.fill: parent
                                                    color: "#e8f4fd"
                                                    opacity: mouseArea.containsMouse ? 1 : 0
                                                    Behavior on opacity { NumberAnimation { duration: 100 } }
                                                }
                                                
                                                MouseArea {
                                                    id: mouseArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                }
                                                
                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 15
                                                    anchors.rightMargin: 15
                                                    spacing: 15
                                                    
                                                    // 权限名称（也是权限字符串）
                                                    Text {
                                                        text: modelData.permission
                                                        Layout.preferredWidth: 300
                                                        font.pixelSize: 12
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#0078d4"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 权限描述
                                                    Text {
                                                        text: modelData.desc
                                                        Layout.fillWidth: true
                                                        font.pixelSize: 12
                                                        color: "#666"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 复制按钮
                                                    Button {
                                                        Layout.preferredWidth: 70
                                                        Layout.preferredHeight: 28
                                                        text: I18n.t("copy") || "复制"
                                                        onClicked: {
                                                            copyToClipboard(modelData.permission)
                                                        }
                                                        background: Rectangle {
                                                            color: parent.hovered ? "#005a9e" : "#0078d4"
                                                            radius: 5
                                                            border.color: parent.hovered ? "#004578" : "#006cbd"
                                                            border.width: 1
                                                            Behavior on color {
                                                                ColorAnimation { duration: 150 }
                                                            }
                                                        }
                                                        contentItem: Text {
                                                            text: parent.text
                                                            font.pixelSize: 12
                                                            font.bold: true
                                                            color: "white"
                                                            horizontalAlignment: Text.AlignHCenter
                                                            verticalAlignment: Text.AlignVCenter
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 复制反馈提示
    Rectangle {
        id: copyFeedback
        anchors.centerIn: parent
        width: 120
        height: 50
        color: "#333333"
        radius: 6
        opacity: 0
        visible: opacity > 0
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copied") || "已复制"
            font.pixelSize: 14
            color: "white"
        }
        
        function show() {
            opacity = 1
            feedbackTimer.start()
        }
        
        Timer {
            id: feedbackTimer
            interval: 1500
            onTriggered: copyFeedback.opacity = 0
        }
    }
    
    TextArea {
        id: clipboardArea
        visible: false
    }
}

