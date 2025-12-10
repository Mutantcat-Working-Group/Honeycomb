import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: complementWindow
    width: 600
    height: 550
    minimumWidth: 500
    minimumHeight: 500
    title: I18n.t("toolComplement")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 位宽选项
    property var bitWidths: [8, 16, 32, 64]
    property int currentBitWidth: 8
    
    // 结果
    property string decimalValue: ""
    property string originalCode: ""
    property string inverseCode: ""
    property string complementCode: ""
    property bool isNegative: false
    property bool hasError: false
    property string errorMsg: ""
    
    // 填充到指定位宽
    function padBinary(bin, width) {
        while (bin.length < width) {
            bin = "0" + bin
        }
        return bin
    }
    
    // 从十进制计算各种码
    function calculateFromDecimal(decStr) {
        hasError = false
        errorMsg = ""
        
        var dec = parseInt(decStr)
        if (isNaN(dec)) {
            hasError = true
            errorMsg = I18n.t("complementInvalidInput") || "无效输入"
            clearResults()
            return
        }
        
        var maxPositive = Math.pow(2, currentBitWidth - 1) - 1
        var minNegative = -Math.pow(2, currentBitWidth - 1)
        
        if (dec > maxPositive || dec < minNegative) {
            hasError = true
            errorMsg = (I18n.t("complementOverflow") || "数值超出范围") + " [" + minNegative + ", " + maxPositive + "]"
            clearResults()
            return
        }
        
        decimalValue = dec.toString()
        isNegative = dec < 0
        
        if (dec >= 0) {
            // 正数：原码=反码=补码
            var bin = padBinary(dec.toString(2), currentBitWidth)
            originalCode = bin
            inverseCode = bin
            complementCode = bin
        } else {
            // 负数
            var absDec = Math.abs(dec)
            var absBin = padBinary(absDec.toString(2), currentBitWidth - 1)
            
            // 原码：符号位1 + 绝对值
            originalCode = "1" + absBin
            
            // 反码：符号位不变，其他位取反
            var inv = "1"
            for (var i = 0; i < absBin.length; i++) {
                inv += absBin[i] === "0" ? "1" : "0"
            }
            inverseCode = inv
            
            // 补码：反码 + 1
            complementCode = addOne(inverseCode)
        }
    }
    
    // 二进制加1
    function addOne(bin) {
        var result = ""
        var carry = 1
        for (var i = bin.length - 1; i >= 0; i--) {
            var sum = parseInt(bin[i]) + carry
            result = (sum % 2).toString() + result
            carry = Math.floor(sum / 2)
        }
        return result
    }
    
    // 从原码计算
    function calculateFromOriginal(binStr) {
        hasError = false
        errorMsg = ""
        
        binStr = binStr.replace(/\s/g, "")
        if (!/^[01]+$/.test(binStr)) {
            hasError = true
            errorMsg = I18n.t("complementInvalidBinary") || "无效的二进制数"
            clearResults()
            return
        }
        
        binStr = padBinary(binStr, currentBitWidth)
        if (binStr.length > currentBitWidth) {
            binStr = binStr.slice(-currentBitWidth)
        }
        
        originalCode = binStr
        isNegative = binStr[0] === "1"
        
        if (!isNegative) {
            // 正数
            decimalValue = parseInt(binStr, 2).toString()
            inverseCode = binStr
            complementCode = binStr
        } else {
            // 负数
            var magnitude = binStr.slice(1)
            decimalValue = "-" + parseInt(magnitude, 2).toString()
            
            // 反码
            var inv = "1"
            for (var i = 0; i < magnitude.length; i++) {
                inv += magnitude[i] === "0" ? "1" : "0"
            }
            inverseCode = inv
            
            // 补码
            complementCode = addOne(inverseCode)
        }
    }
    
    // 从反码计算
    function calculateFromInverse(binStr) {
        hasError = false
        errorMsg = ""
        
        binStr = binStr.replace(/\s/g, "")
        if (!/^[01]+$/.test(binStr)) {
            hasError = true
            errorMsg = I18n.t("complementInvalidBinary") || "无效的二进制数"
            clearResults()
            return
        }
        
        binStr = padBinary(binStr, currentBitWidth)
        if (binStr.length > currentBitWidth) {
            binStr = binStr.slice(-currentBitWidth)
        }
        
        inverseCode = binStr
        isNegative = binStr[0] === "1"
        
        if (!isNegative) {
            // 正数
            decimalValue = parseInt(binStr, 2).toString()
            originalCode = binStr
            complementCode = binStr
        } else {
            // 负数：反码取反得到原码的数值部分
            var magnitude = ""
            for (var i = 1; i < binStr.length; i++) {
                magnitude += binStr[i] === "0" ? "1" : "0"
            }
            decimalValue = "-" + parseInt(magnitude, 2).toString()
            originalCode = "1" + magnitude
            complementCode = addOne(binStr)
        }
    }
    
    // 从补码计算
    function calculateFromComplement(binStr) {
        hasError = false
        errorMsg = ""
        
        binStr = binStr.replace(/\s/g, "")
        if (!/^[01]+$/.test(binStr)) {
            hasError = true
            errorMsg = I18n.t("complementInvalidBinary") || "无效的二进制数"
            clearResults()
            return
        }
        
        binStr = padBinary(binStr, currentBitWidth)
        if (binStr.length > currentBitWidth) {
            binStr = binStr.slice(-currentBitWidth)
        }
        
        complementCode = binStr
        isNegative = binStr[0] === "1"
        
        if (!isNegative) {
            // 正数
            decimalValue = parseInt(binStr, 2).toString()
            originalCode = binStr
            inverseCode = binStr
        } else {
            // 负数：补码-1得到反码，反码取反得到原码数值部分
            var inv = subtractOne(binStr)
            inverseCode = inv
            
            var magnitude = ""
            for (var i = 1; i < inv.length; i++) {
                magnitude += inv[i] === "0" ? "1" : "0"
            }
            decimalValue = "-" + parseInt(magnitude, 2).toString()
            originalCode = "1" + magnitude
        }
    }
    
    // 二进制减1
    function subtractOne(bin) {
        var result = ""
        var borrow = 1
        for (var i = bin.length - 1; i >= 0; i--) {
            var diff = parseInt(bin[i]) - borrow
            if (diff < 0) {
                diff += 2
                borrow = 1
            } else {
                borrow = 0
            }
            result = diff.toString() + result
        }
        return result
    }
    
    function clearResults() {
        decimalValue = ""
        originalCode = ""
        inverseCode = ""
        complementCode = ""
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
            
            // 标题
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolComplement")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolComplementDesc")
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
            
            // 位宽选择
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: (I18n.t("bitWidth") || "位宽") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                Repeater {
                    model: bitWidths
                    
                    Button {
                        text: modelData + " bit"
                        width: 70
                        height: 32
                        
                        background: Rectangle {
                            color: currentBitWidth === modelData ? "#0078d4" : (parent.hovered ? "#e8e8e8" : "white")
                            border.color: currentBitWidth === modelData ? "#0078d4" : "#d0d0d0"
                            border.width: 1
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: currentBitWidth === modelData ? "white" : "#333"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            currentBitWidth = modelData
                            clearResults()
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            // 错误提示
            Text {
                Layout.fillWidth: true
                text: errorMsg
                font.pixelSize: 12
                color: "#e74c3c"
                visible: hasError
                horizontalAlignment: Text.AlignHCenter
            }
            
            // 转换区域
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10
                
                // 十进制输入卡片
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Text {
                            text: (I18n.t("decimal") || "十进制") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.preferredWidth: 60
                        }
                        
                        TextField {
                            id: decInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: decimalValue
                            placeholderText: I18n.t("decimalPlaceholder") || "输入十进制数..."
                            font.pixelSize: 14
                            font.family: "Consolas, Microsoft YaHei"
                            verticalAlignment: Text.AlignVCenter
                            
                            background: Rectangle {
                                color: "#f8f8f8"
                                border.color: decInput.focus ? "#0078d4" : "#d0d0d0"
                                border.width: decInput.focus ? 2 : 1
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: I18n.t("convertBtn") || "转换"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            onClicked: calculateFromDecimal(decInput.text)
                            
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
                }
                
                // 原码卡片
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Text {
                            text: (I18n.t("originalCode") || "原码") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.preferredWidth: 60
                        }
                        
                        TextField {
                            id: origInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: originalCode
                            placeholderText: I18n.t("binaryPlaceholder") || "输入二进制数..."
                            font.pixelSize: 14
                            font.family: "Consolas"
                            verticalAlignment: Text.AlignVCenter
                            
                            background: Rectangle {
                                color: "#f8f8f8"
                                border.color: origInput.focus ? "#0078d4" : "#d0d0d0"
                                border.width: origInput.focus ? 2 : 1
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: I18n.t("convertBtn") || "转换"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            onClicked: calculateFromOriginal(origInput.text)
                            
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
                        
                        Button {
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            enabled: originalCode.length > 0
                            onClicked: copyToClipboard(originalCode)
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                border.color: "#ccc"
                                border.width: 1
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
                
                // 反码卡片
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Text {
                            text: (I18n.t("inverseCode") || "反码") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.preferredWidth: 60
                        }
                        
                        TextField {
                            id: invInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: inverseCode
                            placeholderText: I18n.t("binaryPlaceholder") || "输入二进制数..."
                            font.pixelSize: 14
                            font.family: "Consolas"
                            verticalAlignment: Text.AlignVCenter
                            
                            background: Rectangle {
                                color: "#f8f8f8"
                                border.color: invInput.focus ? "#0078d4" : "#d0d0d0"
                                border.width: invInput.focus ? 2 : 1
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: I18n.t("convertBtn") || "转换"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            onClicked: calculateFromInverse(invInput.text)
                            
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
                        
                        Button {
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            enabled: inverseCode.length > 0
                            onClicked: copyToClipboard(inverseCode)
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                border.color: "#ccc"
                                border.width: 1
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
                
                // 补码卡片
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12
                        
                        Text {
                            text: (I18n.t("complementCode") || "补码") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                            Layout.preferredWidth: 60
                        }
                        
                        TextField {
                            id: compInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            text: complementCode
                            placeholderText: I18n.t("binaryPlaceholder") || "输入二进制数..."
                            font.pixelSize: 14
                            font.family: "Consolas"
                            verticalAlignment: Text.AlignVCenter
                            
                            background: Rectangle {
                                color: "#f8f8f8"
                                border.color: compInput.focus ? "#0078d4" : "#d0d0d0"
                                border.width: compInput.focus ? 2 : 1
                                radius: 4
                            }
                        }
                        
                        Button {
                            text: I18n.t("convertBtn") || "转换"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            onClicked: calculateFromComplement(compInput.text)
                            
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
                        
                        Button {
                            text: I18n.t("copy") || "复制"
                            Layout.preferredWidth: 60
                            Layout.fillHeight: true
                            enabled: complementCode.length > 0
                            onClicked: copyToClipboard(complementCode)
                            
                            background: Rectangle {
                                color: parent.enabled ? (parent.hovered ? "#f0f0f0" : "#e8e8e8") : "#f5f5f5"
                                border.color: "#ccc"
                                border.width: 1
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: parent.enabled ? "#333" : "#999"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
                
                // 填充剩余空间
                Item {
                    Layout.fillHeight: true
                }
            }
            
            // 提示说明
            Rectangle {
                Layout.fillWidth: true
                height: 70
                color: "#f0f7ff"
                border.color: "#d0e4f7"
                border.width: 1
                radius: 6
                
                Column {
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        text: I18n.t("complementTip1") || "• 正数的原码、反码、补码相同"
                        font.pixelSize: 11
                        color: "#666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: I18n.t("complementTip2") || "• 负数的反码 = 原码符号位不变，其他位取反"
                        font.pixelSize: 11
                        color: "#666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: I18n.t("complementTip3") || "• 负数的补码 = 反码 + 1"
                        font.pixelSize: 11
                        color: "#666"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
