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

    <aside
        class="fixed bottom-0 left-0 top-0 z-40 m-0 w-12 lg:w-56 bg-slate-300 p-0 text-neutral-800 dark:bg-slate-800 dark:text-neutral-300"
    >
        <CompSidebar />
    </aside>

    <div class="z-0 ml-12 lg:ml-56 block min-h-[37rem] pt-12">
        <div class="block flex-row dark:text-neutral-200">
            <RouterView />
        </div>
    </div>

    <!-- wallpaper -->
    <div class="fixed bottom-0 left-0 right-0 top-0 -z-10 bg-neutral-100 dark:bg-slate-700"></div>
</template>

<style scoped>

</style>
