import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: httpStatusWindow
    width: 800
    height: 600
    minimumWidth: 600
    minimumHeight: 500
    title: I18n.t("toolHttpStatus")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // HTTP状态码数据
    property var httpStatusData: [
        // 1xx 信息响应
        { code: "100", name: "Continue", desc: I18n.t("httpStatus100") || "继续请求" },
        { code: "101", name: "Switching Protocols", desc: I18n.t("httpStatus101") || "切换协议" },
        { code: "102", name: "Processing", desc: I18n.t("httpStatus102") || "处理中" },
        { code: "103", name: "Early Hints", desc: I18n.t("httpStatus103") || "早期提示" },
        
        // 2xx 成功响应
        { code: "200", name: "OK", desc: I18n.t("httpStatus200") || "请求成功" },
        { code: "201", name: "Created", desc: I18n.t("httpStatus201") || "已创建" },
        { code: "202", name: "Accepted", desc: I18n.t("httpStatus202") || "已接受" },
        { code: "203", name: "Non-Authoritative Information", desc: I18n.t("httpStatus203") || "非权威信息" },
        { code: "204", name: "No Content", desc: I18n.t("httpStatus204") || "无内容" },
        { code: "205", name: "Reset Content", desc: I18n.t("httpStatus205") || "重置内容" },
        { code: "206", name: "Partial Content", desc: I18n.t("httpStatus206") || "部分内容" },
        { code: "207", name: "Multi-Status", desc: I18n.t("httpStatus207") || "多状态" },
        { code: "208", name: "Already Reported", desc: I18n.t("httpStatus208") || "已报告" },
        { code: "226", name: "IM Used", desc: I18n.t("httpStatus226") || "IM已使用" },
        
        // 3xx 重定向响应
        { code: "300", name: "Multiple Choices", desc: I18n.t("httpStatus300") || "多种选择" },
        { code: "301", name: "Moved Permanently", desc: I18n.t("httpStatus301") || "永久移动" },
        { code: "302", name: "Found", desc: I18n.t("httpStatus302") || "临时移动" },
        { code: "303", name: "See Other", desc: I18n.t("httpStatus303") || "查看其他" },
        { code: "304", name: "Not Modified", desc: I18n.t("httpStatus304") || "未修改" },
        { code: "305", name: "Use Proxy", desc: I18n.t("httpStatus305") || "使用代理" },
        { code: "306", name: "unused", desc: I18n.t("httpStatus306") || "未使用" },
        { code: "307", name: "Temporary Redirect", desc: I18n.t("httpStatus307") || "临时重定向" },
        { code: "308", name: "Permanent Redirect", desc: I18n.t("httpStatus308") || "永久重定向" },
        
        // 4xx 客户端错误响应
        { code: "400", name: "Bad Request", desc: I18n.t("httpStatus400") || "错误请求" },
        { code: "401", name: "Unauthorized", desc: I18n.t("httpStatus401") || "未授权" },
        { code: "402", name: "Payment Required", desc: I18n.t("httpStatus402") || "需要付款" },
        { code: "403", name: "Forbidden", desc: I18n.t("httpStatus403") || "禁止访问" },
        { code: "404", name: "Not Found", desc: I18n.t("httpStatus404") || "未找到" },
        { code: "405", name: "Method Not Allowed", desc: I18n.t("httpStatus405") || "方法不允许" },
        { code: "406", name: "Not Acceptable", desc: I18n.t("httpStatus406") || "不可接受" },
        { code: "407", name: "Proxy Authentication Required", desc: I18n.t("httpStatus407") || "需要代理认证" },
        { code: "408", name: "Request Timeout", desc: I18n.t("httpStatus408") || "请求超时" },
        { code: "409", name: "Conflict", desc: I18n.t("httpStatus409") || "冲突" },
        { code: "410", name: "Gone", desc: I18n.t("httpStatus410") || "已删除" },
        { code: "411", name: "Length Required", desc: I18n.t("httpStatus411") || "需要长度" },
        { code: "412", name: "Precondition Failed", desc: I18n.t("httpStatus412") || "前置条件失败" },
        { code: "413", name: "Payload Too Large", desc: I18n.t("httpStatus413") || "请求体过大" },
        { code: "414", name: "URI Too Long", desc: I18n.t("httpStatus414") || "URI过长" },
        { code: "415", name: "Unsupported Media Type", desc: I18n.t("httpStatus415") || "不支持的媒体类型" },
        { code: "416", name: "Range Not Satisfiable", desc: I18n.t("httpStatus416") || "范围不满足" },
        { code: "417", name: "Expectation Failed", desc: I18n.t("httpStatus417") || "期望失败" },
        { code: "418", name: "I'm a teapot", desc: I18n.t("httpStatus418") || "我是茶壶" },
        { code: "421", name: "Misdirected Request", desc: I18n.t("httpStatus421") || "误导请求" },
        { code: "422", name: "Unprocessable Entity", desc: I18n.t("httpStatus422") || "无法处理的实体" },
        { code: "423", name: "Locked", desc: I18n.t("httpStatus423") || "已锁定" },
        { code: "424", name: "Failed Dependency", desc: I18n.t("httpStatus424") || "依赖失败" },
        { code: "425", name: "Too Early", desc: I18n.t("httpStatus425") || "过早" },
        { code: "426", name: "Upgrade Required", desc: I18n.t("httpStatus426") || "需要升级" },
        { code: "428", name: "Precondition Required", desc: I18n.t("httpStatus428") || "需要前置条件" },
        { code: "429", name: "Too Many Requests", desc: I18n.t("httpStatus429") || "请求过多" },
        { code: "431", name: "Request Header Fields Too Large", desc: I18n.t("httpStatus431") || "请求头字段过大" },
        { code: "451", name: "Unavailable For Legal Reasons", desc: I18n.t("httpStatus451") || "因法律原因不可用" },
        
        // 5xx 服务器错误响应
        { code: "500", name: "Internal Server Error", desc: I18n.t("httpStatus500") || "内部服务器错误" },
        { code: "501", name: "Not Implemented", desc: I18n.t("httpStatus501") || "未实现" },
        { code: "502", name: "Bad Gateway", desc: I18n.t("httpStatus502") || "网关错误" },
        { code: "503", name: "Service Unavailable", desc: I18n.t("httpStatus503") || "服务不可用" },
        { code: "504", name: "Gateway Timeout", desc: I18n.t("httpStatus504") || "网关超时" },
        { code: "505", name: "HTTP Version Not Supported", desc: I18n.t("httpStatus505") || "HTTP版本不支持" },
        { code: "506", name: "Variant Also Negotiates", desc: I18n.t("httpStatus506") || "变体协商" },
        { code: "507", name: "Insufficient Storage", desc: I18n.t("httpStatus507") || "存储不足" },
        { code: "508", name: "Loop Detected", desc: I18n.t("httpStatus508") || "检测到循环" },
        { code: "510", name: "Not Extended", desc: I18n.t("httpStatus510") || "未扩展" },
        { code: "511", name: "Network Authentication Required", desc: I18n.t("httpStatus511") || "需要网络认证" }
    ]
    
    // 过滤后的数据
    property var filteredData: httpStatusData
    
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
                    text: I18n.t("toolHttpStatus")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolHttpStatusDesc")
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
            
            // 搜索框
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: I18n.t("search") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: I18n.t("httpStatusSearchPlaceholder") || "输入状态码或描述进行搜索..."
                    
                    background: Rectangle {
                        color: "white"
                        border.color: searchInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: searchInput.focus ? 2 : 1
                        radius: 4
                    }
                    
                    onTextChanged: {
                        filterData()
                    }
                }
                
                Button {
                    text: I18n.t("clearBtn")
                    visible: searchInput.text.length > 0
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#1976d2"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                        border.color: "#1976d2"
                        border.width: 1
                        radius: 4
                        implicitWidth: 60
                        implicitHeight: 36
                    }
                    
                    onClicked: {
                        searchInput.text = ""
                        filterData()
                    }
                }
            }
            
            // 状态码表格
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                clip: true
                
                // 表头 - 固定在顶部
                Rectangle {
                    id: tableHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 40
                    color: "#f5f5f5"
                    border.color: "#e0e0e0"
                    border.width: 1
                    z: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10
                        
                        Text {
                            text: I18n.t("httpStatusCode") || "状态码"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.preferredWidth: 80
                        }
                        
                        Text {
                            text: I18n.t("httpStatusName") || "名称"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.preferredWidth: 200
                        }
                        
                        Text {
                            text: I18n.t("httpStatusDesc") || "描述"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // 数据区域 - 可滚动
                ScrollView {
                    anchors.top: tableHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    clip: true
                    
                    Column {
                        width: parent.width
                        spacing: 0
                        
                        // 数据行
                        Repeater {
                            model: filteredData
                            
                            Rectangle {
                                width: parent.width
                                height: 45
                                color: index % 2 === 0 ? "white" : "#fafafa"
                                border.color: "#e0e0e0"
                                border.width: 1
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 15
                                    anchors.rightMargin: 15
                                    spacing: 10
                                    
                                    Text {
                                        text: modelData.code
                                        font.pixelSize: 14
                                        font.family: "Consolas, Monaco, monospace"
                                        font.bold: true
                                        color: getCodeColor(modelData.code)
                                        Layout.preferredWidth: 80
                                    }
                                    
                                    Text {
                                        text: modelData.name
                                        font.pixelSize: 13
                                        color: "#333"
                                        Layout.preferredWidth: 200
                                    }
                                    
                                    Text {
                                        text: modelData.desc
                                        font.pixelSize: 13
                                        color: "#666"
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    
                                    onEntered: {
                                        parent.color = "#e3f2fd"
                                    }
                                    
                                    onExited: {
                                        parent.color = index % 2 === 0 ? "white" : "#fafafa"
                                    }
                                    
                                    onClicked: {
                                        copyToClipboard(modelData.code + " - " + modelData.name + ": " + modelData.desc)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 根据状态码获取颜色
    function getCodeColor(code) {
        var num = parseInt(code)
        if (num >= 100 && num < 200) {
            return "#17a2b8" // 信息响应 - 蓝绿色
        } else if (num >= 200 && num < 300) {
            return "#28a745" // 成功响应 - 绿色
        } else if (num >= 300 && num < 400) {
            return "#ffc107" // 重定向响应 - 黄色
        } else if (num >= 400 && num < 500) {
            return "#dc3545" // 客户端错误 - 红色
        } else if (num >= 500 && num < 600) {
            return "#6f42c1" // 服务器错误 - 紫色
        }
        return "#333"
    }
    
    // 过滤数据
    function filterData() {
        var searchText = searchInput.text.toLowerCase()
        if (searchText === "") {
            filteredData = httpStatusData
            return
        }
        
        var result = []
        for (var i = 0; i < httpStatusData.length; i++) {
            var item = httpStatusData[i]
            if (item.code.toLowerCase().indexOf(searchText) !== -1 ||
                item.name.toLowerCase().indexOf(searchText) !== -1 ||
                item.desc.toLowerCase().indexOf(searchText) !== -1) {
                result.push(item)
            }
        }
        filteredData = result
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyNotification.show()
    }
    
    // 剪贴板区域
    TextArea {
        id: clipboardArea
        visible: false
    }
    
    // 复制通知
    Rectangle {
        id: copyNotification
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20
        width: 200
        height: 40
        color: "#333"
        radius: 20
        visible: false
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copySuccess") || "已复制到剪贴板"
            color: "white"
            font.pixelSize: 14
        }
        
        function show() {
            visible = true
            hideTimer.start()
        }
        
        Timer {
            id: hideTimer
            interval: 2000
            onTriggered: {
                copyNotification.visible = false
            }
        }
    }
}