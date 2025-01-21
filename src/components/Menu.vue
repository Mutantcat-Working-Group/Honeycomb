<script setup lang="ts">
import { ref } from 'vue'

</script>

<template>
  <div>
    <a-row>
      <a-col :span="24">
        <a-tabs position="left">
          <a-tab-pane key="1" title="常用工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      去除字符串中的空格
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去回车" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      去除字符串中的回车
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="大小写转换" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      转换字符大小写
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符替换" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      替换字符串中指定字符
                    </p>
                  </a-card>
                </a-card-grid>
                
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="2" title="字符工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去回车" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="3" title="JSON工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去回车" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="4" title="转换工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去回车" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
              </a-card>
            </div>
          </a-tab-pane>
          <a-tab-pane key="5" title="随机工具">
            <div class="tool-container">
              <a-card :bordered="false" :style="{ width: '99%' }">
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去空格" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
                    </p>
                  </a-card>
                </a-card-grid>
                <a-card-grid :style="{ width: '25%' }">
                  <a-card class="card-demo" title="字符串去回车" :bordered="false">
                    <template #extra>
                      <a-link>查看</a-link>
                    </template>
                    <p :style="{ margin: 0 }">
                      'Card allow to hover'
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
  height: 99vh;
  padding-bottom: 1px;
  overflow-y: auto;
}

.card-demo {
  width: 100%;
}

.card-demo :deep(.arco-card-header) {
  border: none;
}
</style>
