import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: registerRefWindow
    width: 1200
    height: 750
    title: "通用寄存器速查"
    flags: Qt.Window
    modality: Qt.NonModal
    
    property var architectures: [
        {
            name: "x86 (16位)",
            bitWidth: "16位",
            count: "14个通用寄存器 + 6个段寄存器",
            application: "早期PC、DOS系统、实模式",
            registers: [
                {name: "AX", type: "通用", desc: "累加器，算术运算"},
                {name: "BX", type: "通用", desc: "基址寄存器，内存寻址"},
                {name: "CX", type: "通用", desc: "计数器，循环计数"},
                {name: "DX", type: "通用", desc: "数据寄存器，I/O操作"},
                {name: "SI", type: "通用", desc: "源索引寄存器"},
                {name: "DI", type: "通用", desc: "目的索引寄存器"},
                {name: "BP", type: "通用", desc: "基址指针，栈帧基址"},
                {name: "SP", type: "通用", desc: "栈指针"},
                {name: "IP", type: "特殊", desc: "指令指针(程序计数器)"},
                {name: "FLAGS", type: "特殊", desc: "标志寄存器(CF/ZF/SF/OF等)"},
                {name: "CS", type: "段", desc: "代码段寄存器"},
                {name: "DS", type: "段", desc: "数据段寄存器"},
                {name: "SS", type: "段", desc: "栈段寄存器"},
                {name: "ES", type: "段", desc: "附加段寄存器"},
                {name: "FS", type: "段", desc: "附加段寄存器(80386+)"},
                {name: "GS", type: "段", desc: "附加段寄存器(80386+)"}
            ]
        },
        {
            name: "x86-32 (IA-32)",
            bitWidth: "32位",
            count: "8个通用寄存器 + 6个段寄存器 + 控制寄存器",
            application: "32位Windows/Linux、保护模式、现代x86系统",
            registers: [
                {name: "EAX", type: "通用", desc: "累加器，返回值"},
                {name: "EBX", type: "通用", desc: "基址寄存器"},
                {name: "ECX", type: "通用", desc: "计数器"},
                {name: "EDX", type: "通用", desc: "数据寄存器"},
                {name: "ESI", type: "通用", desc: "源索引"},
                {name: "EDI", type: "通用", desc: "目的索引"},
                {name: "EBP", type: "通用", desc: "栈帧基址指针"},
                {name: "ESP", type: "通用", desc: "栈指针"},
                {name: "EIP", type: "特殊", desc: "指令指针"},
                {name: "EFLAGS", type: "特殊", desc: "32位标志寄存器"},
                {name: "CR0-CR4", type: "控制", desc: "控制寄存器(分页/保护模式)"},
                {name: "DR0-DR7", type: "调试", desc: "调试寄存器"},
                {name: "CS/DS/SS/ES/FS/GS", type: "段", desc: "段寄存器"}
            ]
        },
        {
            name: "x86-64 (AMD64)",
            bitWidth: "64位",
            count: "16个通用寄存器 + 段寄存器 + 控制寄存器",
            application: "64位Windows/Linux、现代服务器、高性能计算",
            registers: [
                {name: "RAX", type: "通用", desc: "累加器，返回值"},
                {name: "RBX", type: "通用", desc: "基址寄存器"},
                {name: "RCX", type: "通用", desc: "计数器，第4个参数(Windows)"},
                {name: "RDX", type: "通用", desc: "数据寄存器，第3个参数"},
                {name: "RSI", type: "通用", desc: "源索引，第2个参数(Linux)"},
                {name: "RDI", type: "通用", desc: "目的索引，第1个参数(Linux)"},
                {name: "RBP", type: "通用", desc: "栈帧基址指针"},
                {name: "RSP", type: "通用", desc: "栈指针"},
                {name: "R8", type: "通用", desc: "第5个参数"},
                {name: "R9", type: "通用", desc: "第6个参数"},
                {name: "R10", type: "通用", desc: "临时寄存器"},
                {name: "R11", type: "通用", desc: "临时寄存器"},
                {name: "R12-R15", type: "通用", desc: "通用寄存器"},
                {name: "RIP", type: "特殊", desc: "指令指针"},
                {name: "RFLAGS", type: "特殊", desc: "64位标志寄存器"},
                {name: "XMM0-XMM15", type: "SIMD", desc: "128位SSE寄存器"},
                {name: "YMM0-YMM15", type: "SIMD", desc: "256位AVX寄存器"},
                {name: "ZMM0-ZMM31", type: "SIMD", desc: "512位AVX-512寄存器"}
            ]
        },
        {
            name: "ARM (32位)",
            bitWidth: "32位",
            count: "16个通用寄存器 + CPSR",
            application: "嵌入式系统、移动设备、IoT、STM32",
            registers: [
                {name: "R0", type: "通用", desc: "参数/返回值/临时寄存器"},
                {name: "R1", type: "通用", desc: "参数/返回值/临时寄存器"},
                {name: "R2", type: "通用", desc: "参数/临时寄存器"},
                {name: "R3", type: "通用", desc: "参数/临时寄存器"},
                {name: "R4-R10", type: "通用", desc: "变量寄存器(需保存)"},
                {name: "R11 (FP)", type: "特殊", desc: "帧指针"},
                {name: "R12 (IP)", type: "特殊", desc: "内部过程调用寄存器"},
                {name: "R13 (SP)", type: "特殊", desc: "栈指针"},
                {name: "R14 (LR)", type: "特殊", desc: "链接寄存器(返回地址)"},
                {name: "R15 (PC)", type: "特殊", desc: "程序计数器"},
                {name: "CPSR", type: "状态", desc: "当前程序状态寄存器"},
                {name: "SPSR", type: "状态", desc: "保存的程序状态寄存器"}
            ]
        },
        {
            name: "ARM64 (AArch64)",
            bitWidth: "64位",
            count: "31个通用寄存器 + SP + PC",
            application: "现代移动设备、Apple Silicon、服务器",
            registers: [
                {name: "X0-X7", type: "通用", desc: "参数和返回值寄存器"},
                {name: "X8", type: "通用", desc: "间接结果寄存器"},
                {name: "X9-X15", type: "通用", desc: "临时寄存器"},
                {name: "X16-X17 (IP0/IP1)", type: "特殊", desc: "内部过程调用寄存器"},
                {name: "X18", type: "特殊", desc: "平台寄存器"},
                {name: "X19-X28", type: "通用", desc: "被调用者保存寄存器"},
                {name: "X29 (FP)", type: "特殊", desc: "帧指针"},
                {name: "X30 (LR)", type: "特殊", desc: "链接寄存器"},
                {name: "SP", type: "特殊", desc: "栈指针"},
                {name: "PC", type: "特殊", desc: "程序计数器"},
                {name: "XZR", type: "特殊", desc: "零寄存器(读取为0)"},
                {name: "V0-V31", type: "SIMD", desc: "128位NEON/浮点寄存器"},
                {name: "PSTATE", type: "状态", desc: "处理器状态"}
            ]
        },
        {
            name: "RISC-V (RV32I)",
            bitWidth: "32位",
            count: "32个通用寄存器",
            application: "开源处理器、嵌入式、教学、IoT",
            registers: [
                {name: "x0 (zero)", type: "特殊", desc: "硬连线为0"},
                {name: "x1 (ra)", type: "特殊", desc: "返回地址"},
                {name: "x2 (sp)", type: "特殊", desc: "栈指针"},
                {name: "x3 (gp)", type: "特殊", desc: "全局指针"},
                {name: "x4 (tp)", type: "特殊", desc: "线程指针"},
                {name: "x5-x7 (t0-t2)", type: "临时", desc: "临时寄存器"},
                {name: "x8 (s0/fp)", type: "保存", desc: "保存寄存器/帧指针"},
                {name: "x9 (s1)", type: "保存", desc: "保存寄存器"},
                {name: "x10-x11 (a0-a1)", type: "参数", desc: "参数/返回值"},
                {name: "x12-x17 (a2-a7)", type: "参数", desc: "参数寄存器"},
                {name: "x18-x27 (s2-s11)", type: "保存", desc: "保存寄存器"},
                {name: "x28-x31 (t3-t6)", type: "临时", desc: "临时寄存器"},
                {name: "pc", type: "特殊", desc: "程序计数器"},
                {name: "CSR", type: "控制", desc: "控制状态寄存器"}
            ]
        },
        {
            name: "RISC-V (RV64I)",
            bitWidth: "64位",
            count: "32个通用寄存器",
            application: "高性能RISC-V、服务器、HPC",
            registers: [
                {name: "x0-x31", type: "通用", desc: "与RV32I相同，但为64位宽"},
                {name: "f0-f31", type: "浮点", desc: "64位浮点寄存器(F/D扩展)"},
                {name: "v0-v31", type: "向量", desc: "向量寄存器(V扩展)"},
                {name: "pc", type: "特殊", desc: "64位程序计数器"}
            ]
        },
        {
            name: "MIPS (32位)",
            bitWidth: "32位",
            count: "32个通用寄存器 + HI/LO",
            application: "路由器、嵌入式系统、教学",
            registers: [
                {name: "$0 (zero)", type: "特殊", desc: "恒为0"},
                {name: "$1 (at)", type: "特殊", desc: "汇编器临时寄存器"},
                {name: "$2-$3 (v0-v1)", type: "返回值", desc: "函数返回值"},
                {name: "$4-$7 (a0-a3)", type: "参数", desc: "函数参数"},
                {name: "$8-$15 (t0-t7)", type: "临时", desc: "临时寄存器"},
                {name: "$16-$23 (s0-s7)", type: "保存", desc: "保存寄存器"},
                {name: "$24-$25 (t8-t9)", type: "临时", desc: "临时寄存器"},
                {name: "$26-$27 (k0-k1)", type: "内核", desc: "内核保留"},
                {name: "$28 (gp)", type: "特殊", desc: "全局指针"},
                {name: "$29 (sp)", type: "特殊", desc: "栈指针"},
                {name: "$30 (fp/s8)", type: "特殊", desc: "帧指针"},
                {name: "$31 (ra)", type: "特殊", desc: "返回地址"},
                {name: "HI", type: "特殊", desc: "乘除法高位结果"},
                {name: "LO", type: "特殊", desc: "乘除法低位结果"},
                {name: "PC", type: "特殊", desc: "程序计数器"}
            ]
        },
        {
            name: "PowerPC (32位)",
            bitWidth: "32位",
            count: "32个通用寄存器 + 特殊寄存器",
            application: "嵌入式、游戏机(PS3/Xbox360)、服务器",
            registers: [
                {name: "r0", type: "通用", desc: "临时寄存器"},
                {name: "r1", type: "特殊", desc: "栈指针"},
                {name: "r2", type: "特殊", desc: "TOC指针(64位)"},
                {name: "r3-r10", type: "参数", desc: "参数和返回值"},
                {name: "r11-r12", type: "临时", desc: "临时寄存器"},
                {name: "r13", type: "特殊", desc: "小数据区指针"},
                {name: "r14-r31", type: "保存", desc: "非易失性寄存器"},
                {name: "LR", type: "特殊", desc: "链接寄存器"},
                {name: "CTR", type: "特殊", desc: "计数寄存器"},
                {name: "CR", type: "特殊", desc: "条件寄存器"},
                {name: "XER", type: "特殊", desc: "定点异常寄存器"},
                {name: "f0-f31", type: "浮点", desc: "浮点寄存器"}
            ]
        },
        {
            name: "AVR (8位)",
            bitWidth: "8位",
            count: "32个通用寄存器",
            application: "Arduino、微控制器、嵌入式",
            registers: [
                {name: "r0-r1", type: "通用", desc: "临时寄存器(乘法结果)"},
                {name: "r2-r17", type: "通用", desc: "通用寄存器"},
                {name: "r18-r27", type: "通用", desc: "通用寄存器"},
                {name: "r26-r27 (X)", type: "指针", desc: "X指针(XL:XH)"},
                {name: "r28-r29 (Y)", type: "指针", desc: "Y指针(YL:YH)"},
                {name: "r30-r31 (Z)", type: "指针", desc: "Z指针(ZL:ZH)"},
                {name: "SP", type: "特殊", desc: "栈指针(SPL:SPH)"},
                {name: "PC", type: "特殊", desc: "程序计数器"},
                {name: "SREG", type: "状态", desc: "状态寄存器"}
            ]
        },
        {
            name: "8051 (8位)",
            bitWidth: "8位",
            count: "8个通用寄存器 + 特殊功能寄存器",
            application: "经典微控制器、工控、教学",
            registers: [
                {name: "R0-R7", type: "通用", desc: "8个通用寄存器(4组bank)"},
                {name: "A", type: "特殊", desc: "累加器"},
                {name: "B", type: "特殊", desc: "B寄存器(乘除法)"},
                {name: "DPTR", type: "特殊", desc: "数据指针(DPH:DPL)"},
                {name: "SP", type: "特殊", desc: "栈指针"},
                {name: "PC", type: "特殊", desc: "程序计数器"},
                {name: "PSW", type: "状态", desc: "程序状态字"},
                {name: "P0-P3", type: "I/O", desc: "I/O端口寄存器"},
                {name: "IE", type: "控制", desc: "中断使能寄存器"},
                {name: "IP", type: "控制", desc: "中断优先级寄存器"},
                {name: "TCON", type: "控制", desc: "定时器控制寄存器"},
                {name: "SCON", type: "控制", desc: "串口控制寄存器"}
            ]
        },
        {
            name: "MSP430 (16位)",
            bitWidth: "16位",
            count: "16个通用寄存器",
            application: "超低功耗MCU、传感器节点、便携设备",
            registers: [
                {name: "R0 (PC)", type: "特殊", desc: "程序计数器"},
                {name: "R1 (SP)", type: "特殊", desc: "栈指针"},
                {name: "R2 (SR)", type: "特殊", desc: "状态寄存器"},
                {name: "R3 (CG)", type: "特殊", desc: "常量生成器"},
                {name: "R4-R15", type: "通用", desc: "通用寄存器"}
            ]
        },
        {
            name: "SPARC (32位)",
            bitWidth: "32位",
            count: "32个窗口寄存器(8个全局+24个窗口)",
            application: "Sun工作站、服务器、航天",
            registers: [
                {name: "g0-g7", type: "全局", desc: "全局寄存器(g0恒为0)"},
                {name: "o0-o7", type: "输出", desc: "输出寄存器(o6=sp, o7=返回地址)"},
                {name: "l0-l7", type: "本地", desc: "局部寄存器"},
                {name: "i0-i7", type: "输入", desc: "输入寄存器(i6=fp, i7=返回地址)"},
                {name: "PC", type: "特殊", desc: "程序计数器"},
                {name: "nPC", type: "特殊", desc: "下一条PC"},
                {name: "PSR", type: "状态", desc: "处理器状态寄存器"},
                {name: "WIM", type: "特殊", desc: "窗口无效掩码"},
                {name: "TBR", type: "特殊", desc: "陷阱基址寄存器"}
            ]
        },
        {
            name: "68000 (Motorola)",
            bitWidth: "32位(16位外部总线)",
            count: "8个数据寄存器 + 8个地址寄存器",
            application: "早期Mac、Amiga、Atari、嵌入式",
            registers: [
                {name: "D0-D7", type: "数据", desc: "数据寄存器(32位)"},
                {name: "A0-A6", type: "地址", desc: "地址寄存器(32位)"},
                {name: "A7 (SP)", type: "特殊", desc: "栈指针(用户/系统各一个)"},
                {name: "PC", type: "特殊", desc: "程序计数器"},
                {name: "SR", type: "状态", desc: "状态寄存器(含CCR)"}
            ]
        },
        {
            name: "Z80 (8位)",
            bitWidth: "8位",
            count: "14个通用寄存器 + 备用寄存器组",
            application: "早期游戏机、CP/M系统、嵌入式",
            registers: [
                {name: "A", type: "通用", desc: "累加器"},
                {name: "F", type: "状态", desc: "标志寄存器"},
                {name: "B, C", type: "通用", desc: "BC寄存器对"},
                {name: "D, E", type: "通用", desc: "DE寄存器对"},
                {name: "H, L", type: "通用", desc: "HL寄存器对(间接寻址)"},
                {name: "A', F'", type: "备用", desc: "备用累加器和标志"},
                {name: "B', C', D', E', H', L'", type: "备用", desc: "备用寄存器组"},
                {name: "IX", type: "索引", desc: "索引寄存器X"},
                {name: "IY", type: "索引", desc: "索引寄存器Y"},
                {name: "SP", type: "特殊", desc: "栈指针"},
                {name: "PC", type: "特殊", desc: "程序计数器"},
                {name: "I", type: "特殊", desc: "中断向量寄存器"},
                {name: "R", type: "特殊", desc: "内存刷新寄存器"}
            ]
        }
    ]
    
    property int currentArchIndex: 0
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5
                    
                    Text {
                        text: "处理器架构"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#333333"
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 10
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#e0e0e0"
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ColumnLayout {
                            width: parent.width
                            spacing: 5
                            
                            Repeater {
                                model: architectures.length
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 70
                                    color: currentArchIndex === index ? "#e3f2fd" : (archMouseArea.containsMouse ? "#f5f5f5" : "transparent")
                                    radius: 4
                                    border.color: currentArchIndex === index ? "#2196F3" : "transparent"
                                    border.width: 2
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 2
                                        
                                        Text {
                                            text: architectures[index].name
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: currentArchIndex === index ? "#2196F3" : "#333333"
                                        }
                                        
                                        Text {
                                            text: architectures[index].bitWidth
                                            font.pixelSize: 11
                                            color: "#666666"
                                        }
                                        
                                        Text {
                                            text: architectures[index].count
                                            font.pixelSize: 10
                                            color: "#999999"
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: archMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            currentArchIndex = index
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#f9f9f9"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "通用寄存器速查"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333333"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        color: "#ffffff"
                        border.color: "#2196F3"
                        border.width: 2
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 8
                            
                            Text {
                                text: architectures[currentArchIndex].name
                                font.pixelSize: 20
                                font.bold: true
                                color: "#2196F3"
                            }
                            
                            RowLayout {
                                spacing: 20
                                
                                RowLayout {
                                    spacing: 5
                                    Text {
                                        text: "位宽:"
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: "#666666"
                                    }
                                    Text {
                                        text: architectures[currentArchIndex].bitWidth
                                        font.pixelSize: 13
                                        color: "#333333"
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 5
                                    Text {
                                        text: "寄存器数量:"
                                        font.pixelSize: 13
                                        font.bold: true
                                        color: "#666666"
                                    }
                                    Text {
                                        text: architectures[currentArchIndex].count
                                        font.pixelSize: 13
                                        color: "#333333"
                                    }
                                }
                            }
                            
                            RowLayout {
                                spacing: 5
                                Text {
                                    text: "应用领域:"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#666666"
                                }
                                Text {
                                    text: architectures[currentArchIndex].application
                                    font.pixelSize: 13
                                    color: "#333333"
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e0e0e0"
                        border.width: 1
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                Rectangle {
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 35
                                    color: "#2196F3"
                                    radius: 4
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "寄存器名称"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                                
                                Rectangle {
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 35
                                    color: "#2196F3"
                                    radius: 4
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "类型"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 35
                                    color: "#2196F3"
                                    radius: 4
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "描述/用途"
                                        font.pixelSize: 14
                                        font.bold: true
                                        color: "#ffffff"
                                    }
                                }
                            }
                            
                            ScrollView {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true
                                
                                ColumnLayout {
                                    width: parent.width
                                    spacing: 5
                                    
                                    Repeater {
                                        model: architectures[currentArchIndex].registers
                                        
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 45
                                            color: index % 2 === 0 ? "#f5f5f5" : "#ffffff"
                                            border.color: "#e0e0e0"
                                            border.width: 1
                                            radius: 4
                                            
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 10
                                                
                                                Text {
                                                    Layout.preferredWidth: 150
                                                    text: modelData.name
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: "#2196F3"
                                                    font.family: "Consolas"
                                                }
                                                
                                                Rectangle {
                                                    Layout.preferredWidth: 100
                                                    Layout.preferredHeight: 25
                                                    color: {
                                                        switch(modelData.type) {
                                                            case "通用": return "#4CAF50"
                                                            case "特殊": return "#FF9800"
                                                            case "参数": return "#2196F3"
                                                            case "临时": return "#9C27B0"
                                                            case "保存": return "#00BCD4"
                                                            case "状态": return "#F44336"
                                                            case "控制": return "#E91E63"
                                                            case "SIMD": return "#673AB7"
                                                            case "浮点": return "#009688"
                                                            case "向量": return "#795548"
                                                            default: return "#607D8B"
                                                        }
                                                    }
                                                    radius: 3
                                                    
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.type
                                                        font.pixelSize: 11
                                                        color: "#ffffff"
                                                        font.bold: true
                                                    }
                                                }
                                                
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.desc
                                                    font.pixelSize: 12
                                                    color: "#333333"
                                                    wrapMode: Text.WordWrap
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
