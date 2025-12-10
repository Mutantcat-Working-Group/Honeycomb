import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: timestampWindow
    width: 750
    height: 650
    minimumWidth: 650
    minimumHeight: 550
    title: I18n.t("toolTimestamp")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 当前系统时间（实时更新，仅用于显示）
    property double currentTimestamp: Date.now()
    
    // 当前选中的时间（用户可以修改，初始为打开时的时间）
    property double selectedTimestamp: Date.now()
    
    // 定时器更新当前系统时间显示
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            currentTimestamp = Date.now()
        }
    }
    
    // 格式化日期时间
    function formatDateTime(timestamp, format) {
        var date = new Date(timestamp)
        
        var year = date.getFullYear()
        var month = String(date.getMonth() + 1).padStart(2, '0')
        var day = String(date.getDate()).padStart(2, '0')
        var hours = String(date.getHours()).padStart(2, '0')
        var minutes = String(date.getMinutes()).padStart(2, '0')
        var seconds = String(date.getSeconds()).padStart(2, '0')
        var ms = String(date.getMilliseconds()).padStart(3, '0')
        
        switch(format) {
            case "iso":
                return date.toISOString()
            case "utc":
                return date.toUTCString()
            case "local":
                return date.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm:ss")
            case "date":
                return date.toLocaleDateString(Qt.locale(), "yyyy-MM-dd")
            case "time":
                return date.toLocaleTimeString(Qt.locale(), "HH:mm:ss")
            case "full":
                return year + "-" + month + "-" + day + " " + hours + ":" + minutes + ":" + seconds + "." + ms
            case "compact":
                return year + month + day + hours + minutes + seconds
            case "chinese":
                return year + "年" + month + "月" + day + "日 " + hours + "时" + minutes + "分" + seconds + "秒"
            default:
                return date.toString()
        }
    }
    
    // 从各种格式更新选中时间
    function updateFromFormat(value, format) {
        var timestamp = 0
        
        try {
            switch(format) {
                case "ms":
                    timestamp = parseInt(value)
                    break
                case "sec":
                    timestamp = parseInt(value) * 1000
                    break
                case "iso":
                case "utc":
                case "local":
                case "date":
                case "full":
                    timestamp = Date.parse(value)
                    break
            }
            
            if (!isNaN(timestamp) && timestamp > 0) {
                selectedTimestamp = timestamp
                return true
            }
        } catch(e) {
            console.log("Parse error:", e)
        }
        return false
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
    }
    
    TextArea {
        id: clipboardArea
        visible: false
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
                    text: I18n.t("toolTimestamp")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolTimestampDesc")
                    font.pixelSize: 13
                    color: "#666"
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 当前时间显示区
            Rectangle {
                Layout.fillWidth: true
                height: 100
                color: "#0078d4"
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15
                        
                        Column {
                            Layout.fillWidth: true
                            spacing: 4
                            
                            Text {
                                text: I18n.t("currentTime") || "当前时间"
                                font.pixelSize: 13
                                color: "#d9ffffff"
                            }
                            
                            Text {
                                text: formatDateTime(currentTimestamp, "local")
                                font.pixelSize: 20
                                font.bold: true
                                color: "white"
                                font.family: "Consolas, Microsoft YaHei"
                            }
                        }
                        
                        Button {
                            text: I18n.t("useCurrentTime") || "使用当前时间"
                            height: 36
                            onClicked: {
                                selectedTimestamp = currentTimestamp
                            }
                            background: Rectangle {
                                color: parent.hovered ? "#ffffff" : "#d9ffffff"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#0078d4"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                    
                    Text {
                        text: I18n.t("timestamp") + ": " + Math.floor(currentTimestamp)
                        font.pixelSize: 12
                        color: "#d9ffffff"
                        font.family: "Consolas, Microsoft YaHei"
                    }
                }
            }
            
            // 滚动区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: timestampWindow.width - 50
                    spacing: 12
                    
                    // 时间戳格式列表
                    TimestampItem {
                        label: I18n.t("timestampMs") || "毫秒时间戳"
                        value: Math.floor(selectedTimestamp).toString()
                        format: "ms"
                        desc: "1733820123456"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampSec") || "秒时间戳"
                        value: Math.floor(selectedTimestamp / 1000).toString()
                        format: "sec"
                        desc: "1733820123"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampISO") || "ISO 8601"
                        value: formatDateTime(selectedTimestamp, "iso")
                        format: "iso"
                        desc: "2024-12-10T12:00:00.000Z"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampUTC") || "UTC 时间"
                        value: formatDateTime(selectedTimestamp, "utc")
                        format: "utc"
                        desc: "Mon, 10 Dec 2024 12:00:00 GMT"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampLocal") || "本地时间"
                        value: formatDateTime(selectedTimestamp, "local")
                        format: "local"
                        desc: "2024-12-10 20:00:00"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampDate") || "日期"
                        value: formatDateTime(selectedTimestamp, "date")
                        format: "date"
                        desc: "2024-12-10"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampTime") || "时间"
                        value: formatDateTime(selectedTimestamp, "time")
                        format: "time"
                        desc: "20:00:00"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampFull") || "完整时间（含毫秒）"
                        value: formatDateTime(selectedTimestamp, "full")
                        format: "full"
                        desc: "2024-12-10 20:00:00.123"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampCompact") || "紧凑格式"
                        value: formatDateTime(selectedTimestamp, "compact")
                        format: "compact"
                        desc: "20241210200000"
                    }
                    
                    TimestampItem {
                        label: I18n.t("timestampChinese") || "中文格式"
                        value: formatDateTime(selectedTimestamp, "chinese")
                        format: "chinese"
                        desc: "2024年12月10日 20时00分00秒"
                    }
                    
                    Item { height: 10 }
                }
            }
        }
    }
    
    // 时间戳项组件
    component TimestampItem: Rectangle {
        property string label: ""
        property string value: ""
        property string format: ""
        property string desc: ""
        
        Layout.fillWidth: true
        height: 85
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 6
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: label
                    font.pixelSize: 13
                    font.bold: true
                    color: "#333"
                    Layout.preferredWidth: 140
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    color: "#f5f5f5"
                    border.color: inputArea.activeFocus ? "#0078d4" : "#d0d0d0"
                    border.width: 1
                    radius: 4
                    
                    TextInput {
                        id: inputArea
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: value
                        font.pixelSize: 13
                        font.family: "Consolas, Microsoft YaHei"
                        color: "#333"
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        
                        onEditingFinished: {
                            if (text !== value) {
                                updateFromFormat(text, format)
                            }
                        }
                    }
                }
                
                Button {
                    text: I18n.t("sync") || "同步"
                    width: 60
                    height: 32
                    onClicked: {
                        updateFromFormat(inputArea.text, format)
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#006cbd" : "#0078d4"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Button {
                    text: I18n.t("copy") || "复制"
                    width: 60
                    height: 32
                    onClicked: {
                        copyToClipboard(value)
                        text = I18n.t("copied") || "已复制"
                        copyResetTimer.start()
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                        radius: 4
                        border.color: "#ccc"
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 12
                        color: "#333"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    Timer {
                        id: copyResetTimer
                        interval: 1500
                        onTriggered: parent.text = I18n.t("copy") || "复制"
                    }
                }
            }
            
            Text {
                text: I18n.t("example") + ": " + desc
                font.pixelSize: 11
                color: "#999"
                Layout.fillWidth: true
            }
        }
    }
}
