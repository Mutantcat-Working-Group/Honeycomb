import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import "../i18n/i18n.js" as I18n

Window {
    id: rootWindow
    width: 1280
    height: 820
    minimumWidth: 900
    minimumHeight: 600
    title: I18n.t("toolWebInspector") || "网页组件选取"
    flags: Qt.Window
    modality: Qt.NonModal

    // 是否处于选取模式
    property bool pickMode: false
    // 最近一次选取到的组件信息（原始 JSON 字符串）
    property string lastPickedJson: ""

    // ===== 注入到网页中的 JavaScript（使用模板字符串，避免转义地狱）=====
    property string injectJs: `
(function(){
  if (window.__honeycombInspector) { return "already"; }
  var HC = window.__honeycombInspector = {
    active: false,
    picked: null,
    overlay: null,
    overlayLabel: null,
    lastEl: null
  };

  function ensureOverlay(){
    if (HC.overlay) { return HC.overlay; }
    var o = document.createElement('div');
    o.setAttribute('data-honeycomb-overlay','1');
    o.style.position = 'fixed';
    o.style.zIndex = '2147483646';
    o.style.pointerEvents = 'none';
    o.style.border = '2px solid #4e9cff';
    o.style.background = 'rgba(78,156,255,0.18)';
    o.style.boxSizing = 'border-box';
    o.style.display = 'none';
    o.style.borderRadius = '2px';
    var lbl = document.createElement('div');
    lbl.setAttribute('data-honeycomb-overlay','1');
    lbl.style.position = 'absolute';
    lbl.style.top = '-20px';
    lbl.style.left = '0';
    lbl.style.background = '#4e9cff';
    lbl.style.color = '#ffffff';
    lbl.style.font = '11px/16px monospace';
    lbl.style.padding = '1px 6px';
    lbl.style.whiteSpace = 'nowrap';
    lbl.style.borderRadius = '2px';
    lbl.style.pointerEvents = 'none';
    o.appendChild(lbl);
    HC.overlayLabel = lbl;
    (document.body || document.documentElement).appendChild(o);
    HC.overlay = o;
    return o;
  }

  function descriptor(el){
    var s = el.tagName ? el.tagName.toLowerCase() : String(el.nodeName).toLowerCase();
    if (el.id) { s += '#' + el.id; }
    if (el.classList && el.classList.length) {
      s += '.' + Array.prototype.join.call(el.classList, '.');
    }
    return s;
  }

  function highlight(el){
    if (!el || !el.getBoundingClientRect) { return; }
    var o = ensureOverlay();
    var r = el.getBoundingClientRect();
    o.style.display = 'block';
    o.style.left = r.left + 'px';
    o.style.top = r.top + 'px';
    o.style.width = r.width + 'px';
    o.style.height = r.height + 'px';
    HC.overlayLabel.textContent = descriptor(el) + '  ' + Math.round(r.width) + ' x ' + Math.round(r.height);
  }

  function getXPath(el){
    if (el && el.id) { return '//*[@id="' + el.id + '"]'; }
    var parts = [];
    while (el && el.nodeType === 1) {
      var idx = 1;
      var sib = el.previousSibling;
      while (sib) {
        if (sib.nodeType === 1 && sib.nodeName === el.nodeName) { idx++; }
        sib = sib.previousSibling;
      }
      parts.unshift(el.nodeName.toLowerCase() + '[' + idx + ']');
      el = el.parentNode;
    }
    return '/' + parts.join('/');
  }

  function cssPath(el){
    var parts = [];
    while (el && el.nodeType === 1 && parts.length < 60) {
      var sel = el.nodeName.toLowerCase();
      if (el.id) {
        sel = '#' + (window.CSS && CSS.escape ? CSS.escape(el.id) : el.id);
        parts.unshift(sel);
        break;
      } else {
        var nth = 1;
        var sib = el;
        while ((sib = sib.previousElementSibling)) {
          if (sib.nodeName === el.nodeName) { nth++; }
        }
        if (nth !== 1) { sel += ':nth-of-type(' + nth + ')'; }
      }
      parts.unshift(sel);
      el = el.parentElement;
    }
    return parts.join(' > ');
  }

  function collect(el){
    var info = {};
    info.descriptor = descriptor(el);
    info.tagName = el.tagName ? el.tagName.toLowerCase() : '';
    info.namespaceURI = el.namespaceURI || '';
    info.id = el.id || '';
    info.classList = el.classList ? Array.prototype.slice.call(el.classList) : [];
    info.name = el.getAttribute ? (el.getAttribute('name') || '') : '';
    info.type = el.getAttribute ? (el.getAttribute('type') || '') : '';
    info.role = el.getAttribute ? (el.getAttribute('role') || '') : '';

    info.attributes = {};
    if (el.attributes) {
      for (var i = 0; i < el.attributes.length; i++) {
        info.attributes[el.attributes[i].name] = el.attributes[i].value;
      }
    }

    info.inlineStyle = (el.getAttribute && el.getAttribute('style')) || '';
    info.value = (el.value !== undefined && el.value !== null) ? String(el.value) : '';
    info.xpath = getXPath(el);
    info.cssSelector = cssPath(el);
    info.textContent = (el.textContent || '').trim().slice(0, 800);
    info.innerHTML = (el.innerHTML || '').slice(0, 3000);
    info.outerHTML = (el.outerHTML || '').slice(0, 6000);
    info.childElementCount = el.childElementCount || 0;
    info.parentTag = el.parentElement ? el.parentElement.tagName.toLowerCase() : '';

    var r = el.getBoundingClientRect ? el.getBoundingClientRect() : {left:0,top:0,width:0,height:0};
    info.rect = {
      x: Math.round(r.left), y: Math.round(r.top),
      width: Math.round(r.width), height: Math.round(r.height)
    };

    info.computedStyle = {};
    try {
      var cs = window.getComputedStyle(el);
      for (var j = 0; j < cs.length; j++) {
        var p = cs[j];
        info.computedStyle[p] = cs.getPropertyValue(p);
      }
    } catch (e) {}

    info.pageUrl = window.location.href;
    return info;
  }

  HC.onMove = function(e){
    if (!HC.active) { return; }
    var el = e.target;
    if (!el || el === HC.overlay || (el.getAttribute && el.getAttribute('data-honeycomb-overlay'))) { return; }
    HC.lastEl = el;
    highlight(el);
  };
  HC.onClick = function(e){
    if (!HC.active) { return; }
    e.preventDefault();
    e.stopPropagation();
    var el = HC.lastEl || e.target;
    try { HC.picked = JSON.stringify(collect(el)); } catch (err) { HC.picked = null; }
    return false;
  };
  HC.onScroll = function(){ if (HC.active && HC.lastEl) { highlight(HC.lastEl); } };

  document.addEventListener('mousemove', HC.onMove, true);
  document.addEventListener('click', HC.onClick, true);
  document.addEventListener('mousedown', HC.onClick, true);
  window.addEventListener('scroll', HC.onScroll, true);
  window.addEventListener('resize', HC.onScroll, true);

  window.__hcSetActive = function(a){
    HC.active = !!a;
    if (!HC.active && HC.overlay) { HC.overlay.style.display = 'none'; }
    document.documentElement.style.cursor = HC.active ? 'crosshair' : '';
    return HC.active;
  };
  window.__hcPoll = function(){ var p = HC.picked; HC.picked = null; return p; };
  return "injected";
})();
`

    // 复制到剪贴板辅助
    function copyToClipboard(text) {
        clipboardHelper.text = text
        clipboardHelper.selectAll()
        clipboardHelper.copy()
    }

    // 隐藏的文本编辑框用于复制到剪贴板
    TextEdit {
        id: clipboardHelper
        visible: false
    }

    // 把选取到的 JSON 信息格式化成可读文本
    function formatInfo(o) {
        var L = []
        L.push("========== 网页组件信息 ==========")
        L.push("【组件描述符】 " + o.descriptor)
        L.push("【标签名 tagName】 " + o.tagName)
        if (o.namespaceURI) L.push("【命名空间】 " + o.namespaceURI)
        if (o.id) L.push("【ID】 " + o.id)
        L.push("【类名 classList】 " + (o.classList && o.classList.length ? o.classList.join(" ") : "(无)"))
        if (o.name) L.push("【name】 " + o.name)
        if (o.type) L.push("【type】 " + o.type)
        if (o.role) L.push("【role】 " + o.role)
        L.push("【子元素数量】 " + o.childElementCount + "　【父元素】 " + (o.parentTag || "(无)"))
        L.push("")
        L.push("【XPath】")
        L.push(o.xpath)
        L.push("")
        L.push("【CSS 选择器】")
        L.push(o.cssSelector)
        L.push("")
        L.push("【位置尺寸 rect】 x=" + o.rect.x + "  y=" + o.rect.y + "  w=" + o.rect.width + "  h=" + o.rect.height)
        L.push("")

        L.push("【全部属性 attributes】")
        var ak = Object.keys(o.attributes || {})
        if (ak.length === 0) {
            L.push("  (无)")
        } else {
            for (var i = 0; i < ak.length; i++) {
                L.push("  " + ak[i] + " = \"" + o.attributes[ak[i]] + "\"")
            }
        }
        L.push("")

        if (o.inlineStyle) {
            L.push("【内联样式 style】")
            L.push(o.inlineStyle)
            L.push("")
        }
        if (o.value) {
            L.push("【value】 " + o.value)
            L.push("")
        }

        L.push("【计算样式 computedStyle（全部）】")
        var ck = Object.keys(o.computedStyle || {})
        for (var j = 0; j < ck.length; j++) {
            L.push("  " + ck[j] + ": " + o.computedStyle[ck[j]] + ";")
        }
        L.push("")

        L.push("【文本内容 textContent】")
        L.push(o.textContent || "(无)")
        L.push("")
        L.push("【outerHTML】")
        L.push(o.outerHTML || "(无)")
        L.push("")
        L.push("【innerHTML】")
        L.push(o.innerHTML || "(无)")
        L.push("")
        L.push("【来源页面】 " + (o.pageUrl || ""))
        return L.join("\n")
    }

    // 处理选取结果
    function handlePicked(jsonStr) {
        rootWindow.lastPickedJson = jsonStr
        var obj
        try {
            obj = JSON.parse(jsonStr)
        } catch (e) {
            return
        }
        // 计算 XPath / CSS 已在注入脚本外补齐，这里若缺失则容错
        if (!obj.xpath) obj.xpath = "(无法计算)"
        if (!obj.cssSelector) obj.cssSelector = "(无法计算)"
        var text = formatInfo(obj)
        infoArea.text = text
        copyToClipboard(text)
        copyToast.visible = true
        toastTimer.restart()
    }

    // 导航到地址栏中的地址
    function navigate(input) {
        var url = (input || "").trim()
        if (url.length === 0) return
        if (!/^[a-zA-Z][a-zA-Z0-9+.-]*:\/\//.test(url)) {
            // 没有协议：像浏览器一样处理——含点且无空格视为域名，否则走搜索
            if (url.indexOf(" ") === -1 && url.indexOf(".") !== -1) {
                url = "https://" + url
            } else {
                url = "https://www.bing.com/search?q=" + encodeURIComponent(url)
            }
        }
        webView.url = url
    }

    // 设置网页内选取模式的开关
    function applyPickMode() {
        webView.runJavaScript("window.__hcSetActive && window.__hcSetActive(" + (pickMode ? "true" : "false") + ")")
    }

    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ===== 顶部工具栏 =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    // 导航按钮组件（统一风格）
                    component NavButton: Button {
                        implicitWidth: 34
                        implicitHeight: 34
                        font.pixelSize: 15
                        background: Rectangle {
                            radius: 6
                            color: !parent.enabled ? "#f5f5f5"
                                   : (parent.hovered ? "#e8f0fe" : "#f0f0f0")
                            border.color: "#e0e0e0"
                            border.width: 1
                        }
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#333333" : "#c0c0c0"
                            font: parent.font
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    NavButton {
                        text: "◀"
                        enabled: webView.canGoBack
                        onClicked: webView.goBack()
                        ToolTip.visible: hovered
                        ToolTip.text: "后退"
                    }
                    NavButton {
                        text: "▶"
                        enabled: webView.canGoForward
                        onClicked: webView.goForward()
                        ToolTip.visible: hovered
                        ToolTip.text: "前进"
                    }
                    NavButton {
                        text: webView.loading ? "✕" : "⟳"
                        onClicked: webView.loading ? webView.stop() : webView.reload()
                        ToolTip.visible: hovered
                        ToolTip.text: webView.loading ? "停止" : "刷新"
                    }

                    TextField {
                        id: urlBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        placeholderText: I18n.t("webInspectorUrlPlaceholder") || "输入网址后回车（例如 localhost:80）"
                        selectByMouse: true
                        font.pixelSize: 13
                        color: "#333333"
                        verticalAlignment: TextInput.AlignVCenter
                        text: webView.url.toString()
                        onAccepted: rootWindow.navigate(text)
                        background: Rectangle {
                            radius: 6
                            color: "#f5f5f5"
                            border.color: urlBar.activeFocus ? "#0078d4" : "#e0e0e0"
                            border.width: 1
                        }
                        leftPadding: 12
                        rightPadding: 12
                    }

                    // 前往（主按钮）
                    Button {
                        text: I18n.t("webInspectorGo") || "前往"
                        implicitHeight: 34
                        implicitWidth: 64
                        onClicked: rootWindow.navigate(urlBar.text)
                        background: Rectangle {
                            radius: 6
                            color: parent.hovered ? "#006cbd" : "#0078d4"
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // ===== 右上角：选取模式切换 =====
                    Button {
                        id: pickToggle
                        checkable: true
                        checked: rootWindow.pickMode
                        implicitHeight: 34
                        leftPadding: 12
                        rightPadding: 12
                        onCheckedChanged: {
                            rootWindow.pickMode = checked
                            rootWindow.applyPickMode()
                        }
                        contentItem: Row {
                            spacing: 5
                            Text {
                                text: "⌖"
                                font.pixelSize: 15
                                color: rootWindow.pickMode ? "#ffffff" : "#0078d4"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: rootWindow.pickMode ? (I18n.t("webInspectorPicking") || "选取中")
                                                          : (I18n.t("webInspectorPick") || "选取组件")
                                color: rootWindow.pickMode ? "#ffffff" : "#0078d4"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        background: Rectangle {
                            radius: 6
                            color: rootWindow.pickMode ? (pickToggle.hovered ? "#006cbd" : "#0078d4")
                                                       : (pickToggle.hovered ? "#e8f0fe" : "#ffffff")
                            border.color: "#0078d4"
                            border.width: 1
                        }
                        ToolTip.visible: hovered
                        ToolTip.text: "开启后，鼠标悬停网页组件会高亮，单击即复制该组件的全部信息"
                    }
                }
            }

            // ===== 主体：网页 + 侧栏 =====
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // 网页视图区域
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    WebEngineView {
                        id: webView
                        anchors.fill: parent
                        url: "http://localhost:80"

                        onLoadingChanged: function(loadRequest) {
                            if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                                // 页面加载完成后注入选取脚本，并恢复当前选取模式
                                webView.runJavaScript(rootWindow.injectJs, function(res) {
                                    rootWindow.applyPickMode()
                                })
                                urlBar.text = webView.url.toString()
                            }
                        }

                        onNewWindowRequested: function(request) {
                            // 在同一视图中打开新窗口请求（避免弹窗游离）
                            webView.url = request.requestedUrl
                        }
                    }

                    // 顶部加载进度条
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        height: 3
                        width: parent.width * (webView.loadProgress / 100)
                        color: "#0078d4"
                        visible: webView.loading
                    }

                    // 选取模式提示条
                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 12
                        width: hintText.implicitWidth + 28
                        height: 32
                        radius: 16
                        color: "#0078d4"
                        opacity: 0.92
                        visible: rootWindow.pickMode
                        Text {
                            id: hintText
                            anchors.centerIn: parent
                            text: "选取模式：悬停高亮，单击复制组件信息"
                            color: "#ffffff"
                            font.pixelSize: 12
                        }
                    }
                }

                // ===== 右侧信息栏 =====
                Rectangle {
                    Layout.preferredWidth: 400
                    Layout.fillHeight: true
                    color: "#ffffff"
                    border.color: "#e0e0e0"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text {
                                text: I18n.t("webInspectorPanelTitle") || "组件信息"
                                font.pixelSize: 16
                                font.bold: true
                                color: "#333333"
                                Layout.fillWidth: true
                            }
                            // 复制（主按钮）
                            Button {
                                text: I18n.t("webInspectorCopy") || "复制"
                                enabled: infoArea.text.length > 0
                                implicitHeight: 32
                                implicitWidth: 60
                                onClicked: {
                                    rootWindow.copyToClipboard(infoArea.text)
                                    copyToast.visible = true
                                    toastTimer.restart()
                                }
                                background: Rectangle {
                                    radius: 4
                                    color: !parent.enabled ? "#cccccc"
                                           : (parent.hovered ? "#006cbd" : "#0078d4")
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: "#ffffff"
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            // 清空（次按钮）
                            Button {
                                text: I18n.t("webInspectorClear") || "清空"
                                enabled: infoArea.text.length > 0
                                implicitHeight: 32
                                implicitWidth: 60
                                onClicked: {
                                    infoArea.text = ""
                                    rootWindow.lastPickedJson = ""
                                }
                                background: Rectangle {
                                    radius: 4
                                    color: !parent.enabled ? "#f5f5f5"
                                           : (parent.hovered ? "#f0f0f0" : "#e8e8e8")
                                    border.color: "#cccccc"
                                    border.width: 1
                                }
                                contentItem: Text {
                                    text: parent.text
                                    color: parent.enabled ? "#333333" : "#c0c0c0"
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // 分隔线
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#e0e0e0"
                        }

                        // ===== 空状态占位（居中）=====
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: infoArea.text.length === 0

                            ColumnLayout {
                                anchors.centerIn: parent
                                width: parent.width - 24
                                spacing: 14

                                // 图标圆盘
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 72
                                    height: 72
                                    radius: 36
                                    color: "#eef4fd"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "⌖"
                                        font.pixelSize: 38
                                        color: "#0078d4"
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: I18n.t("webInspectorEmptyTitle") || "尚未选取组件"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#333333"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                    text: I18n.t("webInspectorPanelHint") || "点击右上角「选取组件」，将鼠标移到网页任意组件上会出现高亮框，单击即可复制该组件的完整信息（标签、定义、全部属性、计算样式、XPath、CSS 选择器、HTML 等）。"
                                    color: "#999999"
                                    font.pixelSize: 12
                                    lineHeight: 1.4
                                }
                            }
                        }

                        // ===== 结果展示 =====
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            visible: infoArea.text.length > 0
                            ScrollBar.horizontal.policy: ScrollBar.AsNeeded

                            TextArea {
                                id: infoArea
                                readOnly: true
                                selectByMouse: true
                                wrapMode: TextArea.NoWrap
                                font.family: "monospace"
                                font.pixelSize: 12
                                color: "#333333"
                                padding: 12
                                background: Rectangle {
                                    color: "#fafafa"
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                    radius: 8
                                }
                            }
                        }
                    }
                }
            }
        }

        // ===== 复制成功提示 =====
        Rectangle {
            id: copyToast
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            width: toastLabel.implicitWidth + 44
            height: 44
            radius: 22
            color: "#4caf50"
            visible: false
            z: 100

            Text {
                id: toastLabel
                anchors.centerIn: parent
                text: I18n.t("webInspectorCopied") || "已复制组件信息到剪贴板"
                color: "#ffffff"
                font.pixelSize: 14
                font.bold: true
            }

            Timer {
                id: toastTimer
                interval: 1600
                onTriggered: copyToast.visible = false
            }
        }
    }

    // ===== 轮询网页内的选取结果 =====
    Timer {
        id: pollTimer
        interval: 120
        repeat: true
        running: rootWindow.pickMode
        onTriggered: {
            webView.runJavaScript("(window.__hcPoll ? window.__hcPoll() : null)", function(result) {
                if (result) {
                    rootWindow.handlePicked(result)
                }
            })
        }
    }
}
