import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: resistorWindow
    width: 800
    height: 735
    title: "电阻阻值计算"
    flags: Qt.Window
    modality: Qt.NonModal
    
    ResistorCalculator {
        id: calculator
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text {
                text: "电阻阻值计算"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "选择电阻环数和每个色环的颜色，自动计算阻值"
                font.pixelSize: 14
                color: "#666666"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "电阻环数:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    Layout.preferredWidth: 80
                }
                
                ComboBox {
                    id: bandCountCombo
                    Layout.preferredWidth: 150
                    model: ["3环", "4环", "5环", "6环"]
                    currentIndex: 1
                    
                    onCurrentIndexChanged: {
                        calculator.bandCount = currentIndex + 3
                    }
                    
                    background: Rectangle {
                        color: bandCountCombo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#ffffff"
                border.color: "#cccccc"
                border.width: 1
                radius: 8
                
                Canvas {
                    id: resistorCanvas
                    anchors.fill: parent
                    anchors.margins: 20
                    
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        
                        var centerY = height / 2
                        var bodyWidth = width * 0.6
                        var bodyHeight = height * 0.4
                        var bodyX = (width - bodyWidth) / 2
                        var bodyY = centerY - bodyHeight / 2
                        
                        ctx.fillStyle = "#D2B48C"
                        ctx.fillRect(bodyX, bodyY, bodyWidth, bodyHeight)
                        
                        ctx.strokeStyle = "#8B7355"
                        ctx.lineWidth = 2
                        ctx.strokeRect(bodyX, bodyY, bodyWidth, bodyHeight)
                        
                        ctx.strokeStyle = "#888888"
                        ctx.lineWidth = 3
                        ctx.beginPath()
                        ctx.moveTo(0, centerY)
                        ctx.lineTo(bodyX, centerY)
                        ctx.stroke()
                        
                        ctx.beginPath()
                        ctx.moveTo(bodyX + bodyWidth, centerY)
                        ctx.lineTo(width, centerY)
                        ctx.stroke()
                        
                        var bandCount = calculator.bandCount
                        var bandWidth = bodyWidth * 0.08
                        var bandSpacing = (bodyWidth - bandWidth * bandCount) / (bandCount + 1)
                        
                        var bands = []
                        if (bandCount >= 3) bands.push(calculator.band1)
                        if (bandCount >= 3) bands.push(calculator.band2)
                        if (bandCount >= 3) bands.push(calculator.band3)
                        if (bandCount >= 4) bands.push(calculator.band4)
                        if (bandCount >= 5) bands.push(calculator.band5)
                        if (bandCount >= 6) bands.push(calculator.band6)
                        
                        for (var i = 0; i < bands.length; i++) {
                            var bandX = bodyX + bandSpacing + i * (bandWidth + bandSpacing)
                            ctx.fillStyle = calculator.getColorHex(bands[i])
                            ctx.fillRect(bandX, bodyY, bandWidth, bodyHeight)
                            
                            ctx.strokeStyle = "#000000"
                            ctx.lineWidth = 1
                            ctx.strokeRect(bandX, bodyY, bandWidth, bodyHeight)
                        }
                    }
                    
                    Connections {
                        target: calculator
                        function onBand1Changed() { resistorCanvas.requestPaint() }
                        function onBand2Changed() { resistorCanvas.requestPaint() }
                        function onBand3Changed() { resistorCanvas.requestPaint() }
                        function onBand4Changed() { resistorCanvas.requestPaint() }
                        function onBand5Changed() { resistorCanvas.requestPaint() }
                        function onBand6Changed() { resistorCanvas.requestPaint() }
                        function onBandCountChanged() { resistorCanvas.requestPaint() }
                    }
                }
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 20
                rowSpacing: 10
                
                Text {
                    text: "第1环:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    visible: calculator.bandCount >= 3
                }
                
                ComboBox {
                    id: band1Combo
                    Layout.fillWidth: true
                    model: ["黑色", "棕色", "红色", "橙色", "黄色", "绿色", "蓝色", "紫色", "灰色", "白色"]
                    visible: calculator.bandCount >= 3
                    
                    onCurrentIndexChanged: {
                        calculator.band1 = currentIndex
                    }
                    
                    delegate: ItemDelegate {
                        width: band1Combo.width
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 20
                                height: 20
                                color: calculator.getColorHex(index)
                                border.color: "#000000"
                                border.width: 1
                            }
                            Text {
                                text: modelData
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: band1Combo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
                
                Text {
                    text: "第2环:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    visible: calculator.bandCount >= 3
                }
                
                ComboBox {
                    id: band2Combo
                    Layout.fillWidth: true
                    model: ["黑色", "棕色", "红色", "橙色", "黄色", "绿色", "蓝色", "紫色", "灰色", "白色"]
                    visible: calculator.bandCount >= 3
                    
                    onCurrentIndexChanged: {
                        calculator.band2 = currentIndex
                    }
                    
                    delegate: ItemDelegate {
                        width: band2Combo.width
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 20
                                height: 20
                                color: calculator.getColorHex(index)
                                border.color: "#000000"
                                border.width: 1
                            }
                            Text {
                                text: modelData
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: band2Combo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
                
                Text {
                    text: calculator.bandCount == 3 ? "倍乘环:" : (calculator.bandCount == 4 ? "倍乘环:" : "第3环:")
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    visible: calculator.bandCount >= 3
                }
                
                ComboBox {
                    id: band3Combo
                    Layout.fillWidth: true
                    model: calculator.bandCount <= 4 ? 
                        ["×1(黑)", "×10(棕)", "×100(红)", "×1k(橙)", "×10k(黄)", "×100k(绿)", "×1M(蓝)", "×10M(紫)", "×0.1(金)", "×0.01(银)"] :
                        ["黑色", "棕色", "红色", "橙色", "黄色", "绿色", "蓝色", "紫色", "灰色", "白色"]
                    visible: calculator.bandCount >= 3
                    
                    onCurrentIndexChanged: {
                        calculator.band3 = currentIndex
                    }
                    
                    delegate: ItemDelegate {
                        width: band3Combo.width
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 20
                                height: 20
                                color: calculator.bandCount <= 4 ? 
                                    (index <= 7 ? calculator.getColorHex(index) : (index == 8 ? "#FFD700" : "#C0C0C0")) :
                                    calculator.getColorHex(index)
                                border.color: "#000000"
                                border.width: 1
                            }
                            Text {
                                text: modelData
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: band3Combo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
                
                Text {
                    text: calculator.bandCount == 4 ? "误差环:" : "倍乘环:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    visible: calculator.bandCount >= 4
                }
                
                ComboBox {
                    id: band4Combo
                    Layout.fillWidth: true
                    model: calculator.bandCount == 4 ?
                        ["±0.5%(绿)", "±0.25%(蓝)", "±0.1%(紫)", "±0.05%(灰)", "±1%(棕)", "±2%(红)", "±4%(黄)", "±5%(金)", "±10%(银)", "±20%(无)"] :
                        ["×1(黑)", "×10(棕)", "×100(红)", "×1k(橙)", "×10k(黄)", "×100k(绿)", "×1M(蓝)", "×10M(紫)", "×0.1(金)", "×0.01(银)"]
                    currentIndex: calculator.bandCount == 4 ? 7 : 0
                    visible: calculator.bandCount >= 4
                    
                    onCurrentIndexChanged: {
                        if (calculator.bandCount == 4) {
                            var toleranceMap = [5, 6, 7, 8, 1, 2, 4, 10, 11, 12]
                            calculator.band4 = toleranceMap[currentIndex]
                        } else {
                            calculator.band4 = currentIndex
                        }
                    }
                    
                    delegate: ItemDelegate {
                        width: band4Combo.width
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 20
                                height: 20
                                color: {
                                    if (calculator.bandCount == 4) {
                                        var colors = ["#00FF00", "#0000FF", "#8B00FF", "#808080", "#8B4513", "#FF0000", "#FFFF00", "#FFD700", "#C0C0C0", "#F5F5DC"]
                                        return colors[index]
                                    } else {
                                        return index <= 7 ? calculator.getColorHex(index) : (index == 8 ? "#FFD700" : "#C0C0C0")
                                    }
                                }
                                border.color: "#000000"
                                border.width: 1
                            }
                            Text {
                                text: modelData
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: band4Combo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
                
                Text {
                    text: "误差环:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    visible: calculator.bandCount >= 5
                }
                
                ComboBox {
                    id: band5Combo
                    Layout.fillWidth: true
                    model: ["±0.5%(绿)", "±0.25%(蓝)", "±0.1%(紫)", "±0.05%(灰)", "±1%(棕)", "±2%(红)", "±4%(黄)", "±5%(金)", "±10%(银)", "±20%(无)"]
                    currentIndex: 7
                    visible: calculator.bandCount >= 5
                    
                    onCurrentIndexChanged: {
                        var toleranceMap = [5, 6, 7, 8, 1, 2, 4, 10, 11, 12]
                        calculator.band5 = toleranceMap[currentIndex]
                    }
                    
                    delegate: ItemDelegate {
                        width: band5Combo.width
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 20
                                height: 20
                                color: {
                                    var colors = ["#00FF00", "#0000FF", "#8B00FF", "#808080", "#8B4513", "#FF0000", "#FFFF00", "#FFD700", "#C0C0C0", "#F5F5DC"]
                                    return colors[index]
                                }
                                border.color: "#000000"
                                border.width: 1
                            }
                            Text {
                                text: modelData
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: band5Combo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
                
                Text {
                    text: "温度系数:"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#333333"
                    visible: calculator.bandCount >= 6
                }
                
                ComboBox {
                    id: band6Combo
                    Layout.fillWidth: true
                    model: ["100ppm(棕)", "50ppm(红)", "15ppm(橙)", "25ppm(黄)", "10ppm(紫)", "5ppm(灰)"]
                    visible: calculator.bandCount >= 6
                    
                    onCurrentIndexChanged: {
                        var tempCoeffMap = [1, 2, 3, 4, 7, 8]
                        calculator.band6 = tempCoeffMap[currentIndex]
                    }
                    
                    delegate: ItemDelegate {
                        width: band6Combo.width
                        contentItem: RowLayout {
                            spacing: 10
                            Rectangle {
                                width: 20
                                height: 20
                                color: {
                                    var colors = ["#8B4513", "#FF0000", "#FFA500", "#FFFF00", "#8B00FF", "#808080"]
                                    return colors[index]
                                }
                                border.color: "#000000"
                                border.width: 1
                            }
                            Text {
                                text: modelData
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                        }
                    }
                    
                    background: Rectangle {
                        color: band6Combo.pressed ? "#e0e0e0" : "#ffffff"
                        border.color: "#cccccc"
                        border.width: 1
                        radius: 4
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#e0e0e0"
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                color: "#ffffff"
                border.color: "#4CAF50"
                border.width: 2
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5
                    
                    Text {
                        text: "计算结果"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#4CAF50"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: calculator.result
                        font.pixelSize: 14
                        color: "#333333"
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
