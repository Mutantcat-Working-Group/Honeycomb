<script setup lang="ts">
import { defineProps, defineEmits, ref, watch } from 'vue';
import JsBarcode from 'jsbarcode';
import { Message } from '@arco-design/web-vue';
import { toPng } from 'html-to-image';
import { saveAs } from 'file-saver';
import QrcodeVue from 'qrcode.vue';
import CryptoJS from 'crypto-js';
import { load as yamlLoad, dump as yamlDump } from 'js-yaml';
import axios from 'axios';

const props = defineProps({
    toolbar: Boolean,
    tooltype: String
});

const emit = defineEmits(['update:toolbar', 'update:tooltype']);

const switchToMenu = () => {
    emit('update:toolbar', false);
};

function minimizeWindow() {
    window.ipcRenderer.send('minimize-window');
}
function closeWindow() {
    window.ipcRenderer.send('close-window');
}

// t1-1
const t1_1_in: any = ref("")
const t1_1_ok: any = ref(false)
function generateBarcode() {
    try {
        JsBarcode("#barcode", t1_1_in.value, {
            format: "CODE128",
            displayValue: true,
            fontSize: 20,
            width: 2,
            height: 60,
            textMargin: 0,
            margin: 1
        })
        t1_1_ok.value = true
        Message.clear()
        Message.success({ content: '生成成功!', position: 'bottom' })
    } catch (err) {
        Message.clear()
        Message.error({ content: '生成条形码失败,请检查输入的数字是否正确', position: 'bottom' })
    }
}

const copySvgToClipboard = async (svgElementId: string): Promise<void> => {
    const svgElement = document.getElementById(svgElementId) as HTMLElement | null;
    if (!svgElement) {
        console.error(`未找到 ID 为 "${svgElementId}" 的 SVG 元素`);
        return;
    }

    try {
        const dataUrl = await toPng(svgElement);
        await navigator.clipboard.write([
            new ClipboardItem({ 'image/png': await (await fetch(dataUrl)).blob() }),
        ]);
        Message.clear()
        Message.success({ content: '图片已复制到剪切板!', position: 'bottom' })
    } catch (error) {
        Message.clear()
        Message.error({ content: '复制图片到剪贴板失败：' + error, position: 'bottom' })
    }
};

const saveSvgImage = async (svgElementId: string): Promise<void> => {
    const svgElement = document.getElementById(svgElementId) as HTMLElement | null;
    if (!svgElement) {
        console.error(`未找到 ID 为 "${svgElementId}" 的 SVG 元素`);
        return;
    }

    try {
        const dataUrl = await toPng(svgElement);
        saveAs(dataUrl, 'code.png');
        Message.clear()
        Message.success({ content: '处理文件保存中!', position: 'bottom' })
    } catch (error) {
        Message.clear()
        Message.error({ content: '保存图片失败：' + error, position: 'bottom' })
    }
};

// t1-2
const t1_2_in: any = ref("")
const t1_2_qr: any = ref("")

function generateQrcode() {
    t1_2_qr.value = t1_2_in.value
}

const copyCanvasToClipboard = async (canvasId: string): Promise<void> => {
    const canvasElement = document.getElementById(canvasId) as HTMLCanvasElement | null;
    if (!canvasElement) {
        console.error(`未找到 ID 为 "${canvasId}" 的 Canvas 元素`);
        return;
    }

    try {
        const dataUrl = await toPng(canvasElement);
        const blob = await (await fetch(dataUrl)).blob();

        await navigator.clipboard.write([
            new ClipboardItem({ 'image/png': blob }),
        ]);

        Message.clear()
        Message.success({ content: '图片已复制到剪贴板', position: 'bottom' })
    } catch (error) {
        Message.clear()
        Message.error({ content: '复制图片到剪贴板失败：' + error, position: 'bottom' })
    }
};

const saveCanvasImage = async (canvasId: string): Promise<void> => {
    const canvasElement = document.getElementById(canvasId) as HTMLCanvasElement | null;
    if (!canvasElement) {
        console.error(`未找到 ID 为 "${canvasId}" 的 Canvas 元素`);
        return;
    }

    try {
        let dataUrl;
        dataUrl = await toPng(canvasElement);

        if (dataUrl) {
            saveAs(dataUrl, `code.png`);
            Message.clear()
            Message.success({ content: '处理文件保存中!', position: 'bottom' })
        }
    } catch (error) {
        Message.clear()
        Message.error({ content: '保存图片失败：' + error, position: 'bottom' })
    }
};

// t1-3 时间戳转换
const t1_3_timestamp = ref('');
const t1_3_datetime = ref('');
const t1_3_current_timestamp = ref(0);
const t1_3_current_datetime = ref('');

// t2-9 正则测试
const t2_9_regex = ref('');
const t2_9_text = ref('');
interface RegexMatch {
    fullMatch: string;
    groups: string[];
    index: number;
    input: string;
}
const t2_9_matches = ref<RegexMatch[]>([]);
const t2_9_error = ref('');
const t2_9_flags = ref({
    global: true,
    ignoreCase: false,
    multiline: false
});

// t2-10 大小写转换
const t2_10_input = ref('');
const t2_10_output = ref('');
const t2_10_mode = ref('upper'); // 'upper', 'lower', 'capitalize', 'title', 'toggle'

// t5-6 UUID生成
const t5_6_uuid = ref('');
const t5_6_version = ref('v4');
const t5_6_count = ref(1);
const t5_6_uppercase = ref(false);
const t5_6_hyphens = ref(true);
const t5_6_generatedUUIDs = ref<string[]>([]);

// 生成UUID函数
function generateUUID() {
    t5_6_generatedUUIDs.value = [];
    const count = Math.min(Math.max(1, t5_6_count.value), 100); // 限制最多生成100个UUID
    
    for (let i = 0; i < count; i++) {
        let uuid = '';
        
        if (t5_6_version.value === 'v4') {
            // 生成版本4的UUID (随机)
            uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                const r = Math.random() * 16 | 0;
                const v = c === 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        } else if (t5_6_version.value === 'v1') {
            // 简单模拟版本1的UUID (基于时间)
            const now = new Date();
            const timeStr = now.getTime().toString(16).padStart(16, '0');
            const randomStr = Math.random().toString(16).substring(2, 10);
            uuid = `${timeStr.substring(0, 8)}-${timeStr.substring(8, 12)}-1${timeStr.substring(13, 16)}-${randomStr.substring(0, 4)}-${randomStr.substring(4, 12)}`;
        }
        
        // 处理大小写
        if (t5_6_uppercase.value) {
            uuid = uuid.toUpperCase();
        }
        
        // 处理连字符
        if (!t5_6_hyphens.value) {
            uuid = uuid.replace(/-/g, '');
        }
        
        t5_6_generatedUUIDs.value.push(uuid);
    }
    
    // 设置第一个UUID为当前显示的UUID
    if (t5_6_generatedUUIDs.value.length > 0) {
        t5_6_uuid.value = t5_6_generatedUUIDs.value[0];
    }
}

// 大小写转换函数
function convertCase() {
    if (!t2_10_input.value) {
        t2_10_output.value = '';
        return;
    }

    switch (t2_10_mode.value) {
        case 'upper':
            t2_10_output.value = t2_10_input.value.toUpperCase();
            break;
        case 'lower':
            t2_10_output.value = t2_10_input.value.toLowerCase();
            break;
        case 'capitalize':
            t2_10_output.value = t2_10_input.value
                .toLowerCase()
                .replace(/(^|\s)\S/g, (letter) => letter.toUpperCase());
            break;
        case 'title':
            t2_10_output.value = t2_10_input.value
                .toLowerCase()
                .replace(/(^|\s)\w/g, (letter) => letter.toUpperCase());
            break;
        case 'toggle':
            t2_10_output.value = t2_10_input.value
                .split('')
                .map(char => {
                    if (char === char.toUpperCase()) {
                        return char.toLowerCase();
                    } else {
                        return char.toUpperCase();
                    }
                })
                .join('');
            break;
        default:
            t2_10_output.value = t2_10_input.value;
    }
}

// 执行正则表达式测试
function testRegex() {
    t2_9_matches.value = [];
    t2_9_error.value = '';
    
    if (!t2_9_regex.value || !t2_9_text.value) {
        t2_9_error.value = '请输入正则表达式和测试文本';
        return;
    }
    
    try {
        // 构建正则表达式标志
        let flags = '';
        if (t2_9_flags.value.global) flags += 'g';
        if (t2_9_flags.value.ignoreCase) flags += 'i';
        if (t2_9_flags.value.multiline) flags += 'm';
        
        // 创建正则表达式对象
        const regex = new RegExp(t2_9_regex.value, flags);
        
        // 执行匹配
        const text = t2_9_text.value;
        let match;
        let matches = [];
        
        if (t2_9_flags.value.global) {
            while ((match = regex.exec(text)) !== null) {
                matches.push({
                    fullMatch: match[0],
                    groups: match.slice(1),
                    index: match.index,
                    input: match.input
                });
                
                // 防止零宽度匹配导致的无限循环
                if (match.index === regex.lastIndex) {
                    regex.lastIndex++;
                }
            }
        } else {
            match = regex.exec(text);
            if (match) {
                matches.push({
                    fullMatch: match[0],
                    groups: match.slice(1),
                    index: match.index,
                    input: match.input
                });
            }
        }
        
        t2_9_matches.value = matches;
        
        if (matches.length === 0) {
            t2_9_error.value = '没有找到匹配项';
        }
        
    } catch (error: any) {
        t2_9_error.value = `正则表达式错误: ${error.message}`;
    }
}

// 更新当前时间和时间戳
function updateCurrentTime() {
    const now = new Date();
    t1_3_current_timestamp.value = Math.floor(now.getTime() / 1000);
    t1_3_current_datetime.value = formatDateTime(now);
}

// 格式化日期时间
function formatDateTime(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

// 时间戳转日期时间
function timestampToDatetime() {
    try {
        if (!t1_3_timestamp.value) {
            Message.warning({ content: '请输入时间戳', position: 'bottom' });
            return;
        }
        
        // 处理毫秒和秒两种时间戳
        let timestamp = parseInt(t1_3_timestamp.value);
        if (timestamp.toString().length === 10) {
            timestamp = timestamp * 1000; // 秒转毫秒
        }
        
        const date = new Date(timestamp);
        t1_3_datetime.value = formatDateTime(date);
        Message.success({ content: '转换成功', position: 'bottom' });
    } catch (error) {
        Message.error({ content: '转换失败，请检查输入的时间戳格式', position: 'bottom' });
    }
}

// 日期时间转时间戳
function datetimeToTimestamp() {
    try {
        if (!t1_3_datetime.value) {
            Message.warning({ content: '请输入日期时间', position: 'bottom' });
            return;
        }
        
        const date = new Date(t1_3_datetime.value);
        if (isNaN(date.getTime())) {
            Message.error({ content: '日期格式无效', position: 'bottom' });
            return;
        }
        
        t1_3_timestamp.value = Math.floor(date.getTime() / 1000).toString();
        Message.success({ content: '转换成功', position: 'bottom' });
    } catch (error) {
        Message.error({ content: '转换失败，请检查输入的日期格式', position: 'bottom' });
    }
}

// 使用当前时间
function useCurrentTime() {
    updateCurrentTime();
    t1_3_timestamp.value = t1_3_current_timestamp.value.toString();
    t1_3_datetime.value = t1_3_current_datetime.value;
}

// 页面加载时更新当前时间
updateCurrentTime();
// 每秒更新一次当前时间
setInterval(updateCurrentTime, 1000);

// t1-4 颜色值转换
const t1_4_hex = ref('#000000');
const t1_4_rgb = ref({ r: 0, g: 0, b: 0 });
const t1_4_hsl = ref({ h: 0, s: 0, l: 0 });
const t1_4_cmyk = ref({ c: 0, m: 0, y: 0, k: 100 });
const t1_4_preview_style = ref('background-color: #000000');

// 将HEX转换为RGB
function hexToRgb(hex: string): { r: number, g: number, b: number } | null {
    // 去除可能的#前缀
    hex = hex.replace(/^#/, '');
    
    // 处理3位HEX值
    if (hex.length === 3) {
        hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    
    // 检查是否是有效的6位HEX值
    const validHex = /^[0-9A-F]{6}$/i.test(hex);
    if (!validHex) {
        return null;
    }
    
    // 解析RGB值
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    
    return { r, g, b };
}

// 将RGB转换为HEX
function rgbToHex(r: number, g: number, b: number): string {
    const toHex = (c: number) => {
        const hex = Math.max(0, Math.min(255, Math.round(c))).toString(16);
        return hex.length === 1 ? '0' + hex : hex;
    };
    
    return '#' + toHex(r) + toHex(g) + toHex(b);
}

// 将RGB转换为HSL
function rgbToHsl(r: number, g: number, b: number): { h: number, s: number, l: number } {
    r /= 255;
    g /= 255;
    b /= 255;
    
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0, s = 0, l = (max + min) / 2;
    
    if (max !== min) {
        const d = max - min;
        s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
        
        switch (max) {
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
        }
        
        h /= 6;
    }
    
    return { 
        h: Math.round(h * 360), 
        s: Math.round(s * 100), 
        l: Math.round(l * 100) 
    };
}

// 将HSL转换为RGB
function hslToRgb(h: number, s: number, l: number): { r: number, g: number, b: number } {
    h /= 360;
    s /= 100;
    l /= 100;
    
    let r, g, b;
    
    if (s === 0) {
        r = g = b = l; // 灰色
    } else {
        const hue2rgb = (p: number, q: number, t: number) => {
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            if (t < 1/6) return p + (q - p) * 6 * t;
            if (t < 1/2) return q;
            if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
        };
        
        const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        const p = 2 * l - q;
        
        r = hue2rgb(p, q, h + 1/3);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1/3);
    }
    
    return { 
        r: Math.round(r * 255), 
        g: Math.round(g * 255), 
        b: Math.round(b * 255) 
    };
}

// 将RGB转换为CMYK
function rgbToCmyk(r: number, g: number, b: number): { c: number, m: number, y: number, k: number } {
    r /= 255;
    g /= 255;
    b /= 255;
    
    const k = 1 - Math.max(r, g, b);
    if (k === 1) {
        return { c: 0, m: 0, y: 0, k: 100 };
    }
    
    const c = (1 - r - k) / (1 - k);
    const m = (1 - g - k) / (1 - k);
    const y = (1 - b - k) / (1 - k);
    
    return { 
        c: Math.round(c * 100), 
        m: Math.round(m * 100), 
        y: Math.round(y * 100), 
        k: Math.round(k * 100) 
    };
}

// 将CMYK转换为RGB
function cmykToRgb(c: number, m: number, y: number, k: number): { r: number, g: number, b: number } {
    c /= 100;
    m /= 100;
    y /= 100;
    k /= 100;
    
    const r = 255 * (1 - c) * (1 - k);
    const g = 255 * (1 - m) * (1 - k);
    const b = 255 * (1 - y) * (1 - k);
    
    return { 
        r: Math.round(r), 
        g: Math.round(g), 
        b: Math.round(b) 
    };
}

// 从HEX更新所有颜色值
function updateFromHex() {
    const rgb = hexToRgb(t1_4_hex.value);
    if (!rgb) {
        Message.error({ content: '无效的HEX颜色值', position: 'bottom' });
        return;
    }
    
    t1_4_rgb.value = rgb;
    t1_4_hsl.value = rgbToHsl(rgb.r, rgb.g, rgb.b);
    t1_4_cmyk.value = rgbToCmyk(rgb.r, rgb.g, rgb.b);
    updatePreview();
}

// 从RGB更新所有颜色值
function updateFromRgb() {
    const { r, g, b } = t1_4_rgb.value;
    
    // 验证RGB值
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
        Message.error({ content: '无效的RGB颜色值，应在0-255之间', position: 'bottom' });
        return;
    }
    
    t1_4_hex.value = rgbToHex(r, g, b);
    t1_4_hsl.value = rgbToHsl(r, g, b);
    t1_4_cmyk.value = rgbToCmyk(r, g, b);
    updatePreview();
}

// 从HSL更新所有颜色值
function updateFromHsl() {
    const { h, s, l } = t1_4_hsl.value;
    
    // 验证HSL值
    if (h < 0 || h > 360 || s < 0 || s > 100 || l < 0 || l > 100) {
        Message.error({ content: '无效的HSL颜色值', position: 'bottom' });
        return;
    }
    
    const rgb = hslToRgb(h, s, l);
    t1_4_rgb.value = rgb;
    t1_4_hex.value = rgbToHex(rgb.r, rgb.g, rgb.b);
    t1_4_cmyk.value = rgbToCmyk(rgb.r, rgb.g, rgb.b);
    updatePreview();
}

// 从CMYK更新所有颜色值
function updateFromCmyk() {
    const { c, m, y, k } = t1_4_cmyk.value;
    
    // 验证CMYK值
    if (c < 0 || c > 100 || m < 0 || m > 100 || y < 0 || y > 100 || k < 0 || k > 100) {
        Message.error({ content: '无效的CMYK颜色值，应在0-100之间', position: 'bottom' });
        return;
    }
    
    const rgb = cmykToRgb(c, m, y, k);
    t1_4_rgb.value = rgb;
    t1_4_hex.value = rgbToHex(rgb.r, rgb.g, rgb.b);
    t1_4_hsl.value = rgbToHsl(rgb.r, rgb.g, rgb.b);
    updatePreview();
}

// 更新颜色预览
function updatePreview() {
    t1_4_preview_style.value = `background-color: ${t1_4_hex.value}`;
}

// 随机生成颜色
function generateRandomColor() {
    const r = Math.floor(Math.random() * 256);
    const g = Math.floor(Math.random() * 256);
    const b = Math.floor(Math.random() * 256);
    
    t1_4_rgb.value = { r, g, b };
    updateFromRgb();
}

// 复制颜色值到剪贴板
function copyColorValue(value: string) {
    navigator.clipboard.writeText(value).then(() => {
        Message.success({ content: '已复制到剪贴板', position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// t2-1
const t2_1_in: any = ref("")
const t2_1_out: any = ref("")

function clear_t2_1() {
    t2_1_in.value = ""
    t2_1_out.value = ""
}

function process_t2_1() {
    t2_1_out.value = t2_1_in.value.replace(/ /g, "");
}

// t2-2
const t2_2_in: any = ref("")
const t2_2_out: any = ref("")
function clear_t2_2() {
    t2_2_in.value = ""
    t2_2_out.value = ""
}
function process_t2_2() {
    t2_2_out.value = t2_2_in.value.replace(/\n/g, "");
}

// t2-3
const t2_3_in: any = ref("")
const t2_3_out: any = ref("")
function clear_t2_3() {
    t2_3_in.value = ""
    t2_3_out.value = ""
}
function process_t2_3() {
    t2_3_out.value = t2_3_in.value.replace(/[\n\s]/g, "");
}

// t2-4
const t2_4_in: any = ref("")
const t2_4_out: any = ref("")
function clear_t2_4() {
    t2_4_in.value = ""
    t2_4_out.value = ""
}
function process_t2_4() {
    t2_4_out.value = t2_4_in.value.replace(/[\u4e00-\u9fa5]/g, function (c: any) {
        return "\\u" + c.charCodeAt(0).toString(16);
    });
}
// 反向处理
function process_t2_4_re() {
    t2_4_in.value = t2_4_out.value.replace(/\\u[\d\w]{4}/gi, function (c: any) {
        return String.fromCharCode(parseInt(c.replace(/\\u/g, ""), 16));
    });
}

// t2-5
const t2_5_in: any = ref("")
const t2_5_out: any = ref("")
const t2_5_from: any = ref("")
const t2_5_to: any = ref("")
function clear_t2_5() {
    t2_5_in.value = ""
    t2_5_out.value = ""
}
function process_t2_5() {
    t2_5_out.value = t2_5_in.value.replace(new RegExp(t2_5_from.value, 'g'), t2_5_to.value);
}

// t2-7 字数统计
const t2_7_in: any = ref("")
const t2_7_stats = ref({
    chars: 0,         // 总字符数(含空格)
    charsNoSpace: 0,  // 不含空格的字符数
    lines: 0,         // 总行数
    words: 0,         // 单词数(以空格分隔)
    chinese: 0,       // 中文字符数
    numbers: 0,       // 数字
    spaces: 0,        // 空格
    tabs: 0,          // Tab符号
    punctuation: 0    // 标点符号
})

function updateStats() {
    const text = t2_7_in.value;
    // 总字符数
    t2_7_stats.value.chars = text.length;
    // 不含空格的字符数
    t2_7_stats.value.charsNoSpace = text.replace(/\s/g, '').length;
    // 行数
    t2_7_stats.value.lines = text ? text.split('\n').length : 0;
    // 单词数
    t2_7_stats.value.words = text.trim() ? text.trim().split(/\s+/).length : 0;
    // 中文字符数
    t2_7_stats.value.chinese = (text.match(/[\u4e00-\u9fa5]/g) || []).length;
    // 数字
    t2_7_stats.value.numbers = (text.match(/[0-9]/g) || []).length;
    // 空格
    t2_7_stats.value.spaces = (text.match(/ /g) || []).length;
    // Tab符号
    t2_7_stats.value.tabs = (text.match(/\t/g) || []).length;
    // 标点符号 (中英文常用标点)
    t2_7_stats.value.punctuation = (text.match(/[,.，。！？!?:;：；""''「」『』\[\]\(\)\{\}【】()《》]/g) || []).length;
}

function clear_t2_7() {
    t2_7_in.value = "";
    updateStats();
}

// 使用watch监听文本变化，解决输入法输入问题
watch(() => t2_7_in.value, () => {
    updateStats();
});

// t2-8 文本对比工具 
const t2_8_left: any = ref("")
const t2_8_right: any = ref("")

interface DiffItem {
    lineNum: number;
    left: string;
    right: string;
    leftHighlight?: number[];
    rightHighlight?: number[];
    different: boolean;
}

const t2_8_diff = ref<DiffItem[]>([])

// 计算两个文本的差异，并对不同之处进行标记
function processDiff() {
    const left = t2_8_left.value || "";
    const right = t2_8_right.value || "";
    
    // 按行拆分文本
    const leftLines = left.split('\n');
    const rightLines = right.split('\n');
    
    const result = [];
    const maxLines = Math.max(leftLines.length, rightLines.length);
    
    for (let i = 0; i < maxLines; i++) {
        const leftLine = i < leftLines.length ? leftLines[i] : "";
        const rightLine = i < rightLines.length ? rightLines[i] : "";
        
        if (leftLine === rightLine) {
            // 相同行
            result.push({
                lineNum: i + 1,
                left: leftLine,
                right: rightLine,
                different: false
            });
        } else {
            // 不同行 - 标记字符级差异
            const diffChars = findDiffChars(leftLine, rightLine);
            result.push({
                lineNum: i + 1,
                left: leftLine,
                right: rightLine,
                leftHighlight: diffChars.left,
                rightHighlight: diffChars.right,
                different: true
            });
        }
    }
    
    t2_8_diff.value = result;
}

// 查找两行文本中字符级的差异
function findDiffChars(str1: string, str2: string) {
    const len1 = str1.length;
    const len2 = str2.length;
    const maxLen = Math.max(len1, len2);
    
    const left = [];
    const right = [];
    
    for (let i = 0; i < maxLen; i++) {
        if (i >= len1) {
            // str1已结束，str2剩余字符全部标记为不同
            right.push(i);
        } else if (i >= len2) {
            // str2已结束，str1剩余字符全部标记为不同
            left.push(i);
        } else if (str1[i] !== str2[i]) {
            // 当前位置字符不同
            left.push(i);
            right.push(i);
        }
    }
    
    return { left, right };
}

// 清空对比工具输入框
function clear_t2_8() {
    t2_8_left.value = "";
    t2_8_right.value = "";
    t2_8_diff.value = [];
}

// t2-6  ASCII 码表数据
interface AsciiRow {
    dec: number;
    hex: string;
    char: string;
}

const asciiData: AsciiRow[] = Array.from({ length: 128 }, (_, i) => ({
    dec: i,
    hex: i.toString(16).toUpperCase().padStart(2, '0'),
    char: (i >= 32 && i !== 127) ? String.fromCharCode(i) : ''
}));

// t3-1
const t3_1_in: any = ref("")
function clear_t3_1() {
    t3_1_in.value = ""
}
function process_t3_1() {
    try {
        t3_1_in.value = JSON.stringify(JSON.parse(t3_1_in.value), null, 4)
    } catch (err) {
        Message.clear()
        Message.error({ content: 'JSON格式化失败,请检查输入的JSON是否正确', position: 'bottom' })
    }
}

// t3-2  JSON <-> YAML
const t3_2_in: any = ref("")
const t3_2_out: any = ref("")

function clear_t3_2() {
    t3_2_in.value = ""
    t3_2_out.value = ""
}

function process_t3_2() {
    try {
        const obj = JSON.parse(t3_2_in.value)
        t3_2_out.value = yamlDump(obj)
    } catch (err) {
        Message.clear()
        Message.error({ content: 'JSON转YAML失败,请检查输入的JSON是否正确', position: 'bottom' })
    }
}

function process_t3_2_re() {
    try {
        const obj: any = yamlLoad(t3_2_out.value)
        t3_2_in.value = JSON.stringify(obj, null, 4)
    } catch (err) {
        Message.clear()
        Message.error({ content: 'YAML转JSON失败,请检查输入的YAML是否正确', position: 'bottom' })
    }
}

// t3-3 屏幕取色器
const t3_3_picked_color = ref('')
const t3_3_is_picking = ref(false)
const t3_3_screenshot_data = ref('')

async function startScreenColorPicker() {
    if (!('EyeDropper' in window)) {
        Message.error({ content: '您的环境不支持屏幕取色器功能', position: 'bottom' });
        return;
    }

    try {
        // 设置取色中状态
        t3_3_is_picking.value = true;
        
        // 请求主进程截取全屏幕
        window.ipcRenderer.send('capture-screen');
        
        // 监听截图结果
        window.ipcRenderer.once('screen-captured', (event, imageData) => {
            // 保存截图数据并创建临时图像
            t3_3_screenshot_data.value = imageData;
            
            // 在截图上使用EyeDropper
            const eyeDropper = new (window as any).EyeDropper();
            
            // 创建临时图片元素并加载截图
            const tempImage = new Image();
            tempImage.src = imageData;
            
            tempImage.onload = async () => {
                try {
                    // 将截图添加到DOM中
                    const tempContainer = document.createElement('div');
                    tempContainer.style.position = 'fixed';
                    tempContainer.style.top = '0';
                    tempContainer.style.left = '0';
                    tempContainer.style.width = '100vw';
                    tempContainer.style.height = '100vh';
                    tempContainer.style.zIndex = '9999';
                    tempContainer.style.backgroundColor = 'transparent';
                    
                    // 设置图片样式，使其适应窗口大小
                    tempImage.style.width = '100%';
                    tempImage.style.height = '100%';
                    tempImage.style.objectFit = 'contain'; // 保持原始比例
                    
                    tempContainer.appendChild(tempImage);
                    document.body.appendChild(tempContainer);
                    
                    // 修改光标样式为取色器
                    document.body.style.cursor = 'crosshair';
                    
                    // 打开取色器
        const result = await eyeDropper.open();
        t3_3_picked_color.value = result.sRGBHex;
        Message.success({ content: `颜色已选取: ${result.sRGBHex}`, position: 'bottom' });
                    
                    // 清理
                    document.body.removeChild(tempContainer);
                    document.body.style.cursor = '';
                } catch (error) {
        Message.info({ content: '已取消取色', position: 'bottom' });
                    
                    // 确保清理
                    const tempContainer = document.querySelector('div[style*="z-index: 9999"]');
                    if (tempContainer) {
                        document.body.removeChild(tempContainer);
                    }
                    document.body.style.cursor = '';
    } finally {
                    t3_3_is_picking.value = false;
                }
            };
            
            tempImage.onerror = () => {
                Message.error({ content: '加载截图失败', position: 'bottom' });
                t3_3_is_picking.value = false;
            };
        });
    } catch (e) {
        Message.info({ content: '取色过程出错', position: 'bottom' });
        t3_3_is_picking.value = false;
    }
}

// t3-4 颜色选择器
const t3_4_color = ref('#165DFF');

// t5-2
const t5_2_in: any = ref("")
const t5_2_out_small: any = ref("")
const t5_2_out_big: any = ref("")
function process_t5_2() {
    var md5 = CryptoJS.MD5(t5_2_in.value).toString()
    t5_2_out_small.value = md5
    t5_2_out_big.value = md5.toUpperCase()
}

// t5-3
const t5_3_in: any = ref("")
const t5_3_out_small: any = ref("")
const t5_3_out_big: any = ref("")
function process_t5_3() {
    var sha1 = CryptoJS.SHA1(t5_3_in.value).toString()
    t5_3_out_small.value = sha1
    t5_3_out_big.value = sha1.toUpperCase()
}

// t5-4
const t5_4_in: any = ref("")
const t5_4_out_small: any = ref("")
const t5_4_out_big: any = ref("")
function process_t5_4() {
    var sha256 = CryptoJS.SHA256(t5_4_in.value).toString()
    t5_4_out_small.value = sha256
    t5_4_out_big.value = sha256.toUpperCase()
}

// t6-1
const t6_1_in: any = ref(0)
const t6_1_out: any = ref("")
function process_t6_1() {
    if (t6_1_in.value < 1 || t6_1_in.value > 99) {
        Message.clear()
        Message.error({ content: '请输入1-99之间的数字', position: 'bottom' })
        return
    }
    // 生成长度为t6_1_in的随机数 纯数字
    var str = ""
    for (var i = 0; i < t6_1_in.value; i++) {
        str += Math.floor(Math.random() * 10)
    }
    t6_1_out.value = str

}

// t6-2
const t6_2_in: any = ref(0)
const t6_2_out: any = ref("")
function process_t6_2() {
    if (t6_2_in.value < 1 || t6_2_in.value > 99) {
        Message.clear()
        Message.error({ content: '请输入1-99之间的数字', position: 'bottom' })
        return
    }
    // 生成长度为t6_2_in的随机数 纯字母
    var str = ""
    for (var i = 0; i < t6_2_in.value; i++) {
        str += String.fromCharCode(Math.floor(Math.random() * 26) + 97)
    }
    t6_2_out.value = str
}

// t6-3
const t6_3_in: any = ref(0)
const t6_3_out: any = ref("")
function process_t6_3() {
    if (t6_3_in.value < 1 || t6_3_in.value > 99) {
        Message.clear()
        Message.error({ content: '请输入1-99之间的数字', position: 'bottom' })
        return
    }
    // 生成长度为t6_3_in的随机数 数字+字母
    var str = ""
    for (var i = 0; i < t6_3_in.value; i++) {
        if (Math.random() > 0.5) {
            str += Math.floor(Math.random() * 10)
        } else {
            str += String.fromCharCode(Math.floor(Math.random() * 26) + 97)
        }
    }
    t6_3_out.value = str
}

// t6-4 随机MAC地址
const t6_4_count = ref(1); // 默认生成1个
const t6_4_format = ref('colon'); // 默认使用冒号分隔
const t6_4_case = ref('lower'); // 默认小写
const t6_4_vendor = ref('random'); // 默认随机厂商
const t6_4_results = ref<string[]>([]);

// 一些常见网络设备厂商的MAC前缀
const macVendorPrefixes: Record<string, string[]> = {
    'cisco': ['00:00:0C', '00:01:42', '00:03:6B', '00:04:9A'],
    'dell': ['00:14:22', 'F8:DB:88', 'F8:BC:12', '74:86:7A'],
    'apple': ['00:03:93', '00:05:02', '00:0A:27', '00:0A:95', '00:1E:52'],
    'huawei': ['00:18:82', '00:1E:10', '00:25:9E', '00:34:FE', '00:E0:FC'],
    'samsung': ['00:07:AB', '00:12:47', '00:15:99', '00:17:C9', '00:1D:25'],
    'tp-link': ['00:14:2D', '00:19:E0', '00:21:27', '00:23:CD', '00:25:86'],
    'xiaomi': ['28:6C:07', '64:09:80', '8C:BE:BE', 'F0:B4:29', 'FC:64:BA'],
    'random': []
};

// 生成随机MAC地址
function generateRandomMAC(format: string, caseType: string, vendor: string): string {
    // 生成随机MAC地址的函数
    const generateRandomHex = (length: number): string => {
        const hex = '0123456789abcdef';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += hex.charAt(Math.floor(Math.random() * hex.length));
        }
        return result;
    };

    let mac = '';
    
    // 如果选择了特定厂商
    if (vendor !== 'random' && macVendorPrefixes[vendor]) {
        // 随机选择该厂商的一个前缀
        const prefixes = macVendorPrefixes[vendor];
        const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
        
        // 使用选定的厂商前缀
        mac = prefix;
        
        // 添加剩余部分
        for (let i = 0; i < 3; i++) {
            mac += format === 'colon' ? ':' : (format === 'hyphen' ? '-' : '');
            mac += generateRandomHex(2);
        }
    } else {
        // 完全随机生成
        for (let i = 0; i < 6; i++) {
            if (i > 0) {
                mac += format === 'colon' ? ':' : (format === 'hyphen' ? '-' : '');
            }
            mac += generateRandomHex(2);
        }
    }
    
    // 转换大小写
    return caseType === 'upper' ? mac.toUpperCase() : mac;
}

// 生成MAC地址
function generateMACAddresses() {
    const count = Math.min(Math.max(1, t6_4_count.value), 100); // 限制最多生成100个
    const format = t6_4_format.value;
    const caseType = t6_4_case.value;
    const vendor = t6_4_vendor.value;
    
    t6_4_results.value = [];
    
    for (let i = 0; i < count; i++) {
        t6_4_results.value.push(generateRandomMAC(format, caseType, vendor));
    }
}

// 复制MAC地址
function copyMAC(mac: string) {
    navigator.clipboard.writeText(mac).then(() => {
        Message.success({ content: '已复制到剪贴板: ' + mac, position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// t6-5 随机IPv4地址
const t6_5_count = ref(1); // 默认生成1个
const t6_5_class = ref('any'); // 默认任意类型
const t6_5_private = ref(false); // 默认不限制为私有地址
const t6_5_results = ref<string[]>([]);

// 生成随机IPv4地址
function generateRandomIPv4(ipClass: string, privateOnly: boolean): string {
    // 随机生成1-254之间的数字
    const randomOctet = () => Math.floor(Math.random() * 254) + 1;
    
    let firstOctet: number;
    let secondOctet: number;
    let thirdOctet: number;
    let fourthOctet: number;
    
    if (privateOnly) {
        // 生成私有IP地址
        const privateRanges = [
            { first: 10, second: [0, 255], third: [0, 255], fourth: [1, 254] }, // 10.0.0.0/8
            { first: 172, second: [16, 31], third: [0, 255], fourth: [1, 254] }, // 172.16.0.0/12
            { first: 192, second: [168], third: [0, 255], fourth: [1, 254] }  // 192.168.0.0/16
        ];
        
        // 随机选择一个私有IP范围
        const range = privateRanges[Math.floor(Math.random() * privateRanges.length)];
        
        firstOctet = range.first;
        secondOctet = range.second.length === 1 
            ? range.second[0] 
            : Math.floor(Math.random() * (range.second[1] - range.second[0] + 1)) + range.second[0];
        thirdOctet = Math.floor(Math.random() * (range.third[1] - range.third[0] + 1)) + range.third[0];
        fourthOctet = Math.floor(Math.random() * (range.fourth[1] - range.fourth[0] + 1)) + range.fourth[0];
    } else {
        // 根据IP类别生成
        switch (ipClass) {
            case 'a': // A类: 1-126.x.x.x
                firstOctet = Math.floor(Math.random() * 126) + 1;
                break;
            case 'b': // B类: 128-191.x.x.x
                firstOctet = Math.floor(Math.random() * 64) + 128;
                break;
            case 'c': // C类: 192-223.x.x.x
                firstOctet = Math.floor(Math.random() * 32) + 192;
                break;
            case 'd': // D类: 224-239.x.x.x (组播地址)
                firstOctet = Math.floor(Math.random() * 16) + 224;
                break;
            case 'e': // E类: 240-255.x.x.x (保留地址)
                firstOctet = Math.floor(Math.random() * 16) + 240;
                break;
            default: // 任意类型
                firstOctet = randomOctet();
                // 避开保留的地址
                while (firstOctet === 127) { // 避开127.x.x.x (环回地址)
                    firstOctet = randomOctet();
                }
        }
        
        secondOctet = randomOctet();
        thirdOctet = randomOctet();
        fourthOctet = randomOctet();
    }
    
    return `${firstOctet}.${secondOctet}.${thirdOctet}.${fourthOctet}`;
}

// 生成IPv4地址
function generateIPv4Addresses() {
    const count = Math.min(Math.max(1, t6_5_count.value), 100); // 限制最多生成100个
    const ipClass = t6_5_class.value;
    const privateOnly = t6_5_private.value;
    
    t6_5_results.value = [];
    
    for (let i = 0; i < count; i++) {
        t6_5_results.value.push(generateRandomIPv4(ipClass, privateOnly));
    }
}

// 复制IPv4地址
function copyIPv4(ip: string) {
    navigator.clipboard.writeText(ip).then(() => {
        Message.success({ content: '已复制到剪贴板: ' + ip, position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// t6-6 随机IPv6地址
const t6_6_count = ref(1); // 默认生成1个
const t6_6_format = ref('full'); // 默认完整格式
const t6_6_results = ref<string[]>([]);

// 生成随机IPv6地址
function generateRandomIPv6(format: string): string {
    // 生成随机16进制数
    const randomHex = (length: number): string => {
        const hex = '0123456789abcdef';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += hex.charAt(Math.floor(Math.random() * hex.length));
        }
        return result;
    };
    
    if (format === 'full') {
        // 生成完整格式的IPv6地址
        let ipv6 = '';
        for (let i = 0; i < 8; i++) {
            if (i > 0) ipv6 += ':';
            ipv6 += randomHex(4);
        }
        return ipv6;
    } else {
        // 生成压缩格式的IPv6地址
        // 首先生成8组
        const groups = [];
        for (let i = 0; i < 8; i++) {
            groups.push(randomHex(4));
        }
        
        // 找出最长的连续0组
        let longestZeroStart = -1;
        let longestZeroLength = 0;
        let currentZeroStart = -1;
        let currentZeroLength = 0;
        
        for (let i = 0; i < groups.length; i++) {
            if (groups[i] === '0000') {
                if (currentZeroStart === -1) {
                    currentZeroStart = i;
                }
                currentZeroLength++;
                
                if (currentZeroLength > longestZeroLength) {
                    longestZeroStart = currentZeroStart;
                    longestZeroLength = currentZeroLength;
                }
            } else {
                currentZeroStart = -1;
                currentZeroLength = 0;
            }
        }
        
        // 如果有连续的0组且长度大于1，则压缩
        if (longestZeroLength > 1) {
            let ipv6 = '';
            for (let i = 0; i < longestZeroStart; i++) {
                ipv6 += (i > 0 ? ':' : '') + groups[i].replace(/^0+/, '') || '0';
            }
            
            ipv6 += '::';
            
            for (let i = longestZeroStart + longestZeroLength; i < groups.length; i++) {
                ipv6 += groups[i].replace(/^0+/, '') || '0';
                if (i < groups.length - 1) ipv6 += ':';
            }
            
            return ipv6;
        } else {
            // 没有足够长的连续0组，但仍然去掉前导0
            return groups.map(g => g.replace(/^0+/, '') || '0').join(':');
        }
    }
}

// 生成IPv6地址
function generateIPv6Addresses() {
    const count = Math.min(Math.max(1, t6_6_count.value), 100); // 限制最多生成100个
    const format = t6_6_format.value;
    
    t6_6_results.value = [];
    
    for (let i = 0; i < count; i++) {
        t6_6_results.value.push(generateRandomIPv6(format));
    }
}

// 复制IPv6地址
function copyIPv6(ip: string) {
    navigator.clipboard.writeText(ip).then(() => {
        Message.success({ content: '已复制到剪贴板: ' + ip, position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// t7-1 WebSocket测试工具
const ws_url: any = ref("ws://echo.websocket.org") // 默认使用echo测试服务器
const ws_connection: any = ref(null)
const ws_connected: any = ref(false)
const ws_message: any = ref("")
const ws_logs: any = ref([])
const ws_auto_scroll: any = ref(true)

// 记录日志
function addLog(type: string, message: string) {
    const timestamp = new Date().toLocaleTimeString();
    ws_logs.value.push({
        id: Date.now() + Math.random(),
        type, 
        message, 
        timestamp
    });
    
    // 自动滚动到底部
    if (ws_auto_scroll.value) {
        setTimeout(() => {
            const container = document.querySelector('.ws-log-container');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }, 50);
    }
}

// 连接WebSocket
function connectWebSocket() {
    if (ws_connected.value) {
        addLog('warning', '已经连接到WebSocket服务器，请先断开连接');
        return;
    }
    
    try {
        ws_connection.value = new WebSocket(ws_url.value);
        
        ws_connection.value.onopen = () => {
            ws_connected.value = true;
            addLog('success', `已连接到 ${ws_url.value}`);
        };
        
        ws_connection.value.onmessage = (event: any) => {
            addLog('received', event.data);
        };
        
        ws_connection.value.onerror = (error: any) => {
            addLog('error', '连接错误');
            console.error('WebSocket error:', error);
        };
        
        ws_connection.value.onclose = () => {
            ws_connected.value = false;
            addLog('info', '连接已关闭');
        };
    } catch (error) {
        addLog('error', `连接失败: ${error}`);
    }
}

// 断开WebSocket连接
function disconnectWebSocket() {
    if (!ws_connection.value) {
        addLog('warning', '没有活动的WebSocket连接');
        return;
    }
    
    ws_connection.value.close();
    ws_connection.value = null;
    ws_connected.value = false;
}

// 发送消息
function sendMessage() {
    if (!ws_connected.value || !ws_connection.value) {
        addLog('error', '未连接到WebSocket服务器');
        return;
    }
    
    if (!ws_message.value.trim()) {
        addLog('warning', '消息不能为空');
        return;
    }
    
    try {
        ws_connection.value.send(ws_message.value);
        addLog('sent', ws_message.value);
        ws_message.value = ''; // 清空输入框
    } catch (error) {
        addLog('error', `发送失败: ${error}`);
    }
}

// 清空日志
function clearLogs() {
    ws_logs.value = [];
}

// t7-2 RESTful API测试工具
const rest_url = ref('https://jsonplaceholder.typicode.com/posts/1');
const rest_method = ref('GET');
const rest_headers = ref('{\n  "Content-Type": "application/json"\n}');
const rest_body = ref('{\n  "title": "foo",\n  "body": "bar",\n  "userId": 1\n}');
const rest_response = ref('');
const rest_status = ref('');
const rest_loading = ref(false);
const rest_response_time = ref(0);
const rest_response_size = ref(0);
const rest_error = ref('');
const rest_history = ref<Array<{
    time: string;
    method: string;
    url: string;
    status: number;
    duration: number;
    id: number;
}>>([]);
const rest_content_type = ref('json');

// 发送请求
async function sendRequest() {
    rest_loading.value = true;
    rest_error.value = '';
    rest_response.value = '';
    rest_status.value = '';
    rest_response_time.value = 0;
    rest_response_size.value = 0;
    
    try {
        let headers: Record<string, string> = {};
        try {
            headers = JSON.parse(rest_headers.value);
        } catch (e) {
            rest_error.value = '请求头格式错误，应为有效的JSON格式';
            rest_loading.value = false;
            return;
        }
        
        let data = null;
        if (['POST', 'PUT', 'PATCH'].includes(rest_method.value.toLowerCase()) && rest_body.value) {
            try {
                if (rest_content_type.value === 'json') {
                    data = JSON.parse(rest_body.value);
                } else if (rest_content_type.value === 'form') {
                    // 将表单数据转换为URLSearchParams
                    const formData = JSON.parse(rest_body.value);
                    const params = new URLSearchParams();
                    for (const key in formData) {
                        params.append(key, formData[key]);
                    }
                    data = params;
                    // 自动设置Content-Type
                    if (!headers['Content-Type']) {
                        headers = { ...headers, 'Content-Type': 'application/x-www-form-urlencoded' };
                    }
                } else if (rest_content_type.value === 'raw') {
                    // 作为原始字符串发送
                    data = rest_body.value;
                }
            } catch (e) {
                rest_error.value = '请求体格式错误，应为有效的JSON格式';
                rest_loading.value = false;
                return;
            }
        }
        
        const startTime = new Date().getTime();
        
        const response = await axios({
            method: rest_method.value.toLowerCase(),
            url: rest_url.value,
            headers: headers,
            data: data,
            validateStatus: function() {
                return true; // 允许任何状态码通过，以便我们手动处理
            }
        });
        
        const endTime = new Date().getTime();
        rest_response_time.value = endTime - startTime;
        
        // 处理响应
        rest_status.value = `${response.status} ${response.statusText}`;
        
        if (typeof response.data === 'object') {
            rest_response.value = JSON.stringify(response.data, null, 2);
            rest_response_size.value = JSON.stringify(response.data).length;
        } else {
            rest_response.value = String(response.data);
            rest_response_size.value = String(response.data).length;
        }
        
        // 添加到历史记录
        rest_history.value.unshift({
            time: new Date().toLocaleTimeString(),
            method: rest_method.value,
            url: rest_url.value,
            status: response.status,
            duration: rest_response_time.value,
            id: Date.now()
        });
        
        // 限制历史记录数量
        if (rest_history.value.length > 10) {
            rest_history.value = rest_history.value.slice(0, 10);
        }
    } catch (error: any) {
        rest_error.value = `请求失败: ${error.message}`;
    } finally {
        rest_loading.value = false;
    }
}

// 清除输入
function clearRestInputs() {
    rest_body.value = '{\n  "title": "foo",\n  "body": "bar",\n  "userId": 1\n}';
    rest_headers.value = '{\n  "Content-Type": "application/json"\n}';
    rest_response.value = '';
    rest_status.value = '';
    rest_error.value = '';
}

// 加载历史记录
function loadHistory(item: {
    time: string;
    method: string;
    url: string;
    status: number;
    duration: number;
    id: number;
}) {
    rest_url.value = item.url;
    rest_method.value = item.method;
}

// 美化JSON
function prettifyJson() {
    try {
        const obj = JSON.parse(rest_body.value);
        rest_body.value = JSON.stringify(obj, null, 2);
    } catch (e) {
        rest_error.value = '不是有效的JSON格式';
    }
}

// t5-5 密码强度分析
const t5_5_password = ref('')
const t5_5_score = ref(0)
const t5_5_feedback = ref('')
const t5_5_criteria = ref([
    { id: 1, name: '长度 ≥ 8', met: false, score: 20, description: '密码长度至少为8个字符' },
    { id: 2, name: '包含小写字母', met: false, score: 20, description: '密码中包含至少一个小写字母(a-z)' },
    { id: 3, name: '包含大写字母', met: false, score: 20, description: '密码中包含至少一个大写字母(A-Z)' },
    { id: 4, name: '包含数字', met: false, score: 20, description: '密码中包含至少一个数字(0-9)' },
    { id: 5, name: '包含特殊字符', met: false, score: 20, description: '密码中包含至少一个特殊字符(!@#$%等)' }
])
const t5_5_strength_color = ref('')

function analyzePassword() {
    const pwd = t5_5_password.value
    let score = 0
    
    // 重置所有条件状态
    t5_5_criteria.value.forEach(criterion => {
        criterion.met = false
    })
    
    // 检查长度
    if (pwd.length >= 8) {
        t5_5_criteria.value[0].met = true
        score += 20
    } else {
        score += Math.min(pwd.length * 2, 19) // 最多给19分，不满足条件
    }
    
    // 检查小写字母
    if (/[a-z]/.test(pwd)) {
        t5_5_criteria.value[1].met = true
        score += 20
    }
    
    // 检查大写字母
    if (/[A-Z]/.test(pwd)) {
        t5_5_criteria.value[2].met = true
        score += 20
    }
    
    // 检查数字
    if (/[0-9]/.test(pwd)) {
        t5_5_criteria.value[3].met = true
        score += 20
    }
    
    // 检查特殊字符
    if (/[^A-Za-z0-9]/.test(pwd)) {
        t5_5_criteria.value[4].met = true
        score += 20
    }
    
    // 确保分数不超过100
    if (score > 100) score = 100
    
    t5_5_score.value = score
    
    // 设置强度评级和颜色
    if (score >= 80) {
        t5_5_feedback.value = '强'
        t5_5_strength_color.value = '#52c41a' // 绿色
    } else if (score >= 60) {
        t5_5_feedback.value = '中'
        t5_5_strength_color.value = '#faad14' // 黄色
    } else {
        t5_5_feedback.value = '弱'
        t5_5_strength_color.value = '#f5222d' // 红色
    }
}

// t3-5 常用HTML颜色
const htmlColorCategories = ref([
    {
        name: "基础颜色",
        colors: [
            { name: "黑色", hex: "#000000" },
            { name: "白色", hex: "#FFFFFF" },
            { name: "红色", hex: "#FF0000" },
            { name: "绿色", hex: "#008000" },
            { name: "蓝色", hex: "#0000FF" },
            { name: "黄色", hex: "#FFFF00" },
            { name: "青色", hex: "#00FFFF" },
            { name: "品红", hex: "#FF00FF" },
            { name: "银色", hex: "#C0C0C0" },
            { name: "灰色", hex: "#808080" },
            { name: "栗色", hex: "#800000" },
            { name: "橄榄色", hex: "#808000" },
            { name: "深绿色", hex: "#008080" },
            { name: "海军蓝", hex: "#000080" },
            { name: "紫色", hex: "#800080" }
        ]
    },
    {
        name: "红色系",
        colors: [
            { name: "印度红", hex: "#CD5C5C" },
            { name: "浅珊瑚色", hex: "#F08080" },
            { name: "珊瑚色", hex: "#FF7F50" },
            { name: "番茄红", hex: "#FF6347" },
            { name: "橙红色", hex: "#FF4500" },
            { name: "深红色", hex: "#DC143C" },
            { name: "粉红色", hex: "#FFC0CB" },
            { name: "亮粉红色", hex: "#FFB6C1" },
            { name: "热粉红色", hex: "#FF69B4" },
            { name: "深粉红色", hex: "#FF1493" },
            { name: "褐红色", hex: "#B22222" },
            { name: "火砖色", hex: "#B22222" },
            { name: "猩红色", hex: "#8B0000" }
        ]
    },
    {
        name: "橙黄色系",
        colors: [
            { name: "橙色", hex: "#FFA500" },
            { name: "深橙色", hex: "#FF8C00" },
            { name: "琥珀色", hex: "#FFBF00" },
            { name: "金色", hex: "#FFD700" },
            { name: "浅黄色", hex: "#FFFFE0" },
            { name: "柠檬黄", hex: "#FFFACD" },
            { name: "卡其色", hex: "#F0E68C" },
            { name: "米色", hex: "#F5F5DC" },
            { name: "鹿皮色", hex: "#FFE4B5" },
            { name: "桃色", hex: "#FFDAB9" },
            { name: "橙红色", hex: "#FF4500" }
        ]
    },
    {
        name: "绿色系",
        colors: [
            { name: "黄绿色", hex: "#ADFF2F" },
            { name: "草绿色", hex: "#7CFC00" },
            { name: "石灰绿", hex: "#32CD32" },
            { name: "森林绿", hex: "#228B22" },
            { name: "海绿色", hex: "#2E8B57" },
            { name: "深绿色", hex: "#006400" },
            { name: "春绿色", hex: "#00FF7F" },
            { name: "薄荷色", hex: "#00FA9A" },
            { name: "中海绿", hex: "#3CB371" },
            { name: "橄榄土褐色", hex: "#6B8E23" },
            { name: "暗橄榄绿", hex: "#556B2F" }
        ]
    },
    {
        name: "蓝色系",
        colors: [
            { name: "天蓝色", hex: "#87CEEB" },
            { name: "深天蓝", hex: "#00BFFF" },
            { name: "道奇蓝", hex: "#1E90FF" },
            { name: "矢车菊蓝", hex: "#6495ED" },
            { name: "皇家蓝", hex: "#4169E1" },
            { name: "蓝紫色", hex: "#8A2BE2" },
            { name: "靛青色", hex: "#4B0082" },
            { name: "午夜蓝", hex: "#191970" },
            { name: "海军蓝", hex: "#000080" },
            { name: "深蓝色", hex: "#00008B" },
            { name: "粉蓝色", hex: "#B0E0E6" },
            { name: "浅蓝色", hex: "#ADD8E6" },
            { name: "钢蓝色", hex: "#4682B4" },
            { name: "青蓝色", hex: "#5F9EA0" }
        ]
    },
    {
        name: "紫色系",
        colors: [
            { name: "薰衣草紫", hex: "#E6E6FA" },
            { name: "蓟色", hex: "#D8BFD8" },
            { name: "梅红色", hex: "#DDA0DD" },
            { name: "紫罗兰色", hex: "#EE82EE" },
            { name: "洋红色", hex: "#DA70D6" },
            { name: "中紫色", hex: "#9370DB" },
            { name: "深紫色", hex: "#9400D3" },
            { name: "深洋红色", hex: "#8B008B" },
            { name: "紫色", hex: "#800080" },
            { name: "靛青色", hex: "#4B0082" },
            { name: "暗紫色", hex: "#663399" }
        ]
    },
    {
        name: "棕色系",
        colors: [
            { name: "玉米丝色", hex: "#FFF8DC" },
            { name: "花白色", hex: "#FFFAF0" },
            { name: "亚麻色", hex: "#FAF0E6" },
            { name: "古董白", hex: "#FAEBD7" },
            { name: "小麦色", hex: "#F5DEB3" },
            { name: "鹿皮色", hex: "#FFE4B5" },
            { name: "沙褐色", hex: "#F4A460" },
            { name: "秘鲁色", hex: "#CD853F" },
            { name: "巧克力色", hex: "#D2691E" },
            { name: "赭色", hex: "#A0522D" },
            { name: "马鞍棕色", hex: "#8B4513" },
            { name: "红木色", hex: "#A52A2A" }
        ]
    },
    {
        name: "灰白色系",
        colors: [
            { name: "白烟色", hex: "#F5F5F5" },
            { name: "雪白色", hex: "#FFFAFA" },
            { name: "亚麻白", hex: "#F0FFF0" },
            { name: "花白色", hex: "#FFFAF0" },
            { name: "幽灵白", hex: "#F8F8FF" },
            { name: "白色", hex: "#FFFFFF" },
            { name: "淡灰色", hex: "#DCDCDC" },
            { name: "亮灰色", hex: "#D3D3D3" },
            { name: "银白色", hex: "#C0C0C0" },
            { name: "深灰色", hex: "#A9A9A9" },
            { name: "暗淡灰色", hex: "#696969" },
            { name: "灰色", hex: "#808080" },
            { name: "暗灰色", hex: "#2F4F4F" }
        ]
    }
]);

// 复制HTML颜色值到剪贴板
function copyHTMLColorValue(value: string) {
    navigator.clipboard.writeText(value).then(() => {
        Message.success({ content: '已复制颜色代码: ' + value, position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// t3-6 回车转br标签
const t3_6_input = ref('');
const t3_6_output = ref('');
const t3_6_options = ref({
    preserveSpaces: true,  // 保留空格
    useNbsp: false,        // 使用&nbsp;替换空格
    addParagraphs: false   // 添加<p>标签
});

// t3-7 常用浏览器UA
const browserUAList = ref([
    {
        category: "Chrome浏览器",
        items: [
            {
                name: "Chrome 119 (Windows)",
                value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
            },
            {
                name: "Chrome 119 (macOS)",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
            },
            {
                name: "Chrome 119 (Linux)",
                value: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36"
            },
            {
                name: "Chrome 119 (Android)",
                value: "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36"
            },
            {
                name: "Chrome 119 (iOS)",
                value: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/119.0.6045.109 Mobile/15E148 Safari/604.1"
            }
        ]
    },
    {
        category: "Firefox浏览器",
        items: [
            {
                name: "Firefox 119 (Windows)",
                value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/119.0"
            },
            {
                name: "Firefox 119 (macOS)",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/119.0"
            },
            {
                name: "Firefox 119 (Linux)",
                value: "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/119.0"
            },
            {
                name: "Firefox 119 (Android)",
                value: "Mozilla/5.0 (Android 14; Mobile; rv:109.0) Gecko/119.0 Firefox/119.0"
            },
            {
                name: "Firefox 119 (iOS)",
                value: "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/119.0 Mobile/15E148 Safari/605.1.15"
            }
        ]
    },
    {
        category: "Safari浏览器",
        items: [
            {
                name: "Safari 16 (macOS)",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15"
            },
            {
                name: "Safari 17 (macOS)",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
            },
            {
                name: "Safari (iOS 16)",
                value: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
            },
            {
                name: "Safari (iOS 17)",
                value: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            },
            {
                name: "Safari (iPadOS)",
                value: "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            }
        ]
    },
    {
        category: "Edge浏览器",
        items: [
            {
                name: "Edge 119 (Windows)",
                value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0"
            },
            {
                name: "Edge 119 (macOS)",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36 Edg/119.0.0.0"
            },
            {
                name: "Edge 119 (Android)",
                value: "Mozilla/5.0 (Linux; Android 10; HD1913) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36 EdgA/119.0.0.0"
            },
            {
                name: "Edge 119 (iOS)",
                value: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 EdgiOS/119.0.0.0 Mobile/15E148 Safari/605.1.15"
            }
        ]
    },
    {
        category: "移动设备浏览器",
        items: [
            {
                name: "Android Chrome (三星 Galaxy S23)",
                value: "Mozilla/5.0 (Linux; Android 13; SM-S911B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"
            },
            {
                name: "Android Chrome (Google Pixel 7)",
                value: "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"
            },
            {
                name: "iOS Safari (iPhone 14)",
                value: "Mozilla/5.0 (iPhone14,3; U; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) Version/10.0 Mobile/19A346 Safari/602.1"
            },
            {
                name: "iOS Safari (iPad Pro)",
                value: "Mozilla/5.0 (iPad; CPU OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1"
            }
        ]
    },
    {
        category: "搜索引擎爬虫",
        items: [
            {
                name: "Google爬虫",
                value: "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
            },
            {
                name: "Bing爬虫",
                value: "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)"
            },
            {
                name: "百度爬虫",
                value: "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)"
            },
            {
                name: "搜狗爬虫",
                value: "Sogou web spider/4.0(+http://www.sogou.com/docs/help/webmasters.htm#07)"
            }
        ]
    },
    {
        category: "其他浏览器",
        items: [
            {
                name: "Opera 103 (Windows)",
                value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 OPR/103.0.0.0"
            },
            {
                name: "Opera 103 (macOS)",
                value: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 OPR/103.0.0.0"
            },
            {
                name: "Samsung Internet",
                value: "Mozilla/5.0 (Linux; Android 13; SAMSUNG SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/21.0 Chrome/110.0.5481.154 Mobile Safari/537.36"
            },
            {
                name: "UC Browser",
                value: "Mozilla/5.0 (Linux; U; Android 10; zh-CN; Redmi K30 5G) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/78.0.3904.108 UCBrowser/13.4.2.1122 Mobile Safari/537.36"
            }
        ]
    }
]);

// 复制UA字符串
function copyUA(value: string) {
    navigator.clipboard.writeText(value).then(() => {
        Message.success({ content: '已复制到剪贴板!', position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// 处理回车转br标签
function process_t3_6() {
    if (!t3_6_input.value) {
        Message.warning({ content: '请输入需要转换的文本', position: 'bottom' });
        return;
    }

    let result = t3_6_input.value;
    
    // 替换回车为<br/>标签
    result = result.replace(/\n/g, '<br/>');
    
    // 处理空格
    if (t3_6_options.value.preserveSpaces) {
        if (t3_6_options.value.useNbsp) {
            // 替换空格为&nbsp;
            result = result.replace(/ /g, '&nbsp;');
        } else {
            // 保留连续空格（HTML中连续空格会被合并为一个）
            result = result.replace(/ {2,}/g, function(match) {
                return '&nbsp;'.repeat(match.length);
            });
        }
    }
    
    // 添加段落标签
    if (t3_6_options.value.addParagraphs) {
        // 将连续的<br/>替换为段落
        result = '<p>' + result.replace(/<br\/><br\/>/g, '</p><p>') + '</p>';
        // 清理可能的空段落
        result = result.replace(/<p><\/p>/g, '');
    }
    
    t3_6_output.value = result;
    Message.success({ content: '转换完成!', position: 'bottom' });
}

// 复制转换结果
function copy_t3_6_result() {
    if (!t3_6_output.value) {
        Message.warning({ content: '没有可复制的内容', position: 'bottom' });
        return;
    }
    
    navigator.clipboard.writeText(t3_6_output.value).then(() => {
        Message.success({ content: '已复制到剪贴板!', position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// 清空输入和输出
function clear_t3_6() {
    t3_6_input.value = '';
    t3_6_output.value = '';
}

</script>

<template>
    <div class="tool-container">
        <div v-show="tooltype == 't1-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="条形码生成" @back="switchToMenu"
                    subtitle="数字生成条形码">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div>
                <a-row class="one-tool-content">
                    <a-col :span="24">
                        <a-row>
                            <a-col :span="4">
                                <p class="t1-1-title">请输入数字：</p>
                            </a-col>
                            <a-col :span="16">
                                <a-input v-model="t1_1_in" placeholder="请输入数字" class="t1-1-inputer"></a-input>
                            </a-col>
                            <a-col :span="4">
                                <a-button @click="generateBarcode" class="t1-1-button">生成条形码</a-button><br />
                            </a-col>
                        </a-row>
                        <a-row style="margin-top: 10px;">
                            <a-col :span="24" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <svg id="barcode"></svg>
                            </a-col>
                        </a-row>
                        <a-row style="margin-top: 10px;" v-show="t1_1_ok">
                            <a-col :span="24" style="width: 200px; ">
                                <a-button class="t1-1-button" style="margin: 0 15px;"
                                    @click="copySvgToClipboard('barcode')">复制条形码</a-button>
                                <a-button class="t1-1-button" style="margin: 0 15px;"
                                    @click="saveSvgImage('barcode')">保存条形码</a-button>
                            </a-col>
                        </a-row>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't1-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="二维码生成" @back="switchToMenu"
                    subtitle="文字、网址生成二维码">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="24">
                        <a-row>
                            <a-col :span="4">
                                <p class="t1-1-title">请输入文字：</p>
                            </a-col>
                            <a-col :span="16">
                                <a-input v-model="t1_2_in" placeholder="请输入文字" class="t1-1-inputer"></a-input>
                            </a-col>
                            <a-col :span="4">
                                <a-button @click="generateQrcode" class="t1-1-button">刷新二维码</a-button><br />
                            </a-col>
                        </a-row>
                        <a-row style="margin-top: 10px;">
                            <a-col :span="24" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <qrcode-vue :value="t1_2_qr" :size="200" :level="'H'" :fg-color="'#000000'"
                                    :bg-color="'#ffffff'" id="qrcode" />
                            </a-col>
                        </a-row>
                        <a-row style="margin-top: 10px;">
                            <a-col :span="24" style="width: 200px; ">
                                <a-button class="t1-1-button" style="margin: 0 15px;"
                                    @click="copyCanvasToClipboard('qrcode')">复制二维码</a-button>
                                <a-button class="t1-1-button" style="margin: 0 15px;"
                                    @click="saveCanvasImage('qrcode')">保存二维码</a-button>
                            </a-col>
                        </a-row>


                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't2-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="字符串去空格" @back="switchToMenu"
                    subtitle="去除字符串中的空格">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="24">
                        <a-row style="margin-top: 5px;">
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="原始文本" v-model="t2_1_in" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                            <a-col :span="2"
                                style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%;">
                                <a-button @click="process_t2_1()" class="t1-1-button">处理</a-button><br />
                                <a-button @click="clear_t2_1()" class="t1-1-button">清空</a-button><br />
                            </a-col>
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="处理结果" v-model="t2_1_out" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                        </a-row>


                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't2-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="字符串去回车" @back="switchToMenu"
                    subtitle="去除字符串中的回车">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="24">
                        <a-row style="margin-top: 5px;">
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="原始文本" v-model="t2_2_in" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                            <a-col :span="2"
                                style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%;">
                                <a-button @click="process_t2_2()" class="t1-1-button">处理</a-button><br />
                                <a-button @click="clear_t2_2()" class="t1-1-button">清空</a-button><br />
                            </a-col>
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="处理结果" v-model="t2_2_out" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                        </a-row>


                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't2-3'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="去除空格回车" @back="switchToMenu"
                    subtitle="去除其中字符回车">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="24">
                        <a-row style="margin-top: 5px;">
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="原始文本" v-model="t2_3_in" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                            <a-col :span="2"
                                style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%;">
                                <a-button @click="process_t2_3()" class="t1-1-button">处理</a-button><br />
                                <a-button @click="clear_t2_3()" class="t1-1-button">清空</a-button><br />
                            </a-col>
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="处理结果" v-model="t2_3_out" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                        </a-row>


                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't2-4'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="中文转Unicode" @back="switchToMenu"
                    subtitle="中文与Unicode互转">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="24">
                        <a-row style="margin-top: 5px;">
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="原始文本" v-model="t2_4_in" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                            <a-col :span="2"
                                style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%;">
                                <a-button @click="process_t2_4()" class="t1-1-button"
                                    style="width: 60px;">-></a-button><br />
                                <a-button @click="process_t2_4_re()" class="t1-1-button" style="width: 60px;"><-</a-button><br />
                                        <a-button @click="clear_t2_4()" class="t1-1-button">清空</a-button><br />
                            </a-col>
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="Unicode编码" v-model="t2_4_out" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't2-5'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="替换与转义" @back="switchToMenu"
                    subtitle="替换指定字符">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="24">
                        <a-row style="margin-top: 5px;">
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="原始文本" v-model="t2_5_in" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                            <a-col :span="2"
                                style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%;">
                                <input type="text" v-model="t2_5_from" placeholder="原本" class="t1-1-inputer"
                                    style="width: 45px;" /><br />
                                <input type="text" v-model="t2_5_to" placeholder="替换" class="t1-1-inputer"
                                    style="width: 45px;" /><br />
                                <a-button @click="process_t2_5()" class="t1-1-button"
                                    style="width: 60px;">-></a-button><br />
                                <a-button @click="clear_t2_5()" class="t1-1-button">清空</a-button><br />
                            </a-col>
                            <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                                <a-textarea placeholder="Unicode编码" v-model="t2_5_out" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't3-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="JSON格式化" @back="switchToMenu"
                    subtitle="替换指定字符">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="22">
                        <a-row style="margin-top: 5px;">
                            <a-col :span="24">
                                <a-textarea placeholder="待格式化JSON" v-model="t3_1_in" :auto-size="{
                                    minRows: 22,
                                    maxRows: 22
                                }" />
                            </a-col>
                        </a-row>
                    </a-col>
                    <a-col :span="2"
                        style="display: flex; flex-direction: column; justify-content: center; align-items: center; height: 100%;margin-top: 5px;">
                        <a-button @click="process_t3_1()" class="t1-1-button" style="width: 60px;">格式化</a-button><br />
                        <a-button @click="clear_t3_1()" class="t1-1-button">清空</a-button><br />
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't3-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="JSON转YAML" @back="switchToMenu"
                    subtitle="双向转换 JSON ⇄ YAML">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                        <a-textarea placeholder="JSON" v-model="t3_2_in" :auto-size="{ minRows: 22, maxRows: 22 }" />
                    </a-col>
                    <a-col :span="2" style="display:flex;flex-direction:column;justify-content:center;align-items:center;height:100%;">
                        <a-button @click="process_t3_2()" class="t1-1-button" style="width:60px;">-&gt;</a-button><br />
                        <a-button @click="process_t3_2_re()" class="t1-1-button" style="width:60px;">&lt;-</a-button><br />
                        <a-button @click="clear_t3_2()" class="t1-1-button">清空</a-button><br />
                    </a-col>
                    <a-col :span="11" style="width: 200px; overflow-x: auto; white-space: nowrap;">
                        <a-textarea placeholder="YAML" v-model="t3_2_out" :auto-size="{ minRows: 22, maxRows: 22 }" />
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-3'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="屏幕取色器" @back="switchToMenu"
                    subtitle="拾取屏幕任意位置的颜色">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <div style="padding: 20px;">
                    <a-card :bordered="false" style="text-align: center;">
                        <a-button 
                            type="primary" 
                            @click="startScreenColorPicker" 
                            :loading="t3_3_is_picking"
                            size="large"
                            style="width: 200px; height: 50px; font-size: 18px;"
                        >
                            {{ t3_3_is_picking ? '取色中...' : '开始取色' }}
                        </a-button>

                        <div v-if="t3_3_picked_color" style="margin-top: 30px;">
                            <a-divider>取色结果</a-divider>
                            <div style="display: flex; align-items: center; justify-content: center; margin-top: 20px;">
                                <div :style="{ backgroundColor: t3_3_picked_color, width: '80px', height: '80px', borderRadius: '8px', border: '1px solid #d9d9d9' }"></div>
                                <div style="margin-left: 20px; text-align: left;">
                                    <p style="font-size: 20px; font-weight: bold; margin: 0;">{{ t3_3_picked_color }}</p>
                                    <a-button 
                                        @click="copyColorValue(t3_3_picked_color)" 
                                        style="margin-top: 10px;"
                                    >
                                        复制颜色值
                                    </a-button>
                                </div>
                            </div>
                        </div>
                        
                        <a-alert style="margin-top: 30px; text-align: left;">
                            <template #title>
                                使用说明
                            </template>
                            点击"开始取色"按钮后，鼠标会变为滴管形状。移动鼠标到屏幕任意位置，单击即可拾取当前像素的颜色。按"Esc"键可取消取色。
                        </a-alert>
                    </a-card>
                </div>
            </div>
        </div>

        <div v-show="tooltype == 't3-4'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="颜色选择器" @back="switchToMenu"
                    subtitle="在色板中选择或自定义颜色">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <div style="padding: 20px;">
                    <a-card :bordered="false" style="display: flex; flex-direction: column; align-items: center; padding: 20px;">
                        <a-color-picker 
                            v-model="t3_4_color"
                            show-preset
                            show-history
                        />
                         <div style="margin-top: 30px; text-align: center;">
                            <p style="font-size: 16px; margin-bottom: 10px;">当前颜色值</p>
                            <a-tag size="large" style="font-size: 18px; padding: 5px 10px;">{{ t3_4_color }}</a-tag>
                            <br/>
                            <a-button 
                                @click="copyColorValue(t3_4_color)" 
                                style="margin-top: 15px;"
                            >
                                复制颜色值
                            </a-button>
                         </div>
                    </a-card>
                </div>
            </div>
        </div>

        <div v-show="tooltype == 't5-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="Windows加密" @back="switchToMenu"
                    subtitle="Windows自带指令">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <h1>计算文件哈希值</h1>

                        <h2>方法一：使用 PowerShell</h2>
                        <p>打开 PowerShell，并运行以下命令：</p>
                        <pre><code>Get-FileHash 文件路径 -Algorithm MD5(可以换成其他算法) | Format-List</code></pre>
                        <p>例如：</p>
                        <pre><code>Get-FileHash C:\Windows\notepad.exe -Algorithm MD5 | Format-List</code></pre>
                        <p>输出示例：</p>
                        <pre><code>Algorithm : MD5
Hash : 9E107D9D372BB6826BD81D3542A419D6
Path : C:\Windows\notepad.exe</code></pre>

                        <h2>方法二：使用 CertUtil 工具</h2>
                        <p>打开命令提示符，并运行以下命令：</p>
                        <pre><code>certutil -hashfile 文件路径 MD5</code></pre>
                        <p>例如：</p>
                        <pre><code>certutil -hashfile C:\Windows\notepad.exe MD5(可以换成其他算法)</code></pre>
                        <p>输出示例：</p>
                        <pre><code>MD5 哈希 (MD5) 的 C:\Windows\notepad.exe:
9E107D9D372BB6826BD81D3542A419D6
CertUtil: -hashfile 命令成功完成。</code></pre>

                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't5-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="MD5加密" @back="switchToMenu"
                    subtitle="字符串转MD5">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="4">
                        <p class="t1-1-title">输入字符串：</p>
                    </a-col>
                    <a-col :span="16">
                        <a-input v-model="t5_2_in" placeholder="请输入字符串" class="t1-1-inputer"></a-input>
                    </a-col>
                    <a-col :span="4">
                        <a-button @click="process_t5_2" class="t1-1-button">生成MD5</a-button><br />
                    </a-col>
                </a-row>
                <a-row v-show="t5_2_out_small != '' && t5_2_out_big != ''">
                    <a-col :span="24">
                        <a-row style="margin-top: 10px;">
                            <p style="text-align: center;width: 100%;margin: 0;font-size: large;">小写MD5： {{
                                t5_2_out_small }}</p>
                            <br />
                        </a-row>
                        <a-row>
                            <p style="text-align: center;width: 100%;margin: 0;margin-top: 5px;font-size: large;">大写MD5：
                                {{
                                t5_2_out_big }}</p><br />
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't5-3'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="SHA1加密" @back="switchToMenu"
                    subtitle="字符串转SHA1">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="4">
                        <p class="t1-1-title">输入字符串：</p>
                    </a-col>
                    <a-col :span="16">
                        <a-input v-model="t5_3_in" placeholder="请输入字符串" class="t1-1-inputer"></a-input>
                    </a-col>
                    <a-col :span="4">
                        <a-button @click="process_t5_3" class="t1-1-button">生成SHA1</a-button><br />
                    </a-col>
                </a-row>
                <a-row v-show="t5_3_out_small != '' && t5_3_out_big != ''">
                    <a-col :span="24">
                        <a-row style="margin-top: 10px;">
                            <p style="text-align: center;width: 100%;margin: 0;font-size: large;">小写SHA1： {{
                                t5_3_out_small }}</p>
                            <br />
                        </a-row>
                        <a-row>
                            <p style="text-align: center;width: 100%;margin: 0;margin-top: 5px;font-size: large;">
                                大写SHA1： {{
                                t5_3_out_big }}</p><br />
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't5-4'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="SHA256加密" @back="switchToMenu"
                    subtitle="字符串转SHA256">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="4">
                        <p class="t1-1-title">输入字符串：</p>
                    </a-col>
                    <a-col :span="16">
                        <a-input v-model="t5_4_in" placeholder="请输入字符串" class="t1-1-inputer"></a-input>
                    </a-col>
                    <a-col :span="4">
                        <a-button @click="process_t5_4" class="t1-1-button">生成SHA1</a-button><br />
                    </a-col>
                </a-row>
                <a-row v-show="t5_4_out_small != '' && t5_4_out_big != ''">
                    <a-col :span="24">
                        <a-row style="margin-top: 10px;">
                            <p style="text-align: center;width: 100%;margin: 0;">小写SHA256： {{ t5_4_out_small }}</p>
                            <br />
                        </a-row>
                        <a-row>
                            <p style="text-align: center;width: 100%;margin: 0;margin-top: 5px;">大写SHA256： {{
                                t5_4_out_big }}</p>
                            <br />
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't6-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="随机数字" @back="switchToMenu"
                    subtitle="生成随机数字">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="4">
                        <p class="t1-1-title">随机数长度：</p>
                    </a-col>
                    <a-col :span="16">
                        <a-input-number v-model="t6_1_in" placeholder="请输入长度" class="t1-1-inputer"></a-input-number>
                    </a-col>
                    <a-col :span="4">
                        <a-button @click="process_t6_1" class="t1-1-button">生成随机数</a-button><br />
                    </a-col>
                </a-row>
                <a-row v-show="t6_1_out != ''">
                    <a-col :span="24">
                        <a-row style="margin-top:10px;">
                            <p style="text-align: center;width: 100%;margin: 0;">随机数： {{ t6_1_out }}</p><br />
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't6-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="随机字符串" @back="switchToMenu"
                    subtitle="生成随机字符串">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"><template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="4">
                        <p class="t1-1-title">字符串长度：</p>
                    </a-col>
                    <a-col :span="16">
                        <a-input-number v-model="t6_2_in" placeholder="请输入长度" class="t1-1-inputer"></a-input-number>
                    </a-col>
                    <a-col :span="4">
                        <a-button @click="process_t6_2" class="t1-1-button">生成字符串</a-button><br />
                    </a-col>
                </a-row>
                <a-row v-show="t6_2_out != ''">
                    <a-col :span="24">
                        <a-row style="margin-top:10px;">
                            <p style="text-align: center;width: 100%;margin: 0;">随机字符串： {{ t6_2_out }}</p><br />
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't6-3'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="随机混合串" @back="switchToMenu"
                    subtitle="生成字母数字混合串">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"><template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row>
                    <a-col :span="4">
                        <p class="t1-1-title">混合串长度：</p>
                    </a-col>
                    <a-col :span="16">
                        <a-input-number v-model="t6_3_in" placeholder="请输入长度" class="t1-1-inputer"></a-input-number>
                    </a-col>
                    <a-col :span="4">
                        <a-button @click="process_t6_3" class="t1-1-button">生成混合串</a-button><br />
                    </a-col>
                </a-row>
                <a-row v-show="t6_3_out != ''">
                    <a-col :span="24">
                        <a-row style="margin-top:10px;">
                            <p style="text-align: center;width: 100%;margin: 0;">随机混合串： {{ t6_3_out }}</p><br />
                        </a-row>
                    </a-col>
                </a-row>

            </div>
        </div>

        <div v-show="tooltype == 't6-4'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="随机MAC地址" @back="switchToMenu"
                    subtitle="生成随机MAC地址">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-card :bordered="false" style="margin-bottom: 20px;">
                    <a-form :model="{}">
                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="生成数量">
                                    <a-input-number v-model="t6_4_count" :min="1" :max="100" style="width: 100%;"></a-input-number>
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="厂商">
                                    <a-select v-model="t6_4_vendor" style="width: 100%;">
                                        <a-option value="random">随机</a-option>
                                        <a-option value="cisco">Cisco</a-option>
                                        <a-option value="dell">Dell</a-option>
                                        <a-option value="apple">Apple</a-option>
                                        <a-option value="huawei">Huawei</a-option>
                                        <a-option value="samsung">Samsung</a-option>
                                        <a-option value="tp-link">TP-Link</a-option>
                                        <a-option value="xiaomi">Xiaomi</a-option>
                                    </a-select>
                                </a-form-item>
                            </a-col>
                        </a-row>
                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="格式">
                                    <a-radio-group v-model="t6_4_format">
                                        <a-radio value="colon">冒号分隔 (00:11:22)</a-radio>
                                        <a-radio value="hyphen">连字符分隔 (00-11-22)</a-radio>
                                        <a-radio value="none">无分隔 (001122)</a-radio>
                                    </a-radio-group>
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="大小写">
                                    <a-radio-group v-model="t6_4_case">
                                        <a-radio value="lower">小写 (aa:bb:cc)</a-radio>
                                        <a-radio value="upper">大写 (AA:BB:CC)</a-radio>
                                    </a-radio-group>
                                </a-form-item>
                            </a-col>
                        </a-row>
                        <a-row>
                            <a-col :span="24" style="text-align: center;">
                                <a-button type="primary" @click="generateMACAddresses" style="margin-right: 16px;">生成MAC地址</a-button>
                            </a-col>
                        </a-row>
                    </a-form>
                </a-card>
                
                <div v-show="t6_4_results.length > 0" style="width: 100%;">
                    <a-card :bordered="false" title="生成的MAC地址" style="width: 100%;">
                        <div class="custom-scrollbar" style="max-height: 300px; overflow-y: auto; width: 100%;">
                            <div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;">
                                <a-tag 
                                    v-for="(mac, index) in t6_4_results" 
                                    :key="index" 
                                    :style="{
                                        cursor: 'pointer',
                                        padding: '6px 10px',
                                        fontSize: '14px',
                                        fontFamily: 'monospace',
                                        backgroundColor: '#f0f2f5'
                                    }"
                                    @click="copyMAC(mac)"
                                >
                                    {{ mac }}
                                </a-tag>
                            </div>
                            <div style="margin-top: 16px; color: #666; font-size: 12px; text-align: center;">
                                点击地址可复制到剪贴板
                            </div>
                        </div>
                    </a-card>
                </div>
            </div>
        </div>

        <div v-show="tooltype == 't6-5'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="随机IPv4地址" @back="switchToMenu"
                    subtitle="生成随机IPv4地址">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-card :bordered="false" style="margin-bottom: 20px;">
                    <a-form :model="{}">
                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="生成数量">
                                    <a-input-number v-model="t6_5_count" :min="1" :max="100" style="width: 100%;"></a-input-number>
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="IP类别">
                                    <a-select v-model="t6_5_class" style="width: 100%;">
                                        <a-option value="any">任意类别</a-option>
                                        <a-option value="a">A类 (1-126.x.x.x)</a-option>
                                        <a-option value="b">B类 (128-191.x.x.x)</a-option>
                                        <a-option value="c">C类 (192-223.x.x.x)</a-option>
                                        <a-option value="d">D类 (224-239.x.x.x)</a-option>
                                        <a-option value="e">E类 (240-255.x.x.x)</a-option>
                                    </a-select>
                                </a-form-item>
                            </a-col>
                        </a-row>
                        <a-row>
                            <a-col :span="24">
                                <a-form-item>
                                    <a-checkbox v-model="t6_5_private">仅生成私有IP地址 (10.x.x.x, 172.16-31.x.x, 192.168.x.x)</a-checkbox>
                                </a-form-item>
                            </a-col>
                        </a-row>
                        <a-row>
                            <a-col :span="24" style="text-align: center;">
                                <a-button type="primary" @click="generateIPv4Addresses" style="margin-right: 16px;">生成IPv4地址</a-button>
                            </a-col>
                        </a-row>
                    </a-form>
                </a-card>
                
                <div v-show="t6_5_results.length > 0" style="width: 100%;">
                    <a-card :bordered="false" title="生成的IPv4地址" style="width: 100%;">
                        <div class="custom-scrollbar" style="max-height: 300px; overflow-y: auto; width: 100%;">
                            <div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;">
                                <a-tag 
                                    v-for="(ip, index) in t6_5_results" 
                                    :key="index" 
                                    :style="{
                                        cursor: 'pointer',
                                        padding: '6px 10px',
                                        fontSize: '14px',
                                        fontFamily: 'monospace',
                                        backgroundColor: '#f0f2f5'
                                    }"
                                    @click="copyIPv4(ip)"
                                >
                                    {{ ip }}
                                </a-tag>
                            </div>
                            <div style="margin-top: 16px; color: #666; font-size: 12px; text-align: center;">
                                点击地址可复制到剪贴板
                            </div>
                        </div>
                    </a-card>
                </div>
            </div>
        </div>

        <div v-show="tooltype == 't6-6'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="随机IPv6地址" @back="switchToMenu"
                    subtitle="生成随机IPv6地址">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-card :bordered="false" style="margin-bottom: 20px;">
                    <a-form :model="{}">
                        <a-row :gutter="16">
                            <a-col :span="12">
                                <a-form-item label="生成数量">
                                    <a-input-number v-model="t6_6_count" :min="1" :max="100" style="width: 100%;"></a-input-number>
                                </a-form-item>
                            </a-col>
                            <a-col :span="12">
                                <a-form-item label="格式">
                                    <a-radio-group v-model="t6_6_format">
                                        <a-radio value="full">完整格式 (xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx)</a-radio>
                                        <a-radio value="compressed">压缩格式 (省略连续的0)</a-radio>
                                    </a-radio-group>
                                </a-form-item>
                            </a-col>
                        </a-row>
                        <a-row>
                            <a-col :span="24" style="text-align: center;">
                                <a-button type="primary" @click="generateIPv6Addresses" style="margin-right: 16px;">生成IPv6地址</a-button>
                            </a-col>
                        </a-row>
                    </a-form>
                </a-card>
                
                <div v-show="t6_6_results.length > 0" style="width: 100%;">
                    <a-card :bordered="false" title="生成的IPv6地址" style="width: 100%;">
                        <div class="custom-scrollbar" style="max-height: 300px; overflow-y: auto; width: 100%;">
                            <div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;">
                                <a-tag 
                                    v-for="(ip, index) in t6_6_results" 
                                    :key="index" 
                                    :style="{
                                        cursor: 'pointer',
                                        padding: '6px 10px',
                                        fontSize: '14px',
                                        fontFamily: 'monospace',
                                        backgroundColor: '#f0f2f5'
                                    }"
                                    @click="copyIPv6(ip)"
                                >
                                    {{ ip }}
                                </a-tag>
                            </div>
                            <div style="margin-top: 16px; color: #666; font-size: 12px; text-align: center;">
                                点击地址可复制到剪贴板
                            </div>
                        </div>
                    </a-card>
                </div>
            </div>
        </div>

        <div v-show="tooltype == 't2-6'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="ASCII码表" @back="switchToMenu"
                    subtitle="ASCII 十进制 / 十六进制 对照">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"><template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <table style="width: 100%; text-align: center; border-collapse: collapse;">
                            <thead>
                                <tr>
                                    <th style="border:1px solid #ddd;padding:4px;">Dec</th>
                                    <th style="border:1px solid #ddd;padding:4px;">Hex</th>
                                    <th style="border:1px solid #ddd;padding:4px;">Char</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="row in asciiData" :key="row.dec">
                                    <td style="border:1px solid #ddd;padding:4px;">{{ row.dec }}</td>
                                    <td style="border:1px solid #ddd;padding:4px;">{{ row.hex }}</td>
                                    <td style="border:1px solid #ddd;padding:4px;">{{ row.char === '' ? 'Ctrl' : row.char }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't2-7'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="字数统计" @back="switchToMenu"
                    subtitle="文本字符统计分析">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"><template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 文本输入区 -->
                        <a-textarea 
                            placeholder="请输入或粘贴需要统计的文本..." 
                            v-model="t2_7_in" 
                            :auto-size="{ minRows: 10, maxRows: 10 }"
                            style="margin-bottom: 20px;"
                        />

                        <!-- 统计结果展示区 -->
                        <a-card title="统计结果">
                            <a-row :gutter="[16, 16]">
                                <a-col :span="8">
                                    <a-statistic title="总字符数" :value="t2_7_stats.chars" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="不含空格字符" :value="t2_7_stats.charsNoSpace" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="行数" :value="t2_7_stats.lines" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="单词数" :value="t2_7_stats.words" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="中文字符" :value="t2_7_stats.chinese" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="数字" :value="t2_7_stats.numbers" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="空格" :value="t2_7_stats.spaces" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="Tab符" :value="t2_7_stats.tabs" />
                                </a-col>
                                <a-col :span="8">
                                    <a-statistic title="标点符号" :value="t2_7_stats.punctuation" />
                                </a-col>
                            </a-row>
                            <a-divider />
                            <a-button type="primary" @click="clear_t2_7" style="margin-right: 10px;">清空文本</a-button>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't2-8'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="文本对比工具" @back="switchToMenu"
                    subtitle="比较两段文本的差异">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"><template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 输入区 -->
                        <div style="display: flex; margin-bottom: 10px;">
                            <div style="flex: 1; margin-right: 5px;">
                                <div class="diff-header">原文本</div>
                                <a-textarea 
                                    v-model="t2_8_left" 
                                    placeholder="请输入或粘贴原文本" 
                                    :auto-size="{ minRows: 10, maxRows: 10 }"
                                    style="width: 100%;"
                                />
                            </div>
                            <div style="flex: 1; margin-left: 5px;">
                                <div class="diff-header">对比文本</div>
                                <a-textarea 
                                    v-model="t2_8_right" 
                                    placeholder="请输入或粘贴对比文本" 
                                    :auto-size="{ minRows: 10, maxRows: 10 }"
                                    style="width: 100%;"
                                />
                            </div>
                        </div>
                        
                        <!-- 按钮区 -->
                        <div style="text-align: center; margin-bottom: 15px;">
                            <a-button type="primary" @click="processDiff" style="margin-right: 10px;">比较差异</a-button>
                            <a-button @click="clear_t2_8">清空</a-button>
                        </div>
                        
                        <!-- 对比结果区 -->
                        <div v-if="t2_8_diff && t2_8_diff.length > 0">
                            <div class="diff-header" style="margin-bottom: 10px;">
                                差异结果 (不同行: {{ t2_8_diff.filter((item: DiffItem) => item.different).length }}/{{ t2_8_diff.length }})
                            </div>
                            <div style="display: flex; border: 1px solid #ddd; border-radius: 4px;">
                                <div style="flex: 1; border-right: 1px solid #ddd; padding: 0 5px;">
                                    <div v-for="(item, index) in t2_8_diff" :key="'left-'+index" 
                                        :style="{ backgroundColor: item.different ? '#ffeeee' : 'transparent', padding: '2px 5px' }">
                                        <span class="line-number">{{ item.lineNum }}:</span>
                                        <span v-if="!item.different">{{ item.left }}</span>
                                        <span v-else>
                                            <template v-for="(char, i) in item.left" :key="'char-'+i">
                                                <span :style="{ backgroundColor: item.leftHighlight && item.leftHighlight.includes(i) ? '#ff8080' : 'transparent' }">
                                                    {{ char }}
                                                </span>
                                            </template>
                                        </span>
                                    </div>
                                </div>
                                <div style="flex: 1; padding: 0 5px;">
                                    <div v-for="(item, index) in t2_8_diff" :key="'right-'+index" 
                                        :style="{ backgroundColor: item.different ? '#eeeeff' : 'transparent', padding: '2px 5px' }">
                                        <span class="line-number">{{ item.lineNum }}:</span>
                                        <span v-if="!item.different">{{ item.right }}</span>
                                        <span v-else>
                                            <template v-for="(char, i) in item.right" :key="'char-'+i">
                                                <span :style="{ backgroundColor: item.rightHighlight && item.rightHighlight.includes(i) ? '#8080ff' : 'transparent' }">
                                                    {{ char }}
                                                </span>
                                            </template>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't7-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="WebSocket测试" @back="switchToMenu"
                    subtitle="WebSocket连接测试工具">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"><template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 连接设置区 -->
                        <a-card title="连接设置" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center;">
                                <span style="width: 80px;">服务器URL：</span>
                                <a-input v-model="ws_url" :disabled="ws_connected" placeholder="WebSocket服务器地址" 
                                         style="flex: 1; margin-right: 15px;" />
                                <a-button type="primary" :disabled="ws_connected" @click="connectWebSocket"
                                          style="margin-right: 10px;">连接</a-button>
                                <a-button :disabled="!ws_connected" @click="disconnectWebSocket">断开</a-button>
                            </div>
                            <div style="margin-top: 10px;">
                                <a-alert v-if="ws_connected" type="success">WebSocket已连接</a-alert>
                                <a-alert v-else type="info">WebSocket未连接</a-alert>
                            </div>
                        </a-card>

                        <!-- 消息发送区 -->
                        <a-card title="发送消息" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center;">
                                <a-textarea v-model="ws_message" placeholder="输入要发送的消息内容" :auto-size="{ minRows: 2, maxRows: 2 }"
                                           style="flex: 1; margin-right: 15px;" />
                                <a-button type="primary" :disabled="!ws_connected" @click="sendMessage">发送</a-button>
                            </div>
                        </a-card>

                        <!-- 日志区域 -->
                        <a-card title="通信日志">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                                <div>
                                    <a-checkbox v-model="ws_auto_scroll">自动滚动</a-checkbox>
                                </div>
                                <div>
                                    <a-button size="small" @click="clearLogs">清空日志</a-button>
                                </div>
                            </div>

                            <div class="ws-log-container custom-scrollbar" style="height: 250px; overflow-y: auto; border: 1px solid #eee; padding: 10px; border-radius: 4px;width: 96%;margin: 0 auto;">
                                <div v-for="log in ws_logs" :key="log.id" class="ws-log-item" :class="`ws-log-${log.type}`">
                                    <span class="ws-log-time">[{{ log.timestamp }}]</span>
                                    <span class="ws-log-type">
                                        <a-tag v-if="log.type === 'success'" color="green">成功</a-tag>
                                        <a-tag v-else-if="log.type === 'error'" color="red">错误</a-tag>
                                        <a-tag v-else-if="log.type === 'sent'" color="blue">发送</a-tag>
                                        <a-tag v-else-if="log.type === 'received'" color="purple">接收</a-tag>
                                        <a-tag v-else-if="log.type === 'warning'" color="orange">警告</a-tag>
                                        <a-tag v-else color="gray">信息</a-tag>
                                    </span>
                                    <span class="ws-log-message">{{ log.message }}</span>
                                </div>
                                <div v-if="ws_logs.length === 0" class="ws-log-empty">
                                    暂无日志记录
                                </div>
                            </div>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't7-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="RESTful API测试" @back="switchToMenu"
                    subtitle="RESTful API测试工具">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 请求设置区 -->
                        <a-card title="请求设置" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center;">
                                <span style="width: 80px;">URL：</span>
                                <a-input v-model="rest_url" placeholder="请输入API地址" style="flex: 1; margin-right: 15px;" />
                                <a-button @click="sendRequest" :disabled="rest_loading" style="margin-right: 10px;">发送请求</a-button>
                                <a-button @click="clearRestInputs" style="margin-right: 10px;">清空输入</a-button>
                                <a-button @click="prettifyJson" style="margin-right: 10px;">美化JSON</a-button>
                            </div>
                            <div style="margin-top: 10px;">
                                <a-alert v-if="rest_loading" type="info">正在发送请求...</a-alert>
                                <a-alert v-else-if="rest_error" type="error">{{ rest_error }}</a-alert>
                                <a-alert v-else-if="rest_status" type="success">{{ rest_status }}</a-alert>
                                <a-alert v-else-if="rest_response" type="info">{{ rest_response }}</a-alert>
                                <a-alert v-else-if="rest_response_time" type="info">响应时间：{{ rest_response_time }}ms</a-alert>
                                <a-alert v-else-if="rest_response_size" type="info">响应大小：{{ rest_response_size }}字节</a-alert>
                            </div>
                        </a-card>

                        <!-- 请求方法选择 -->
                        <a-card title="请求方法" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center;">
                                <span style="width: 80px;">方法：</span>
                                <a-select v-model="rest_method" style="flex: 1; margin-right: 15px;" placeholder="请选择请求方法">
                                    <a-option value="GET">GET</a-option>
                                    <a-option value="POST">POST</a-option>
                                    <a-option value="PUT">PUT</a-option>
                                    <a-option value="DELETE">DELETE</a-option>
                                    <a-option value="PATCH">PATCH</a-option>
                                 </a-select>
                            </div>
                        </a-card>

                        <!-- 请求头设置 -->
                        <a-card title="请求头" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center;">
                                <span style="width: 80px;">头信息：</span>
                                <a-textarea v-model="rest_headers" placeholder="请输入请求头，格式为JSON" :auto-size="{ minRows: 4, maxRows: 4 }"
                                            style="flex: 1; margin-right: 15px;" />
                            </div>
                        </a-card>

                        <!-- 请求体设置 -->
                        <a-card title="请求体" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center;">
                                <span style="width: 80px;">数据类型：</span>
                                <a-select v-model="rest_content_type" style="flex: 1; margin-right: 15px;">
                                    <a-option value="json">JSON</a-option>
                                    <a-option value="form">表单数据</a-option>
                                    <a-option value="raw">原始字符串</a-option>
                                </a-select>
                                <a-textarea v-model="rest_body" placeholder="请输入请求体" :auto-size="{ minRows: 4, maxRows: 4 }"
                                            style="flex: 1; margin-right: 15px;" />
                            </div>
                        </a-card>

                        <!-- 响应区域 -->
                        <a-card title="响应" style="margin-bottom: 15px;">
                            <div style="margin-bottom: 10px;">
                                <span>状态码：</span>
                                <span style="font-weight: bold;">{{ rest_status }}</span>
                                <span style="margin-left: 20px;">响应时间：</span>
                                <span style="font-weight: bold;">{{ rest_response_time }}ms</span>
                                <span style="margin-left: 20px;">大小：</span>
                                <span style="font-weight: bold;">{{ rest_response_size }} 字节</span>
                             </div>
                            <a-textarea 
                                v-model="rest_response" 
                                placeholder="响应内容将在这里显示" 
                                :auto-size="{ minRows: 10, maxRows: 10 }"
                                style="width: 100%; font-family: 'Courier New', monospace;" 
                                readonly
                            />
                        </a-card>

                        <!-- 历史记录 -->
                        <a-card title="历史记录" style="margin-bottom: 15px;">
                            <div v-if="rest_history.length > 0">
                                <div class="rest-history-table">
                                    <div class="rest-history-header">
                                        <span class="rest-history-time">时间</span>
                                        <span class="rest-history-method">方法</span>
                                        <span class="rest-history-url">URL</span>
                                        <span class="rest-history-status">状态</span>
                                        <span class="rest-history-action">操作</span>
                                    </div>
                                    <div v-for="item in rest_history" :key="item.id" class="rest-history-row">
                                        <span class="rest-history-time">{{ item.time }}</span>
                                        <span class="rest-history-method">{{ item.method }}</span>
                                        <span class="rest-history-url">{{ item.url }}</span>
                                        <span class="rest-history-status" :class="item.status >= 400 ? 'error-status' : 'success-status'">
                                            {{ item.status }}
                                        </span>
                                        <span class="rest-history-action">
                                            <a-button size="small" @click="loadHistory(item)">加载</a-button>
                                        </span>
                                    </div>
                                </div>
                            </div>
                            <div v-else style="text-align: center; padding: 10px; color: #888;">
                                暂无历史记录
                             </div>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't1-3'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="时间戳转换" @back="switchToMenu"
                    subtitle="时间戳与日期互转">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <!-- 当前时间信息 -->
                <a-row>
                    <a-col :span="24">
                        <a-card title="当前时间" :bordered="false">
                            <a-row>
                                <a-col :span="12">
                                    <p>当前时间戳：{{ t1_3_current_timestamp }}</p>
                                </a-col>
                                <a-col :span="12">
                                    <p>当前日期时间：{{ t1_3_current_datetime }}</p>
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="24">
                                    <a-button type="primary" @click="useCurrentTime">使用当前时间</a-button>
                                </a-col>
                            </a-row>
                        </a-card>
                    </a-col>
                </a-row>

                <!-- 时间戳转日期时间 -->
                <a-row style="margin-top: 20px;">
                    <a-col :span="24">
                        <a-card title="时间戳转日期时间" :bordered="false">
                            <a-row>
                                <a-col :span="18">
                                    <a-input v-model="t1_3_timestamp" placeholder="请输入时间戳（秒/毫秒）" />
                                </a-col>
                                <a-col :span="6">
                                    <a-button type="primary" @click="timestampToDatetime" style="margin-left: 10px;">转换</a-button>
                                </a-col>
                            </a-row>
                            <a-row style="margin-top: 10px;">
                                <a-col :span="24">
                                    <a-input v-model="t1_3_datetime" placeholder="转换后的日期时间" readonly />
                                </a-col>
                            </a-row>
                        </a-card>
                    </a-col>
                </a-row>

                <!-- 日期时间转时间戳 -->
                <a-row style="margin-top: 20px;">
                    <a-col :span="24">
                        <a-card title="日期时间转时间戳" :bordered="false">
                            <a-row>
                                <a-col :span="18">
                                    <a-input v-model="t1_3_datetime" placeholder="请输入日期时间（如：2023-06-15 14:30:00）" />
                                </a-col>
                                <a-col :span="6">
                                    <a-button type="primary" @click="datetimeToTimestamp" style="margin-left: 10px;">转换</a-button>
                                </a-col>
                            </a-row>
                            <a-row style="margin-top: 10px;">
                                <a-col :span="24">
                                    <a-input v-model="t1_3_timestamp" placeholder="转换后的时间戳（秒）" readonly />
                                </a-col>
                            </a-row>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't2-10'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="大小写转换" @back="switchToMenu"
                    subtitle="文本大小写转换">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 转换模式选择 -->
                        <div style="margin-bottom: 20px;">
                            <h3 style="margin-bottom: 10px;">转换模式</h3>
                            <a-radio-group v-model="t2_10_mode" type="button" @change="convertCase" style="display: flex; flex-wrap: wrap; gap: 10px;">
                                <a-radio value="upper">全部大写</a-radio>
                                <a-radio value="lower">全部小写</a-radio>
                                <a-radio value="capitalize">首字母大写</a-radio>
                                <a-radio value="title">单词首字母大写</a-radio>
                                <a-radio value="toggle">大小写互换</a-radio>
                            </a-radio-group>
                        </div>

                        <!-- 输入文本区域 -->
                        <div style="margin-bottom: 20px;">
                            <h3 style="margin-bottom: 10px;">输入文本</h3>
                            <a-textarea 
                                v-model="t2_10_input" 
                                placeholder="请输入需要转换的文本" 
                                :auto-size="{ minRows: 5, maxRows: 8 }" 
                                style="font-size: 15px; border-radius: 4px;"
                                @input="convertCase"
                            />
                        </div>

                        <!-- 转换按钮 -->
                        <div style="display: flex; justify-content: center; width: 100%; margin: 20px 0;">
                            <a-button 
                                type="primary" 
                                @click="convertCase" 
                                size="large"
                                :style="{ 
                                    fontSize: '16px', 
                                    height: '40px', 
                                    padding: '0 30px',
                                    boxShadow: '0 2px 6px rgba(22, 93, 255, 0.2)'
                                }"
                            >
                                转换文本
                            </a-button>
                        </div>

                        <!-- 结果输出区域 -->
                        <div style="margin-bottom: 20px;">
                            <h3 style="margin-bottom: 10px;">转换结果</h3>
                            <a-textarea 
                                v-model="t2_10_output" 
                                placeholder="转换结果将显示在这里" 
                                :auto-size="{ minRows: 5, maxRows: 8 }" 
                                style="font-size: 15px; border-radius: 4px; background-color: #f8faff;"
                                readonly
                            />
                        </div>

                        <!-- 复制按钮 -->
                        <div style="display: flex; justify-content: center; width: 100%; margin: 10px 0 30px 0;">
                            <a-button 
                                @click="copyColorValue(t2_10_output)" 
                                :disabled="!t2_10_output"
                                size="large"
                                :style="{ 
                                    fontSize: '15px', 
                                    height: '36px', 
                                    padding: '0 20px'
                                }"
                            >
                                复制结果
                            </a-button>
                        </div>

                        <!-- 说明信息 -->
                        <h2>转换模式说明</h2>
                        <div style="margin-top: 15px; margin-bottom: 30px;">
                            <h3>全部大写</h3>
                            <p>将所有字母转换为大写形式</p>
                            <p>例如：hello world → HELLO WORLD</p>
                            
                            <h3>全部小写</h3>
                            <p>将所有字母转换为小写形式</p>
                            <p>例如：HELLO WORLD → hello world</p>
                            
                            <h3>首字母大写</h3>
                            <p>将文本的第一个字母转换为大写</p>
                            <p>例如：hello world → Hello world</p>
                            
                            <h3>单词首字母大写</h3>
                            <p>将每个单词的首字母转换为大写</p>
                            <p>例如：hello world → Hello World</p>
                            
                            <h3>大小写互换</h3>
                            <p>将大写字母转换为小写，小写字母转换为大写</p>
                            <p>例如：Hello World → hELLO wORLD</p>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't2-9'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="正则测试" @back="switchToMenu"
                    subtitle="测试正则表达式">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <div style="padding: 20px;">
                    <a-card :bordered="false">
                        <!-- 正则表达式输入区域 -->
                        <a-form-item label="正则表达式">
                            <div style="display: flex; align-items: center;">
                                <span style="margin-right: 8px; font-size: 16px; color: #165dff;">/</span>
                                <a-input 
                                    v-model="t2_9_regex" 
                                    placeholder="输入正则表达式，不需要包含斜杠" 
                                    style="flex: 1; min-width: 300px;" 
                                    :style="{ fontSize: '15px' }"
                                />
                                <span style="margin: 0 8px; font-size: 16px; color: #165dff;">/</span>
                                <a-space size="large">
                                    <a-tooltip content="全局匹配">
                                        <a-checkbox v-model="t2_9_flags.global">
                                            <span style="font-size: 15px; font-weight: 500;">g</span>
                                        </a-checkbox>
                                    </a-tooltip>
                                    <a-tooltip content="忽略大小写">
                                        <a-checkbox v-model="t2_9_flags.ignoreCase">
                                            <span style="font-size: 15px; font-weight: 500;">i</span>
                                        </a-checkbox>
                                    </a-tooltip>
                                    <a-tooltip content="多行模式">
                                        <a-checkbox v-model="t2_9_flags.multiline">
                                            <span style="font-size: 15px; font-weight: 500;">m</span>
                                        </a-checkbox>
                                    </a-tooltip>
                                </a-space>
                            </div>
                        </a-form-item>

                        <!-- 测试文本输入区域 -->
                        <a-form-item label="测试文本">
                            <a-textarea 
                                v-model="t2_9_text" 
                                placeholder="输入需要测试的文本内容" 
                                :auto-size="{ minRows: 5, maxRows: 8 }" 
                                style="font-size: 15px; border-radius: 4px;"
                            />
                        </a-form-item>

                        <!-- 测试按钮 -->
                        <div style="display: flex; justify-content: center; width: 100%; margin: 20px 0;">
                            <a-button 
                                type="primary" 
                                @click="testRegex" 
                                size="large"
                                :style="{ 
                                    fontSize: '16px', 
                                    height: '40px', 
                                    padding: '0 30px',
                                    boxShadow: '0 2px 6px rgba(22, 93, 255, 0.2)'
                                }"
                            >
                                测试正则表达式
                            </a-button>
                        </div>

                        <!-- 错误信息 -->
                        <a-alert v-if="t2_9_error" type="error" style="margin-bottom: 16px;">
                            {{ t2_9_error }}
                        </a-alert>

                        <!-- 匹配结果 -->
                        <div v-if="t2_9_matches.length > 0">
                            <a-divider style="margin: 24px 0; font-weight: 500; font-size: 16px;">匹配结果</a-divider>
                            
                            <a-card 
                                v-for="(match, index) in t2_9_matches" 
                                :key="index"
                                :bordered="false" 
                                style="margin-bottom: 20px; background-color: #f8faff; border-radius: 6px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);"
                            >
                                <template #title>
                                    <div style="font-size: 16px; color: #1d2129; display: flex; align-items: center;">
                                        <a-badge status="processing" />
                                        <span style="margin-left: 8px;">匹配项 #{{ index + 1 }}</span>
                                        <a-tag size="small" style="margin-left: 10px;">位置: {{ match.index }}</a-tag>
                                    </div>
                                </template>
                                
                                <a-descriptions :column="1" size="medium" bordered style="margin-top: 8px;">
                                    <a-descriptions-item label="完整匹配">
                                        <a-tag color="blue" style="font-size: 14px; padding: 4px 8px;">{{ match.fullMatch }}</a-tag>
                                    </a-descriptions-item>
                                    
                                    <a-descriptions-item v-if="match.groups && match.groups.length > 0" label="捕获组">
                                        <div v-for="(group, groupIndex) in match.groups" :key="groupIndex" style="margin-bottom: 6px;">
                                            <a-tag color="green" style="font-size: 14px; padding: 4px 8px;">
                                                <span style="font-weight: 500;">组 {{ groupIndex + 1 }}:</span> {{ group }}
                                            </a-tag>
                                        </div>
                                    </a-descriptions-item>
                                </a-descriptions>
                            </a-card>
                            
                            <a-result 
                                status="success" 
                                :subtitle="`共找到 ${t2_9_matches.length} 个匹配项`"
                                style="padding: 24px 0;"
                            >
                                <template #icon>
                                    <a-statistic 
                                        :value="t2_9_matches.length"
                                        style="text-align: center;"
                                        :value-style="{ color: '#165dff', fontSize: '32px', fontWeight: 'bold' }"
                                    />
                                </template>
                            </a-result>
                        </div>

                        <!-- 帮助信息 -->
                        <a-collapse style="margin-top: 30px; border-radius: 6px; overflow: hidden;">
                            <a-collapse-item header="正则表达式常用语法参考" key="1">
                                <a-card :bordered="false" style="background-color: #f8faff;">
                                    <a-tabs default-active-key="1">
                                        <a-tab-pane key="1" title="字符匹配">
                                            <a-table :columns="[
                                                { title: '语法', dataIndex: 'syntax', width: 80 },
                                                { title: '说明', dataIndex: 'description' }
                                            ]" :data="[
                                                { syntax: '.', description: '匹配任意单个字符（除了换行符）' },
                                                { syntax: '\\d', description: '匹配任意数字，等同于 [0-9]' },
                                                { syntax: '\\D', description: '匹配任意非数字字符' },
                                                { syntax: '\\w', description: '匹配任意字母、数字或下划线，等同于 [A-Za-z0-9_]' },
                                                { syntax: '\\W', description: '匹配任意非字母、数字或下划线的字符' },
                                                { syntax: '\\s', description: '匹配任意空白字符（空格、制表符、换行符等）' },
                                                { syntax: '\\S', description: '匹配任意非空白字符' }
                                            ]" :pagination="false" :bordered="false" />
                                        </a-tab-pane>
                                        
                                        <a-tab-pane key="2" title="数量限定符">
                                            <a-table :columns="[
                                                { title: '语法', dataIndex: 'syntax', width: 80 },
                                                { title: '说明', dataIndex: 'description' }
                                            ]" :data="[
                                                { syntax: '*', description: '匹配前面的表达式 0 次或多次' },
                                                { syntax: '+', description: '匹配前面的表达式 1 次或多次' },
                                                { syntax: '?', description: '匹配前面的表达式 0 次或 1 次' },
                                                { syntax: '{n}', description: '精确匹配前面的表达式 n 次' },
                                                { syntax: '{n,}', description: '匹配前面的表达式至少 n 次' },
                                                { syntax: '{n,m}', description: '匹配前面的表达式 n 到 m 次' }
                                            ]" :pagination="false" :bordered="false" />
                                        </a-tab-pane>
                                        
                                        <a-tab-pane key="3" title="位置匹配">
                                            <a-table :columns="[
                                                { title: '语法', dataIndex: 'syntax', width: 80 },
                                                { title: '说明', dataIndex: 'description' }
                                            ]" :data="[
                                                { syntax: '^', description: '匹配字符串开头' },
                                                { syntax: '$', description: '匹配字符串结尾' },
                                                { syntax: '\\b', description: '匹配单词边界' },
                                                { syntax: '\\B', description: '匹配非单词边界' }
                                            ]" :pagination="false" :bordered="false" />
                                        </a-tab-pane>
                                        
                                        <a-tab-pane key="4" title="特殊字符">
                                            <a-table :columns="[
                                                { title: '语法', dataIndex: 'syntax', width: 80 },
                                                { title: '说明', dataIndex: 'description' }
                                            ]" :data="[
                                                { syntax: '\\', description: '转义字符，用于匹配特殊字符本身，如 \\. 匹配点号' },
                                                { syntax: '|', description: '或操作符，如 a|b 匹配 a 或 b' },
                                                { syntax: '[]', description: '字符类，匹配方括号内的任意一个字符，如 [abc] 匹配 a、b 或 c' },
                                                { syntax: '[^]', description: '否定字符类，匹配不在方括号内的任意字符' },
                                                { syntax: '()', description: '分组，将多个字符作为一个单元处理，并创建捕获组' }
                                            ]" :pagination="false" :bordered="false" />
                                        </a-tab-pane>
                                        
                                        <a-tab-pane key="5" title="常用示例">
                                            <a-table :columns="[
                                                { title: '示例', dataIndex: 'example', width: 150 },
                                                { title: '说明', dataIndex: 'description' }
                                            ]" :data="[
                                                { example: '/^\\d{4}-\\d{2}-\\d{2}$/', description: '匹配日期格式 YYYY-MM-DD' },
                                                { example: '/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$/', description: '匹配电子邮件地址' },
                                                { example: '/^1[3-9]\\d{9}$/', description: '匹配中国大陆手机号码' },
                                                { example: '/(https?:\\/\\/[^\\s]+)/', description: '匹配网址链接' }
                                            ]" :pagination="false" :bordered="false" />
                                        </a-tab-pane>
                                    </a-tabs>
                                </a-card>
                            </a-collapse-item>
                        </a-collapse>
                    </a-card>
                </div>
            </div>
        </div>
        
        <div v-show="tooltype == 't1-4'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="颜色值转换" @back="switchToMenu"
                    subtitle="颜色编码转换">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 颜色预览区域 -->
                        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; margin-bottom: 20px;">
                            <div :style="t1_4_preview_style" style="width: 120px; height: 120px; border-radius: 8px; border: 1px solid #ddd; margin-bottom: 15px;"></div>
                            <a-button type="primary" @click="generateRandomColor">生成随机颜色</a-button>
                        </div>

                        <!-- HEX颜色值 -->
                        <a-card title="HEX 颜色值" :bordered="false" style="margin-bottom: 15px;">
                            <a-row style="margin-bottom: 10px;">
                                <a-col :span="24" style="display: flex; align-items: center;">
                                    <span style="margin-right: 10px; width: 40px; text-align: right;">HEX:</span>
                                    <a-input v-model="t1_4_hex" placeholder="如：#FF0000" style="flex: 1;" />
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="24" style="display: flex; justify-content: center;">
                                    <a-space>
                                        <a-button type="primary" @click="updateFromHex">转换</a-button>
                                        <a-button @click="copyColorValue(t1_4_hex)">复制</a-button>
                                    </a-space>
                                </a-col>
                            </a-row>
                        </a-card>

                        <!-- RGB颜色值 -->
                        <a-card title="RGB 颜色值" :bordered="false" style="margin-bottom: 15px;">
                            <a-row style="margin-bottom: 10px;">
                                <a-col :span="8" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">R:</span>
                                    <a-input-number v-model="t1_4_rgb.r" :min="0" :max="255" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="8" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">G:</span>
                                    <a-input-number v-model="t1_4_rgb.g" :min="0" :max="255" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="8" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">B:</span>
                                    <a-input-number v-model="t1_4_rgb.b" :min="0" :max="255" style="width: calc(100% - 30px);" />
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="24" style="display: flex; justify-content: center; margin-top: 10px;">
                                    <a-space>
                                        <a-button type="primary" @click="updateFromRgb">转换</a-button>
                                        <a-button @click="copyColorValue(`rgb(${t1_4_rgb.r}, ${t1_4_rgb.g}, ${t1_4_rgb.b})`)">复制</a-button>
                                    </a-space>
                                </a-col>
                            </a-row>
                        </a-card>

                        <!-- HSL颜色值 -->
                        <a-card title="HSL 颜色值" :bordered="false" style="margin-bottom: 15px;">
                            <a-row style="margin-bottom: 10px;">
                                <a-col :span="8" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">H:</span>
                                    <a-input-number v-model="t1_4_hsl.h" :min="0" :max="360" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="8" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">S:</span>
                                    <a-input-number v-model="t1_4_hsl.s" :min="0" :max="100" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="8" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">L:</span>
                                    <a-input-number v-model="t1_4_hsl.l" :min="0" :max="100" style="width: calc(100% - 30px);" />
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="24" style="display: flex; justify-content: center; margin-top: 10px;">
                                    <a-space>
                                        <a-button type="primary" @click="updateFromHsl">转换</a-button>
                                        <a-button @click="copyColorValue(`hsl(${t1_4_hsl.h}, ${t1_4_hsl.s}%, ${t1_4_hsl.l}%)`)">复制</a-button>
                                    </a-space>
                                </a-col>
                            </a-row>
                        </a-card>

                        <!-- CMYK颜色值 -->
                        <a-card title="CMYK 颜色值" :bordered="false">
                            <a-row style="margin-bottom: 10px;">
                                <a-col :span="6" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">C:</span>
                                    <a-input-number v-model="t1_4_cmyk.c" :min="0" :max="100" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="6" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">M:</span>
                                    <a-input-number v-model="t1_4_cmyk.m" :min="0" :max="100" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="6" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">Y:</span>
                                    <a-input-number v-model="t1_4_cmyk.y" :min="0" :max="100" style="width: calc(100% - 30px);" />
                                </a-col>
                                <a-col :span="6" style="display: flex; align-items: center;">
                                    <span style="margin-right: 5px; width: 25px; text-align: right;">K:</span>
                                    <a-input-number v-model="t1_4_cmyk.k" :min="0" :max="100" style="width: calc(100% - 30px);" />
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="24" style="display: flex; justify-content: center; margin-top: 10px;">
                                    <a-space>
                                        <a-button type="primary" @click="updateFromCmyk">转换</a-button>
                                        <a-button @click="copyColorValue(`cmyk(${t1_4_cmyk.c}%, ${t1_4_cmyk.m}%, ${t1_4_cmyk.y}%, ${t1_4_cmyk.k}%)`)">复制</a-button>
                                    </a-space>
                                </a-col>
                            </a-row>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

                 <div v-show="tooltype == 't5-6'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="生成UUID" @back="switchToMenu"
                    subtitle="生成唯一标识符">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden;">
                    <a-col :span="24">
                        <!-- 左右两栏布局 -->
                        <div style="display: flex; flex-direction: column; max-width: 900px; margin: 0 auto; padding: 0 16px;">
                            <!-- 上部分：配置和生成区域 -->
                            <div style="display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 20px;">
                                <!-- 左侧：配置选项 -->
                                <div style="flex: 1; min-width: 300px; background: #f8faff; border-radius: 10px; padding: 16px; border: 1px solid #e5e6eb; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                    <h3 style="margin-bottom: 16px; color: #1d2129; font-size: 18px; text-align: center; border-bottom: 1px solid #e5e6eb; padding-bottom: 10px;">配置选项</h3>
                                    
                                <!-- UUID版本选择 -->
                                    <div style="margin-bottom: 18px;">
                                    <div style="margin-bottom: 8px; font-weight: 500; color: #1d2129;">UUID版本</div>
                                        <a-radio-group v-model="t5_6_version" type="button" style="display: flex; flex-wrap: wrap; gap: 8px;">
                                        <a-radio value="v4">版本4 (随机)</a-radio>
                                        <a-radio value="v1">版本1 (时间)</a-radio>
                                    </a-radio-group>
                                </div>
                                
                                <!-- 生成数量 -->
                                    <div style="margin-bottom: 18px;">
                                    <div style="margin-bottom: 8px; font-weight: 500; color: #1d2129;">生成数量</div>
                                    <a-input-number 
                                        v-model="t5_6_count" 
                                        :min="1" 
                                        :max="100" 
                                        style="width: 120px;"
                                    />
                                </div>
                                
                                <!-- 格式选项 -->
                                <div>
                                    <div style="margin-bottom: 8px; font-weight: 500; color: #1d2129;">格式选项</div>
                                    <div style="display: flex; flex-wrap: wrap; gap: 16px;">
                                        <a-checkbox v-model="t5_6_uppercase">大写字母</a-checkbox>
                                        <a-checkbox v-model="t5_6_hyphens">包含连字符</a-checkbox>
                            </div>
                        </div>
                        
                        <!-- 生成按钮 -->
                                    <div style="display: flex; justify-content: center; margin-top: 20px;">
                            <a-button 
                                type="primary" 
                                @click="generateUUID" 
                                size="large"
                                            style="font-size: 16px; height: 40px; padding: 0 30px;"
                            >
                                生成UUID
                            </a-button>
                                    </div>
                        </div>
                        
                                <!-- 右侧：当前UUID显示区域 -->
                                <div v-if="t5_6_uuid" style="flex: 1; min-width: 300px; background: #f8faff; border-radius: 10px; padding: 16px; border: 1px solid #e5e6eb; box-shadow: 0 2px 8px rgba(0,0,0,0.05); display: flex; flex-direction: column;">
                                    <h3 style="margin-bottom: 16px; color: #1d2129; font-size: 18px; text-align: center; border-bottom: 1px solid #e5e6eb; padding-bottom: 10px;">当前UUID</h3>
                                    
                                    <div style="flex-grow: 1; display: flex; flex-direction: column; justify-content: center; align-items: center;">
                                        <p style="font-family: monospace; font-size: 16px; word-break: break-all; margin-bottom: 20px; overflow-wrap: break-word; max-width: 100%; text-align: center; background: white; padding: 12px; border-radius: 6px; border: 1px dashed #e5e6eb;">
                                    {{ t5_6_uuid }}
                                </p>
                                        
                                        <a-button @click="copyColorValue(t5_6_uuid)" size="medium" type="primary">
                                    复制UUID
                                </a-button>
                                    </div>
                            </div>
                        </div>
                        
                            <!-- 中间部分：生成的UUID列表 -->
                            <div v-if="t5_6_generatedUUIDs.length > 1" style="margin-bottom: 24px; background: #f8faff; border-radius: 10px; padding: 16px; border: 1px solid #e5e6eb; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <h3 style="margin-bottom: 16px; color: #1d2129; font-size: 18px; text-align: center; border-bottom: 1px solid #e5e6eb; padding-bottom: 10px;">生成的UUID列表</h3>
                                
                                <div style="max-height: 300px; overflow-y: auto; padding-right: 4px;">
                                <div 
                                    v-for="(uuid, index) in t5_6_generatedUUIDs" 
                                    :key="index"
                                    v-show="index > 0"
                                        style="padding: 10px; border-bottom: 1px solid #e5e6eb; background-color: white; margin-bottom: 8px; border-radius: 6px;"
                                >
                                        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                                            <span style="font-family: monospace; word-break: break-all; overflow-wrap: break-word; flex: 1; padding-right: 10px; font-size: 14px;">{{ uuid }}</span>
                                        <a-button 
                                            @click="copyColorValue(uuid)" 
                                            size="small" 
                                            type="text"
                                        >
                                            复制
                                        </a-button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 全部复制按钮 -->
                                <div style="display: flex; justify-content: center; margin-top: 16px;">
                            <a-button 
                                @click="copyColorValue(t5_6_generatedUUIDs.join('\n'))" 
                                        type="primary"
                                        ghost
                            >
                                复制全部UUID
                            </a-button>
                                </div>
                        </div>
                        
                            <!-- 下部分：UUID说明 -->
                            <div style="margin-bottom: 24px; background: #f8faff; border-radius: 10px; padding: 16px; border: 1px solid #e5e6eb; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <h3 style="margin-bottom: 16px; color: #1d2129; font-size: 18px; text-align: center; border-bottom: 1px solid #e5e6eb; padding-bottom: 10px;">关于UUID</h3>
                            
                                <!-- UUID简介 -->
                                <div style="background-color: white; border-radius: 8px; padding: 12px; margin-bottom: 16px; border: 1px solid #e5e6eb;">
                                    <p style="line-height: 1.6; font-size: 14px; color: #333; margin: 0;">
                                        UUID是一种128位标识符，用于在计算机系统中唯一标识信息。无需中央注册即可生成，特别适用于分布式系统。每个UUID由32个十六进制数字组成，格式：8-4-4-4-12（如：550e8400-e29b-41d4-a716-446655440000）
                                </p>
                            </div>
                            
                                <!-- 版本和用途信息 -->
                                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 16px;">
                                    <!-- UUID版本说明 -->
                                    <div style="background: white; border-radius: 8px; padding: 16px; border: 1px solid #e5e6eb;">
                                        <h4 style="margin: 0 0 12px 0; color: #165dff; font-size: 16px;">UUID版本说明</h4>
                                        
                                        <div style="margin-bottom: 10px; padding: 10px; background-color: #f8faff; border-radius: 6px; border-left: 3px solid #165dff;">
                                            <div style="font-weight: 500; margin-bottom: 4px; color: #1d2129; font-size: 14px;">版本1 (基于时间)</div>
                                            <div style="color: #4e5969; line-height: 1.5; font-size: 13px;">
                                                基于时间戳和MAC地址生成，适用于顺序场景
                                            </div>
                                        </div>
                                        
                                        <div style="padding: 10px; background-color: #f8faff; border-radius: 6px; border-left: 3px solid #165dff;">
                                            <div style="font-weight: 500; margin-bottom: 4px; color: #1d2129; font-size: 14px;">版本4 (随机)</div>
                                            <div style="color: #4e5969; line-height: 1.5; font-size: 13px;">
                                                基于随机数生成，常用于大多数场景
                                        </div>
                                    </div>
                                </div>
                                
                                    <!-- 常见用途 -->
                                    <div style="background: white; border-radius: 8px; padding: 16px; border: 1px solid #e5e6eb;">
                                        <h4 style="margin: 0 0 12px 0; color: #165dff; font-size: 16px;">常见用途</h4>
                                        
                                        <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px;">
                                            <div style="padding: 10px; background-color: #f8faff; border-radius: 6px; text-align: center; color: #165dff; font-weight: 500; font-size: 13px;">
                                                数据库主键
                                            </div>
                                            <div style="padding: 10px; background-color: #f8faff; border-radius: 6px; text-align: center; color: #165dff; font-weight: 500; font-size: 13px;">
                                                分布式标识
                                            </div>
                                            <div style="padding: 10px; background-color: #f8faff; border-radius: 6px; text-align: center; color: #165dff; font-weight: 500; font-size: 13px;">
                                                会话ID
                                            </div>
                                            <div style="padding: 10px; background-color: #f8faff; border-radius: 6px; text-align: center; color: #165dff; font-weight: 500; font-size: 13px;">
                                                文件名
                                            </div>
                                            <div style="padding: 10px; background-color: #f8faff; border-radius: 6px; text-align: center; color: #165dff; font-weight: 500; font-size: 13px; grid-column: span 2;">
                                                API标识符
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't5-5'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="密码强度分析" @back="switchToMenu"
                    subtitle="分析密码安全强度">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 密码输入区域 -->
                        <a-card :bordered="false" style="margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.09);">
                            <template #title>
                                <div style="font-size: 16px; font-weight: 500;">
                                    <i class="icon-lock" style="margin-right: 8px;"></i>输入密码进行安全评估
                                </div>
                            </template>
                            <div style="display: flex; align-items: center;">
                                <a-input 
                                    v-model="t5_5_password" 
                                    placeholder="请输入需要分析的密码" 
                                    :style="{flex: 1, marginRight: '10px'}" 
                                    size="large"
                                    allow-clear
                                />
                                <a-button type="primary" @click="analyzePassword" size="large">
                                    分析密码
                                </a-button>
                            </div>
                        </a-card>

                        <!-- 密码强度展示区域 -->
                        <div v-show="t5_5_score > 0">
                            <a-card :bordered="false" style="margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.09);">
                                <template #title>
                                    <div style="font-size: 16px; font-weight: 500;">密码强度评估</div>
                                </template>
                                
                                <div style="text-align: center; margin-bottom: 20px;">
                                    <a-tag :color="t5_5_strength_color" style="font-size: 18px; padding: 5px 15px;">
                                        {{ t5_5_feedback }}级强度
                                    </a-tag>
                                </div>
                                
                                <a-progress 
                                    :percent="t5_5_score/100" 
                                    :stroke-color="t5_5_strength_color" 
                                    :stroke-width="12"
                                    style="margin-bottom: 15px;"
                                />
                                
                                <div style="text-align: center; font-size: 15px; color: #666;">
                                    <span style="font-weight: 500;">总评分: </span>
                                    <span style="font-size: 18px; color: #333; font-weight: bold;">{{ t5_5_score }}</span>
                                    <span> / 100</span>
                                </div>
                            </a-card>
                        </div>

                        <!-- 评估标准列表 -->
                        <div v-show="t5_5_score > 0">
                            <a-card 
                                :bordered="false" 
                                style="margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.09);"
                            >
                                <template #title>
                                    <div style="font-size: 16px; font-weight: 500;">评估标准</div>
                                </template>
                                
                                <div class="password-criteria-list">
                                    <div 
                                        v-for="item in t5_5_criteria" 
                                        :key="item.id" 
                                        class="criteria-item"
                                        :style="{
                                            padding: '12px 16px',
                                            borderRadius: '6px',
                                            backgroundColor: item.met ? 'rgba(82, 196, 26, 0.1)' : 'rgba(245, 34, 45, 0.05)',
                                            marginBottom: '10px',
                                            border: `1px solid ${item.met ? 'rgba(82, 196, 26, 0.3)' : 'rgba(245, 34, 45, 0.2)'}`
                                        }"
                                    >
                                        <div style="display: flex; align-items: center; justify-content: space-between;">
                                            <div style="display: flex; align-items: center;">
                                                <a-tag 
                                                    :color="item.met ? '#52c41a' : '#f5222d'" 
                                                    style="margin-right: 10px; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; padding: 0;"
                                                >
                                                    <span style="font-size: 14px;">{{ item.met ? '✓' : '✗' }}</span>
                                                </a-tag>
                                                <span style="font-weight: 500; font-size: 15px;">{{ item.name }}</span>
                                            </div>
                                            <a-tag :color="item.met ? '#52c41a' : '#d9d9d9'">
                                                {{ item.met ? '+' + item.score : 0 }}分
                                            </a-tag>
                                        </div>
                                        <div style="margin-left: 34px; color: #666; font-size: 13px; margin-top: 4px;">
                                            {{ item.description }}
                                        </div>
                                    </div>
                                </div>
                            </a-card>
                        </div>

                        <!-- 密码安全提示 -->
                        <div v-show="t5_5_score > 0">
                            <a-card 
                                :bordered="false" 
                                style="margin-bottom: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.09);"
                            >
                                <template #title>
                                    <div style="font-size: 16px; font-weight: 500;">
                                        <i class="icon-info-circle" style="margin-right: 8px;"></i>密码安全提示
                                    </div>
                                </template>
                                
                                <div style="background-color: #f9f9f9; padding: 15px; border-radius: 6px;">
                                    <div style="font-weight: 500; margin-bottom: 10px; color: #333;">一个强密码应该：</div>
                                    <ul style="padding-left: 20px; margin: 0;">
                                        <li style="margin-bottom: 8px; color: #555;">长度至少8个字符，更长更好</li>
                                        <li style="margin-bottom: 8px; color: #555;">同时包含大小写字母、数字和特殊字符</li>
                                        <li style="margin-bottom: 8px; color: #555;">避免使用常见单词、名字或生日</li>
                                        <li style="margin-bottom: 8px; color: #555;">不要在多个网站使用相同的密码</li>
                                        <li style="color: #555;">定期更换密码</li>
                                    </ul>
                                </div>
                            </a-card>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-5'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="常用HTML颜色" @back="switchToMenu"
                    subtitle="网页常用色系与色块">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden; margin: 0 auto; max-width: 100%;">
                    <a-col :span="24">
                        <div v-for="category in htmlColorCategories" :key="category.name" style="margin-bottom: 20px; padding: 0 5px;">
                            <h3 style="margin-bottom: 10px; padding-left: 10px; border-left: 4px solid #165dff;">{{ category.name }}</h3>
                            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 10px;">
                                <div 
                                    v-for="color in category.colors" 
                                    :key="color.hex" 
                                    style="display: flex; flex-direction: column; align-items: center; cursor: pointer;"
                                    @click="copyHTMLColorValue(color.hex)"
                                >
                                    <div 
                                        :style="{
                                            backgroundColor: color.hex,
                                            width: '100%',
                                            height: '40px',
                                            borderRadius: '4px',
                                            marginBottom: '5px',
                                            border: '1px solid #ddd'
                                        }"
                                    ></div>
                                    <div style="font-size: 12px; text-align: center; width: 100%; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{{ color.name }}</div>
                                    <div style="font-size: 12px; color: #666;">{{ color.hex }}</div>
                                </div>
                            </div>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-6'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="回车转br标签" @back="switchToMenu"
                    subtitle="将回车转换为&lt;br/&gt;标签">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <!-- 输入文本区域 -->
                        <a-textarea 
                            v-model="t3_6_input" 
                            placeholder="请输入需要转换的文本" 
                            :auto-size="{ minRows: 10, maxRows: 10 }"
                            style="margin-bottom: 20px;"
                        />

                        <!-- 选项设置 -->
                        <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                            <div>
                                <a-checkbox v-model="t3_6_options.preserveSpaces">保留空格</a-checkbox>
                                <a-checkbox v-model="t3_6_options.useNbsp">使用&amp;nbsp;替换空格</a-checkbox>
                                <a-checkbox v-model="t3_6_options.addParagraphs">添加&lt;p&gt;标签</a-checkbox>
                            </div>
                            <div>
                                <a-button @click="process_t3_6">转换</a-button>
                                <a-button @click="copy_t3_6_result">复制结果</a-button>
                                <a-button @click="clear_t3_6">清空</a-button>
                            </div>
                        </div>

                        <!-- 转换结果 -->
                        <div style="margin-bottom: 20px;">
                            <h3 style="margin-bottom: 10px;">转换结果</h3>
                            <div style="display: flex; flex-direction: column; gap: 10px;">
                                <div style="border: 1px solid #ddd; padding: 10px; background-color: #f9f9f9; border-radius: 4px; overflow-x: auto;">
                                    <pre style="margin: 0; white-space: pre-wrap;">{{ t3_6_output }}</pre>
                                </div>
                                <div style="border: 1px solid #ddd; padding: 10px; border-radius: 4px;">
                                    <div v-html="t3_6_output"></div>
                                </div>
                            </div>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-7'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="常用浏览器UA" @back="switchToMenu"
                    subtitle="浏览器User-Agent字符串">
                    <template #extra>
                        <div class="can_touch">
                            <a-button class="header-button no-outline-button" @click="minimizeWindow()"> <template
                                    #icon><img src="../assets/min.png" style="width: 15px;" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button" @click="closeWindow()"> <template
                                    #icon><img src="../assets/close.png" style="width: 15px;" /></template> </a-button>
                        </div>
                    </template>
                </a-page-header>
            </div>
            <div class="one-tool-content">
                <a-row class="page-content custom-scrollbar">
                    <a-col :span="24">
                        <div v-for="category in browserUAList" :key="category.category" style="margin-bottom: 20px;">
                            <h3 style="margin-bottom: 10px; padding-left: 10px; border-left: 4px solid #165dff;">{{ category.category }}</h3>
                            <a-table 
                                :columns="[
                                    { title: '浏览器', dataIndex: 'name', width: '25%' },
                                    { title: 'User-Agent字符串', dataIndex: 'value', width: '60%' },
                                    { title: '操作', dataIndex: 'operation', width: '15%' }
                                ]" 
                                :data="category.items" 
                                :pagination="false"
                                :bordered="true"
                                size="small"
                            >
                                <template #value="{ record }">
                                    <div style="word-break: break-all; font-family: monospace; font-size: 12px;">
                                        {{ record.value }}
                                    </div>
                                </template>
                                <template #operation="{ record }">
                                    <a-button size="small" type="primary" @click="copyUA(record.value)">复制</a-button>
                                </template>
                            </a-table>
                        </div>
                        
                        <div style="margin-top: 20px; background-color: #f9f9f9; padding: 15px; border-radius: 6px;">
                            <h4 style="margin-top: 0;">关于User-Agent</h4>
                            <p>User-Agent（用户代理）是HTTP请求头中的一个字段，用于标识发起请求的浏览器类型、版本、操作系统等信息。</p>
                            <p>开发者可以通过User-Agent进行：</p>
                            <ul>
                                <li>浏览器兼容性检测</li>
                                <li>网站访问统计分析</li>
                                <li>针对不同设备提供响应式内容</li>
                                <li>网络爬虫开发</li>
                            </ul>
                            <p style="margin-bottom: 0;">注意：过度依赖User-Agent进行功能判断可能导致兼容性问题，现代Web开发更推荐使用特性检测。</p>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

    </div>
</template>

<style>
/* 自定义滚动条样式 */
.custom-scrollbar {
    width: 300px;
    height: 200px;
    overflow-y: scroll;
}

/* 隐藏默认的滚动条 */
.custom-scrollbar::-webkit-scrollbar {
    width: 8px;
    /* 设置滚动条的宽度 */
}

/* 滚动条的轨道 */
.custom-scrollbar::-webkit-scrollbar-track {
    background: #f1f1f1;
    /* 滚动条轨道的背景颜色 */
}

/* 滚动条滑块 */
.custom-scrollbar::-webkit-scrollbar-thumb {
    background: #888;
    /* 滚动条滑块的背景颜色 */
    border-radius: 4px;
    /* 滚动条滑块的圆角半径 */
}

/* 滚动条滑块在悬停时的样式 */
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
    background: #555;
    /* 滚动条滑块在悬停时的背景颜色 */
}

.tool-container {
    width: 100%;
    height: 100%;
}

.one-tool {
    width: 100vw;
    height: 100vh;
}

.one-tool-head {
    -webkit-app-region: drag;
}

.arco-page-header .arco-icon-hover.arco-page-header-icon-hover::before {
    -webkit-app-region: no-drag;
}

.can_touch {
    -webkit-app-region: no-drag;
}

.header-button {
    background-color: transparent !important;
}

.header-button:hover {
    background-color: #f0f0f0 !important;
}

.no-outline-button {
    outline: none;
    /* 移除默认点击边框 */
}

.no-outline-button:focus {
    outline: none;
    /* 移除焦点时的边框 */
}

.one-tool-content {
    padding: 10px;
}

.t1-1-title {
    margin: 0;
    height: 42px;
    font-size: 20px;
    text-align: center;
    line-height: 42px;
}

.t1-1-inputer {
    width: 100%;
    height: 42px;
}

.t1-1-button {
    height: 42px !important;
}

pre {
    background-color: #f4f4f4;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
    overflow-x: auto;
}

code {
    font-family: Consolas, monospace;
    color: #c7254e;
    background-color: #f9f2f4;
    padding: 2px 4px;
    border-radius: 4px;
}

.page-content {
    height: 510px;
    width: 100%;
}

/* Differ工具样式 */
.diff-header {
    font-weight: bold;
    padding: 5px 0;
}
.line-number {
    color: #999;
    display: inline-block;
    width: 30px;
    user-select: none;
}

/* WebSocket工具样式 */
.ws-log-item {
    margin-bottom: 5px;
    padding: 5px;
    border-radius: 3px;
}
.ws-log-time {
    margin-right: 5px;
    color: #888;
    display: inline-block;
    width: 75px;
}
.ws-log-type {
    display: inline-block;
    width: 60px;
    margin-right: 5px;
    text-align: center;
}
.ws-log-message {
    word-break: break-all;
}
.ws-log-empty {
    text-align: center;
    color: #aaa;
    padding: 20px 0;
}

/* RESTful API工具样式 */
.rest-history-table {
    width: 100%;
    border-collapse: collapse;
}
.rest-history-header, .rest-history-row {
    display: flex;
    justify-content: space-between;
    padding: 5px 0;
    border-bottom: 1px solid #ddd;
}
.rest-history-header {
    font-weight: bold;
}
.rest-history-time, .rest-history-method, .rest-history-url, .rest-history-status, .rest-history-action {
    flex: 1;
    text-align: center;
}
.rest-history-status.success-status {
    color: #5cb85c;
}
.rest-history-status.error-status {
    color: #d9534f;
}
</style>