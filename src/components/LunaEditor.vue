<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useI18n } from '@yangss/vue3-i18n'
import utils from '../misc/utils.js'

const { _, t } = useI18n()
const scriptName = ref('')
const scriptContent = ref('')
const logContent = ref('')
const scriptCache = ref({})

let luavm = ''

let logContainer = ref(null)

let logUpdater = 0

function saveScript() {
  const name = scriptName.value
  const script = scriptContent.value
  const next = function (ok) {
    const msg = ok ? t('success') : t('failed')
    Swal.fire(msg)
    if (ok) {
      scriptCache[name] = script
      loadScriptsFromServer()
    }
  }
  utils.call(next, 'AddLuaScript', [name, script])
}

function loadScript() {
  const name = scriptName.value
  const scripts = scriptCache.value
  for (const key in scripts) {
    if (key === name) {
      const script = scripts[name]
      const cur = scriptContent.value
      if (!cur || cur.length === 0) {
        scriptContent.value = script
      } else if (script !== cur) {
        Swal.fire({
          title: t('replaceCurScript'),
          showDenyButton: true,
          confirmButtonText: t('yes'),
          denyButtonText: t('no'),
        }).then((result) => {
          if (result.isConfirmed) {
            scriptContent.value = script
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
      scriptCache.value = j
    } catch (err) {
      Swal.fire(err.toString())
    }
  }
  utils.call(next, 'GetAllLuaScripts')
}

function updateLog() {
  if (luavm === null || luavm.length === 0) {
    return
  }
  const next = function (log) {
    logContent.value = log || ''
    nextTick(() => {
      logContainer.value.scrollTop = logContainer.value.scrollHeight + 120
    })
  }
  utils.call(next, 'GetLuaVmLog', [luavm])
}

function clearLog() {
  utils.call(null, 'ClearLuaVmLog', [luavm])
}

function removeLuaVm() {
  utils.call(null, 'RemoveLuaVm', [luavm])
}

function runScript() {

  const script = scriptContent.value
  const name = scriptName.value

  removeLuaVm()
  const next = function (handle) {
    luavm = handle
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
  const name = scriptName.value
  const script = scriptContent.value
  const cache = scriptCache.value[name]
  if (script && script.length > 0 && script !== cache) {
    Swal.fire(t('scriptNoSavedYet'))
  } else {
    scriptContent.value = ''
    scriptName.value = ''
  }
}

onMounted(() => {
  loadScriptsFromServer()
  logUpdater = setInterval(updateLog, 1000)
})

onUnmounted(() => {
  clearInterval(logUpdater)
  removeLuaVm()
})

</script>

<template>
  <div
    class="dark:bg-slate-700 bg-slate-300 left-0 md:left-56 opacity-95 fixed z-50 flex flex-col right-0 bottom-0 p-2 top-12">
    <!-- toolstrip -->
    <div class="flex w-full dark:bg-slate-600 bg-slate-200 h-10 items-center text-base px-2">
      <label class="mx-1">{{ t('name') }}</label>
      <div class="grow mx-1">
        <input type="text" class="w-full px-2 dark:bg-slate-500 bg-neutral-100" list="scriptname-datalist"
          v-model="scriptName" @change="loadScript" />
        <datalist id="scriptname-datalist" class="dark:bg-slate-600">
          <option v-for="(_, key) in scriptCache" :value="key" class="dark:bg-slate-600"></option>
        </datalist>
      </div>
      <button class="mx-1" @click="newScript"><i class="fas fa-file-code"></i></button>
      <button class="mx-1" @click="saveScript"><i class="fas fa-save"></i></button>
      <button class="mx-1" @click="runScript"><i class="fas fa-play"></i></button>
      <button class="mx-1" @click="stopScript"><i class="fas fa-stop"></i></button>
      <button class="mx-1" @click="abortScript"><i class="fas fa-stop-circle"></i></button>
      <button class="mx-1" @click="clearLog"><i class="fas fa-broom"></i></button>
    </div>
    <div class="flex grow w-full flex-row">
      <div class="grow mr-1 mt-1">
        <textarea class="dark:bg-slate-500 bg-neutral-100 w-full h-full p-2" v-model="scriptContent">
        </textarea>
      </div>
      <div class="w-[30%] ml-1 mt-1">
        <textarea readonly class="dark:bg-slate-600 bg-neutral-200 w-full h-full p-1" v-model="logContent"
          ref="logContainer"></textarea>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
