<script setup>
import { RouterView } from 'vue-router'
import CompHeader from './components/Header.vue'
import CompSidebar from './components/Sidebar.vue'
import { useI18n } from '@yangss/vue3-i18n'
import { onBeforeMount } from 'vue'
import utils from './misc/utils'

onBeforeMount(() => {
  const { _, t } = useI18n()
  utils.init(t)
  utils.reloadThemeMode()
})
</script>

<template>
  <header class="dark:bg-slate-800  bg-slate-300 fixed flex top-0 left-0 w-full h-12 z-10">
    <CompHeader />
  </header>

  <input id="hamburger-menu-toggle" type="checkbox" class="hidden" />
  <label for="hamburger-menu-toggle"
    class="hamburger-menu-button-container md:invisible visible fixed z-50 left-2.5 top-5 flex cursor-pointer justify-start items-start">
    <div
      class="dark:before:bg-neutral-200 dark:after:bg-neutral-200 dark:bg-neutral-200 before:bg-neutral-700 after:bg-neutral-700 bg-neutral-700 hamburger-menu-button">
    </div>
  </label>

  <aside
    class="dark:bg-slate-800 dark:text-neutral-200 md:visible bg-slate-300 invisible fixed bottom-0 top-0 left-0 w-56 p-0 m-0 z-40">
    <CompSidebar />
  </aside>

  <div class="block pt-12 z-0 min-h-[37rem] ml-0 md:ml-56">
    <div class="dark:text-neutral-200 block flex-row">
      <RouterView />
    </div>
  </div>

  <!-- wallpaper -->
  <div class="dark:bg-slate-700 bg-neutral-100 fixed top-0 left-0 right-0 bottom-0 -z-10"> </div>
</template>

<style scoped>
@media (max-width: 768px) {
  #hamburger-menu-toggle:checked~aside {
    visibility: visible;
  }
}

.hamburger-menu-button,
.hamburger-menu-button::before,
.hamburger-menu-button::after {
  display: block;
  position: absolute;
  height: 0.4rem;
  width: 1.8rem;
  border-radius: 0.4rem;
}

.hamburger-menu-button::before {
  content: '';
  margin-top: -0.5rem;
}

.hamburger-menu-button::after {
  content: '';
  margin-top: 0.5rem;
}

#hamburger-menu-toggle:checked+.hamburger-menu-button-container .hamburger-menu-button::before {
  margin-top: 0px;
  transform: rotate(405deg);
}

#hamburger-menu-toggle:checked+.hamburger-menu-button-container .hamburger-menu-button {
  background: none;
}

#hamburger-menu-toggle:checked+.hamburger-menu-button-container .hamburger-menu-button::after {
  margin-top: 0px;
  transform: rotate(-405deg);
}
</style>
