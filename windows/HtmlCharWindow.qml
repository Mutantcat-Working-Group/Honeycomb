import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: htmlCharWindow
    width: 900
    height: 600
    minimumWidth: 700
    minimumHeight: 500
    title: I18n.t("toolHtmlChar")
    flags: Qt.Window
    modality: Qt.NonModal
    
    property string leftText: ""
    property string rightText: ""
    
    // HTML特殊字符编码映射表
    property var htmlEntities: ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#39;",
        " ": "&nbsp;",
        "\u00A9": "&copy;",
        "\u00AE": "&reg;",
        "\u2122": "&trade;",
        "\u20AC": "&euro;",
        "\u00A3": "&pound;",
        "\u00A5": "&yen;",
        "\u00A2": "&cent;",
        "\u00A7": "&sect;",
        "\u00B6": "&para;",
        "\u2022": "&bull;",
        "\u2026": "&hellip;",
        "\u2014": "&mdash;",
        "\u2013": "&ndash;",
        "\u201C": "&ldquo;",
        "\u201D": "&rdquo;",
        "\u2018": "&lsquo;",
        "\u2019": "&rsquo;",
        "\u00D7": "&times;",
        "\u00F7": "&divide;",
        "\u00B1": "&plusmn;",
        "\u2260": "&ne;",
        "\u2264": "&le;",
        "\u2265": "&ge;",
        "\u221E": "&infin;",
        "\u2211": "&sum;",
        "\u220F": "&prod;",
        "\u222B": "&int;",
        "\u221A": "&radic;",
        "\u00B0": "&deg;",
        "\u2032": "&prime;",
        "\u2033": "&Prime;",
        "\u00B5": "&micro;",
        "\u03C0": "&pi;",
        "\u03A9": "&Omega;",
        "\u03B1": "&alpha;",
        "\u03B2": "&beta;",
        "\u03B3": "&gamma;",
        "\u03B4": "&delta;",
        "\u03B5": "&epsilon;",
        "\u03B6": "&zeta;",
        "\u03B7": "&eta;",
        "\u03B8": "&theta;",
        "\u03B9": "&iota;",
        "\u03BA": "&kappa;",
        "\u03BB": "&lambda;",
        "\u03BC": "&mu;",
        "\u03BD": "&nu;",
        "\u03BE": "&xi;",
        "\u03BF": "&omicron;",
        "\u03C1": "&rho;",
        "\u03C3": "&sigma;",
        "\u03C4": "&tau;",
        "\u03C5": "&upsilon;",
        "\u03C6": "&phi;",
        "\u03C7": "&chi;",
        "\u03C8": "&psi;",
        "\u03C9": "&omega;"
    })
    
    // HTML编码
    function htmlEncode(text) {
        var result = text
        // 按照重要性顺序处理，避免重复编码
        result = result.replace(/&/g, "&amp;")
        result = result.replace(/</g, "&lt;")
        result = result.replace(/>/g, "&gt;")
        result = result.replace(/"/g, "&quot;")
        result = result.replace(/'/g, "&#39;")
        result = result.replace(/ /g, "&nbsp;")
        
        // 处理其他特殊字符
        for (var key in htmlEntities) {
            if (key !== "&" && key !== "<" && key !== ">" && key !== "\"" && key !== "'" && key !== " ") {
                var regex = new RegExp(escapeRegExp(key), 'g')
                result = result.replace(regex, htmlEntities[key])
            }
        }
        return result
    }
    
    // HTML解码
    function htmlDecode(text) {
        try {
            var result = text
            
            // 解码所有HTML实体
            for (var key in htmlEntities) {
                var entity = htmlEntities[key]
                var regex = new RegExp(escapeRegExp(entity), 'g')
                result = result.replace(regex, key)
            }
            
            // 处理数字实体 &#123; 和 &#x1A;
            result = result.replace(/&#(\d+);/g, function(match, dec) {
                return String.fromCharCode(parseInt(dec, 10))
            })
            
            result = result.replace(/&#x([0-9a-fA-F]+);/g, function(match, hex) {
                return String.fromCharCode(parseInt(hex, 16))
            })
            
            return result
        } catch(e) {
            console.log("HTML decode error:", e)
            return text
        }
    }
    
    // 转义正则表达式特殊字符
    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    }
    
    // 转换为HTML编码
    function convertToHtmlEncode() {
        rightText = htmlEncode(leftText)
    }
    
    // 转换为HTML解码
    function convertToHtmlDecode() {
        leftText = htmlDecode(rightText)
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
            spacing: 15
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolHtmlChar")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolHtmlCharDesc")
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
            
            // 左右转换区域
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                // 左侧：原始文本输入区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("htmlOriginalText") || "原始文本"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + leftText.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: leftArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: leftArea.activeFocus ? 2 : 1
                        radius: 6
                        
                        Flickable {
                            id: leftFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: leftArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: leftArea
                                text: leftText
                                onTextChanged: leftText = text
                                placeholderText: I18n.t("htmlOriginalPlaceholder") || "在此输入要编码的文本..."
                                font.pixelSize: 14
                                font.family: "Microsoft YaHei"
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
                        layoutDirection: "RightToLeft"
                        
                        Button {
                            id: copyLeftBtn
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 80
                            height: 36
                            enabled: leftText.length > 0
                            onClicked: {
                                copyToClipboard(leftText)
                                text = I18n.t("copied") || "已复制"
                                copyLeftTimer.start()
                            }
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Timer {
                                id: copyLeftTimer
                                interval: 1500
                                onTriggered: copyLeftBtn.text = I18n.t("copy") || "复制"
                            }
                        }

                        Button {
                            text: I18n.t("clear") || "清空"
                            Layout.preferredWidth: 80
                            height: 36
                            onClicked: leftText = ""
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
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // 中间转换按钮
                ColumnLayout {
                    Layout.preferredWidth: 80
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 15
                    
                    Button {
                        text: "→\nHTML编码"
                        Layout.fillWidth: true
                        height: 70
                        enabled: leftText.length > 0
                        onClicked: convertToHtmlEncode()
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    
                    Button {
                        text: "←\nHTML解码"
                        Layout.fillWidth: true
                        height: 70
                        enabled: rightText.length > 0
                        onClicked: convertToHtmlDecode()
                        background: Rectangle {
                            color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
                            radius: 6
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
                
                // 右侧：HTML编码输出区
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("htmlEncodedText") || "HTML编码"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: (I18n.t("charCount") || "字符数") + ": " + rightText.length
                            font.pixelSize: 12
                            color: "#888"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: rightArea.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: rightArea.activeFocus ? 2 : 1
                        radius: 6
                        
                        Flickable {
                            id: rightFlick
                            anchors.fill: parent
                            anchors.margins: 8
                            contentWidth: width
                            contentHeight: rightArea.contentHeight
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            TextArea.flickable: TextArea {
                                id: rightArea
                                text: rightText
                                onTextChanged: rightText = text
                                placeholderText: I18n.t("htmlEncodedPlaceholder") || "在此输入要解码的HTML文本..."
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
                        layoutDirection: "RightToLeft"
                         
                        Button {
                            id: copyRightBtn
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 80
                            height: 36
                            enabled: rightText.length > 0
                            onClicked: {
                                copyToClipboard(rightText)
                                text = I18n.t("copied") || "已复制"
                                copyRightTimer.start()
                            }
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                radius: 4
                                border.color: "#ccc"
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            Timer {
                                id: copyRightTimer
                                interval: 1500
                                onTriggered: copyRightBtn.text = I18n.t("copy") || "复制"
                            }
                        }

                        Button {
                            text: I18n.t("clear") || "清空"
                            Layout.preferredWidth: 80
                            height: 36
                            onClicked: rightText = ""
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
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            // 说明文字
            Text {
                Layout.fillWidth: true
                text: I18n.t("htmlCharTip") || "支持HTML实体编码、数字实体编码(&#123;、&#x1A;)，用于防止XSS攻击和确保HTML正确显示"
                font.pixelSize: 11
                color: "#999"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }
    }
}
