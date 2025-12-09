import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "i18n/i18n.js" as I18n

ApplicationWindow {
    id: mainWindow
    width: 1150
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    title: qsTr(I18n.t("appTitle"))
    
    // 当前选中的导航索引
    property int currentNavIndex: 1
    
    // 导航项数据
    property var navItems: [
        {text: "工具说明", desc: "软件介绍与帮助", icon: ""},
        {text: "编码工具", desc: "编码转换相关工具", icon: ""},
        {text: "字符工具", desc: "字符处理相关工具", icon: ""},
        {text: "开发工具", desc: "开发辅助相关工具", icon: ""},
        {text: "加密工具", desc: "加密解密相关工具", icon: ""},
        {text: "随机工具", desc: "随机生成相关工具", icon: ""},
        {text: "网络工具", desc: "网络测试相关工具", icon: ""},
        {text: "硬件工具", desc: "硬件信息相关工具", icon: ""}
    ]
    
    // 各分类的工具数据
    property var toolsData: {
        0: [ // 工具说明
            {title: "关于蜂巢", subtitle: "软件介绍与说明"},
            {title: "使用帮助", subtitle: "功能使用指南"},
            {title: "更新日志", subtitle: "版本更新记录"},
            {title: "反馈建议", subtitle: "问题反馈与建议"},
            {title: "软件设置", subtitle: "修改本软件设置"}
        ],
        1: [ // 编码工具
            {title: "条形码生成", subtitle: "数字生成条形码"},
            {title: "二维码码生成", subtitle: "文字生成二维码"},
            {title: "时间戳转换", subtitle: "时间戳与日期互转"},
            {title: "颜色值转换", subtitle: "颜色编码转换"},
            {title: "中文转Unicode", subtitle: "中文与Unicode互转"},
            {title: "ASCII码表", subtitle: "ASCII码对照表"},
            {title: "进制转换", subtitle: "数字进制相互转换"},
            {title: "补码转换", subtitle: "原码反码补码转换"}
        ],
        2: [ // 字符工具
            {title: "字符串去空格", subtitle: "去除字符串中的空格"},
            {title: "字符串去回车", subtitle: "去除字符串中的回车"},
            {title: "去除空格回车", subtitle: "去除文中空格和回车"},
            {title: "替换与转义", subtitle: "替换指定字符"},
            {title: "字数统计", subtitle: "文本字符分析"},
            {title: "文本对比", subtitle: "比较文本差异"},
            {title: "正则测试", subtitle: "测试正则表达式"},
            {title: "大小写转换", subtitle: "文本大小写转换"}
        ],
        3: [ // 开发工具
            {title: "JSON格式化", subtitle: "将JSON格式化输出"},
            {title: "JSON转YAML", subtitle: "JSON与YAML转换"},
            {title: "屏幕取色器", subtitle: "拾取屏幕任意颜色"},
            {title: "颜色选择器", subtitle: "从色板中选择颜色"},
            {title: "常用HTML颜色", subtitle: "常用网页色系和色块"},
            {title: "回车转br标签", subtitle: "换行符转HTML标签"},
            {title: "常用浏览器UA", subtitle: "浏览器User-Agent"},
            {title: "Go交叉编译", subtitle: "跨平台编译参考"},
            {title: "htaccess转nginx", subtitle: "转换htaccess规则"},
            {title: "Manifest权限大全", subtitle: "Android权限对照表"},
            {title: "HTTP状态码", subtitle: "HTTP状态码大全"},
            {title: "Content-Type", subtitle: "MIME类型参考大全"},
            {title: "HTML特殊字符", subtitle: "HTML字符编解码"}
        ],
        4: [ // 加密工具
            {title: "Windows加密", subtitle: "Windows自带指令"},
            {title: "MD5加密", subtitle: "字符串转MD5"},
            {title: "SHA1加密", subtitle: "字符串转SHA1"},
            {title: "SHA256加密", subtitle: "字符串转SHA256"},
            {title: "密码强度分析", subtitle: "分析密码安全强度"}
        ],
        5: [ // 随机工具
            {title: "随机数字", subtitle: "生成随机数字"},
            {title: "随机字符串", subtitle: "生成随机字符串"},
            {title: "随机混合串", subtitle: "生成字母数字混合串"},
            {title: "随机MAC地址", subtitle: "生成网络设备MAC地址"},
            {title: "随机IPv4地址", subtitle: "生成随机IPv4地址"},
            {title: "随机IPv6地址", subtitle: "生成随机IPv6地址"},
            {title: "生成UUID", subtitle: "生成唯一标识符"}
        ],
        6: [ // 网络工具
            {title: "WebSocket测试", subtitle: "WebSocket测试"},
            {title: "RESTful测试", subtitle: "API接口测试"},
            {title: "MQTT监听", subtitle: "MQTT订阅监听"},
            {title: "MQTT广播", subtitle: "MQTT消息发布"},
            {title: "子网掩码计算器", subtitle: "IP地址与子网划分"},
            {title: "RTSP预览", subtitle: "实时视频流预览"}
        ],
        7: [ // 硬件工具
            {title: "寄存器寻址范围", subtitle: "不同位数寄存器范围"},
            {title: "电阻阻值计算", subtitle: "彩色环带电阻速查"},
            {title: "RISC-V指令集模块", subtitle: "RISC-V指令集模块名"},
            {title: "通用寄存器速查", subtitle: "各种芯片寄存器信息"},
            {title: "汇编速查", subtitle: "各种指令集汇编速查"}
        ]
    }
    
    // 计算卡片列数
    property int cardMinWidth: 220
    property int cardSpacing: 20
    property int contentMargin: 30
    property int sidebarWidth: 120
    property int availableWidth: mainWindow.width - sidebarWidth - contentMargin * 2
    property int cardColumns: Math.max(1, Math.floor((availableWidth + cardSpacing) / (cardMinWidth + cardSpacing)))
    property real cardWidth: (availableWidth - (cardColumns - 1) * cardSpacing) / cardColumns
    
    // 主容器
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // 左侧导航栏
        Rectangle {
            Layout.preferredWidth: sidebarWidth
            Layout.fillHeight: true
            color: "#f5f5f5"
            
            Column {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0
                
                // 导航项
                Repeater {
                    model: navItems
                    
                    Rectangle {
                        width: sidebarWidth
                        height: 50
                        color: currentNavIndex === index ? "#1976d2" : "transparent"
                        
                        // 左侧选中指示条
                        Rectangle {
                            width: 3
                            height: parent.height
                            color: "#1976d2"
                            visible: currentNavIndex === index
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.text
                            font.pixelSize: 14
                            color: currentNavIndex === index ? "white" : "#333"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentNavIndex = index
                            }
                        }
                    }
                }
            }
        }
        
        // 右侧内容区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // 顶部标题栏
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: "white"
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 30
                        anchors.rightMargin: 30
                        spacing: 20
                        
                        Text {
                            text: navItems[currentNavIndex].text
                            font.pixelSize: 20
                            font.bold: true
                        }
                        
                        Text {
                            text: navItems[currentNavIndex].desc
                            font.pixelSize: 14
                            color: "#666"
                        }
                        
                        Item {
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // 工具卡片网格
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentWidth: availableWidth
                    
                    Flickable {
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: cardGrid.height + contentMargin * 2
                        boundsBehavior: Flickable.StopAtBounds
                        
                        GridLayout {
                            id: cardGrid
                            x: contentMargin
                            y: contentMargin
                            width: availableWidth
                            columns: cardColumns
                            columnSpacing: cardSpacing
                            rowSpacing: cardSpacing
                            
                            // 工具卡片
                            Repeater {
                                model: toolsData[currentNavIndex] || []
                                
                                Rectangle {
                                    Layout.preferredWidth: cardWidth
                                    Layout.preferredHeight: 120
                                    Layout.fillWidth: true
                                    color: "white"
                                    border.color: hovered ? "#1976d2" : "#e0e0e0"
                                    border.width: hovered ? 2 : 1
                                    radius: 8
                                    
                                    property bool hovered: false
                                    
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData.title
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: "#333"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        
                                        Text {
                                            text: modelData.subtitle
                                            font.pixelSize: 13
                                            color: "#1976d2"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        
                                        onEntered: parent.hovered = true
                                        onExited: parent.hovered = false
                                        
                                        onClicked: {
                                            console.log("Clicked:", modelData.title)
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
