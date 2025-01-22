<script setup lang="ts">
import { defineProps, defineEmits, ref } from 'vue';
import JsBarcode from 'jsbarcode';

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

function generateBarcode() {
    JsBarcode("#barcode", t1_1_in.value, {
        format: "CODE128",
        displayValue: true,
        fontSize: 20,
        width: 2,
        height: 60,
        textMargin: 0,
        margin: 0
    });
}
</script>

<template>
    <div class="tool-container">
        <div v-show="tooltype == 't1-1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="条码生成" @back="switchToMenu"
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
                                <a-col :span="20">
                                    <a-input v-model="t1_1_in" placeholder="请输入数字" class="t1-1-inputer"></a-input>
                                </a-col>
                            </a-row>
                            <a-button @click="generateBarcode">生成条形码</a-button><br/>
                            <svg id="barcode"></svg>
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
  scrollbar-width: thin;
  /* Firefox */
  scrollbar-color: #888 #f1f1f1;
  /* Firefox */
}

/* 仅应用于你需要的div */
.scrollable-div {
  height: 200px;
  overflow-y: auto;
}

.scrollable-div::-webkit-scrollbar {
  width: 6px;
  /* 设定滚动条的宽度 */
}

/* 滚动条轨道 */
.scrollable-div::-webkit-scrollbar-track {
  background: #f1f1f1;
}

/* 滚动条把手 */
.scrollable-div::-webkit-scrollbar-thumb {
  background: #888;
}

/* 滚动条把手悬停 */
.scrollable-div::-webkit-scrollbar-thumb:hover {
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
</style>