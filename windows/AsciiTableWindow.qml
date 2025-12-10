import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: asciiWindow
    width: 900
    height: 700
    minimumWidth: 800
    minimumHeight: 600
    title: I18n.t("toolAscii")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // ASCII 数据
    property var asciiData: [
        // 控制字符 0-31
        {dec: 0, char: "NUL", desc: "空字符"},
        {dec: 1, char: "SOH", desc: "标题开始"},
        {dec: 2, char: "STX", desc: "正文开始"},
        {dec: 3, char: "ETX", desc: "正文结束"},
        {dec: 4, char: "EOT", desc: "传输结束"},
        {dec: 5, char: "ENQ", desc: "请求"},
        {dec: 6, char: "ACK", desc: "确认"},
        {dec: 7, char: "BEL", desc: "响铃"},
        {dec: 8, char: "BS", desc: "退格"},
        {dec: 9, char: "HT", desc: "水平制表"},
        {dec: 10, char: "LF", desc: "换行"},
        {dec: 11, char: "VT", desc: "垂直制表"},
        {dec: 12, char: "FF", desc: "换页"},
        {dec: 13, char: "CR", desc: "回车"},
        {dec: 14, char: "SO", desc: "移出"},
        {dec: 15, char: "SI", desc: "移入"},
        {dec: 16, char: "DLE", desc: "数据链路转义"},
        {dec: 17, char: "DC1", desc: "设备控制1"},
        {dec: 18, char: "DC2", desc: "设备控制2"},
        {dec: 19, char: "DC3", desc: "设备控制3"},
        {dec: 20, char: "DC4", desc: "设备控制4"},
        {dec: 21, char: "NAK", desc: "否定确认"},
        {dec: 22, char: "SYN", desc: "同步空闲"},
        {dec: 23, char: "ETB", desc: "传输块结束"},
        {dec: 24, char: "CAN", desc: "取消"},
        {dec: 25, char: "EM", desc: "媒介结束"},
        {dec: 26, char: "SUB", desc: "替换"},
        {dec: 27, char: "ESC", desc: "转义"},
        {dec: 28, char: "FS", desc: "文件分隔符"},
        {dec: 29, char: "GS", desc: "组分隔符"},
        {dec: 30, char: "RS", desc: "记录分隔符"},
        {dec: 31, char: "US", desc: "单元分隔符"},
        // 可打印字符 32-127
        {dec: 32, char: "SP", desc: "空格"},
        {dec: 33, char: "!", desc: "感叹号"},
        {dec: 34, char: "\"", desc: "双引号"},
        {dec: 35, char: "#", desc: "井号"},
        {dec: 36, char: "$", desc: "美元符"},
        {dec: 37, char: "%", desc: "百分号"},
        {dec: 38, char: "&", desc: "和号"},
        {dec: 39, char: "'", desc: "单引号"},
        {dec: 40, char: "(", desc: "左括号"},
        {dec: 41, char: ")", desc: "右括号"},
        {dec: 42, char: "*", desc: "星号"},
        {dec: 43, char: "+", desc: "加号"},
        {dec: 44, char: ",", desc: "逗号"},
        {dec: 45, char: "-", desc: "减号"},
        {dec: 46, char: ".", desc: "句点"},
        {dec: 47, char: "/", desc: "斜杠"},
        {dec: 48, char: "0", desc: "数字0"},
        {dec: 49, char: "1", desc: "数字1"},
        {dec: 50, char: "2", desc: "数字2"},
        {dec: 51, char: "3", desc: "数字3"},
        {dec: 52, char: "4", desc: "数字4"},
        {dec: 53, char: "5", desc: "数字5"},
        {dec: 54, char: "6", desc: "数字6"},
        {dec: 55, char: "7", desc: "数字7"},
        {dec: 56, char: "8", desc: "数字8"},
        {dec: 57, char: "9", desc: "数字9"},
        {dec: 58, char: ":", desc: "冒号"},
        {dec: 59, char: ";", desc: "分号"},
        {dec: 60, char: "<", desc: "小于"},
        {dec: 61, char: "=", desc: "等号"},
        {dec: 62, char: ">", desc: "大于"},
        {dec: 63, char: "?", desc: "问号"},
        {dec: 64, char: "@", desc: "at符号"},
        {dec: 65, char: "A", desc: "大写A"},
        {dec: 66, char: "B", desc: "大写B"},
        {dec: 67, char: "C", desc: "大写C"},
        {dec: 68, char: "D", desc: "大写D"},
        {dec: 69, char: "E", desc: "大写E"},
        {dec: 70, char: "F", desc: "大写F"},
        {dec: 71, char: "G", desc: "大写G"},
        {dec: 72, char: "H", desc: "大写H"},
        {dec: 73, char: "I", desc: "大写I"},
        {dec: 74, char: "J", desc: "大写J"},
        {dec: 75, char: "K", desc: "大写K"},
        {dec: 76, char: "L", desc: "大写L"},
        {dec: 77, char: "M", desc: "大写M"},
        {dec: 78, char: "N", desc: "大写N"},
        {dec: 79, char: "O", desc: "大写O"},
        {dec: 80, char: "P", desc: "大写P"},
        {dec: 81, char: "Q", desc: "大写Q"},
        {dec: 82, char: "R", desc: "大写R"},
        {dec: 83, char: "S", desc: "大写S"},
        {dec: 84, char: "T", desc: "大写T"},
        {dec: 85, char: "U", desc: "大写U"},
        {dec: 86, char: "V", desc: "大写V"},
        {dec: 87, char: "W", desc: "大写W"},
        {dec: 88, char: "X", desc: "大写X"},
        {dec: 89, char: "Y", desc: "大写Y"},
        {dec: 90, char: "Z", desc: "大写Z"},
        {dec: 91, char: "[", desc: "左方括号"},
        {dec: 92, char: "\\", desc: "反斜杠"},
        {dec: 93, char: "]", desc: "右方括号"},
        {dec: 94, char: "^", desc: "脱字符"},
        {dec: 95, char: "_", desc: "下划线"},
        {dec: 96, char: "`", desc: "反引号"},
        {dec: 97, char: "a", desc: "小写a"},
        {dec: 98, char: "b", desc: "小写b"},
        {dec: 99, char: "c", desc: "小写c"},
        {dec: 100, char: "d", desc: "小写d"},
        {dec: 101, char: "e", desc: "小写e"},
        {dec: 102, char: "f", desc: "小写f"},
        {dec: 103, char: "g", desc: "小写g"},
        {dec: 104, char: "h", desc: "小写h"},
        {dec: 105, char: "i", desc: "小写i"},
        {dec: 106, char: "j", desc: "小写j"},
        {dec: 107, char: "k", desc: "小写k"},
        {dec: 108, char: "l", desc: "小写l"},
        {dec: 109, char: "m", desc: "小写m"},
        {dec: 110, char: "n", desc: "小写n"},
        {dec: 111, char: "o", desc: "小写o"},
        {dec: 112, char: "p", desc: "小写p"},
        {dec: 113, char: "q", desc: "小写q"},
        {dec: 114, char: "r", desc: "小写r"},
        {dec: 115, char: "s", desc: "小写s"},
        {dec: 116, char: "t", desc: "小写t"},
        {dec: 117, char: "u", desc: "小写u"},
        {dec: 118, char: "v", desc: "小写v"},
        {dec: 119, char: "w", desc: "小写w"},
        {dec: 120, char: "x", desc: "小写x"},
        {dec: 121, char: "y", desc: "小写y"},
        {dec: 122, char: "z", desc: "小写z"},
        {dec: 123, char: "{", desc: "左花括号"},
        {dec: 124, char: "|", desc: "竖线"},
        {dec: 125, char: "}", desc: "右花括号"},
        {dec: 126, char: "~", desc: "波浪号"},
        {dec: 127, char: "DEL", desc: "删除"}
    ]
    
    function toHex(dec) {
        return ("0" + dec.toString(16).toUpperCase()).slice(-2)
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
                    text: I18n.t("toolAscii")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                }
                Text {
                    text: I18n.t("toolAsciiDesc")
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
            
            // 表格区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 1
                    spacing: 0
                    
                    // 表头
                    Rectangle {
                        Layout.fillWidth: true
                        height: 45
                        color: "#0078d4"
                        radius: 5
                        
                        // 覆盖底部圆角
                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 5
                            color: "#0078d4"
                        }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 0
                            
                            Text {
                                text: "Dec"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Text {
                                text: "Hex"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Text {
                                text: I18n.t("asciiChar") || "字符"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            
                            Text {
                                text: I18n.t("asciiDesc") || "说明"
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                    
                    // 表格内容
                    ListView {
                        id: asciiList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: asciiData
                        
                        ScrollBar.vertical: ScrollBar {
                            active: true
                        }
                        
                        delegate: Rectangle {
                            width: asciiList.width
                            height: 38
                            color: index % 2 === 0 ? "#ffffff" : "#f8f8f8"
                            
                            // 鼠标悬停效果
                            Rectangle {
                                anchors.fill: parent
                                color: "#e8f4fd"
                                opacity: mouseArea.containsMouse ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 100 } }
                            }
                            
                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 15
                                anchors.rightMargin: 15
                                spacing: 0
                                
                                // Dec
                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.fillHeight: true
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.dec
                                        font.pixelSize: 13
                                        font.family: "Consolas"
                                        color: "#333"
                                    }
                                }
                                
                                // Hex
                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.fillHeight: true
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "0x" + toHex(modelData.dec)
                                        font.pixelSize: 13
                                        font.family: "Consolas"
                                        color: "#0078d4"
                                    }
                                }
                                
                                // 字符
                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.fillHeight: true
                                    
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 60
                                        height: 28
                                        color: modelData.dec < 32 || modelData.dec === 127 ? "#fff3cd" : "#d4edda"
                                        radius: 4
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.char
                                            font.pixelSize: 13
                                            font.family: "Consolas, Microsoft YaHei"
                                            font.bold: true
                                            color: modelData.dec < 32 || modelData.dec === 127 ? "#856404" : "#155724"
                                        }
                                    }
                                }
                                
                                // 说明
                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.fillHeight: true
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.desc
                                        font.pixelSize: 13
                                        color: "#666"
                                    }
                                }
                            }
                            
                            // 底部分隔线
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: "#f0f0f0"
                            }
                        }
                    }
                }
            }
            
            // 底部说明
            RowLayout {
                Layout.fillWidth: true
                spacing: 30
                
                Row {
                    spacing: 8
                    Rectangle {
                        width: 16
                        height: 16
                        color: "#fff3cd"
                        radius: 3
                    }
                    Text {
                        text: I18n.t("asciiControl") || "控制字符 (0-31, 127)"
                        font.pixelSize: 12
                        color: "#666"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Row {
                    spacing: 8
                    Rectangle {
                        width: 16
                        height: 16
                        color: "#d4edda"
                        radius: 3
                    }
                    Text {
                        text: I18n.t("asciiPrintable") || "可打印字符 (32-126)"
                        font.pixelSize: 12
                        color: "#666"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: I18n.t("asciiTotal") || "共 128 个字符"
                    font.pixelSize: 12
                    color: "#999"
                }
            }
        }
    }
}
