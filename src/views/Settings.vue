<script setup>
import utils from '../misc/utils.js'
import { onMounted, ref } from 'vue'

let data = ref({})

function parseSettings(settings) {
  const importModes = ["config", "http", "socks", "custom"]
  const s = JSON.parse(settings)
  let d = {}
  d["Culture"] = s["Culture"]
  d["Import ss://..."] = s["ImportOptions"]["IsImportSsShareLink"]
  d["Import trojan://..."] = s["ImportOptions"]["IsImportTrojanShareLink"]
  const modeIdx = s["ImportOptions"]["Mode"]
  if (modeIdx === 1 || modeIdx === 2) {
    const defInbound = importModes[modeIdx] + "://" + s["ImportOptions"]["Ip"] + ":" + s["ImportOptions"]["Port"]
    d["Default inbound"] = defInbound
  }
  d["Max concurrent"] = s["MaxConcurrentV2RayCoreNum"]
  d["Switch latency"] = s["QuickSwitchServerLatency"] + "ms"
  if (s["SpeedtestOptions"]["IsUse"]) {
    d["Speedtest URL"] = s["SpeedtestOptions"]["Url"]
  }
  d["Subscription"] = JSON.parse(s["SubscribeUrls"]).length
  d["Check V2RayGCon update"] = s["isCheckV2RayCoreUpdateWhenAppStart"]
  d["Check core update"] = s["isCheckV2RayCoreUpdateWhenAppStart"]
  d["Download core type"] = s["isDownloadWin32V2RayCore"] ? "win32" : "win64"
  d["uTLS enabled"] = s["isEnableUtlsFingerprint"]
  d["Selfsign cert"] = s["isSupportSelfSignedCert"]
  d["Update using proxy"] = s["isUpdateUseProxy"]
  d["uTLS fingerprint"] = s["uTlsFingerprint"]
  d["Download core source"] = s["v2rayCoreDownloadSource"]

  const od = Object.keys(d).sort().reduce((o, k) => {
    o[k] = d[k]
    return o
  }, {})

  data.value = od
}

function getSettings() {
  utils.call(parseSettings, "GetSettings")
}

onMounted(() => getSettings())

</script>

<template>
  <div class="dark:text-neutral-100">
    <ul>
      <li v-for="(v, k) in data" class="dark:odd:bg-slate-600 odd:bg-neutral-200">
        <div class="inline-flex w-60 shrink-0 mx-2 my-0.5">{{ k }}</div>
        <div class="inline-flex mx-2 my-0.5">{{ v.toString() }}</div>
      </li>
    </ul>
  </div>
</template>

<style scoped></style>
