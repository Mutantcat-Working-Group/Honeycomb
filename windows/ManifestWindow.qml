import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: manifestWindow
    width: 1100
    height: 700
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolManifest")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // Android权限数据
    property var permissionData: {
        "网络权限": [
            {name: "INTERNET", desc: "允许应用程序打开网络套接字", permission: "android.permission.INTERNET"},
            {name: "ACCESS_NETWORK_STATE", desc: "允许应用程序访问网络连接信息", permission: "android.permission.ACCESS_NETWORK_STATE"},
            {name: "ACCESS_WIFI_STATE", desc: "允许应用程序访问WiFi网络状态信息", permission: "android.permission.ACCESS_WIFI_STATE"},
            {name: "CHANGE_WIFI_STATE", desc: "允许应用程序改变WiFi连接状态", permission: "android.permission.CHANGE_WIFI_STATE"},
            {name: "CHANGE_NETWORK_STATE", desc: "允许应用程序改变网络连接状态", permission: "android.permission.CHANGE_NETWORK_STATE"}
        ],
        "存储权限": [
            {name: "READ_EXTERNAL_STORAGE", desc: "允许应用程序读取外部存储", permission: "android.permission.READ_EXTERNAL_STORAGE"},
            {name: "WRITE_EXTERNAL_STORAGE", desc: "允许应用程序写入外部存储", permission: "android.permission.WRITE_EXTERNAL_STORAGE"},
            {name: "READ_MEDIA_IMAGES", desc: "允许应用程序读取媒体图片（Android 13+）", permission: "android.permission.READ_MEDIA_IMAGES"},
            {name: "READ_MEDIA_VIDEO", desc: "允许应用程序读取媒体视频（Android 13+）", permission: "android.permission.READ_MEDIA_VIDEO"},
            {name: "READ_MEDIA_AUDIO", desc: "允许应用程序读取媒体音频（Android 13+）", permission: "android.permission.READ_MEDIA_AUDIO"},
            {name: "MANAGE_EXTERNAL_STORAGE", desc: "允许应用程序管理所有文件访问权限（Android 11+）", permission: "android.permission.MANAGE_EXTERNAL_STORAGE"}
        ],
        "位置权限": [
            {name: "ACCESS_FINE_LOCATION", desc: "允许应用程序访问精确位置", permission: "android.permission.ACCESS_FINE_LOCATION"},
            {name: "ACCESS_COARSE_LOCATION", desc: "允许应用程序访问大致位置", permission: "android.permission.ACCESS_COARSE_LOCATION"},
            {name: "ACCESS_BACKGROUND_LOCATION", desc: "允许应用程序在后台访问位置（Android 10+）", permission: "android.permission.ACCESS_BACKGROUND_LOCATION"}
        ],
        "相机权限": [
            {name: "CAMERA", desc: "允许应用程序使用相机设备", permission: "android.permission.CAMERA"},
            {name: "RECORD_AUDIO", desc: "允许应用程序录制音频", permission: "android.permission.RECORD_AUDIO"}
        ],
        "联系人权限": [
            {name: "READ_CONTACTS", desc: "允许应用程序读取用户联系人数据", permission: "android.permission.READ_CONTACTS"},
            {name: "WRITE_CONTACTS", desc: "允许应用程序写入用户联系人数据", permission: "android.permission.WRITE_CONTACTS"},
            {name: "GET_ACCOUNTS", desc: "允许应用程序访问账户列表", permission: "android.permission.GET_ACCOUNTS"}
        ],
        "电话权限": [
            {name: "CALL_PHONE", desc: "允许应用程序拨打电话", permission: "android.permission.CALL_PHONE"},
            {name: "READ_PHONE_STATE", desc: "允许应用程序读取电话状态", permission: "android.permission.READ_PHONE_STATE"},
            {name: "READ_PHONE_NUMBERS", desc: "允许应用程序读取电话号码（Android 8.0+）", permission: "android.permission.READ_PHONE_NUMBERS"},
            {name: "ANSWER_PHONE_CALLS", desc: "允许应用程序接听电话（Android 8.0+）", permission: "android.permission.ANSWER_PHONE_CALLS"},
            {name: "READ_CALL_LOG", desc: "允许应用程序读取通话记录", permission: "android.permission.READ_CALL_LOG"},
            {name: "WRITE_CALL_LOG", desc: "允许应用程序写入通话记录", permission: "android.permission.WRITE_CALL_LOG"}
        ],
        "短信权限": [
            {name: "SEND_SMS", desc: "允许应用程序发送短信", permission: "android.permission.SEND_SMS"},
            {name: "RECEIVE_SMS", desc: "允许应用程序接收短信", permission: "android.permission.RECEIVE_SMS"},
            {name: "READ_SMS", desc: "允许应用程序读取短信", permission: "android.permission.READ_SMS"},
            {name: "RECEIVE_WAP_PUSH", desc: "允许应用程序接收WAP推送消息", permission: "android.permission.RECEIVE_WAP_PUSH"}
        ],
        "日历权限": [
            {name: "READ_CALENDAR", desc: "允许应用程序读取用户日历数据", permission: "android.permission.READ_CALENDAR"},
            {name: "WRITE_CALENDAR", desc: "允许应用程序写入用户日历数据", permission: "android.permission.WRITE_CALENDAR"}
        ],
        "传感器权限": [
            {name: "BODY_SENSORS", desc: "允许应用程序访问身体传感器数据（Android 6.0+）", permission: "android.permission.BODY_SENSORS"},
            {name: "ACTIVITY_RECOGNITION", desc: "允许应用程序识别用户活动（Android 10+）", permission: "android.permission.ACTIVITY_RECOGNITION"}
        ],
        "系统权限": [
            {name: "SYSTEM_ALERT_WINDOW", desc: "允许应用程序显示系统级窗口", permission: "android.permission.SYSTEM_ALERT_WINDOW"},
            {name: "REQUEST_INSTALL_PACKAGES", desc: "允许应用程序请求安装包（Android 8.0+）", permission: "android.permission.REQUEST_INSTALL_PACKAGES"},
            {name: "WRITE_SETTINGS", desc: "允许应用程序修改系统设置", permission: "android.permission.WRITE_SETTINGS"},
            {name: "VIBRATE", desc: "允许应用程序控制振动器", permission: "android.permission.VIBRATE"},
            {name: "WAKE_LOCK", desc: "允许应用程序防止设备休眠", permission: "android.permission.WAKE_LOCK"},
            {name: "RECEIVE_BOOT_COMPLETED", desc: "允许应用程序接收系统启动完成广播", permission: "android.permission.RECEIVE_BOOT_COMPLETED"}
        ],
        "通知权限": [
            {name: "POST_NOTIFICATIONS", desc: "允许应用程序发送通知（Android 13+）", permission: "android.permission.POST_NOTIFICATIONS"}
        ],
        "其他权限": [
            {name: "BLUETOOTH", desc: "允许应用程序连接到已配对的蓝牙设备", permission: "android.permission.BLUETOOTH"},
            {name: "BLUETOOTH_ADMIN", desc: "允许应用程序发现和配对蓝牙设备", permission: "android.permission.BLUETOOTH_ADMIN"},
            {name: "NFC", desc: "允许应用程序通过NFC进行I/O操作", permission: "android.permission.NFC"},
            {name: "ACCESS_NOTIFICATION_POLICY", desc: "允许应用程序访问通知策略", permission: "android.permission.ACCESS_NOTIFICATION_POLICY"},
            {name: "BIND_ACCESSIBILITY_SERVICE", desc: "允许应用程序绑定到辅助功能服务", permission: "android.permission.BIND_ACCESSIBILITY_SERVICE"}
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
                    text: I18n.t("toolManifest")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolManifestDesc") || "Manifest参照表"
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
                    width: manifestWindow.width - 50
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
                                                Layout.preferredWidth: 200
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
                                                text: I18n.t("permissionString") || "权限字符串"
                                                Layout.preferredWidth: 300
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
                                                    
                                                    // 权限名称
                                                    Text {
                                                        text: modelData.name
                                                        Layout.preferredWidth: 200
                                                        font.pixelSize: 13
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#333"
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
                                                    
                                                    // 权限字符串
                                                    Text {
                                                        text: modelData.permission
                                                        Layout.preferredWidth: 300
                                                        font.pixelSize: 12
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#0078d4"
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

