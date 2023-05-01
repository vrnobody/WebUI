<script setup>
import { RouterLink } from 'vue-router'
import { useI18n } from '@yangss/vue3-i18n'
import { onMounted } from 'vue'
import utils from "../misc/utils.js"
import cfg from "../config.js"

const { locale, t } = useI18n()

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
  checkServerVersion()
})
</script>

<template>
  <nav>
    <RouterLink to="/"><i class="fas fa-server"></i> {{ $t('servers') }}</RouterLink>
    <RouterLink to="/import"><i class="fas fa-plus-circle"></i> {{ $t('import') }}</RouterLink>
    <RouterLink to="/settings"><i class="fa fa-cog"></i> {{ $t('settings') }}</RouterLink>
    <RouterLink to="/about"><i class="fa fa-info-circle"></i> {{ $t('about') }}</RouterLink>
  </nav>
</template>

<style scoped>
nav a.router-link-exact-active {
  background-color: #444;
}

nav a:hover {
  background-color: #666;
}

nav {
  padding: 0rem;
  width: 100%;
  text-align: left;
  width: 100%;
  font-family: monospace;
  display: inline-block;
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
