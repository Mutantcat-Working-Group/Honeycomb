import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: htaccessNginxWindow
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 450
    title: I18n.t("toolHtaccess")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 转换函数
    function convertText() {
        var input = inputArea.text
        
        if (input.length === 0) {
            outputArea.text = ""
            return
        }
        
        var lines = input.split(/\r\n|\n|\r/)
        var result = []
        var i = 0
        var inRewriteRule = false
        var rewriteConditions = []
        
        while (i < lines.length) {
            var line = lines[i].trim()
            
            // 跳过空行和注释
            if (line.length === 0 || line.startsWith("#")) {
                if (line.startsWith("#")) {
                    result.push("    # " + line.substring(1).trim())
                } else {
                    result.push("")
                }
                i++
                continue
            }
            
            // RewriteEngine On
            if (line.match(/^RewriteEngine\s+On$/i)) {
                result.push("    # RewriteEngine On (nginx always enabled)")
                i++
                continue
            }
            
            // RewriteCond
            if (line.match(/^RewriteCond\s+/i)) {
                var condMatch = line.match(/^RewriteCond\s+%{([^}]+)}\s+(.+)$/i)
                if (condMatch) {
                    var condVar = condMatch[1].trim()
                    var condPattern = condMatch[2].trim()
                    rewriteConditions.push({var: condVar, pattern: condPattern})
                }
                i++
                continue
            }
            
            // RewriteRule
            if (line.match(/^RewriteRule\s+/i)) {
                var ruleMatch = line.match(/^RewriteRule\s+([^\s]+)\s+([^\s]+)(?:\s+\[(.+)\])?$/i)
                if (ruleMatch) {
                    var pattern = ruleMatch[1]
                    var substitution = ruleMatch[2]
                    var flags = ruleMatch[3] || ""
                    
                    // 转换RewriteRule为nginx rewrite
                    var nginxRule = convertRewriteRule(pattern, substitution, flags, rewriteConditions)
                    result.push(nginxRule)
                    rewriteConditions = [] // 清空条件
                }
                i++
                continue
            }
            
            // Redirect
            if (line.match(/^Redirect\s+/i)) {
                var redirectMatch = line.match(/^Redirect\s+(\d{3})?\s*([^\s]+)\s+(.+)$/i)
                if (redirectMatch) {
                    var status = redirectMatch[1] || "301"
                    var fromPath = redirectMatch[2]
                    var toUrl = redirectMatch[3]
                    result.push("    return " + status + " " + toUrl + ";")
                }
                i++
                continue
            }
            
            // RedirectMatch
            if (line.match(/^RedirectMatch\s+/i)) {
                var redirectMatchMatch = line.match(/^RedirectMatch\s+(\d{3})?\s*([^\s]+)\s+(.+)$/i)
                if (redirectMatchMatch) {
                    var status2 = redirectMatchMatch[1] || "301"
                    var pattern2 = redirectMatchMatch[2]
                    var toUrl2 = redirectMatchMatch[3]
                    var nginxPattern = convertApachePattern(pattern2)
                    result.push("    if ($uri ~ " + nginxPattern + ") {")
                    result.push("        return " + status2 + " " + toUrl2 + ";")
                    result.push("    }")
                }
                i++
                continue
            }
            
            // ErrorDocument
            if (line.match(/^ErrorDocument\s+/i)) {
                var errorMatch = line.match(/^ErrorDocument\s+(\d{3})\s+(.+)$/i)
                if (errorMatch) {
                    var errorCode = errorMatch[1]
                    var errorPage = errorMatch[2]
                    result.push("    error_page " + errorCode + " " + errorPage + ";")
                }
                i++
                continue
            }
            
            // DirectoryIndex
            if (line.match(/^DirectoryIndex\s+/i)) {
                var indexMatch = line.match(/^DirectoryIndex\s+(.+)$/i)
                if (indexMatch) {
                    var indexFiles = indexMatch[1].split(/\s+/)
                    result.push("    index " + indexFiles.join(" ") + ";")
                }
                i++
                continue
            }
            
            // Options
            if (line.match(/^Options\s+/i)) {
                result.push("    # Options directive (check nginx equivalent)")
                i++
                continue
            }
            
            // Allow/Deny
            if (line.match(/^(Allow|Deny)\s+/i)) {
                var allowDenyMatch = line.match(/^(Allow|Deny)\s+(.+)$/i)
                if (allowDenyMatch) {
                    var action = allowDenyMatch[1].toLowerCase()
                    var from = allowDenyMatch[2]
                    if (action === "allow") {
                        result.push("    allow " + from + ";")
                    } else {
                        result.push("    deny " + from + ";")
                    }
                }
                i++
                continue
            }
            
            // 其他规则，保留原样并添加注释
            result.push("    # " + line)
            i++
        }
        
        // 添加nginx server块结构
        var finalResult = "server {\n"
        finalResult += "    # Converted from .htaccess\n"
        finalResult += "    # Please review and test the configuration\n\n"
        finalResult += result.join("\n")
        finalResult += "\n}"
        
        outputArea.text = finalResult
    }
    
    // 转换Apache正则模式到nginx格式
    function convertApachePattern(apachePattern) {
        // Apache使用^和$，nginx也支持，但需要转义一些特殊字符
        var nginxPattern = apachePattern
        // 转义nginx特殊字符
        nginxPattern = nginxPattern.replace(/([{}])/g, "\\$1")
        // Apache的^和$在nginx中也需要
        return "~* " + nginxPattern
    }
    
    // 转换RewriteRule
    function convertRewriteRule(pattern, substitution, flags, conditions) {
        var result = []
        var nginxPattern = convertApachePattern(pattern)
        
        // 处理RewriteCond条件
        if (conditions.length > 0) {
            result.push("    if (")
            var condParts = []
            for (var j = 0; j < conditions.length; j++) {
                var cond = conditions[j]
                var condExpr = ""
                
                // 转换常见的Apache变量
                if (cond.var === "REQUEST_FILENAME") {
                    condExpr = "$request_filename"
                } else if (cond.var === "REQUEST_URI") {
                    condExpr = "$uri"
                } else if (cond.var === "QUERY_STRING") {
                    condExpr = "$args"
                } else if (cond.var === "HTTP_HOST") {
                    condExpr = "$host"
                } else if (cond.var === "HTTPS") {
                    condExpr = "$https"
                } else {
                    condExpr = "$" + cond.var.toLowerCase()
                }
                
                // 处理条件模式
                var condPattern = cond.pattern
                if (condPattern.startsWith("!")) {
                    condExpr = "!" + condExpr
                    condPattern = condPattern.substring(1)
                }
                
                if (condPattern === "-f" || condPattern === "!-f") {
                    condExpr = (condPattern.startsWith("!") ? "!" : "") + "-f " + condExpr
                } else if (condPattern === "-d" || condPattern === "!-d") {
                    condExpr = (condPattern.startsWith("!") ? "!" : "") + "-d " + condExpr
                } else {
                    condExpr += " ~ " + condPattern
                }
                
                condParts.push(condExpr)
            }
            result.push("        " + condParts.join(" &&\n        ") + ") {")
        }
        
        // 处理flags
        var isLast = flags.indexOf("[L]") !== -1 || flags.indexOf("[last]") !== -1
        var isPermanent = flags.indexOf("[R=301]") !== -1 || flags.indexOf("[R=302]") !== -1
        var redirectCode = "301"
        if (flags.indexOf("[R=302]") !== -1) {
            redirectCode = "302"
        }
        
        // 转换substitution
        var nginxSubstitution = substitution
        if (nginxSubstitution.startsWith("http://") || nginxSubstitution.startsWith("https://")) {
            // 外部URL，使用return
            result.push("        return " + redirectCode + " " + nginxSubstitution + ";")
        } else if (nginxSubstitution.startsWith("/")) {
            // 绝对路径
            if (isPermanent) {
                result.push("        return " + redirectCode + " " + nginxSubstitution + ";")
            } else {
                result.push("        rewrite " + nginxPattern + " " + nginxSubstitution + (isLast ? " last;" : ";"))
            }
        } else {
            // 相对路径
            result.push("        rewrite " + nginxPattern + " " + nginxSubstitution + (isLast ? " last;" : ";"))
        }
        
        if (conditions.length > 0) {
            result.push("    }")
        }
        
        return result.join("\n")
    }
    
    // 复制结果
    function copyResult() {
        if (outputArea.text.length > 0) {
            outputArea.selectAll()
            outputArea.copy()
            outputArea.deselect()
            copyBtn.text = I18n.t("copied") || "已复制"
            copyTimer.start()
        }
    }
    
    Timer {
        id: copyTimer
        interval: 1500
        onTriggered: copyBtn.text = I18n.t("copyResult") || "复制结果"
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 15
            
            // 标题栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Column {
                    spacing: 5
                    Text {
                        text: I18n.t("toolHtaccess")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333"
                    }
                    Text {
                        text: I18n.t("toolHtaccessDesc")
                        font.pixelSize: 13
                        color: "#666"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // 加载示例按钮
                Button {
                    text: I18n.t("loadExample") || "加载示例"
                    width: 100
                    height: 32
                    onClicked: {
                        inputArea.text = "# 开启重写引擎\nRewriteEngine On\nRewriteBase /\n\n# 不是文件且不是目录则重写\nRewriteCond %{REQUEST_FILENAME} !-f\nRewriteCond %{REQUEST_FILENAME} !-d\nRewriteRule ^(.*)$ index.php?/$1 [L]\n\n# 强制HTTPS重定向\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]\n\n# 禁止访问隐藏文件\n<FilesMatch \"^.\">\n    Order allow,deny\n    Deny from all\n</FilesMatch>\n\n# 设置默认首页文件\nDirectoryIndex index.php index.html\n\n# 简单URL重定向\nRedirect 301 /oldpage.html /newpage.html\n\n# 设置缓存\n<FilesMatch \"\\.(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$\">\n    Header set Cache-Control \"max-age=2592000, public\"\n</FilesMatch>"
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#006cbd" : "#0078d4"
                        radius: 4
                    }
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 13
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 左右主体区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20
                
                // 左侧输入区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("inputText") || "输入文本"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + inputArea.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: inputArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: inputArea.activeFocus ? 2 : 1
                        radius: 6
                        
                        Flickable {
                            id: inputFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: inputArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: inputArea
                                placeholderText: I18n.t("inputPlaceholder") || "在此粘贴或输入.htaccess配置..."
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                
                                background: null
                            }
                            
                            ScrollBar.vertical: ScrollBar { }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("clearInput") || "清空"
                            width: 70
                            height: 32
                            onClicked: {
                                inputArea.text = ""
                                outputArea.text = ""
                            }
                            background: Rectangle {
                                color: parent.hovered ? "#f0f0f0" : "#e8e8e8"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#333"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
                
                // 中间按钮区
                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 15
                    
                    Button {
                        text: "→"
                        width: 50
                        height: 50
                        font.pixelSize: 24
                        onClicked: convertText()
                        
                        background: Rectangle {
                            color: parent.hovered ? "#006cbd" : "#0078d4"
                            radius: 25
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 24
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        ToolTip.visible: hovered
                        ToolTip.text: I18n.t("clickToProcess") || "点击处理"
                    }
                    
                    Text {
                        text: I18n.t("clickToProcess") || "点击处理"
                        font.pixelSize: 11
                        color: "#888"
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
                
                // 右侧输出区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("outputResult") || "输出结果"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + outputArea.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#fafafa"
                        border.color: "#d0d0d0"
                        border.width: 1
                        radius: 6
                        
                        Flickable {
                            id: outputFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: outputArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: outputArea
                                readOnly: true
                                font.pixelSize: 14
                                font.family: "Consolas, Microsoft YaHei"
                                wrapMode: TextArea.Wrap
                                selectByMouse: true
                                placeholderText: I18n.t("outputPlaceholder") || "处理结果将显示在这里..."
                                
                                background: null
                            }
                            
                            ScrollBar.vertical: ScrollBar { }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            id: copyBtn
                            text: I18n.t("copyResult") || "复制结果"
                            width: 90
                            height: 32
                            enabled: outputArea.length > 0
                            onClicked: copyResult()
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
            
            // 底部提示信息
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#f0f0f0"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    
                    Text {
                        text: I18n.t("htaccessTip") || "提示：转换结果仅供参考，请仔细检查并测试配置"
                        font.pixelSize: 12
                        color: "#666"
                    }
                    
                    Item { Layout.fillWidth: true }
                }
            }
        }
    }
}

