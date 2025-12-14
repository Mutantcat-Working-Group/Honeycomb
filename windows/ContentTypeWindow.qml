import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: contentTypeWindow
    width: 1100
    height: 700
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolContentType")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // Content-Type数据
    property var contentTypeData: {
        "文本类型": [
            {type: "text/plain", desc: "纯文本文件", ext: ".txt"},
            {type: "text/html", desc: "HTML文档", ext: ".html, .htm"},
            {type: "text/css", desc: "CSS样式表", ext: ".css"},
            {type: "text/javascript", desc: "JavaScript文件", ext: ".js"},
            {type: "text/xml", desc: "XML文档", ext: ".xml"},
            {type: "text/csv", desc: "CSV文件", ext: ".csv"},
            {type: "text/markdown", desc: "Markdown文档", ext: ".md, .markdown"},
            {type: "text/calendar", desc: "日历数据", ext: ".ics"},
            {type: "text/vcard", desc: "电子名片", ext: ".vcf"}
        ],
        "应用类型": [
            {type: "application/json", desc: "JSON数据", ext: ".json"},
            {type: "application/xml", desc: "XML应用数据", ext: ".xml"},
            {type: "application/pdf", desc: "PDF文档", ext: ".pdf"},
            {type: "application/zip", desc: "ZIP压缩文件", ext: ".zip"},
            {type: "application/msword", desc: "Word文档", ext: ".doc"},
            {type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", desc: "Word文档", ext: ".docx"},
            {type: "application/vnd.ms-excel", desc: "Excel表格", ext: ".xls"},
            {type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", desc: "Excel表格", ext: ".xlsx"},
            {type: "application/vnd.ms-powerpoint", desc: "PowerPoint演示文稿", ext: ".ppt"},
            {type: "application/vnd.openxmlformats-officedocument.presentationml.presentation", desc: "PowerPoint演示文稿", ext: ".pptx"},
            {type: "application/octet-stream", desc: "二进制流数据", ext: ".bin, .exe"},
            {type: "application/x-www-form-urlencoded", desc: "表单编码数据", ext: "无"}
        ],
        "图片类型": [
            {type: "image/jpeg", desc: "JPEG图片", ext: ".jpg, .jpeg"},
            {type: "image/png", desc: "PNG图片", ext: ".png"},
            {type: "image/gif", desc: "GIF图片", ext: ".gif"},
            {type: "image/webp", desc: "WebP图片", ext: ".webp"},
            {type: "image/svg+xml", desc: "SVG矢量图", ext: ".svg"},
            {type: "image/bmp", desc: "BMP位图", ext: ".bmp"},
            {type: "image/tiff", desc: "TIFF图片", ext: ".tiff, .tif"},
            {type: "image/x-icon", desc: "图标文件", ext: ".ico"}
        ],
        "音频类型": [
            {type: "audio/mpeg", desc: "MP3音频", ext: ".mp3"},
            {type: "audio/wav", desc: "WAV音频", ext: ".wav"},
            {type: "audio/ogg", desc: "OGG音频", ext: ".ogg"},
            {type: "audio/mp4", desc: "MP4音频", ext: ".m4a"},
            {type: "audio/aac", desc: "AAC音频", ext: ".aac"},
            {type: "audio/flac", desc: "FLAC无损音频", ext: ".flac"},
            {type: "audio/webm", desc: "WebM音频", ext: ".weba"}
        ],
        "视频类型": [
            {type: "video/mp4", desc: "MP4视频", ext: ".mp4"},
            {type: "video/mpeg", desc: "MPEG视频", ext: ".mpeg, .mpg"},
            {type: "video/quicktime", desc: "QuickTime视频", ext: ".mov"},
            {type: "video/x-msvideo", desc: "AVI视频", ext: ".avi"},
            {type: "video/webm", desc: "WebM视频", ext: ".webm"},
            {type: "video/ogg", desc: "OGG视频", ext: ".ogv"},
            {type: "video/3gpp", desc: "3GP视频", ext: ".3gp"},
            {type: "video/x-flv", desc: "Flash视频", ext: ".flv"}
        ],
        "字体类型": [
            {type: "font/woff", desc: "WOFF字体", ext: ".woff"},
            {type: "font/woff2", desc: "WOFF2字体", ext: ".woff2"},
            {type: "font/ttf", desc: "TrueType字体", ext: ".ttf"},
            {type: "font/otf", desc: "OpenType字体", ext: ".otf"},
            {type: "application/font-sfnt", desc: "SFNT字体", ext: ".sfnt"},
            {type: "application/font-woff", desc: "WOFF字体(旧)", ext: ".woff"}
        ],
        "消息类型": [
            {type: "message/rfc822", desc: "电子邮件消息", ext: ".eml, .msg"},
            {type: "message/http", desc: "HTTP消息", ext: "无"}
        ],
        "模型类型": [
            {type: "model/gltf+json", desc: "GLTF模型", ext: ".gltf"},
            {type: "model/gltf-binary", desc: "GLTF二进制模型", ext: ".glb"},
            {type: "model/obj", desc: "OBJ模型", ext: ".obj"}
        ],
        "多部分类型": [
            {type: "multipart/form-data", desc: "表单数据(文件上传)", ext: "无"},
            {type: "multipart/mixed", desc: "混合多部分", ext: "无"},
            {type: "multipart/alternative", desc: "替代多部分", ext: "无"},
            {type: "multipart/related", desc: "相关多部分", ext: "无"}
        ]
    }
    
    // 复制到剪贴板
    function copyToClipboard(text) {
        clipboardArea.text = text
        clipboardArea.selectAll()
        clipboardArea.copy()
        clipboardArea.text = ""
        copyFeedback.show()
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
                    text: I18n.t("toolContentType")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolContentTypeDesc") || "MIME类型参考大全"
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
            
            // 内容区域
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                ColumnLayout {
                    width: contentTypeWindow.width - 50
                    spacing: 25
                    
                    // 遍历每个分类
                    Repeater {
                        id: categoryRepeater
                        model: Object.keys(contentTypeData)
                        
                        ColumnLayout {
                            id: categoryColumn
                            Layout.fillWidth: true
                            spacing: 12
                            
                            property string categoryName: modelData
                            
                            // 分类标题
                            Text {
                                text: categoryColumn.categoryName
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333"
                                Layout.leftMargin: 5
                            }
                            
                            // 表格容器
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: contentTypeData[categoryColumn.categoryName].length * 42 + 40
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
                                        Layout.preferredHeight: 40
                                        color: "#0078d4"
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 15
                                            anchors.rightMargin: 15
                                            spacing: 15
                                            
                                            Text {
                                                text: I18n.t("contentTypeMime") || "MIME类型"
                                                Layout.preferredWidth: 300
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("contentTypeDesc") || "描述"
                                                Layout.fillWidth: true
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("contentTypeExt") || "文件扩展名"
                                                Layout.preferredWidth: 150
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                            }
                                            
                                            Text {
                                                text: I18n.t("operation") || "操作"
                                                Layout.preferredWidth: 80
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: "white"
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }
                                    }
                                    
                                    // 表格内容
                                    Column {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        
                                        Repeater {
                                            model: contentTypeData[categoryColumn.categoryName]
                                            
                                            Rectangle {
                                                width: parent.width
                                                height: 42
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
                                                    spacing: 15
                                                    
                                                    // MIME类型
                                                    Text {
                                                        text: modelData.type
                                                        Layout.preferredWidth: 300
                                                        font.pixelSize: 13
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#0078d4"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 描述
                                                    Text {
                                                        text: modelData.desc
                                                        Layout.fillWidth: true
                                                        font.pixelSize: 12
                                                        color: "#666"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 文件扩展名
                                                    Text {
                                                        text: modelData.ext
                                                        Layout.preferredWidth: 150
                                                        font.pixelSize: 12
                                                        font.family: "Consolas, Microsoft YaHei"
                                                        color: "#333"
                                                        elide: Text.ElideRight
                                                    }
                                                    
                                                    // 复制按钮
                                                    Button {
                                                        Layout.preferredWidth: 70
                                                        Layout.preferredHeight: 28
                                                        text: I18n.t("copy") || "复制"
                                                        onClicked: {
                                                            copyToClipboard(modelData.type)
                                                        }
                                                        background: Rectangle {
                                                            color: parent.hovered ? "#005a9e" : "#0078d4"
                                                            radius: 5
                                                            border.color: parent.hovered ? "#004578" : "#006cbd"
                                                            border.width: 1
                                                            Behavior on color {
                                                                ColorAnimation { duration: 150 }
                                                            }
                                                        }
                                                        contentItem: Text {
                                                            text: parent.text
                                                            font.pixelSize: 12
                                                            font.bold: true
                                                            color: "white"
                                                            horizontalAlignment: Text.AlignHCenter
                                                            verticalAlignment: Text.AlignVCenter
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 复制反馈提示
    Rectangle {
        id: copyFeedback
        anchors.centerIn: parent
        width: 120
        height: 50
        color: "#333333"
        radius: 6
        opacity: 0
        visible: opacity > 0
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("copied") || "已复制"
            font.pixelSize: 14
            color: "white"
        }
        
        function show() {
            opacity = 1
            feedbackTimer.start()
        }
        
        Timer {
            id: feedbackTimer
            interval: 1500
            onTriggered: copyFeedback.opacity = 0
        }
    }
    
    TextArea {
        id: clipboardArea
        visible: false
    }
}