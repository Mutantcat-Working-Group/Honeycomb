import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: radixWindow
    width: 550
    height: 450
    minimumWidth: 450
    minimumHeight: 400
    title: I18n.t("toolRadix")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 进制列表
    property var radixList: [
        {name: I18n.t("radixBinary") || "二进制", value: 2},
        {name: I18n.t("radixOctal") || "八进制", value: 8},
        {name: I18n.t("radixDecimal") || "十进制", value: 10},
        {name: I18n.t("radixHex") || "十六进制", value: 16}
    ]
    
    property int fromRadix: 10
    property int toRadix: 16
    property string resultText: ""
    
    // 转换函数
    function convert() {
        var input = inputField.text.trim()
        if (input.length === 0) {
            resultText = ""
            return
        }
        
        try {
            // 先转为十进制
            var decimal = parseInt(input, fromRadix)
            
            if (isNaN(decimal)) {
                resultText = I18n.t("radixInvalidInput") || "无效输入"
                return
            }
            
            // 再转为目标进制
            resultText = decimal.toString(toRadix).toUpperCase()
        } catch(e) {
            resultText = I18n.t("radixError") || "转换错误"
        }
    }
    
    // 复制到剪贴板
    function copyResult() {
        clipboardArea.text = resultText
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
            anchors.margins: 30
            spacing: 20
            
            // 标题
            Text {
                text: I18n.t("toolRadix")
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRadixDesc")
                font.pixelSize: 14
                color: "#666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            // 分隔线
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 输入区域
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: (I18n.t("radixInput") || "输入") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                TextField {
                    id: inputField
                    Layout.fillWidth: true
                    placeholderText: I18n.t("radixInputPlaceholder") || "请输入数字..."
                    font.pixelSize: 14
                    font.family: "Consolas, Microsoft YaHei"
                    
                    background: Rectangle {
                        color: "white"
                        border.color: inputField.focus ? "#1976d2" : "#e0e0e0"
                        border.width: inputField.focus ? 2 : 1
                        radius: 4
                    }
                }
            }
            
            // 进制选择区域
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Text {
                    text: (I18n.t("radixFrom") || "从") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                ComboBox {
                    id: fromCombo
                    Layout.preferredWidth: 120
                    model: radixList
                    textRole: "name"
                    currentIndex: 2  // 默认十进制
                    
                    onCurrentIndexChanged: {
                        fromRadix = radixList[currentIndex].value
                        convert()
                    }
                    
                    background: Rectangle {
                        color: "white"
                        border.color: fromCombo.pressed ? "#1976d2" : "#e0e0e0"
                        border.width: 1
                        radius: 4
                        implicitHeight: 36
                    }
                    
                    contentItem: Text {
                        leftPadding: 10
                        text: fromCombo.displayText
                        font.pixelSize: 14
                        color: "#333"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Text {
                    text: "→"
                    font.pixelSize: 20
                    color: "#1976d2"
                }
                
                Text {
                    text: (I18n.t("radixTo") || "到") + ":"
                    font.pixelSize: 14
                    color: "#333"
                }
                
                ComboBox {
                    id: toCombo
                    Layout.preferredWidth: 120
                    model: radixList
                    textRole: "name"
                    currentIndex: 3  // 默认十六进制
                    
                    onCurrentIndexChanged: {
                        toRadix = radixList[currentIndex].value
                        convert()
                    }
                    
                    background: Rectangle {
                        color: "white"
                        border.color: toCombo.pressed ? "#1976d2" : "#e0e0e0"
                        border.width: 1
                        radius: 4
                        implicitHeight: 36
                    }
                    
                    contentItem: Text {
                        leftPadding: 10
                        text: toCombo.displayText
                        font.pixelSize: 14
                        color: "#333"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: I18n.t("convertBtn") || "转换"
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                        radius: 4
                        implicitWidth: 80
                        implicitHeight: 36
                    }
                    
                    onClicked: convert()
                }
            }
            
            // 结果显示区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: (I18n.t("resultLabel") || "结果") + ":"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            id: copyBtn
                            text: I18n.t("copyBtn") || "复制"
                            visible: resultText.length > 0 && resultText !== (I18n.t("radixInvalidInput") || "无效输入") && resultText !== (I18n.t("radixError") || "转换错误")
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
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
                                implicitHeight: 28
                            }
                            
                            onClicked: {
                                copyResult()
                                text = I18n.t("copied") || "已复制"
                                copyTimer.start()
                            }
                            
                            Timer {
                                id: copyTimer
                                interval: 1500
                                onTriggered: copyBtn.text = I18n.t("copyBtn") || "复制"
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f8f8f8"
                        radius: 4
                        clip: true
                        
                        Flickable {
                            anchors.fill: parent
                            anchors.margins: 10
                            contentWidth: width
                            contentHeight: resultDisplay.height
                            clip: true
                            flickableDirection: Flickable.VerticalFlick
                            
                            ScrollBar.vertical: ScrollBar {
                                active: true
                            }
                            
                            Text {
                                id: resultDisplay
                                width: parent.width
                                text: resultText.length > 0 ? resultText : (I18n.t("radixPlaceholder") || "转换结果将显示在这里")
                                font.pixelSize: resultText.length > 0 ? 18 : 14
                                font.family: "Consolas, Microsoft YaHei"
                                font.bold: resultText.length > 0
                                color: resultText.length > 0 ? (resultText === (I18n.t("radixInvalidInput") || "无效输入") || resultText === (I18n.t("radixError") || "转换错误") ? "#e74c3c" : "#333") : "#999"
                                wrapMode: Text.Wrap
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
            
            // 提示信息
            Text {
                Layout.fillWidth: true
                text: I18n.t("radixTip") || "提示：二进制仅支持0-1，八进制支持0-7，十进制支持0-9，十六进制支持0-9和A-F"
                font.pixelSize: 11
                color: "#999"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
