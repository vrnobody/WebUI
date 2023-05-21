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
  <!-- toolstrip -->
  <div class="md:left-56 left-8 top-0 h-12 py-0 px-4 flex grow justify-left items-center fixed z-20">
    <div class="m-0 text-2xl">
      <button @click="saveSettings" class="my-0 mx-1"><i class="fas fa-save"></i> {{ t('save')
      }}</button>
    </div>
  </div>

  <!-- header -->
  <div class="left-0 md:left-56 flex fixed top-12 right-0 grow z-10">
    <div class="dark:bg-slate-500 dark:text-neutral-700 grow bg-slate-400 text-xs text-neutral-600 table h-6">
      <div class="table-cell py-0 px-1 align-middle text-center w-[18rem]">{{ t('key') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center">{{ t('value') }}</div>
    </div>
  </div>

  <!-- settings list -->
  <div class="dark:text-neutral-100">
    <div class="block w-full h-6"></div>
    <ul :key="isRequireRerender">
      <li v-for="(value, key) in propsTable" class="dark:odd:bg-slate-600 odd:bg-neutral-200 items-center flex">
        <div class="inline-flex w-[18rem] shrink-0 px-1 py-1">{{ t(value) }}</div>
        <div class="inline-flex grow px-1 py-1">
          <input v-if="getElementType(key) === 'text'" type="text" v-model="settings[key]"
            class="dark:bg-slate-500 bg-neutral-100 grow px-1 border border-neutral-400 dark:border-0" />
          <input v-if="getElementType(key) === 'checkbox'" type="checkbox" v-model="settings[key]" class="w-4 h-4" />
        </div>
      </li>
    </ul>
    <div class="block grow h-10"></div>
  </div>
</template>

<style scoped></style>
