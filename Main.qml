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
    
    // 窗口组件映射
    property var windowComponents: ({
        "关于蜂巢": "qrc:/qt/qml/Honeycomb/windows/AboutWindow.qml",
        "使用帮助": "qrc:/qt/qml/Honeycomb/windows/HelpWindow.qml",
        "更新日志": "qrc:/qt/qml/Honeycomb/windows/ChangelogWindow.qml",
        "反馈建议": "qrc:/qt/qml/Honeycomb/windows/FeedbackWindow.qml",
        "随机数字": "qrc:/qt/qml/Honeycomb/windows/RandomNumberWindow.qml",
        "随机字符串": "qrc:/qt/qml/Honeycomb/windows/RandomLetterWindow.qml",
        "随机混合串": "qrc:/qt/qml/Honeycomb/windows/RandomMixedWindow.qml",
        "条形码生成": "qrc:/qt/qml/Honeycomb/windows/BarcodeWindow.qml",
        "二维码生成": "qrc:/qt/qml/Honeycomb/windows/QRCodeWindow.qml",
        "时间戳转换": "qrc:/qt/qml/Honeycomb/windows/TimestampWindow.qml",
        "颜色值转换": "qrc:/qt/qml/Honeycomb/windows/ColorConverterWindow.qml",
        "中文转Unicode": "qrc:/qt/qml/Honeycomb/windows/UnicodeWindow.qml",
        "ASCII码表": "qrc:/qt/qml/Honeycomb/windows/AsciiTableWindow.qml",
        "进制转换": "qrc:/qt/qml/Honeycomb/windows/RadixWindow.qml",
        "补码转换": "qrc:/qt/qml/Honeycomb/windows/ComplementWindow.qml",
        "字符串去空格": "qrc:/qt/qml/Honeycomb/windows/TrimSpaceWindow.qml",
        "字符串去回车": "qrc:/qt/qml/Honeycomb/windows/TrimNewlineWindow.qml",
        "去除空格回车": "qrc:/qt/qml/Honeycomb/windows/TrimAllWindow.qml",
        "替换与转义": "qrc:/qt/qml/Honeycomb/windows/ReplaceWindow.qml",
        "字数统计": "qrc:/qt/qml/Honeycomb/windows/WordCountWindow.qml",
        "文本对比": "qrc:/qt/qml/Honeycomb/windows/TextDiffWindow.qml",
        "正则测试": "qrc:/qt/qml/Honeycomb/windows/RegexWindow.qml",
        "大小写转换": "qrc:/qt/qml/Honeycomb/windows/CaseConvertWindow.qml",
        "JSON格式化": "qrc:/qt/qml/Honeycomb/windows/JsonFormatWindow.qml",
        "JSON转YAML": "qrc:/qt/qml/Honeycomb/windows/JsonYamlWindow.qml",
        "屏幕取色器": "qrc:/qt/qml/Honeycomb/windows/ColorPickerWindow.qml",
        "颜色选择器": "qrc:/qt/qml/Honeycomb/windows/ColorSelectorWindow.qml",
        "常用HTML颜色": "qrc:/qt/qml/Honeycomb/windows/HtmlColorWindow.qml",
        "回车转br标签": "qrc:/qt/qml/Honeycomb/windows/BrTagWindow.qml",
        "常用浏览器UA": "qrc:/qt/qml/Honeycomb/windows/UserAgentWindow.qml",
        "Go交叉编译": "qrc:/qt/qml/Honeycomb/windows/GoCrossWindow.qml",
        "htaccess转nginx": "qrc:/qt/qml/Honeycomb/windows/HtaccessNginxWindow.qml",
        "Android权限": "qrc:/qt/qml/Honeycomb/windows/ManifestWindow.qml",
        "Harmony权限": "qrc:/qt/qml/Honeycomb/windows/HarmonyPermissionWindow.qml",
        "HTTP状态码": "qrc:/qt/qml/Honeycomb/windows/HttpStatusWindow.qml"
    })
    
    // 存储已打开的窗口引用，防止被垃圾回收
    property var openedWindows: []
    
    // 打开工具窗口的函数
    function openToolWindow(toolKey) {
        var componentPath = windowComponents[toolKey]
        if (componentPath) {
            var component = Qt.createComponent(componentPath)
            if (component.status === Component.Ready) {
                // 使用 null 作为父级，让窗口在任务栏显示为独立窗口
                var window = component.createObject(null)
                if (window) {
                    // 保存引用防止被垃圾回收
                    openedWindows.push(window)
                    // 窗口关闭时从列表移除并销毁
                    window.closing.connect(function() {
                        var idx = openedWindows.indexOf(window)
                        if (idx !== -1) {
                            openedWindows.splice(idx, 1)
                        }
                        window.destroy()
                    })
                    window.show()
                }
            } else if (component.status === Component.Error) {
                console.log("Error creating window:", component.errorString())
            }
        } else {
            console.log("No window component for:", toolKey)
        }
    }
    
    // 导航项数据
    property var navItems: [
        {text: I18n.t("navToolInfo"), desc: I18n.t("navToolInfoDesc"), icon: ""},
        {text: I18n.t("navEncode"), desc: I18n.t("navEncodeDesc"), icon: ""},
        {text: I18n.t("navString"), desc: I18n.t("navStringDesc"), icon: ""},
        {text: I18n.t("navDev"), desc: I18n.t("navDevDesc"), icon: ""},
        {text: I18n.t("navEncrypt"), desc: I18n.t("navEncryptDesc"), icon: ""},
        {text: I18n.t("navRandom"), desc: I18n.t("navRandomDesc"), icon: ""},
        {text: I18n.t("navNetwork"), desc: I18n.t("navNetworkDesc"), icon: ""},
        {text: I18n.t("navHardware"), desc: I18n.t("navHardwareDesc"), icon: ""}
    ]
    
    // 各分类的工具数据
    property var toolsData: {
        0: [ // 工具说明
            {title: I18n.t("toolAbout"), subtitle: I18n.t("toolAboutDesc"), key: "关于蜂巢"},
            {title: I18n.t("toolHelp"), subtitle: I18n.t("toolHelpDesc"), key: "使用帮助"},
            {title: I18n.t("toolChangelog"), subtitle: I18n.t("toolChangelogDesc"), key: "更新日志"},
            {title: I18n.t("toolFeedback"), subtitle: I18n.t("toolFeedbackDesc"), key: "反馈建议"},
            {title: I18n.t("toolSettings"), subtitle: I18n.t("toolSettingsDesc"), key: "软件设置"}
        ],
        1: [ // 编码工具
            {title: I18n.t("toolBarcode"), subtitle: I18n.t("toolBarcodeDesc"), key: "条形码生成"},
            {title: I18n.t("toolQrcode"), subtitle: I18n.t("toolQrcodeDesc"), key: "二维码生成"},
            {title: I18n.t("toolTimestamp"), subtitle: I18n.t("toolTimestampDesc"), key: "时间戳转换"},
            {title: I18n.t("toolColor"), subtitle: I18n.t("toolColorDesc"), key: "颜色值转换"},
            {title: I18n.t("toolUnicode"), subtitle: I18n.t("toolUnicodeDesc"), key: "中文转Unicode"},
            {title: I18n.t("toolAscii"), subtitle: I18n.t("toolAsciiDesc"), key: "ASCII码表"},
            {title: I18n.t("toolRadix"), subtitle: I18n.t("toolRadixDesc"), key: "进制转换"},
            {title: I18n.t("toolComplement"), subtitle: I18n.t("toolComplementDesc"), key: "补码转换"}
        ],
        2: [ // 字符工具
            {title: I18n.t("toolTrimSpace"), subtitle: I18n.t("toolTrimSpaceDesc"), key: "字符串去空格"},
            {title: I18n.t("toolTrimNewline"), subtitle: I18n.t("toolTrimNewlineDesc"), key: "字符串去回车"},
            {title: I18n.t("toolTrimAll"), subtitle: I18n.t("toolTrimAllDesc"), key: "去除空格回车"},
            {title: I18n.t("toolReplace"), subtitle: I18n.t("toolReplaceDesc"), key: "替换与转义"},
            {title: I18n.t("toolWordCount"), subtitle: I18n.t("toolWordCountDesc"), key: "字数统计"},
            {title: I18n.t("toolTextDiff"), subtitle: I18n.t("toolTextDiffDesc"), key: "文本对比"},
            {title: I18n.t("toolRegex"), subtitle: I18n.t("toolRegexDesc"), key: "正则测试"},
            {title: I18n.t("toolCase"), subtitle: I18n.t("toolCaseDesc"), key: "大小写转换"}
        ],
        3: [ // 开发工具
            {title: I18n.t("toolJsonFormat"), subtitle: I18n.t("toolJsonFormatDesc"), key: "JSON格式化"},
            {title: I18n.t("toolJsonYaml"), subtitle: I18n.t("toolJsonYamlDesc"), key: "JSON转YAML"},
            {title: I18n.t("toolColorPicker"), subtitle: I18n.t("toolColorPickerDesc"), key: "屏幕取色器"},
            {title: I18n.t("toolColorSelect"), subtitle: I18n.t("toolColorSelectDesc"), key: "颜色选择器"},
            {title: I18n.t("toolHtmlColor"), subtitle: I18n.t("toolHtmlColorDesc"), key: "常用HTML颜色"},
            {title: I18n.t("toolBrTag"), subtitle: I18n.t("toolBrTagDesc"), key: "回车转br标签"},
            {title: I18n.t("toolUserAgent"), subtitle: I18n.t("toolUserAgentDesc"), key: "常用浏览器UA"},
            {title: I18n.t("toolGoCross"), subtitle: I18n.t("toolGoCrossDesc"), key: "Go交叉编译"},
            {title: I18n.t("toolHtaccess"), subtitle: I18n.t("toolHtaccessDesc"), key: "htaccess转nginx"},
            {title: I18n.t("toolManifest"), subtitle: I18n.t("toolManifestDesc"), key: "Android权限"},
            {title: I18n.t("toolHarmonyPermission"), subtitle: I18n.t("toolHarmonyPermissionDesc"), key: "Harmony权限"},
            {title: I18n.t("toolHttpStatus"), subtitle: I18n.t("toolHttpStatusDesc"), key: "HTTP状态码"},
            {title: I18n.t("toolContentType"), subtitle: I18n.t("toolContentTypeDesc"), key: "Content-Type"},
            {title: I18n.t("toolHtmlChar"), subtitle: I18n.t("toolHtmlCharDesc"), key: "HTML特殊字符"}
        ],
        4: [ // 加密工具
            {title: I18n.t("toolWinEncrypt"), subtitle: I18n.t("toolWinEncryptDesc"), key: "Windows加密"},
            {title: I18n.t("toolMd5"), subtitle: I18n.t("toolMd5Desc"), key: "MD5加密"},
            {title: I18n.t("toolSha1"), subtitle: I18n.t("toolSha1Desc"), key: "SHA1加密"},
            {title: I18n.t("toolSha256"), subtitle: I18n.t("toolSha256Desc"), key: "SHA256加密"},
            {title: I18n.t("toolPwdStrength"), subtitle: I18n.t("toolPwdStrengthDesc"), key: "密码强度分析"}
        ],
        5: [ // 随机工具
            {title: I18n.t("toolRandomNum"), subtitle: I18n.t("toolRandomNumDesc"), key: "随机数字"},
            {title: I18n.t("toolRandomStr"), subtitle: I18n.t("toolRandomStrDesc"), key: "随机字符串"},
            {title: I18n.t("toolRandomMix"), subtitle: I18n.t("toolRandomMixDesc"), key: "随机混合串"},
            {title: I18n.t("toolRandomMac"), subtitle: I18n.t("toolRandomMacDesc"), key: "随机MAC地址"},
            {title: I18n.t("toolRandomIpv4"), subtitle: I18n.t("toolRandomIpv4Desc"), key: "随机IPv4地址"},
            {title: I18n.t("toolRandomIpv6"), subtitle: I18n.t("toolRandomIpv6Desc"), key: "随机IPv6地址"},
            {title: I18n.t("toolUuid"), subtitle: I18n.t("toolUuidDesc"), key: "生成UUID"}
        ],
        6: [ // 网络工具
            {title: I18n.t("toolWebsocket"), subtitle: I18n.t("toolWebsocketDesc"), key: "WebSocket测试"},
            {title: I18n.t("toolRestful"), subtitle: I18n.t("toolRestfulDesc"), key: "RESTful测试"},
            {title: I18n.t("toolMqttSub"), subtitle: I18n.t("toolMqttSubDesc"), key: "MQTT监听"},
            {title: I18n.t("toolMqttPub"), subtitle: I18n.t("toolMqttPubDesc"), key: "MQTT广播"},
            {title: I18n.t("toolSubnet"), subtitle: I18n.t("toolSubnetDesc"), key: "子网掩码计算器"},
            {title: I18n.t("toolRtsp"), subtitle: I18n.t("toolRtspDesc"), key: "RTSP预览"}
        ],
        7: [ // 硬件工具
            {title: I18n.t("toolRegister"), subtitle: I18n.t("toolRegisterDesc"), key: "寄存器寻址范围"},
            {title: I18n.t("toolResistor"), subtitle: I18n.t("toolResistorDesc"), key: "电阻阻值计算"},
            {title: I18n.t("toolRiscv"), subtitle: I18n.t("toolRiscvDesc"), key: "RISC-V指令集模块"},
            {title: I18n.t("toolRegisterRef"), subtitle: I18n.t("toolRegisterRefDesc"), key: "通用寄存器速查"},
            {title: I18n.t("toolAsm"), subtitle: I18n.t("toolAsmDesc"), key: "汇编速查"}
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
                                            openToolWindow(modelData.key)
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
