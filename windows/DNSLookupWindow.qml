import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: dnsLookupWindow
    width: 760
    height: 560
    minimumWidth: 680
    minimumHeight: 480
    title: I18n.t("toolDNSLookup") || "DNS查询"
    flags: Qt.Window
    modality: Qt.NonModal

    DNSLookupTool {
        id: dnsTool
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: I18n.t("toolDNSLookup") || "DNS查询"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: I18n.t("toolDNSLookupDesc") || "查询域名DNS记录"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 132
                color: "white"
                border.color: "#e0e0e0"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 12

                    Text {
                        text: "查询设置"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        TextField {
                            id: domainInput
                            Layout.fillWidth: true
                            text: dnsTool.domain
                            placeholderText: "example.com"
                            font.pixelSize: 14
                            selectByMouse: true
                            onTextChanged: dnsTool.domain = text
                            onAccepted: dnsTool.lookup()
                        }

                        ComboBox {
                            id: recordTypeCombo
                            Layout.preferredWidth: 110
                            model: ["A", "AAAA", "CNAME", "MX", "NS", "TXT", "PTR", "SRV"]
                            onActivated: dnsTool.recordType = currentText
                            Component.onCompleted: dnsTool.recordType = currentText
                        }

                        Button {
                            text: dnsTool.isLoading ? "查询中..." : (I18n.t("searchBtn") || "查询")
                            enabled: !dnsTool.isLoading
                            Layout.preferredWidth: 96
                            Layout.preferredHeight: 36
                            onClicked: dnsTool.lookup()
                        }

                        Button {
                            text: I18n.t("clearBtn") || "清空"
                            Layout.preferredWidth: 82
                            Layout.preferredHeight: 36
                            onClicked: dnsTool.clear()
                        }
                    }

                    Text {
                        text: "支持 A、AAAA、CNAME、MX、NS、TXT、PTR、SRV 记录"
                        font.pixelSize: 12
                        color: "#777777"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "查询结果"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: dnsTool.recordType + "  " + dnsTool.domain
                            font.pixelSize: 12
                            color: "#777777"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        visible: dnsTool.errorMessage.length > 0
                        height: visible ? 38 : 0
                        color: "#fff5f5"
                        border.color: "#ffcdd2"
                        radius: 4

                        Text {
                            anchors.fill: parent
                            anchors.margins: 10
                            text: dnsTool.errorMessage
                            color: "#c62828"
                            font.pixelSize: 13
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextArea {
                            text: dnsTool.result
                            readOnly: true
                            wrapMode: TextArea.Wrap
                            font.family: "Menlo"
                            font.pixelSize: 13
                            placeholderText: "点击查询后显示 DNS 记录"
                        }
                    }
                }
            }
        }
    }
}
