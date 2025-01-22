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
</script>

<template>
    <div class="tool-container">
        <div v-show="tooltype == 't1'" class="one-tool">
            <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-tool-head">
                <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="条码生成" @back="switchToMenu"
                    subtitle="数字生成条形码"></a-page-header>
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

.one-tool-head{
    -webkit-app-region: drag; 
}

.arco-page-header .arco-icon-hover.arco-page-header-icon-hover::before{
    -webkit-app-region: no-drag;
}
</style>