<script setup>
import { RouterView } from 'vue-router'
import CompHeader from './components/Header.vue'
import CompSidebar from './components/Sidebar.vue'

</script>

<template>
  <header>
    <CompHeader />
  </header>
  <aside>
    <CompSidebar />
  </aside>
  <div class="main-area-wrapper">
    <div class="main-area-body">
      <RouterView />
    </div>
  </div>
  <!--
    <h4>{{ $t('introduction', { name: "aaaa", age: "123" }) }}</h4>
    <img alt="Vue logo" class="logo" src="@/assets/logo.svg" width="125" height="125" />
  -->
</template>

<style scoped>
.main-area-body {
  display: block;
  flex-flow: row;
}

.main-area-wrapper {
  display: block;
  margin-left: 14rem;
  padding-top: 3rem;
  z-index: 50;
  min-height: 37rem;
}

aside {
  position: fixed;
  height: 100%;
  width: 14rem;
  top: 3rem;
  padding: 0rem;
  margin: 0rem;
  left: 0rem;
  z-index: 100;
  background-color: #333;
}

header {
  position: fixed;
  display: flex;
  top: 0rem;
  left: 0rem;
  background-color: aqua;
  width: 100%;
  height: 3rem;
  z-index: 100;
}
</style>
