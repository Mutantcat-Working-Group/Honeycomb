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
            <a-button class="header-button no-outline-button"  @click="minimizeWindow()"> <template #icon><img src="../assets/min.png"
                  style="width: 15px;"/></template>
            </a-button>
            <a-button class="header-button no-outline-button"  @click="closeWindow()"> <template #icon><img src="../assets/close.png"
                  style="width: 15px;" /></template> </a-button>
          </div>
        </template>
      </a-page-header>
    </div>
    <a-row>
      <a-col :span="24">
        <a-tabs position="left">
          <a-tab-pane key="0" title="工具说明">
            <div>
              <a-row><a-col :span="24">
                  <img src="../assets/icon.jpg"
                    style="width: 100px; height:  100px; border-radius: 5px; margin-top: 10px;" />
                </a-col>
              </a-row>
              <a-row><a-col :span="24">
                  <h3>蜂巢工具箱是一个离线工具箱，提供了一些常用的工具。</h3>
                </a-col>
              </a-row>
              <a-row><a-col :span="24">
                  <h4>官网：www.mutantcat.org</h4>
                </a-col>
              </a-row>
              <a-row><a-col :span="24">
                  <h4>版本：1.1.2025012</h4>
                </a-col>
              </a-row>
            </div>
          </a-tab-pane>
          <a-tab-pane key="1" title="常用工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t1-1')">
                  <a-card class="card-demo" title="条形码生成" :bordered="false">
                    <p :style="{ margin: 0 }">
                      数字生成条形码
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t1-2')">
                  <a-card class="card-demo" title="二维码码生成" :bordered="false">
                    <p :style="{ margin: 0 }">
                      文字生成二维码
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t3-1')">
                  <a-card class="card-demo" title="JSON格式化" :bordered="false">
                    <p :style="{ margin: 0 }">
                      将JSON格式化输出
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-1')">
                  <a-card class="card-demo" title="Windows加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      Windows自带指令
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="2" title="字符工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-1')">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-2')">
                  <a-card class="card-demo" title="字符串去回车" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除字符串中的回车
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-3')">
                  <a-card class="card-demo" title="去除空格回车" :bordered="false">
                    <p :style="{ margin: 0 }">
                      去除文中空格和回车
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-4')">
                  <a-card class="card-demo" title="中文转Unicode" :bordered="false">
                    <p :style="{ margin: 0 }">
                      中文与Unicode互转
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-5')">
                  <a-card class="card-demo" title="替换与转义" :bordered="false">
                    <p :style="{ margin: 0 }">
                      替换指定字符
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-2')">
                  <a-card class="card-demo" title="MD5加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      字符串转MD5
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-3')">
                  <a-card class="card-demo" title="SHA1加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      字符串转SHA1
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-4')">
                  <a-card class="card-demo" title="SHA256加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      字符串转SHA256
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="3" title="JSON工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t3-1')">
                  <a-card class="card-demo" title="JSON格式化" :bordered="false">
                    <p :style="{ margin: 0 }">
                      将JSON格式化输出
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="4" title="转换工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-4')">
                  <a-card class="card-demo" title="中文转Unicode" :bordered="false">
                    <p :style="{ margin: 0 }">
                      中文与Unicode互转
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t2-5')">
                  <a-card class="card-demo" title="替换与转义" :bordered="false">
                    <p :style="{ margin: 0 }">
                      替换指定字符
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="5" title="加密工具">
            <div class="tool-container custom-scrollbar">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-1')">
                  <a-card class="card-demo" title="Windows加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      Windows自带指令
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-2')">
                  <a-card class="card-demo" title="MD5加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      字符串转MD5
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-3')">
                  <a-card class="card-demo" title="SHA1加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      字符串转SHA1
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t5-4')">
                  <a-card class="card-demo" title="SHA256加密" :bordered="false">
                    <p :style="{ margin: 0 }">
                      字符串转SHA256
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="6" title="随机工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t6-1')">
                  <a-card class="card-demo" title="随机数字" :bordered="false">
                    <p :style="{ margin: 0 }">
                      生成随机数字
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t6-2')">
                  <a-card class="card-demo" title="随机字符串" :bordered="false">
                    <p :style="{ margin: 0 }">
                      生成随机字符串
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '24%' }" class="one-card" @click="switchToTool('t6-3')">
                  <a-card class="card-demo" title="随机混合串" :bordered="false">
                    <p :style="{ margin: 0 }">
                      生成字母数字混合串
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
