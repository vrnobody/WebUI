<script setup>
import utils from '../misc/utils.js'
import { onMounted, onUnmounted, ref, defineAsyncComponent, nextTick } from 'vue'
import { VueDraggableNext } from 'vue-draggable-next'

import ConfigEditor from '../components/servers/ConfigEditor.vue'
import LogViewer from '../components/servers/LogViewer.vue'
import SettingsEditor from '../components/servers/SettingsEditor.vue'
import FadeTransition from '../components/transitions/FadeTransition.vue'
import LoadingWidget from '../components/widgets/Loading.vue'

import Tooltips from '@/components/widgets/Tooltips.vue'

import DropdownMenu from 'v-dropdown-menu'
import '@/assets/v-dropdown-menu.css'

const VPagination = defineAsyncComponent(() => import("@hennge/vue3-pagination"))

const t = utils.getTranslator()


const curPageNum = ref(1)
const curPageNumText = ref('1')
const pages = ref(0)
const searchType = ref("summary")
const searchKeyword = ref("")
const isLoading = ref(true)
const curServUid = ref('')
const curServTitle = ref('')

let servsInfo = ref([])
const servsCount = ref(0)
const servsSelected = ref(0)
let curSelection = '{}'

const hWnds = {
  logViwer: ref(false),
  configEditor: ref(false),
  settingsEditor: ref(false),
}

function saveSelectionLater() {
  const servs = servsInfo.value
  const selection = {}
  for (let index = 0; index < servs.length; index++) {
    const serv = servs[index]
    selection[serv.uid] = serv.selected
  }

  const cs = JSON.stringify(selection)
  curSelection = cs
  setTimeout(() => {
    if (curSelection !== cs) {
      // pass
      return
    }
    utils.call(refresh, 'ChangeSelection', [cs])
  }, 1000);
}

function selectAll(isCurPage) {
  if (isCurPage) {
    for (const serv of servsInfo.value) {
      serv.selected = true
    }
    saveSelectionLater()
    return
  }
  utils.call(refresh, 'SelectAllServers')
}

function selectTimeoutGlobal() {
  utils.call(refresh, 'SelectAllTimeoutedServers')
}

function invertSelection(isCurPage) {
  if (isCurPage) {
    for (const serv of servsInfo.value) {
      serv.selected = !serv.selected
    }
    saveSelectionLater()
    return
  }
  utils.call(refresh, 'InvertSelectionGlobal')
}

function sortSelectedBy(condition) {
  const count = servsSelected.value
  if (count < 1) {
    Swal.fire(t('noServerSelected'))
    return
  }

  let fn = 'SortSelectedByLatency'
  switch (condition) {
    case 'time':
      fn = 'SortSelectedByModifyTime'
      break;
    case 'summary':
      fn = 'SortSelectedBySummary'
      break;
    case 'latency':
      break;
    default:
      break;
  }
  utils.call(refresh, fn)
}

function deleteSelected() {
  const count = servsSelected.value

  if (count < 1) {
    Swal.fire(t('noServerSelected'))
    return
  }

  const next = function () {
    const msg = t('serversDeleted')
    Swal.fire(msg)
    refresh()
  }

  const title = t('confirmDeleteNServers', { count: count })
  utils.confirm(title, function () {
    utils.call(next, 'DeleteSelectedServers')
  })
}

function stopServ(uid) {
  utils.call(refresh, "StopServ", [uid])
}

function restartServ(uid) {
  utils.call(refresh, "RestartServ", [uid, true])
}

function restartOneServ(uid) {
  utils.call(refresh, "RestartServ", [uid, false])
}

function search() {
  curPageNum.value = 1
  refresh()
}

function refresh() {
  const next = function (r) {
    curPageNumText.value = curPageNum.value.toString()
    pages.value = r.pages
    servsInfo.value = r.data
    servsCount.value = r.count
    servsSelected.value = r.selected
    isLoading.value = false
  }

  utils.call(next, "GetSerializedServers", [
    curPageNum.value,
    searchType.value,
    searchKeyword.value,
  ])
}

function clearSearchKeyword() {
  searchKeyword.value = ''
  nextTick(refresh)
}

function servOrderChanged(evt) {
  const servs = servsInfo.value
  const maxIndex = servs.length - 1
  if (maxIndex < 1) {
    return
  }
  const newIndex = evt.moved.newIndex
  const curServ = servs[newIndex]
  let idx = -1
  if (newIndex >= maxIndex) {
    idx = servs[newIndex - 1].index + 0.05
  } else {
    idx = servs[newIndex + 1].index - 0.05
  }

  const next = function (ok) {
    if (!ok) {
      Swal.fire(t('error'))
    }
    refresh()
  }

  utils.call(next, "ChangeServIndex", [curServ.uid, idx])
}

function getServTitleByUid(uid) {
  const servs = servsInfo.value
  for (const serv of servs) {
    if (serv.uid === uid) {
      return serv.index + '.[' + utils.trim(serv.name, 18) + ']' + serv.summary
    }
  }
  return null
}

function openWindow(handle, uid) {
  curServUid.value = uid
  curServTitle.value = getServTitleByUid(uid)
  handle.value = true
}

function closeWindow(handle) {
  handle.value = false
  if (handle !== hWnds.logViwer) {
    refresh()
  }
}

function isShowPopWindow() {
  for (const key in hWnds) {
    if (hWnds[key].value) {
      return true
    }
  }
  return false
}

function jumpToPage() {
  const pn = Math.floor(parseFloat(curPageNumText.value)) || 1
  curPageNum.value = pn
  refresh()
}

onMounted(() => {
  refresh()
})

onUnmounted(() => {
})
</script>

<template>
  <!-- toolstrip -->
  <div class="md:left-56 left-8 top-0 h-12 py-0 px-4 flex grow justify-left items-center fixed z-20">
    <div class="hidden sm:flex">
      <select v-model="searchType" class="dark:bg-slate-500 bg-neutral-50 w-20 md:w-24 inline-block">
        <option value="summary" selected>{{ t('summary') }}</option>
        <option value="title">{{ t('title') }}</option>
        <option value="tags">{{ t('tags') }}</option>
        <option value="index">{{ t('index') }}</option>
      </select>
      <div class="relative">
        <input v-model="searchKeyword" @keyup.enter="search" type="text"
          class="dark:bg-slate-500 bg-neutral-50 w-40 md:w-48 my-0 mx-4" :placeholder="t('search')" />
        <div class="dark:text-neutral-700 absolute m-0 right-6 top-0 text-neutral-300">
          <button @click="clearSearchKeyword"><i class="fas fa-search"></i></button>
        </div>
      </div>
    </div>
    <div class="dark:bg-slate-500 bg-slate-200 h-3/4 w-0.5 m-1"></div>
    <div class="m-0 text-2xl">
      <DropdownMenu withDropdownCloser>
        <template #trigger>
          <button class="my-0 mx-1"><i class="fas fa-check-circle"></i></button>
        </template>
        <template #body>
          <ul class="dark:bg-slate-600 bg-slate-300 dark:text-neutral-300 text-neutral-700 text-base p-2">
            <li>
              <span class="text-sm dark:text-neutral-400 text-neutral-500">{{ t('curPage') }}</span>
            </li>
            <li>
              <hr>
            </li>
            <li><button @click="selectAll(true)" dropdown-closer>{{ t('selectAll') }}</button></li>
            <li class="h-2"></li>
            <li>
              <span class="text-sm dark:text-neutral-400 text-neutral-500">{{ t('global') }}</span>
            </li>
            <li>
              <hr>
            </li>
            <li><button @click="selectAll(false)" dropdown-closer>{{ t('selectAll') }}</button></li>
            <li><button @click="selectTimeoutGlobal()" dropdown-closer>{{ t('selectTimeout') }}</button></li>
          </ul>
        </template>
      </DropdownMenu>
      <DropdownMenu withDropdownCloser>
        <template #trigger>
          <button class="my-0 mx-1"><i class="fas fa-adjust"></i></button>
        </template>
        <template #body>
          <ul class="dark:bg-slate-600 bg-slate-300 dark:text-neutral-300 text-neutral-700 text-base p-2">
            <li><button @click="invertSelection(true)" dropdown-closer>{{ t('invertSelection') }} ({{ t('curPage')
            }})</button></li>
            <li><button @click="invertSelection(false)" dropdown-closer>{{ t('invertSelection') }} ({{ t('global')
            }})</button></li>
          </ul>
        </template>
      </DropdownMenu>
    </div>
    <div class="dark:bg-slate-500 bg-slate-200 h-3/4 w-0.5 m-1"></div>
    <div class="m-0 text-2xl">
      <DropdownMenu withDropdownCloser>
        <template #trigger>
          <button class="my-0 mx-1"><i class="fas fa-sort-alpha-down"></i></button>
        </template>
        <template #body>
          <ul class="dark:bg-slate-600 bg-slate-300 dark:text-neutral-300 text-neutral-700 text-base p-2">
            <li><button @click="sortSelectedBy('latency')" dropdown-closer>{{ t('sortSelectedByLatency') }}</button></li>
            <li><button @click="sortSelectedBy('time')" dropdown-closer>{{ t('sortSelectedByModifyTime') }}</button></li>
            <li><button @click="sortSelectedBy('summary')" dropdown-closer>{{ t('sortSelectedBySummary') }}</button></li>
          </ul>
        </template>
      </DropdownMenu>
      <Tooltips :css="'mt-8'" :tip="t('newConfig')">
        <button @click="openWindow(hWnds.configEditor, null)" class="my-0 mx-1"><i class="fas fa-plus"></i></button>
      </Tooltips>
      <button @click="deleteSelected" class="my-0 mx-1"><i class="fas fa-trash-alt"></i></button>
    </div>
    <div class="dark:bg-slate-500 bg-slate-200 h-3/4 w-0.5 m-1"></div>
    <div class="m-0 text-2xl">
      <Tooltips :css="'mt-8 w-24'" :tip="t('viewLogs')">
        <button @click="openWindow(hWnds.logViwer, null)" class="my-0 mx-1"><i class="fas fa-file-alt"></i></button>
      </Tooltips>
    </div>
  </div>

  <!-- header -->
  <div class="left-0 md:left-56 flex fixed top-12 right-0 grow z-10">
    <div class="dark:bg-slate-500 dark:text-neutral-700 grow bg-slate-400 text-xs text-neutral-600 table h-6">
      <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('status') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('select') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ t('index') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center">{{ t('title') }}</div>
      <div class="hidden sm:table-cell  py-0 px-1 align-middle text-center w-60 lg:w-[28%]">{{ t('summary') }}
      </div>
      <div class="hidden lg:table-cell py-0 px-1 align-middle text-center w-56">{{ t('tags') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center w-32">{{ t('controls') }}</div>
    </div>
  </div>

  <!-- loading -->
  <LoadingWidget v-if="isLoading" />

  <!-- empty list -->
  <div v-if="servsInfo.length <= 0" class="flex justify-center">
    <div v-if="!isLoading" class="text-lg mt-8">{{ t('listIsEmpty') }}</div>
  </div>

  <!-- servers list -->
  <div v-else class="flex flex-col">
    <div class="block w-full h-6"></div>
    <ul>
      <VueDraggableNext ghost-class="ghost" :list="servsInfo" @change="servOrderChanged">
        <li v-for="serv in servsInfo" :key="serv.uid" class="dark:odd:bg-slate-600 odd:bg-neutral-200">
          <div class="cursor-grab grow text-base table w-full h-8">
            <div class="table-cell py-0 px-1 align-middle text-center w-12">
              <div v-if="serv.on"
                class="dark:bg-lime-700 dark:text-neutral-200 bg-lime-500 inline-block text-neutral-100 text-xs py-0.5 px-1 rounded cursor-pointer"
                @click="stopServ(serv.uid)">ON</div>
            </div>
            <div class="table-cell py-0 px-1 align-middle text-center w-12">
              <input type="checkbox" v-model="serv.selected" class="w-4 h-4" @change="saveSelectionLater" />
            </div>
            <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ serv['index'] }}</div>
            <div class="table-cell py-1 px-2 align-middle text-left break-all">
              <p class="whitespace-pre-wrap">{{ serv['name'] }}</p>
            </div>
            <div class="hidden sm:table-cell lg:w-[28%] py-1 px-2 align-middle text-left break-all w-60">{{
              serv['summary']
            }}
            </div>
            <div class="hidden lg:table-cell py-1 px-2 align-middle text-left break-all w-56">
              <div class="flex flex-wrap justify-start">
                <div v-if="serv.tags && serv.tags.length < 1" class="text-base py-0 px-1 cursor-pointer text-blue-400"
                  @click="openWindow(hWnds.settingsEditor, serv.uid)">
                  <i class="fas fa-tags"></i>
                </div>
                <div
                  class="dark:bg-cyan-700 bg-cyan-600 dark:text-neutral-300 text-neutral-200 cursor-pointer rounded inline-block text-xs py-0.5 px-1 max-w-[4.5rem] text-ellipsis overflow-hidden whitespace-nowrap my-0.5 mx-0.5"
                  v-for="tag in serv.tags" @click="openWindow(hWnds.settingsEditor, serv.uid)">{{ tag }}</div>
              </div>
            </div>
            <div class="table-cell py-0 px-1 align-middle text-center w-32">
              <button class="text-xl my-0 mx-1 text-red-700" @click="restartServ(serv.uid)">
                <i class="fa fa-play"></i>
              </button>
              <button class="text-xl my-0 mx-1" @click="restartOneServ(serv.uid)">
                <i class="fas fa-play-circle"></i>
              </button>
              <button class="text-xl my-0 mx-1" @click="openWindow(hWnds.configEditor, serv.uid)">
                <i class="fas fa-edit"></i>
              </button>
              <button class="text-xl my-0 mx-1" @click="openWindow(hWnds.logViwer, serv.uid)">
                <i class="fas fa-file-alt"></i>
              </button>
            </div>
          </div>
        </li>
      </VueDraggableNext>
    </ul>
    <div class="block grow h-14"></div>
  </div>

  <div
    class="dark:bg-slate-500 bg-slate-400 leading-7 align-middle block z-10 md:left-56 left-0 dark:text-neutral-800 text-neutral-600 text-sm fixed bottom-0 right-0 px-2">
    <!-- counter -->
    <div class="float-left">
      {{ t('count') }}: {{ servsCount }} &nbsp; {{ t('selected') }}: {{ servsSelected }}
    </div>

    <!-- pager -->
    <div class="float-right inline-flex" v-if="pages > 1">
      <VPagination v-model="curPageNum" :pages="pages" :range-size="2" active-color="#DCEDFF"
        @update:modelValue="refresh" />
      <input v-model="curPageNumText"
        class="inline-block dark:bg-slate-200 bg-slate-200 text-center text-sm my-1 mx-2 w-12"
        @keyup.enter="jumpToPage" />
      <button @click="jumpToPage" class="inline-block text-sm">{{ t('jump') }}</button>
    </div>
  </div>

  <!-- popup window -->
  <FadeTransition>
    <div v-if="isShowPopWindow()"
      class="transition-transform dark:bg-slate-700 bg-slate-300 left-0 md:left-56 opacity-95 fixed z-50 flex flex-col right-0 bottom-0 p-4 top-0">
      <SettingsEditor v-if="hWnds.settingsEditor.value" @onClose="closeWindow(hWnds.settingsEditor)"
        v-model:uid="curServUid" v-model:title="curServTitle" />
      <ConfigEditor v-if="hWnds.configEditor.value" @onClose="closeWindow(hWnds.configEditor)" v-model:uid="curServUid"
        v-model:title="curServTitle" />
      <LogViewer v-if="hWnds.logViwer.value" @onClose="closeWindow(hWnds.logViwer)" v-model:uid="curServUid"
        v-model:title="curServTitle" />
    </div>
  </FadeTransition>
</template>

<style scoped>
.ghost {
  opacity: 60%;
  background-color: rgb(100, 116, 139);
}
</style>
