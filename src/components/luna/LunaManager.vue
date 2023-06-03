<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { VueDraggableNext } from 'vue-draggable-next'
import Tooltips from '@/components/widgets/Tooltips.vue'
import utils from '@/misc/utils.js'

const t = utils.getTranslator()

const coreInfos = ref([])
const isCoreSettingsEditorVisible = ref(false)
let curCoreSettings = ref({})
let curCoreName = ''
let refreshTimer = 0

function coreInfoToTag(coreInfo) {
  let r = ''
  if (coreInfo.isAutorun) {
    r += 'A'
  }
  if (coreInfo.isLoadClr) {
    r += 'C'
  }
  if (coreInfo.isHidden) {
    r += 'H'
  }
  return r.length < 1 ? t('none') : r
}

function coreOrderChanged(evt) {
  const infos = coreInfos.value
  const maxIndex = infos.length - 1
  if (maxIndex < 1) {
    return
  }
  const newIndex = evt.moved.newIndex
  const curServ = infos[newIndex]
  let idx = -1
  if (newIndex >= maxIndex) {
    idx = infos[newIndex - 1].index + 0.05
  } else {
    idx = infos[newIndex + 1].index - 0.05
  }
  const next = function (ok) {
    if (!ok) {
      Swal.fire(t('error'))
    }
    refresh()
  }

  const name = curServ.name || ''
  utils.call(next, 'ChangeLuaCoreIndex', [name, idx])
}

function refresh() {
  const next = function (str) {
    try {
      const j = JSON.parse(str)
      coreInfos.value = j
    } catch (err) {
      Swal.fire(err.toString())
    }
  }
  utils.call(next, 'GetAllLuaCoreInfos')
}

function stopCore(name) {
  utils.call(refresh, 'StopLuaCore', [name])
}

function startCore(name) {
  utils.call(refresh, 'StartLuaCore', [name])
}

function restartCore(name) {
  utils.call(refresh, 'RestartLuaCore', [name])
}

function abortCore(name) {
  utils.call(refresh, 'AbortLuaCore', [name])
}

function removeCore(name) {
  const title = t('confirmRemoveCore', { name: name })
  const onYes = function () {
    utils.call(refresh, 'RemoveLuaCore', [name])
  }
  utils.confirm(title, onYes)
}

function closeCoreSettingsEditor() {
  isCoreSettingsEditorVisible.value = false
}

function saveCoreSettings() {
  const name = curCoreName || ''
  let info = curCoreSettings.value
  info.index = parseFloat(info.index)
  const settings = JSON.stringify(info)

  const next = function (ok) {
    if (ok) {
      closeCoreSettingsEditor()
      refresh()
    } else {
      Swal.fire(t('failed'))
    }
  }
  utils.call(next, 'ChangeLuaCoreInfo', [name, settings])
}

function editCoreSettings(name) {
  curCoreName = name
  const infos = coreInfos.value
  for (const key in infos) {
    if (infos[key].name === name) {
      curCoreSettings.value = JSON.parse(JSON.stringify(infos[key]))
      isCoreSettingsEditorVisible.value = true
      return
    }
  }
}

onMounted(() => {
  refresh()
  refreshTimer = setInterval(refresh, 1500)
})

onUnmounted(() => {
  clearInterval(refreshTimer)
})
</script>

<template>
  <!-- header -->
  <div class="fixed left-0 right-0 top-12 z-10 flex grow md:left-56">
    <div
      class="table h-6 grow bg-slate-400 text-xs text-neutral-600 dark:bg-slate-500 dark:text-neutral-700"
    >
      <div class="table-cell w-12 px-1 py-0 text-center align-middle">{{ t('status') }}</div>
      <div class="table-cell w-16 px-1 py-0 text-center align-middle">{{ t('index') }}</div>
      <div class="table-cell px-1 py-0 text-center align-middle">{{ t('name') }}</div>
      <div class="table-cell w-16 px-1 py-0 text-center align-middle">{{ t('tags') }}</div>
      <div class="table-cell w-28 px-1 py-0 text-center align-middle">{{ t('controls') }}</div>
    </div>
  </div>

  <!-- empty list -->
  <div v-if="coreInfos.length <= 0" class="flex justify-center">
    <div class="mt-8 text-lg">{{ t('listIsEmpty') }}</div>
  </div>
  <!-- body -->
  <div class="flex flex-col">
    <div class="block h-6 w-full"></div>
    <ul>
      <VueDraggableNext ghost-class="ghost" :list="coreInfos" @change="coreOrderChanged">
        <li
          v-for="coreInfo in coreInfos"
          :key="coreInfo.index"
          class="odd:bg-neutral-200 dark:odd:bg-slate-600"
        >
          <div class="table h-8 w-full grow cursor-grab text-base">
            <div class="table-cell w-12 px-1 py-0 text-center align-middle leading-[0]">
              <button
                v-if="coreInfo.isRunning"
                class="cursor-pointer rounded bg-lime-500 px-1 py-0.5 text-xs text-neutral-100 dark:bg-lime-700 dark:text-neutral-200"
                @click="stopCore(coreInfo.name)"
              >
                ON
              </button>
            </div>
            <div class="table-cell w-16 px-1 py-0 text-center align-middle">
              {{ coreInfo.index }}
            </div>
            <div class="table-cell break-all px-2 py-1 text-left align-middle">
              <button class="whitespace-pre-wrap text-left" @click="startCore(coreInfo.name)">
                {{ coreInfo.name }}
              </button>
            </div>
            <div class="table-cell w-16 text-center align-middle leading-[0]">
              <div
                class="mx-0.5 my-0.5 inline-block w-12 cursor-pointer text-ellipsis rounded bg-cyan-600 px-1 py-0.5 text-center text-xs text-neutral-200 dark:bg-cyan-700 dark:text-neutral-300"
                @click="editCoreSettings(coreInfo.name)"
              >
                {{ coreInfoToTag(coreInfo) }}
              </div>
            </div>
            <div class="table-cell w-28 px-1 py-0 text-center align-middle text-lg">
              <button class="mx-1 my-0" @click="startCore(coreInfo.name)">
                <i class="fas fa-chevron-right"></i>
              </button>
              <Tooltips :css="'mt-6'" :tip="t('restart')">
                <button class="mx-1 my-0" @click="restartCore(coreInfo.name)">
                  <i class="fas fa-sync"></i>
                </button>
              </Tooltips>
              <Tooltips :css="'mt-6 right-2'" :tip="t('terminate')">
                <button class="mx-1 my-0" @click="abortCore(coreInfo.name)">
                  <i class="fas fa-stop-circle"></i>
                </button>
              </Tooltips>
              <button class="mx-1 my-0" @click="removeCore(coreInfo.name)">
                <i class="fas fa-trash-alt"></i>
              </button>
            </div>
          </div>
        </li>
      </VueDraggableNext>
    </ul>
    <div class="block h-10 grow"></div>
  </div>

  <!-- core settings -->
  <div
    v-if="isCoreSettingsEditorVisible"
    class="fixed bottom-0 left-0 right-0 top-0 z-50 flex flex-col bg-slate-300 p-4 opacity-95 dark:bg-slate-700 md:left-56"
  >
    <div class="block h-4/5 w-full grow bg-neutral-200 p-4 dark:bg-slate-600">
      <div class="flex h-9 items-center">
        <div class="w-24 px-4 py-0">{{ t('index') }}</div>
        <div class="flex grow px-4 py-0">
          <input
            type="text"
            v-model="curCoreSettings.index"
            class="grow bg-neutral-100 dark:bg-slate-500"
          />
        </div>
      </div>
      <div class="flex h-9 items-center">
        <div class="w-24 px-4 py-0">{{ t('name') }}</div>
        <div class="flex grow px-4 py-0">
          <input
            type="text"
            v-model="curCoreSettings.name"
            class="grow bg-neutral-100 dark:bg-slate-500"
          />
        </div>
      </div>
      <div class="flex h-9 items-center">
        <div class="w-24 px-4 py-0">{{ t('autorun') }}</div>
        <div class="flex grow px-4 py-0">
          <input type="checkbox" v-model="curCoreSettings.isAutorun" class="h-4 w-4" />
        </div>
      </div>
      <div class="flex h-9 items-center">
        <div class="w-24 px-4 py-0">{{ t('hidden') }}</div>
        <div class="flex grow px-4 py-0">
          <input type="checkbox" v-model="curCoreSettings.isHidden" class="h-4 w-4" />
        </div>
      </div>
      <div class="flex h-9 items-center">
        <div class="w-24 px-4 py-0">{{ t('loadClr') }}</div>
        <div class="flex grow px-4 py-0">
          <input type="checkbox" v-model="curCoreSettings.isLoadClr" class="h-4 w-4" />
        </div>
      </div>
    </div>
    <div class="flex h-10 w-full items-end justify-center">
      <button @click="saveCoreSettings" class="mx-4 my-0">{{ t('save') }}</button>
      <button @click="closeCoreSettingsEditor" class="mx-4 my-0">{{ t('close') }}</button>
    </div>
  </div>
</template>

<style scoped>
.ghost {
  opacity: 60%;
  background-color: rgb(100, 116, 139);
}
</style>
