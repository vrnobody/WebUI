<script setup>
import { RouterLink } from 'vue-router'
import { useI18n } from '@yangss/vue3-i18n'
import { onMounted } from 'vue'
import utils from "../misc/utils.js"
import cfg from "../config.js"

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
    // console.log(ok, ver, appVer)
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

onMounted(() => {
  checkAppVersion()
  checkServerVersion()
})
</script>

<template>
  <div class="h-12 w-full inline-flex items-center justify-center  text-neutral-100 text-2xl">V2RayGCon</div>
  <nav class="p-0 w-full text-left inline-block">
    <RouterLink to="/"><i class="fas fa-server"></i> {{ t('servers') }}</RouterLink>
    <RouterLink to="/import"><i class="fas fa-file-import"></i> {{ t('import') }}</RouterLink>
    <RouterLink to="/settings"><i class="fas fa-cog"></i> {{ t('settings') }}</RouterLink>
    <RouterLink to="/about"><i class="fas fa-info-circle"></i> {{ t('about') }}</RouterLink>
  </nav>
</template>

<style scoped>
nav a.router-link-exact-active {
  background-color: #444;
}

nav a:hover {
  background-color: #666;
}

nav a {
  text-decoration: none;
  font-size: 1.2rem;
  font-weight: bold;
  color: whitesmoke;
  margin: 0.3rem;
  display: block;
  padding: 0.5rem 2rem;
}
</style>
