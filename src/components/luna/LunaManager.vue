<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import utils from '../../misc/utils.js'
import { useI18n } from '@yangss/vue3-i18n'
import { VueDraggableNext } from 'vue-draggable-next'

const { _, t } = useI18n()

const coreInfos = ref([])
const isCoreSettingsEditorVisible = ref(false)
let curCoreSettings = ref({})
let curCoreName = ""
let refreshTimer = 0

function coreInfoToTag(coreInfo) {
  let r = ""
  if (coreInfo.isAutorun) {
    r += "A"
  }
  if (coreInfo.isLoadClr) {
    r += "C"
  }
  if (coreInfo.isHidden) {
    r += "H"
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

  utils.call(next, "ChangeLuaCoreIndex", [curServ.name, idx])
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
  const name = curCoreName
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
  <div class="">
    <!-- header -->
    <div class="left-0 md:left-56 flex fixed top-12 right-0 grow z-10">
      <div class="dark:bg-slate-500 dark:text-neutral-700 grow bg-slate-400 text-xs text-neutral-600 table h-6">
        <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('status') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ t('index') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center">{{ t('name') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ t('tags') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center w-20">{{ t('controls') }}</div>
      </div>
    </div>

    <!-- empty list -->
    <div v-if="coreInfos.length <= 0" class="flex justify-center">
      <div class="text-lg mt-8">{{ t('listIsEmpty') }}</div>
    </div>
    <!-- body -->
    <div class="flex flex-col">
      <div class="block w-full h-6"></div>
      <ul>
        <VueDraggableNext ghost-class="ghost" :list="coreInfos" @change="coreOrderChanged">
          <li v-for="coreInfo in coreInfos" :key="coreInfo.index" class="dark:odd:bg-slate-600 odd:bg-neutral-200">
            <div class="cursor-grab grow text-base table w-full h-8">
              <div class="table-cell py-0 px-1 align-middle text-center w-12">
                <div v-if="coreInfo.isRunning"
                  class="dark:bg-lime-700 dark:text-neutral-200 bg-lime-500 inline-block text-neutral-100 text-xs py-0.5 px-1 rounded cursor-pointer"
                  @click="stopCore(coreInfo.name)">ON</div>
              </div>
              <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ coreInfo.index }}</div>
              <div class="table-cell py-1 px-2 align-middle text-left break-all">
                <p class="whitespace-pre-wrap">{{ coreInfo.name }}</p>
              </div>
              <div class="table-cell align-middle text-center w-16">
                <div
                  class="dark:bg-cyan-700 bg-cyan-600 dark:text-neutral-300 text-neutral-200 cursor-pointer rounded inline-block text-xs py-0.5 px-1 text-center w-12 text-ellipsis my-0.5 mx-0.5"
                  @click="editCoreSettings(coreInfo.name)">{{ coreInfoToTag(coreInfo) }}</div>
              </div>
              <div class="table-cell py-0 px-1 align-middle text-center w-20">
                <button class="text-xl my-0 mx-1 text-red-700" @click="startCore(coreInfo.name)">
                  <i class="fa fa-play"></i>
                </button>
                <button class="text-xl my-0 mx-1" @click="removeCore(coreInfo.name)">
                  <i class="fas fa-trash-alt"></i>
                </button>
              </div>
            </div>
          </li>
        </VueDraggableNext>
      </ul>
      <div class="block grow h-10"></div>
    </div>
    <div v-if="isCoreSettingsEditorVisible"
      class="dark:bg-slate-700 bg-slate-300 left-0 md:left-56 opacity-95 fixed z-50 flex flex-col right-0 bottom-0 p-4 top-0">
      <div class="dark:bg-slate-600 block grow w-full h-4/5 p-4 bg-neutral-200">
        <div class="flex items-center h-9">
          <div class="py-0 px-4 w-24">{{ t('index') }}</div>
          <div class="flex grow py-0 px-4">
            <input type="text" v-model="curCoreSettings.index" class="dark:bg-slate-500 bg-neutral-100 grow" />
          </div>
        </div>
        <div class="flex items-center h-9">
          <div class="py-0 px-4 w-24">{{ t('name') }}</div>
          <div class="flex grow py-0 px-4">
            <input type="text" v-model="curCoreSettings.name" class="dark:bg-slate-500 bg-neutral-100 grow" />
          </div>
        </div>
        <div class="flex items-center h-9">
          <div class="py-0 px-4 w-24">{{ t('autorun') }}</div>
          <div class="flex grow py-0 px-4">
            <input type="checkbox" v-model="curCoreSettings.isAutorun" class="w-4 h-4" />
          </div>
        </div>
        <div class="flex items-center h-9">
          <div class="py-0 px-4 w-24">{{ t('hidden') }}</div>
          <div class="flex grow py-0 px-4">
            <input type="checkbox" v-model="curCoreSettings.isHidden" class="w-4 h-4" />
          </div>
        </div>
        <div class="flex items-center h-9">
          <div class="py-0 px-4 w-24">{{ t('loadClr') }}</div>
          <div class="flex grow py-0 px-4">
            <input type="checkbox" v-model="curCoreSettings.isLoadClr" class="w-4 h-4" />
          </div>
        </div>
      </div>
      <div class="flex w-full h-10 justify-center items-end">
        <button @click="saveCoreSettings" class="my-0 mx-4">{{ t('save') }}</button>
        <button @click="closeCoreSettingsEditor" class="my-0 mx-4">{{ t('close') }}</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.ghost {
  opacity: 60%;
  background-color: rgb(100, 116, 139);
}
</style>
