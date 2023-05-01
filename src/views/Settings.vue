<script setup>
import utils from '../misc/utils.js'
import { onMounted, ref } from 'vue'

let data = ref({})

function parseSettings(settings) {
  let s = JSON.parse(settings)
  let filteredKeys = {
    "QuickSwitchServerLatency": "switch lantency",
    "v2rayCoreDownloadSource": "update core url",
    "isEnableUtlsFingerprint": "enable uTLS",
    "ServerPanelPageSize": "page size",
    "isEnableStat": "enable stat",
    "isPortable": "portable",
    "CfgShowToolPanel": "show left panel",
    "isCheckUpdateWhenAppStart": "check for app update",
    "isCheckV2RayCoreUpdateWhenAppStart": "check for core update",
    "isUpdateUseProxy": "use proxy",
    "Culture": "culture",
    "MaxConcurrentV2RayCoreNum": "concurrent",
  }

  let d = {}
  for (const key in s) {
    if (filteredKeys.hasOwnProperty(key)) {
      let k = filteredKeys[key]
      d[k] = s[key].toString()
    }
  }
  data.value = d
}

function getSettings() {
  utils.call(parseSettings, "GetSettings")
}

onMounted(() => getSettings())

</script>

<template>
  <div class="main-div">
    <ul>
      <li v-for="(v, k) in data">
        <div class="key-div">{{ k }}</div>
        <div class="value-div">{{ v.toString() }}</div>
      </li>
    </ul>
  </div>
</template>

<style scoped>
ul {
  margin: 0rem;
  padding: 0rem;
  list-style-type: none;
}

li:nth-child(odd) {
  background-color: #e6e6e6;
}

.key-div {
  display: inline-flex;
  width: 15rem;
  flex-shrink: 0;
  margin: 0.1rem 0.5rem;
}

.value-div {
  display: inline-flex;
  margin: 0.1rem 0.5rem;
}

.main-div {
  display: flow;
}
</style>
