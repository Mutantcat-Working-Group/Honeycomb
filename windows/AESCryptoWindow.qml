import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: aesCryptoWindow
    width: 700
    height: 750
    title: I18n.t("toolAESCrypto") || "AES加解密"
    flags: Qt.Window
    modality: Qt.NonModal

    AESCrypto {
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
        width: 350

        contentItem: Label {
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
                text: I18n.t("toolAESCrypto") || "AES加解密"
                font.pixelSize: 24
                font.bold: true
                color: "#333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: I18n.t("aesCryptoDesc") || "支持AES-128/192/256加密，ECB/CBC模式"
                font.pixelSize: 14
                color: "#666"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }

            // 密钥长度选择
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Text {
                    text: (I18n.t("aesKeySize") || "密钥长度") + ":"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333"
                }

                RadioButton {
                    id: aes128Radio
                    text: "AES-128"
                    checked: true
                    onCheckedChanged: {
                        if (checked) crypto.keySize = "128"
                    }
                }

                RadioButton {
                    id: aes192Radio
                    text: "AES-192"
                    onCheckedChanged: {
                        if (checked) crypto.keySize = "192"
                    }
                }

                RadioButton {
                    id: aes256Radio
                    text: "AES-256"
                    onCheckedChanged: {
                        if (checked) crypto.keySize = "256"
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // 模式选择
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

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

            // 密钥输入
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        id: keyLabel
                        text: (I18n.t("key") || "密钥") + " (" + (aes128Radio.checked ? "32" : (aes192Radio.checked ? "48" : "64")) + " Hex):"
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
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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
                            keyInput.text = crypto.generateKey()
                        }
                    }
                }

                TextField {
                    id: keyInput
                    Layout.fillWidth: true
                    placeholderText: aes128Radio.checked ? 
                        I18n.t("aesKeyPlaceholder128") || "请输入32位十六进制密钥..." :
                        (aes192Radio.checked ? 
                            I18n.t("aesKeyPlaceholder192") || "请输入48位十六进制密钥..." :
                            I18n.t("aesKeyPlaceholder256") || "请输入64位十六进制密钥...")
                    font.family: "Consolas"
                    font.pixelSize: 14
                    maximumLength: aes128Radio.checked ? 32 : (aes192Radio.checked ? 48 : 64)

                    background: Rectangle {
                        color: "white"
                        border.color: keyInput.focus ? "#1976d2" : "#e0e0e0"
                        border.width: keyInput.focus ? 2 : 1
                        radius: 6
                    }

                    onTextChanged: crypto.key = text
                }
            }

            // IV 输入 (CBC模式)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: cbcRadio.checked

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
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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
                        placeholderText: I18n.t("aesInputPlaceholder") || "加密时输入明文，解密时输入十六进制密文..."
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

                Item { Layout.fillWidth: true }

                Button {
                    text: I18n.t("encrypt") || "加密"

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
                        crypto.encrypt()
                    }
                }

                Button {
                    text: I18n.t("decrypt") || "解密"

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
                        crypto.decrypt()
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
                    text: "AES: " + (I18n.t("aesDesc") || "高级加密标准，支持128/192/256位密钥，ECB/CBC模式，使用PKCS7填充")
                    font.pixelSize: 12
                    color: "#666"
                    wrapMode: Text.Wrap
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
