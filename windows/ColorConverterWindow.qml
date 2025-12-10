import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: colorWindow
    width: 750
    height: 700
    minimumWidth: 650
    minimumHeight: 600
    title: I18n.t("toolColor")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 当前颜色
    property color currentColor: "#000000"
    
    // 生成随机颜色
    function randomColor() {
        var r = Math.floor(Math.random() * 256)
        var g = Math.floor(Math.random() * 256)
        var b = Math.floor(Math.random() * 256)
        currentColor = Qt.rgba(r/255, g/255, b/255, 1)
    }
    
    // 从 HEX 更新颜色
    function updateFromHex(hex) {
        try {
            var color = Qt.color(hex)
            if (color.toString() !== "invalid") {
                currentColor = color
                return true
            }
        } catch(e) {}
        return false
    }
    
    // 从 RGB 更新颜色
    function updateFromRGB(r, g, b) {
        try {
            var red = parseInt(r)
            var green = parseInt(g)
            var blue = parseInt(b)
            if (red >= 0 && red <= 255 && green >= 0 && green <= 255 && blue >= 0 && blue <= 255) {
                currentColor = Qt.rgba(red/255, green/255, blue/255, 1)
                return true
            }
        } catch(e) {}
        return false
    }
    
    // 从 HSL 更新颜色
    function updateFromHSL(h, s, l) {
        try {
            var hue = parseFloat(h)
            var sat = parseFloat(s)
            var light = parseFloat(l)
            if (hue >= 0 && hue <= 360 && sat >= 0 && sat <= 100 && light >= 0 && light <= 100) {
                currentColor = Qt.hsla(hue/360, sat/100, light/100, 1)
                return true
            }
        } catch(e) {}
        return false
    }
    
    // 从 HSV 更新颜色
    function updateFromHSV(h, s, v) {
        try {
            var hue = parseFloat(h)
            var sat = parseFloat(s)
            var val = parseFloat(v)
            if (hue >= 0 && hue <= 360 && sat >= 0 && sat <= 100 && val >= 0 && val <= 100) {
                currentColor = Qt.hsva(hue/360, sat/100, val/100, 1)
                return true
            }
        } catch(e) {}
        return false
    }
    
    // 获取 HEX
    function getHex() {
        return currentColor.toString()
    }
    
    // 获取 HEX (无#)
    function getHexNoHash() {
        return currentColor.toString().substring(1)
    }
    
    // 获取 RGB
    function getRGB() {
        var r = Math.round(currentColor.r * 255)
        var g = Math.round(currentColor.g * 255)
        var b = Math.round(currentColor.b * 255)
        return "rgb(" + r + ", " + g + ", " + b + ")"
    }
    
    // 获取 RGB 值
    function getRGBValues() {
        return {
            r: Math.round(currentColor.r * 255),
            g: Math.round(currentColor.g * 255),
            b: Math.round(currentColor.b * 255)
        }
    }
    
    // 获取 HSL
    function getHSL() {
        var h = Math.round(currentColor.hslHue * 360)
        var s = Math.round(currentColor.hslSaturation * 100)
        var l = Math.round(currentColor.hslLightness * 100)
        return "hsl(" + h + ", " + s + "%, " + l + "%)"
    }
    
    // 获取 HSL 值
    function getHSLValues() {
        return {
            h: Math.round(currentColor.hslHue * 360),
            s: Math.round(currentColor.hslSaturation * 100),
            l: Math.round(currentColor.hslLightness * 100)
        }
    }
    
    // 获取 HSV 值
    function getHSVValues() {
        return {
            h: Math.round(currentColor.hsvHue * 360),
            s: Math.round(currentColor.hsvSaturation * 100),
            v: Math.round(currentColor.hsvValue * 100)
        }
    }
    
    // 获取 HSV
    function getHSV() {
        var hsv = getHSVValues()
        return "hsv(" + hsv.h + ", " + hsv.s + "%, " + hsv.v + "%)"
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
                    text: I18n.t("toolColor")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolColorDesc")
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
            
            // 色块显示区
            Rectangle {
                Layout.fillWidth: true
                height: 220
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // 色块
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        color: currentColor
                        border.color: "#333"
                        border.width: 2
                        radius: 6
                        
                        // 黑白对比文字
                        Column {
                            anchors.centerIn: parent
                            spacing: 5
                            
                            Text {
                                text: getHex().toUpperCase()
                                font.pixelSize: 18
                                font.bold: true
                                font.family: "Consolas, Microsoft YaHei"
                                color: (currentColor.r * 0.299 + currentColor.g * 0.587 + currentColor.b * 0.114) > 0.5 ? "#000000" : "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            Text {
                                text: getRGB()
                                font.pixelSize: 12
                                font.family: "Consolas, Microsoft YaHei"
                                color: (currentColor.r * 0.299 + currentColor.g * 0.587 + currentColor.b * 0.114) > 0.5 ? "#000000" : "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                    
                    // 按钮
                    Button {
                        text: I18n.t("randomColor") || "随机颜色"
                        Layout.fillWidth: true
                        height: 40
                        onClicked: randomColor()
                        background: Rectangle {
                            color: parent.hovered ? "#006cbd" : "#0078d4"
                            radius: 6
                        }
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 14
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            
            // 滚动区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: colorWindow.width - 50
                    spacing: 12
                    
                    // HEX 格式
                    ColorItem {
                        label: I18n.t("colorHex") || "HEX (#RRGGBB)"
                        value: getHex().toUpperCase()
                        desc: "#FF5733"
                        onSyncClicked: function(val) {
                            updateFromHex(val)
                        }
                    }
                    
                    ColorItem {
                        label: I18n.t("colorHexNoHash") || "HEX (RRGGBB)"
                        value: getHexNoHash().toUpperCase()
                        desc: "FF5733"
                        onSyncClicked: function(val) {
                            updateFromHex("#" + val)
                        }
                    }
                    
                    // RGB 格式
                    ColorRGBItem {
                        label: I18n.t("colorRGB") || "RGB"
                        rValue: getRGBValues().r
                        gValue: getRGBValues().g
                        bValue: getRGBValues().b
                        desc: "rgb(255, 87, 51)"
                        onSyncClicked: function(r, g, b) {
                            updateFromRGB(r, g, b)
                        }
                    }
                    
                    // HSL 格式
                    ColorHSLItem {
                        label: I18n.t("colorHSL") || "HSL"
                        hValue: getHSLValues().h
                        sValue: getHSLValues().s
                        lValue: getHSLValues().l
                        desc: "hsl(9, 100%, 60%)"
                        onSyncClicked: function(h, s, l) {
                            updateFromHSL(h, s, l)
                        }
                    }
                    
                    // HSV 格式
                    ColorHSVItem {
                        label: I18n.t("colorHSV") || "HSV"
                        hValue: getHSVValues().h
                        sValue: getHSVValues().s
                        vValue: getHSVValues().v
                        desc: "hsv(9, 80%, 100%)"
                        onSyncClicked: function(h, s, v) {
                            updateFromHSV(h, s, v)
                        }
                    }
                    
                    ColorItem {
                        label: I18n.t("colorRGBFunc") || "RGB 函数"
                        value: getRGB()
                        desc: "rgb(255, 87, 51)"
                        readOnly: true
                    }
                    
                    ColorItem {
                        label: I18n.t("colorHSLFunc") || "HSL 函数"
                        value: getHSL()
                        desc: "hsl(9, 100%, 60%)"
                        readOnly: true
                    }
                    
                    ColorItem {
                        label: I18n.t("colorHSVFunc") || "HSV 函数"
                        value: getHSV()
                        desc: "hsv(9, 80%, 100%)"
                        readOnly: true
                    }
                    
                    Item { height: 10 }
                }
            }
        }
    }
    
    // 单值颜色项组件
    component ColorItem: Rectangle {
        property string label: ""
        property string value: ""
        property string desc: ""
        property bool readOnly: false
        signal syncClicked(string val)
        
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
                    color: readOnly ? "#f9f9f9" : "#f5f5f5"
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
                        readOnly: parent.parent.parent.parent.readOnly
                    }
                }
                
                Button {
                    text: I18n.t("sync") || "同步"
                    width: 60
                    height: 32
                    visible: !readOnly
                    enabled: !readOnly
                    onClicked: {
                        syncClicked(inputArea.text)
                    }
                    background: Rectangle {
                        color: parent.enabled ? (parent.hovered ? "#006cbd" : "#0078d4") : "#ccc"
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
    
    // RGB 颜色项组件
    component ColorRGBItem: Rectangle {
        property string label: ""
        property int rValue: 0
        property int gValue: 0
        property int bValue: 0
        property string desc: ""
        signal syncClicked(string r, string g, string b)
        
        Layout.fillWidth: true
        height: 100
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 6
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            
            Text {
                text: label
                font.pixelSize: 13
                font.bold: true
                color: "#333"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                RowLayout {
                    spacing: 5
                    Text { text: "R:"; font.pixelSize: 12; color: "#e74c3c"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: rInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: rInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: rValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 255 }
                        }
                    }
                }
                
                RowLayout {
                    spacing: 5
                    Text { text: "G:"; font.pixelSize: 12; color: "#27ae60"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: gInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: gInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: gValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 255 }
                        }
                    }
                }
                
                RowLayout {
                    spacing: 5
                    Text { text: "B:"; font.pixelSize: 12; color: "#3498db"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: bInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: bInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: bValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 255 }
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("sync") || "同步"
                    width: 60
                    height: 32
                    onClicked: {
                        syncClicked(rInput.text, gInput.text, bInput.text)
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
                        copyToClipboard("rgb(" + rValue + ", " + gValue + ", " + bValue + ")")
                        text = I18n.t("copied") || "已复制"
                        copyTimer.start()
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
                        id: copyTimer
                        interval: 1500
                        onTriggered: parent.text = I18n.t("copy") || "复制"
                    }
                }
            }
            
            Text {
                text: I18n.t("example") + ": " + desc
                font.pixelSize: 11
                color: "#999"
            }
        }
    }
    
    // HSL 颜色项组件
    component ColorHSLItem: Rectangle {
        property string label: ""
        property int hValue: 0
        property int sValue: 0
        property int lValue: 0
        property string desc: ""
        signal syncClicked(string h, string s, string l)
        
        Layout.fillWidth: true
        height: 100
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 6
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            
            Text {
                text: label
                font.pixelSize: 13
                font.bold: true
                color: "#333"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                RowLayout {
                    spacing: 5
                    Text { text: "H:"; font.pixelSize: 12; color: "#e74c3c"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: hInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: hInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: hValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 360 }
                        }
                    }
                }
                
                RowLayout {
                    spacing: 5
                    Text { text: "S:"; font.pixelSize: 12; color: "#27ae60"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: sInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: sInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: sValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 100 }
                        }
                    }
                }
                
                RowLayout {
                    spacing: 5
                    Text { text: "L:"; font.pixelSize: 12; color: "#3498db"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: lInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: lInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: lValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 100 }
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("sync") || "同步"
                    width: 60
                    height: 32
                    onClicked: {
                        syncClicked(hInput.text, sInput.text, lInput.text)
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
                        copyToClipboard("hsl(" + hValue + ", " + sValue + "%, " + lValue + "%)")
                        text = I18n.t("copied") || "已复制"
                        copyTimer.start()
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
                        id: copyTimer
                        interval: 1500
                        onTriggered: parent.text = I18n.t("copy") || "复制"
                    }
                }
            }
            
            Text {
                text: I18n.t("example") + ": " + desc
                font.pixelSize: 11
                color: "#999"
            }
        }
    }
    
    // HSV 颜色项组件
    component ColorHSVItem: Rectangle {
        property string label: ""
        property int hValue: 0
        property int sValue: 0
        property int vValue: 0
        property string desc: ""
        signal syncClicked(string h, string s, string v)
        
        Layout.fillWidth: true
        height: 100
        color: "white"
        border.color: "#e0e0e0"
        border.width: 1
        radius: 6
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 8
            
            Text {
                text: label
                font.pixelSize: 13
                font.bold: true
                color: "#333"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                RowLayout {
                    spacing: 5
                    Text { text: "H:"; font.pixelSize: 12; color: "#e74c3c"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: hInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: hInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: hValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 360 }
                        }
                    }
                }
                
                RowLayout {
                    spacing: 5
                    Text { text: "S:"; font.pixelSize: 12; color: "#27ae60"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: sInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: sInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: sValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 100 }
                        }
                    }
                }
                
                RowLayout {
                    spacing: 5
                    Text { text: "V:"; font.pixelSize: 12; color: "#3498db"; font.bold: true; width: 20 }
                    Rectangle {
                        width: 60
                        height: 32
                        color: "#f5f5f5"
                        border.color: vInput.activeFocus ? "#0078d4" : "#d0d0d0"
                        border.width: 1
                        radius: 4
                        TextInput {
                            id: vInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: vValue.toString()
                            font.pixelSize: 13
                            font.family: "Consolas"
                            color: "#333"
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            validator: IntValidator { bottom: 0; top: 100 }
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("sync") || "同步"
                    width: 60
                    height: 32
                    onClicked: {
                        syncClicked(hInput.text, sInput.text, vInput.text)
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
                        copyToClipboard("hsv(" + hValue + ", " + sValue + "%, " + vValue + "%)")
                        text = I18n.t("copied") || "已复制"
                        copyTimer.start()
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
                        id: copyTimer
                        interval: 1500
                        onTriggered: parent.text = I18n.t("copy") || "复制"
                    }
                }
            }
            
            Text {
                text: I18n.t("example") + ": " + desc
                font.pixelSize: 11
                color: "#999"
            }
        }
    }
}
