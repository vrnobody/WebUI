<script setup>
import { RouterView } from 'vue-router'
import CompHeader from '@/components/app/Header.vue'
import CompSidebar from '@/components/app/Sidebar.vue'
import { useI18n } from '@yangss/vue3-i18n'
import { onBeforeMount, onMounted } from 'vue'
import utils from '@/misc/utils.js'
import config from '@/config.js'

onBeforeMount(() => {
  // eslint-disable-next-line no-unused-vars
  const { _, t } = useI18n()
  utils.init(t)
  utils.reloadThemeMode()
})

onMounted(() => {
  if (config.isDevMode) {
    document.title = 'WebUI - DEV'
  }
  // do not do this
  // utils.hideScrollbarX()
})
</script>

<template>
  <header class="fixed left-0 top-0 z-10 flex h-12 w-full bg-slate-300 dark:bg-slate-800">
    <CompHeader />
  </header>

  <input id="hamburger-menu-toggle" type="checkbox" class="hidden" />
  <label
    for="hamburger-menu-toggle"
    class="hamburger-menu-button-container visible fixed left-2.5 top-5 z-50 flex cursor-pointer items-start justify-start md:invisible"
  >
    <div
      class="hamburger-menu-button bg-neutral-700 before:bg-neutral-700 after:bg-neutral-700 dark:bg-neutral-200 dark:before:bg-neutral-200 dark:after:bg-neutral-200"
    ></div>
  </label>

  <aside
    class="invisible fixed bottom-0 left-0 top-0 z-40 m-0 w-56 bg-slate-300 p-0 text-neutral-800 dark:bg-slate-800 dark:text-neutral-300 md:visible"
  >
    <CompSidebar />
  </aside>

  <div class="z-0 ml-0 block min-h-[37rem] pt-12 md:ml-56">
    <div class="block flex-row dark:text-neutral-200">
      <RouterView />
    </div>
  </div>

  <!-- wallpaper -->
  <div class="fixed bottom-0 left-0 right-0 top-0 -z-10 bg-neutral-100 dark:bg-slate-700"></div>
</template>

<style scoped>
@media (max-width: 768px) {
  #hamburger-menu-toggle:checked ~ aside {
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
  transition: 0.4s;
}

.hamburger-menu-button::before {
  content: '';
  margin-top: -0.5rem;
}

.hamburger-menu-button::after {
  content: '';
  margin-top: 0.5rem;
}

#hamburger-menu-toggle:checked + .hamburger-menu-button-container .hamburger-menu-button::before {
  width: 60%;
  transform: translateX(0.8rem) translateY(0.15rem) rotate(45deg);
}

#hamburger-menu-toggle:checked + .hamburger-menu-button-container .hamburger-menu-button {
  transform: rotate(180deg);
}

#hamburger-menu-toggle:checked + .hamburger-menu-button-container .hamburger-menu-button::after {
  width: 60%;
  transform: translateX(0.8rem) translateY(-0.15rem) rotate(-45deg);
}
</style>
