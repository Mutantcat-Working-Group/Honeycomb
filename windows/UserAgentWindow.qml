import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: userAgentWindow
    width: 1100
    height: 700
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolUserAgent")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // User-Agent 数据
    property var uaData: {
        "Chrome浏览器": [
            {name: "Chrome 120 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"},
            {name: "Chrome 120 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"},
            {name: "Chrome 120 (Linux)", ua: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"},
            {name: "Chrome 119 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"},
            {name: "Chrome 118 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"}
        ],
        "Firefox浏览器": [
            {name: "Firefox 121 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"},
            {name: "Firefox 121 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0"},
            {name: "Firefox 121 (Linux)", ua: "Mozilla/5.0 (X11; Linux x86_64; rv:121.0) Gecko/20100101 Firefox/121.0"},
            {name: "Firefox 120 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:120.0) Gecko/20100101 Firefox/120.0"},
            {name: "Firefox 119 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:119.0) Gecko/20100101 Firefox/119.0"}
        ],
        "Safari浏览器": [
            {name: "Safari 17 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"},
            {name: "Safari 16 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15"},
            {name: "Safari 15 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6.6 Safari/605.1.15"},
            {name: "Safari (iOS 17)", ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"},
            {name: "Safari (iOS 16)", ua: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"}
        ],
        "Edge浏览器": [
            {name: "Edge 120 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"},
            {name: "Edge 119 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0"},
            {name: "Edge 118 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36 Edg/118.0.0.0"},
            {name: "Edge 120 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"},
            {name: "Edge 120 (Linux)", ua: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"}
        ],
        "移动设备浏览器": [
            {name: "Chrome Mobile (Android)", ua: "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"},
            {name: "Chrome Mobile (Android 12)", ua: "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"},
            {name: "Samsung Internet", ua: "Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/23.0 Chrome/115.0.0.0 Mobile Safari/537.36"},
            {name: "Opera Mobile", ua: "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 OPR/85.0.4341.75"},
            {name: "Firefox Mobile (Android)", ua: "Mozilla/5.0 (Android 13; Mobile; rv:121.0) Gecko/121.0 Firefox/121.0"}
        ],
        "搜索引擎爬虫": [
            {name: "Googlebot", ua: "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"},
            {name: "Bingbot", ua: "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"},
            {name: "Baiduspider", ua: "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)"},
            {name: "YandexBot", ua: "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)"},
            {name: "Slurp (Yahoo)", ua: "Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"},
            {name: "DuckDuckBot", ua: "Mozilla/5.0 (compatible; DuckDuckBot/1.0; +http://duckduckgo.com/duckduckbot.html)"}
        ],
        "其他浏览器": [
            {name: "Opera 105 (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 OPR/105.0.0.0"},
            {name: "Opera 105 (macOS)", ua: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 OPR/105.0.0.0"},
            {name: "Brave (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Brave/120.0.0.0"},
            {name: "Vivaldi (Windows)", ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Vivaldi/6.5.3206.63"},
            {name: "UC Browser (Android)", ua: "Mozilla/5.0 (Linux; U; Android 13; zh-cn) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/120.0.0.0 Mobile Safari/537.36 UCBrowser/15.0.0.0"}
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
                    text: I18n.t("toolUserAgent")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolUserAgentDesc") || "浏览器User-Agent"
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
                    width: userAgentWindow.width - 50
                    spacing: 25
                    
                    // 遍历每个分类
                    Repeater {
                        id: categoryRepeater
                        model: Object.keys(uaData)
                        
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
                                Layout.preferredHeight: uaData[categoryColumn.categoryName].length * 42 + 40
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
                                                text: I18n.t("browserName") || "浏览器名称"
                                                Layout.preferredWidth: 200
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("userAgent") || "User-Agent"
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
                                            model: uaData[categoryColumn.categoryName]
                                            
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
                                                    
                                                    // 浏览器名称
                                                    Text {
                                                        text: modelData.name
                                                        Layout.preferredWidth: 200
                                                        font.pixelSize: 13
                                                        color: "#333"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // User-Agent
                                                    Text {
                                                        text: modelData.ua
                                                        Layout.fillWidth: true
                                                        font.pixelSize: 12
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#666"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 复制按钮
                                                    Button {
                                                        Layout.preferredWidth: 70
                                                        Layout.preferredHeight: 28
                                                        text: I18n.t("copy") || "复制"
                                                        onClicked: {
                                                            copyToClipboard(modelData.ua)
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

