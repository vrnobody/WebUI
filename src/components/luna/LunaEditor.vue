<script setup>
import { ref, onMounted, onUnmounted, nextTick, computed, defineAsyncComponent } from 'vue'
import utils from '@/misc/utils.js'

import DropdownMenu from 'v-dropdown-menu'
import Tooltips from '@/components/widgets/Tooltips.vue'
import '@/assets/v-dropdown-menu.css'
import FileBrowser from '@/components/luna/FileBrowser.vue'
import Attacher from '@/components/luna/Attacher.vue'

const LuaEditor = defineAsyncComponent(() => import('./LuaEditor.vue'))

const t = utils.getTranslator()
const scriptName = ref('')
const scriptContent = ref('')
const isEditingLocalFile = ref(false)
const filename = ref('')
const isFileBrowserVisiable = ref(false)
const isAttacherVisiable = ref(false)
const curOp = ref('')

const logContent = ref('')
const scriptDb = ref({})

const isFullScreen = ref(false)
const isLogPanelVisible = ref(false)
const isLoadClr = ref(false)

let luavm = ''

let logContainer = ref(null)

let logUpdater = 0

let lastScriptContent = ''
let lastScriptName = ''

const isTopLevel = computed({
  get() {
    return isFullScreen.value || isFileBrowserVisiable.value || isAttacherVisiable.value
  }
})

function showFileBrowser(op) {
  const cur = scriptContent.value
  const next = function () {
    curOp.value = op
    isFileBrowserVisiable.value = true
  }
  if (lastScriptContent !== cur && op !== 'save') {
    utils.confirm(t('emptyCurScript'), next)
  } else {
    next()
  }
}

function loadScriptFromFile() {
  const fn = filename.value
  const next = function (script) {
    isEditingLocalFile.value = true
    scriptName.value = ''
    scriptContent.value = script
    lastScriptName = ''
    lastScriptContent = script
  }
  utils.call(next, 'ReadFile', [fn])
}

function saveScriptToFile(quiet) {
  const fn = filename.value || ''
  const content = scriptContent.value

  const next = function () {
    isEditingLocalFile.value = true
    scriptName.value = ''
    lastScriptName = ''
    lastScriptContent = content

    if (!quiet) {
      Swal.fire(t('success'))
    }
  }
  utils.call(next, 'WrtieFile', [fn, content])
}

function closeFileBrowser(isExecCurOp) {
  isFileBrowserVisiable.value = false
  const op = curOp.value
  curOp.value = ''
  if (!isExecCurOp) {
    return
  }
  switch (op) {
    case 'load':
      loadScriptFromFile()
      break
    case 'save':
      saveScriptToFile()
  }
}

function saveScript(quiet) {
  if (isEditingLocalFile.value) {
    saveScriptToFile(quiet)
    return
  }
  const name = scriptName.value || ''
  const script = scriptContent.value || ''
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

function loadScriptFromCache() {
  const name = scriptName.value
  const scripts = scriptDb.value
  const load = function (s) {
    isEditingLocalFile.value = false
    scriptContent.value = s
    lastScriptContent = s
    lastScriptName = name
  }
  for (const key in scripts) {
    if (key !== name) {
      continue
    }
    const script = scripts[name]
    const cur = scriptContent.value
    if (lastScriptContent === cur) {
      load(script)
    } else {
      utils.confirm(
        t('replaceCurScript'),
        function () {
          load(script)
        },
        function () {
          scriptName.value = lastScriptName
        }
      )
    }
    return
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

function startLogUpdater() {
  clearInterval(logUpdater)
  logContent.value = ''
  isLogPanelVisible.value = true
  logUpdater = setInterval(updateLog, 1000)
}

function runScript() {
  const name = (isEditingLocalFile.value ? filename.value : scriptName.value) || ''
  const script = scriptContent.value || ''
  const loadClr = isLoadClr.value

  removeLuaVm()
  clearInterval(logUpdater)
  const next = function (handle) {
    luavm = handle
    startLogUpdater()
  }
  utils.call(next, 'RunLuaScript', [name, script, loadClr])
}

function stopScript() {
  utils.call(null, 'StopLuaVm', [luavm])
}

function abortScript() {
  utils.call(null, 'AbortLuaVm', [luavm])
}

function newScript() {
  const cur = scriptContent.value
  const empty = function () {
    isEditingLocalFile.value = false
    scriptContent.value = ''
    scriptName.value = ''
    lastScriptContent = ''
    lastScriptName = ''
  }
  if (lastScriptContent === cur) {
    empty()
  } else {
    utils.confirm(t('emptyCurScript'), empty)
  }
}

function onKeyDown(e) {
  if (e.ctrlKey) {
    switch (e.key) {
      case 's':
        e.preventDefault()
        saveScript(true)
        break
      case 'n':
        // this keyboard shortcut will not work
        e.preventDefault()
        newScript()
        break
    }
    return
  }

  switch (e.key) {
    case 'F5':
      runScript()
      e.preventDefault()
      break
    case 'F6':
      stopScript()
      e.preventDefault()
      break
    case 'F7':
      abortScript()
      e.preventDefault()
      break
    case 'F8':
      clearLog()
      e.preventDefault()
      break
  }
}

function openAttacher() {
  isAttacherVisiable.value = true
}
function closeAttacher() {
  isAttacherVisiable.value = false
}

function attachTo(uid, name) {
  const id = uid || ''
  const n = name || ''
  const next = function (script) {
    isEditingLocalFile.value = false
    luavm = id

    scriptName.value = n
    lastScriptName = n

    scriptContent.value = script
    lastScriptContent = script

    closeAttacher()
    startLogUpdater()
  }
  utils.call(next, 'GetScriptFromLuaVm', [id])
}

function switchEditorMode() {
  lastScriptName = ''
  scriptName.value = ''
  isEditingLocalFile.value = false
}

function onFullScreenHandler(fullScreen) {
  isFullScreen.value = fullScreen
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
</script>

<template>
  <div
    class="fixed bottom-0 right-0 flex flex-col bg-slate-300 p-2 dark:bg-slate-800"
    :class="{
      'left-0 right-0 top-0 z-50': isTopLevel,
      'left-0 top-12 z-20 pt-0 md:left-56': !isTopLevel
    }"
  >
    <!-- toolstrip -->
    <div class="flex h-10 w-full items-center bg-slate-400 px-2 text-base dark:bg-slate-500">
      <label class="mx-1 shrink-0">{{ t(isEditingLocalFile ? 'file' : 'name') }}</label>
      <div class="mx-1 flex grow overflow-hidden">
        <span
          v-if="isEditingLocalFile"
          class="w-full overflow-hidden text-ellipsis whitespace-nowrap px-2"
          >{{ filename }}</span
        >
        <input
          v-else
          type="text"
          class="w-full bg-neutral-100 px-2 dark:bg-slate-600"
          list="scriptname-datalist"
          v-model="scriptName"
          @change="loadScriptFromCache"
        />
        <datalist id="scriptname-datalist" class="dark:bg-slate-600">
          <option
            v-for="(_, key) in scriptDb"
            :key="key"
            :value="key"
            class="dark:bg-slate-600"
          ></option>
        </datalist>
      </div>
      <DropdownMenu withDropdownCloser>
        <template #trigger>
          <button class="mx-1"><i class="fas fa-tools"></i></button>
        </template>
        <template #body>
          <ul class="bg-slate-300 p-2 text-neutral-700 dark:bg-slate-600 dark:text-neutral-300">
            <li>
              <button @click="newScript" dropdown-closer>{{ t('newScript') }}</button>
            </li>
            <li v-if="isEditingLocalFile">
              <button @click="switchEditorMode" dropdown-closer>{{ t('switchEditorMode') }}</button>
            </li>
            <li>
              <button @click="showFileBrowser('load')" dropdown-closer>{{ t('loadFile') }}</button>
            </li>
            <li>
              <button @click="showFileBrowser('save')" dropdown-closer>{{ t('saveAs') }}</button>
            </li>
            <li>
              <button @click="openAttacher" dropdown-closer>{{ t('openAttacher') }}</button>
            </li>
          </ul>
        </template>
      </DropdownMenu>
      <button class="mx-1" @click="saveScript(false)"><i class="fas fa-save"></i></button>
      <button class="mx-1" @click="runScript"><i class="fas fa-play"></i></button>
      <button class="mx-1" @click="stopScript"><i class="fas fa-stop"></i></button>
      <button class="mx-1" @click="abortScript"><i class="fas fa-stop-circle"></i></button>
      <button class="mx-1" @click="clearLog"><i class="fas fa-broom"></i></button>
      <Tooltips :tip="t('allowImportClrLibs')" :css="'right-4 mt-6'">
        <div class="mx-1 inline-flex items-center">
          <input type="checkbox" v-model="isLoadClr" name="is-load-clr" class="mr-1 h-4 w-4" />
          <label for="is-load-clr">CLR</label>
        </div>
      </Tooltips>
    </div>

    <!-- edit area -->
    <div class="flex w-full grow flex-row">
      <div
        class="flex w-[70%] min-w-[20%] resize-x flex-col overflow-auto"
        :class="{ grow: !isLogPanelVisible }"
      >
        <LuaEditor
          v-model:script="scriptContent"
          @onFullScreen="onFullScreenHandler"
          v-model:logPanelVisible="isLogPanelVisible"
        />
      </div>
      <div v-if="isLogPanelVisible" class="ml-1 mt-1 flex grow">
        <textarea
          readonly
          class="grow resize-none bg-neutral-200 p-1 dark:bg-slate-600"
          v-model="logContent"
          ref="logContainer"
        ></textarea>
      </div>
    </div>

    <!-- attacher -->
    <div
      v-if="isAttacherVisiable"
      class="fixed bottom-0 left-0 right-0 top-0 z-50 flex flex-col bg-slate-300 p-4 text-neutral-700 dark:bg-slate-700 dark:text-neutral-300"
    >
      <Attacher @onAttach="attachTo" @onClose="closeAttacher" />
    </div>

    <!-- file browser -->
    <div
      v-if="isFileBrowserVisiable"
      class="fixed bottom-0 left-0 right-0 top-0 z-50 flex flex-col bg-slate-300 p-4 text-neutral-700 dark:bg-slate-600 dark:text-neutral-300"
    >
      <FileBrowser
        v-model:filename="filename"
        v-model:op="curOp"
        @onSave="closeFileBrowser(true)"
        @onClose="closeFileBrowser(false)"
      />
    </div>
  </div>
</template>

<style scoped></style>
