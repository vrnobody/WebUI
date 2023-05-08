<script setup>
import { RouterView } from 'vue-router'
import CompHeader from './components/Header.vue'
import CompSidebar from './components/Sidebar.vue'

</script>

<template>
  <header>
    <CompHeader />
  </header>

  <input id="menu-toggle" type="checkbox" />
  <label class='menu-button-container' for="menu-toggle">
    <div class='menu-button'></div>
  </label>

  <aside>
    <CompSidebar />
  </aside>

  <div class="main-area-wrapper">
    <div class="main-area-body">
      <RouterView />
    </div>
  </div>
</template>

<style scoped>
@media (max-width: 800px) {
  body .menu-button-container {
    visibility: visible;
  }

  body .main-area-wrapper {
    margin-left: 0rem;
  }

  aside {
    visibility: hidden;
  }

  #menu-toggle:checked~aside {
    visibility: visible;
  }
}

.menu-button-container {
  visibility: hidden;
  position: fixed;
  z-index: 400;
  left: 0.7rem;
  top: 1.25rem;
  display: flex;
  cursor: pointer;
  justify-content: start;
  align-items: start;
}

#menu-toggle {
  display: none;
}

.menu-button,
.menu-button::before,
.menu-button::after {
  display: block;
  background-color: lightgray;
  position: absolute;
  height: 0.4rem;
  width: 1.8rem;
  border-radius: 0.4rem;
}

.menu-button::before {
  content: '';
  margin-top: -0.5rem;
}

.menu-button::after {
  content: '';
  margin-top: 0.5rem;
}

#menu-toggle:checked+.menu-button-container .menu-button::before {
  margin-top: 0px;
  transform: rotate(405deg);
}

#menu-toggle:checked+.menu-button-container .menu-button {
  background: rgba(255, 255, 255, 0);
}

#menu-toggle:checked+.menu-button-container .menu-button::after {
  margin-top: 0px;
  transform: rotate(-405deg);
}

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
  bottom: 0rem;
  width: 14rem;
  top: 0rem;
  padding: 0rem;
  margin: 0rem;
  left: 0rem;
  z-index: 300;
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
