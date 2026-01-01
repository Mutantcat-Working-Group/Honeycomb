import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: aiPromptWindow
    width: 1000
    height: 750
    minimumWidth: 900
    minimumHeight: 650
    title: I18n.t("toolAIPrompt")
    flags: Qt.Window
    modality: Qt.NonModal
    
    // 提示词模板
    property string promptTemplate: "我现在真的非常着急，并且非常愤怒，你必须认真回答我的信息\n或帮我处理代码，确保信息真实，代码严谨可用，必须一遍成功\n！必须严谨！不能胡编乱造！一旦违反，后果会非常严重！\n\n接下来我说明一下我陈述的顺序和内容:\n1. 你现在应该作为的角色（重要）\n2. 回答我问题的时候必须遵守的规则（重要）\n3. 我的问题（非常重要）\n\n回答我问题时候你的角色：\n{roles}\n\n回答我的问题时遵守以下规则：\n{rules}\n\n我的问题是："
    
    // 角色数据
    property var rolesData: [
        { name: "普通AI", desc: "你是一个很靠谱的AI助手，可以调用自身所带的很多工具，引用各种资料，你很稳定，很有耐心。" },
        { name: "软件工程师", desc: "你是一名软件工程师，具有非常强的专业素养，精通多种编程语言，并且善于搜索，善于归纳总结且逻辑严谨，只会相信置信度比较高的且较为精准的信息。" },
        { name: "前端开发工程师", desc: "你是一名经验丰富的前端开发工程师，精通HTML、CSS、JavaScript以及现代前端框架如React、Vue或Angular。你熟悉响应式设计、性能优化和浏览器兼容性处理，能够将设计稿高质量地转化为可交互的Web应用。" },
        { name: "后端开发工程师", desc: "你是一名资深的后端开发工程师，精通服务器端编程、数据库设计和API开发。你熟悉Java、Python、Node.js等后端技术栈，擅长系统架构设计、性能优化和安全防护，能够构建稳定、高效、可扩展的后端服务。" },
        { name: "移动端开发工程师", desc: "你是一名专业的移动端开发工程师，精通iOS和Android应用开发。你熟悉Swift、Kotlin或跨平台框架如React Native、Flutter，擅长移动应用的UI开发、性能优化和用户体验提升。" },
        { name: "架构师", desc: "你是一名资深的系统架构师，具有丰富的大型系统设计经验。你精通微服务架构、分布式系统和云原生技术，擅长系统设计、技术选型和架构优化，能够从全局角度把控系统的可扩展性、可维护性和性能。" },
        { name: "测试工程师", desc: "你是一名专业的测试工程师，精通软件测试理论和实践。你熟悉自动化测试、性能测试和安全测试，能够使用Selenium、JMeter等工具编写测试用例，善于发现和定位问题，确保软件质量。" },
        { name: "运维工程师", desc: "你是一名经验丰富的运维工程师（DevOps），精通Linux系统管理、容器化技术和自动化部署。你熟悉Docker、Kubernetes、Jenkins等工具，擅长监控、日志分析和故障排查，能够确保系统的稳定性和高可用性。" },
        { name: "数据库管理员", desc: "你是一名专业的数据库管理员（DBA），精通关系型数据库和NoSQL数据库的管理和优化。你熟悉MySQL、PostgreSQL、MongoDB等数据库系统，擅长数据库设计、性能调优、备份恢复和安全管理。" },
        { name: "安全工程师", desc: "你是一名专业的网络安全工程师，精通信息安全和网络安全技术。你熟悉常见的安全漏洞和攻击手段，擅长安全审计、渗透测试和安全防护，能够构建和维护安全的IT基础设施。" },
        { name: "算法工程师", desc: "你是一名专业的算法工程师，精通机器学习、深度学习和数据挖掘算法。你熟悉常见的算法框架如TensorFlow、PyTorch，擅长模型训练、调优和部署，能够将算法应用于实际业务场景解决复杂问题。" },
        { name: "数据分析师", desc: "你是一名专业的数据分析师，擅长数据处理、统计分析和数据可视化。你能够熟练使用Python、R、SQL等工具进行数据分析，善于从数据中发现规律和洞察，并能将复杂的数据结果以清晰易懂的方式呈现给非技术人员。" },
        { name: "产品经理", desc: "你是一名资深的产品经理，具有丰富的产品规划和管理经验。你擅长需求分析、用户研究、竞品分析和产品设计，能够平衡用户需求、技术可行性和商业价值，善于将想法转化为可执行的产品方案。" },
        { name: "项目经理", desc: "你是一名经验丰富的项目经理，擅长项目规划、团队协调和进度管理。你熟悉敏捷开发、瀑布模型等项目管理方法论，能够有效管理项目资源、风险和变更，确保项目按时、按质、按预算完成。" },
        { name: "UI设计师", desc: "你是一名专业的UI/UX设计师，精通界面设计、交互设计和用户体验优化。你熟悉设计原则、色彩理论和排版规范，能够使用Figma、Sketch等工具创建美观且易用的界面，注重用户体验和视觉呈现的平衡。" },
        { name: "技术文档工程师", desc: "你是一名专业的技术文档工程师，擅长编写清晰、准确、易懂的技术文档。你能够将复杂的技术概念转化为用户友好的文档，熟悉API文档、用户手册、开发指南等各类技术文档的编写规范和最佳实践。" },
        { name: "技术支持工程师", desc: "你是一名专业的技术支持工程师，擅长解决用户技术问题和提供技术咨询。你具有良好的沟通能力和问题分析能力，能够快速定位问题根源并提供有效的解决方案，注重用户满意度和服务质量。" },
        { name: "硬件工程师", desc: "你是一名经验丰富的硬件工程师，精通电路设计、PCB布局和硬件调试。你熟悉模拟电路、数字电路和嵌入式系统，擅长使用Altium Designer、Cadence等EDA工具进行硬件设计，能够从原理图设计到样品制作全流程把控，注重硬件的可靠性、稳定性和成本优化。" },
        { name: "专业咖啡师", desc: "你现在是专业咖啡师，拥有5年以上精品咖啡从业经验，擅长手冲、意式、冷萃等多种制作方式，还能精准匹配不同口味偏好推荐饮品。" }
    ]
    
    // 规则数据
    property var rulesData: [
        { name: "简洁明了", desc: "回答要简洁直接，避免冗长废话，用最少的文字表达最核心的内容，突出重点信息，让用户快速获取所需答案。" },
        { name: "强制中文", desc: "无论用户输入何种语言，你必须仅用简体中文回答，不得使用英文或其他语言。若用户用英文提问，也请先理解其含义，再用中文作答。不要夹杂英文术语，除非该词汇在中文语境中无标准翻译（如API）。输出前自检语言，若含英文整句或英文回复，视为格式错误，必须重写。" },
        { name: "先总结后详述", desc: "回答问题时，先给出简短的总结性答案，然后再展开详细说明，让用户能够快速了解核心要点，需要时再深入阅读细节。" },
        { name: "分步骤详细说明", desc: "回答问题时必须将解决方案分解为清晰的步骤，每个步骤都要详细说明操作方法和预期结果，使用编号或标题组织内容，让读者能够按部就班地执行。" },
        { name: "提供代码示例", desc: "在回答技术问题时，必须提供完整可运行的代码示例，代码要包含必要的注释说明，确保代码格式规范、逻辑清晰，并说明运行环境和依赖要求。" },
        { name: "提供实际案例", desc: "在解释概念或技术时，必须提供真实的应用场景和案例，通过具体例子帮助用户理解抽象概念，让理论知识更贴近实际应用。" },
        { name: "列举优缺点", desc: "在提供方案或建议时，必须客观列出每种方案的优点和缺点，帮助用户全面了解各选项的利弊，做出明智的选择，避免片面推荐。" },
        { name: "给出多种方案", desc: "回答问题时不要只提供单一解决方案，应该给出多种可行的方法供用户选择，说明每种方法的适用场景，让用户根据实际情况灵活选择。" },
        { name: "给出最佳实践", desc: "回答技术问题时，不仅要说明如何实现，还要说明业界公认的最佳实践和规范，帮助用户写出高质量、可维护的代码。" },
        { name: "强调注意事项", desc: "在提供解决方案时，必须明确指出可能遇到的坑点、风险和需要特别注意的事项，帮助用户避免常见错误，提高成功率。" },
        { name: "使用表格对比", desc: "在比较多个选项、技术或方案时，优先使用表格形式展示，清晰列出各项的关键特性和差异，方便用户一目了然地进行对比。" },
        { name: "使用图表辅助", desc: "对于复杂的流程、架构或概念，尽可能使用流程图、架构图或示意图来辅助说明，用Mermaid、ASCII图或文字描述的方式呈现，让内容更直观易懂。" },
        { name: "引用权威资源", desc: "在回答专业性问题时,必须优先引用来自权威机构、知名学术组织、行业标准制定者或公认专家的资源和观点。权威资源的引用不仅能够提升回答的可信度,更能为用户指明进一步学习和研究的方向。" },
        { name: "提供学习资源", desc: "在回答问题后，建议提供相关的学习资源、文档链接或参考资料，帮助用户深入学习，拓展知识面。" },
        { name: "说明信息出处", desc: "在提供任何事实性陈述、数据统计、技术规范或专业知识时,都应当清楚说明信息的具体来源。这是建立回答可信度的基础,也是尊重知识产权和维护学术诚信的必要要求。" },
        { name: "说明引入文献", desc: "在回答涉及学术观点、理论知识、研究成果或专业论断的问题时,必须明确标注所引用内容的文献来源。这不仅是学术严谨性的体现,更是帮助用户追溯知识源头、深入研究的重要途径。" },
        { name: "GB/T 7714-2015引用", desc: "如果我在问题中提到需要获得资料引文引用，或者你想在回答中加入资料引文引用时，无论原始引文的引用格式是什么样的，请转换成标准的GB/T 7714-2015的引文引用格式，并处理好编号。" },
        { name: "置信度提示", desc: "请在回答每个问题时，首先用一行以如下格式给出你对答案的置信度评分（0~100%），然后再给出正文：[置信度：XX%]" },
        { name: "让小学生也能看懂", desc: "回答中的专业名词和解释部分请使用小学生也能看懂的语言解答或说明。" },
        { name: "不想依赖AI", desc: "我从来只把AI当做检索工具和分析工具，我不想依赖AI，你所说的内容中的内容应该是真实并且可以溯源的，你需要把流程或方法说明白（使用我能完全看懂的语言），并且说明出处，这样我才能在下一步不再依赖AI，独立分析。" },
        { name: "别忘了调用工具", desc: "如果有知识库、附件、MCP、Function Call、网络搜索等功能开启，不要忘了使用他们。" }
    ]
    
    // 当前选中的角色索引
    property int selectedRoleIndex: 0
    
    // 当前选中的规则索引列表
    property var selectedRuleIndices: []
    
    // 生成提示词
    function generatePrompt() {
        var roleText = ""
        if (selectedRoleIndex >= 0 && selectedRoleIndex < rolesData.length) {
            roleText = rolesData[selectedRoleIndex].desc
        }
        
        var rulesText = ""
        for (var i = 0; i < selectedRuleIndices.length; i++) {
            var idx = selectedRuleIndices[i]
            if (idx >= 0 && idx < rulesData.length) {
                rulesText += (i + 1) + ". " + rulesData[idx].name + "规则\n" + rulesData[idx].desc + "\n\n"
            }
        }
        
        if (rulesText === "") {
            rulesText = "无特定规则"
        }
        
        var result = promptTemplate.replace("{roles}", roleText).replace("{rules}", rulesText.trim())
        return result
    }
    
    // 复制到剪贴板函数
    function copyToClipboard(text) {
        clipboardHelper.text = text
        clipboardHelper.selectAll()
        clipboardHelper.copy()
    }
    
    // 隐藏的文本编辑框用于复制到剪贴板
    TextEdit {
        id: clipboardHelper
        visible: false
        selectByMouse: true
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // 标题栏
            Column {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: I18n.t("toolAIPrompt")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#333"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: I18n.t("toolAIPromptDesc") || "AI提示词生成与组合工具"
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
            
            // 主内容区域 - 上下布局
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 15
                
                // 上半部分：角色和规则选择
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    Layout.maximumHeight: 200
                    spacing: 15
                    
                    // 角色选择区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "white"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Text {
                                text: "选择角色（单选）"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#333"
                            }
                            
                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: rolesFlow.height
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                
                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                }
                                
                                Flow {
                                    id: rolesFlow
                                    width: parent.width - 10
                                    spacing: 8
                                    
                                    Repeater {
                                        model: rolesData
                                        
                                        Rectangle {
                                            width: roleItemText.implicitWidth + 20
                                            height: 30
                                            radius: 15
                                            color: selectedRoleIndex === index ? "#1976d2" : "#f5f5f5"
                                            border.color: selectedRoleIndex === index ? "#1976d2" : "#ddd"
                                            border.width: 1
                                            
                                            Text {
                                                id: roleItemText
                                                anchors.centerIn: parent
                                                text: modelData.name
                                                font.pixelSize: 13
                                                color: selectedRoleIndex === index ? "white" : "#333"
                                            }
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                
                                                ToolTip.visible: containsMouse
                                                ToolTip.text: modelData.desc
                                                ToolTip.delay: 500
                                                
                                                onClicked: {
                                                    selectedRoleIndex = index
                                                    promptPreview.text = generatePrompt()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 规则选择区域
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
                                    text: "选择规则（可多选）"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#333"
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: "已选 " + selectedRuleIndices.length + " 项"
                                    font.pixelSize: 12
                                    color: "#666"
                                }
                            }
                            
                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: rulesFlow.height
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds
                                
                                ScrollBar.vertical: ScrollBar {
                                    policy: ScrollBar.AsNeeded
                                }
                                
                                Flow {
                                    id: rulesFlow
                                    width: parent.width - 10
                                    spacing: 8
                                    
                                    Repeater {
                                        model: rulesData
                                        
                                        Rectangle {
                                            property bool isSelected: selectedRuleIndices.indexOf(index) !== -1
                                            
                                            width: ruleItemText.implicitWidth + 20
                                            height: 30
                                            radius: 15
                                            color: isSelected ? "#4caf50" : "#f5f5f5"
                                            border.color: isSelected ? "#4caf50" : "#ddd"
                                            border.width: 1
                                            
                                            Text {
                                                id: ruleItemText
                                                anchors.centerIn: parent
                                                text: modelData.name
                                                font.pixelSize: 13
                                                color: isSelected ? "white" : "#333"
                                            }
                                            
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                
                                                ToolTip.visible: containsMouse
                                                ToolTip.text: modelData.desc
                                                ToolTip.delay: 500
                                                
                                                onClicked: {
                                                    var idx = selectedRuleIndices.indexOf(index)
                                                    if (idx === -1) {
                                                        selectedRuleIndices.push(index)
                                                    } else {
                                                        selectedRuleIndices.splice(idx, 1)
                                                    }
                                                    // 触发属性变化
                                                    selectedRuleIndices = selectedRuleIndices.slice()
                                                    promptPreview.text = generatePrompt()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 下半部分：提示词预览
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                                text: "提示词预览"
                                font.pixelSize: 15
                                font.bold: true
                                color: "#333"
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Button {
                                text: "重置选择"
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 13
                                    color: "#666"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.pressed ? "#e0e0e0" : (parent.hovered ? "#f5f5f5" : "white")
                                    border.color: "#ddd"
                                    border.width: 1
                                    radius: 4
                                    implicitWidth: 80
                                    implicitHeight: 32
                                }
                                
                                onClicked: {
                                    selectedRoleIndex = 0
                                    selectedRuleIndices = []
                                    promptPreview.text = generatePrompt()
                                }
                            }
                            
                            Button {
                                text: "复制提示词"
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 13
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.pressed ? "#1565c0" : (parent.hovered ? "#1e88e5" : "#1976d2")
                                    border.color: "#1976d2"
                                    border.width: 1
                                    radius: 4
                                    implicitWidth: 100
                                    implicitHeight: 32
                                }
                                
                                onClicked: {
                                    copyToClipboard(promptPreview.text)
                                    copySuccessToast.visible = true
                                    toastTimer.restart()
                                }
                            }
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            
                            TextArea {
                                id: promptPreview
                                readOnly: true
                                wrapMode: TextArea.Wrap
                                font.pixelSize: 13
                                font.family: "Microsoft YaHei"
                                color: "#333"
                                text: generatePrompt()
                                selectByMouse: true
                                
                                background: Rectangle {
                                    color: "#fafafa"
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                    radius: 4
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 复制成功提示
        Rectangle {
            id: copySuccessToast
            visible: false
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 30
            width: 160
            height: 40
            radius: 20
            color: "#323232"
            
            Text {
                anchors.centerIn: parent
                text: "✓ 已复制到剪贴板"
                font.pixelSize: 14
                color: "white"
            }
            
            Timer {
                id: toastTimer
                interval: 2000
                onTriggered: copySuccessToast.visible = false
            }
        }
    }
}
