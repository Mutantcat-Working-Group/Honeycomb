import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../i18n/i18n.js" as I18n

Window {
    id: riscvWindow
    width: 1100
    height: 700
    title: "RISC-V指令集速查"
    flags: Qt.Window
    modality: Qt.NonModal
    
    property var instructionSets: [
        {
            name: "RV32I",
            type: "基础整数指令集",
            description: "32位基础整数指令集，包含40+条指令",
            instructions: [
                {name: "ADD", format: "R-type", desc: "加法运算: rd = rs1 + rs2"},
                {name: "SUB", format: "R-type", desc: "减法运算: rd = rs1 - rs2"},
                {name: "AND", format: "R-type", desc: "按位与: rd = rs1 & rs2"},
                {name: "OR", format: "R-type", desc: "按位或: rd = rs1 | rs2"},
                {name: "XOR", format: "R-type", desc: "按位异或: rd = rs1 ^ rs2"},
                {name: "SLL", format: "R-type", desc: "逻辑左移: rd = rs1 << rs2"},
                {name: "SRL", format: "R-type", desc: "逻辑右移: rd = rs1 >> rs2"},
                {name: "SRA", format: "R-type", desc: "算术右移: rd = rs1 >>> rs2"},
                {name: "SLT", format: "R-type", desc: "小于则置位(有符号): rd = (rs1 < rs2) ? 1 : 0"},
                {name: "SLTU", format: "R-type", desc: "小于则置位(无符号): rd = (rs1 < rs2) ? 1 : 0"},
                {name: "ADDI", format: "I-type", desc: "立即数加法: rd = rs1 + imm"},
                {name: "ANDI", format: "I-type", desc: "立即数按位与: rd = rs1 & imm"},
                {name: "ORI", format: "I-type", desc: "立即数按位或: rd = rs1 | imm"},
                {name: "XORI", format: "I-type", desc: "立即数按位异或: rd = rs1 ^ imm"},
                {name: "SLLI", format: "I-type", desc: "立即数逻辑左移: rd = rs1 << imm"},
                {name: "SRLI", format: "I-type", desc: "立即数逻辑右移: rd = rs1 >> imm"},
                {name: "SRAI", format: "I-type", desc: "立即数算术右移: rd = rs1 >>> imm"},
                {name: "SLTI", format: "I-type", desc: "立即数小于则置位(有符号)"},
                {name: "SLTIU", format: "I-type", desc: "立即数小于则置位(无符号)"},
                {name: "LB", format: "I-type", desc: "加载字节(有符号): rd = M[rs1+imm][0:7]"},
                {name: "LH", format: "I-type", desc: "加载半字(有符号): rd = M[rs1+imm][0:15]"},
                {name: "LW", format: "I-type", desc: "加载字: rd = M[rs1+imm][0:31]"},
                {name: "LBU", format: "I-type", desc: "加载字节(无符号)"},
                {name: "LHU", format: "I-type", desc: "加载半字(无符号)"},
                {name: "SB", format: "S-type", desc: "存储字节: M[rs1+imm][0:7] = rs2[0:7]"},
                {name: "SH", format: "S-type", desc: "存储半字: M[rs1+imm][0:15] = rs2[0:15]"},
                {name: "SW", format: "S-type", desc: "存储字: M[rs1+imm][0:31] = rs2[0:31]"},
                {name: "BEQ", format: "B-type", desc: "相等则分支: if(rs1 == rs2) PC += imm"},
                {name: "BNE", format: "B-type", desc: "不等则分支: if(rs1 != rs2) PC += imm"},
                {name: "BLT", format: "B-type", desc: "小于则分支(有符号): if(rs1 < rs2) PC += imm"},
                {name: "BGE", format: "B-type", desc: "大于等于则分支(有符号): if(rs1 >= rs2) PC += imm"},
                {name: "BLTU", format: "B-type", desc: "小于则分支(无符号)"},
                {name: "BGEU", format: "B-type", desc: "大于等于则分支(无符号)"},
                {name: "JAL", format: "J-type", desc: "跳转并链接: rd = PC+4; PC += imm"},
                {name: "JALR", format: "I-type", desc: "跳转并链接寄存器: rd = PC+4; PC = rs1+imm"},
                {name: "LUI", format: "U-type", desc: "加载立即数到高位: rd = imm << 12"},
                {name: "AUIPC", format: "U-type", desc: "PC加立即数到高位: rd = PC + (imm << 12)"},
                {name: "ECALL", format: "I-type", desc: "环境调用(系统调用)"},
                {name: "EBREAK", format: "I-type", desc: "环境断点(调试断点)"},
                {name: "FENCE", format: "I-type", desc: "内存屏障指令"}
            ]
        },
        {
            name: "RV64I",
            type: "64位基础整数指令集",
            description: "RV32I的64位扩展，增加64位操作指令",
            instructions: [
                {name: "LWU", format: "I-type", desc: "加载字(无符号): rd = M[rs1+imm][0:31]"},
                {name: "LD", format: "I-type", desc: "加载双字: rd = M[rs1+imm][0:63]"},
                {name: "SD", format: "S-type", desc: "存储双字: M[rs1+imm][0:63] = rs2[0:63]"},
                {name: "ADDIW", format: "I-type", desc: "字立即数加法: rd = SEXT((rs1+imm)[31:0])"},
                {name: "SLLIW", format: "I-type", desc: "字立即数逻辑左移"},
                {name: "SRLIW", format: "I-type", desc: "字立即数逻辑右移"},
                {name: "SRAIW", format: "I-type", desc: "字立即数算术右移"},
                {name: "ADDW", format: "R-type", desc: "字加法: rd = SEXT((rs1+rs2)[31:0])"},
                {name: "SUBW", format: "R-type", desc: "字减法: rd = SEXT((rs1-rs2)[31:0])"},
                {name: "SLLW", format: "R-type", desc: "字逻辑左移"},
                {name: "SRLW", format: "R-type", desc: "字逻辑右移"},
                {name: "SRAW", format: "R-type", desc: "字算术右移"}
            ]
        },
        {
            name: "RV128I",
            type: "128位基础整数指令集",
            description: "RV64I的128位扩展，支持128位操作",
            instructions: [
                {name: "LDU", format: "I-type", desc: "加载双字(无符号)"},
                {name: "LQ", format: "I-type", desc: "加载四字: rd = M[rs1+imm][0:127]"},
                {name: "SQ", format: "S-type", desc: "存储四字: M[rs1+imm][0:127] = rs2[0:127]"},
                {name: "ADDID", format: "I-type", desc: "双字立即数加法"},
                {name: "SLLID", format: "I-type", desc: "双字立即数逻辑左移"},
                {name: "SRLID", format: "I-type", desc: "双字立即数逻辑右移"},
                {name: "SRAID", format: "I-type", desc: "双字立即数算术右移"},
                {name: "ADDD", format: "R-type", desc: "双字加法"},
                {name: "SUBD", format: "R-type", desc: "双字减法"},
                {name: "SLLD", format: "R-type", desc: "双字逻辑左移"},
                {name: "SRLD", format: "R-type", desc: "双字逻辑右移"},
                {name: "SRAD", format: "R-type", desc: "双字算术右移"}
            ]
        },
        {
            name: "RV32E",
            type: "嵌入式基础整数指令集",
            description: "RV32I的精简版，仅16个通用寄存器(x0-x15)",
            instructions: [
                {name: "注", format: "", desc: "指令集与RV32I相同，但寄存器数量减半"},
                {name: "寄存器", format: "", desc: "x0-x15 (16个通用寄存器)"},
                {name: "优势", format: "", desc: "减少芯片面积，适合资源受限的嵌入式系统"},
                {name: "应用", format: "", desc: "微控制器、IoT设备、低功耗应用"}
            ]
        },
        {
            name: "M",
            type: "整数乘除法扩展",
            description: "标准整数乘法和除法指令",
            instructions: [
                {name: "MUL", format: "R-type", desc: "乘法(低位): rd = (rs1 * rs2)[XLEN-1:0]"},
                {name: "MULH", format: "R-type", desc: "乘法(高位,有符号×有符号): rd = (rs1 * rs2)[2*XLEN-1:XLEN]"},
                {name: "MULHSU", format: "R-type", desc: "乘法(高位,有符号×无符号)"},
                {name: "MULHU", format: "R-type", desc: "乘法(高位,无符号×无符号)"},
                {name: "DIV", format: "R-type", desc: "除法(有符号): rd = rs1 / rs2"},
                {name: "DIVU", format: "R-type", desc: "除法(无符号): rd = rs1 / rs2"},
                {name: "REM", format: "R-type", desc: "取余(有符号): rd = rs1 % rs2"},
                {name: "REMU", format: "R-type", desc: "取余(无符号): rd = rs1 % rs2"},
                {name: "MULW", format: "R-type", desc: "字乘法(RV64)"},
                {name: "DIVW", format: "R-type", desc: "字除法(RV64)"},
                {name: "DIVUW", format: "R-type", desc: "字除法无符号(RV64)"},
                {name: "REMW", format: "R-type", desc: "字取余(RV64)"},
                {name: "REMUW", format: "R-type", desc: "字取余无符号(RV64)"}
            ]
        },
        {
            name: "A",
            type: "原子指令扩展",
            description: "原子内存操作指令，支持多核同步",
            instructions: [
                {name: "LR.W", format: "R-type", desc: "加载保留字: rd = M[rs1]; 设置保留标记"},
                {name: "SC.W", format: "R-type", desc: "条件存储字: if(保留有效) M[rs1]=rs2, rd=0 else rd=1"},
                {name: "AMOSWAP.W", format: "R-type", desc: "原子交换: rd = M[rs1]; M[rs1] = rs2"},
                {name: "AMOADD.W", format: "R-type", desc: "原子加: rd = M[rs1]; M[rs1] += rs2"},
                {name: "AMOXOR.W", format: "R-type", desc: "原子异或: rd = M[rs1]; M[rs1] ^= rs2"},
                {name: "AMOAND.W", format: "R-type", desc: "原子与: rd = M[rs1]; M[rs1] &= rs2"},
                {name: "AMOOR.W", format: "R-type", desc: "原子或: rd = M[rs1]; M[rs1] |= rs2"},
                {name: "AMOMIN.W", format: "R-type", desc: "原子最小值(有符号): rd = M[rs1]; M[rs1] = min(M[rs1], rs2)"},
                {name: "AMOMAX.W", format: "R-type", desc: "原子最大值(有符号): rd = M[rs1]; M[rs1] = max(M[rs1], rs2)"},
                {name: "AMOMINU.W", format: "R-type", desc: "原子最小值(无符号)"},
                {name: "AMOMAXU.W", format: "R-type", desc: "原子最大值(无符号)"},
                {name: "LR.D", format: "R-type", desc: "加载保留双字(RV64)"},
                {name: "SC.D", format: "R-type", desc: "条件存储双字(RV64)"},
                {name: "注", format: "", desc: "所有AMO指令都支持.aq(获取)和.rl(释放)内存顺序标记"}
            ]
        },
        {
            name: "F",
            type: "单精度浮点扩展",
            description: "IEEE 754单精度(32位)浮点运算",
            instructions: [
                {name: "FLW", format: "I-type", desc: "加载单精度浮点: fd = M[rs1+imm]"},
                {name: "FSW", format: "S-type", desc: "存储单精度浮点: M[rs1+imm] = fs2"},
                {name: "FADD.S", format: "R-type", desc: "浮点加法: fd = fs1 + fs2"},
                {name: "FSUB.S", format: "R-type", desc: "浮点减法: fd = fs1 - fs2"},
                {name: "FMUL.S", format: "R-type", desc: "浮点乘法: fd = fs1 * fs2"},
                {name: "FDIV.S", format: "R-type", desc: "浮点除法: fd = fs1 / fs2"},
                {name: "FSQRT.S", format: "R-type", desc: "浮点平方根: fd = sqrt(fs1)"},
                {name: "FMIN.S", format: "R-type", desc: "浮点最小值: fd = min(fs1, fs2)"},
                {name: "FMAX.S", format: "R-type", desc: "浮点最大值: fd = max(fs1, fs2)"},
                {name: "FMADD.S", format: "R4-type", desc: "融合乘加: fd = (fs1 * fs2) + fs3"},
                {name: "FMSUB.S", format: "R4-type", desc: "融合乘减: fd = (fs1 * fs2) - fs3"},
                {name: "FNMADD.S", format: "R4-type", desc: "融合负乘加: fd = -(fs1 * fs2) + fs3"},
                {name: "FNMSUB.S", format: "R4-type", desc: "融合负乘减: fd = -(fs1 * fs2) - fs3"},
                {name: "FSGNJ.S", format: "R-type", desc: "符号注入: fd = {fs2[31], fs1[30:0]}"},
                {name: "FSGNJN.S", format: "R-type", desc: "符号取反注入"},
                {name: "FSGNJX.S", format: "R-type", desc: "符号异或注入"},
                {name: "FEQ.S", format: "R-type", desc: "浮点相等比较: rd = (fs1 == fs2)"},
                {name: "FLT.S", format: "R-type", desc: "浮点小于比较: rd = (fs1 < fs2)"},
                {name: "FLE.S", format: "R-type", desc: "浮点小于等于比较: rd = (fs1 <= fs2)"},
                {name: "FCVT.W.S", format: "R-type", desc: "浮点转整数(32位)"},
                {name: "FCVT.WU.S", format: "R-type", desc: "浮点转无符号整数(32位)"},
                {name: "FCVT.S.W", format: "R-type", desc: "整数转浮点(32位)"},
                {name: "FCVT.S.WU", format: "R-type", desc: "无符号整数转浮点(32位)"},
                {name: "FMV.X.W", format: "R-type", desc: "浮点寄存器移到整数寄存器"},
                {name: "FMV.W.X", format: "R-type", desc: "整数寄存器移到浮点寄存器"},
                {name: "FCLASS.S", format: "R-type", desc: "浮点分类(NaN, Inf, 0等)"}
            ]
        },
        {
            name: "D",
            type: "双精度浮点扩展",
            description: "IEEE 754双精度(64位)浮点运算",
            instructions: [
                {name: "FLD", format: "I-type", desc: "加载双精度浮点: fd = M[rs1+imm]"},
                {name: "FSD", format: "S-type", desc: "存储双精度浮点: M[rs1+imm] = fs2"},
                {name: "FADD.D", format: "R-type", desc: "双精度浮点加法"},
                {name: "FSUB.D", format: "R-type", desc: "双精度浮点减法"},
                {name: "FMUL.D", format: "R-type", desc: "双精度浮点乘法"},
                {name: "FDIV.D", format: "R-type", desc: "双精度浮点除法"},
                {name: "FSQRT.D", format: "R-type", desc: "双精度浮点平方根"},
                {name: "FMIN.D", format: "R-type", desc: "双精度浮点最小值"},
                {name: "FMAX.D", format: "R-type", desc: "双精度浮点最大值"},
                {name: "FMADD.D", format: "R4-type", desc: "双精度融合乘加"},
                {name: "FMSUB.D", format: "R4-type", desc: "双精度融合乘减"},
                {name: "FNMADD.D", format: "R4-type", desc: "双精度融合负乘加"},
                {name: "FNMSUB.D", format: "R4-type", desc: "双精度融合负乘减"},
                {name: "FSGNJ.D", format: "R-type", desc: "双精度符号注入"},
                {name: "FSGNJN.D", format: "R-type", desc: "双精度符号取反注入"},
                {name: "FSGNJX.D", format: "R-type", desc: "双精度符号异或注入"},
                {name: "FEQ.D", format: "R-type", desc: "双精度相等比较"},
                {name: "FLT.D", format: "R-type", desc: "双精度小于比较"},
                {name: "FLE.D", format: "R-type", desc: "双精度小于等于比较"},
                {name: "FCVT.W.D", format: "R-type", desc: "双精度转整数(32位)"},
                {name: "FCVT.WU.D", format: "R-type", desc: "双精度转无符号整数(32位)"},
                {name: "FCVT.D.W", format: "R-type", desc: "整数转双精度(32位)"},
                {name: "FCVT.D.WU", format: "R-type", desc: "无符号整数转双精度(32位)"},
                {name: "FCVT.S.D", format: "R-type", desc: "双精度转单精度"},
                {name: "FCVT.D.S", format: "R-type", desc: "单精度转双精度"},
                {name: "FCLASS.D", format: "R-type", desc: "双精度浮点分类"}
            ]
        },
        {
            name: "Q",
            type: "四精度浮点扩展",
            description: "IEEE 754四精度(128位)浮点运算",
            instructions: [
                {name: "FLQ", format: "I-type", desc: "加载四精度浮点"},
                {name: "FSQ", format: "S-type", desc: "存储四精度浮点"},
                {name: "FADD.Q", format: "R-type", desc: "四精度浮点加法"},
                {name: "FSUB.Q", format: "R-type", desc: "四精度浮点减法"},
                {name: "FMUL.Q", format: "R-type", desc: "四精度浮点乘法"},
                {name: "FDIV.Q", format: "R-type", desc: "四精度浮点除法"},
                {name: "FSQRT.Q", format: "R-type", desc: "四精度浮点平方根"},
                {name: "注", format: "", desc: "包含所有D扩展的四精度版本"}
            ]
        },
        {
            name: "C",
            type: "压缩指令扩展",
            description: "16位压缩指令，提高代码密度",
            instructions: [
                {name: "C.LWSP", format: "CI", desc: "栈指针加载字: rd = M[sp+imm]"},
                {name: "C.SWSP", format: "CSS", desc: "栈指针存储字: M[sp+imm] = rs2"},
                {name: "C.LW", format: "CL", desc: "加载字(压缩): rd' = M[rs1'+imm]"},
                {name: "C.SW", format: "CS", desc: "存储字(压缩): M[rs1'+imm] = rs2'"},
                {name: "C.J", format: "CJ", desc: "跳转(压缩): PC += imm"},
                {name: "C.JAL", format: "CJ", desc: "跳转并链接(压缩,RV32)"},
                {name: "C.JR", format: "CR", desc: "跳转寄存器: PC = rs1"},
                {name: "C.JALR", format: "CR", desc: "跳转并链接寄存器: ra = PC+2; PC = rs1"},
                {name: "C.BEQZ", format: "CB", desc: "等于零则分支: if(rs1' == 0) PC += imm"},
                {name: "C.BNEZ", format: "CB", desc: "不等于零则分支: if(rs1' != 0) PC += imm"},
                {name: "C.LI", format: "CI", desc: "加载立即数: rd = imm"},
                {name: "C.LUI", format: "CI", desc: "加载立即数到高位: rd = imm << 12"},
                {name: "C.ADDI", format: "CI", desc: "立即数加法: rd = rd + imm"},
                {name: "C.ADDI16SP", format: "CI", desc: "栈指针加立即数: sp = sp + imm"},
                {name: "C.ADDI4SPN", format: "CIW", desc: "栈指针加4倍立即数: rd' = sp + imm"},
                {name: "C.SLLI", format: "CI", desc: "立即数逻辑左移: rd = rd << imm"},
                {name: "C.SRLI", format: "CB", desc: "立即数逻辑右移: rd' = rd' >> imm"},
                {name: "C.SRAI", format: "CB", desc: "立即数算术右移: rd' = rd' >>> imm"},
                {name: "C.ANDI", format: "CB", desc: "立即数按位与: rd' = rd' & imm"},
                {name: "C.MV", format: "CR", desc: "移动: rd = rs2"},
                {name: "C.ADD", format: "CR", desc: "加法: rd = rd + rs2"},
                {name: "C.AND", format: "CS", desc: "按位与: rd' = rd' & rs2'"},
                {name: "C.OR", format: "CS", desc: "按位或: rd' = rd' | rs2'"},
                {name: "C.XOR", format: "CS", desc: "按位异或: rd' = rd' ^ rs2'"},
                {name: "C.SUB", format: "CS", desc: "减法: rd' = rd' - rs2'"},
                {name: "C.NOP", format: "CI", desc: "空操作"},
                {name: "C.EBREAK", format: "CR", desc: "环境断点(压缩)"}
            ]
        },
        {
            name: "Zicsr",
            type: "控制状态寄存器扩展",
            description: "CSR访问指令",
            instructions: [
                {name: "CSRRW", format: "I-type", desc: "CSR读写: rd = CSR[imm]; CSR[imm] = rs1"},
                {name: "CSRRS", format: "I-type", desc: "CSR读并置位: rd = CSR[imm]; CSR[imm] |= rs1"},
                {name: "CSRRC", format: "I-type", desc: "CSR读并清零: rd = CSR[imm]; CSR[imm] &= ~rs1"},
                {name: "CSRRWI", format: "I-type", desc: "CSR立即数读写: rd = CSR[imm]; CSR[imm] = uimm"},
                {name: "CSRRSI", format: "I-type", desc: "CSR立即数读并置位"},
                {name: "CSRRCI", format: "I-type", desc: "CSR立即数读并清零"}
            ]
        },
        {
            name: "Zifencei",
            type: "指令流同步扩展",
            description: "指令缓存同步",
            instructions: [
                {name: "FENCE.I", format: "I-type", desc: "指令流同步: 刷新指令缓存，确保指令流一致性"}
            ]
        },
        {
            name: "B",
            type: "位操作扩展",
            description: "位操作和位计数指令",
            instructions: [
                {name: "ANDN", format: "R-type", desc: "按位与非: rd = rs1 & ~rs2"},
                {name: "ORN", format: "R-type", desc: "按位或非: rd = rs1 | ~rs2"},
                {name: "XNOR", format: "R-type", desc: "按位同或: rd = ~(rs1 ^ rs2)"},
                {name: "CLZ", format: "R-type", desc: "计数前导零: rd = count_leading_zeros(rs1)"},
                {name: "CTZ", format: "R-type", desc: "计数尾随零: rd = count_trailing_zeros(rs1)"},
                {name: "CPOP", format: "R-type", desc: "计数置位位数: rd = popcount(rs1)"},
                {name: "MAX", format: "R-type", desc: "最大值(有符号): rd = max(rs1, rs2)"},
                {name: "MAXU", format: "R-type", desc: "最大值(无符号): rd = max(rs1, rs2)"},
                {name: "MIN", format: "R-type", desc: "最小值(有符号): rd = min(rs1, rs2)"},
                {name: "MINU", format: "R-type", desc: "最小值(无符号): rd = min(rs1, rs2)"},
                {name: "SEXT.B", format: "R-type", desc: "符号扩展字节: rd = SEXT(rs1[7:0])"},
                {name: "SEXT.H", format: "R-type", desc: "符号扩展半字: rd = SEXT(rs1[15:0])"},
                {name: "ZEXT.H", format: "R-type", desc: "零扩展半字: rd = ZEXT(rs1[15:0])"},
                {name: "ROL", format: "R-type", desc: "循环左移: rd = (rs1 << rs2) | (rs1 >> (XLEN-rs2))"},
                {name: "ROR", format: "R-type", desc: "循环右移: rd = (rs1 >> rs2) | (rs1 << (XLEN-rs2))"},
                {name: "RORI", format: "I-type", desc: "立即数循环右移"},
                {name: "REV8", format: "R-type", desc: "字节序反转"},
                {name: "BCLR", format: "R-type", desc: "清除位: rd = rs1 & ~(1 << rs2)"},
                {name: "BEXT", format: "R-type", desc: "提取位: rd = (rs1 >> rs2) & 1"},
                {name: "BINV", format: "R-type", desc: "反转位: rd = rs1 ^ (1 << rs2)"},
                {name: "BSET", format: "R-type", desc: "设置位: rd = rs1 | (1 << rs2)"}
            ]
        },
        {
            name: "V",
            type: "向量扩展",
            description: "SIMD向量操作指令",
            instructions: [
                {name: "VLE", format: "Vector", desc: "向量加载: vd = M[rs1]"},
                {name: "VSE", format: "Vector", desc: "向量存储: M[rs1] = vs3"},
                {name: "VADD", format: "Vector", desc: "向量加法: vd[i] = vs2[i] + vs1[i]"},
                {name: "VSUB", format: "Vector", desc: "向量减法: vd[i] = vs2[i] - vs1[i]"},
                {name: "VMUL", format: "Vector", desc: "向量乘法: vd[i] = vs2[i] * vs1[i]"},
                {name: "VDIV", format: "Vector", desc: "向量除法: vd[i] = vs2[i] / vs1[i]"},
                {name: "VAND", format: "Vector", desc: "向量按位与: vd[i] = vs2[i] & vs1[i]"},
                {name: "VOR", format: "Vector", desc: "向量按位或: vd[i] = vs2[i] | vs1[i]"},
                {name: "VXOR", format: "Vector", desc: "向量按位异或: vd[i] = vs2[i] ^ vs1[i]"},
                {name: "VMIN", format: "Vector", desc: "向量最小值: vd[i] = min(vs2[i], vs1[i])"},
                {name: "VMAX", format: "Vector", desc: "向量最大值: vd[i] = max(vs2[i], vs1[i])"},
                {name: "VMACC", format: "Vector", desc: "向量乘加: vd[i] += vs1[i] * vs2[i]"},
                {name: "VREDSUM", format: "Vector", desc: "向量归约求和: vd[0] = Σvs2[i]"},
                {name: "VSLIDE", format: "Vector", desc: "向量滑动"},
                {name: "注", format: "", desc: "支持多种元素宽度(8/16/32/64位)和向量长度"}
            ]
        }
    ]
    
    property int currentSetIndex: 0
    
    Rectangle {
        anchors.fill: parent
        color: "#f9f9f9"
        
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            Rectangle {
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: "#ffffff"
                border.color: "#e0e0e0"
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5
                    
                    Text {
                        text: "指令集列表"
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
                                model: instructionSets.length
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    color: currentSetIndex === index ? "#e3f2fd" : (setMouseArea.containsMouse ? "#f5f5f5" : "transparent")
                                    radius: 4
                                    border.color: currentSetIndex === index ? "#2196F3" : "transparent"
                                    border.width: 2
                                    
                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 2
                                        
                                        Text {
                                            text: instructionSets[index].name
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: currentSetIndex === index ? "#2196F3" : "#333333"
                                        }
                                        
                                        Text {
                                            text: instructionSets[index].type
                                            font.pixelSize: 11
                                            color: "#666666"
                                            wrapMode: Text.WordWrap
                                            Layout.fillWidth: true
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: setMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        
                                        onClicked: {
                                            currentSetIndex = index
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
                        text: "RISC-V指令集速查"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#333333"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        color: "#ffffff"
                        border.color: "#2196F3"
                        border.width: 2
                        radius: 8
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 5
                            
                            Text {
                                text: instructionSets[currentSetIndex].name + " - " + instructionSets[currentSetIndex].type
                                font.pixelSize: 18
                                font.bold: true
                                color: "#2196F3"
                            }
                            
                            Text {
                                text: instructionSets[currentSetIndex].description
                                font.pixelSize: 14
                                color: "#666666"
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
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
                                        text: "指令名称"
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
                                        text: "格式"
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
                                        text: "描述"
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
                                        model: instructionSets[currentSetIndex].instructions
                                        
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 40
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
                                                
                                                Text {
                                                    Layout.preferredWidth: 100
                                                    text: modelData.format
                                                    font.pixelSize: 12
                                                    color: "#666666"
                                                    font.family: "Consolas"
                                                }
                                                
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: modelData.desc
                                                    font.pixelSize: 12
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
    }
}
