<script setup>
import { RouterLink } from 'vue-router'
import { onMounted } from 'vue'
import Tooltips from '@/components/widgets/Tooltips.vue'
import utils from '@/misc/utils.js'
import config from '@/config.js'
import store from '@/misc/store.js'

const t = utils.getTranslator()

function IsNewerVersion(minVer, curVer) {
    const mvs = minVer.split('.').map((n) => parseInt(n))
    const cvs = curVer.split('.').map((n) => parseInt(n))
    for (let index = 0; index < mvs.length; index++) {
        if (mvs[index] > cvs[index]) {
            return false
        }
    }
    return true
}

function checkAppVersion() {
    const ver = config.supportedAppVersion
    const cb = function (appVer) {
        const ok = IsNewerVersion(ver, appVer)
        if (!ok) {
            const msg = t('please_update_app', {
                curVer: appVer,
                expectedVer: ver
            })
            Swal.fire(msg)
        }
    }
    utils.call(cb, 'GetAppVersion')
}

function checkServerVersion() {
    let vers = config.supportedServerVersions
    let cb = function (servVer) {
        if (vers.indexOf(servVer) < 0) {
            let msg = t('server_ver_not_supported', {
                curVer: servVer,
                expectedVer: vers[0]
            })
            Swal.fire(msg)
        }
    }
    utils.call(cb, 'GetServerVersion')
}

function changeThemeMode(mode) {
    config.saveThemeMode(mode)
    utils.reloadThemeMode()
    store.onThemeChanges.value = !store.onThemeChanges.value
}

onMounted(() => {
    checkAppVersion()
    checkServerVersion()
})
</script>

<template>
    <div class="inline-flex h-12 w-full items-center justify-center text-2xl">V2RayGCon</div>
    <nav class="inline-block w-full grow p-0 text-left">
        <RouterLink
            to="/"
            exact-active-class="dark:bg-slate-600 bg-slate-400"
            class="hover:bg-slate-500 dark:hover:bg-slate-500"
            ><i class="fas fa-server"></i> {{ t('servers') }}</RouterLink
        >
        <RouterLink
            to="/import"
            exact-active-class="dark:bg-slate-600 bg-slate-400"
            class="hover:bg-slate-500 dark:hover:bg-slate-500"
            ><i class="fas fa-file-import"></i> {{ t('import') }}</RouterLink
        >
        <RouterLink
            to="/luna"
            exact-active-class="dark:bg-slate-600 bg-slate-400"
            class="hover:bg-slate-500 dark:hover:bg-slate-500"
            ><i class="fas fa-code"></i> Luna</RouterLink
        >
        <RouterLink
            to="/settings"
            exact-active-class="dark:bg-slate-600 bg-slate-400"
            class="hover:bg-slate-500 dark:hover:bg-slate-500"
            ><i class="fas fa-cog"></i> {{ t('settings') }}
        </RouterLink>
        <RouterLink
            to="/about"
            exact-active-class="dark:bg-slate-600 bg-slate-400"
            class="hover:bg-slate-500 dark:hover:bg-slate-500"
            ><i class="fas fa-info-circle"></i> {{ t('about') }}</RouterLink
        >
    </nav>
    <div class="absolute bottom-4 flex h-6 w-full items-center justify-center text-xl">
        <Tooltips :css="'-mt-8'" :tip="t('lightTheme')">
            <button @click="changeThemeMode('light')">
                <i class="fas fa-sun mx-1 my-0"></i>
            </button>
        </Tooltips>
        <Tooltips :css="'-mt-8'" :tip="t('darkTheme')">
            <button @click="changeThemeMode('dark')">
                <i class="fas fa-moon mx-1 my-0"></i>
            </button>
        </Tooltips>
        <Tooltips :css="'-mt-8'" :tip="t('system')">
            <button @click="changeThemeMode('system')">
                <i class="fas fa-desktop mx-1 my-0"></i>
            </button>
        </Tooltips>
    </div>
</template>

<style scoped>
nav a {
    text-decoration: none;
    font-size: 1.2rem;
    font-weight: bold;
    margin: 0.3rem;
    display: block;
    padding: 0.5rem 2rem;
}
</style>
