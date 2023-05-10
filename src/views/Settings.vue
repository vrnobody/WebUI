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
  <div>
    <ul>
      <li v-for="(v, k) in data" class="odd:bg-neutral-200">
        <div class="inline-flex w-60 shrink-0 mx-2 my-0.5">{{ k }}</div>
        <div class="inline-flex mx-2 my-0.5">{{ v.toString() }}</div>
      </li>
    </ul>
  </div>
</template>

<style scoped></style>
