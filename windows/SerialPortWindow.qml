import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: serialPortWindow
    width: 780
    height: 720
    minimumWidth: 680
    minimumHeight: 560
    title: I18n.t("toolSerialPort") || "串口调试"
    flags: Qt.Window
    modality: Qt.NonModal

    SerialPortTool {
        id: serial
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: I18n.t("toolSerialPort") || "串口调试"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: I18n.t("toolSerialPortDesc") || "连接串口设备收发数据，支持HEX/文本"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }

            // ===== 连接参数区 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    Text {
                        text: I18n.t("serialConnSettings") || "连接参数"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }

                    // 第一行：串口 + 刷新 + 波特率
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: I18n.t("serialPort") || "串口:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 50
                        }

                        ComboBox {
                            id: portCombo
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 36
                            model: serial.availablePorts
                            enabled: !serial.isOpen
                            onActivated: serial.portName = currentText
                            Component.onCompleted: {
                                if (serial.availablePorts.length > 0)
                                    serial.portName = currentText
                            }
                        }

                        Button {
                            text: I18n.t("serialRefresh") || "刷新"
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 36
                            enabled: !serial.isOpen
                            background: Rectangle {
                                color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#666666"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: serial.refreshPorts()
                        }

                        Text {
                            text: I18n.t("serialBaud") || "波特率:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 60
                        }

                        ComboBox {
                            id: baudCombo
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 36
                            editable: true
                            model: ["9600", "19200", "38400", "57600", "115200", "230400", "460800", "921600"]
                            currentIndex: 4
                            enabled: !serial.isOpen
                            function applyValue() {
                                var v = parseInt(editText.length > 0 ? editText : currentText)
                                if (!isNaN(v) && v > 0)
                                    serial.baudRate = v
                            }
                            onActivated: applyValue()
                            onAccepted: applyValue()
                            Component.onCompleted: serial.baudRate = parseInt(currentText)
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // 第二行：数据位 / 停止位 / 校验位
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: I18n.t("serialDataBits") || "数据位:"
                            font.pixelSize: 14
                            color: "#333333"
                        }
                        ComboBox {
                            id: dataBitsCombo
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 36
                            model: ["5", "6", "7", "8"]
                            currentIndex: 3
                            enabled: !serial.isOpen
                            onActivated: serial.dataBits = parseInt(currentText)
                            Component.onCompleted: serial.dataBits = parseInt(currentText)
                        }

                        Text {
                            text: I18n.t("serialStopBits") || "停止位:"
                            font.pixelSize: 14
                            color: "#333333"
                        }
                        ComboBox {
                            id: stopBitsCombo
                            Layout.preferredWidth: 70
                            Layout.preferredHeight: 36
                            model: ["1", "2"]
                            currentIndex: 0
                            enabled: !serial.isOpen
                            onActivated: serial.stopBits = parseInt(currentText)
                            Component.onCompleted: serial.stopBits = parseInt(currentText)
                        }

                        Text {
                            text: I18n.t("serialParity") || "校验位:"
                            font.pixelSize: 14
                            color: "#333333"
                        }
                        ComboBox {
                            id: parityCombo
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            model: ["None", "Even", "Odd", "Mark", "Space"]
                            currentIndex: 0
                            enabled: !serial.isOpen
                            onActivated: serial.parity = currentText
                            Component.onCompleted: serial.parity = currentText
                        }

                        Item { Layout.fillWidth: true }

                        // 状态灯 + 状态文本（紧凑靠右）
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: serial.isOpen ? "#27ae60" : "#e74c3c"
                        }
                        Text {
                            text: serial.statusText
                            font.pixelSize: 13
                            color: serial.isOpen ? "#27ae60" : "#999999"
                            elide: Text.ElideRight
                            Layout.maximumWidth: 160
                            Layout.rightMargin: 4
                        }

                        Button {
                            text: serial.isOpen ? (I18n.t("serialClose") || "关闭") : (I18n.t("serialOpen") || "打开")
                            Layout.preferredWidth: 88
                            Layout.minimumWidth: 88
                            Layout.preferredHeight: 36
                            background: Rectangle {
                                color: serial.isOpen
                                       ? (parent.pressed ? "#d32f2f" : (parent.hovered ? "#e53935" : "#f44336"))
                                       : (parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2"))
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: serial.isOpen ? serial.close() : serial.open()
                        }
                    }
                }
            }

            // ===== 接收区 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: I18n.t("serialReceiveArea") || "接收区:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }

                        CheckBox {
                            id: hexRecvCheck
                            text: "HEX"
                            checked: serial.hexReceive
                            onToggled: serial.hexReceive = checked
                        }

                        CheckBox {
                            id: timestampCheck
                            text: I18n.t("serialTimestamp") || "时间戳"
                            checked: serial.showTimestamp
                            onToggled: serial.showTimestamp = checked
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: "RX: " + serial.rxBytes + "  TX: " + serial.txBytes
                            font.pixelSize: 12
                            color: "#999999"
                        }

                        Button {
                            text: I18n.t("serialClearLog") || "清空"
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 28
                            background: Rectangle {
                                color: parent.pressed ? "#f0f0f0" : (parent.hovered ? "#f5f5f5" : "white")
                                border.color: "#e0e0e0"
                                border.width: 1
                                radius: 4
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#666666"
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                serial.clearLog()
                                serial.resetCounters()
                            }
                        }
                    }

                    ScrollView {
                        id: recvScroll
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        TextArea {
                            id: recvText
                            text: serial.receiveLog
                            readOnly: true
                            wrapMode: TextArea.WrapAnywhere
                            textFormat: TextEdit.PlainText
                            font.pixelSize: 12
                            font.family: "Consolas, Monaco, monospace"
                            color: "#333333"
                            selectByMouse: true
                            width: recvScroll.width

                            background: Rectangle { color: "transparent" }

                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("serialNoData") || "暂无数据"
                                font.pixelSize: 14
                                color: "#999999"
                                visible: serial.receiveLog.length === 0
                            }

                            onTextChanged: {
                                if (length > 0)
                                    cursorPosition = length
                            }
                        }
                    }
                }
            }

            // ===== 发送区 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: I18n.t("serialSendArea") || "发送区:"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333333"
                        }

                        CheckBox {
                            id: hexSendCheck
                            text: "HEX"
                        }

                        CheckBox {
                            id: newlineCheck
                            text: I18n.t("serialAppendNewline") || "追加换行"
                        }

                        Item { Layout.fillWidth: true }

                        CheckBox {
                            id: autoSendCheck
                            text: I18n.t("serialAutoSend") || "定时发送"
                            enabled: serial.isOpen
                            onToggled: {
                                if (checked) {
                                    var interval = parseInt(intervalInput.text)
                                    if (isNaN(interval) || interval < 10) interval = 1000
                                    serial.startAutoSend(sendInput.text, hexSendCheck.checked,
                                                         newlineCheck.checked, interval)
                                } else {
                                    serial.stopAutoSend()
                                }
                            }
                        }

                        TextField {
                            id: intervalInput
                            Layout.preferredWidth: 70
                            text: "1000"
                            placeholderText: "ms"
                            enabled: !autoSendCheck.checked
                            font.pixelSize: 13
                            validator: IntValidator { bottom: 10; top: 3600000 }
                            background: Rectangle {
                                color: "white"
                                border.color: intervalInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: intervalInput.focus ? 2 : 1
                                radius: 4
                            }
                        }
                        Text {
                            text: "ms"
                            font.pixelSize: 13
                            color: "#999999"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            TextArea {
                                id: sendInput
                                placeholderText: hexSendCheck.checked
                                    ? (I18n.t("serialHexHint") || "输入十六进制，如: 01 02 AB FF")
                                    : (I18n.t("serialTextHint") || "输入要发送的文本")
                                wrapMode: TextArea.WrapAnywhere
                                font.pixelSize: 13
                                font.family: "Consolas, Monaco, monospace"
                                color: "#333333"
                                selectByMouse: true

                                background: Rectangle {
                                    color: "white"
                                    border.color: sendInput.focus ? "#1976d2" : "#e0e0e0"
                                    border.width: sendInput.focus ? 2 : 1
                                    radius: 4
                                }
                            }
                        }

                        Button {
                            text: I18n.t("serialSend") || "发送"
                            Layout.preferredWidth: 80
                            Layout.fillHeight: true
                            enabled: serial.isOpen
                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: serial.sendData(sendInput.text, hexSendCheck.checked, newlineCheck.checked)
                        }
                    }
                }
            }
        }
    }

    onClosing: {
        serial.stopAutoSend()
        serial.close()
    }
}
