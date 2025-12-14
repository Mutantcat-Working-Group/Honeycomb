import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: htmlColorWindow
    width: 900
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    title: I18n.t("toolHtmlColor")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // HTML颜色数据
    property var colorData: {
        "基础颜色": {
            "白色": "#FFFFFF",
            "黑色": "#000000",
            "灰色": "#808080",
            "深灰色": "#404040",
            "浅灰色": "#C0C0C0",
            "银白色": "#F5F5F5",
            "暗灰色": "#A9A9A9",
            "淡灰色": "#D3D3D3",
            "烟灰色": "#696969",
            "石板灰": "#708090"
        },
        "红色系": {
            "深红色": "#8B0000",
            "红色": "#FF0000",
            "橙红色": "#FF4500",
            "粉红色": "#FFC0CB",
            "浅粉红色": "#FFB6C1",
            "暗红色": "#DC143C",
            "淡红色": "#FF6347",
            "玫瑰红": "#FF69B4",
            "深粉红": "#FF1493",
            "浅珊瑚色": "#F08080",
            "印度红": "#CD5C5C",
            "火砖红": "#B22222"
        },
        "橙色系": {
            "橙色": "#FFA500",
            "深橙色": "#FF8C00",
            "浅橙色": "#FFE4B5",
            "珊瑚橙": "#FF7F50",
            "深橙红": "#FF4500",
            "浅橙黄": "#FFDAB9",
            "番茄红": "#FF6347",
            "金橙色": "#FF8C00",
            "浅桃色": "#FFE4E1"
        },
        "黄色系": {
            "黄色": "#FFFF00",
            "金黄色": "#FFD700",
            "浅黄色": "#FFFFE0",
            "柠檬色": "#FFFACD",
            "淡黄色": "#FFFF99",
            "深黄色": "#CCCC00",
            "卡其黄": "#F0E68C",
            "米黄色": "#F5DEB3",
            "象牙白": "#FFFFF0",
            "玉米色": "#FFF8DC"
        },
        "绿色系": {
            "深绿色": "#006400",
            "绿色": "#00FF00",
            "酸橙绿": "#32CD32",
            "浅绿色": "#90EE90",
            "薄荷绿": "#98FB98",
            "森林绿": "#228B22",
            "海绿色": "#2E8B57",
            "草绿色": "#7CFC00",
            "橄榄绿": "#808000",
            "深橄榄绿": "#556B2F",
            "黄绿色": "#ADFF2F",
            "春绿色": "#00FF7F",
            "青绿色": "#00CED1"
        },
        "蓝色系": {
            "深蓝色": "#00008B",
            "蓝色": "#0000FF",
            "天蓝色": "#87CEEB",
            "浅蓝色": "#ADD8E6",
            "海军蓝": "#000080",
            "钢蓝色": "#4682B4",
            "深天蓝": "#00BFFF",
            "淡蓝色": "#E0F6FF",
            "中蓝色": "#0000CD",
            "皇家蓝": "#4169E1",
            "粉蓝色": "#B0E0E6",
            "青蓝色": "#00FFFF",
            "深青色": "#008B8B"
        },
        "紫色系": {
            "紫色": "#800080",
            "紫罗兰": "#EE82EE",
            "浅紫色": "#DDA0DD",
            "靛蓝色": "#4B0082",
            "深紫色": "#8B008B",
            "淡紫色": "#E6E6FA",
            "中紫色": "#9370DB",
            "深紫罗兰": "#9400D3",
            "兰花紫": "#DA70D6",
            "暗紫色": "#663399"
        },
        "卡其色系": {
            "卡其色": "#C3B091",
            "深卡其布": "#BDB76B",
            "浅卡其布": "#F0E68C",
            "米色": "#F5F5DC",
            "浅黄褐色": "#FFE4C4",
            "小麦色": "#F5DEB3",
            "桃色": "#FFDAB9",
            "杏仁白": "#FFEBCD",
            "古董白": "#FAEBD7",
            "亚麻色": "#FAF0E6"
        },
        "棕色系": {
            "栗色": "#800000",
            "棕色": "#A52A2A",
            "深棕色": "#654321",
            "浅棕色": "#D2B48C",
            "沙棕色": "#F4A460",
            "巧克力色": "#D2691E",
            "深巧克力": "#7B3F00",
            "鞍棕色": "#8B4513",
            "赭色": "#CD853F",
            "秘鲁色": "#CD853F",
            "深棕色": "#8B4513",
            "浅棕色": "#DEB887"
        },
        "金属色": {
            "银色": "#C0C0C0",
            "金色": "#FFD700",
            "铜色": "#B87333",
            "青铜色": "#CD7F32",
            "深金色": "#B8860B",
            "浅金色": "#F0E68C",
            "古铜色": "#CD853F",
            "黄铜色": "#B5A642",
            "银灰色": "#C0C0C0",
            "暗金色": "#B8860B"
        }
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
                    text: I18n.t("toolHtmlColor")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolHtmlColorDesc") || "常用网页色系和色块"
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
            
            // 颜色列表区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: htmlColorWindow.width - 50
                    spacing: 20
                    
                    // 遍历每个颜色分类
                    Repeater {
                        id: categoryRepeater
                        model: Object.keys(colorData)
                        
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
                            
                            // 颜色块网格
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 7
                                columnSpacing: 12
                                rowSpacing: 12
                                
                                // 遍历该分类下的所有颜色
                                Repeater {
                                    id: colorRepeater
                                    model: Object.keys(colorData[categoryColumn.categoryName])
                                    
                                    // 单个颜色块
                                    Rectangle {
                                        Layout.preferredWidth: 110
                                        Layout.preferredHeight: 90
                                        color: "white"
                                        border.color: "#e0e0e0"
                                        border.width: 1
                                        radius: 6
                                        
                                        property string colorName: modelData
                                        property string colorValue: colorData[categoryColumn.categoryName][modelData]
                                        
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 4
                                            
                                            // 颜色块
                                            Rectangle {
                                                Layout.fillWidth: true
                                                Layout.preferredHeight: 40
                                                color: parent.parent.colorValue
                                                border.color: "#333"
                                                border.width: 1
                                                radius: 4
                                            }
                                            
                                            // 颜色名称
                                            Text {
                                                text: parent.parent.colorName
                                                font.pixelSize: 11
                                                color: "#333"
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                                elide: Text.ElideRight
                                            }
                                            
                                            // 颜色值
                                            Text {
                                                text: parent.parent.colorValue
                                                font.pixelSize: 10
                                                font.family: "Consolas, Microsoft YaHei"
                                                color: "#666"
                                                Layout.fillWidth: true
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                copyToClipboard(parent.colorValue)
                                                copyFeedback.show()
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
}

