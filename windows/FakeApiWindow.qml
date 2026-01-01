import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Honeycomb
import "../i18n/i18n.js" as I18n

Window {
    id: fakeApiWindow
    width: 950
    height: 700
    title: I18n.t("toolFakeApi") || "Fake API"
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 窗口关闭时停止服务器
    onClosing: {
        if (fakeServer.isRunning) {
            fakeServer.stopServer()
        }
    }
    
    // C++ 后端实例
    FakeApiServer {
        id: fakeServer
        
        onLogMessage: function(message) {
            logModel.append({text: message})
            if (logModel.count > 200) {
                logModel.remove(0)
            }
            logListView.positionViewAtEnd()
        }
        
        onSelectedIndexChanged: {
            loadRouteToEditor()
        }
    }
    
    // 日志模型
    ListModel {
        id: logModel
    }
    
    // HTTP方法选项
    property var httpMethods: ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
    
    // 响应类型选项
    property var responseTypes: [
        {value: "json", label: "JSON"},
        {value: "text", label: "纯文本"},
        {value: "html", label: "HTML"},
        {value: "xml", label: "XML"},
        {value: "file", label: "文件"}
    ]
    
    // 加载路由到编辑器
    function loadRouteToEditor() {
        if (fakeServer.selectedIndex < 0) {
            pathInput.text = ""
            responseBodyInput.text = ""
            statusCodeInput.value = 200
            delayInput.value = 0
            contentTypeInput.text = ""
            responseTypeCombo.currentIndex = 0
            // 清除方法选择
            for (var i = 0; i < methodRepeater.count; i++) {
                methodRepeater.itemAt(i).checked = (i === 0)
            }
            return
        }
        
        var route = fakeServer.getRoute(fakeServer.selectedIndex)
        pathInput.text = route.path || ""
        responseBodyInput.text = route.responseBody || ""
        statusCodeInput.value = route.statusCode || 200
        delayInput.value = route.delay || 0
        contentTypeInput.text = route.contentType || ""
        
        // 设置响应类型
        var rtIndex = 0
        for (var j = 0; j < responseTypes.length; j++) {
            if (responseTypes[j].value === route.responseType) {
                rtIndex = j
                break
            }
        }
        responseTypeCombo.currentIndex = rtIndex
        
        // 设置方法选择
        var methods = route.methods || []
        for (var k = 0; k < methodRepeater.count; k++) {
            var methodName = httpMethods[k]
            methodRepeater.itemAt(k).checked = methods.indexOf(methodName) >= 0
        }
    }
    
    // 保存编辑器到路由
    function saveEditorToRoute() {
        if (fakeServer.selectedIndex < 0) return
        
        var methods = []
        for (var i = 0; i < methodRepeater.count; i++) {
            if (methodRepeater.itemAt(i).checked) {
                methods.push(httpMethods[i])
            }
        }
        
        if (methods.length === 0) {
            methods = ["GET"]
        }
        
        var route = {
            path: pathInput.text,
            methods: methods,
            responseType: responseTypes[responseTypeCombo.currentIndex].value,
            statusCode: statusCodeInput.value,
            responseBody: responseBodyInput.text,
            contentType: contentTypeInput.text,
            delay: delayInput.value,
            enabled: true
        }
        
        fakeServer.updateRoute(fakeServer.selectedIndex, route)
    }
    
    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择响应文件"
        onAccepted: {
            responseBodyInput.text = selectedFile.toString().replace("file:///", "")
        }
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12
            
            // 顶部控制栏
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15
                    
                    Text {
                        text: I18n.t("portNumber") || "端口号:"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#333"
                    }
                    
                    SpinBox {
                        id: portInput
                        from: 1
                        to: 65535
                        value: fakeServer.port
                        editable: true
                        enabled: !fakeServer.isRunning
                        Layout.preferredWidth: 120
                        
                        background: Rectangle {
                            color: fakeServer.isRunning ? "#f5f5f5" : "white"
                            border.color: "#e0e0e0"
                            border.width: 1
                            radius: 4
                        }
                        
                        contentItem: TextInput {
                            z: 2
                            text: portInput.textFromValue(portInput.value, portInput.locale)
                            font.pixelSize: 13
                            color: "#333"
                            selectionColor: "#1976d2"
                            selectedTextColor: "white"
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !portInput.editable
                            validator: portInput.validator
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                        }
                        
                        onValueChanged: fakeServer.port = value
                    }
                    
                    Button {
                        text: fakeServer.isRunning ? (I18n.t("stopServer") || "停止服务") : (I18n.t("startServer") || "启动服务")
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 32
                        
                        background: Rectangle {
                            color: fakeServer.isRunning 
                                ? (parent.hovered ? "#d32f2f" : "#f44336")
                                : (parent.hovered ? "#388e3c" : "#4caf50")
                            radius: 4
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onClicked: {
                            if (fakeServer.isRunning) {
                                fakeServer.stopServer()
                            } else {
                                fakeServer.startServer()
                            }
                        }
                    }
                    
                    // 状态指示
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: fakeServer.isRunning ? "#e8f5e9" : "#fafafa"
                        radius: 4
                        border.color: fakeServer.isRunning ? "#4caf50" : "#e0e0e0"
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: fakeServer.isRunning ? "#4caf50" : "#bbb"
                                
                                SequentialAnimation on opacity {
                                    running: fakeServer.isRunning
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 800 }
                                    NumberAnimation { to: 1.0; duration: 800 }
                                }
                            }
                            
                            Text {
                                text: fakeServer.statusMessage || (I18n.t("serverStopped") || "服务未启动")
                                font.pixelSize: 12
                                color: fakeServer.isRunning ? "#2e7d32" : "#666"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                visible: fakeServer.isRunning
                                text: (I18n.t("requestCount") || "请求:") + " " + fakeServer.requestCount
                                font.pixelSize: 11
                                color: "#666"
                            }
                        }
                    }
                }
            }
            
            // 主内容区
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12
                
                // 左侧路由列表
                Rectangle {
                    Layout.preferredWidth: 260
                    Layout.fillHeight: true
                    color: "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 6
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        
                        // 路由列表标题
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: I18n.t("routeList") || "路由列表"
                                font.pixelSize: 14
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // 导入按钮
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 4
                                color: importMouseArea.containsMouse ? "#e3f2fd" : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "📥"
                                    font.pixelSize: 14
                                }
                                
                                MouseArea {
                                    id: importMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    ToolTip.visible: containsMouse
                                    ToolTip.text: I18n.t("importConfig") || "导入配置"
                                    ToolTip.delay: 500
                                    
                                    onClicked: {
                                        var filePath = fakeServer.selectImportFile()
                                        if (filePath) {
                                            if (fakeServer.importFromFile(filePath)) {
                                                importToast.show()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 导出按钮
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 4
                                color: exportMouseArea.containsMouse ? "#e8f5e9" : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "📤"
                                    font.pixelSize: 14
                                }
                                
                                MouseArea {
                                    id: exportMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    ToolTip.visible: containsMouse
                                    ToolTip.text: I18n.t("exportConfig") || "导出配置"
                                    ToolTip.delay: 500
                                    
                                    onClicked: {
                                        if (fakeServer.routes.length === 0) {
                                            return
                                        }
                                        var filePath = fakeServer.selectExportFile()
                                        if (filePath) {
                                            if (fakeServer.exportToFile(filePath)) {
                                                exportToast.show()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Text {
                                text: fakeServer.routes.length + " 个"
                                font.pixelSize: 11
                                color: "#888"
                                Layout.leftMargin: 4
                            }
                        }
                        
                        // 添加路由按钮
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 32
                            text: I18n.t("addRoute") || "+ 添加路由"
                            
                            background: Rectangle {
                                color: parent.hovered ? "#e3f2fd" : "#f5f5f5"
                                border.color: "#1976d2"
                                border.width: 1
                                radius: 4
                            }
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 13
                                color: "#1976d2"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                fakeServer.addRoute("/api/example")
                            }
                        }
                        
                        // 路由列表
                        ListView {
                            id: routeListView
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: fakeServer.routes
                            spacing: 4
                            
                            ScrollBar.vertical: ScrollBar {
                                active: true
                                policy: ScrollBar.AsNeeded
                            }
                            
                            delegate: Rectangle {
                                width: routeListView.width
                                height: 56
                                color: fakeServer.selectedIndex === index ? "#e3f2fd" : (routeMouseArea.containsMouse ? "#f5f5f5" : "transparent")
                                radius: 4
                                border.color: fakeServer.selectedIndex === index ? "#1976d2" : "transparent"
                                border.width: 1
                                
                                MouseArea {
                                    id: routeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        // 先保存当前编辑的路由
                                        if (fakeServer.selectedIndex >= 0 && fakeServer.selectedIndex !== index) {
                                            saveEditorToRoute()
                                        }
                                        fakeServer.selectedIndex = index
                                    }
                                }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8
                                    
                                    Column {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        
                                        Text {
                                            text: modelData.path || "/api/new"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#333"
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                        
                                        Row {
                                            spacing: 4
                                            
                                            Repeater {
                                                model: modelData.methods || ["GET"]
                                                
                                                Rectangle {
                                                    width: methodLabel.width + 8
                                                    height: 16
                                                    radius: 3
                                                    color: {
                                                        switch(modelData) {
                                                            case "GET": return "#e3f2fd"
                                                            case "POST": return "#e8f5e9"
                                                            case "PUT": return "#fff3e0"
                                                            case "DELETE": return "#ffebee"
                                                            case "PATCH": return "#f3e5f5"
                                                            default: return "#f5f5f5"
                                                        }
                                                    }
                                                    
                                                    Text {
                                                        id: methodLabel
                                                        anchors.centerIn: parent
                                                        text: modelData
                                                        font.pixelSize: 9
                                                        font.bold: true
                                                        color: {
                                                            switch(modelData) {
                                                                case "GET": return "#1976d2"
                                                                case "POST": return "#388e3c"
                                                                case "PUT": return "#f57c00"
                                                                case "DELETE": return "#d32f2f"
                                                                case "PATCH": return "#7b1fa2"
                                                                default: return "#666"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // 删除按钮
                                    Rectangle {
                                        width: 24
                                        height: 24
                                        radius: 12
                                        color: deleteMouseArea.containsMouse ? "#ffebee" : "transparent"
                                        visible: routeMouseArea.containsMouse || fakeServer.selectedIndex === index
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "×"
                                            font.pixelSize: 16
                                            color: deleteMouseArea.containsMouse ? "#d32f2f" : "#999"
                                        }
                                        
                                        MouseArea {
                                            id: deleteMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                fakeServer.removeRoute(index)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 空状态
                            Text {
                                visible: fakeServer.routes.length === 0
                                anchors.centerIn: parent
                                text: I18n.t("noRoutes") || "暂无路由\n点击上方按钮添加"
                                font.pixelSize: 13
                                color: "#999"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
                
                // 右侧编辑区
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
                        spacing: 12
                        visible: fakeServer.selectedIndex >= 0
                        
                        // 路由路径
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: I18n.t("routePath") || "路由路径:"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 80
                            }
                            
                            TextField {
                                id: pathInput
                                Layout.fillWidth: true
                                placeholderText: "/api/users"
                                font.pixelSize: 13
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: pathInput.focus ? "#1976d2" : "#e0e0e0"
                                    border.width: pathInput.focus ? 2 : 1
                                    radius: 4
                                }
                                
                                onTextChanged: saveEditorToRoute()
                            }
                        }
                        
                        // 请求方法
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: I18n.t("httpMethods") || "请求方法:"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 80
                                Layout.alignment: Qt.AlignTop
                            }
                            
                            Flow {
                                Layout.fillWidth: true
                                spacing: 8
                                
                                Repeater {
                                    id: methodRepeater
                                    model: httpMethods
                                    
                                    CheckBox {
                                        text: modelData
                                        checked: modelData === "GET"
                                        
                                        indicator: Rectangle {
                                            implicitWidth: 18
                                            implicitHeight: 18
                                            x: 0
                                            y: parent.height / 2 - height / 2
                                            radius: 3
                                            border.color: parent.checked ? "#1976d2" : "#ccc"
                                            color: parent.checked ? "#1976d2" : "white"
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "✓"
                                                font.pixelSize: 12
                                                color: "white"
                                                visible: parent.parent.checked
                                            }
                                        }
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            font.pixelSize: 12
                                            color: "#333"
                                            leftPadding: 24
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        onCheckedChanged: saveEditorToRoute()
                                    }
                                }
                            }
                        }
                        
                        // 状态码和延迟
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            
                            RowLayout {
                                spacing: 10
                                
                                Text {
                                    text: I18n.t("statusCode") || "状态码:"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                SpinBox {
                                    id: statusCodeInput
                                    from: 100
                                    to: 599
                                    value: 200
                                    editable: true
                                    Layout.preferredWidth: 110
                                    
                                    background: Rectangle {
                                        color: "white"
                                        border.color: "#e0e0e0"
                                        border.width: 1
                                        radius: 4
                                    }
                                    
                                    contentItem: TextInput {
                                        z: 2
                                        text: statusCodeInput.textFromValue(statusCodeInput.value, statusCodeInput.locale)
                                        font.pixelSize: 13
                                        color: "#333"
                                        selectionColor: "#1976d2"
                                        selectedTextColor: "white"
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        readOnly: !statusCodeInput.editable
                                        validator: statusCodeInput.validator
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                    }
                                    
                                    onValueChanged: saveEditorToRoute()
                                }
                            }
                            
                            RowLayout {
                                spacing: 10
                                
                                Text {
                                    text: I18n.t("responseDelay") || "延迟(ms):"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                SpinBox {
                                    id: delayInput
                                    from: 0
                                    to: 30000
                                    value: 0
                                    stepSize: 100
                                    editable: true
                                    Layout.preferredWidth: 120
                                    
                                    background: Rectangle {
                                        color: "white"
                                        border.color: "#e0e0e0"
                                        border.width: 1
                                        radius: 4
                                    }
                                    
                                    contentItem: TextInput {
                                        z: 2
                                        text: delayInput.textFromValue(delayInput.value, delayInput.locale)
                                        font.pixelSize: 13
                                        color: "#333"
                                        selectionColor: "#1976d2"
                                        selectedTextColor: "white"
                                        horizontalAlignment: Qt.AlignHCenter
                                        verticalAlignment: Qt.AlignVCenter
                                        readOnly: !delayInput.editable
                                        validator: delayInput.validator
                                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                    }
                                    
                                    onValueChanged: saveEditorToRoute()
                                }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // 响应类型
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: I18n.t("responseType") || "响应类型:"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 80
                            }
                            
                            ComboBox {
                                id: responseTypeCombo
                                Layout.preferredWidth: 120
                                model: responseTypes.map(t => t.label)
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                    radius: 4
                                }
                                
                                onCurrentIndexChanged: saveEditorToRoute()
                            }
                            
                            Text {
                                text: "Content-Type:"
                                font.pixelSize: 13
                                color: "#666"
                            }
                            
                            TextField {
                                id: contentTypeInput
                                Layout.fillWidth: true
                                placeholderText: "自动 (留空使用默认)"
                                font.pixelSize: 12
                                
                                background: Rectangle {
                                    color: "white"
                                    border.color: contentTypeInput.focus ? "#1976d2" : "#e0e0e0"
                                    border.width: 1
                                    radius: 4
                                }
                                
                                onTextChanged: saveEditorToRoute()
                            }
                        }
                        
                        // 响应内容
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                text: I18n.t("responseBody") || "响应内容:"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#333"
                                Layout.preferredWidth: 80
                                Layout.alignment: Qt.AlignTop
                            }
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                
                                // 文件选择按钮（仅文件类型显示）
                                Button {
                                    visible: responseTypeCombo.currentIndex === 4 // file
                                    text: I18n.t("selectFile") || "选择文件..."
                                    Layout.preferredHeight: 28
                                    
                                    background: Rectangle {
                                        color: parent.hovered ? "#e3f2fd" : "white"
                                        border.color: "#1976d2"
                                        border.width: 1
                                        radius: 4
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        font.pixelSize: 12
                                        color: "#1976d2"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    onClicked: fileDialog.open()
                                }
                                
                                Text {
                                    visible: responseTypeCombo.currentIndex === 4
                                    text: I18n.t("filePathTip") || "输入文件的完整路径"
                                    font.pixelSize: 11
                                    color: "#888"
                                }
                            }
                        }
                        
                        // 响应内容编辑器
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#1e1e1e"
                            radius: 4
                            
                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 8
                                
                                TextArea {
                                    id: responseBodyInput
                                    font.family: "Consolas, Monaco, 'Courier New', monospace"
                                    font.pixelSize: 13
                                    color: "#d4d4d4"
                                    placeholderText: responseTypeCombo.currentIndex === 4 
                                        ? "文件路径，如: C:/data/response.json"
                                        : '{\n  "message": "Hello World",\n  "success": true\n}'
                                    placeholderTextColor: "#666"
                                    wrapMode: TextArea.WrapAnywhere
                                    
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    onTextChanged: saveEditorToRoute()
                                }
                            }
                        }
                    }
                    
                    // 未选择路由时的提示
                    Text {
                        visible: fakeServer.selectedIndex < 0
                        anchors.centerIn: parent
                        text: I18n.t("selectRouteToEdit") || "请从左侧选择或添加一个路由进行编辑"
                        font.pixelSize: 14
                        color: "#999"
                    }
                }
            }
            
            // 底部日志区
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#1e1e1e"
                radius: 6
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: I18n.t("serverLog") || "请求日志"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#888"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: I18n.t("clearLog") || "清空"
                            font.pixelSize: 11
                            color: "#888"
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: logModel.clear()
                            }
                        }
                    }
                    
                    ListView {
                        id: logListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: logModel
                        spacing: 1
                        
                        ScrollBar.vertical: ScrollBar {
                            active: true
                            policy: ScrollBar.AsNeeded
                        }
                        
                        delegate: Text {
                            width: logListView.width
                            text: model.text
                            font.family: "Consolas, Monaco, monospace"
                            font.pixelSize: 11
                            color: {
                                if (model.text.indexOf("[错误]") >= 0) return "#f44336"
                                if (model.text.indexOf("[404]") >= 0 || model.text.indexOf("[405]") >= 0) return "#ff9800"
                                if (model.text.indexOf("[200]") >= 0 || model.text.indexOf("[201]") >= 0) return "#4caf50"
                                if (model.text.indexOf("[启动]") >= 0) return "#2196f3"
                                if (model.text.indexOf("[停止]") >= 0) return "#9c27b0"
                                if (model.text.indexOf("[信息]") >= 0) return "#00bcd4"
                                return "#aaa"
                            }
                        }
                        
                        Text {
                            visible: logModel.count === 0
                            anchors.centerIn: parent
                            text: I18n.t("noLogs") || "暂无日志"
                            font.pixelSize: 11
                            color: "#666"
                        }
                    }
                }
            }
        }
    }
    
    // 导入成功提示
    Rectangle {
        id: importToast
        width: 140
        height: 36
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        color: "#323232"
        radius: 18
        opacity: 0
        visible: opacity > 0
        
        function show() {
            importToastAnim.restart()
        }
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("importSuccess") || "导入成功"
            font.pixelSize: 13
            color: "white"
        }
        
        SequentialAnimation {
            id: importToastAnim
            NumberAnimation { target: importToast; property: "opacity"; to: 1; duration: 150 }
            PauseAnimation { duration: 1500 }
            NumberAnimation { target: importToast; property: "opacity"; to: 0; duration: 300 }
        }
    }
    
    // 导出成功提示
    Rectangle {
        id: exportToast
        width: 140
        height: 36
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        color: "#323232"
        radius: 18
        opacity: 0
        visible: opacity > 0
        
        function show() {
            exportToastAnim.restart()
        }
        
        Text {
            anchors.centerIn: parent
            text: I18n.t("exportSuccess") || "导出成功"
            font.pixelSize: 13
            color: "white"
        }
        
        SequentialAnimation {
            id: exportToastAnim
            NumberAnimation { target: exportToast; property: "opacity"; to: 1; duration: 150 }
            PauseAnimation { duration: 1500 }
            NumberAnimation { target: exportToast; property: "opacity"; to: 0; duration: 300 }
        }
    }
}
