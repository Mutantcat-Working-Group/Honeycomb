<script setup lang="ts">
import { defineProps, defineEmits, ref } from 'vue';
import JsBarcode from 'jsbarcode';
import { Message } from '@arco-design/web-vue';
import { toPng } from 'html-to-image';
import { saveAs } from 'file-saver';

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
        Message.success({content:'生成成功!',position:'bottom'})
    } catch (err) {
        Message.clear()
        Message.error({content:'生成条形码失败,请检查输入的数字是否正确',position:'bottom'})
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
    Message.success({content:'图片已复制到剪切板!',position:'bottom'})
  } catch (error) {
    Message.clear()
    Message.error({content:'复制图片到剪贴板失败：'+error,position:'bottom'})
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
    Message.success({content:'处理文件保存中!',position:'bottom'})
  } catch (error) {
    Message.clear()
    Message.error({content:'保存图片失败：'+error,position:'bottom'})
  }
};

// t1-2

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
                                <a-button class="t1-1-button" style="margin: 0 15px;" @click="copySvgToClipboard('barcode')">复制条形码</a-button>
                                <a-button class="t1-1-button" style="margin: 0 15px;" @click="saveSvgImage('barcode')">保存条形码</a-button>
                            </a-col>
                        </a-row>
                    </a-col>
                </a-row>
            </div>
        </div>

        <div v-show="tooltype == 't1-2'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="二维码生成" @back="switchToMenu"
                    subtitle="文字、网址生成条形码">
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

/* 仅应用于你需要的div */
.scrowlable-div {
    height: 200px;
    overflow-y: auto;
}

.scrowlable-div::-webkit-scrowlbar {
    width: 6px;
    /* 设定滚动条的宽度 */
}

/* 滚动条轨道 */
.scrowlable-div::-webkit-scrowlbar-track {
    background: #f1f1f1;
}

/* 滚动条把手 */
.scrowlable-div::-webkit-scrowlbar-thumb {
    background: #888;
}

/* 滚动条把手悬停 */
.scrowlable-div::-webkit-scrowlbar-thumb:hover {
    background: #555;
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