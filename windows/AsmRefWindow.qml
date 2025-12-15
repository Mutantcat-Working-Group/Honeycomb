import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: asmRefWindow
    width: 1200
    height: 750
    title: "汇编指令速查"
    flags: Qt.Window
    modality: Qt.NonModal
    
    property var allInstructions: [
        {arch: "x86", category: "数据传送", name: "MOV", operands: "dest, src", desc: "数据传送: dest = src"},
        {arch: "x86", category: "数据传送", name: "PUSH", operands: "src", desc: "压栈: SP -= size; [SP] = src"},
        {arch: "x86", category: "数据传送", name: "POP", operands: "dest", desc: "出栈: dest = [SP]; SP += size"},
        {arch: "x86", category: "数据传送", name: "XCHG", operands: "op1, op2", desc: "交换: op1 ↔ op2"},
        {arch: "x86", category: "数据传送", name: "LEA", operands: "reg, mem", desc: "加载有效地址: reg = &mem"},
        {arch: "x86", category: "数据传送", name: "MOVSX", operands: "dest, src", desc: "符号扩展传送"},
        {arch: "x86", category: "数据传送", name: "MOVZX", operands: "dest, src", desc: "零扩展传送"},
        {arch: "x86", category: "算术运算", name: "ADD", operands: "dest, src", desc: "加法: dest += src"},
        {arch: "x86", category: "算术运算", name: "SUB", operands: "dest, src", desc: "减法: dest -= src"},
        {arch: "x86", category: "算术运算", name: "MUL", operands: "src", desc: "无符号乘法: AX/EAX/RAX *= src"},
        {arch: "x86", category: "算术运算", name: "IMUL", operands: "src", desc: "有符号乘法"},
        {arch: "x86", category: "算术运算", name: "DIV", operands: "src", desc: "无符号除法: AX/EAX/RAX /= src"},
        {arch: "x86", category: "算术运算", name: "IDIV", operands: "src", desc: "有符号除法"},
        {arch: "x86", category: "算术运算", name: "INC", operands: "dest", desc: "自增: dest++"},
        {arch: "x86", category: "算术运算", name: "DEC", operands: "dest", desc: "自减: dest--"},
        {arch: "x86", category: "算术运算", name: "NEG", operands: "dest", desc: "取负: dest = -dest"},
        {arch: "x86", category: "算术运算", name: "CMP", operands: "op1, op2", desc: "比较(减法但不保存结果)"},
        {arch: "x86", category: "逻辑运算", name: "AND", operands: "dest, src", desc: "按位与: dest &= src"},
        {arch: "x86", category: "逻辑运算", name: "OR", operands: "dest, src", desc: "按位或: dest |= src"},
        {arch: "x86", category: "逻辑运算", name: "XOR", operands: "dest, src", desc: "按位异或: dest ^= src"},
        {arch: "x86", category: "逻辑运算", name: "NOT", operands: "dest", desc: "按位取反: dest = ~dest"},
        {arch: "x86", category: "逻辑运算", name: "TEST", operands: "op1, op2", desc: "测试(与运算但不保存结果)"},
        {arch: "x86", category: "移位运算", name: "SHL", operands: "dest, count", desc: "逻辑左移: dest <<= count"},
        {arch: "x86", category: "移位运算", name: "SHR", operands: "dest, count", desc: "逻辑右移: dest >>= count"},
        {arch: "x86", category: "移位运算", name: "SAL", operands: "dest, count", desc: "算术左移(同SHL)"},
        {arch: "x86", category: "移位运算", name: "SAR", operands: "dest, count", desc: "算术右移(保留符号位)"},
        {arch: "x86", category: "移位运算", name: "ROL", operands: "dest, count", desc: "循环左移"},
        {arch: "x86", category: "移位运算", name: "ROR", operands: "dest, count", desc: "循环右移"},
        {arch: "x86", category: "控制转移", name: "JMP", operands: "label", desc: "无条件跳转"},
        {arch: "x86", category: "控制转移", name: "JE/JZ", operands: "label", desc: "相等/为零则跳转(ZF=1)"},
        {arch: "x86", category: "控制转移", name: "JNE/JNZ", operands: "label", desc: "不等/不为零则跳转(ZF=0)"},
        {arch: "x86", category: "控制转移", name: "JG/JNLE", operands: "label", desc: "大于则跳转(有符号)"},
        {arch: "x86", category: "控制转移", name: "JL/JNGE", operands: "label", desc: "小于则跳转(有符号)"},
        {arch: "x86", category: "控制转移", name: "JA/JNBE", operands: "label", desc: "大于则跳转(无符号)"},
        {arch: "x86", category: "控制转移", name: "JB/JNAE", operands: "label", desc: "小于则跳转(无符号)"},
        {arch: "x86", category: "控制转移", name: "CALL", operands: "proc", desc: "调用过程: PUSH IP/EIP; JMP proc"},
        {arch: "x86", category: "控制转移", name: "RET", operands: "", desc: "返回: POP IP/EIP"},
        {arch: "x86", category: "控制转移", name: "LOOP", operands: "label", desc: "循环: CX--; if(CX!=0) JMP label"},
        {arch: "x86", category: "字符串操作", name: "MOVS", operands: "", desc: "串传送: [DI] = [SI]; SI++; DI++"},
        {arch: "x86", category: "字符串操作", name: "CMPS", operands: "", desc: "串比较"},
        {arch: "x86", category: "字符串操作", name: "SCAS", operands: "", desc: "串扫描"},
        {arch: "x86", category: "字符串操作", name: "LODS", operands: "", desc: "串加载"},
        {arch: "x86", category: "字符串操作", name: "STOS", operands: "", desc: "串存储"},
        {arch: "x86", category: "其他", name: "NOP", operands: "", desc: "空操作"},
        {arch: "x86", category: "其他", name: "HLT", operands: "", desc: "停机"},
        {arch: "x86", category: "其他", name: "INT", operands: "n", desc: "软件中断"},
        {arch: "x86", category: "其他", name: "IRET", operands: "", desc: "中断返回"},
        
        {arch: "ARM", category: "数据处理", name: "MOV", operands: "Rd, Op2", desc: "数据传送: Rd = Op2"},
        {arch: "ARM", category: "数据处理", name: "MVN", operands: "Rd, Op2", desc: "取反传送: Rd = ~Op2"},
        {arch: "ARM", category: "数据处理", name: "ADD", operands: "Rd, Rn, Op2", desc: "加法: Rd = Rn + Op2"},
        {arch: "ARM", category: "数据处理", name: "SUB", operands: "Rd, Rn, Op2", desc: "减法: Rd = Rn - Op2"},
        {arch: "ARM", category: "数据处理", name: "RSB", operands: "Rd, Rn, Op2", desc: "反向减法: Rd = Op2 - Rn"},
        {arch: "ARM", category: "数据处理", name: "MUL", operands: "Rd, Rm, Rs", desc: "乘法: Rd = Rm * Rs"},
        {arch: "ARM", category: "数据处理", name: "MLA", operands: "Rd, Rm, Rs, Rn", desc: "乘加: Rd = Rm*Rs + Rn"},
        {arch: "ARM", category: "数据处理", name: "AND", operands: "Rd, Rn, Op2", desc: "按位与: Rd = Rn & Op2"},
        {arch: "ARM", category: "数据处理", name: "ORR", operands: "Rd, Rn, Op2", desc: "按位或: Rd = Rn | Op2"},
        {arch: "ARM", category: "数据处理", name: "EOR", operands: "Rd, Rn, Op2", desc: "按位异或: Rd = Rn ^ Op2"},
        {arch: "ARM", category: "数据处理", name: "BIC", operands: "Rd, Rn, Op2", desc: "位清除: Rd = Rn & ~Op2"},
        {arch: "ARM", category: "数据处理", name: "CMP", operands: "Rn, Op2", desc: "比较: Rn - Op2(更新标志)"},
        {arch: "ARM", category: "数据处理", name: "CMN", operands: "Rn, Op2", desc: "负数比较: Rn + Op2"},
        {arch: "ARM", category: "数据处理", name: "TST", operands: "Rn, Op2", desc: "测试: Rn & Op2(更新标志)"},
        {arch: "ARM", category: "数据处理", name: "TEQ", operands: "Rn, Op2", desc: "相等测试: Rn ^ Op2"},
        {arch: "ARM", category: "访存指令", name: "LDR", operands: "Rd, [Rn]", desc: "加载字: Rd = M[Rn]"},
        {arch: "ARM", category: "访存指令", name: "STR", operands: "Rd, [Rn]", desc: "存储字: M[Rn] = Rd"},
        {arch: "ARM", category: "访存指令", name: "LDRB", operands: "Rd, [Rn]", desc: "加载字节"},
        {arch: "ARM", category: "访存指令", name: "STRB", operands: "Rd, [Rn]", desc: "存储字节"},
        {arch: "ARM", category: "访存指令", name: "LDRH", operands: "Rd, [Rn]", desc: "加载半字"},
        {arch: "ARM", category: "访存指令", name: "STRH", operands: "Rd, [Rn]", desc: "存储半字"},
        {arch: "ARM", category: "访存指令", name: "LDM", operands: "Rn, {regs}", desc: "批量加载"},
        {arch: "ARM", category: "访存指令", name: "STM", operands: "Rn, {regs}", desc: "批量存储"},
        {arch: "ARM", category: "访存指令", name: "PUSH", operands: "{regs}", desc: "压栈"},
        {arch: "ARM", category: "访存指令", name: "POP", operands: "{regs}", desc: "出栈"},
        {arch: "ARM", category: "分支指令", name: "B", operands: "label", desc: "分支跳转"},
        {arch: "ARM", category: "分支指令", name: "BL", operands: "label", desc: "带链接分支: LR=PC+4; PC=label"},
        {arch: "ARM", category: "分支指令", name: "BX", operands: "Rm", desc: "分支交换: PC=Rm(可切换ARM/Thumb)"},
        {arch: "ARM", category: "分支指令", name: "BLX", operands: "Rm", desc: "带链接分支交换"},
        {arch: "ARM", category: "其他", name: "SWI", operands: "imm", desc: "软件中断"},
        {arch: "ARM", category: "其他", name: "NOP", operands: "", desc: "空操作"},
        
        {arch: "RISC-V", category: "算术运算", name: "ADD", operands: "rd, rs1, rs2", desc: "加法: rd = rs1 + rs2"},
        {arch: "RISC-V", category: "算术运算", name: "SUB", operands: "rd, rs1, rs2", desc: "减法: rd = rs1 - rs2"},
        {arch: "RISC-V", category: "算术运算", name: "ADDI", operands: "rd, rs1, imm", desc: "立即数加法: rd = rs1 + imm"},
        {arch: "RISC-V", category: "算术运算", name: "MUL", operands: "rd, rs1, rs2", desc: "乘法: rd = rs1 * rs2"},
        {arch: "RISC-V", category: "算术运算", name: "DIV", operands: "rd, rs1, rs2", desc: "除法: rd = rs1 / rs2"},
        {arch: "RISC-V", category: "算术运算", name: "REM", operands: "rd, rs1, rs2", desc: "取余: rd = rs1 % rs2"},
        {arch: "RISC-V", category: "逻辑运算", name: "AND", operands: "rd, rs1, rs2", desc: "按位与: rd = rs1 & rs2"},
        {arch: "RISC-V", category: "逻辑运算", name: "OR", operands: "rd, rs1, rs2", desc: "按位或: rd = rs1 | rs2"},
        {arch: "RISC-V", category: "逻辑运算", name: "XOR", operands: "rd, rs1, rs2", desc: "按位异或: rd = rs1 ^ rs2"},
        {arch: "RISC-V", category: "逻辑运算", name: "ANDI", operands: "rd, rs1, imm", desc: "立即数按位与"},
        {arch: "RISC-V", category: "逻辑运算", name: "ORI", operands: "rd, rs1, imm", desc: "立即数按位或"},
        {arch: "RISC-V", category: "逻辑运算", name: "XORI", operands: "rd, rs1, imm", desc: "立即数按位异或"},
        {arch: "RISC-V", category: "移位运算", name: "SLL", operands: "rd, rs1, rs2", desc: "逻辑左移: rd = rs1 << rs2"},
        {arch: "RISC-V", category: "移位运算", name: "SRL", operands: "rd, rs1, rs2", desc: "逻辑右移: rd = rs1 >> rs2"},
        {arch: "RISC-V", category: "移位运算", name: "SRA", operands: "rd, rs1, rs2", desc: "算术右移: rd = rs1 >>> rs2"},
        {arch: "RISC-V", category: "移位运算", name: "SLLI", operands: "rd, rs1, shamt", desc: "立即数逻辑左移"},
        {arch: "RISC-V", category: "移位运算", name: "SRLI", operands: "rd, rs1, shamt", desc: "立即数逻辑右移"},
        {arch: "RISC-V", category: "移位运算", name: "SRAI", operands: "rd, rs1, shamt", desc: "立即数算术右移"},
        {arch: "RISC-V", category: "比较指令", name: "SLT", operands: "rd, rs1, rs2", desc: "小于则置位: rd = (rs1<rs2)?1:0"},
        {arch: "RISC-V", category: "比较指令", name: "SLTU", operands: "rd, rs1, rs2", desc: "无符号小于则置位"},
        {arch: "RISC-V", category: "比较指令", name: "SLTI", operands: "rd, rs1, imm", desc: "立即数小于则置位"},
        {arch: "RISC-V", category: "比较指令", name: "SLTIU", operands: "rd, rs1, imm", desc: "立即数无符号小于则置位"},
        {arch: "RISC-V", category: "访存指令", name: "LW", operands: "rd, offset(rs1)", desc: "加载字: rd = M[rs1+offset]"},
        {arch: "RISC-V", category: "访存指令", name: "SW", operands: "rs2, offset(rs1)", desc: "存储字: M[rs1+offset] = rs2"},
        {arch: "RISC-V", category: "访存指令", name: "LB", operands: "rd, offset(rs1)", desc: "加载字节(符号扩展)"},
        {arch: "RISC-V", category: "访存指令", name: "LBU", operands: "rd, offset(rs1)", desc: "加载字节(零扩展)"},
        {arch: "RISC-V", category: "访存指令", name: "LH", operands: "rd, offset(rs1)", desc: "加载半字(符号扩展)"},
        {arch: "RISC-V", category: "访存指令", name: "LHU", operands: "rd, offset(rs1)", desc: "加载半字(零扩展)"},
        {arch: "RISC-V", category: "访存指令", name: "SB", operands: "rs2, offset(rs1)", desc: "存储字节"},
        {arch: "RISC-V", category: "访存指令", name: "SH", operands: "rs2, offset(rs1)", desc: "存储半字"},
        {arch: "RISC-V", category: "分支指令", name: "BEQ", operands: "rs1, rs2, label", desc: "相等则分支: if(rs1==rs2) PC+=offset"},
        {arch: "RISC-V", category: "分支指令", name: "BNE", operands: "rs1, rs2, label", desc: "不等则分支"},
        {arch: "RISC-V", category: "分支指令", name: "BLT", operands: "rs1, rs2, label", desc: "小于则分支(有符号)"},
        {arch: "RISC-V", category: "分支指令", name: "BGE", operands: "rs1, rs2, label", desc: "大于等于则分支(有符号)"},
        {arch: "RISC-V", category: "分支指令", name: "BLTU", operands: "rs1, rs2, label", desc: "小于则分支(无符号)"},
        {arch: "RISC-V", category: "分支指令", name: "BGEU", operands: "rs1, rs2, label", desc: "大于等于则分支(无符号)"},
        {arch: "RISC-V", category: "跳转指令", name: "JAL", operands: "rd, label", desc: "跳转并链接: rd=PC+4; PC+=offset"},
        {arch: "RISC-V", category: "跳转指令", name: "JALR", operands: "rd, rs1, offset", desc: "寄存器跳转并链接: rd=PC+4; PC=rs1+offset"},
        {arch: "RISC-V", category: "其他", name: "LUI", operands: "rd, imm", desc: "加载立即数到高位: rd = imm << 12"},
        {arch: "RISC-V", category: "其他", name: "AUIPC", operands: "rd, imm", desc: "PC加立即数: rd = PC + (imm<<12)"},
        {arch: "RISC-V", category: "其他", name: "ECALL", operands: "", desc: "环境调用(系统调用)"},
        {arch: "RISC-V", category: "其他", name: "EBREAK", operands: "", desc: "环境断点"},
        
        {arch: "MIPS", category: "算术运算", name: "ADD", operands: "$d, $s, $t", desc: "加法: $d = $s + $t"},
        {arch: "MIPS", category: "算术运算", name: "SUB", operands: "$d, $s, $t", desc: "减法: $d = $s - $t"},
        {arch: "MIPS", category: "算术运算", name: "ADDI", operands: "$t, $s, imm", desc: "立即数加法: $t = $s + imm"},
        {arch: "MIPS", category: "算术运算", name: "ADDU", operands: "$d, $s, $t", desc: "无符号加法"},
        {arch: "MIPS", category: "算术运算", name: "SUBU", operands: "$d, $s, $t", desc: "无符号减法"},
        {arch: "MIPS", category: "算术运算", name: "MUL", operands: "$d, $s, $t", desc: "乘法: $d = $s * $t"},
        {arch: "MIPS", category: "算术运算", name: "MULT", operands: "$s, $t", desc: "乘法: HI:LO = $s * $t"},
        {arch: "MIPS", category: "算术运算", name: "DIV", operands: "$s, $t", desc: "除法: LO=$s/$t; HI=$s%$t"},
        {arch: "MIPS", category: "逻辑运算", name: "AND", operands: "$d, $s, $t", desc: "按位与: $d = $s & $t"},
        {arch: "MIPS", category: "逻辑运算", name: "OR", operands: "$d, $s, $t", desc: "按位或: $d = $s | $t"},
        {arch: "MIPS", category: "逻辑运算", name: "XOR", operands: "$d, $s, $t", desc: "按位异或: $d = $s ^ $t"},
        {arch: "MIPS", category: "逻辑运算", name: "NOR", operands: "$d, $s, $t", desc: "按位或非: $d = ~($s | $t)"},
        {arch: "MIPS", category: "逻辑运算", name: "ANDI", operands: "$t, $s, imm", desc: "立即数按位与"},
        {arch: "MIPS", category: "逻辑运算", name: "ORI", operands: "$t, $s, imm", desc: "立即数按位或"},
        {arch: "MIPS", category: "逻辑运算", name: "XORI", operands: "$t, $s, imm", desc: "立即数按位异或"},
        {arch: "MIPS", category: "移位运算", name: "SLL", operands: "$d, $t, shamt", desc: "逻辑左移: $d = $t << shamt"},
        {arch: "MIPS", category: "移位运算", name: "SRL", operands: "$d, $t, shamt", desc: "逻辑右移: $d = $t >> shamt"},
        {arch: "MIPS", category: "移位运算", name: "SRA", operands: "$d, $t, shamt", desc: "算术右移: $d = $t >>> shamt"},
        {arch: "MIPS", category: "移位运算", name: "SLLV", operands: "$d, $t, $s", desc: "变量逻辑左移: $d = $t << $s"},
        {arch: "MIPS", category: "移位运算", name: "SRLV", operands: "$d, $t, $s", desc: "变量逻辑右移"},
        {arch: "MIPS", category: "移位运算", name: "SRAV", operands: "$d, $t, $s", desc: "变量算术右移"},
        {arch: "MIPS", category: "比较指令", name: "SLT", operands: "$d, $s, $t", desc: "小于则置位: $d=($s<$t)?1:0"},
        {arch: "MIPS", category: "比较指令", name: "SLTU", operands: "$d, $s, $t", desc: "无符号小于则置位"},
        {arch: "MIPS", category: "比较指令", name: "SLTI", operands: "$t, $s, imm", desc: "立即数小于则置位"},
        {arch: "MIPS", category: "比较指令", name: "SLTIU", operands: "$t, $s, imm", desc: "立即数无符号小于则置位"},
        {arch: "MIPS", category: "访存指令", name: "LW", operands: "$t, offset($s)", desc: "加载字: $t = M[$s+offset]"},
        {arch: "MIPS", category: "访存指令", name: "SW", operands: "$t, offset($s)", desc: "存储字: M[$s+offset] = $t"},
        {arch: "MIPS", category: "访存指令", name: "LB", operands: "$t, offset($s)", desc: "加载字节(符号扩展)"},
        {arch: "MIPS", category: "访存指令", name: "LBU", operands: "$t, offset($s)", desc: "加载字节(零扩展)"},
        {arch: "MIPS", category: "访存指令", name: "LH", operands: "$t, offset($s)", desc: "加载半字(符号扩展)"},
        {arch: "MIPS", category: "访存指令", name: "LHU", operands: "$t, offset($s)", desc: "加载半字(零扩展)"},
        {arch: "MIPS", category: "访存指令", name: "SB", operands: "$t, offset($s)", desc: "存储字节"},
        {arch: "MIPS", category: "访存指令", name: "SH", operands: "$t, offset($s)", desc: "存储半字"},
        {arch: "MIPS", category: "分支指令", name: "BEQ", operands: "$s, $t, label", desc: "相等则分支: if($s==$t) PC+=offset"},
        {arch: "MIPS", category: "分支指令", name: "BNE", operands: "$s, $t, label", desc: "不等则分支"},
        {arch: "MIPS", category: "分支指令", name: "BGTZ", operands: "$s, label", desc: "大于零则分支"},
        {arch: "MIPS", category: "分支指令", name: "BLEZ", operands: "$s, label", desc: "小于等于零则分支"},
        {arch: "MIPS", category: "分支指令", name: "BLTZ", operands: "$s, label", desc: "小于零则分支"},
        {arch: "MIPS", category: "分支指令", name: "BGEZ", operands: "$s, label", desc: "大于等于零则分支"},
        {arch: "MIPS", category: "跳转指令", name: "J", operands: "label", desc: "跳转: PC = (PC&0xF0000000)|addr"},
        {arch: "MIPS", category: "跳转指令", name: "JAL", operands: "label", desc: "跳转并链接: $ra=PC+8; PC=addr"},
        {arch: "MIPS", category: "跳转指令", name: "JR", operands: "$s", desc: "寄存器跳转: PC = $s"},
        {arch: "MIPS", category: "跳转指令", name: "JALR", operands: "$d, $s", desc: "寄存器跳转并链接: $d=PC+8; PC=$s"},
        {arch: "MIPS", category: "其他", name: "LUI", operands: "$t, imm", desc: "加载立即数到高位: $t = imm << 16"},
        {arch: "MIPS", category: "其他", name: "MFHI", operands: "$d", desc: "从HI传送: $d = HI"},
        {arch: "MIPS", category: "其他", name: "MFLO", operands: "$d", desc: "从LO传送: $d = LO"},
        {arch: "MIPS", category: "其他", name: "MTHI", operands: "$s", desc: "传送到HI: HI = $s"},
        {arch: "MIPS", category: "其他", name: "MTLO", operands: "$s", desc: "传送到LO: LO = $s"},
        {arch: "MIPS", category: "其他", name: "SYSCALL", operands: "", desc: "系统调用"},
        {arch: "MIPS", category: "其他", name: "NOP", operands: "", desc: "空操作(实际为SLL $0,$0,0)"},
        
        {arch: "AVR", category: "算术运算", name: "ADD", operands: "Rd, Rr", desc: "加法: Rd = Rd + Rr"},
        {arch: "AVR", category: "算术运算", name: "ADC", operands: "Rd, Rr", desc: "带进位加法: Rd = Rd + Rr + C"},
        {arch: "AVR", category: "算术运算", name: "SUB", operands: "Rd, Rr", desc: "减法: Rd = Rd - Rr"},
        {arch: "AVR", category: "算术运算", name: "SBC", operands: "Rd, Rr", desc: "带借位减法: Rd = Rd - Rr - C"},
        {arch: "AVR", category: "算术运算", name: "SUBI", operands: "Rd, K", desc: "立即数减法: Rd = Rd - K"},
        {arch: "AVR", category: "算术运算", name: "INC", operands: "Rd", desc: "自增: Rd++"},
        {arch: "AVR", category: "算术运算", name: "DEC", operands: "Rd", desc: "自减: Rd--"},
        {arch: "AVR", category: "算术运算", name: "MUL", operands: "Rd, Rr", desc: "无符号乘法: R1:R0 = Rd * Rr"},
        {arch: "AVR", category: "逻辑运算", name: "AND", operands: "Rd, Rr", desc: "按位与: Rd = Rd & Rr"},
        {arch: "AVR", category: "逻辑运算", name: "OR", operands: "Rd, Rr", desc: "按位或: Rd = Rd | Rr"},
        {arch: "AVR", category: "逻辑运算", name: "EOR", operands: "Rd, Rr", desc: "按位异或: Rd = Rd ^ Rr"},
        {arch: "AVR", category: "逻辑运算", name: "COM", operands: "Rd", desc: "按位取反: Rd = ~Rd"},
        {arch: "AVR", category: "逻辑运算", name: "NEG", operands: "Rd", desc: "取负: Rd = -Rd"},
        {arch: "AVR", category: "逻辑运算", name: "ANDI", operands: "Rd, K", desc: "立即数按位与"},
        {arch: "AVR", category: "逻辑运算", name: "ORI", operands: "Rd, K", desc: "立即数按位或"},
        {arch: "AVR", category: "移位运算", name: "LSL", operands: "Rd", desc: "逻辑左移: Rd = Rd << 1"},
        {arch: "AVR", category: "移位运算", name: "LSR", operands: "Rd", desc: "逻辑右移: Rd = Rd >> 1"},
        {arch: "AVR", category: "移位运算", name: "ASR", operands: "Rd", desc: "算术右移"},
        {arch: "AVR", category: "移位运算", name: "ROL", operands: "Rd", desc: "循环左移"},
        {arch: "AVR", category: "移位运算", name: "ROR", operands: "Rd", desc: "循环右移"},
        {arch: "AVR", category: "访存指令", name: "LD", operands: "Rd, X/Y/Z", desc: "加载: Rd = M[X/Y/Z]"},
        {arch: "AVR", category: "访存指令", name: "ST", operands: "X/Y/Z, Rr", desc: "存储: M[X/Y/Z] = Rr"},
        {arch: "AVR", category: "访存指令", name: "LDI", operands: "Rd, K", desc: "加载立即数: Rd = K"},
        {arch: "AVR", category: "访存指令", name: "LDS", operands: "Rd, k", desc: "加载直接: Rd = M[k]"},
        {arch: "AVR", category: "访存指令", name: "STS", operands: "k, Rr", desc: "存储直接: M[k] = Rr"},
        {arch: "AVR", category: "访存指令", name: "PUSH", operands: "Rr", desc: "压栈"},
        {arch: "AVR", category: "访存指令", name: "POP", operands: "Rd", desc: "出栈"},
        {arch: "AVR", category: "分支指令", name: "BREQ", operands: "k", desc: "相等则分支(Z=1)"},
        {arch: "AVR", category: "分支指令", name: "BRNE", operands: "k", desc: "不等则分支(Z=0)"},
        {arch: "AVR", category: "分支指令", name: "BRCS", operands: "k", desc: "进位置位则分支(C=1)"},
        {arch: "AVR", category: "分支指令", name: "BRCC", operands: "k", desc: "进位清零则分支(C=0)"},
        {arch: "AVR", category: "分支指令", name: "BRSH", operands: "k", desc: "大于等于则分支(无符号)"},
        {arch: "AVR", category: "分支指令", name: "BRLO", operands: "k", desc: "小于则分支(无符号)"},
        {arch: "AVR", category: "跳转指令", name: "RJMP", operands: "k", desc: "相对跳转: PC = PC + k + 1"},
        {arch: "AVR", category: "跳转指令", name: "JMP", operands: "k", desc: "绝对跳转: PC = k"},
        {arch: "AVR", category: "跳转指令", name: "RCALL", operands: "k", desc: "相对调用"},
        {arch: "AVR", category: "跳转指令", name: "CALL", operands: "k", desc: "绝对调用"},
        {arch: "AVR", category: "跳转指令", name: "RET", operands: "", desc: "返回"},
        {arch: "AVR", category: "跳转指令", name: "RETI", operands: "", desc: "中断返回"},
        {arch: "AVR", category: "其他", name: "NOP", operands: "", desc: "空操作"},
        {arch: "AVR", category: "其他", name: "SLEEP", operands: "", desc: "休眠"},
        {arch: "AVR", category: "其他", name: "WDR", operands: "", desc: "看门狗复位"},
        
        {arch: "8051", category: "数据传送", name: "MOV", operands: "dest, src", desc: "数据传送: dest = src"},
        {arch: "8051", category: "数据传送", name: "MOVC", operands: "A, @A+DPTR", desc: "从代码存储器传送"},
        {arch: "8051", category: "数据传送", name: "MOVX", operands: "A, @DPTR", desc: "从外部存储器传送"},
        {arch: "8051", category: "数据传送", name: "PUSH", operands: "direct", desc: "压栈"},
        {arch: "8051", category: "数据传送", name: "POP", operands: "direct", desc: "出栈"},
        {arch: "8051", category: "数据传送", name: "XCH", operands: "A, Rn", desc: "交换"},
        {arch: "8051", category: "算术运算", name: "ADD", operands: "A, src", desc: "加法: A = A + src"},
        {arch: "8051", category: "算术运算", name: "ADDC", operands: "A, src", desc: "带进位加法: A = A + src + C"},
        {arch: "8051", category: "算术运算", name: "SUBB", operands: "A, src", desc: "带借位减法: A = A - src - C"},
        {arch: "8051", category: "算术运算", name: "INC", operands: "dest", desc: "自增: dest++"},
        {arch: "8051", category: "算术运算", name: "DEC", operands: "dest", desc: "自减: dest--"},
        {arch: "8051", category: "算术运算", name: "MUL", operands: "AB", desc: "乘法: BA = A * B"},
        {arch: "8051", category: "算术运算", name: "DIV", operands: "AB", desc: "除法: A=A/B; B=A%B"},
        {arch: "8051", category: "逻辑运算", name: "ANL", operands: "dest, src", desc: "按位与: dest &= src"},
        {arch: "8051", category: "逻辑运算", name: "ORL", operands: "dest, src", desc: "按位或: dest |= src"},
        {arch: "8051", category: "逻辑运算", name: "XRL", operands: "dest, src", desc: "按位异或: dest ^= src"},
        {arch: "8051", category: "逻辑运算", name: "CLR", operands: "A/C/bit", desc: "清零"},
        {arch: "8051", category: "逻辑运算", name: "CPL", operands: "A/C/bit", desc: "取反"},
        {arch: "8051", category: "逻辑运算", name: "RL", operands: "A", desc: "循环左移"},
        {arch: "8051", category: "逻辑运算", name: "RR", operands: "A", desc: "循环右移"},
        {arch: "8051", category: "逻辑运算", name: "RLC", operands: "A", desc: "带进位循环左移"},
        {arch: "8051", category: "逻辑运算", name: "RRC", operands: "A", desc: "带进位循环右移"},
        {arch: "8051", category: "分支指令", name: "SJMP", operands: "rel", desc: "短跳转: PC = PC + rel"},
        {arch: "8051", category: "分支指令", name: "LJMP", operands: "addr16", desc: "长跳转: PC = addr16"},
        {arch: "8051", category: "分支指令", name: "AJMP", operands: "addr11", desc: "绝对跳转"},
        {arch: "8051", category: "分支指令", name: "JZ", operands: "rel", desc: "为零则跳转"},
        {arch: "8051", category: "分支指令", name: "JNZ", operands: "rel", desc: "不为零则跳转"},
        {arch: "8051", category: "分支指令", name: "JC", operands: "rel", desc: "进位则跳转"},
        {arch: "8051", category: "分支指令", name: "JNC", operands: "rel", desc: "无进位则跳转"},
        {arch: "8051", category: "分支指令", name: "JB", operands: "bit, rel", desc: "位为1则跳转"},
        {arch: "8051", category: "分支指令", name: "JNB", operands: "bit, rel", desc: "位为0则跳转"},
        {arch: "8051", category: "分支指令", name: "CJNE", operands: "op1, op2, rel", desc: "比较不等则跳转"},
        {arch: "8051", category: "分支指令", name: "DJNZ", operands: "Rn, rel", desc: "减1不为零则跳转"},
        {arch: "8051", category: "调用返回", name: "LCALL", operands: "addr16", desc: "长调用"},
        {arch: "8051", category: "调用返回", name: "ACALL", operands: "addr11", desc: "绝对调用"},
        {arch: "8051", category: "调用返回", name: "RET", operands: "", desc: "返回"},
        {arch: "8051", category: "调用返回", name: "RETI", operands: "", desc: "中断返回"},
        {arch: "8051", category: "其他", name: "NOP", operands: "", desc: "空操作"},
        {arch: "8051", category: "其他", name: "SWAP", operands: "A", desc: "半字节交换"}
    ]
    
    property var filteredInstructions: allInstructions
    property string currentArch: "全部"
    property string currentCategory: "全部"
    property string searchText: ""
    
    function filterInstructions() {
        var result = allInstructions
        
        if (currentArch !== "全部") {
            result = result.filter(function(inst) {
                return inst.arch === currentArch
            })
        }
        
        if (currentCategory !== "全部") {
            result = result.filter(function(inst) {
                return inst.category === currentCategory
            })
        }
        
        if (searchText !== "") {
            var search = searchText.toLowerCase()
            result = result.filter(function(inst) {
                return inst.name.toLowerCase().indexOf(search) !== -1 ||
                       inst.desc.toLowerCase().indexOf(search) !== -1 ||
                       inst.operands.toLowerCase().indexOf(search) !== -1
            })
        }
        
        filteredInstructions = result
    }
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text {
                text: "汇编指令速查"
                font.pixelSize: 22
                font.bold: true
                color: "#333333"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15
                    
                    ColumnLayout {
                        spacing: 5
                        
                        Text {
                            text: "指令集架构"
                            font.pixelSize: 12
                            color: "#666666"
                        }
                        
                        ComboBox {
                            id: archCombo
                            Layout.preferredWidth: 150
                            model: ["全部", "x86", "ARM", "RISC-V", "MIPS", "AVR", "8051"]
                            
                            onCurrentTextChanged: {
                                currentArch = currentText
                                filterInstructions()
                            }
                            
                            background: Rectangle {
                                color: archCombo.pressed ? "#e0e0e0" : "#ffffff"
                                border.color: "#cccccc"
                                border.width: 1
                                radius: 4
                            }
                        }
                    }
                    
                    ColumnLayout {
                        spacing: 5
                        
                        Text {
                            text: "指令分类"
                            font.pixelSize: 12
                            color: "#666666"
                        }
                        
                        ComboBox {
                            id: categoryCombo
                            Layout.preferredWidth: 150
                            model: ["全部", "数据传送", "算术运算", "逻辑运算", "移位运算", "比较指令", "访存指令", "分支指令", "跳转指令", "控制转移", "调用返回", "数据处理", "字符串操作", "其他"]
                            
                            onCurrentTextChanged: {
                                currentCategory = currentText
                                filterInstructions()
                            }
                            
                            background: Rectangle {
                                color: categoryCombo.pressed ? "#e0e0e0" : "#ffffff"
                                border.color: "#cccccc"
                                border.width: 1
                                radius: 4
                            }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "关键字搜索"
                            font.pixelSize: 12
                            color: "#666666"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            TextField {
                                id: searchField
                                Layout.fillWidth: true
                                placeholderText: "输入指令名称或描述..."
                                
                                onTextChanged: {
                                    searchText = text
                                    filterInstructions()
                                }
                                
                                background: Rectangle {
                                    color: "#ffffff"
                                    border.color: searchField.activeFocus ? "#2196F3" : "#cccccc"
                                    border.width: searchField.activeFocus ? 2 : 1
                                    radius: 4
                                }
                            }
                            
                            Button {
                                text: "清除"
                                Layout.preferredWidth: 60
                                Layout.preferredHeight: 28
                                
                                onClicked: {
                                    archCombo.currentIndex = 0
                                    categoryCombo.currentIndex = 0
                                    searchField.text = ""
                                }
                                
                                background: Rectangle {
                                    color: parent.pressed ? "#1976D2" : (parent.hovered ? "#42A5F5" : "#2196F3")
                                    radius: 4
                                }
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#e3f2fd"
                border.color: "#2196F3"
                border.width: 1
                radius: 4
                
                Text {
                    anchors.centerIn: parent
                    text: "共找到 " + filteredInstructions.length + " 条指令"
                    font.pixelSize: 13
                    font.bold: true
                    color: "#2196F3"
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
                            Layout.preferredWidth: 80
                            Layout.preferredHeight: 35
                            color: "#2196F3"
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: "架构"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            color: "#2196F3"
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: "分类"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 35
                            color: "#2196F3"
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: "指令"
                                font.pixelSize: 13
                                font.bold: true
                                color: "#ffffff"
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 35
                            color: "#2196F3"
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: "操作数"
                                font.pixelSize: 13
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
                                text: "描述"
                                font.pixelSize: 13
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
                            spacing: 3
                            
                            Repeater {
                                model: filteredInstructions.length
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: index % 2 === 0 ? "#f5f5f5" : "#ffffff"
                                    border.color: "#e0e0e0"
                                    border.width: 1
                                    radius: 4
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 10
                                        
                                        Rectangle {
                                            Layout.preferredWidth: 80
                                            Layout.preferredHeight: 24
                                            color: {
                                                switch(filteredInstructions[index].arch) {
                                                    case "x86": return "#FF5722"
                                                    case "ARM": return "#4CAF50"
                                                    case "RISC-V": return "#2196F3"
                                                    case "MIPS": return "#9C27B0"
                                                    case "AVR": return "#FF9800"
                                                    case "8051": return "#607D8B"
                                                    default: return "#999999"
                                                }
                                            }
                                            radius: 3
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: filteredInstructions[index].arch
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "#ffffff"
                                            }
                                        }
                                        
                                        Text {
                                            Layout.preferredWidth: 120
                                            text: filteredInstructions[index].category
                                            font.pixelSize: 11
                                            color: "#666666"
                                        }
                                        
                                        Text {
                                            Layout.preferredWidth: 120
                                            text: filteredInstructions[index].name
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "#2196F3"
                                            font.family: "Consolas"
                                        }
                                        
                                        Text {
                                            Layout.preferredWidth: 200
                                            text: filteredInstructions[index].operands
                                            font.pixelSize: 11
                                            color: "#FF5722"
                                            font.family: "Consolas"
                                        }
                                        
                                        Text {
                                            Layout.fillWidth: true
                                            text: filteredInstructions[index].desc
                                            font.pixelSize: 11
                                            color: "#333333"
                                            wrapMode: Text.WordWrap
                                            font.family: "Consolas"
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
