<script setup lang="ts">
import { defineProps, defineEmits } from 'vue';

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
</script>

<template>
    <div class="tool-container">
        <div v-show="tooltype == 't1'" class="one-tool">
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
        </div>
    </div>
</template>

<style>
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
</style>