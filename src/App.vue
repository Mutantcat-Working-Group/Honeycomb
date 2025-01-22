<script setup lang="ts">
import Menu from './components/Menu.vue';
import Tool from './components/Tool.vue';
import { ref } from 'vue';

const toolbar = ref(false);
const tooltype = ref("t1");
</script>

<template>
  <Menu v-show="!toolbar" :toolbar="toolbar" :tooltype="tooltype" @update:toolbar="toolbar = $event"
    @update:tooltype="tooltype = $event" class="main-container" />
  <Tool v-show="toolbar" :toolbar="toolbar" :tooltype="tooltype" @update:toolbar="toolbar = $event"
    @update:tooltype="tooltype = $event" msg="" class="main-container" />
</template>

<style>
.main-container {
  width: 100vw;
  height: 100vh;
}
</style>
