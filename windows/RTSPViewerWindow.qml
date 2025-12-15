import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: rtspViewerWindow
    width: 900
    height: 720
    title: I18n.t("toolRTSPViewer") || "RTSP预览"
    flags: Qt.Window
    modality: Qt.NonModal
    
    RTSPViewer {
        id: rtspViewer
    }
    
    MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput
        
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.PlayingState) {
                rtspViewer.updateStatus(qsTr("正在播放"))
            } else if (playbackState === MediaPlayer.StoppedState) {
                rtspViewer.updateStatus(qsTr("已停止"))
            } else if (playbackState === MediaPlayer.PausedState) {
                rtspViewer.updateStatus(qsTr("已暂停"))
            }
        }
        
        onErrorOccurred: function(error, errorString) {
            rtspViewer.updateStatus(qsTr("错误: ") + errorString)
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text {
                text: I18n.t("toolRTSPViewer") || "RTSP预览"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: I18n.t("toolRTSPViewerDesc") || "实时预览RTSP视频流"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
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
                    
                    Text {
                        text: I18n.t("rtspSettings") || "RTSP设置"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "RTSP地址:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        TextField {
                            id: rtspInput
                            Layout.fillWidth: true
                            text: "rtsp://"
                            placeholderText: "例如: rtsp://admin:password@192.168.1.100:554/stream"
                            font.pixelSize: 14
                            
                            background: Rectangle {
                                color: "white"
                                border.color: rtspInput.focus ? "#1976d2" : "#e0e0e0"
                                border.width: rtspInput.focus ? 2 : 1
                                radius: 4
                            }
                            
                            Component.onCompleted: {
                                rtspViewer.rtspUrl = text
                            }
                            
                            onTextChanged: {
                                rtspViewer.rtspUrl = text
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "传输协议:"
                            font.pixelSize: 14
                            color: "#333333"
                            Layout.preferredWidth: 90
                        }
                        
                        ComboBox {
                            id: protocolCombo
                            Layout.preferredWidth: 120
                            model: ["TCP", "UDP"]
                            currentIndex: 0
                            
                            onCurrentTextChanged: {
                                rtspViewer.transportProtocol = currentText
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Button {
                            text: I18n.t("startPreview") || "开始预览"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            enabled: mediaPlayer.playbackState !== MediaPlayer.PlayingState
                            
                            background: Rectangle {
                                color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                if (rtspViewer.rtspUrl === "" || rtspViewer.rtspUrl === "rtsp://") {
                                    rtspViewer.updateStatus(qsTr("错误: RTSP地址不能为空"))
                                    return
                                }
                                
                                var url = rtspViewer.rtspUrl
                                if (rtspViewer.transportProtocol.toLowerCase() === "tcp") {
                                    if (url.indexOf("?") === -1) {
                                        url += "?tcp"
                                    } else {
                                        url += "&tcp"
                                    }
                                }
                                
                                mediaPlayer.source = url
                                mediaPlayer.play()
                                rtspViewer.updateStatus(qsTr("正在连接..."))
                            }
                        }
                        
                        Button {
                            text: I18n.t("stopPreview") || "停止预览"
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 36
                            enabled: mediaPlayer.playbackState === MediaPlayer.PlayingState
                            
                            background: Rectangle {
                                color: parent.pressed ? "#d32f2f" : (parent.hovered ? "#e53935" : "#f44336")
                                radius: 4
                                opacity: parent.enabled ? 1.0 : 0.5
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                mediaPlayer.stop()
                                rtspViewer.updateStatus(qsTr("已停止"))
                            }
                        }
                    }
                }
            }
            
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
                        
                        Text {
                            text: I18n.t("videoPreview") || "视频预览"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: rtspViewer.statusMessage
                            font.pixelSize: 13
                            color: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "#27ae60" : "#666666"
                            font.bold: mediaPlayer.playbackState === MediaPlayer.PlayingState
                        }
                        
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "#27ae60" : "#e74c3c"
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#000000"
                        radius: 4
                        
                        VideoOutput {
                            id: videoOutput
                            anchors.fill: parent
                            
                            Text {
                                anchors.centerIn: parent
                                text: I18n.t("noVideoStream") || "暂无视频流\n点击「开始预览」连接RTSP"
                                font.pixelSize: 16
                                color: "#999999"
                                horizontalAlignment: Text.AlignHCenter
                                visible: mediaPlayer.playbackState !== MediaPlayer.PlayingState
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? 
                                  (I18n.t("resolution") || "分辨率") + ": " + 
                                  videoOutput.sourceRect.width + "x" + videoOutput.sourceRect.height : ""
                            font.pixelSize: 12
                            color: "#666666"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? 
                                  (I18n.t("bufferProgress") || "缓冲") + ": " + 
                                  Math.round(mediaPlayer.bufferProgress * 100) + "%" : ""
                            font.pixelSize: 12
                            color: "#666666"
                        }
                    }
                }
            }
        }
    }
}
