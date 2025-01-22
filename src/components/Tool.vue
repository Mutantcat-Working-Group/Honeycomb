<script setup lang="ts">
import { defineProps, defineEmits, ref } from 'vue';
import JsBarcode from 'jsbarcode';
import { Message } from '@arco-design/web-vue';
import { toPng } from 'html-to-image';
import { saveAs } from 'file-saver';
import QrcodeVue from 'qrcode.vue';

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
    t2_4_out.value = t2_4_in.value.replace(/[\u4e00-\u9fa5]/g, function (c) {
        return "\\u" + c.charCodeAt(0).toString(16);
    });
}
// 反向处理
function process_t2_4_re() {
    t2_4_in.value = t2_4_out.value.replace(/\\u[\d\w]{4}/gi, function (c) {
        return String.fromCharCode(parseInt(c.replace(/\\u/g, ""), 16));
    });
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
                            <a-button class="header-button no-outline-button" @click=""> <template #icon><img
                                        src="../assets/min.png" style="width: 15px;"
                                        @click="minimizeWindow()" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button"> <template #icon><img
                                        src="../assets/close.png" style="width: 15px;"
                                        @click="closeWindow()" /></template> </a-button>
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
                            <a-button class="header-button no-outline-button" @click=""> <template #icon><img
                                        src="../assets/min.png" style="width: 15px;"
                                        @click="minimizeWindow()" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button"> <template #icon><img
                                        src="../assets/close.png" style="width: 15px;"
                                        @click="closeWindow()" /></template> </a-button>
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
                            <a-button class="header-button no-outline-button" @click=""> <template #icon><img
                                        src="../assets/min.png" style="width: 15px;"
                                        @click="minimizeWindow()" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button"> <template #icon><img
                                        src="../assets/close.png" style="width: 15px;"
                                        @click="closeWindow()" /></template> </a-button>
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
                            <a-button class="header-button no-outline-button" @click=""> <template #icon><img
                                        src="../assets/min.png" style="width: 15px;"
                                        @click="minimizeWindow()" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button"> <template #icon><img
                                        src="../assets/close.png" style="width: 15px;"
                                        @click="closeWindow()" /></template> </a-button>
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
                            <a-button class="header-button no-outline-button" @click=""> <template #icon><img
                                        src="../assets/min.png" style="width: 15px;"
                                        @click="minimizeWindow()" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button"> <template #icon><img
                                        src="../assets/close.png" style="width: 15px;"
                                        @click="closeWindow()" /></template> </a-button>
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
                            <a-button class="header-button no-outline-button" @click=""> <template #icon><img
                                        src="../assets/min.png" style="width: 15px;"
                                        @click="minimizeWindow()" /></template>
                            </a-button>
                            <a-button class="header-button no-outline-button"> <template #icon><img
                                        src="../assets/close.png" style="width: 15px;"
                                        @click="closeWindow()" /></template> </a-button>
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
                                <a-button @click="process_t2_4()" class="t1-1-button" style="width: 60px;">-></a-button><br />
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

    </div>
</template>

<style>
/* 为所有元素定义滚动条样式 */
* {
    scrowlbar-width: thin;
    /* Firefox */
    scrowlbar-color: #888 #f1f1f1;
    /* Firefox */
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
</style>