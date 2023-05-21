<script setup>
import utils from '../misc/utils.js'
import { onMounted, ref } from 'vue'

const t = utils.getTranslator()

const settings = ref({})
const isRequireRerender = ref(false)

const propsTable = {
  'maxConcurrentV2RayCoreNum': 'maxConcurrentCore',
  'isEnableUtlsFingerprint': 'enableUTlsfingerprint',
  'uTlsFingerprint': 'uTlsFingerprint',
  'isUseCustomUserAgent': 'enableUserAgent',
  'CustomUserAgent': 'userAgent',
  'isUseCustomSpeedtestSettings': 'enableSpeedtestSettings',
  'CustomSpeedtestUrl': 'speedtestUrl',
  'CustomSpeedtestTimeout': 'speedtestTimeout',
  'CustomSpeedtestExpectedSizeInKib': 'speedtestSize',
  'CustomSpeedtestCycles': 'speettestCycles',
  'QuickSwitchServerLantency': 'quickSwitchLantency',
  'CustomDefImportTrojanShareLink': 'importTrojan',
  'CustomDefImportSsShareLink': 'importShadowsocks',
  'CustomDefImportMode': 'importMode',
  'CustomDefImportIp': 'importIp',
  'CustomDefImportPort': 'importPort',
}

function saveSettings() {
  const props = settings.value
  const next = function (ok) {
    if (ok) {
      loadSettings()
      Swal.fire(t('success'))
    } else {
      Swal.file(t('failed'))
    }
  }
  utils.call(next, 'SetUserSettings', [props])
}

function loadSettings() {
  const names = Object.keys(propsTable)
  const next = function (str) {
    try {
      settings.value = JSON.parse(str)
      forceRerender()
    } catch (err) {
      Swal.fire(err.toString())
    }
  }
  utils.call(next, "GetUserSettings", [names])
}

function getElementType(key) {
  const s = settings.value
  if (!s.hasOwnProperty(key)) {
    return null
  }
  const t = typeof (s[key])
  switch (t) {
    case 'boolean':
      return 'checkbox'
    case 'number':
    case 'string':
      return 'text'
    default:
      break;
  }
  return 'span'
}


const forceRerender = () => {
  isRequireRerender.value = !isRequireRerender.value
}

onMounted(() => {
  loadSettings()
})

</script>

<template>
  <!-- settings list -->
  <div class="dark:text-neutral-100">
    <ul :key="isRequireRerender">
      <li v-for="(value, key) in propsTable"
        class="dark:odd:bg-slate-600 odd:bg-neutral-300 dark:bg-slate-700 bg-neutral-200 flex items-center">
        <div class="inline-flex w-[18rem] shrink-0 mx-2 my-0.5">{{ t(value) }}</div>
        <div class="inline-flex mx-2 my-0.5 grow">
          <input v-if="getElementType(key) === 'text'" type="text" v-model="settings[key]"
            class="dark:bg-slate-500 bg-neutral-100 grow px-2 my-1 mx-2" />
          <input v-if="getElementType(key) === 'checkbox'" type="checkbox" v-model="settings[key]"
            class="w-4 h-4 my-1 mx-2" />
        </div>
      </li>
    </ul>
  </div>
  <div class="block grow h-10"></div>

  <!-- save button -->
  <div class="dark:bg-slate-500 bg-slate-400 fixed bottom-0 right-0 z-10 flex-col py-1 px-1">
    <div class="text-base">
      <button @click="saveSettings" class="px-2"><i class="fas fa-save"></i> {{ t('save') }}</button>
    </div>
  </div>
</template>

<style scoped></style>
