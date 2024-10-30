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
    const len = Math.min(mvs.length, cvs.length)
    for (let index = 0; index < len; index++) {
        if (cvs[index] != mvs[index]) {
            return cvs[index] > mvs[index]
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

function clearPassword() {
    function onYes() {
        config.set('token', '')
        config.saveAdminToken('')
        config.save()
        utils.reloadPage()
    }
    utils.confirm(t('clearPassword'), onYes)
}

function isTokenSet() {
    const token = config.get('token')
    // console.log("token:", token)
    return token && token.length > 1
}

onMounted(() => {
    checkAppVersion()
    checkServerVersion()
})
</script>

<template>
    <div class="inline-flex h-12 w-full items-center justify-center text-2xl">
        <span class="hidden lg:inline-block">V2RayGCon</span>
        <span class="inline-block lg:hidden">G</span>
    </div>
    <nav class="inline-block w-full grow text-center lg:text-left">
        <RouterLink
            to="/"
            exact-active-class="dark:bg-slate-600 bg-slate-400 px-2 py-2 lg:px-4"
            class="px-2 py-2 hover:bg-slate-500 dark:hover:bg-slate-500 lg:px-4"
            ><i class="fas fa-server p-0"></i
            ><span class="hidden lg:inline-block">&nbsp;{{ t('servers') }}</span></RouterLink
        >
        <RouterLink
            to="/import"
            exact-active-class="dark:bg-slate-600 bg-slate-400 px-2 py-2 lg:px-4"
            class="px-2 py-2 hover:bg-slate-500 dark:hover:bg-slate-500 lg:px-4"
            ><i class="fas fa-file-import p-0"></i
            ><span class="hidden lg:inline-block">&nbsp;{{ t('import') }}</span>
        </RouterLink>
        <RouterLink
            to="/luna"
            exact-active-class="dark:bg-slate-600 bg-slate-400 px-2 py-2 lg:px-4"
            class="px-2 py-2 hover:bg-slate-500 dark:hover:bg-slate-500 lg:px-4"
            ><i class="fas fa-code"></i
            ><span class="hidden lg:inline-block">&nbsp;NeoLuna</span></RouterLink
        >
        <RouterLink
            to="/settings"
            exact-active-class="dark:bg-slate-600 bg-slate-400 px-2 py-2 lg:px-4"
            class="px-2 py-2 hover:bg-slate-500 dark:hover:bg-slate-500 lg:px-4"
            ><i class="fas fa-cog"></i
            ><span class="hidden lg:inline-block">&nbsp;{{ t('settings') }}</span>
        </RouterLink>
        <RouterLink
            to="/about"
            exact-active-class="dark:bg-slate-600 bg-slate-400 px-2 py-2 lg:px-4"
            class="px-2 py-2 hover:bg-slate-500 dark:hover:bg-slate-500 lg:px-4"
            ><i class="fas fa-info-circle"></i
            ><span class="hidden lg:inline-block">&nbsp;{{ t('about') }}</span>
        </RouterLink>
    </nav>
    <div class="absolute bottom-4 flex h-6 w-full items-center justify-center text-xl">
        <Tooltips :css="'-mt-8'" :tip="t('lightTheme')" class="hidden lg:inline-block">
            <button @click="changeThemeMode('light')">
                <i class="fas fa-sun mx-1 my-0"></i>
            </button>
        </Tooltips>
        <Tooltips :css="'-mt-8'" :tip="t('darkTheme')" class="hidden lg:inline-block">
            <button @click="changeThemeMode('dark')">
                <i class="fas fa-moon mx-1 my-0"></i>
            </button>
        </Tooltips>
        <Tooltips :css="'-mt-8'" :tip="t('system')" class="hidden lg:inline-block">
            <button @click="changeThemeMode('system')">
                <i class="fas fa-desktop mx-1 my-0"></i>
            </button>
        </Tooltips>
        <Tooltips v-if="isTokenSet()" :css="'-mt-8'" :tip="t('logout')">
            <button @click="clearPassword()">
                <i class="fas fa-sign-out-alt mx-1 my-0"></i>
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
}
</style>
