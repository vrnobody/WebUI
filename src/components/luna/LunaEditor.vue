<script setup>
import { ref, onMounted, onUnmounted, nextTick, defineAsyncComponent } from 'vue'
import { useI18n } from '@yangss/vue3-i18n'
import utils from '../../misc/utils.js'

const LuaEditor = defineAsyncComponent(() => import("./LuaEditor.vue"))

const { _, t } = useI18n()
const scriptName = ref('')
const scriptContent = ref('')
const logContent = ref('')
const scriptDb = ref({})

let luavm = ''

let logContainer = ref(null)

let logUpdater = 0

let lastScriptContent = ""

function saveScript(quiet) {
  const name = scriptName.value
  const script = scriptContent.value
  const showResult = function (ok) {
    if (ok) {
      scriptDb[name] = script
      lastScriptContent = script
      loadScriptsFromServer()
    }

    if (quiet && ok) {
      return
    }
    const msg = ok ? t('success') : t('failed')
    Swal.fire(msg)
  }
  utils.call(showResult, 'AddLuaScript', [name, script])
}

function loadScript() {
  const name = scriptName.value
  const scripts = scriptDb.value
  for (const key in scripts) {
    if (key === name) {
      const script = scripts[name]
      const cur = scriptContent.value
      if (lastScriptContent === null || lastScriptContent.length < 1 || lastScriptContent === cur) {
        scriptContent.value = script
        lastScriptContent = script
      } else {
        Swal.fire({
          title: t('replaceCurScript'),
          showDenyButton: true,
          confirmButtonText: t('yes'),
          denyButtonText: t('no'),
        }).then((result) => {
          if (result.isConfirmed) {
            scriptContent.value = script
            lastScriptContent = script
          }
        })
        return
      }
    }
  }
}

function loadScriptsFromServer() {
  const next = function (str) {
    try {
      const j = JSON.parse(str)
      scriptDb.value = j
    } catch (err) {
      Swal.fire(err.toString())
    }
  }
  utils.call(next, 'GetAllLuaScripts')
}

function updateLog() {
  if (!luavm) {
    clearInterval(logUpdater)
    return
  }
  const next = function (log) {

    if (!log) {
      clearInterval(logUpdater)
      return
    }

    if (log === logContent.value) {
      return
    }
    logContent.value = log || ''
    nextTick(() => {
      if (logContainer.value) {
        logContainer.value.scrollTop = logContainer.value.scrollHeight + 120
      }
    })
  }
  utils.call(next, 'GetLuaVmLog', [luavm])
}

function clearLog() {
  function next() {
    logContent.value = ''
  }
  utils.call(next, 'ClearLuaVmLog', [luavm])
}

function removeLuaVm() {
  utils.call(null, 'RemoveLuaVm', [luavm])
}

function runScript() {

  const script = scriptContent.value
  const name = scriptName.value

  removeLuaVm()
  clearInterval(logUpdater)
  const next = function (handle) {
    luavm = handle
    isLogPanelVisible.value = true
    logUpdater = setInterval(updateLog, 1000)
  }
  utils.call(next, 'RunLuaScript', [name, script])
}

function stopScript() {
  utils.call(null, 'StopLuaVm', [luavm])
}

function abortScript() {
  utils.call(null, 'AbortLuaVm', [luavm])
}

function newScript() {
  const cur = scriptContent.value
  if (lastScriptContent === null || lastScriptContent.length < 1 || lastScriptContent === cur) {
    scriptContent.value = ''
    scriptName.value = ''
    lastScriptContent = ''
  } else {
    Swal.fire(t('scriptNoSavedYet'))
  }
}

function onKeyDown(e) {

  if (e.ctrlKey && e.key === 's') {
    e.preventDefault()
    saveScript(true)
    return
  }

  switch (e.key) {
    case 'F5':
      runScript()
      e.preventDefault()
      break;
    case 'F6':
      stopScript()
      e.preventDefault()
      break;
    case 'F7':
      abortScript()
      e.preventDefault()
      break;
    case 'F8':
      clearLog()
      e.preventDefault()
      break;
  }
}

onMounted(() => {
  document.addEventListener('keydown', onKeyDown)
  loadScriptsFromServer()
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeyDown)
  clearInterval(logUpdater)
  removeLuaVm()
})

const isFullScreen = ref(false)
function onFullScreenHandler(fullScreen) {
  isFullScreen.value = fullScreen
}

const isLogPanelVisible = ref(false)
</script>

<template>
  <div class="dark:bg-slate-800 bg-slate-300 p-2 fixed flex flex-col right-0 bottom-0"
    :class="{ 'z-50 left-0 right-0 top-0': isFullScreen, 'z-20 top-12 pt-0 left-0 md:left-56': !isFullScreen }">
    <!-- toolstrip -->
    <div class="flex w-full dark:bg-slate-500 bg-slate-400 h-10 items-center text-base px-2">
      <label class="mx-1">{{ t('name') }}</label>
      <div class="grow mx-1">
        <input type="text" class="w-full px-2 dark:bg-slate-600 bg-neutral-100" list="scriptname-datalist"
          v-model="scriptName" @change="loadScript" />
        <datalist id="scriptname-datalist" class="dark:bg-slate-600">
          <option v-for="(_, key) in scriptDb" :value="key" class="dark:bg-slate-600"></option>
        </datalist>
      </div>
      <button class="mx-1" @click="newScript"><i class="fas fa-file-code"></i></button>
      <button class="mx-1" @click="saveScript(false)"><i class="fas fa-save"></i></button>
      <button class="mx-1" @click="runScript"><i class="fas fa-play"></i></button>
      <button class="mx-1" @click="stopScript"><i class="fas fa-stop"></i></button>
      <button class="mx-1" @click="abortScript"><i class="fas fa-stop-circle"></i></button>
      <button class="mx-1" @click="clearLog"><i class="fas fa-broom"></i></button>
    </div>
    <div class="flex grow w-full flex-row">
      <div class="flex w-[70%] min-w-[20%] overflow-auto resize-x flex-col" :class="{ 'grow': !isLogPanelVisible }">
        <LuaEditor v-model:script="scriptContent" @onFullScreen="onFullScreenHandler"
          v-model:logPanelVisible="isLogPanelVisible" />
      </div>
      <div v-if="isLogPanelVisible" class="grow ml-1 mt-1 flex">
        <textarea readonly class="dark:bg-slate-600 bg-neutral-200 grow p-1 resize-none" v-model="logContent"
          ref="logContainer"></textarea>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
