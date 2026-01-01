import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: smCryptoWindow
    width: 700
    height: 700
    title: I18n.t("smCrypto") || "国密加解密"
    flags: Qt.Window
    modality: Qt.NonModal
    
    SMCrypto {
        id: crypto
        
        onErrorOccurred: function(error) {
            errorDialog.text = error
            errorDialog.open()
        }
    }
    
    Dialog {
        id: errorDialog
        property string text: ""
        title: I18n.t("error") || "错误"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        modal: true
        
        Label {
            text: errorDialog.text
            wrapMode: Text.Wrap
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 15
            
            // 标题
            Text {
                text: I18n.t("smCrypto") || "国密加解密"
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("smCryptoDesc") || "支持SM3哈希和SM4加密算法"
                font.pixelSize: 14
                color: "#666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            // 算法选择
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                Text {
                    text: (I18n.t("algorithm") || "算法") + ":"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }
                
                RadioButton {
                    id: sm3Radio
                    text: "SM3 (" + (I18n.t("hash") || "哈希") + ")"
                    checked: true
                    onCheckedChanged: {
                        if (checked) crypto.algorithm = "SM3"
                    }
                }
                
                RadioButton {
                    id: sm4Radio
                    text: "SM4 (" + (I18n.t("symmetric") || "对称加密") + ")"
                    onCheckedChanged: {
                        if (checked) crypto.algorithm = "SM4"
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
            
            // SM4 选项
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                visible: sm4Radio.checked
                
                Text {
                    text: (I18n.t("mode") || "模式") + ":"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }
                
                RadioButton {
                    id: ecbRadio
                    text: "ECB"
                    checked: true
                    onCheckedChanged: {
                        if (checked) crypto.mode = "ECB"
                    }
                }
                
                RadioButton {
                    id: cbcRadio
                    text: "CBC"
                    onCheckedChanged: {
                        if (checked) crypto.mode = "CBC"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                CheckBox {
                    id: uppercaseCheck
                    text: I18n.t("uppercase") || "大写输出"
                    onCheckedChanged: crypto.uppercase = checked
                }
            }
            
            // 密钥输入 (SM4)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: sm4Radio.checked
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: (I18n.t("key") || "密钥") + " (32 Hex):"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: I18n.t("generateKey") || "生成密钥"
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "#1976d2"
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                            border.color: "#1976d2"
                            border.width: 1
                            radius: 4
                            implicitHeight: 28
                            implicitWidth: 80
                        }
                        
                        onClicked: {
                            keyInput.text = crypto.generateKey(16)
                        }
                    }
                }
                
                TextField {
                    id: keyInput
                    Layout.fillWidth: true
                    placeholderText: I18n.t("enterKeyHex") || "请输入32位十六进制密钥..."
                    font.family: "Consolas"
                    font.pixelSize: 14
                    maximumLength: 32
                    
                    background: Rectangle {
                        color: "white"
                        border.color: keyInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: keyInput.focus ? 2 : 1
                        radius: 6
                    }
                    
                    onTextChanged: crypto.key = text
                }
            }
            
            // IV 输入 (SM4 CBC)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: sm4Radio.checked && cbcRadio.checked
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "IV (32 Hex):"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#333"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: I18n.t("generateIV") || "生成IV"
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 12
                            color: "#1976d2"
                        }
                        
                        background: Rectangle {
                            color: parent.pressed ? "#e3f2fd" : (parent.hovered ? "#f5f5f5" : "transparent")
                            border.color: "#1976d2"
                            border.width: 1
                            radius: 4
                            implicitHeight: 28
                            implicitWidth: 80
                        }
                        
                        onClicked: {
                            ivInput.text = crypto.generateIV()
                        }
                    }
                }
                
                TextField {
                    id: ivInput
                    Layout.fillWidth: true
                    placeholderText: I18n.t("enterIVHex") || "请输入32位十六进制IV..."
                    font.family: "Consolas"
                    font.pixelSize: 14
                    maximumLength: 32
                    
                    background: Rectangle {
                        color: "white"
                        border.color: ivInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: ivInput.focus ? 2 : 1
                        radius: 6
                    }
                    
                    onTextChanged: crypto.iv = text
                }
            }
            
            // 输入区域
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                
                Text {
                    text: (I18n.t("inputText") || "输入") + ":"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    TextArea {
                        id: inputText
                        placeholderText: sm3Radio.checked ? 
                            (I18n.t("enterTextToHash") || "请输入要哈希的文本...") :
                            (I18n.t("enterTextOrCipher") || "加密时输入明文，解密时输入十六进制密文...")
                        wrapMode: TextArea.Wrap
                        font.pixelSize: 14
                        color: "#333"
                        selectByMouse: true
                        
                        background: Rectangle {
                            color: "white"
                            border.color: inputText.focus ? "#1976d2" : "#e0e0e0"
                            border.width: inputText.focus ? 2 : 1
                            radius: 8
                        }
                        
                        onTextChanged: crypto.inputText = text
                    }
                }
            }
            
            // 操作按钮
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                CheckBox {
                    id: uppercaseSM3Check
                    text: I18n.t("uppercase") || "大写输出"
                    visible: sm3Radio.checked
                    onCheckedChanged: crypto.uppercase = checked
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: sm3Radio.checked ? (I18n.t("hash") || "哈希") : (I18n.t("encrypt") || "加密")
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#388e3c" : (parent.hovered ? "#4caf50" : "#43a047")
                        radius: 4
                        implicitWidth: 100
                        implicitHeight: 36
                    }
                    
                    onClicked: {
                        if (sm3Radio.checked) {
                            crypto.sm3Hash()
                        } else {
                            crypto.sm4Encrypt()
                        }
                    }
                }
                
                Button {
                    text: I18n.t("decrypt") || "解密"
                    visible: sm4Radio.checked
                    
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
                        implicitWidth: 100
                        implicitHeight: 36
                    }
                    
                    onClicked: {
                        crypto.sm4Decrypt()
                    }
                }
                
                Button {
                    text: I18n.t("clearBtn") || "清空"
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: "#666"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 4
                        implicitWidth: 60
                        implicitHeight: 36
                    }
                    
                    onClicked: {
                        inputText.text = ""
                        keyInput.text = ""
                        ivInput.text = ""
                        crypto.clear()
                    }
                }
            }
            
            // 结果显示
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
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
                            text: I18n.t("copyBtn") || "复制"
                            visible: crypto.result.length > 0
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 12
                                color: "#1976d2"
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
                                resultText.selectAll()
                                resultText.copy()
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        TextArea {
                            id: resultText
                            text: crypto.result
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 14
                            font.family: "Consolas"
                            color: "#333"
                            selectByMouse: true
                            
                            background: Rectangle {
                                color: "transparent"
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("resultWillAppear") || "结果将显示在这里"
                                font.pixelSize: 14
                                color: "#999"
                                visible: crypto.result.length === 0
                            }
                        }
                    }
                }
            }
            
            // 算法说明
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#f5f5f5"
                radius: 8
                
                Text {
                    anchors.fill: parent
                    anchors.margins: 10
                    text: sm3Radio.checked ? 
                        "SM3: " + (I18n.t("sm3Desc") || "国密哈希算法，输出256位哈希值，类似SHA-256") :
                        "SM4: " + (I18n.t("sm4Desc") || "国密对称加密算法，128位密钥，支持ECB/CBC模式")
                    font.pixelSize: 12
                    color: "#666"
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
