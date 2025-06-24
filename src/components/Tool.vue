<script setup lang="ts">
import { IconCopy } from '@arco-design/web-vue/es/icon';
import { defineProps, defineEmits, ref, watch, onBeforeUnmount, onMounted, computed, h } from 'vue';
import JsBarcode from 'jsbarcode';
import { Message } from '@arco-design/web-vue';
import { toPng } from 'html-to-image';
import { saveAs } from 'file-saver';
import QrcodeVue from 'qrcode.vue';
import CryptoJS from 'crypto-js';
import { load as yamlLoad, dump as yamlDump } from 'js-yaml';
import axios from 'axios';
import mqtt from 'mqtt';

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

// t7-5 子网掩码计算器
const t7_5_ipAddress = ref('192.168.1.1');
const t7_5_subnetMask = ref('255.255.255.0');
const t7_5_cidrNotation = ref('24');
const t7_5_networkAddress = ref('');
const t7_5_broadcastAddress = ref('');
const t7_5_firstUsableIp = ref('');
const t7_5_lastUsableIp = ref('');
const t7_5_totalHosts = ref(0);
const t7_5_usableHosts = ref(0);

// t3-9 htaccess转nginx功能
const t3_9_input = ref('');
const t3_9_output = ref('');
const t3_9_error = ref('');

// t3-10 Android Manifest权限大全
const t3_10_search = ref('');
const t3_10_categoryFilter = ref('all');

// t3-11 HTTP状态码
const t3_11_search = ref('');
const t3_11_categoryFilter = ref('all');

// t3-12 Content-Type对照表
const t3_12_search = ref('');
const t3_12_categoryFilter = ref('all');

// t3-13 HTML特殊字符转义
const t3_13_input = ref('');
const t3_13_output = ref('');
const t3_13_direction = ref('encode'); // encode 或 decode

// htaccess转nginx的转换函数
function convertHtaccessToNginx() {
    const htaccess = t3_9_input.value.trim();
    if (!htaccess) {
        t3_9_error.value = '请输入htaccess规则';
        return;
    }

    t3_9_error.value = '';
    try {
        // 按行拆分
        const lines = htaccess.split('\n');
        let nginx = '';
        let insideLocation = false;
        let currentLocation = '';

        // 处理每一行
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            
            // 跳过空行和注释
            if (!line || line.startsWith('#')) {
                nginx += '# ' + line.replace(/^#\s*/, '') + '\n';
                continue;
            }

            // 处理重写引擎开关
            if (line.match(/^\s*RewriteEngine\s+on\s*$/i)) {
                // Nginx不需要显式开启重写引擎
                nginx += '# RewriteEngine On - Nginx默认已启用重写功能\n';
                continue;
            }

            // 处理RewriteBase
            const rewriteBaseMatch = line.match(/^\s*RewriteBase\s+(.+?)\s*$/i);
            if (rewriteBaseMatch) {
                nginx += '# RewriteBase ' + rewriteBaseMatch[1] + ' - 在Nginx中不需要\n';
                continue;
            }

            // 处理RewriteCond
            const rewriteCondMatch = line.match(/^\s*RewriteCond\s+(.+?)\s+(.+?)(?:\s+\[(.+?)\])?\s*$/i);
            if (rewriteCondMatch) {
                const variable = rewriteCondMatch[1];
                const pattern = rewriteCondMatch[2];
                const flags = rewriteCondMatch[3] || '';
                
                // 转换常见的变量
                let nginxVariable = '';
                if (variable === '%{REQUEST_FILENAME}') {
                    nginxVariable = '$request_filename';
                } else if (variable === '%{HTTP_HOST}') {
                    nginxVariable = '$host';
                } else if (variable === '%{HTTPS}') {
                    nginxVariable = '$https';
                } else if (variable.startsWith('%{HTTP:')) {
                    nginxVariable = '$http_' + variable.substring(7, variable.length - 1).toLowerCase();
                } else if (variable.startsWith('%{ENV:')) {
                    nginxVariable = '$' + variable.substring(6, variable.length - 1).toLowerCase();
                } else {
                    // 默认尝试转换为小写的Nginx变量
                    nginxVariable = '$' + variable.replace(/^%\{|\}$/g, '').toLowerCase();
                }
                
                nginx += '# 条件: if (' + nginxVariable + ' ' + (pattern.startsWith('!') ? '!= ' : '= ') + pattern.replace(/^!/, '') + ')\n';
                continue;
            }

            // 处理RewriteRule
            const rewriteRuleMatch = line.match(/^\s*RewriteRule\s+(.+?)\s+(.+?)(?:\s+\[(.+?)\])?\s*$/i);
            if (rewriteRuleMatch) {
                const pattern = rewriteRuleMatch[1];
                let substitution = rewriteRuleMatch[2];
                const flags = rewriteRuleMatch[3] || '';
                
                // 处理标志
                let nginxFlags = '';
                if (flags.includes('R=301') || flags.includes('R')) {
                    nginxFlags += ' permanent';
                } else if (flags.includes('R=302')) {
                    nginxFlags += ' redirect';
                }
                
                if (flags.includes('L')) {
                    nginxFlags += ' last';
                }
                
                // 处理代理传递
                if (substitution.startsWith('http')) {
                    nginx += 'location ~ ' + pattern + ' {\n';
                    nginx += '    proxy_pass ' + substitution + ';\n';
                    nginx += '}\n';
                } else {
                    // 处理普通重写规则
                    substitution = substitution.replace(/\$(\d)/g, '$$1'); // $1 变成 $1
                    nginx += 'rewrite ' + pattern + ' ' + substitution + nginxFlags + ';\n';
                }
                continue;
            }

            // 处理RedirectMatch
            const redirectMatch = line.match(/^\s*RedirectMatch\s+(\d+)?\s+(.+?)\s+(.+?)\s*$/i);
            if (redirectMatch) {
                const statusCode = redirectMatch[1] || '302';
                const pattern = redirectMatch[2];
                const destination = redirectMatch[3];
                
                nginx += 'location ~ ' + pattern + ' {\n';
                nginx += '    return ' + statusCode + ' ' + destination + ';\n';
                nginx += '}\n';
                continue;
            }

            // 处理Redirect
            const redirectDirectMatch = line.match(/^\s*Redirect\s+(\d+)?\s+(.+?)\s+(.+?)\s*$/i);
            if (redirectDirectMatch) {
                const statusCode = redirectDirectMatch[1] || '302';
                const path = redirectDirectMatch[2];
                const destination = redirectDirectMatch[3];
                
                nginx += 'location ' + path + ' {\n';
                nginx += '    return ' + statusCode + ' ' + destination + ';\n';
                nginx += '}\n';
                continue;
            }

            // 处理DirectoryIndex
            const directoryIndexMatch = line.match(/^\s*DirectoryIndex\s+(.+?)\s*$/i);
            if (directoryIndexMatch) {
                const indexes = directoryIndexMatch[1].split(/\s+/);
                nginx += 'index ' + indexes.join(' ') + ';\n';
                continue;
            }
            
            // 处理其他未识别的规则
            nginx += '# 未转换: ' + line + '\n';
        }

        // 设置输出结果
        t3_9_output.value = nginx;
    } catch (error: any) {
        t3_9_error.value = '转换出错: ' + error.message;
    }
}

// 清空htaccess转nginx的输入和输出
function clear_t3_9() {
    t3_9_input.value = '';
    t3_9_output.value = '';
    t3_9_error.value = '';
}

// 复制htaccess转nginx的输出结果
function copy_t3_9_result() {
    if (!t3_9_output.value) {
        Message.warning({ content: '没有可复制的内容', position: 'bottom' });
        return;
    }
    
    navigator.clipboard.writeText(t3_9_output.value).then(() => {
        Message.success({ content: '已复制到剪贴板!', position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// Android权限数据
const androidPermissions = [
    {
        name: "android.permission.INTERNET",
        description: "允许应用程序打开网络套接字",
        category: "network",
        protection: "normal",
        constant: "android.Manifest.permission.INTERNET"
    },
    {
        name: "android.permission.ACCESS_NETWORK_STATE",
        description: "允许应用程序访问有关网络的信息",
        category: "network",
        protection: "normal",
        constant: "android.Manifest.permission.ACCESS_NETWORK_STATE"
    },
    {
        name: "android.permission.ACCESS_WIFI_STATE",
        description: "允许应用程序访问有关Wi-Fi网络的信息",
        category: "network",
        protection: "normal",
        constant: "android.Manifest.permission.ACCESS_WIFI_STATE"
    },
    {
        name: "android.permission.CHANGE_WIFI_STATE",
        description: "允许应用程序更改Wi-Fi连接状态",
        category: "network",
        protection: "normal",
        constant: "android.Manifest.permission.CHANGE_WIFI_STATE"
    },
    {
        name: "android.permission.ACCESS_FINE_LOCATION",
        description: "允许应用程序访问精确位置",
        category: "location",
        protection: "dangerous",
        constant: "android.Manifest.permission.ACCESS_FINE_LOCATION"
    },
    {
        name: "android.permission.ACCESS_COARSE_LOCATION",
        description: "允许应用程序访问大致位置",
        category: "location",
        protection: "dangerous",
        constant: "android.Manifest.permission.ACCESS_COARSE_LOCATION"
    },
    {
        name: "android.permission.READ_EXTERNAL_STORAGE",
        description: "允许应用程序从外部存储读取",
        category: "storage",
        protection: "dangerous",
        constant: "android.Manifest.permission.READ_EXTERNAL_STORAGE"
    },
    {
        name: "android.permission.WRITE_EXTERNAL_STORAGE",
        description: "允许应用程序写入外部存储",
        category: "storage",
        protection: "dangerous",
        constant: "android.Manifest.permission.WRITE_EXTERNAL_STORAGE"
    },
    {
        name: "android.permission.CAMERA",
        description: "允许应用程序访问相机设备",
        category: "hardware",
        protection: "dangerous",
        constant: "android.Manifest.permission.CAMERA"
    },
    {
        name: "android.permission.RECORD_AUDIO",
        description: "允许应用程序录制音频",
        category: "hardware",
        protection: "dangerous",
        constant: "android.Manifest.permission.RECORD_AUDIO"
    },
    {
        name: "android.permission.READ_CONTACTS",
        description: "允许应用程序读取用户的联系人数据",
        category: "contacts",
        protection: "dangerous",
        constant: "android.Manifest.permission.READ_CONTACTS"
    },
    {
        name: "android.permission.WRITE_CONTACTS",
        description: "允许应用程序写入用户的联系人数据",
        category: "contacts",
        protection: "dangerous",
        constant: "android.Manifest.permission.WRITE_CONTACTS"
    },
    {
        name: "android.permission.READ_CALENDAR",
        description: "允许应用程序读取用户的日历数据",
        category: "calendar",
        protection: "dangerous",
        constant: "android.Manifest.permission.READ_CALENDAR"
    },
    {
        name: "android.permission.WRITE_CALENDAR",
        description: "允许应用程序写入用户的日历数据",
        category: "calendar",
        protection: "dangerous",
        constant: "android.Manifest.permission.WRITE_CALENDAR"
    },
    {
        name: "android.permission.READ_CALL_LOG",
        description: "允许应用程序读取用户的通话记录",
        category: "phone",
        protection: "dangerous",
        constant: "android.Manifest.permission.READ_CALL_LOG"
    },
    {
        name: "android.permission.WRITE_CALL_LOG",
        description: "允许应用程序写入用户的通话记录",
        category: "phone",
        protection: "dangerous",
        constant: "android.Manifest.permission.WRITE_CALL_LOG"
    },
    {
        name: "android.permission.CALL_PHONE",
        description: "允许应用程序拨打电话",
        category: "phone",
        protection: "dangerous",
        constant: "android.Manifest.permission.CALL_PHONE"
    },
    {
        name: "android.permission.READ_SMS",
        description: "允许应用程序读取短信",
        category: "messages",
        protection: "dangerous",
        constant: "android.Manifest.permission.READ_SMS"
    },
    {
        name: "android.permission.SEND_SMS",
        description: "允许应用程序发送短信",
        category: "messages",
        protection: "dangerous",
        constant: "android.Manifest.permission.SEND_SMS"
    },
    {
        name: "android.permission.RECEIVE_SMS",
        description: "允许应用程序接收短信",
        category: "messages",
        protection: "dangerous",
        constant: "android.Manifest.permission.RECEIVE_SMS"
    },
    {
        name: "android.permission.BLUETOOTH",
        description: "允许应用程序连接到已配对的蓝牙设备",
        category: "hardware",
        protection: "normal",
        constant: "android.Manifest.permission.BLUETOOTH"
    },
    {
        name: "android.permission.BLUETOOTH_ADMIN",
        description: "允许应用程序发现和配对蓝牙设备",
        category: "hardware",
        protection: "normal",
        constant: "android.Manifest.permission.BLUETOOTH_ADMIN"
    },
    {
        name: "android.permission.NFC",
        description: "允许应用程序通过NFC执行I/O操作",
        category: "hardware",
        protection: "normal",
        constant: "android.Manifest.permission.NFC"
    },
    {
        name: "android.permission.VIBRATE",
        description: "允许访问振动器",
        category: "hardware",
        protection: "normal",
        constant: "android.Manifest.permission.VIBRATE"
    },
    {
        name: "android.permission.WAKE_LOCK",
        description: "允许使用PowerManager WakeLocks防止处理器休眠或屏幕变暗",
        category: "system",
        protection: "normal",
        constant: "android.Manifest.permission.WAKE_LOCK"
    },
    {
        name: "android.permission.GET_ACCOUNTS",
        description: "允许访问帐户服务中的帐户列表",
        category: "accounts",
        protection: "dangerous",
        constant: "android.Manifest.permission.GET_ACCOUNTS"
    },
    {
        name: "android.permission.MANAGE_ACCOUNTS",
        description: "允许管理帐户列表",
        category: "accounts",
        protection: "dangerous",
        constant: "android.Manifest.permission.MANAGE_ACCOUNTS"
    },
    {
        name: "android.permission.FOREGROUND_SERVICE",
        description: "允许应用程序使用前台服务",
        category: "system",
        protection: "normal",
        constant: "android.Manifest.permission.FOREGROUND_SERVICE"
    },
    {
        name: "android.permission.RECEIVE_BOOT_COMPLETED",
        description: "允许应用程序接收系统启动完成的广播",
        category: "system",
        protection: "normal",
        constant: "android.Manifest.permission.RECEIVE_BOOT_COMPLETED"
    },
    {
        name: "android.permission.REQUEST_INSTALL_PACKAGES",
        description: "允许应用程序请求安装软件包",
        category: "system",
        protection: "normal",
        constant: "android.Manifest.permission.REQUEST_INSTALL_PACKAGES"
    }
];

// Android权限过滤函数
function filterAndroidPermissions() {
    if (!t3_10_search.value && t3_10_categoryFilter.value === 'all') {
        return androidPermissions;
    }
    
    return androidPermissions.filter(permission => {
        const matchesSearch = t3_10_search.value === '' || 
            permission.name.toLowerCase().includes(t3_10_search.value.toLowerCase()) ||
            permission.description.toLowerCase().includes(t3_10_search.value.toLowerCase());
            
        const matchesCategory = t3_10_categoryFilter.value === 'all' || 
            permission.category === t3_10_categoryFilter.value;
            
        return matchesSearch && matchesCategory;
    });
}

// Android权限复制函数
function copyAndroidPermission(permission: string) {
    navigator.clipboard.writeText(permission)
        .then(() => {
            Message.success({ content: '已复制权限: ' + permission, position: 'bottom' });
        })
        .catch(() => {
            Message.error({ content: '复制失败', position: 'bottom' });
        });
}

// HTTP状态码数据
const httpStatusCodes = [
    { code: "100", name: "Continue", description: "请求者应该继续提出请求。服务器返回此代码表示已收到请求的第一部分，正在等待其余部分", category: "1xx" },
    { code: "101", name: "Switching Protocols", description: "请求者已要求服务器切换协议，服务器已确认并准备切换", category: "1xx" },
    { code: "102", name: "Processing", description: "服务器已收到并正在处理该请求，但无响应可用", category: "1xx" },
    { code: "103", name: "Early Hints", description: "与Link链接头字段结合使用，允许用户代理在服务器仍在准备响应时开始预加载资源", category: "1xx" },
    
    { code: "200", name: "OK", description: "请求成功。一般用于GET与POST请求", category: "2xx" },
    { code: "201", name: "Created", description: "请求已完成，并且已创建了新资源。通常是在POST请求，或是某些PUT请求之后返回的响应", category: "2xx" },
    { code: "202", name: "Accepted", description: "服务器已接受请求，但尚未处理。最终该请求可能会也可能不会被执行，并且可能在处理发生时被禁止", category: "2xx" },
    { code: "203", name: "Non-Authoritative Information", description: "服务器是一个转换代理服务器，源站使用200响应，但回应了原始响应的修改版本", category: "2xx" },
    { code: "204", name: "No Content", description: "服务器成功处理了请求，没有返回任何内容", category: "2xx" },
    { code: "205", name: "Reset Content", description: "服务器成功处理了请求，但没有返回任何内容，与204不同，此响应要求请求者重置文档视图", category: "2xx" },
    { code: "206", name: "Partial Content", description: "服务器已经成功处理了部分GET请求。常用于断点续传或者将一个大文档分解为多个下载段同时下载", category: "2xx" },
    { code: "207", name: "Multi-Status", description: "代表之后的消息体将是一个XML消息，并且可能依照之前子请求数量的不同，包含一系列独立的响应代码", category: "2xx" },
    { code: "208", name: "Already Reported", description: "在DAV里面使用，用于避免多状态响应重复枚举多个绑定的内部成员", category: "2xx" },
    { code: "226", name: "IM Used", description: "服务器已经完成了对资源的GET请求，并且响应是对当前实例应用的一个或多个实例操作结果的表示", category: "2xx" },
    
    { code: "300", name: "Multiple Choices", description: "被请求的资源有一系列可供选择的回馈信息，每个都有自己特定的地址和浏览器驱动的商议信息", category: "3xx" },
    { code: "301", name: "Moved Permanently", description: "被请求的资源已永久移动到新位置，并且将来任何对此资源的引用都应该使用本响应返回的若干个URI之一", category: "3xx" },
    { code: "302", name: "Found", description: "请求的资源现在临时从不同的URI响应请求", category: "3xx" },
    { code: "303", name: "See Other", description: "对应当前请求的响应可以在另一个URI上被找到，而且客户端应当采用GET的方式访问那个资源", category: "3xx" },
    { code: "304", name: "Not Modified", description: "如果客户端发送了一个带条件的GET请求且该请求已被允许，而文档的内容未被修改，则服务器应当返回这个状态码", category: "3xx" },
    { code: "305", name: "Use Proxy", description: "被请求的资源必须通过指定的代理才能被访问", category: "3xx" },
    { code: "306", name: "Switch Proxy", description: "在最新版的规范中，已经不再使用这个状态码", category: "3xx" },
    { code: "307", name: "Temporary Redirect", description: "请求的资源现在临时从不同的URI响应请求，与302不同的是，客户端应保持原有的请求方法", category: "3xx" },
    { code: "308", name: "Permanent Redirect", description: "请求的资源已永久移动到新位置，与301不同的是，客户端应保持原有的请求方法", category: "3xx" },
    
    { code: "400", name: "Bad Request", description: "由于语法无效，服务器无法理解该请求", category: "4xx" },
    { code: "401", name: "Unauthorized", description: "类似于403，但特别用于需要身份验证的情况，并且服务器期望的响应是身份验证凭证", category: "4xx" },
    { code: "402", name: "Payment Required", description: "此响应码保留以便将来使用，创造此响应码的最初目的是用于数字支付系统", category: "4xx" },
    { code: "403", name: "Forbidden", description: "服务器理解请求但拒绝执行它，与401不同的是，身份验证也无济于事", category: "4xx" },
    { code: "404", name: "Not Found", description: "请求失败，请求所希望得到的资源未在服务器上发现", category: "4xx" },
    { code: "405", name: "Method Not Allowed", description: "请求行中指定的请求方法不能被用于请求相应的资源", category: "4xx" },
    { code: "406", name: "Not Acceptable", description: "请求的资源的内容特性无法满足请求头中的条件，因而无法生成响应实体", category: "4xx" },
    { code: "407", name: "Proxy Authentication Required", description: "与401响应类似，只不过客户端必须在代理服务器上进行身份验证", category: "4xx" },
    { code: "408", name: "Request Timeout", description: "请求超时。客户端没有在服务器预备等待的时间内完成一个请求的发送", category: "4xx" },
    { code: "409", name: "Conflict", description: "由于和被请求的资源的当前状态之间存在冲突，请求无法完成", category: "4xx" },
    { code: "410", name: "Gone", description: "被请求的资源在服务器上已经不再可用，而且没有任何已知的转发地址", category: "4xx" },
    { code: "411", name: "Length Required", description: "服务器拒绝在没有定义Content-Length头的情况下接受请求", category: "4xx" },
    { code: "412", name: "Precondition Failed", description: "服务器在验证在请求的头字段中给出先决条件时，没能满足其中的一个或多个", category: "4xx" },
    { code: "413", name: "Payload Too Large", description: "服务器拒绝处理当前请求，因为该请求提交的实体数据大小超过了服务器愿意或者能够处理的范围", category: "4xx" },
    { code: "414", name: "URI Too Long", description: "请求的URI长度超过了服务器能够解释的长度，因此服务器拒绝对该请求提供服务", category: "4xx" },
    { code: "415", name: "Unsupported Media Type", description: "对于当前请求的方法和所请求的资源，请求中提交的实体并不是服务器所支持的格式", category: "4xx" },
    { code: "416", name: "Range Not Satisfiable", description: "如果请求中包含了Range请求头，并且Range中指定的任何数据范围都与当前资源的可用范围不重合，服务器返回此状态码", category: "4xx" },
    { code: "417", name: "Expectation Failed", description: "此响应码表明服务器无法满足Expect请求头字段指定的期望值", category: "4xx" },
    { code: "418", name: "I'm a teapot", description: "服务器拒绝尝试用茶壶冲泡咖啡(这是一个笑话，参见1998年愚人节的玩笑)", category: "4xx" },
    { code: "421", name: "Misdirected Request", description: "请求被定向到无法生成响应的服务器(例如，由于连接重用)", category: "4xx" },
    { code: "422", name: "Unprocessable Entity", description: "请求格式正确，但由于含有语义错误，无法响应", category: "4xx" },
    { code: "423", name: "Locked", description: "当前资源被锁定", category: "4xx" },
    { code: "424", name: "Failed Dependency", description: "由于之前的某个请求发生的错误，导致当前请求失败", category: "4xx" },
    { code: "425", name: "Too Early", description: "服务器不愿意冒着风险去处理可能重播的请求", category: "4xx" },
    { code: "426", name: "Upgrade Required", description: "客户端应当切换到TLS/1.0", category: "4xx" },
    { code: "428", name: "Precondition Required", description: "原始服务器要求该请求是有条件的", category: "4xx" },
    { code: "429", name: "Too Many Requests", description: "用户在给定的时间内发送了太多的请求(限制速率)", category: "4xx" },
    { code: "431", name: "Request Header Fields Too Large", description: "服务器不愿处理请求，因为它的请求头字段太大", category: "4xx" },
    { code: "451", name: "Unavailable For Legal Reasons", description: "用户请求非法资源，例如：由于政府的要求而被拒绝访问的网页", category: "4xx" },
    
    { code: "500", name: "Internal Server Error", description: "服务器遇到了不知道如何处理的情况", category: "5xx" },
    { code: "501", name: "Not Implemented", description: "此请求方法不被服务器支持且无法被处理，只有GET和HEAD是要求服务器支持的", category: "5xx" },
    { code: "502", name: "Bad Gateway", description: "作为网关或者代理工作的服务器尝试执行请求时，从上游服务器接收到无效的响应", category: "5xx" },
    { code: "503", name: "Service Unavailable", description: "服务器没有准备好处理请求。常见原因是服务器因维护或重载而停机", category: "5xx" },
    { code: "504", name: "Gateway Timeout", description: "作为网关或者代理工作的服务器尝试执行请求时，未能及时从上游服务器收到响应", category: "5xx" },
    { code: "505", name: "HTTP Version Not Supported", description: "服务器不支持请求中所使用的HTTP协议版本", category: "5xx" },
    { code: "506", name: "Variant Also Negotiates", description: "服务器有一个内部配置错误：被请求的协商变元资源被配置为在透明内容协商中使用自己，因此在一个协商处理中不是一个合适的重点", category: "5xx" },
    { code: "507", name: "Insufficient Storage", description: "服务器无法存储完成请求所必须的内容", category: "5xx" },
    { code: "508", name: "Loop Detected", description: "服务器在处理请求时检测到无限循环", category: "5xx" },
    { code: "510", name: "Not Extended", description: "获取资源所需要的策略并没有被满足", category: "5xx" },
    { code: "511", name: "Network Authentication Required", description: "客户端需要进行身份验证才能获得网络访问权限", category: "5xx" }
];

// HTTP状态码过滤函数
function filterHttpStatusCodes() {
    if (!t3_11_search.value && t3_11_categoryFilter.value === 'all') {
        return httpStatusCodes;
    }
    
    return httpStatusCodes.filter(status => {
        const matchesSearch = t3_11_search.value === '' || 
            status.code.includes(t3_11_search.value) ||
            status.name.toLowerCase().includes(t3_11_search.value.toLowerCase()) ||
            status.description.toLowerCase().includes(t3_11_search.value.toLowerCase());
            
        const matchesCategory = t3_11_categoryFilter.value === 'all' || 
            status.category === t3_11_categoryFilter.value;
            
        return matchesSearch && matchesCategory;
    });
}

// 复制HTTP状态码
function copyHttpStatusCode(code: string) {
    navigator.clipboard.writeText(code)
        .then(() => {
            Message.success({ content: '已复制状态码: ' + code, position: 'bottom' });
        })
        .catch(() => {
            Message.error({ content: '复制失败', position: 'bottom' });
        });
}

// Content-Type数据
const contentTypes = [
    { type: "text/plain", extension: ".txt", description: "纯文本文件", category: "text" },
    { type: "text/html", extension: ".html, .htm", description: "HTML文档", category: "text" },
    { type: "text/css", extension: ".css", description: "CSS样式表", category: "text" },
    { type: "text/javascript", extension: ".js", description: "JavaScript文件", category: "text" },
    { type: "text/markdown", extension: ".md", description: "Markdown文本", category: "text" },
    { type: "text/xml", extension: ".xml", description: "XML文档", category: "text" },
    { type: "text/csv", extension: ".csv", description: "CSV表格数据", category: "text" },
    
    { type: "image/jpeg", extension: ".jpg, .jpeg", description: "JPEG图像", category: "image" },
    { type: "image/png", extension: ".png", description: "PNG图像", category: "image" },
    { type: "image/gif", extension: ".gif", description: "GIF图像", category: "image" },
    { type: "image/svg+xml", extension: ".svg", description: "SVG矢量图像", category: "image" },
    { type: "image/webp", extension: ".webp", description: "WebP图像", category: "image" },
    { type: "image/bmp", extension: ".bmp", description: "BMP图像", category: "image" },
    { type: "image/tiff", extension: ".tif, .tiff", description: "TIFF图像", category: "image" },
    { type: "image/x-icon", extension: ".ico", description: "ICO图标", category: "image" },
    
    { type: "audio/mpeg", extension: ".mp3", description: "MP3音频", category: "audio" },
    { type: "audio/wav", extension: ".wav", description: "WAV音频", category: "audio" },
    { type: "audio/ogg", extension: ".ogg", description: "OGG音频", category: "audio" },
    { type: "audio/aac", extension: ".aac", description: "AAC音频", category: "audio" },
    { type: "audio/webm", extension: ".weba", description: "WebM音频", category: "audio" },
    { type: "audio/midi", extension: ".mid, .midi", description: "MIDI音频", category: "audio" },
    
    { type: "video/mp4", extension: ".mp4", description: "MP4视频", category: "video" },
    { type: "video/mpeg", extension: ".mpeg, .mpg", description: "MPEG视频", category: "video" },
    { type: "video/webm", extension: ".webm", description: "WebM视频", category: "video" },
    { type: "video/ogg", extension: ".ogv", description: "OGG视频", category: "video" },
    { type: "video/quicktime", extension: ".mov", description: "QuickTime视频", category: "video" },
    { type: "video/x-ms-wmv", extension: ".wmv", description: "Windows Media视频", category: "video" },
    { type: "video/x-msvideo", extension: ".avi", description: "AVI视频", category: "video" },
    { type: "video/3gpp", extension: ".3gp", description: "3GPP视频", category: "video" },
    
    { type: "application/json", extension: ".json", description: "JSON数据", category: "application" },
    { type: "application/xml", extension: ".xml", description: "XML应用数据", category: "application" },
    { type: "application/pdf", extension: ".pdf", description: "PDF文档", category: "application" },
    { type: "application/zip", extension: ".zip", description: "ZIP压缩文件", category: "application" },
    { type: "application/x-rar-compressed", extension: ".rar", description: "RAR压缩文件", category: "application" },
    { type: "application/x-7z-compressed", extension: ".7z", description: "7-Zip压缩文件", category: "application" },
    { type: "application/msword", extension: ".doc", description: "MS Word文档", category: "application" },
    { type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", extension: ".docx", description: "MS Word文档(OOXML)", category: "application" },
    { type: "application/vnd.ms-excel", extension: ".xls", description: "MS Excel表格", category: "application" },
    { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", extension: ".xlsx", description: "MS Excel表格(OOXML)", category: "application" },
    { type: "application/vnd.ms-powerpoint", extension: ".ppt", description: "MS PowerPoint演示文稿", category: "application" },
    { type: "application/vnd.openxmlformats-officedocument.presentationml.presentation", extension: ".pptx", description: "MS PowerPoint演示文稿(OOXML)", category: "application" },
    { type: "application/javascript", extension: ".js", description: "JavaScript(替代方案)", category: "application" },
    { type: "application/octet-stream", extension: "任意", description: "二进制数据流", category: "application" },
    { type: "application/x-www-form-urlencoded", extension: "-", description: "HTML表单数据(URL编码)", category: "application" },
    
    { type: "multipart/form-data", extension: "-", description: "多部分表单数据(文件上传)", category: "multipart" },
    { type: "multipart/byteranges", extension: "-", description: "多部分字节范围", category: "multipart" },
    { type: "multipart/mixed", extension: "-", description: "多部分混合内容", category: "multipart" },
    
    { type: "font/ttf", extension: ".ttf", description: "TrueType字体", category: "font" },
    { type: "font/otf", extension: ".otf", description: "OpenType字体", category: "font" },
    { type: "font/woff", extension: ".woff", description: "Web开放字体格式", category: "font" },
    { type: "font/woff2", extension: ".woff2", description: "Web开放字体格式2", category: "font" }
];

// Content-Type过滤函数
function filterContentTypes() {
    if (!t3_12_search.value && t3_12_categoryFilter.value === 'all') {
        return contentTypes;
    }
    
    return contentTypes.filter(contentType => {
        const matchesSearch = t3_12_search.value === '' || 
            contentType.type.toLowerCase().includes(t3_12_search.value.toLowerCase()) ||
            contentType.extension.toLowerCase().includes(t3_12_search.value.toLowerCase()) ||
            contentType.description.toLowerCase().includes(t3_12_search.value.toLowerCase());
            
        const matchesCategory = t3_12_categoryFilter.value === 'all' || 
            contentType.category === t3_12_categoryFilter.value;
            
        return matchesSearch && matchesCategory;
    });
}

// 复制Content-Type
function copyContentType(type: string) {
    navigator.clipboard.writeText(type)
        .then(() => {
            Message.success({ content: '已复制: ' + type, position: 'bottom' });
        })
        .catch(() => {
            Message.error({ content: '复制失败', position: 'bottom' });
        });
}

// HTML特殊字符参考表
const htmlSpecialChars = [
    { char: '&', entity: '&amp;', numeric: '&#38;', description: '与号' },
    { char: '<', entity: '&lt;', numeric: '&#60;', description: '小于号' },
    { char: '>', entity: '&gt;', numeric: '&#62;', description: '大于号' },
    { char: '"', entity: '&quot;', numeric: '&#34;', description: '双引号' },
    { char: "'", entity: '&apos;', numeric: '&#39;', description: '单引号/撇号' },
    { char: ' ', entity: '&nbsp;', numeric: '&#160;', description: '不换行空格' },
    { char: '¢', entity: '&cent;', numeric: '&#162;', description: '分' },
    { char: '£', entity: '&pound;', numeric: '&#163;', description: '英镑' },
    { char: '¥', entity: '&yen;', numeric: '&#165;', description: '日元/人民币' },
    { char: '€', entity: '&euro;', numeric: '&#8364;', description: '欧元' },
    { char: '©', entity: '&copy;', numeric: '&#169;', description: '版权' },
    { char: '®', entity: '&reg;', numeric: '&#174;', description: '注册商标' },
    { char: '™', entity: '&trade;', numeric: '&#8482;', description: '商标' },
    { char: '×', entity: '&times;', numeric: '&#215;', description: '乘号' },
    { char: '÷', entity: '&divide;', numeric: '&#247;', description: '除号' },
    { char: '±', entity: '&plusmn;', numeric: '&#177;', description: '加减号' },
    { char: '°', entity: '&deg;', numeric: '&#176;', description: '度' },
    { char: '²', entity: '&sup2;', numeric: '&#178;', description: '平方（上标2）' },
    { char: '³', entity: '&sup3;', numeric: '&#179;', description: '立方（上标3）' },
    { char: '½', entity: '&frac12;', numeric: '&#189;', description: '二分之一' },
    { char: '¼', entity: '&frac14;', numeric: '&#188;', description: '四分之一' },
    { char: '¾', entity: '&frac34;', numeric: '&#190;', description: '四分之三' },
    { char: 'α', entity: '&alpha;', numeric: '&#945;', description: '希腊字母alpha' },
    { char: 'β', entity: '&beta;', numeric: '&#946;', description: '希腊字母beta' },
    { char: 'π', entity: '&pi;', numeric: '&#960;', description: '圆周率' },
    { char: '—', entity: '&mdash;', numeric: '&#8212;', description: '破折号' },
    { char: '–', entity: '&ndash;', numeric: '&#8211;', description: '连字符' },
    { char: '…', entity: '&hellip;', numeric: '&#8230;', description: '省略号' },
    { char: '•', entity: '&bull;', numeric: '&#8226;', description: '项目符号' },
    { char: '→', entity: '&rarr;', numeric: '&#8594;', description: '右箭头' },
    { char: '←', entity: '&larr;', numeric: '&#8592;', description: '左箭头' },
    { char: '↑', entity: '&uarr;', numeric: '&#8593;', description: '上箭头' },
    { char: '↓', entity: '&darr;', numeric: '&#8595;', description: '下箭头' },
    { char: '♥', entity: '&hearts;', numeric: '&#9829;', description: '心形' },
    { char: '♠', entity: '&spades;', numeric: '&#9824;', description: '黑桃' },
    { char: '♣', entity: '&clubs;', numeric: '&#9827;', description: '梅花' },
    { char: '♦', entity: '&diams;', numeric: '&#9830;', description: '方块' }
];

// HTML特殊字符转义函数
function htmlEncode(text: string): string {
    if (!text) return '';
    return text
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;');
}

// HTML特殊字符解码函数
function htmlDecode(text: string): string {
    if (!text) return '';
    const textarea = document.createElement('textarea');
    textarea.innerHTML = text;
    return textarea.value;
}

// 处理HTML特殊字符转义
function processHtmlSpecialChars() {
    if (t3_13_direction.value === 'encode') {
        t3_13_output.value = htmlEncode(t3_13_input.value);
    } else {
        t3_13_output.value = htmlDecode(t3_13_input.value);
    }
}

// 复制HTML特殊字符转义结果
function copyHtmlSpecialCharsResult() {
    if (!t3_13_output.value) {
        Message.warning({ content: '没有可复制的内容', position: 'bottom' });
        return;
    }
    
    navigator.clipboard.writeText(t3_13_output.value).then(() => {
        Message.success({ content: '已复制到剪贴板!', position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// 清空HTML特殊字符转义输入和输出
function clearHtmlSpecialChars() {
    t3_13_input.value = '';
    t3_13_output.value = '';
}

// 加载示例htaccess规则
function load_t3_9_example() {
    t3_9_input.value = `# 开启重写引擎
RewriteEngine On
RewriteBase /

# 不是文件且不是目录则重写
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php?/$1 [L]

# 强制HTTPS重定向
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}/$1 [R=301,L]

# 禁止访问隐藏文件
<FilesMatch "^\.">
    Order allow,deny
    Deny from all
</FilesMatch>

# 设置默认首页文件
DirectoryIndex index.php index.html

# 简单URL重定向
Redirect 301 /oldpage.html /newpage.html

# 设置缓存
<FilesMatch "\\.(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$">
    Header set Cache-Control "max-age=2592000, public"
</FilesMatch>`;
}

// 计算CIDR表示法（如果提供了子网掩码）
function calculateCIDR() {
  if (!t7_5_subnetMask.value) return;
  
  const octets = t7_5_subnetMask.value.split('.').map(Number);
  if (octets.length !== 4) {
    Message.error({ content: '无效的子网掩码格式', position: 'bottom' });
    return;
  }
  
  let cidr = 0;
  for (const octet of octets) {
    // 转换为二进制并计算1的数量
    const binaryOctet = octet.toString(2);
    for (let i = 0; i < binaryOctet.length; i++) {
      if (binaryOctet[i] === '1') cidr++;
    }
  }
  
  t7_5_cidrNotation.value = cidr.toString();
}

// 根据CIDR计算子网掩码
function calculateSubnetMask() {
  const cidr = parseInt(t7_5_cidrNotation.value);
  if (isNaN(cidr) || cidr < 0 || cidr > 32) {
    Message.error({ content: 'CIDR值必须在0到32之间', position: 'bottom' });
    return;
  }
  
  // 创建一个32位全为1的二进制数
  let binary = '';
  for (let i = 0; i < 32; i++) {
    binary += i < cidr ? '1' : '0';
  }
  
  // 将32位二进制数分成4个八位，并转换为十进制
  const octets = [];
  for (let i = 0; i < 4; i++) {
    const octetBinary = binary.substring(i * 8, (i + 1) * 8);
    octets.push(parseInt(octetBinary, 2));
  }
  
  t7_5_subnetMask.value = octets.join('.');
}

// 计算所有子网信息
function calculateSubnetInfo() {
  // 验证IP地址格式
  const ipOctets = t7_5_ipAddress.value.split('.').map(Number);
  if (ipOctets.length !== 4 || ipOctets.some(o => isNaN(o) || o < 0 || o > 255)) {
    Message.error({ content: '无效的IP地址格式', position: 'bottom' });
    return;
  }
  
  // 验证子网掩码格式
  const maskOctets = t7_5_subnetMask.value.split('.').map(Number);
  if (maskOctets.length !== 4 || maskOctets.some(o => isNaN(o) || o < 0 || o > 255)) {
    Message.error({ content: '无效的子网掩码格式', position: 'bottom' });
    return;
  }
  
  // 计算网络地址
  const networkOctets = [];
  for (let i = 0; i < 4; i++) {
    networkOctets.push(ipOctets[i] & maskOctets[i]);
  }
  t7_5_networkAddress.value = networkOctets.join('.');
  
  // 计算广播地址
  const broadcastOctets = [];
  for (let i = 0; i < 4; i++) {
    broadcastOctets.push((ipOctets[i] & maskOctets[i]) | (~maskOctets[i] & 255));
  }
  t7_5_broadcastAddress.value = broadcastOctets.join('.');
  
  // 计算第一个可用IP（网络地址+1）
  const firstUsableOctets = [...networkOctets];
  firstUsableOctets[3]++;
  t7_5_firstUsableIp.value = firstUsableOctets.join('.');
  
  // 计算最后一个可用IP（广播地址-1）
  const lastUsableOctets = [...broadcastOctets];
  lastUsableOctets[3]--;
  t7_5_lastUsableIp.value = lastUsableOctets.join('.');
  
  // 计算IP地址总数和可用IP地址数
  const cidr = parseInt(t7_5_cidrNotation.value);
  t7_5_totalHosts.value = Math.pow(2, 32 - cidr);
  t7_5_usableHosts.value = Math.max(0, t7_5_totalHosts.value - 2); // 减去网络地址和广播地址
}

// 监听输入变化，自动更新计算结果
watch(t7_5_subnetMask, () => {
  calculateCIDR();
  calculateSubnetInfo();
});

watch(t7_5_cidrNotation, () => {
  calculateSubnetMask();
  calculateSubnetInfo();
});

watch(t7_5_ipAddress, () => {
  calculateSubnetInfo();
});

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

// t8-1 寄存器寻址范围
interface RegisterInfo {
    width: string;
    range: string;
    maxValue: string;
    applications: string;
}

// t8-2 电阻阻值计算器
interface ColorBand {
    name: string;
    value: number | null;
    multiplier: number | null;
    tolerance: number | null;
    color: string;
    textColor: string;
}

const t8_2_colors: ColorBand[] = [
    { name: "黑色", value: 0, multiplier: 1, tolerance: null, color: "#000000", textColor: "#FFFFFF" },
    { name: "棕色", value: 1, multiplier: 10, tolerance: 1, color: "#8B4513", textColor: "#FFFFFF" },
    { name: "红色", value: 2, multiplier: 100, tolerance: 2, color: "#FF0000", textColor: "#FFFFFF" },
    { name: "橙色", value: 3, multiplier: 1000, tolerance: null, color: "#FFA500", textColor: "#000000" },
    { name: "黄色", value: 4, multiplier: 10000, tolerance: null, color: "#FFFF00", textColor: "#000000" },
    { name: "绿色", value: 5, multiplier: 100000, tolerance: 0.5, color: "#008000", textColor: "#FFFFFF" },
    { name: "蓝色", value: 6, multiplier: 1000000, tolerance: 0.25, color: "#0000FF", textColor: "#FFFFFF" },
    { name: "紫色", value: 7, multiplier: 10000000, tolerance: 0.1, color: "#800080", textColor: "#FFFFFF" },
    { name: "灰色", value: 8, multiplier: 100000000, tolerance: 0.05, color: "#808080", textColor: "#FFFFFF" },
    { name: "白色", value: 9, multiplier: 1000000000, tolerance: null, color: "#FFFFFF", textColor: "#000000" },
    { name: "金色", value: null, multiplier: 0.1, tolerance: 5, color: "#FFD700", textColor: "#000000" },
    { name: "银色", value: null, multiplier: 0.01, tolerance: 10, color: "#C0C0C0", textColor: "#000000" },
    { name: "无色", value: null, multiplier: null, tolerance: 20, color: "transparent", textColor: "#000000" }
];

const t8_2_bandCount = ref(4); // 默认4色环
const t8_2_bandIndices = ref([1, 0, 2, 10]); // 直接存储颜色索引：棕色, 黑色, 红色, 金色
const t8_2_resistanceValue = ref("1000Ω ±5%");
const t8_2_detailedCalculation = ref("计算: 1*10 + 0*1 = 10 × 100 = 1000Ω, 容差: ±5%");

// 验证颜色选择是否合适的函数
function isValidColorForBand(bandIndex: number, colorIndex: number): boolean {
    const bandCount = t8_2_bandCount.value;
    const color = t8_2_colors[colorIndex];
    
    // 对于数值环（前几环），不能是null值
    if (bandIndex < bandCount - 2 && bandCount >= 4) {
        return color.value !== null;
    }
    // 对于数值环（前两环），在3环电阻中
    if (bandIndex < 2 && bandCount === 3) {
        return color.value !== null;
    }
    // 对于倍数环
    if ((bandIndex === 2 && bandCount === 3) || 
        (bandIndex === 2 && bandCount === 4) ||
        (bandIndex === 3 && bandCount >= 5)) {
        return color.multiplier !== null;
    }
    // 对于容差环
    if ((bandIndex === 3 && bandCount === 4) ||
        (bandIndex === 4 && bandCount >= 5)) {
        return color.tolerance !== null;
    }
    
    return true;
}

function t8_2_calculateResistanceValue() {
    let value = 0;
    let multiplier = 1;
    let tolerance: number | null = null;
    let calculation = "计算: ";

    if (t8_2_bandCount.value === 3) {
        // 3色环: 第一位 + 第二位 × 乘数
        const firstDigit = t8_2_colors[t8_2_bandIndices.value[0]].value || 0;
        const secondDigit = t8_2_colors[t8_2_bandIndices.value[1]].value || 0;
        value = firstDigit * 10 + secondDigit;
        multiplier = t8_2_colors[t8_2_bandIndices.value[2]].multiplier || 1;
        tolerance = 20; // 3色环默认为±20%
        calculation += `${firstDigit}*10 + ${secondDigit}*1 = ${value}`;
    } else if (t8_2_bandCount.value === 4) {
        // 4色环: 第一位 + 第二位 × 乘数, 最后一位为容差
        const firstDigit = t8_2_colors[t8_2_bandIndices.value[0]].value || 0;
        const secondDigit = t8_2_colors[t8_2_bandIndices.value[1]].value || 0;
        value = firstDigit * 10 + secondDigit;
        multiplier = t8_2_colors[t8_2_bandIndices.value[2]].multiplier || 1;
        tolerance = t8_2_colors[t8_2_bandIndices.value[3]].tolerance;
        calculation += `${firstDigit}*10 + ${secondDigit}*1 = ${value}`;
    } else if (t8_2_bandCount.value === 5) {
        // 5色环: 第一位 + 第二位 + 第三位 × 乘数, 最后一位为容差
        const firstDigit = t8_2_colors[t8_2_bandIndices.value[0]].value || 0;
        const secondDigit = t8_2_colors[t8_2_bandIndices.value[1]].value || 0;
        const thirdDigit = t8_2_colors[t8_2_bandIndices.value[2]].value || 0;
        value = firstDigit * 100 + secondDigit * 10 + thirdDigit;
        multiplier = t8_2_colors[t8_2_bandIndices.value[3]].multiplier || 1;
        tolerance = t8_2_colors[t8_2_bandIndices.value[4]].tolerance;
        calculation += `${firstDigit}*100 + ${secondDigit}*10 + ${thirdDigit}*1 = ${value}`;
    } else if (t8_2_bandCount.value === 6) {
        // 6色环: 第一位 + 第二位 + 第三位 × 乘数, 第5位为容差, 第6位为温度系数
        const firstDigit = t8_2_colors[t8_2_bandIndices.value[0]].value || 0;
        const secondDigit = t8_2_colors[t8_2_bandIndices.value[1]].value || 0;
        const thirdDigit = t8_2_colors[t8_2_bandIndices.value[2]].value || 0;
        value = firstDigit * 100 + secondDigit * 10 + thirdDigit;
        multiplier = t8_2_colors[t8_2_bandIndices.value[3]].multiplier || 1;
        tolerance = t8_2_colors[t8_2_bandIndices.value[4]].tolerance;
        calculation += `${firstDigit}*100 + ${secondDigit}*10 + ${thirdDigit}*1 = ${value}`;
    }

    const finalValue = value * multiplier;
    let displayValue = "";

    if (finalValue >= 1000000) {
        displayValue = (finalValue / 1000000) + "MΩ";
    } else if (finalValue >= 1000) {
        displayValue = (finalValue / 1000) + "kΩ";
    } else {
        displayValue = finalValue + "Ω";
    }

    if (tolerance !== null) {
        displayValue += ` ±${tolerance}%`;
    }

    t8_2_resistanceValue.value = displayValue;
    t8_2_detailedCalculation.value = calculation + ` × ${multiplier} = ${finalValue}Ω, 容差: ±${tolerance}%`;
    
    if (t8_2_bandCount.value === 6) {
        const tempCoeff = t8_2_colors[t8_2_bandIndices.value[5]].value || 0;
        t8_2_detailedCalculation.value += `, 温度系数: ${tempCoeff}ppm/°C`;
    }
}

// 根据选择的色环数量更新示例数组
function t8_2_updateBandCount() {
    // 根据选择的色环数量调整数组
    if (t8_2_bandCount.value === 3) {
        t8_2_bandIndices.value = [1, 0, 2]; // 棕色, 黑色, 红色
    } else if (t8_2_bandCount.value === 4) {
        t8_2_bandIndices.value = [1, 0, 2, 10]; // 棕色, 黑色, 红色, 金色
    } else if (t8_2_bandCount.value === 5) {
        t8_2_bandIndices.value = [1, 0, 0, 2, 10]; // 棕色, 黑色, 黑色, 红色, 金色
    } else if (t8_2_bandCount.value === 6) {
        t8_2_bandIndices.value = [1, 0, 0, 2, 10, 1]; // 棕色, 黑色, 黑色, 红色, 金色, 棕色
    }
    
    // 重新计算电阻值
    t8_2_calculateResistanceValue();
}

// 更新电阻条颜色
function t8_2_updateBandColor(index: number, colorIndex: number) {
    t8_2_bandIndices.value[index] = colorIndex;
    t8_2_calculateResistanceValue();
}

// 初始化电阻计算器
function t8_2_initResistorCalculator() {
    t8_2_calculateResistanceValue();
}

// t8-3 RISC-V指令集速查
interface RiscVInstruction {
    name: string;
    description: string;
    type: string;
}

const t8_3_baseInstructions: RiscVInstruction[] = [
    { name: "RV32I", description: "32位整数指令集", type: "基本指令集" },
    { name: "RV32E", description: "RV32I的子集，用于小型的嵌入式场景", type: "基本指令集" },
    { name: "RV64I", description: "64位整数指令集，兼容RV32I", type: "基本指令集" },
    { name: "RV128I", description: "128位整数指令集，兼容RV64I和RV32I", type: "基本指令集" }
];

const t8_3_extensionInstructions: RiscVInstruction[] = [
    { name: "M", description: "整数乘法（Multiplication）与除法指令集", type: "扩展指令集" },
    { name: "A", description: "存储器原子（Atomic）指令集", type: "扩展指令集" },
    { name: "F", description: "单精度（32bit）浮点（Float）指令集", type: "扩展指令集" },
    { name: "D", description: "双精度（64bit）浮点（Double）指令集，兼容F", type: "扩展指令集" },
    { name: "C", description: "压缩（Compressed）指令集", type: "扩展指令集" },
    { name: "V", description: "向量（Vector）指令集", type: "扩展指令集" },
    { name: "N", description: "用户级中断（User-level Interrupts）", type: "扩展指令集" },
    { name: "S", description: "监管者模式（Supervisor Mode）", type: "扩展指令集" },
    { name: "H", description: "管理程序（Hypervisor）扩展", type: "扩展指令集" },
    { name: "G", description: "通用组合（General）= IMAFD", type: "扩展指令集" },
    { name: "Q", description: "四精度（128bit）浮点（Quad）指令集", type: "扩展指令集" },
    { name: "L", description: "十进制浮点（Decimal Floating-Point）", type: "扩展指令集" },
    { name: "B", description: "位操作（Bit Manipulation）指令集", type: "扩展指令集" },
    { name: "J", description: "动态语言（Dynamic Languages）支持", type: "扩展指令集" },
    { name: "T", description: "事务内存（Transactional Memory）", type: "扩展指令集" },
    { name: "P", description: "打包SIMD（Packed-SIMD）指令集", type: "扩展指令集" }
];

const t8_3_searchTerm = ref("");
const t8_3_selectedType = ref("all");

// 过滤指令集
const t8_3_filteredInstructions = computed(() => {
    let allInstructions = [...t8_3_baseInstructions, ...t8_3_extensionInstructions];
    
    // 按类型过滤
    if (t8_3_selectedType.value !== "all") {
        allInstructions = allInstructions.filter(inst => inst.type === t8_3_selectedType.value);
    }
    
    // 按搜索词过滤
    if (t8_3_searchTerm.value) {
        const term = t8_3_searchTerm.value.toLowerCase();
        allInstructions = allInstructions.filter(inst => 
            inst.name.toLowerCase().includes(term) || 
            inst.description.toLowerCase().includes(term)
        );
    }
    
    return allInstructions;
});

// t8-4 通用寄存器速查
interface RegisterDetail {
    name: string;
    fullName: string;
    description: string;
}

interface DetailedInfo {
    generalPurpose?: RegisterDetail[];
    indexPointer?: RegisterDetail[];
    segment?: RegisterDetail[];
    control?: RegisterDetail[];
}

interface ChipRegister {
    chipSeries: string;
    architecture: string;
    registerCount: number;
    bitWidth: number;
    registerNames: string;
    specialRegisters: string;
    applications: string;
    category: string;
    detailedInfo?: DetailedInfo;
}

const t8_4_registerData: ChipRegister[] = [
    // ARM系列
    {
        chipSeries: "ARM Cortex-M0/M0+",
        architecture: "ARMv6-M",
        registerCount: 13,
        bitWidth: 32,
        registerNames: "R0-R12, SP(R13), LR(R14), PC(R15)",
        specialRegisters: "SP(栈指针), LR(链接寄存器), PC(程序计数器)",
        applications: "超低功耗嵌入式系统, IoT设备",
        category: "ARM"
    },
    {
        chipSeries: "ARM Cortex-M3/M4",
        architecture: "ARMv7-M",
        registerCount: 13,
        bitWidth: 32,
        registerNames: "R0-R12, SP(R13), LR(R14), PC(R15)",
        specialRegisters: "SP(栈指针), LR(链接寄存器), PC(程序计数器), PSR(状态寄存器)",
        applications: "中高性能嵌入式系统, 实时控制",
        category: "ARM"
    },
    {
        chipSeries: "ARM Cortex-A系列",
        architecture: "ARMv7-A/ARMv8-A",
        registerCount: 31,
        bitWidth: 64,
        registerNames: "X0-X30(64位), W0-W30(32位), SP, PC",
        specialRegisters: "SP(栈指针), PC(程序计数器), CPSR(状态寄存器)",
        applications: "智能手机, 平板电脑, 服务器",
        category: "ARM"
    },
    
    // x86系列
    {
        chipSeries: "8086/8088 汇编",
        architecture: "x86-16",
        registerCount: 14,
        bitWidth: 16,
        registerNames: "AX, BX, CX, DX, SI, DI, BP, SP, CS, DS, ES, SS, IP, FLAGS",
        specialRegisters: "SP(栈指针), IP(指令指针), FLAGS(标志寄存器), 段寄存器(CS,DS,ES,SS)",
        applications: "16位汇编编程, 系统底层开发, 教学",
        category: "x86",
        detailedInfo: {
            generalPurpose: [
                { name: "AX", fullName: "累加器", description: "主要用于算术运算，可分为AH(高8位)和AL(低8位)" },
                { name: "BX", fullName: "基址寄存器", description: "用作基址寻址，可分为BH和BL" },
                { name: "CX", fullName: "计数寄存器", description: "用于循环计数和字符串操作，可分为CH和CL" },
                { name: "DX", fullName: "数据寄存器", description: "用于I/O操作和乘除法扩展，可分为DH和DL" }
            ],
            indexPointer: [
                { name: "SI", fullName: "源变址寄存器", description: "字符串操作的源地址指针" },
                { name: "DI", fullName: "目的变址寄存器", description: "字符串操作的目的地址指针" },
                { name: "BP", fullName: "基址指针", description: "栈帧基址指针，用于访问栈中数据" },
                { name: "SP", fullName: "栈指针", description: "指向栈顶的指针" }
            ],
            segment: [
                { name: "CS", fullName: "代码段寄存器", description: "指向当前执行的代码段" },
                { name: "DS", fullName: "数据段寄存器", description: "指向默认的数据段" },
                { name: "ES", fullName: "附加段寄存器", description: "用于字符串操作的目标段" },
                { name: "SS", fullName: "栈段寄存器", description: "指向当前栈段" }
            ],
            control: [
                { name: "IP", fullName: "指令指针", description: "指向下一条要执行的指令" },
                { name: "FLAGS", fullName: "标志寄存器", description: "包含状态标志和控制标志" }
            ]
        }
    },
    {
        chipSeries: "x86-32 (IA-32)",
        architecture: "x86-32",
        registerCount: 8,
        bitWidth: 32,
        registerNames: "EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP",
        specialRegisters: "ESP(栈指针), EBP(基址指针), EIP(指令指针)",
        applications: "传统PC, 嵌入式x86系统",
        category: "x86"
    },
    {
        chipSeries: "x86-64 (AMD64)",
        architecture: "x86-64",
        registerCount: 16,
        bitWidth: 64,
        registerNames: "RAX, RBX, RCX, RDX, RSI, RDI, RSP, RBP, R8-R15",
        specialRegisters: "RSP(栈指针), RBP(基址指针), RIP(指令指针)",
        applications: "现代PC, 服务器, 工作站",
        category: "x86"
    },
    
    // RISC-V系列
    {
        chipSeries: "RISC-V RV32I",
        architecture: "RISC-V",
        registerCount: 32,
        bitWidth: 32,
        registerNames: "x0(zero), x1(ra), x2(sp), x3(gp), x4(tp), x5-x31",
        specialRegisters: "x0(零寄存器), x1(返回地址), x2(栈指针), PC",
        applications: "嵌入式系统, IoT, 开源处理器",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV64I",
        architecture: "RISC-V",
        registerCount: 32,
        bitWidth: 64,
        registerNames: "x0(zero), x1(ra), x2(sp), x3(gp), x4(tp), x5-x31",
        specialRegisters: "x0(零寄存器), x1(返回地址), x2(栈指针), PC",
        applications: "高性能计算, 服务器, 桌面系统",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV32E",
        architecture: "RISC-V Embedded",
        registerCount: 16,
        bitWidth: 32,
        registerNames: "x0(zero), x1(ra), x2(sp), x3(gp), x4(tp), x5-x15",
        specialRegisters: "x0(零寄存器), x1(返回地址), x2(栈指针), PC",
        applications: "超低功耗嵌入式, 微控制器, IoT终端",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV64E",
        architecture: "RISC-V Embedded",
        registerCount: 16,
        bitWidth: 64,
        registerNames: "x0(zero), x1(ra), x2(sp), x3(gp), x4(tp), x5-x15",
        specialRegisters: "x0(零寄存器), x1(返回地址), x2(栈指针), PC",
        applications: "高性能嵌入式, 64位微控制器",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV32IF",
        architecture: "RISC-V + Float",
        registerCount: 64,
        bitWidth: 32,
        registerNames: "x0-x31(整数), f0-f31(单精度浮点)",
        specialRegisters: "x0(零寄存器), x1(ra), x2(sp), PC, fcsr(浮点控制状态)",
        applications: "数字信号处理, 音频处理, 科学计算",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV64IF",
        architecture: "RISC-V + Float",
        registerCount: 64,
        bitWidth: 64,
        registerNames: "x0-x31(整数), f0-f31(单精度浮点)",
        specialRegisters: "x0(零寄存器), x1(ra), x2(sp), PC, fcsr(浮点控制状态)",
        applications: "高性能DSP, 实时音频, 浮点密集计算",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV32IFD",
        architecture: "RISC-V + Double Float",
        registerCount: 64,
        bitWidth: 32,
        registerNames: "x0-x31(整数), f0-f31(双精度浮点)",
        specialRegisters: "x0(零寄存器), x1(ra), x2(sp), PC, fcsr(浮点控制状态)",
        applications: "科学计算, 工程仿真, 高精度数值计算",
        category: "RISC-V"
    },
    {
        chipSeries: "RISC-V RV64IFD",
        architecture: "RISC-V + Double Float",
        registerCount: 64,
        bitWidth: 64,
        registerNames: "x0-x31(整数), f0-f31(双精度浮点)",
        specialRegisters: "x0(零寄存器), x1(ra), x2(sp), PC, fcsr(浮点控制状态)",
        applications: "高性能计算, 科学研究, 深度学习推理",
        category: "RISC-V"
    },
    
    // MIPS系列
    {
        chipSeries: "MIPS32",
        architecture: "MIPS32",
        registerCount: 32,
        bitWidth: 32,
        registerNames: "$0(zero), $1(at), $2-$3(v0-v1), $4-$7(a0-a3), $8-$15(t0-t7), $16-$23(s0-s7), $24-$25(t8-t9), $26-$27(k0-k1), $28(gp), $29(sp), $30(fp), $31(ra)",
        specialRegisters: "$0(零寄存器), $29(栈指针), $31(返回地址), PC, HI, LO",
        applications: "路由器, 嵌入式系统, 学术教学",
        category: "MIPS"
    },
    {
        chipSeries: "MIPS64",
        architecture: "MIPS64",
        registerCount: 32,
        bitWidth: 64,
        registerNames: "$0(zero), $1(at), $2-$3(v0-v1), $4-$7(a0-a3), $8-$15(t0-t7), $16-$23(s0-s7), $24-$25(t8-t9), $26-$27(k0-k1), $28(gp), $29(sp), $30(fp), $31(ra)",
        specialRegisters: "$0(零寄存器), $29(栈指针), $31(返回地址), PC, HI, LO",
        applications: "高性能嵌入式, 网络设备",
        category: "MIPS"
    },
    
    // AVR系列
    {
        chipSeries: "AVR (Arduino)",
        architecture: "AVR",
        registerCount: 32,
        bitWidth: 8,
        registerNames: "R0-R31",
        specialRegisters: "R26:R27(X), R28:R29(Y), R30:R31(Z), SP, PC",
        applications: "Arduino, 8位嵌入式系统",
        category: "8-bit"
    },
    
    // 8051系列
    {
        chipSeries: "8051/8052",
        architecture: "MCS-51",
        registerCount: 4,
        bitWidth: 8,
        registerNames: "A(累加器), B, R0-R7(寄存器组), DPTR",
        specialRegisters: "A(累加器), B(乘除寄存器), SP(栈指针), PC, PSW",
        applications: "传统8位嵌入式, 单片机教学",
        category: "8-bit"
    },
    
    // PIC系列
    {
        chipSeries: "PIC16系列",
        architecture: "PIC",
        registerCount: 1,
        bitWidth: 8,
        registerNames: "W(工作寄存器)",
        specialRegisters: "W(工作寄存器), PC, STATUS, FSR",
        applications: "简单嵌入式控制, 传感器节点",
        category: "8-bit"
    },
    {
        chipSeries: "PIC32系列",
        architecture: "PIC32",
        registerCount: 32,
        bitWidth: 32,
        registerNames: "$0(zero), $1(at), $2-$31",
        specialRegisters: "基于MIPS架构的寄存器组织",
        applications: "32位嵌入式应用, 图形处理",
        category: "PIC"
    },
    
    // PowerPC系列
    {
        chipSeries: "PowerPC",
        architecture: "PowerPC",
        registerCount: 32,
        bitWidth: 32,
        registerNames: "GPR0-GPR31",
        specialRegisters: "LR(链接寄存器), CTR(计数寄存器), CR(条件寄存器)",
        applications: "嵌入式, 汽车电子, 工业控制",
        category: "PowerPC"
    },
    
    // DSP系列
    {
        chipSeries: "TI C6000 DSP",
        architecture: "C6000",
        registerCount: 32,
        bitWidth: 32,
        registerNames: "A0-A15, B0-B15",
        specialRegisters: "A端寄存器(A0-A15), B端寄存器(B0-B15)",
        applications: "数字信号处理, 音频视频处理",
        category: "DSP"
    }
];

const t8_4_searchTerm = ref("");
const t8_4_categoryFilter = ref("all");
const t8_4_selectedChip = ref<ChipRegister | null>(null);

// 过滤寄存器数据
const t8_4_filteredRegisters = computed(() => {
    let filtered = t8_4_registerData;
    
    // 按分类过滤
    if (t8_4_categoryFilter.value !== "all") {
        filtered = filtered.filter(chip => chip.category === t8_4_categoryFilter.value);
    }
    
    // 按搜索词过滤
    if (t8_4_searchTerm.value) {
        const term = t8_4_searchTerm.value.toLowerCase();
        filtered = filtered.filter(chip => 
            chip.chipSeries.toLowerCase().includes(term) ||
            chip.architecture.toLowerCase().includes(term) ||
            chip.applications.toLowerCase().includes(term)
        );
    }
    
    return filtered;
});

// 监听工具类型变化，如果切换到电阻计算器就初始化
watch(() => props.tooltype, (newType) => {
    if (newType === 't8-2') {
        t8_2_initResistorCalculator();
    }
});

const t8_1_registerData: RegisterInfo[] = [
    {
        width: "8 位",
        range: "2^8 = 256",
        maxValue: "0xFF (255)",
        applications: "早期的单片机 8051"
    },
    {
        width: "16 位",
        range: "2^16 = 65536",
        maxValue: "0xFFFF (65535)",
        applications: "X86系列的算组 8086、MSP430系列单片机"
    },
    {
        width: "32 位",
        range: "2^32 = 4294967296",
        maxValue: "0xFFFFFFFF (4294967295)",
        applications: "早期的终端、个人计算机和服务器"
    },
    {
        width: "64 位",
        range: "2^64 = 18446744073709551616",
        maxValue: "0xFFFFFFFFFFFFFFFF",
        applications: "目前主流的移动智能终端、个人计算机和服务器"
    }
];

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

// t1-5 进制转换
const t1_5_input = ref('')
const t1_5_fromBase = ref(10)
const t1_5_toBase = ref(16)
const t1_5_result = ref('')

// 进制转换函数
function convertBase() {
    const input = t1_5_input.value.trim();
    if (!input) {
        Message.warning({ content: '请输入要转换的数字', position: 'bottom' });
        return;
    }

    try {
        // 验证输入是否为有效的源进制数字
        const decimal = parseInt(input, t1_5_fromBase.value);
        if (isNaN(decimal)) {
            Message.error({ content: `输入的数字不是有效的${t1_5_fromBase.value}进制数`, position: 'bottom' });
            return;
        }

        // 转换为目标进制
        const result = decimal.toString(t1_5_toBase.value).toUpperCase();
        t1_5_result.value = result;
        
        Message.success({ content: '转换成功!', position: 'bottom' });
    } catch (error) {
        Message.error({ content: '转换失败，请检查输入', position: 'bottom' });
    }
}

// 交换进制
function swapBase() {
    const temp = t1_5_fromBase.value;
    t1_5_fromBase.value = t1_5_toBase.value;
    t1_5_toBase.value = temp;
    
    // 如果有输入值，重新转换
    if (t1_5_input.value.trim()) {
        convertBase();
    }
}

// 清空进制转换
function clear_t1_5() {
    t1_5_input.value = '';
    t1_5_result.value = '';
}

// 复制进制转换结果
function copy_t1_5_result() {
    if (!t1_5_result.value) {
        Message.warning({ content: '没有可复制的结果', position: 'bottom' });
        return;
    }
    
    navigator.clipboard.writeText(t1_5_result.value).then(() => {
        Message.success({ content: '已复制到剪贴板', position: 'bottom' });
    }).catch(() => {
        Message.error({ content: '复制失败', position: 'bottom' });
    });
}

// t1-6 补码转换
const t1_6_input = ref('')
const t1_6_bitWidth = ref(8)
const t1_6_results = ref({
    decimal: 0,
    original: '',
    inverse: '',
    complement: '',
    binary: ''
})

// 补码转换函数
function convertComplement() {
    const input = t1_6_input.value.trim();
    if (!input) {
        Message.warning({ content: '请输入要转换的数字', position: 'bottom' });
        return;
    }

    try {
        let decimal: number;
        
        // 判断输入类型
        if (input.startsWith('0b') || input.match(/^[01]+$/)) {
            // 二进制输入
            const binaryStr = input.startsWith('0b') ? input.slice(2) : input;
            if (binaryStr.length > t1_6_bitWidth.value) {
                Message.error({ content: `二进制位数超过设定的${t1_6_bitWidth.value}位`, position: 'bottom' });
                return;
            }
            decimal = parseInt(binaryStr, 2);
            
            // 如果是补码形式的负数
            if (binaryStr.length === t1_6_bitWidth.value && binaryStr[0] === '1') {
                decimal = decimal - Math.pow(2, t1_6_bitWidth.value);
            }
        } else {
            // 十进制输入
            decimal = parseInt(input, 10);
            if (isNaN(decimal)) {
                Message.error({ content: '输入的数字格式不正确', position: 'bottom' });
                return;
            }
        }

        // 检查数字范围
        const maxValue = Math.pow(2, t1_6_bitWidth.value - 1) - 1;
        const minValue = -Math.pow(2, t1_6_bitWidth.value - 1);
        
        if (decimal > maxValue || decimal < minValue) {
            Message.error({ 
                content: `数字超出${t1_6_bitWidth.value}位有符号整数范围 [${minValue}, ${maxValue}]`, 
                position: 'bottom' 
            });
            return;
        }

        // 计算原码、反码、补码
        const absValue = Math.abs(decimal);
        const isNegative = decimal < 0;
        
        // 原码（符号位 + 数值的二进制）
        let original = absValue.toString(2).padStart(t1_6_bitWidth.value - 1, '0');
        original = (isNegative ? '1' : '0') + original;
        
        let inverse = '';
        let complement = '';
        
        if (isNegative) {
            // 负数：反码是原码除符号位外按位取反
            inverse = '1' + original.slice(1).split('').map(bit => bit === '0' ? '1' : '0').join('');
            
            // 补码是反码+1
            let carry = 1;
            let complementBits = inverse.split('').reverse();
            for (let i = 0; i < complementBits.length; i++) {
                if (carry === 0) break;
                if (complementBits[i] === '0') {
                    complementBits[i] = '1';
                    carry = 0;
                } else {
                    complementBits[i] = '0';
                }
            }
            complement = complementBits.reverse().join('');
        } else {
            // 正数：原码、反码、补码都相同
            inverse = original;
            complement = original;
        }

        // 更新结果
        t1_6_results.value = {
            decimal: decimal,
            original: original,
            inverse: inverse,
            complement: complement,
            binary: complement // 计算机中实际存储的就是补码
        };
        
        Message.success({ content: '转换成功!', position: 'bottom' });
    } catch (error) {
        Message.error({ content: '转换失败，请检查输入', position: 'bottom' });
    }
}

// 清空补码转换
function clear_t1_6() {
    t1_6_input.value = '';
    t1_6_results.value = {
        decimal: 0,
        original: '',
        inverse: '',
        complement: '',
        binary: ''
    };
}

// 复制补码转换结果
function copy_t1_6_result(type: string) {
    let value = '';
    switch (type) {
        case 'decimal':
            value = t1_6_results.value.decimal.toString();
            break;
        case 'original':
            value = t1_6_results.value.original;
            break;
        case 'inverse':
            value = t1_6_results.value.inverse;
            break;
        case 'complement':
            value = t1_6_results.value.complement;
            break;
        case 'binary':
            value = t1_6_results.value.binary;
            break;
        default:
            return;
    }
    
    if (!value) {
        Message.warning({ content: '没有可复制的结果', position: 'bottom' });
        return;
    }
    
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

// t7-3 MQTT监听工具
const mqtt_host = ref('127.0.0.1');
const mqtt_port = ref(1883);
const mqtt_topic = ref('test/test');
const mqtt_username = ref('');
const mqtt_password = ref('');
const mqtt_connection = ref<any>(null);
const mqtt_connected = ref(false);
const mqtt_logs = ref<Array<{
    id: number;
    type: string;
    message: string;
    timestamp: string;
    rawData: any;
}>>([]);
const mqtt_auto_scroll = ref(true);
const mqtt_max_logs = ref(1000); // 最大日志条数
const mqtt_total_received = ref(0); // 总接收消息数

// 记录MQTT日志
function addMqttLog(type: string, message: string, rawData: any = null) {
    const timestamp = new Date().toLocaleTimeString();
    let formattedMessage = message;
    
    // 统计消息数量
    if (type === 'received') {
        mqtt_total_received.value++;
    }
    
    // 如果有原始数据并且是JSON，尝试格式化它
    let jsonData = null;
    let truncatedRawData = rawData;
    
    if (rawData) {
        try {
            jsonData = JSON.parse(rawData);
            if (type === 'received') {
                // 限制JSON消息的显示长度
                const jsonStr = JSON.stringify(jsonData, null, 2);
                if (jsonStr.length > 1000) {
                    formattedMessage = jsonStr.substring(0, 1000) + '...(消息过长，已截断)';
                    // 不保存完整的原始数据，避免内存占用过大
                    truncatedRawData = jsonStr.substring(0, 500) + '...(已截断)';
                } else {
                    formattedMessage = jsonStr;
                }
            }
        } catch (e) {
            // 不是JSON格式，使用原始消息
            if (type === 'received') {
                // 限制非JSON消息的显示长度
                if (rawData && rawData.length > 1000) {
                    formattedMessage = rawData.substring(0, 1000) + '...(消息过长，已截断)';
                    truncatedRawData = rawData.substring(0, 500) + '...(已截断)';
                } else {
                    formattedMessage = rawData;
                }
            }
        }
    }
    
    mqtt_logs.value.push({
        id: Date.now() + Math.random(),
        type,
        message: formattedMessage,
        timestamp,
        rawData: jsonData || truncatedRawData
    });
    
    // 限制日志数量，避免内存过度消耗
    if (mqtt_logs.value.length > mqtt_max_logs.value) {
        // 删除最早的日志，保持数组大小在限制范围内
        const removeCount = mqtt_logs.value.length - mqtt_max_logs.value;
        mqtt_logs.value.splice(0, removeCount);
    }
    
    // 自动滚动到底部
    if (mqtt_auto_scroll.value) {
        setTimeout(() => {
            const container = document.querySelector('.mqtt-log-container');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }, 50);
    }
}

// 使用Electron主进程连接MQTT服务器
function connectMqtt() {
    if (mqtt_connected.value) {
        addMqttLog('warning', '已经连接到MQTT服务器，请先断开连接');
        return;
    }
    
    // 使用Electron主进程来连接MQTT
    addMqttLog('info', '正在连接到MQTT服务器...');
    
    // 发送连接请求到主进程
    window.ipcRenderer.send('test-mqtt-connection', {
        host: mqtt_host.value,
        port: mqtt_port.value,
        topic: mqtt_topic.value,
        username: mqtt_username.value || undefined,
        password: mqtt_password.value || undefined
    });
    
    // 监听连接结果
    window.ipcRenderer.once('mqtt-connection-result', (event, result) => {
        if (result.success) {
        mqtt_connected.value = true;
            addMqttLog('success', '已连接到MQTT服务器并订阅主题: ' + mqtt_topic.value);
        } else {
            addMqttLog('error', '连接失败: ' + result.error);
        }
    });
}

// 断开MQTT连接
function disconnectMqtt() {
    if (!mqtt_connected.value) {
        addMqttLog('warning', '没有活动的MQTT连接');
        return;
    }
    
    addMqttLog('info', '正在断开连接...');
    
    // 通知主进程断开连接
    window.ipcRenderer.send('mqtt-disconnect');
    
    // 设置状态为未连接
    mqtt_connected.value = false;
    addMqttLog('info', '已断开与MQTT服务器的连接');
}

// 取消订阅主题
function unsubscribeTopic() {
    if (!mqtt_connected.value || !mqtt_connection.value) {
        addMqttLog('error', '未连接到MQTT服务器');
        return;
    }
    
    mqtt_connection.value.unsubscribe(mqtt_topic.value, function(err: any) {
        if (err) {
            addMqttLog('error', '取消订阅失败: ' + err);
        } else {
            addMqttLog('success', '已成功取消订阅主题: ' + mqtt_topic.value);
        }
    });
}

// 清空MQTT日志
function clearMqttLogs() {
    mqtt_logs.value = [];
    mqtt_total_received.value = 0;
}

// 设置监听MQTT消息
function setupMQTTMessageListener() {
    // 监听从主进程发送的MQTT消息
    window.ipcRenderer.on('mqtt-message', (event, data) => {
        try {
            addMqttLog('received', `收到来自主题 [${data.topic}] 的消息: ${data.message}`);
        } catch (err) {
            console.error('处理MQTT消息时出错:', err);
        }
    });
}

// t7-4 MQTT广播工具
const mqtt_pub_host = ref('127.0.0.1');
const mqtt_pub_port = ref(1883);
const mqtt_pub_topic = ref('test/test');
const mqtt_pub_username = ref('');
const mqtt_pub_password = ref('');
const mqtt_pub_message = ref(JSON.stringify({ data: '测试消息', timestamp: new Date().toISOString() }, null, 2));
const mqtt_pub_connected = ref(false);
const mqtt_pub_interval = ref<any>(null);
const mqtt_pub_interval_time = ref(3);
const mqtt_pub_message_handler = ref<((event: any, data: any) => void) | null>(null);
const mqtt_pub_logs = ref<Array<{
    id: number;
    type: string;
    message: string;
    timestamp: string;
}>>([]);
const mqtt_pub_auto_scroll = ref(true);

// 记录MQTT广播日志
function addMqttPubLog(type: string, message: string) {
    const timestamp = new Date().toLocaleTimeString();
    mqtt_pub_logs.value.push({
        id: Date.now() + Math.random(),
        type,
        message,
        timestamp
    });
    
    // 自动滚动到底部
    if (mqtt_pub_auto_scroll.value) {
        setTimeout(() => {
            const container = document.querySelector('.mqtt-pub-log-container');
            if (container) {
                container.scrollTop = container.scrollHeight;
            }
        }, 50);
    }
}

// 单次广播消息
function publishMqttMessage() {
    // 发送单次广播请求到主进程
    window.ipcRenderer.send('mqtt-publish', {
        host: mqtt_pub_host.value,
        port: mqtt_pub_port.value,
        topic: mqtt_pub_topic.value,
        message: mqtt_pub_message.value,
        username: mqtt_pub_username.value || undefined,
        password: mqtt_pub_password.value || undefined
    });
    
    // 监听发布结果
    window.ipcRenderer.once('mqtt-publish-result', (event, result) => {
        if (result.success) {
            addMqttPubLog('success', '消息发送成功: ' + mqtt_pub_message.value);
        } else {
            addMqttPubLog('error', '消息发送失败: ' + result.error);
        }
    });
}

// 开始持续广播
function startContinuousPublish() {
    if (mqtt_pub_connected.value) {
        addMqttPubLog('warning', '已经在持续广播中');
        return;
    }
    
    // 发送连接请求到主进程
    window.ipcRenderer.send('mqtt-publish-connect', {
        host: mqtt_pub_host.value,
        port: mqtt_pub_port.value,
        topic: mqtt_pub_topic.value,
        message: mqtt_pub_message.value,
        interval: mqtt_pub_interval_time.value,
        username: mqtt_pub_username.value || undefined,
        password: mqtt_pub_password.value || undefined
    });
    
    // 监听连接结果
    window.ipcRenderer.once('mqtt-publish-connect-result', (event, result) => {
        if (result.success) {
            mqtt_pub_connected.value = true;
            addMqttPubLog('success', '已连接到MQTT服务器并开始持续广播');
            
            // 监听发布消息
            const messageHandler = (event: any, data: any) => {
                addMqttPubLog('sent', '发送消息: ' + data.message);
            };
            // 保存处理函数的引用
            mqtt_pub_message_handler.value = messageHandler;
            window.ipcRenderer.on('mqtt-publish-message', messageHandler);
        } else {
            addMqttPubLog('error', '连接失败: ' + result.error);
        }
    });
}

// 停止持续广播
function stopContinuousPublish() {
    if (!mqtt_pub_connected.value) {
        addMqttPubLog('warning', '没有活动的持续广播');
        return;
    }
    
    // 发送断开连接请求到主进程
    window.ipcRenderer.send('mqtt-publish-disconnect');
    
    mqtt_pub_connected.value = false;
    addMqttPubLog('info', '已停止持续广播');
    
    // 移除消息监听
    if (mqtt_pub_message_handler.value) {
        window.ipcRenderer.off('mqtt-publish-message', mqtt_pub_message_handler.value);
        mqtt_pub_message_handler.value = null;
    }
}

// 清空MQTT广播日志
function clearMqttPubLogs() {
    mqtt_pub_logs.value = [];
}

// 复制文本到剪贴板
function copyToClipboard(text: string) {
    navigator.clipboard.writeText(text)
        .then(() => {
            Message.success('已复制到剪贴板');
        })
        .catch(err => {
            Message.error('复制失败: ' + err);
        });
}

// 在组件挂载时设置监听器
onMounted(() => {
    setupMQTTMessageListener();
});

// 在组件销毁前断开连接
onBeforeUnmount(() => {
    // 如果还有连接，先断开连接
    if (mqtt_connected.value) {
        disconnectMqtt();
    }
    
    // 如果还有广播连接，也断开
    if (mqtt_pub_connected.value) {
        stopContinuousPublish();
    }
});

// 在Electron环境中尝试MQTT连接（使用ipcRenderer）
function electronMQTTTest() {
    addMqttLog('info', '尝试通过Electron的IPC方式连接MQTT...');
    
    // 检查是否存在ipcRenderer
    if (window.ipcRenderer) {
        // 向主进程发送MQTT连接请求
        window.ipcRenderer.send('test-mqtt-connection', {
            host: mqtt_host.value,
            port: mqtt_port.value,
            topic: mqtt_topic.value
        });
        
        // 监听连接结果
        window.ipcRenderer.once('mqtt-connection-result', (event, result) => {
            if (result.success) {
                addMqttLog('success', '主进程MQTT连接成功: ' + result.message);
            } else {
                addMqttLog('error', '主进程MQTT连接失败: ' + result.error);
            }
        });
    } else {
        addMqttLog('error', '无法访问Electron IPC渲染进程');
    }
}

// 尝试直接在渲染进程中使用Node.js方式连接MQTT
function nodeMQTTTest() {
    addMqttLog('info', '尝试使用浏览器方式直接连接MQTT...');
    
    try {
        // 尝试使用MQTT.js的浏览器版本
        // 注意：直接使用导入的mqtt实例
        
        // 完全按照原始示例代码的方式配置
        const url = 'mqtt://' + mqtt_host.value + ':' + mqtt_port.value;
        const clientId = 'mqtt_browser_test_' + Math.random().toString(16).substr(2, 8);
        
        console.log('尝试浏览器方式连接MQTT:', url);
        
        // 创建客户端连接 - 注意不使用options参数，而是直接在URL中指定
        const testClient = mqtt.connect(url, {
            clientId: clientId,
            clean: true
        });
        
        // 添加事件处理
        testClient.on('connect', function() {
            addMqttLog('success', '浏览器连接方式成功连接到MQTT服务器');
            console.log('浏览器连接方式连接成功！');
            
            // 连接成功后关闭连接
            setTimeout(() => {
                testClient.end();
                addMqttLog('info', '测试连接已关闭');
            }, 3000);
        });
        
        testClient.on('error', function(err) {
            addMqttLog('error', '浏览器连接方式错误: ' + err);
            console.error('浏览器连接方式错误:', err);
            testClient.end();
        });
        
        testClient.on('close', function() {
            console.log('浏览器连接方式关闭');
        });
    } catch (error) {
        addMqttLog('error', '无法使用浏览器方式连接: ' + error);
        console.error('浏览器方式连接错误:', error);
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
                        style="display: flex; flex-direction: column; justify-content: center; align-items: center; margin-top: 5px;">
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

        <!-- t1-5 进制转换 -->
        <div v-show="tooltype == 't1-5'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="进制转换" @back="switchToMenu"
                    subtitle="数字进制相互转换">
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
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                支持2-36进制之间的数字转换。常用进制：二进制(2)、八进制(8)、十进制(10)、十六进制(16)
                            </a-alert>
                        </div>

                        <!-- 输入区域 -->
                        <a-card title="输入数字" :bordered="false" style="margin-bottom: 15px;">
                            <a-row style="margin-bottom: 15px;">
                                <a-col :span="24">
                                    <a-input 
                                        v-model="t1_5_input" 
                                        placeholder="请输入要转换的数字" 
                                        style="font-size: 16px;"
                                        @press-enter="convertBase"
                                    />
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="11">
                                    <div style="display: flex; align-items: center;">
                                        <span style="margin-right: 10px; font-weight: 500;">从</span>
                                        <a-select v-model="t1_5_fromBase" style="flex: 1;">
                                            <a-option :value="2">二进制 (2)</a-option>
                                            <a-option :value="8">八进制 (8)</a-option>
                                            <a-option :value="10">十进制 (10)</a-option>
                                            <a-option :value="16">十六进制 (16)</a-option>
                                            <a-option v-for="i in 36" :key="i" :value="i" v-show="![2,8,10,16].includes(i)">
                                                {{ i }}进制
                                            </a-option>
                                        </a-select>
                                        <span style="margin-left: 10px;">进制</span>
                                    </div>
                                </a-col>
                                <a-col :span="2" style="display: flex; justify-content: center; align-items: center;">
                                    <a-button @click="swapBase" type="text">
                                        ⇄
                                    </a-button>
                                </a-col>
                                <a-col :span="11">
                                    <div style="display: flex; align-items: center;">
                                        <span style="margin-right: 10px; font-weight: 500;">转为</span>
                                        <a-select v-model="t1_5_toBase" style="flex: 1;">
                                            <a-option :value="2">二进制 (2)</a-option>
                                            <a-option :value="8">八进制 (8)</a-option>
                                            <a-option :value="10">十进制 (10)</a-option>
                                            <a-option :value="16">十六进制 (16)</a-option>
                                            <a-option v-for="i in 36" :key="i" :value="i" v-show="![2,8,10,16].includes(i)">
                                                {{ i }}进制
                                            </a-option>
                                        </a-select>
                                        <span style="margin-left: 10px;">进制</span>
                                    </div>
                                </a-col>
                            </a-row>
                        </a-card>

                        <!-- 操作按钮 -->
                        <div style="display: flex; justify-content: center; margin-bottom: 15px;">
                            <a-space>
                                <a-button type="primary" @click="convertBase" size="large">转换</a-button>
                                <a-button @click="clear_t1_5">清空</a-button>
                            </a-space>
                        </div>

                        <!-- 结果显示 -->
                        <a-card title="转换结果" :bordered="false" v-show="t1_5_result">
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <a-input 
                                    v-model="t1_5_result" 
                                    readonly 
                                    style="flex: 1; font-size: 16px; font-family: monospace;"
                                />
                                <a-button @click="copy_t1_5_result" type="primary">复制</a-button>
                            </div>
                        </a-card>

                        <!-- 进制参考表 -->
                        <a-card title="常用进制对照" :bordered="false" style="margin-top: 20px;">
                            <div style="overflow-x: auto;">
                                <table style="width: 100%; border-collapse: collapse;">
                                    <thead>
                                        <tr style="background-color: #f5f5f5;">
                                            <th style="padding: 8px; border: 1px solid #ddd; text-align: center;">十进制</th>
                                            <th style="padding: 8px; border: 1px solid #ddd; text-align: center;">二进制</th>
                                            <th style="padding: 8px; border: 1px solid #ddd; text-align: center;">八进制</th>
                                            <th style="padding: 8px; border: 1px solid #ddd; text-align: center;">十六进制</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr v-for="i in 16" :key="i">
                                            <td style="padding: 6px; border: 1px solid #ddd; text-align: center;">{{ i - 1 }}</td>
                                            <td style="padding: 6px; border: 1px solid #ddd; text-align: center; font-family: monospace;">{{ (i - 1).toString(2) }}</td>
                                            <td style="padding: 6px; border: 1px solid #ddd; text-align: center; font-family: monospace;">{{ (i - 1).toString(8) }}</td>
                                            <td style="padding: 6px; border: 1px solid #ddd; text-align: center; font-family: monospace;">{{ (i - 1).toString(16).toUpperCase() }}</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <!-- t1-6 补码转换 -->
        <div v-show="tooltype == 't1-6'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="补码转换" @back="switchToMenu"
                    subtitle="原码反码补码转换">
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
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                支持十进制数字和二进制数字的原码、反码、补码相互转换。输入二进制时可以加0b前缀或直接输入。
                            </a-alert>
                        </div>

                        <!-- 配置区域 -->
                        <a-card title="转换配置" :bordered="false" style="margin-bottom: 15px;">
                            <a-row>
                                <a-col :span="12">
                                    <div style="display: flex; align-items: center;">
                                        <span style="margin-right: 10px; font-weight: 500;">位宽：</span>
                                        <a-select v-model="t1_6_bitWidth" style="width: 120px;">
                                            <a-option :value="8">8位</a-option>
                                            <a-option :value="16">16位</a-option>
                                            <a-option :value="32">32位</a-option>
                                        </a-select>
                                    </div>
                                </a-col>
                                <a-col :span="12">
                                    <div style="color: #666; font-size: 14px;">
                                        支持范围：{{ -Math.pow(2, t1_6_bitWidth - 1) }} ~ {{ Math.pow(2, t1_6_bitWidth - 1) - 1 }}
                                    </div>
                                </a-col>
                            </a-row>
                        </a-card>

                        <!-- 输入区域 -->
                        <a-card title="输入数字" :bordered="false" style="margin-bottom: 15px;">
                            <a-row style="margin-bottom: 15px;">
                                <a-col :span="24">
                                    <a-input 
                                        v-model="t1_6_input" 
                                        placeholder="请输入十进制数字或二进制数字（如：-5 或 0b1011 或 1011）" 
                                        style="font-size: 16px;"
                                        @press-enter="convertComplement"
                                    />
                                </a-col>
                            </a-row>
                            <a-row>
                                <a-col :span="24" style="display: flex; justify-content: center;">
                                    <a-space>
                                        <a-button type="primary" @click="convertComplement" size="large">转换</a-button>
                                        <a-button @click="clear_t1_6">清空</a-button>
                                    </a-space>
                                </a-col>
                            </a-row>
                        </a-card>

                        <!-- 结果显示 -->
                        <div v-show="t1_6_results.original">
                            <a-card title="转换结果" :bordered="false" style="margin-bottom: 15px;">
                                <div style="display: flex; flex-direction: column; gap: 12px;">
                                    <!-- 十进制 -->
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <span style="width: 80px; font-weight: 500;">十进制：</span>
                                        <a-input 
                                            :value="t1_6_results.decimal" 
                                            readonly 
                                            style="flex: 1; font-family: monospace;"
                                        />
                                        <a-button @click="copy_t1_6_result('decimal')" size="small">复制</a-button>
                                    </div>
                                    
                                    <!-- 原码 -->
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <span style="width: 80px; font-weight: 500;">原码：</span>
                                        <a-input 
                                            :value="t1_6_results.original" 
                                            readonly 
                                            style="flex: 1; font-family: monospace; letter-spacing: 1px;"
                                        />
                                        <a-button @click="copy_t1_6_result('original')" size="small">复制</a-button>
                                    </div>
                                    
                                    <!-- 反码 -->
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <span style="width: 80px; font-weight: 500;">反码：</span>
                                        <a-input 
                                            :value="t1_6_results.inverse" 
                                            readonly 
                                            style="flex: 1; font-family: monospace; letter-spacing: 1px;"
                                        />
                                        <a-button @click="copy_t1_6_result('inverse')" size="small">复制</a-button>
                                    </div>
                                    
                                    <!-- 补码 -->
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <span style="width: 80px; font-weight: 500;">补码：</span>
                                        <a-input 
                                            :value="t1_6_results.complement" 
                                            readonly 
                                            style="flex: 1; font-family: monospace; letter-spacing: 1px;"
                                        />
                                        <a-button @click="copy_t1_6_result('complement')" size="small">复制</a-button>
                                    </div>
                                </div>
                            </a-card>

                            <!-- 知识点说明 -->
                            <a-card title="知识点说明" :bordered="false">
                                <div style="line-height: 1.6;">
                                    <p><strong>原码：</strong>符号位 + 数值的二进制表示（0表示正数，1表示负数）</p>
                                    <p><strong>反码：</strong>正数的反码与原码相同；负数的反码是符号位不变，其他位按位取反</p>
                                    <p><strong>补码：</strong>正数的补码与原码相同；负数的补码是反码加1</p>
                                    <p><strong>说明：</strong>计算机内部使用补码来表示和存储数字，这样可以统一正负数的运算规则</p>
                                </div>
                            </a-card>
                        </div>
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

        <div v-show="tooltype == 't3-8'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="Go交叉编译" @back="switchToMenu"
                    subtitle="Go语言跨平台编译指南">
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
                        <h3 style="margin: 15px 0px;">Go语言交叉编译命令参考</h3>
                        <p style="margin-bottom: 15px;">通过设置环境变量 <code>GOOS</code> 和 <code>GOARCH</code> 即可实现跨平台编译</p>
                        
                        <a-alert type="info" banner style="margin-bottom: 20px;">
                            <strong>基本用法</strong>: <code>GOOS=目标系统 GOARCH=目标架构 go build</code><br/>
                            示例: <code>GOOS=windows GOARCH=amd64 go build -o myapp.exe main.go</code>
                        </a-alert>

                        <h4 style="margin: 15px 0px;">Windows 系统编译命令</h4>
                        <a-table :bordered="true" :data="[
                            { os: 'Windows', arch: 'x86 (32位)', cmd: 'GOOS=windows GOARCH=386 go build -o myapp.exe main.go' },
                            { os: 'Windows', arch: 'x64 (64位)', cmd: 'GOOS=windows GOARCH=amd64 go build -o myapp.exe main.go' },
                            { os: 'Windows', arch: 'ARM (32位)', cmd: 'GOOS=windows GOARCH=arm go build -o myapp.exe main.go' },
                            { os: 'Windows', arch: 'ARM64 (64位)', cmd: 'GOOS=windows GOARCH=arm64 go build -o myapp.exe main.go' }
                        ]" :pagination="false" style="margin-bottom: 20px;">
                            <template #columns>
                                <a-table-column title="操作系统" data-index="os" />
                                <a-table-column title="架构" data-index="arch" />
                                <a-table-column title="编译命令" data-index="cmd">
                                    <template #cell="{ record }">
                                        <a-button size="mini" style="margin-right: 8px;" 
                                            @click="copyToClipboard(record.cmd)">复制</a-button>
                                        <code>{{ record.cmd }}</code>
                                    </template>
                                </a-table-column>
                            </template>
                        </a-table>

                        <h4 style="margin: 15px 0px;">macOS 系统编译命令</h4>
                        <a-table :bordered="true" :data="[
                            { os: 'macOS', arch: 'Intel (64位)', cmd: 'GOOS=darwin GOARCH=amd64 go build -o myapp main.go' },
                            { os: 'macOS', arch: 'Apple Silicon (M1/M2)', cmd: 'GOOS=darwin GOARCH=arm64 go build -o myapp main.go' }
                        ]" :pagination="false" style="margin-bottom: 20px;">
                            <template #columns>
                                <a-table-column title="操作系统" data-index="os" />
                                <a-table-column title="架构" data-index="arch" />
                                <a-table-column title="编译命令" data-index="cmd">
                                    <template #cell="{ record }">
                                        <a-button size="mini" style="margin-right: 8px;" 
                                            @click="copyToClipboard(record.cmd)">复制</a-button>
                                        <code>{{ record.cmd }}</code>
                                    </template>
                                </a-table-column>
                            </template>
                        </a-table>

                        <h4 style="margin: 15px 0px;">Linux 系统编译命令</h4>
                        <a-table :bordered="true" :data="[
                            { os: 'Linux', arch: 'x86 (32位)', cmd: 'GOOS=linux GOARCH=386 go build -o myapp main.go' },
                            { os: 'Linux', arch: 'x64 (64位)', cmd: 'GOOS=linux GOARCH=amd64 go build -o myapp main.go' },
                            { os: 'Linux', arch: 'ARM (32位)', cmd: 'GOOS=linux GOARCH=arm go build -o myapp main.go' },
                            { os: 'Linux', arch: 'ARM64 (64位)', cmd: 'GOOS=linux GOARCH=arm64 go build -o myapp main.go' },
                            { os: 'Linux', arch: 'MIPS (32位小端)', cmd: 'GOOS=linux GOARCH=mipsle go build -o myapp main.go' },
                            { os: 'Linux', arch: 'MIPS (64位小端)', cmd: 'GOOS=linux GOARCH=mips64le go build -o myapp main.go' }
                        ]" :pagination="false" style="margin-bottom: 20px;">
                            <template #columns>
                                <a-table-column title="操作系统" data-index="os" />
                                <a-table-column title="架构" data-index="arch" />
                                <a-table-column title="编译命令" data-index="cmd">
                                    <template #cell="{ record }">
                                        <a-button size="mini" style="margin-right: 8px;" 
                                            @click="copyToClipboard(record.cmd)">复制</a-button>
                                        <code>{{ record.cmd }}</code>
                                    </template>
                                </a-table-column>
                            </template>
                        </a-table>

                        <h4 style="margin: 15px 0px;">其他操作系统编译命令</h4>
                        <a-table :bordered="true" :data="[
                            { os: 'Android', arch: 'ARM (32位)', cmd: 'GOOS=android GOARCH=arm go build -o myapp main.go' },
                            { os: 'Android', arch: 'ARM64 (64位)', cmd: 'GOOS=android GOARCH=arm64 go build -o myapp main.go' },
                            { os: 'FreeBSD', arch: 'x64 (64位)', cmd: 'GOOS=freebsd GOARCH=amd64 go build -o myapp main.go' },
                            { os: 'OpenBSD', arch: 'x64 (64位)', cmd: 'GOOS=openbsd GOARCH=amd64 go build -o myapp main.go' },
                            { os: 'Solaris', arch: 'x64 (64位)', cmd: 'GOOS=solaris GOARCH=amd64 go build -o myapp main.go' },
                            { os: 'DragonFly', arch: 'x64 (64位)', cmd: 'GOOS=dragonfly GOARCH=amd64 go build -o myapp main.go' }
                        ]" :pagination="false" style="margin-bottom: 20px;">
                            <template #columns>
                                <a-table-column title="操作系统" data-index="os" />
                                <a-table-column title="架构" data-index="arch" />
                                <a-table-column title="编译命令" data-index="cmd">
                                    <template #cell="{ record }">
                                        <a-button size="mini" style="margin-right: 8px;" 
                                            @click="copyToClipboard(record.cmd)">复制</a-button>
                                        <code>{{ record.cmd }}</code>
                                    </template>
                                </a-table-column>
                            </template>
                        </a-table>

                        <h4 style="margin: 15px 0px;">Windows中的交叉编译批处理示例</h4>
                        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                            <pre style="margin: 0; white-space: pre-wrap; font-family: Consolas, monospace;">@echo off
setlocal

set APP_NAME=myapp
set MAIN_GO=main.go

echo 开始编译 %APP_NAME% 到多个平台...

:: Windows 64位
set GOOS=windows
set GOARCH=amd64
go build -o %APP_NAME%_windows_amd64.exe %MAIN_GO%
if %ERRORLEVEL% neq 0 goto :error

:: Linux 64位
set GOOS=linux
set GOARCH=amd64
go build -o %APP_NAME%_linux_amd64 %MAIN_GO%
if %ERRORLEVEL% neq 0 goto :error

:: macOS 64位
set GOOS=darwin
set GOARCH=amd64
go build -o %APP_NAME%_darwin_amd64 %MAIN_GO%
if %ERRORLEVEL% neq 0 goto :error

echo 编译完成！
goto :end

:error
echo 编译失败，错误代码: %ERRORLEVEL%

:end
endlocal
</pre>
                                    </div>

                        <h4 style="margin: 15px 0px;">macOS/Linux中的交叉编译脚本示例</h4>
                        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                            <pre style="margin: 0; white-space: pre-wrap; font-family: Consolas, monospace;">#!/bin/bash

APP_NAME="myapp"
MAIN_GO="main.go"

echo "开始编译 $APP_NAME 到多个平台..."

# Windows 64位
GOOS=windows GOARCH=amd64 go build -o ${APP_NAME}_windows_amd64.exe $MAIN_GO
if [ $? -ne 0 ]; then
    echo "编译失败!"
    exit 1
fi

# Linux 64位
GOOS=linux GOARCH=amd64 go build -o ${APP_NAME}_linux_amd64 $MAIN_GO
if [ $? -ne 0 ]; then
    echo "编译失败!"
    exit 1
fi

# macOS 64位
GOOS=darwin GOARCH=amd64 go build -o ${APP_NAME}_darwin_amd64 $MAIN_GO
if [ $? -ne 0 ]; then
    echo "编译失败!"
    exit 1
fi

echo "编译完成！"
</pre>
                        </div>

                        <h4 style="margin: 15px 0px;">使用标签和编译约束</h4>
                        <p>在交叉编译中，您可能需要处理平台特定的代码：</p>
                        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                            <pre style="margin: 0; white-space: pre-wrap; font-family: Consolas, monospace;">// +build windows

package main

import (
    "fmt"
    "os"
    "os/exec"
)

func openBrowser(url string) error {
    cmd := exec.Command("cmd", "/c", "start", url)
    return cmd.Start()
}
</pre>
                        </div>

                        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                            <pre style="margin: 0; white-space: pre-wrap; font-family: Consolas, monospace;">// +build linux

package main

import (
    "fmt"
    "os"
    "os/exec"
)

func openBrowser(url string) error {
    cmd := exec.Command("xdg-open", url)
    return cmd.Start()
}
</pre>
                        </div>

                        <h4 style="margin: 15px 0px;">支持的GOOS和GOARCH值</h4>
                        <p>Go语言支持的操作系统(GOOS)和架构(GOARCH)组合：</p>
                        <div style="background-color: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                            <div style="font-family: Consolas, monospace;">
                                <strong>GOOS（操作系统）</strong>：
                                <p>android, darwin, dragonfly, freebsd, illumos, ios, js, linux, netbsd, openbsd, plan9, solaris, windows</p>
                                
                                <strong>GOARCH（架构）</strong>：
                                <p>386, amd64, arm, arm64, loong64, mips, mips64, mips64le, mipsle, ppc64, ppc64le, riscv64, s390x, wasm</p>
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

        <div v-show="tooltype == 't7-3'" class="one-tool">
             <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="MQTT监听工具" @back="switchToMenu"
                    subtitle="MQTT连接测试工具">
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
                                                                          <!-- 连接设置区 -->
                         <a-card title="连接设置" :style="{ marginBottom: '15px', borderRadius: '8px' }" :bordered="true" :hover="true">
                             <div style="display: flex; align-items: center; flex-wrap: wrap;">
                                 <span style="width: 120px; font-weight: 500;">MQTT服务器地址：</span>
                                 <a-input v-model="mqtt_host" :disabled="mqtt_connected" placeholder="MQTT服务器地址" 
                                          style="flex: 1; margin-right: 15px;" />
                                 <span style="width: 60px; font-weight: 500;">端口：</span>
                                 <a-input-number v-model="mqtt_port" :disabled="mqtt_connected" :min="1" :max="65535" style="width: 100px; margin-right: 15px;" />
                             </div>
                             <div style="margin-top: 15px; display: flex; align-items: center; flex-wrap: wrap;">
                                 <span style="width: 120px; font-weight: 500;">主题：</span>
                                 <a-input v-model="mqtt_topic" :disabled="mqtt_connected" placeholder="请输入要订阅的主题" style="flex: 1; margin-right: 15px;" />
                             </div>
                             
                             <a-collapse :bordered="false" style="margin-top: 15px; background: transparent;">
                                 <a-collapse-item header="认证设置（可选）" key="1">
                                     <div style="display: flex; align-items: center; margin-bottom: 10px;">
                                         <span style="width: 120px; font-weight: 500;">用户名：</span>
                                         <a-input v-model="mqtt_username" :disabled="mqtt_connected" placeholder="可选，不填则不使用认证" style="flex: 1;" />
                                     </div>
                                     <div style="display: flex; align-items: center;">
                                         <span style="width: 120px; font-weight: 500;">密码：</span>
                                         <a-input-password v-model="mqtt_password" :disabled="mqtt_connected" placeholder="可选，不填则不使用认证" style="flex: 1;" />
                                    </div>
                                </a-collapse-item>
                            </a-collapse>
                             <div style="margin-top: 15px; display: flex; justify-content: flex-end;">
                                 <a-button type="primary" :disabled="mqtt_connected" @click="connectMqtt"
                                           style="margin-right: 10px; width: 120px;">连接</a-button>
                                 <a-button :disabled="!mqtt_connected" @click="disconnectMqtt" 
                                          style="width: 120px;">断开</a-button>
                        </div>
                             <div style="margin-top: 15px;">
                                 <a-alert v-if="mqtt_connected" type="success" :style="{ fontWeight: '500' }">已连接到MQTT服务器并订阅主题: {{ mqtt_topic }}</a-alert>
                                 <a-alert v-else type="info">MQTT未连接</a-alert>
                             </div>
                         </a-card>

                         <!-- 日志区域 -->
                         <a-card title="通信日志" :style="{ marginBottom: '15px', borderRadius: '8px' }" :bordered="true" :hover="true">
                             <!-- 统计信息 -->
                             <div style="display: flex; justify-content: space-between; margin-bottom: 15px; padding: 12px; background-color: #f0f7ff; border-radius: 8px;">
                                 <div style="display: flex; align-items: center; gap: 20px;">
                                     <div style="display: flex; align-items: center; gap: 5px;">
                                         <a-tag color="purple">接收消息</a-tag>
                                         <span style="font-weight: 600; color: #722ed1;">{{ mqtt_total_received }}</span>
                                     </div>
                                     <div style="display: flex; align-items: center; gap: 5px;">
                                         <a-tag color="gray">当前日志</a-tag>
                                         <span style="font-weight: 600; color: #595959;">{{ mqtt_logs.length }}/{{ mqtt_max_logs }}</span>
                                     </div>
                                 </div>
                             </div>
                             
                             <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; padding: 0 2%;">
                                 <div style="display: flex; align-items: center; gap: 15px;">
                                     <a-checkbox v-model="mqtt_auto_scroll">自动滚动</a-checkbox>
                                     <div style="display: flex; align-items: center; gap: 8px;">
                                         <span style="font-size: 14px;">日志上限：</span>
                                         <a-input-number v-model="mqtt_max_logs" :min="100" :max="10000" :step="100" 
                                                        style="width: 100px;" size="small" />
                                     </div>
                             </div>
                             <div>
                                     <a-button size="small" @click="clearMqttLogs" type="outline">清空日志</a-button>
                             </div>
                         </div>

                             <!-- 日志数量警告 -->
                             <div v-if="mqtt_logs.length >= mqtt_max_logs * 0.9" style="margin-bottom: 10px;">
                                 <a-alert type="warning" :style="{ fontSize: '12px' }">
                                     日志数量已接近上限 ({{ mqtt_logs.length }}/{{ mqtt_max_logs }})，旧日志将自动清理以释放内存
                                 </a-alert>
                                 </div>
                             
                             <div class="mqtt-log-container custom-scrollbar" style="height: 300px; overflow-y: auto; border: 1px solid #eee; padding: 15px; border-radius: 8px; width: 96%; margin: 0 auto; box-shadow: inset 0 0 5px rgba(0,0,0,0.05);">
                                 <div v-for="log in mqtt_logs" :key="log.id" class="mqtt-log-item" :class="`mqtt-log-${log.type}`">
                                     <span class="mqtt-log-time">[{{ log.timestamp }}]</span>
                                     <span class="mqtt-log-type">
                                         <a-tag v-if="log.type === 'success'" color="green">成功</a-tag>
                                         <a-tag v-else-if="log.type === 'error'" color="red">错误</a-tag>
                                         <a-tag v-else-if="log.type === 'received'" color="purple">接收</a-tag>
                                         <a-tag v-else-if="log.type === 'sent'" color="blue">发送</a-tag>
                                         <a-tag v-else-if="log.type === 'warning'" color="orange">警告</a-tag>
                                         <a-tag v-else color="gray">信息</a-tag>
                                     </span>
                                     <span class="mqtt-log-message">{{ log.message }}</span>
                                 </div>
                                 <div v-if="mqtt_logs.length === 0" class="mqtt-log-empty">
                                     暂无日志记录
                             </div>
                         </div>
                         </a-card>
                         
                         <!-- 使用说明 -->
                         <a-card title="使用说明" :style="{ marginBottom: '15px', borderRadius: '8px' }" :bordered="true" :hover="true">
                             <div class="mqtt-usage-guide">
                                 <div style="padding: 5px 15px; background-color: #f8f9fa; border-radius: 6px; margin-bottom: 15px;">
                                     <h4 style="margin-bottom: 10px; color: #1890ff;">连接说明</h4>
                                     <p>本工具实现订阅连接MQTT服务器的特定主题，支持实时接收和显示消息</p>
                                 </div>
                                 
                                 <div style="padding: 5px 15px; background-color: #f8f9fa; border-radius: 6px; margin-bottom: 15px;">
                                     <h4 style="margin-bottom: 10px; color: #1890ff;">默认参数</h4>
                                     <div style="display: flex; flex-wrap: wrap;">
                                         <div style="flex: 1; min-width: 150px; margin: 5px;">
                                             <a-tag color="blue">QoS: 0</a-tag>
                                         </div>
                                         <div style="flex: 1; min-width: 150px; margin: 5px;">
                                             <a-tag color="blue">Clean Session: true</a-tag>
                                         </div>
                                         <div style="flex: 1; min-width: 150px; margin: 5px;">
                                             <a-tag color="blue">Client ID: 自动生成</a-tag>
                                         </div>
                                     </div>
                                 </div>
                                 
                                 <div style="padding: 12px 18px; background-color: #f0f7ff; border-radius: 8px; border-left: 4px solid #1890ff;">
                                     <h4 style="margin-bottom: 12px; color: #1890ff; font-weight: 600;">认证选项</h4>
                                     <p style="margin-bottom: 8px; line-height: 1.5;">MQTT连接支持以下认证方式：</p>
                                     <div style="display: flex; margin: 10px 0;">
                                         <div style="flex: 1; border-radius: 6px; background-color: white; padding: 10px; margin-right: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                                             <div style="display: flex; align-items: center; margin-bottom: 5px;">
                                                 <a-tag color="green">基础连接</a-tag>
                                             </div>
                                             <p>无需认证，直接连接MQTT服务器</p>
                                             <div style="color: #888; font-size: 12px; margin-top: 5px;">适用于无认证要求的服务器</div>
                                         </div>
                                         <div style="flex: 1; border-radius: 6px; background-color: white; padding: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">
                                             <div style="display: flex; align-items: center; margin-bottom: 5px;">
                                                 <a-tag color="blue">用户名+密码</a-tag>
                                             </div>
                                             <p>提供用户名和密码进行身份验证</p>
                                             <div style="color: #888; font-size: 12px; margin-top: 5px;">适用于需要身份验证的MQTT服务器</div>
                                         </div>
                                     </div>
                                     <div style="font-size: 12px; color: #555; font-style: italic; margin-top: 8px; line-height: 1.5;">
                                         提示: 如果您不确定连接参数，请联系您的MQTT服务器管理员获取正确的配置信息。
                                     </div>
                                 </div>
                             </div>
                        </a-card>
                     </a-col>
                 </a-row>
             </div>
         </div>

        <div v-show="tooltype == 't7-4'" class="one-tool">
             <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="MQTT广播工具" @back="switchToMenu"
                    subtitle="MQTT消息发布工具">
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
                        <!-- 连接设置区 -->
                        <a-card title="广播设置" :style="{ marginBottom: '15px', borderRadius: '8px' }" :bordered="true" :hover="true">
                            <div style="display: flex; align-items: center; flex-wrap: wrap;">
                                <span style="width: 120px; font-weight: 500;">MQTT服务器地址：</span>
                                <a-input v-model="mqtt_pub_host" :disabled="mqtt_pub_connected" placeholder="MQTT服务器地址" 
                                         style="flex: 1; margin-right: 15px;" />
                                <span style="width: 60px; font-weight: 500;">端口：</span>
                                <a-input-number v-model="mqtt_pub_port" :disabled="mqtt_pub_connected" :min="1" :max="65535" style="width: 100px; margin-right: 15px;" />
                            </div>
                            
                            <div style="margin-top: 15px; display: flex; align-items: center; flex-wrap: wrap;">
                                <span style="width: 120px; font-weight: 500;">主题：</span>
                                <a-input v-model="mqtt_pub_topic" :disabled="mqtt_pub_connected" placeholder="请输入要发布的主题" style="flex: 1; margin-right: 15px;" />
                            </div>
                            
                            <a-collapse :bordered="false" style="margin-top: 15px; background: transparent;">
                                <a-collapse-item header="认证设置（可选）" key="1">
                                    <div style="display: flex; align-items: center; margin-bottom: 10px;">
                                        <span style="width: 120px; font-weight: 500;">用户名：</span>
                                        <a-input v-model="mqtt_pub_username" :disabled="mqtt_pub_connected" placeholder="可选，不填则不使用认证" style="flex: 1;" />
                                    </div>
                                    <div style="display: flex; align-items: center;">
                                        <span style="width: 120px; font-weight: 500;">密码：</span>
                                        <a-input-password v-model="mqtt_pub_password" :disabled="mqtt_pub_connected" placeholder="可选，不填则不使用认证" style="flex: 1;" />
                                    </div>
                                </a-collapse-item>
                            </a-collapse>

                            <div style="margin-top: 15px;">
                                <span style="font-weight: 500; display: block; margin-bottom: 10px;">消息内容：</span>
                                <a-textarea v-model="mqtt_pub_message" :disabled="mqtt_pub_connected" 
                                   placeholder="请输入要发布的消息内容，支持JSON格式" 
                                   :auto-size="{ minRows: 5, maxRows: 10 }" 
                                   style="font-family: monospace; width: 100%;" />
                            </div>

                            <div style="margin-top: 15px; display: flex; align-items: center; flex-wrap: wrap; justify-content: center;" 
                                 v-show="!mqtt_pub_connected">
                                <a-button type="primary" @click="publishMqttMessage" 
                                          style="margin-right: 15px;">单次广播</a-button>
                                
                                <span style="margin-right: 10px;">或</span>
                                
                                <span style="margin-right: 10px;">每</span>
                                <a-input-number v-model="mqtt_pub_interval_time" :min="1" :max="60" 
                                                style="width: 80px; margin-right: 10px;" />
                                <span style="margin-right: 15px;">秒广播一次</span>
                                
                                <a-button type="primary" status="success" @click="startContinuousPublish">
                                    开始持续广播
                                </a-button>
                            </div>
                            
                            <div style="margin-top: 15px; display: flex; justify-content: center;" 
                                 v-show="mqtt_pub_connected">
                                <a-button type="primary" status="danger" @click="stopContinuousPublish"
                                         style="width: 160px;">停止持续广播</a-button>
                            </div>
                            
                            <div style="margin-top: 15px;">
                                <a-alert v-if="mqtt_pub_connected" type="success" :style="{ fontWeight: '500' }">
                                    正在持续广播中，每 {{ mqtt_pub_interval_time }} 秒发送一次消息到主题: {{ mqtt_pub_topic }}
                         </a-alert>
                            </div>
                        </a-card>

                        <!-- 日志区域 -->
                        <a-card title="广播日志" :style="{ marginBottom: '15px', borderRadius: '8px' }" :bordered="true" :hover="true">
                            <div style="display: flex; justify-content: space-between; margin-bottom: 15px; padding: 0 2%;">
                                <div>
                                    <a-checkbox v-model="mqtt_pub_auto_scroll">自动滚动</a-checkbox>
                                </div>
                                <div>
                                    <a-button size="small" @click="clearMqttPubLogs" type="outline">清空日志</a-button>
                                </div>
                            </div>

                            <div class="mqtt-pub-log-container custom-scrollbar" style="height: 250px; overflow-y: auto; border: 1px solid #eee; padding: 15px; border-radius: 8px; width: 96%; margin: 0 auto; box-shadow: inset 0 0 5px rgba(0,0,0,0.05);">
                                <div v-for="log in mqtt_pub_logs" :key="log.id" class="mqtt-log-item" :class="`mqtt-log-${log.type}`">
                                    <span class="mqtt-log-time">[{{ log.timestamp }}]</span>
                                    <span class="mqtt-log-type">
                                        <a-tag v-if="log.type === 'success'" color="green">成功</a-tag>
                                        <a-tag v-else-if="log.type === 'error'" color="red">错误</a-tag>
                                        <a-tag v-else-if="log.type === 'sent'" color="blue">发送</a-tag>
                                        <a-tag v-else-if="log.type === 'warning'" color="orange">警告</a-tag>
                                        <a-tag v-else color="gray">信息</a-tag>
                                    </span>
                                    <span class="mqtt-log-message">{{ log.message }}</span>
                                </div>
                                <div v-if="mqtt_pub_logs.length === 0" class="mqtt-log-empty">
                                    暂无日志记录
                                </div>
                            </div>
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't7-5'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="子网掩码计算器" @back="switchToMenu"
                    subtitle="IP地址与子网划分工具">
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
                        <!-- IP地址和子网掩码输入区 -->
                        <a-card title="网络地址设置" style="margin-bottom: 15px;">
                            <div style="display: flex; align-items: center; margin-bottom: 15px;">
                                <span style="width: 130px;">IP地址：</span>
                                <a-input v-model="t7_5_ipAddress" placeholder="如：192.168.1.1" style="flex: 1; margin-right: 15px;" />
                            </div>
                            <div style="display: flex; align-items: center; margin-bottom: 15px;">
                                <span style="width: 130px;">子网掩码：</span>
                                <a-input v-model="t7_5_subnetMask" placeholder="如：255.255.255.0" style="flex: 1; margin-right: 15px;" />
                            </div>
                            <div style="display: flex; align-items: center; margin-bottom: 15px;">
                                <span style="width: 130px;">CIDR表示法：</span>
                                <div style="display: flex; align-items: center; flex: 1;">
                                    <a-input-number v-model="t7_5_cidrNotation" :min="0" :max="32" placeholder="24" style="width: 120px;" />
                                    <span style="margin-left: 5px;">/</span>
                                </div>
                            </div>
                            <div style="display: flex; justify-content: center; margin-top: 15px;">
                                <a-button type="primary" @click="calculateSubnetInfo">计算</a-button>
                            </div>
                        </a-card>

                        <!-- 计算结果展示区 -->
                        <a-card title="网络信息" style="margin-bottom: 15px;">
                            <a-descriptions :column="1" bordered>
                                <a-descriptions-item label="IP地址">{{ t7_5_ipAddress }}</a-descriptions-item>
                                <a-descriptions-item label="子网掩码">{{ t7_5_subnetMask }}</a-descriptions-item>
                                <a-descriptions-item label="CIDR表示">{{ t7_5_cidrNotation ? '/' + t7_5_cidrNotation : '' }}</a-descriptions-item>
                                <a-descriptions-item label="网络地址">{{ t7_5_networkAddress }}</a-descriptions-item>
                                <a-descriptions-item label="广播地址">{{ t7_5_broadcastAddress }}</a-descriptions-item>
                                <a-descriptions-item label="可用IP范围">{{ t7_5_firstUsableIp }} - {{ t7_5_lastUsableIp }}</a-descriptions-item>
                                <a-descriptions-item label="总主机数">{{ t7_5_totalHosts }}</a-descriptions-item>
                                <a-descriptions-item label="可用主机数">{{ t7_5_usableHosts }}</a-descriptions-item>
                            </a-descriptions>
                        </a-card>

                        <!-- 子网掩码表 -->
                        <a-card title="常用子网掩码参考" style="margin-bottom: 15px;">
                            <a-table :columns="[
                                { title: 'CIDR', dataIndex: 'cidr' },
                                { title: '子网掩码', dataIndex: 'mask' },
                                { title: '可用IP数量', dataIndex: 'hosts' }
                            ]" :data="[
                                { cidr: '/24', mask: '255.255.255.0', hosts: '254' },
                                { cidr: '/25', mask: '255.255.255.128', hosts: '126' },
                                { cidr: '/26', mask: '255.255.255.192', hosts: '62' },
                                { cidr: '/27', mask: '255.255.255.224', hosts: '30' },
                                { cidr: '/28', mask: '255.255.255.240', hosts: '14' },
                                { cidr: '/29', mask: '255.255.255.248', hosts: '6' },
                                { cidr: '/30', mask: '255.255.255.252', hosts: '2' },
                                { cidr: '/16', mask: '255.255.0.0', hosts: '65,534' },
                                { cidr: '/8', mask: '255.0.0.0', hosts: '16,777,214' }
                            ]" :pagination="false" :scroll="{ y: 240 }" />
                        </a-card>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-10'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="Android Manifest权限大全" @back="switchToMenu"
                    subtitle="Android权限对照表">
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
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden; max-width: 100%;">
                    <a-col :span="24">
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                这个工具提供了常用的Android权限列表，包含权限名称、描述、类别和保护级别等信息。您可以直接复制需要的权限到项目中使用。
                            </a-alert>
                        </div>

                        <div style="margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
                            <a-input-search
                                v-model="t3_10_search"
                                placeholder="搜索权限名称或描述"
                                style="width: 300px;"
                                allow-clear
                            />
                            <a-radio-group v-model="t3_10_categoryFilter" type="button">
                                <a-radio value="all">全部</a-radio>
                                <a-radio value="network">网络</a-radio>
                                <a-radio value="storage">存储</a-radio>
                                <a-radio value="location">位置</a-radio>
                                <a-radio value="hardware">硬件</a-radio>
                                <a-radio value="system">系统</a-radio>
                            </a-radio-group>
                        </div>

                        <a-table
                            :columns="[
                                { title: '权限名', dataIndex: 'name', width: 320 },
                                { title: '描述', dataIndex: 'description' },
                                { title: '保护级别', dataIndex: 'protection', width: 130 }
                            ]"
                            :data="filterAndroidPermissions()"
                            :bordered="false"
                            :pagination="{ pageSize: 10 }"
                            :scroll="{ x: '100%' }"
                            row-key="name"
                            :row-class="() => 'permission-table-row'"
                        >
                            <template #name="{ record }">
                                <div style="display: flex; align-items: center;">
                                    <span style="flex: 1; overflow: hidden; text-overflow: ellipsis;">{{ record.name }}</span>
                                    <a-button 
                                        type="text" 
                                        size="mini" 
                                        @click="copyAndroidPermission(record.name)" 
                                        style="margin-left: 4px; padding: 0 4px;"
                                    >
                                        <template #icon><icon-copy /></template>
                                    </a-button>
                                </div>
                                     </template>
                            <template #protection="{ record }">
                                <a-tag 
                                    :color="record.protection === 'dangerous' ? 'red' : 'green'"
                                    style="min-width: 80px; text-align: center; padding: 0 8px;"
                                >
                                    {{ record.protection === 'dangerous' ? '危险权限' : '普通权限' }}
                                </a-tag>
                             </template>
                         </a-table>

                        <div style="margin-top: 20px;">
                            <a-collapse style="max-width: 100%;">
                                <a-collapse-item header="Android权限保护级别说明" key="1">
                                    <div style="padding: 10px;">
                                        <h3>权限保护级别:</h3>
                                        <p><strong>普通权限 (normal)</strong>: 低风险权限，在安装时自动授予，无需用户确认。</p>
                                        <p><strong>危险权限 (dangerous)</strong>: 高风险权限，需要在运行时明确请求用户授权。</p>
                                        <p><strong>签名权限 (signature)</strong>: 只有当应用使用与声明该权限的应用相同的证书签名时才会被授予。</p>
                                        <p><strong>特权权限 (privileged)</strong>: 只授予系统应用或与系统映像相同的证书签名的应用。</p>
                                    </div>
                                </a-collapse-item>
                                <a-collapse-item header="权限的请求方式" key="2">
                                    <div style="padding: 10px;">
                                        <h3>在AndroidManifest.xml中声明权限:</h3>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;"><code>&lt;manifest ...&gt;
    &lt;uses-permission android:name="android.permission.INTERNET" /&gt;
    &lt;uses-permission android:name="android.permission.CAMERA" /&gt;
    &lt;application ...&gt;
        ...
    &lt;/application&gt;
&lt;/manifest&gt;</code></pre>

                                        <h3>危险权限的运行时请求 (Android 6.0+):</h3>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;"><code>// 检查权限
if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
        != PackageManager.PERMISSION_GRANTED) {
    // 请求权限
    ActivityCompat.requestPermissions(this,
            new String[]{Manifest.permission.CAMERA},
            MY_PERMISSIONS_REQUEST_CAMERA);
}</code></pre>
                                    </div>
                                </a-collapse-item>
                            </a-collapse>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-9'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="htaccess转nginx" @back="switchToMenu"
                    subtitle="转换htaccess规则到nginx配置">
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
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden; max-width: 100%;">
                    <a-col :span="24">
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                这个工具可以将Apache的.htaccess规则转换为Nginx配置格式。目前支持基本的重写规则、重定向和文件设置。
                            </a-alert>
                        </div>

                        <div style="margin-bottom: 16px; text-align: right;margin-right: 8px;">
                            <a-button type="outline" @click="load_t3_9_example" style="margin-right: 8px;">
                                加载示例
                            </a-button>
                            <a-button type="outline" @click="clear_t3_9" style="margin-right: 8px;">
                                清空
                            </a-button>
                            <a-button type="primary" @click="convertHtaccessToNginx">
                                转换
                            </a-button>
                        </div>

                        <a-row :gutter="16" style="max-width: 100%; margin: 0;">
                            <a-col :span="12" style="padding: 0 8px;">
                                <div style="margin-bottom: 8px;">
                                    <strong>htaccess规则 (输入)</strong>
                                </div>
                                <a-textarea
                                    v-model="t3_9_input"
                                    placeholder="请输入.htaccess规则内容"
                                    :auto-size="{ minRows: 20, maxRows: 20 }"
                                    style="width: 100%;"
                                />
                            </a-col>
                            <a-col :span="12" style="padding: 0 8px;">
                                <div style="margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center;">
                                    <strong>nginx配置 (输出)</strong>
                                    <a-button v-if="t3_9_output" size="small" @click="copy_t3_9_result">
                                        复制结果
                                    </a-button>
                                </div>
                                <a-textarea
                                    v-model="t3_9_output"
                                    placeholder="转换后的nginx配置将显示在这里"
                                    :auto-size="{ minRows: 20, maxRows: 20 }"
                                    style="width: 100%;"
                                    readonly
                                />
                                <a-alert
                                    v-if="t3_9_error"
                                    type="error"
                                    style="margin-top: 8px;"
                                    show-icon
                                >
                                    {{ t3_9_error }}
                                </a-alert>
                            </a-col>
                        </a-row>

                        <div style="margin-top: 20px; max-width: 100%;">
                            <a-collapse style="max-width: 100%;">
                                <a-collapse-item header="htaccess与nginx配置对照参考" key="1">
                                    <a-table
                                        :scroll="{ x: '100%' }"
                                        :columns="[
                                            { title: 'Apache (.htaccess)', dataIndex: 'apache', width: '50%' },
                                            { title: 'Nginx 配置', dataIndex: 'nginx' }
                                        ]"
                                        :data="[
                                            { 
                                                apache: 'RewriteEngine On', 
                                                nginx: '# Nginx默认已启用重写功能，无需显式配置' 
                                            },
                                            { 
                                                apache: 'RewriteBase /path', 
                                                nginx: '# Nginx不需要RewriteBase，直接在location块中定义路径' 
                                            },
                                            { 
                                                apache: 'RewriteRule ^/old$ /new [R=301,L]', 
                                                nginx: 'rewrite ^/old$ /new permanent;' 
                                            },
                                            { 
                                                apache: 'RewriteCond %{REQUEST_FILENAME} !-f\nRewriteCond %{REQUEST_FILENAME} !-d\nRewriteRule ^(.*)$ index.php?/$1 [L]', 
                                                nginx: 'location / {\n    try_files $uri $uri/ /index.php?$args;\n}' 
                                            },
                                            { 
                                                apache: 'ErrorDocument 404 /404.html', 
                                                nginx: 'error_page 404 /404.html;' 
                                            },
                                            { 
                                                apache: 'DirectoryIndex index.php index.html', 
                                                nginx: 'index index.php index.html;' 
                                            },
                                            { 
                                                apache: 'Redirect 301 /oldpage.html /newpage.html', 
                                                nginx: 'location /oldpage.html {\n    return 301 /newpage.html;\n}' 
                                            }
                                        ]"
                                        :bordered="false"
                                        :pagination="false"
                                    />
                                </a-collapse-item>
                                <a-collapse-item header="重写规则标志对照表" key="2">
                                    <a-table
                                        :scroll="{ x: '100%' }"
                                        :columns="[
                                            { title: 'Apache标志', dataIndex: 'apache', width: '30%' },
                                            { title: 'Nginx等效项', dataIndex: 'nginx', width: '30%' },
                                            { title: '说明', dataIndex: 'description' }
                                        ]"
                                        :data="[
                                            { 
                                                apache: '[L]', 
                                                nginx: 'last', 
                                                description: '停止处理后续规则' 
                                            },
                                            { 
                                                apache: '[R=301]', 
                                                nginx: 'permanent', 
                                                description: '301永久重定向' 
                                            },
                                            { 
                                                apache: '[R] 或 [R=302]', 
                                                nginx: 'redirect', 
                                                description: '302临时重定向' 
                                            },
                                            { 
                                                apache: '[F]', 
                                                nginx: 'return 403', 
                                                description: '返回403禁止访问' 
                                            },
                                            { 
                                                apache: '[G]', 
                                                nginx: 'return 410', 
                                                description: '返回410资源永久删除' 
                                            },
                                            { 
                                                apache: '[NC]', 
                                                nginx: '~*', 
                                                description: '不区分大小写匹配' 
                                            }
                                        ]"
                                        :bordered="false"
                                        :pagination="false"
                                    />
                                </a-collapse-item>
                            </a-collapse>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-13'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="HTML特殊字符转义" @back="switchToMenu"
                    subtitle="HTML字符编解码">
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
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden; max-width: 100%;">
                    <a-col :span="24">
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                将HTML文本中的特殊字符进行编码或解码，避免在HTML页面中产生歧义。常用于防止XSS攻击和确保HTML正确显示。
                            </a-alert>
                        </div>

                        <a-radio-group v-model="t3_13_direction" type="button" style="margin-bottom: 16px;">
                            <a-radio value="encode">编码 (字符 → 实体)</a-radio>
                            <a-radio value="decode">解码 (实体 → 字符)</a-radio>
                        </a-radio-group>

                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <span style="font-weight: bold;">{{ t3_13_direction === 'encode' ? '输入文本' : 'HTML实体文本' }}</span>
                                    <div>
                                        <a-button size="small" @click="clearHtmlSpecialChars" style="margin-right: 8px;">
                                            清空
                                        </a-button>
                                    </div>
                                </div>
                                <a-textarea
                                    v-model="t3_13_input"
                                    :placeholder="t3_13_direction === 'encode' ? '请输入需要编码的文本' : '请输入需要解码的HTML实体文本'"
                                    :auto-size="{ minRows: 6, maxRows: 6 }"
                                    style="width: 100%;"
                                />
                            </div>

                            <div style="display: flex; justify-content: center;">
                                <a-button type="primary" @click="processHtmlSpecialChars">
                                    {{ t3_13_direction === 'encode' ? '编码' : '解码' }}
                                </a-button>
                            </div>

                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <span style="font-weight: bold;">{{ t3_13_direction === 'encode' ? 'HTML实体结果' : '解码结果' }}</span>
                                    <a-button size="small" @click="copyHtmlSpecialCharsResult" :disabled="!t3_13_output">
                                        复制结果
                                    </a-button>
                                </div>
                                <a-textarea
                                    v-model="t3_13_output"
                                    :placeholder="t3_13_direction === 'encode' ? '编码后的HTML实体将显示在这里' : '解码后的文本将显示在这里'"
                                    :auto-size="{ minRows: 6, maxRows: 6 }"
                                    style="width: 100%;"
                                    readonly
                                />
                            </div>
                        </div>

                        <div style="margin-top: 20px;">
                            <a-collapse style="max-width: 100%;">
                                <a-collapse-item header="常用HTML特殊字符参考表" key="1">
                                    <a-table
                                        :columns="[
                                            { title: '字符', dataIndex: 'char', width: 80 },
                                            { title: '实体名称', dataIndex: 'entity', width: 150 },
                                            { title: '数字编码', dataIndex: 'numeric', width: 150 },
                                            { title: '描述', dataIndex: 'description' }
                                        ]"
                                        :data="htmlSpecialChars"
                                        :bordered="false"
                                        :pagination="{ pageSize: 8 }"
                                        :scroll="{ x: '100%' }"
                                        row-key="entity"
                                        :row-class="() => 'html-char-table-row'"
                                    >
                                        <template #char="{ record }">
                                            <span class="html-char-display">{{ record.char }}</span>
                                     </template>
                                        <template #entity="{ record }">
                                            <div style="display: flex; align-items: center;">
                                                <span style="flex: 1; font-family: monospace;">{{ record.entity }}</span>
                                                <a-button 
                                                    type="text" 
                                                    size="mini" 
                                                    @click="copyContentType(record.entity)" 
                                                    style="padding: 0 4px;"
                                                >
                                                    <template #icon><icon-copy /></template>
                                                </a-button>
                                            </div>
                                        </template>
                                        <template #numeric="{ record }">
                                            <span style="font-family: monospace;">{{ record.numeric }}</span>
                             </template>
                         </a-table>
                                </a-collapse-item>
                                <a-collapse-item header="HTML特殊字符转义的使用场景" key="2">
                                    <div style="padding: 10px;">
                                        <h4>1. 安全性 - 防止XSS攻击</h4>
                                        <p>当用户输入内容需要显示在网页上时，对特殊字符进行编码可以防止恶意代码注入，避免XSS攻击。</p>
                                        
                                        <h4>2. 正确显示HTML标记</h4>
                                        <p>当需要在网页中显示HTML标记本身而不是让浏览器解析它们时，需要对特殊字符进行编码。</p>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;"><code>// 未编码
&lt;p&gt;这是一个段落&lt;/p&gt;
// 显示效果：这是一个段落

// 编码后
&amp;lt;p&amp;gt;这是一个段落&amp;lt;/p&amp;gt;
// 显示效果：&lt;p&gt;这是一个段落&lt;/p&gt;</code></pre>
                                        
                                        <h4>3. 处理XML/HTML数据</h4>
                                        <p>在处理XML或HTML数据时，需要确保特殊字符不会干扰文档结构。</p>
                                    </div>
                                </a-collapse-item>
                            </a-collapse>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't3-12'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="Content-Type对照表" @back="switchToMenu"
                    subtitle="MIME类型参考大全">
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
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden; max-width: 100%;">
                    <a-col :span="24">
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                Content-Type指定了HTTP消息中的多媒体类型信息，也称为MIME类型。本工具提供常见MIME类型对照参考。
                            </a-alert>
                        </div>

                        <div style="margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
                            <a-input-search
                                v-model="t3_12_search"
                                placeholder="搜索类型、扩展名或描述"
                                style="width: 300px;"
                                allow-clear
                            />
                            <a-radio-group v-model="t3_12_categoryFilter" type="button">
                                <a-radio value="all">全部</a-radio>
                                <a-radio value="text">文本</a-radio>
                                <a-radio value="image">图像</a-radio>
                                <a-radio value="audio">音频</a-radio>
                                <a-radio value="video">视频</a-radio>
                                <a-radio value="application">应用</a-radio>
                            </a-radio-group>
                        </div>

                        <a-table
                            :columns="[
                                { title: 'Content-Type', dataIndex: 'type', width: 300 },
                                { title: '文件扩展名', dataIndex: 'extension', width: 120 },
                                { title: '描述', dataIndex: 'description' },
                                { title: '类别', dataIndex: 'category', width: 100 }
                            ]"
                            :data="filterContentTypes()"
                            :bordered="false"
                            :pagination="{ pageSize: 10 }"
                            :scroll="{ x: '100%' }"
                            row-key="type"
                            :row-class="() => 'content-type-table-row'"
                        >
                            <template #type="{ record }">
                                <div style="display: flex; align-items: center;">
                                    <span style="flex: 1; overflow: hidden; text-overflow: ellipsis;">{{ record.type }}</span>
                                    <a-button 
                                        type="text" 
                                        size="mini" 
                                        @click="copyContentType(record.type)" 
                                        style="padding: 0 4px;"
                                    >
                                        <template #icon><icon-copy /></template>
                                    </a-button>
                                </div>
                            </template>
                            <template #category="{ record }">
                                <a-tag :color="
                                    record.category === 'text' ? 'blue' : 
                                    record.category === 'image' ? 'green' : 
                                    record.category === 'audio' ? 'gold' : 
                                    record.category === 'video' ? 'magenta' : 
                                    record.category === 'application' ? 'purple' : 
                                    record.category === 'multipart' ? 'orange' :
                                    record.category === 'font' ? 'cyan' : 'default'
                                " style="text-align: center; min-width: 60px;">
                                    {{ 
                                        record.category === 'text' ? '文本' : 
                                        record.category === 'image' ? '图像' : 
                                        record.category === 'audio' ? '音频' : 
                                        record.category === 'video' ? '视频' : 
                                        record.category === 'application' ? '应用' : 
                                        record.category === 'multipart' ? '多部分' :
                                        record.category === 'font' ? '字体' : record.category
                                    }}
                                </a-tag>
                            </template>
                        </a-table>

                        <div style="margin-top: 20px;">
                            <a-collapse style="max-width: 100%;">
                                <a-collapse-item header="Content-Type使用说明" key="1">
                                    <div style="padding: 10px;">
                                        <h3>Content-Type的基本用法:</h3>
                                        <p>在HTTP头部，Content-Type指定了消息体的媒体类型，格式为：</p>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;">Content-Type: [媒体类型]; [可选参数]</pre>
                                        <p>例如：</p>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;">Content-Type: text/html; charset=UTF-8</pre>
                                        <p>其中，<code>text/html</code>是媒体类型，<code>charset=UTF-8</code>是可选参数，指定了字符编码。</p>
                                    </div>
                                </a-collapse-item>
                                <a-collapse-item header="常见Content-Type示例" key="2">
                                    <div style="padding: 10px;">
                                        <h4>在HTML表单中使用：</h4>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;"><code>&lt;form action="/upload" method="post" enctype="multipart/form-data"&gt;
  &lt;input type="file" name="fileUpload"&gt;
  &lt;input type="submit" value="上传"&gt;
&lt;/form&gt;</code></pre>
                                        
                                        <h4>在AJAX请求中使用：</h4>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;"><code>const xhr = new XMLHttpRequest();
xhr.open('POST', '/api/data');
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.send(JSON.stringify({ name: 'example' }));</code></pre>
                                        
                                        <h4>在Fetch API中使用：</h4>
                                        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;"><code>fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ name: 'example' })
});</code></pre>
                                    </div>
                                </a-collapse-item>
                            </a-collapse>
                        </div>
                    </a-col>
                </a-row>
            </div>
                                     </div>

        <div v-show="tooltype == 't3-11'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="HTTP状态码" @back="switchToMenu"
                    subtitle="HTTP状态码大全">
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
                <a-row class="page-content custom-scrollbar" style="overflow-x: hidden; max-width: 100%;">
                    <a-col :span="24">
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                HTTP状态码是用于表示HTTP请求处理结果的三位数字代码。本工具提供了常见HTTP状态码的查询和参考。
                            </a-alert>
                        </div>

                        <div style="margin-bottom: 16px; display: flex; justify-content: space-between; align-items: center;">
                            <a-input-search
                                v-model="t3_11_search"
                                placeholder="搜索状态码、名称或描述"
                                style="width: 300px;"
                                allow-clear
                            />
                            <a-radio-group v-model="t3_11_categoryFilter" type="button">
                                <a-radio value="all">全部</a-radio>
                                <a-radio value="1xx">1xx</a-radio>
                                <a-radio value="2xx">2xx</a-radio>
                                <a-radio value="3xx">3xx</a-radio>
                                <a-radio value="4xx">4xx</a-radio>
                                <a-radio value="5xx">5xx</a-radio>
                            </a-radio-group>
                        </div>

                        <a-table
                            :columns="[
                                { title: '状态码', dataIndex: 'code', width: 100 },
                                { title: '名称', dataIndex: 'name', width: 200 },
                                { title: '描述', dataIndex: 'description' },
                                { title: '类别', dataIndex: 'category', width: 100 }
                            ]"
                            :data="filterHttpStatusCodes()"
                            :bordered="false"
                            :pagination="{ pageSize: 10 }"
                            :scroll="{ x: '100%' }"
                            row-key="code"
                            :row-class="() => 'status-code-table-row'"
                        >
                            <template #code="{ record }">
                                <div style="display: flex; align-items: center;">
                                    <a-button 
                                        type="text" 
                                        size="mini" 
                                        @click="copyHttpStatusCode(record.code)" 
                                        style="padding: 0 4px; font-weight: bold;"
                                    >
                                        {{ record.code }}
                                    </a-button>
                                </div>
                            </template>
                            <template #category="{ record }">
                                <a-tag :color="
                                    record.category === '1xx' ? 'blue' : 
                                    record.category === '2xx' ? 'green' : 
                                    record.category === '3xx' ? 'orange' : 
                                    record.category === '4xx' ? 'red' : 
                                    record.category === '5xx' ? 'purple' : 'default'
                                " style="text-align: center; min-width: 60px;">
                                    {{ record.category }}
                                </a-tag>
                            </template>
                        </a-table>

                        <div style="margin-top: 20px;">
                            <a-collapse style="max-width: 100%;">
                                <a-collapse-item header="HTTP状态码类别说明" key="1">
                                    <div style="padding: 10px;">
                                        <h3>HTTP状态码分类:</h3>
                                        <p><strong>1xx 信息响应</strong>: 请求已被接收，需要继续处理。这类响应是临时响应，只包含状态行和某些可选的响应头信息，并以空行结束。</p>
                                        <p><strong>2xx 成功响应</strong>: 请求已成功被服务器接收、理解并接受。</p>
                                        <p><strong>3xx 重定向</strong>: 需要后续操作才能完成这一请求。通常，这些状态码用来重定向。</p>
                                        <p><strong>4xx 客户端错误</strong>: 请求包含语法错误或者无法完成请求。这些状态码代表了客户端看起来可能发生了错误。</p>
                                        <p><strong>5xx 服务器错误</strong>: 服务器在处理请求的过程中发生了错误。这些状态码代表了服务器在处理请求的过程中有错误或者异常状态发生。</p>
                                    </div>
                                </a-collapse-item>
                                <a-collapse-item header="最常用的HTTP状态码" key="2">
                                    <div style="padding: 10px;">
                                        <ul style="padding-left: 20px;">
                                            <li><strong>200 OK</strong>: 请求成功。一般用于GET与POST请求</li>
                                            <li><strong>201 Created</strong>: 请求已完成，并且已创建了新资源</li>
                                            <li><strong>301 Moved Permanently</strong>: 被请求的资源已永久移动到新位置</li>
                                            <li><strong>302 Found</strong>: 请求的资源现在临时从不同的URI响应请求</li>
                                            <li><strong>304 Not Modified</strong>: 资源未被修改，可使用缓存</li>
                                            <li><strong>400 Bad Request</strong>: 由于语法无效，服务器无法理解该请求</li>
                                            <li><strong>401 Unauthorized</strong>: 需要身份验证</li>
                                            <li><strong>403 Forbidden</strong>: 服务器理解请求但拒绝执行</li>
                                            <li><strong>404 Not Found</strong>: 请求的资源未在服务器上发现</li>
                                            <li><strong>500 Internal Server Error</strong>: 服务器遇到了不知道如何处理的情况</li>
                                            <li><strong>502 Bad Gateway</strong>: 网关或代理服务器从上游服务器收到无效响应</li>
                                            <li><strong>503 Service Unavailable</strong>: 服务器暂时不可用</li>
                                        </ul>
                                    </div>
                                </a-collapse-item>
                            </a-collapse>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

                <!-- t8-1 寄存器寻址范围 -->
        <div v-show="tooltype == 't8-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="寄存器寻址范围" @back="switchToMenu"
                    subtitle="显示不同位数寄存器的寻址范围">
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
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                <div>
                                    <p style="margin: 0 0 10px 0;"><strong>寄存器寻址范围说明</strong></p>
                                    <p style="margin: 0;">寄存器的位数决定了可以直接访问的内存地址范围，也影响了系统的整体性能和兼容性。随着技术发展，从早期的8位单片机到现代的64位处理器，寻址能力不断提升。</p>
                                </div>
                            </a-alert>
                        </div>

                        <a-table 
                            :columns="[
                                { title: '通用寄存器的宽度', dataIndex: 'width', width: 180 },
                                { title: '寻址范围', dataIndex: 'range', width: 220 },
                                { title: '最大值', dataIndex: 'maxValue', width: 200 },
                                { title: '应用场景', dataIndex: 'applications' }
                            ]"
                            :data="t8_1_registerData"
                            :pagination="false"
                            :bordered="true"
                            style="margin-bottom: 20px;"
                        />

                        <div style="margin-top: 20px;">
                            <a-collapse :default-active-key="['1']">
                                <a-collapse-item header="技术细节说明" key="1">
                                    <div class="register-details">
                                        <div class="detail-section">
                                            <h4 class="section-title">💾 寻址能力对比</h4>
                                            <div class="info-grid">
                                                <div class="info-item">
                                                    <span class="bit-label">8位</span>
                                                    <span class="description">256个位置 • 简单控制</span>
                                                </div>
                                                <div class="info-item">
                                                    <span class="bit-label">16位</span>
                                                    <span class="description">64KB空间 • 嵌入式系统</span>
                                                </div>
                                                <div class="info-item">
                                                    <span class="bit-label">32位</span>
                                                    <span class="description">4GB空间 • 桌面应用</span>
                                                </div>
                                                <div class="info-item">
                                                    <span class="bit-label">64位</span>
                                                    <span class="description">16EB空间 • 高性能计算</span>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="detail-section">
                                            <h4 class="section-title">⏳ 发展历程</h4>
                                            <div class="timeline">
                                                <div class="timeline-item">
                                                    <span class="year">1970s</span>
                                                    <span class="event">8位处理器兴起 (Intel 8008/8080)</span>
                                                </div>
                                                <div class="timeline-item">
                                                    <span class="year">1980s</span>
                                                    <span class="event">16位处理器普及 (Intel 8086/8088)</span>
                                                </div>
                                                <div class="timeline-item">
                                                    <span class="year">1990s</span>
                                                    <span class="event">32位成为主流 (Intel 80386)</span>
                                                </div>
                                                <div class="timeline-item">
                                                    <span class="year">2000s+</span>
                                                    <span class="event">64位占据主导地位</span>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="detail-section">
                                            <h4 class="section-title">💡 实际应用要点</h4>
                                            <div class="tips-container">
                                                <div class="tip-item">实际可用内存小于理论最大值</div>
                                                <div class="tip-item">64位系统通常使用48位地址空间</div>
                                                <div class="tip-item">需平衡性能、功耗和成本考虑</div>
                                            </div>
                                        </div>
                                    </div>
                                </a-collapse-item>
                            </a-collapse>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <!-- t8-2 电阻阻值计算 -->
        <div v-show="tooltype == 't8-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="电阻阻值计算" @back="switchToMenu"
                    subtitle="根据电阻上的彩色条纹计算电阻值">
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
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                <div>
                                    <p style="margin: 0 0 10px 0;"><strong>电阻色环计算器使用说明</strong></p>
                                    <p style="margin: 0;">通过识别电阻上的彩色环带，可以精确确定电阻的阻值和允许误差范围。不同的色环数量对应不同的电阻精确度，常见的有3环、4环、5环和6环电阻。</p>
                                </div>
                            </a-alert>
                        </div>

                        <a-card title="电阻阻值计算器" style="margin-bottom: 20px;">
                            <a-space direction="vertical" fill size="large">
                                <a-radio-group v-model="t8_2_bandCount" type="button" @change="t8_2_updateBandCount">
                                    <a-radio :value="3">3色环</a-radio>
                                    <a-radio :value="4">4色环</a-radio>
                                    <a-radio :value="5">5色环</a-radio>
                                    <a-radio :value="6">6色环</a-radio>
                                </a-radio-group>

                                <!-- 电阻可视化 -->
                                <div class="resistor-display">
                                    <div class="resistor-body">
                                        <div class="resistor-lead left-lead"></div>
                                        <!-- 动态渲染电阻色环 -->
                                        <div v-for="(colorIndex, index) in t8_2_bandIndices" :key="index" 
                                            class="resistor-band" 
                                            :style="{
                                                backgroundColor: t8_2_colors[colorIndex].color,
                                                color: t8_2_colors[colorIndex].textColor,
                                                left: `${20 + index * (60 / t8_2_bandCount)}%`
                                            }">
                                        </div>
                                        <div class="resistor-lead right-lead"></div>
                                    </div>
                                </div>
                                
                                <!-- 色环选择器 -->
                                <a-form layout="vertical">
                                    <a-row :gutter="16" justify="space-between">
                                        <a-col 
                                            v-for="(colorIndex, index) in t8_2_bandIndices" 
                                            :key="index" 
                                            :span="t8_2_bandCount === 3 ? 8 : t8_2_bandCount === 4 ? 6 : t8_2_bandCount === 5 ? 4 : 4"
                                            :style="{ 
                                                minWidth: t8_2_bandCount === 6 ? '180px' : '150px',
                                                flex: t8_2_bandCount === 6 ? '1 1 180px' : '1 1 150px'
                                            }"
                                        >
                                            <a-form-item :label="`第${index + 1}环`">
                                                <a-select 
                                                    :model-value="colorIndex"
                                                    @change="(value: number) => t8_2_updateBandColor(index, value)"
                                                    style="width: 100%;"
                                                >
                                                    <a-option v-for="(color, cIndex) in t8_2_colors" :key="cIndex" :value="cIndex">
                                                        <div style="display: flex; align-items: center;">
                                                            <div style="width: 16px; height: 16px; margin-right: 8px; border-radius: 50%; border: 1px solid #ccc;" 
                                                                :style="{ backgroundColor: color.color }">
                                                            </div>
                                                            {{ color.name }}
                                                        </div>
                                                    </a-option>
                                                </a-select>
                                            </a-form-item>
                                        </a-col>
                                    </a-row>
                                </a-form>

                                <!-- 计算结果显示 -->
                                <a-result status="success" :title="t8_2_resistanceValue">
                                    <template #subtitle>
                                        <div>{{ t8_2_detailedCalculation }}</div>
                                    </template>
                                </a-result>
                            </a-space>
                        </a-card>

                        <a-collapse :default-active-key="['1']">
                            <a-collapse-item header="电阻色环说明" key="1">
                                <div>
                                    <h4>颜色对应数值</h4>
                                    <a-table 
                                        :columns="[
                                            { title: '颜色', dataIndex: 'name' },
                                            { 
                                                title: '值', 
                                                dataIndex: 'value',
                                                render: ({ record }: any) => record.value !== null ? record.value : '-'
                                            },
                                            { 
                                                title: '倍数', 
                                                dataIndex: 'multiplier',
                                                render: ({ record }: any) => record.multiplier !== null ? record.multiplier : '-'
                                            },
                                            { 
                                                title: '误差(%)', 
                                                dataIndex: 'tolerance',
                                                render: ({ record }: any) => record.tolerance !== null ? `±${record.tolerance}%` : '-'
                                            }
                                        ]"
                                        :data="t8_2_colors"
                                        :pagination="false"
                                        :bordered="true"
                                        size="small"
                                    />
                                    
                                    <h4 style="margin-top: 20px;">不同环数电阻说明</h4>
                                    <a-descriptions bordered size="small" :column="1">
                                        <a-descriptions-item label="3色环">
                                            第1环: 第一位数值<br/>
                                            第2环: 第二位数值<br/>
                                            第3环: 倍率因子<br/>
                                            (误差固定为±20%)
                                        </a-descriptions-item>
                                        <a-descriptions-item label="4色环">
                                            第1环: 第一位数值<br/>
                                            第2环: 第二位数值<br/>
                                            第3环: 倍率因子<br/>
                                            第4环: 误差值
                                        </a-descriptions-item>
                                        <a-descriptions-item label="5色环">
                                            第1环: 第一位数值<br/>
                                            第2环: 第二位数值<br/>
                                            第3环: 第三位数值<br/>
                                            第4环: 倍率因子<br/>
                                            第5环: 误差值
                                        </a-descriptions-item>
                                        <a-descriptions-item label="6色环">
                                            第1环: 第一位数值<br/>
                                            第2环: 第二位数值<br/>
                                            第3环: 第三位数值<br/>
                                            第4环: 倍率因子<br/>
                                            第5环: 误差值<br/>
                                            第6环: 温度系数
                                        </a-descriptions-item>
                                    </a-descriptions>
                                </div>
                            </a-collapse-item>
                        </a-collapse>
                    </a-col>
                </a-row>
            </div>
        </div>

        <!-- t8-3 RISC-V指令集速查 -->
        <div v-show="tooltype == 't8-3'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="RISC-V指令集速查" @back="switchToMenu"
                    subtitle="RISC-V指令集模块参考手册">
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
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                <div>
                                    <p style="margin: 0 0 10px 0;"><strong>RISC-V指令集架构说明</strong></p>
                                    <p style="margin: 0;">RISC-V是一个开源的指令集架构（ISA），基于精简指令集计算（RISC）原则。它具有模块化设计，包含基本指令集和各种扩展指令集，可根据具体应用需求进行组合。</p>
                                </div>
                            </a-alert>
                        </div>

                        <a-card title="指令集搜索与过滤" style="margin-bottom: 20px;">
                            <a-space direction="vertical" size="large" fill>
                                <a-row :gutter="16">
                                    <a-col :span="12">
                                        <a-input v-model="t8_3_searchTerm" placeholder="搜索指令集名称或描述..." allow-clear>
                                            <template #prefix>
                                                <icon-search />
                                            </template>
                                        </a-input>
                                    </a-col>
                                    <a-col :span="12">
                                        <a-select v-model="t8_3_selectedType" placeholder="选择指令集类型" allow-clear>
                                            <a-option value="all">全部类型</a-option>
                                            <a-option value="基本指令集">基本指令集</a-option>
                                            <a-option value="扩展指令集">扩展指令集</a-option>
                                        </a-select>
                                    </a-col>
                                </a-row>
                            </a-space>
                        </a-card>

                        <a-card title="RISC-V指令集列表" style="margin-bottom: 20px;">
                            <a-table 
                                :columns="[
                                    { 
                                        title: '指令集名称', 
                                        dataIndex: 'name', 
                                        width: 120,
                                        render: ({ record }: any) => {
                                            const isBase = record.type === '基本指令集';
                                            return h('a-tag', { 
                                                color: isBase ? 'blue' : 'green' 
                                            }, record.name);
                                        }
                                    },
                                    { title: '类型', dataIndex: 'type', width: 120 },
                                    { title: '描述', dataIndex: 'description' }
                                ]"
                                :data="t8_3_filteredInstructions"
                                :pagination="{
                                    pageSize: 10,
                                    showSizeChanger: true,
                                    showQuickJumper: true,
                                    showTotal: (total: number) => `共 ${total} 条指令集`
                                }"
                                :bordered="true"
                                size="middle"
                            />
                        </a-card>

                        <a-collapse :default-active-key="['1', '2', '3']">
                            <a-collapse-item header="基本指令集详解" key="1">
                                <div class="risc-v-details">
                                    <div class="instruction-group">
                                        <h4>🔧 基本整数指令集</h4>
                                        <a-descriptions bordered size="small" :column="1">
                                            <a-descriptions-item label="RV32I">
                                                32位基本整数指令集，包含整数计算、逻辑运算、移位、比较、分支、跳转和访存指令。这是RISC-V的核心指令集。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="RV32E">
                                                RV32I的精简版本，寄存器数量从32个减少到16个，专为极小型嵌入式应用设计，可显著降低硬件成本。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="RV64I">
                                                64位整数指令集，在RV32I基础上扩展支持64位操作。提供更大的地址空间和数据宽度，向下兼容RV32I。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="RV128I">
                                                128位整数指令集，为未来高性能计算需求设计。目前主要用于研究和长远规划。
                                            </a-descriptions-item>
                                        </a-descriptions>
                                    </div>
                                </div>
                            </a-collapse-item>
                            
                            <a-collapse-item header="常用扩展指令集" key="2">
                                <div class="risc-v-details">
                                    <div class="instruction-group">
                                        <h4>⚡ 性能扩展</h4>
                                        <a-descriptions bordered size="small" :column="1">
                                            <a-descriptions-item label="M - 乘除法">
                                                提供整数乘法和除法指令，大幅提升数学运算性能。几乎所有实际应用都会包含此扩展。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="A - 原子操作">
                                                支持原子内存操作，是多核系统和并发编程的基础。包括原子交换、比较交换等指令。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="C - 压缩指令">
                                                将常用的32位指令压缩为16位，可减少程序大小20-30%，提高指令缓存效率。
                                            </a-descriptions-item>
                                        </a-descriptions>
                                        
                                        <h4>🔢 浮点扩展</h4>
                                        <a-descriptions bordered size="small" :column="1">
                                            <a-descriptions-item label="F - 单精度浮点">
                                                IEEE 754单精度（32位）浮点运算，包括加减乘除、比较、转换等操作。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="D - 双精度浮点">
                                                IEEE 754双精度（64位）浮点运算，在F的基础上增加更高精度的浮点支持。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="Q - 四精度浮点">
                                                IEEE 754四精度（128位）浮点运算，用于需要极高精度的科学计算应用。
                                            </a-descriptions-item>
                                        </a-descriptions>
                                    </div>
                                </div>
                            </a-collapse-item>
                            
                            <a-collapse-item header="系统级扩展" key="3">
                                <div class="risc-v-details">
                                    <div class="instruction-group">
                                        <h4>🏛️ 特权级扩展</h4>
                                        <a-descriptions bordered size="small" :column="1">
                                            <a-descriptions-item label="S - 监管者模式">
                                                支持操作系统内核运行的监管者特权级，包括虚拟内存管理、异常处理等系统功能。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="H - 虚拟化支持">
                                                提供硬件虚拟化支持，允许虚拟机监控器（Hypervisor）高效管理多个虚拟机。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="N - 用户级中断">
                                                允许用户态程序直接处理某些中断，可提高I/O密集型应用的性能。
                                            </a-descriptions-item>
                                        </a-descriptions>
                                        
                                        <h4>🚀 高性能扩展</h4>
                                        <a-descriptions bordered size="small" :column="1">
                                            <a-descriptions-item label="V - 向量处理">
                                                向量指令集，支持SIMD（单指令多数据）操作，大幅提升并行计算性能。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="B - 位操作">
                                                提供高效的位操作指令，包括位计数、位反转、位域提取等，常用于密码学和数据处理。
                                            </a-descriptions-item>
                                            <a-descriptions-item label="G - 通用组合">
                                                G = IMAFD的组合，代表一个包含基本整数、乘除法、原子操作、单双精度浮点的通用配置。
                                            </a-descriptions-item>
                                        </a-descriptions>
                                    </div>
                                </div>
                            </a-collapse-item>
                        </a-collapse>

                        <div style="margin-top: 20px;">
                            <a-alert type="success" show-icon>
                                <template #icon><icon-info-circle /></template>
                                <div>
                                    <p style="margin: 0 0 10px 0;"><strong>💡 选择建议</strong></p>
                                    <p style="margin: 0;">
                                        • <strong>嵌入式应用</strong>：RV32I + M + C（基础 + 乘除法 + 压缩）<br/>
                                        • <strong>通用应用</strong>：RV64G（64位通用组合，包含IMAFD）<br/>
                                        • <strong>高性能计算</strong>：RV64G + V（增加向量处理能力）<br/>
                                        • <strong>系统软件</strong>：RV64G + S + H（增加系统级支持）
                                    </p>
                                </div>
                            </a-alert>
                        </div>
                    </a-col>
                </a-row>
            </div>
        </div>

        <!-- t8-4 通用寄存器速查 -->
        <div v-show="tooltype == 't8-4'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="通用寄存器速查" @back="switchToMenu"
                    subtitle="各种芯片架构的通用寄存器信息">
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
                        <div style="margin-bottom: 20px;">
                            <a-alert type="info" show-icon>
                                <div>
                                    <p style="margin: 0 0 10px 0;"><strong>通用寄存器架构对比</strong></p>
                                    <p style="margin: 0;">不同处理器架构具有不同的寄存器组织方式，了解各种架构的寄存器特点有助于选择合适的处理器和优化程序性能。本工具汇总了常见芯片架构的寄存器信息。</p>
                                </div>
                            </a-alert>
                        </div>

                        <a-card title="芯片选择与搜索" style="margin-bottom: 20px;">
                            <a-space direction="vertical" size="large" fill>
                                <a-row :gutter="16">
                                    <a-col :span="8">
                                        <a-input v-model="t8_4_searchTerm" placeholder="搜索芯片系列、架构或应用..." allow-clear>
                                            <template #prefix>
                                                <icon-search />
                                            </template>
                                        </a-input>
                                    </a-col>
                                    <a-col :span="8">
                                        <a-select v-model="t8_4_categoryFilter" placeholder="选择架构分类" allow-clear>
                                            <a-option value="all">全部架构</a-option>
                                            <a-option value="ARM">ARM架构</a-option>
                                            <a-option value="x86">x86架构</a-option>
                                            <a-option value="RISC-V">RISC-V架构</a-option>
                                            <a-option value="MIPS">MIPS架构</a-option>
                                            <a-option value="8-bit">8位处理器</a-option>
                                            <a-option value="PIC">PIC架构</a-option>
                                            <a-option value="PowerPC">PowerPC架构</a-option>
                                            <a-option value="DSP">DSP处理器</a-option>
                                        </a-select>
                                    </a-col>
                                    <a-col :span="8">
                                        <a-select 
                                            v-model="t8_4_selectedChip" 
                                            placeholder="选择要查看的芯片" 
                                            allow-clear
                                            value-key="chipSeries"
                                        >
                                            <a-option v-for="chip in t8_4_filteredRegisters" :key="chip.chipSeries" :value="chip" :label="chip.chipSeries">
                                                <div style="display: flex; align-items: center; gap: 8px;">
                                                    <a-tag :color="(() => {
                                                        const colors: Record<string, string> = {
                                                            'ARM': 'blue',
                                                            'x86': 'green', 
                                                            'RISC-V': 'orange',
                                                            'MIPS': 'purple',
                                                            '8-bit': 'red',
                                                            'PIC': 'cyan',
                                                            'PowerPC': 'magenta',
                                                            'DSP': 'gold'
                                                        };
                                                        return colors[chip.category] || 'default';
                                                    })()" size="small">
                                                        {{ chip.category }}
                                                    </a-tag>
                                                    <span>{{ chip.chipSeries }}</span>
                                                </div>
                                            </a-option>
                                        </a-select>
                                    </a-col>
                                </a-row>
                            </a-space>
                        </a-card>

                        <!-- 芯片概览信息 -->
                        <a-card v-if="!t8_4_selectedChip" title="芯片架构概览" style="margin-bottom: 20px;">
                            <a-row :gutter="[16, 16]">
                                <a-col v-for="chip in t8_4_filteredRegisters" :key="chip.chipSeries" :span="8">
                                    <a-card 
                                        class="chip-overview-card" 
                                        size="small" 
                                        hoverable
                                        @click="t8_4_selectedChip = chip"
                                        style="cursor: pointer;"
                                    >
                                        <template #title>
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <a-tag :color="(() => {
                                                    const colors: Record<string, string> = {
                                                        'ARM': 'blue',
                                                        'x86': 'green', 
                                                        'RISC-V': 'orange',
                                                        'MIPS': 'purple',
                                                        '8-bit': 'red',
                                                        'PIC': 'cyan',
                                                        'PowerPC': 'magenta',
                                                        'DSP': 'gold'
                                                    };
                                                    return colors[chip.category] || 'default';
                                                })()" size="small">
                                                    {{ chip.category }}
                                                </a-tag>
                                                <span style="font-size: 13px;">{{ chip.chipSeries }}</span>
                                            </div>
                                        </template>
                                        <div style="font-size: 12px; line-height: 1.5;">
                                            <p style="margin: 0 0 4px 0;"><strong>架构：</strong>{{ chip.architecture }}</p>
                                            <p style="margin: 0 0 4px 0;"><strong>寄存器：</strong>{{ chip.registerCount }}个 × {{ chip.bitWidth }}位</p>
                                            <p style="margin: 0;"><strong>应用：</strong>{{ chip.applications }}</p>
                                        </div>
                                    </a-card>
                                </a-col>
                            </a-row>
                            <div v-if="t8_4_filteredRegisters.length === 0" style="text-align: center; color: #999; padding: 40px 0;">
                                <icon-search style="font-size: 48px; margin-bottom: 16px;" />
                                <p>未找到匹配的芯片架构</p>
                            </div>
                        </a-card>

                        <!-- 选中芯片的详细信息 -->
                        <a-card v-if="t8_4_selectedChip" style="margin-bottom: 20px;">
                            <template #title>
                                <div style="display: flex; align-items: center; justify-content: space-between;">
                                    <div style="display: flex; align-items: center; gap: 12px;">
                                        <a-tag :color="(() => {
                                            const colors: Record<string, string> = {
                                                'ARM': 'blue',
                                                'x86': 'green', 
                                                'RISC-V': 'orange',
                                                'MIPS': 'purple',
                                                '8-bit': 'red',
                                                'PIC': 'cyan',
                                                'PowerPC': 'magenta',
                                                'DSP': 'gold'
                                            };
                                            return colors[t8_4_selectedChip.category] || 'default';
                                        })()">
                                            {{ t8_4_selectedChip.category }}
                                        </a-tag>
                                        <span>{{ t8_4_selectedChip.chipSeries }} 寄存器详情</span>
                                    </div>
                                    <a-button type="text" @click="t8_4_selectedChip = null">
                                        <template #icon><icon-close /></template>
                                        返回概览
                                    </a-button>
                                </div>
                            </template>
                            
                            <a-descriptions bordered :column="2" style="margin-bottom: 20px;">
                                <a-descriptions-item label="芯片系列">{{ t8_4_selectedChip.chipSeries }}</a-descriptions-item>
                                <a-descriptions-item label="架构">{{ t8_4_selectedChip.architecture }}</a-descriptions-item>
                                <a-descriptions-item label="寄存器数量">{{ t8_4_selectedChip.registerCount }}个</a-descriptions-item>
                                <a-descriptions-item label="位宽">{{ t8_4_selectedChip.bitWidth }}位</a-descriptions-item>
                                <a-descriptions-item label="主要应用" :span="2">{{ t8_4_selectedChip.applications }}</a-descriptions-item>
                            </a-descriptions>

                            <!-- 基本寄存器信息 -->
                            <a-row :gutter="16" style="margin-bottom: 16px;">
                                <a-col :span="12">
                                    <a-card title="寄存器名称" size="small">
                                        <div style="font-family: monospace; line-height: 1.8; font-size: 13px;">
                                            {{ t8_4_selectedChip.registerNames }}
                                        </div>
                                    </a-card>
                                </a-col>
                                <a-col :span="12">
                                    <a-card title="特殊寄存器" size="small">
                                        <div style="line-height: 1.8; font-size: 13px;">
                                            {{ t8_4_selectedChip.specialRegisters }}
                                        </div>
                                    </a-card>
                                </a-col>
                            </a-row>

                            <!-- 详细寄存器信息（仅8086显示） -->
                            <div v-if="t8_4_selectedChip.detailedInfo">
                                <a-divider>详细寄存器说明</a-divider>
                                <a-row :gutter="16">
                                    <a-col v-if="t8_4_selectedChip.detailedInfo.generalPurpose" :span="12">
                                        <a-card title="🔧 通用寄存器" size="small" style="margin-bottom: 16px;">
                                            <div v-for="reg in t8_4_selectedChip.detailedInfo.generalPurpose" :key="reg.name" class="register-item">
                                                <div class="register-header">
                                                    <a-tag color="blue" size="small">{{ reg.name }}</a-tag>
                                                    <span class="register-fullname">{{ reg.fullName }}</span>
                                                </div>
                                                <div class="register-description">{{ reg.description }}</div>
                                            </div>
                                        </a-card>
                                    </a-col>
                                    <a-col v-if="t8_4_selectedChip.detailedInfo.indexPointer" :span="12">
                                        <a-card title="📍 变址和指针寄存器" size="small" style="margin-bottom: 16px;">
                                            <div v-for="reg in t8_4_selectedChip.detailedInfo.indexPointer" :key="reg.name" class="register-item">
                                                <div class="register-header">
                                                    <a-tag color="green" size="small">{{ reg.name }}</a-tag>
                                                    <span class="register-fullname">{{ reg.fullName }}</span>
                                                </div>
                                                <div class="register-description">{{ reg.description }}</div>
                                            </div>
                                        </a-card>
                                    </a-col>
                                    <a-col v-if="t8_4_selectedChip.detailedInfo.segment" :span="12">
                                        <a-card title="🗂️ 段寄存器" size="small" style="margin-bottom: 16px;">
                                            <div v-for="reg in t8_4_selectedChip.detailedInfo.segment" :key="reg.name" class="register-item">
                                                <div class="register-header">
                                                    <a-tag color="orange" size="small">{{ reg.name }}</a-tag>
                                                    <span class="register-fullname">{{ reg.fullName }}</span>
                                                </div>
                                                <div class="register-description">{{ reg.description }}</div>
                                            </div>
                                        </a-card>
                                    </a-col>
                                    <a-col v-if="t8_4_selectedChip.detailedInfo.control" :span="12">
                                        <a-card title="⚙️ 控制寄存器" size="small" style="margin-bottom: 16px;">
                                            <div v-for="reg in t8_4_selectedChip.detailedInfo.control" :key="reg.name" class="register-item">
                                                <div class="register-header">
                                                    <a-tag color="red" size="small">{{ reg.name }}</a-tag>
                                                    <span class="register-fullname">{{ reg.fullName }}</span>
                                                </div>
                                                <div class="register-description">{{ reg.description }}</div>
                                            </div>
                                        </a-card>
                                    </a-col>
                                </a-row>
                            </div>
                        </a-card>

                        <a-collapse :default-active-key="['1', '2', '3']">
                            <a-collapse-item header="ARM架构寄存器详解" key="1">
                                <div class="register-details">
                                    <h4>🔧 ARM Cortex系列对比</h4>
                                    <a-descriptions bordered size="small" :column="1">
                                        <a-descriptions-item label="Cortex-M0/M0+">
                                            <strong>ARMv6-M架构</strong><br/>
                                            • 13个32位通用寄存器(R0-R12)<br/>
                                            • 特殊寄存器：SP(R13)、LR(R14)、PC(R15)<br/>
                                            • 超低功耗设计，适合电池供电设备<br/>
                                            • 简化的指令集，降低硬件复杂度
                                        </a-descriptions-item>
                                        <a-descriptions-item label="Cortex-M3/M4">
                                            <strong>ARMv7-M架构</strong><br/>
                                            • 相同的寄存器组织(R0-R15)<br/>
                                            • M4增加了DSP指令和浮点单元<br/>
                                            • 更强的中断处理能力<br/>
                                            • 支持位带操作(Bit-banding)
                                        </a-descriptions-item>
                                        <a-descriptions-item label="Cortex-A系列">
                                            <strong>ARMv7-A/ARMv8-A架构</strong><br/>
                                            • ARMv8-A：31个64位通用寄存器(X0-X30)<br/>
                                            • 可作为32位寄存器使用(W0-W30)<br/>
                                            • 支持多种执行状态和异常级别<br/>
                                            • 高性能应用处理器，支持复杂操作系统
                                        </a-descriptions-item>
                                    </a-descriptions>
                                </div>
                            </a-collapse-item>
                            
                            <a-collapse-item header="x86架构演进" key="2">
                                <div class="register-details">
                                    <h4>💻 x86寄存器发展历程</h4>
                                    <a-descriptions bordered size="small" :column="1">
                                        <a-descriptions-item label="8086/8088 (16位)">
                                            • AX, BX, CX, DX (可分为AH/AL等)<br/>
                                            • SI, DI, BP, SP<br/>
                                            • 段寄存器：CS, DS, ES, SS
                                        </a-descriptions-item>
                                        <a-descriptions-item label="80386+ (32位)">
                                            • 扩展为32位：EAX, EBX, ECX, EDX等<br/>
                                            • 新增：FS, GS段寄存器<br/>
                                            • 支持保护模式和虚拟内存
                                        </a-descriptions-item>
                                        <a-descriptions-item label="x86-64 (64位)">
                                            • 再次扩展：RAX, RBX, RCX, RDX等<br/>
                                            • 新增：R8-R15通用寄存器<br/>
                                            • 更大的地址空间和数据处理能力
                                        </a-descriptions-item>
                                    </a-descriptions>
                                </div>
                            </a-collapse-item>
                            
                            <a-collapse-item header="其他架构特色" key="3">
                                <div class="register-details">
                                    <h4>🌟 特色架构介绍</h4>
                                    <a-descriptions bordered size="small" :column="1">
                                        <a-descriptions-item label="RISC-V">
                                            <strong>开源指令集架构</strong><br/>
                                            • x0寄存器恒为0，简化硬件设计<br/>
                                            • 模块化设计，可扩展性强<br/>
                                            • 统一的寄存器命名规范<br/>
                                            • 支持32位、64位、128位变种
                                        </a-descriptions-item>
                                        <a-descriptions-item label="MIPS">
                                            <strong>学术界经典架构</strong><br/>
                                            • 32个通用寄存器，规整的设计<br/>
                                            • $0恒为0，简化编程<br/>
                                            • HI/LO寄存器专门处理乘除法结果<br/>
                                            • RISC设计典型代表
                                        </a-descriptions-item>
                                        <a-descriptions-item label="8位处理器">
                                            <strong>嵌入式经典</strong><br/>
                                            • 8051：4个通用寄存器 + 累加器<br/>
                                            • AVR：32个8位寄存器<br/>
                                            • PIC16：单一工作寄存器架构<br/>
                                            • 适合资源受限的简单应用
                                        </a-descriptions-item>
                                        <a-descriptions-item label="DSP处理器">
                                            <strong>数字信号处理优化</strong><br/>
                                            • 专用的累加器和地址寄存器<br/>
                                            • 并行处理单元(A端/B端)<br/>
                                            • 硬件乘法器和桶形移位器<br/>
                                            • 优化的音频/视频处理能力
                                        </a-descriptions-item>
                                    </a-descriptions>
                                </div>
                            </a-collapse-item>
                        </a-collapse>

                        <div style="margin-top: 20px;">
                            <a-alert type="success" show-icon>
                                <template #icon><icon-info-circle /></template>
                                <div>
                                    <p style="margin: 0 0 10px 0;"><strong>💡 选择建议</strong></p>
                                    <p style="margin: 0;">
                                        • <strong>超低功耗项目</strong>：ARM Cortex-M0/M0+ 或 8位处理器<br/>
                                        • <strong>实时控制</strong>：ARM Cortex-M3/M4 或 DSP处理器<br/>
                                        • <strong>高性能应用</strong>：ARM Cortex-A 或 x86-64<br/>
                                        • <strong>开源项目</strong>：RISC-V架构<br/>
                                        • <strong>教学研究</strong>：MIPS架构<br/>
                                        • <strong>简单控制</strong>：8051或PIC系列
                                    </p>
                                </div>
                            </a-alert>
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
    width: 100%;
    height: auto;
    overflow-y: auto;
    overflow-x: hidden;
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

/* 电阻阻值计算器样式 */
.resistor-display {
    margin: 20px auto;
    width: 100%;
    height: 80px;
    display: flex;
    align-items: center;
    justify-content: center;
}

.resistor-body {
    position: relative;
    width: 80%;
    height: 40px;
    background-color: #d9d9d9;
    border-radius: 20px;
    display: flex;
    align-items: center;
}

.resistor-band {
    position: absolute;
    width: 10px;
    height: 40px;
    border-radius: 0;
}

.resistor-lead {
    width: 50px;
    height: 4px;
    background-color: #a0a0a0;
    position: absolute;
}

.left-lead {
    left: -50px;
}

.right-lead {
    right: -50px;
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

/* Android权限表格样式 */
.permission-table-row {
    height: 48px;
}

/* HTTP状态码表格样式 */
.status-code-table-row {
    height: 48px;
}

/* Content-Type表格样式 */
.content-type-table-row {
    height: 48px;
}

/* HTML特殊字符表格样式 */
.html-char-table-row {
    height: 48px;
}

.html-char-display {
    font-size: 20px;
    font-weight: bold;
    text-align: center;
    display: block;
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

/* 寄存器详情样式 */
.register-details {
    font-size: 14px;
    line-height: 1.5;
}

.detail-section {
    margin-bottom: 20px;
}

.section-title {
    font-size: 16px;
    font-weight: 600;
    color: #1d2129;
    margin: 0 0 12px 0;
    display: flex;
    align-items: center;
    gap: 8px;
}

.info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 8px;
    margin-bottom: 5px;
}

.info-item {
    display: flex;
    align-items: center;
    padding: 8px 12px;
    background: #f7f8fa;
    border-radius: 6px;
    border-left: 3px solid #165dff;
}

.bit-label {
    font-weight: 600;
    color: #165dff;
    min-width: 35px;
    margin-right: 8px;
}

.description {
    color: #4e5969;
    font-size: 13px;
}

.timeline {
    space-y: 6px;
}

.timeline-item {
    display: flex;
    align-items: center;
    padding: 6px 0;
    border-bottom: 1px solid #f2f3f5;
}

.timeline-item:last-child {
    border-bottom: none;
}

.year {
    font-weight: 600;
    color: #ff7d00;
    min-width: 60px;
    margin-right: 12px;
    font-size: 13px;
}

.event {
    color: #4e5969;
    font-size: 13px;
}

.tips-container {
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.tip-item {
    padding: 8px 12px;
    background: #fff7e6;
    border-radius: 6px;
    color: #86909c;
    font-size: 13px;
    border-left: 3px solid #ff7d00;
}
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

/* MQTT工具样式 */
.mqtt-log-item {
    margin-bottom: 8px;
    padding: 8px;
    border-radius: 4px;
    transition: background-color 0.3s;
    line-height: 1.5;
}
.mqtt-log-item:hover {
    background-color: rgba(0, 0, 0, 0.02);
}
.mqtt-log-received {
    border-left: 3px solid #722ed1;
    background-color: rgba(114, 46, 209, 0.05);
}
.mqtt-log-error {
    border-left: 3px solid #f5222d;
    background-color: rgba(245, 34, 45, 0.05);
}
.mqtt-log-success {
    border-left: 3px solid #52c41a;
    background-color: rgba(82, 196, 26, 0.05);
}
.mqtt-log-warning {
    border-left: 3px solid #fa8c16;
    background-color: rgba(250, 140, 22, 0.05);
}
.mqtt-log-time {
    margin-right: 5px;
    color: #888;
    display: inline-block;
    width: 75px;
    font-family: monospace;
}
.mqtt-log-type {
    display: inline-block;
    width: 60px;
    margin-right: 8px;
    text-align: center;
}
.mqtt-log-message {
    word-break: break-all;
    padding-left: 5px;
    font-family: "Consolas", monospace;
}
.mqtt-log-empty {
    text-align: center;
    color: #aaa;
    padding: 30px 0;
    font-style: italic;
}
.mqtt-usage-guide {
    padding: 10px;
}
.mqtt-usage-guide h4 {
    margin: 15px 0 8px;
}
.mqtt-usage-guide p {
    line-height: 1.6;
}

/* t8-4 通用寄存器速查样式 */
.register-details h4 {
    margin: 0 0 16px 0;
    color: var(--color-text-1);
    font-weight: 600;
}

.register-details .arco-descriptions-item-label {
    font-weight: 600;
    color: var(--color-text-1);
}

.register-details .arco-descriptions-item-value {
    line-height: 1.6;
}

.register-details strong {
    color: var(--color-primary);
}

.chip-overview-card {
    transition: all 0.3s ease;
    border: 1px solid #e5e6eb;
}

.chip-overview-card:hover {
    border-color: #165dff;
    box-shadow: 0 4px 12px rgba(22, 93, 255, 0.15);
    transform: translateY(-2px);
}

.register-item {
    margin-bottom: 12px;
    padding: 8px 12px;
    background: #f7f8fa;
    border-radius: 6px;
    border-left: 3px solid #165dff;
}

.register-item:last-child {
    margin-bottom: 0;
}

.register-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 4px;
}

.register-fullname {
    font-weight: 600;
    color: #1d2129;
}

.register-description {
    font-size: 12px;
    color: #4e5969;
    line-height: 1.5;
}
</style>