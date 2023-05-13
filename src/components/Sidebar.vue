<script setup>
import { RouterLink } from 'vue-router'
import { useI18n } from '@yangss/vue3-i18n'
import { onMounted } from 'vue'
import utils from "../misc/utils.js"
import cfg from "../config.js"
import config from '../config.js'

const { _, t } = useI18n()

function IsNewerVersion(minVer, curVer) {
  const mvs = minVer.split(".").map(n => parseInt(n))
  const cvs = curVer.split(".").map(n => parseInt(n))
  for (let index = 0; index < mvs.length; index++) {
    if (mvs[index] > cvs[index]) {
      return false
    }
  }
  return true
}

function checkAppVersion() {
  const ver = cfg.supportedAppVersion
  const cb = function (appVer) {
    const ok = IsNewerVersion(ver, appVer)
    if (!ok) {
      const msg = t('please_update_app', {
        curVer: appVer,
        expectedVer: ver,
      })
      Swal.fire(msg)
    }
  }
  utils.call(cb, "GetAppVersion")
}

function checkServerVersion() {
  let vers = cfg.supportedServerVersions
  let cb = function (servVer) {
    if (vers.indexOf(servVer) < 0) {
      let msg = t('server_ver_not_supported', {
        curVer: servVer,
        expectedVer: vers[0],
      })
      Swal.fire(msg)
    }
  }
  utils.call(cb, "GetServerVersion")
}

function changeThemeMode(mode) {
  config.saveThemeMode(mode)
  utils.reloadThemeMode()
}

onMounted(() => {
  checkAppVersion()
  checkServerVersion()
})
</script>

<template>
  <div class="h-12 w-full inline-flex items-center justify-center text-2xl">
    V2RayGCon</div>
  <nav class="p-0 w-full text-left inline-block grow">
    <RouterLink to="/" exact-active-class="dark:bg-slate-600 bg-slate-400"
      class="dark:hover:bg-slate-500 hover:bg-slate-500"><i class="fas fa-server"></i> {{ t('servers')
      }}</RouterLink>
    <RouterLink to="/import" exact-active-class="dark:bg-slate-600 bg-slate-400"
      class="dark:hover:bg-slate-500 hover:bg-slate-500"><i class="fas fa-file-import"></i> {{
        t('import') }}</RouterLink>
    <RouterLink to="/luna" exact-active-class="dark:bg-slate-600 bg-slate-400"
      class="dark:hover:bg-slate-500 hover:bg-slate-500"><i class="fas fa-code"></i> Luna</RouterLink>
    <RouterLink to="/settings" exact-active-class="dark:bg-slate-600 bg-slate-400"
      class="dark:hover:bg-slate-500 hover:bg-slate-500"><i class="fas fa-cog"></i> {{ t('settings') }}
    </RouterLink>
    <RouterLink to="/about" exact-active-class="dark:bg-slate-600 bg-slate-400"
      class="dark:hover:bg-slate-500 hover:bg-slate-500"><i class="fas fa-info-circle"></i> {{
        t('about') }}</RouterLink>
  </nav>
  <div class="bottom-4 absolute w-full flex justify-center items-center text-xl h-6">
    <button @click="changeThemeMode('light')">
      <i class="fas fa-sun my-0 mx-1"></i>
    </button>
    <button @click="changeThemeMode('dark')">
      <i class="fas fa-moon my-0 mx-1"></i>
    </button>
    <button @click="changeThemeMode('system')">
      <i class="fas fa-desktop  my-0 mx-1"></i>
    </button>
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
