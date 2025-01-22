<script setup lang="ts">
import { defineProps, defineEmits } from 'vue';
const props = defineProps({ toolbar: Boolean, tooltype: String });
const emit = defineEmits(['update:toolbar', 'update:tooltype']);
const switchToTool = (t: string) => {
  emit('update:toolbar', true);
  emit('update:tooltype', t);
};

function minimizeWindow() {
  window.ipcRenderer.send('minimize-window');
}
function closeWindow() {
  window.ipcRenderer.send('close-window');
}

</script>

<template>
  <div>
    <div :style="{ background: 'var(--color-fill-1)', padding: '2px' }" class="one-head">
      <a-page-header :style="{ background: 'var(--color-bg-2)' }" title="蜂巢工具箱" subtitle="离线功能列表" :show-back=false>
        <template #extra>
          <div class="can_touch">
            <a-button class="header-button no-outline-button" @click=""> <template #icon><img src="../assets/min.png"
                  style="width: 15px;" @click="minimizeWindow()" /></template>
            </a-button>
            <a-button class="header-button no-outline-button"> <template #icon><img src="../assets/close.png"
                  style="width: 15px;" @click="closeWindow()" /></template> </a-button>
          </div>
        </template>
      </a-page-header>
    </div>
    <a-row>
      <a-col :span="24">
        <a-tabs position="left">
          <a-tab-pane key="1" title="常用工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t1')">
                  <a-card class="card-demo" title="条形码生成" :bordered="false">
                    <p :style="{ margin: 0 }">
                      数字生成条形码
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t1')">
                  <a-card class="card-demo" title="条形码生成" :bordered="false">
                    <p :style="{ margin: 0 }">
                      数字生成条形码
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t1')">
                  <a-card class="card-demo" title="条形码生成" :bordered="false">
                    <p :style="{ margin: 0 }">
                      数字生成条形码
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t1')">
                  <a-card class="card-demo" title="条形码生成" :bordered="false">
                    <p :style="{ margin: 0 }">
                      数字生成条形码
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="2" title="字符工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }" class="one-card">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="3" title="JSON工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }" class="one-card">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="4" title="转换工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }" class="one-card">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="5" title="加密工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }" class="one-card">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="6" title="随机工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }" class="one-card">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
        </a-tabs>
      </a-col>
    </a-row>
  </div>
</template>

<style scoped>
.one-head {
  -webkit-app-region: drag;
}

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
  display: flex;
  flex-wrap: nowrap;
  justify-content: center;
  align-items: start;
  width: 99%;
  height: calc(99vh - 66px);
  padding-bottom: 1px;
  overflow-y: auto;
}


.one-card {
  border-radius: 5px;
  margin-left: 0.5%;
  margin-right: 0.5%;
  margin-top: 0.5%;
  margin-bottom: 0.5%;
}

.one-card:hover {
  background-color: #f0f0f0;
  cursor: pointer;
}

.card-demo {
  width: 100%;
}

.card-demo :deep(.arco-card-header) {
  border: none;
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
