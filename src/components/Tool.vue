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

                            <div class="ws-log-container custom-scrollbar" style="height: 250px; overflow-y: auto; border: 1px solid #eee; padding: 10px; border-radius: 4px;">
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
                                    <a-select-option value="json">JSON</a-select-option>
                                    <a-select-option value="form">表单数据</a-select-option>
                                    <a-select-option value="raw">原始字符串</a-select-option>
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