<script setup>
import { useI18n } from '@yangss/vue3-i18n'
import utils from '../misc/utils.js'
import { onMounted, ref, defineAsyncComponent } from 'vue'
import { VueDraggableNext } from 'vue-draggable-next'

const VPagination = defineAsyncComponent(() => import("@hennge/vue3-pagination"))
const JsonEditor = defineAsyncComponent(() => import("../components/JsonEditor.vue"))

const { _, t } = useI18n()
const servSettingKeys = ["index", "name", "mark", "remark", "tag1", "tag2", "tag3"]

let curPageNum = ref(1)
let pages = ref(15)
let searchType = ref("summary")
let searchKeyword = ref("")

let data = ref([])

let isJsonEditorVisible = ref(false)
let servConfig = ref("")
let curServUid = ""
let isServSettingsEditorVisible = ref(false)
let servSettings = ref({})

function GenSaveButtonText() {
  if (curServUid && curServUid.length > 0) {
    return t('save')
  }
  return t('add')
}

function editServSettings(uid) {
  curServUid = uid
  const next = function (tags) {
    if (tags) {
      servSettings.value = tags
      isServSettingsEditorVisible.value = true
      return
    }
    Swal.fire(err.toString())
  }
  utils.call(next, "GetServSettings", [uid])
}

function saveServSettings() {
  const next = function (ok) {
    if (ok) {
      closeServSettingsEditor()
      refresh()
      return
    }
    Swal.fire(t('failed'))
  }
  utils.call(next, "SaveServSettings", [curServUid, servSettings.value])
}

function closeServSettingsEditor() {
  isServSettingsEditorVisible.value = false
}

function editServConfig(uid) {
  curServUid = uid
  let next = function (config) {
    try {
      const j = JSON.parse(config)
      const s = JSON.stringify(j, null, 4)
      servConfig.value = s
      isJsonEditorVisible.value = true
    } catch (err) {
      Swal.fire(err.toString())
    }
  }
  utils.call(next, "GetServerConfig", [uid])
}

function openEmptyJsonEditor() {
  curServUid = ""
  servConfig.value = "{}"
  isJsonEditorVisible.value = true
}

function closeJsonEditor() {
  isJsonEditorVisible.value = false
}

function saveServConfig() {
  let next = function (err) {
    if (err) {
      Swal.fire(t(err))
      return
    }
    isJsonEditorVisible.value = false
    refresh()
  }

  try {
    const config = servConfig.value
    const uid = curServUid
    utils.call(next, "SaveServerConfig", [uid, config])
  } catch (err) {
    Swal.fire(err.toString())
  }
}

function parseServerInfo(r) {
  pages = r.pages
  data.value = r.data
}

function selectAll() {
  for (const serv of data.value) {
    serv.selected = true
  }
}

function invertSelection() {
  for (const serv of data.value) {
    serv.selected = !serv.selected
  }
}

function deleteSelected() {
  let uids = data.value.filter(el => el.selected).map(el => el.uid)
  if (uids.length < 1) {
    Swal.fire(t('noServerSelected'))
    return
  }

  let title = t('confirmDeleteNServers', { count: uids.length })
  let next = function (success) {
    const msg = success ? t('serversDeleted') : t('deleteFailed')
    Swal.fire(msg)
    refresh()
  }
  Swal.fire({
    title: title,
    showDenyButton: true,
    confirmButtonText: t('yes'),
    denyButtonText: t('no'),
  }).then((result) => {
    if (result.isConfirmed) {
      utils.call(next, "DeleteServersByUids", [uids])
    }
  })
}

function stopServ(uid) {
  utils.call(refresh, "StopServ", [uid])
}

function restartServ(uid) {
  utils.call(refresh, "RestartServ", [uid])
}

function search() {
  let pn = 1
  curPageNum.value = pn
  utils.call(parseServerInfo, "GetSerializedServers", [
    pn,
    searchType.value,
    searchKeyword.value,
  ])
}

function refresh() {
  utils.call(parseServerInfo, "GetSerializedServers", [
    curPageNum.value,
    searchType.value,
    searchKeyword.value,
  ])
}

function servOrderChanged(evt) {
  const servs = data.value
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

function insertAtCursor(el, text) {
  text = text || '';
  if (document.selection) {
    // IE
    el.focus();
    var sel = document.selection.createRange();
    sel.text = text;
  } else if (el.selectionStart || el.selectionStart === 0) {
    // Others
    var startPos = el.selectionStart;
    var endPos = el.selectionEnd;
    el.value = el.value.substring(0, startPos) +
      text +
      el.value.substring(endPos, el.value.length);
    el.selectionStart = startPos + text.length;
    el.selectionEnd = startPos + text.length;
  } else {
    el.value += text;
  }

  // vue will not auto-update ref()
  servConfig.value = el.value;
};

function bindJsonEditorKeydownEvent(e) {
  const editor = e.target
  const TABKEY = 9;
  if (e.keyCode == TABKEY) {
    insertAtCursor(editor, "    ");
    if (e.preventDefault) {
      e.preventDefault();
    }
    return false;
  }
}

onMounted(() => {
  refresh()
})
</script>

<template>
  <div class="left-0 md:left-56 flex fixed top-12 right-0 grow z-10">
    <div class="dark:bg-slate-500 dark:text-neutral-700 grow bg-slate-400 text-xs text-neutral-600 table h-6">
      <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('status') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('select') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ t('index') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center">{{ t('title') }}</div>
      <div class="hidden sm:table-cell  py-0 px-1 align-middle text-center w-60 lg:w-[28%]">{{ t('summary') }}
      </div>
      <div class="hidden lg:table-cell py-0 px-1 align-middle text-center w-56">{{ t('tags') }}</div>
      <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ t('controls') }}</div>
    </div>
  </div>
  <div class="flex flex-col">
    <div class="block w-full h-6"></div>
    <ul>
      <VueDraggableNext ghost-class="ghost" :list="data" @change="servOrderChanged">
        <li v-for="serv in data" :key="serv.uid" class="dark:odd:bg-slate-600 odd:bg-neutral-200">
          <div class="cursor-grab grow text-base table w-full h-8">
            <div class="table-cell py-0 px-1 align-middle text-center w-12">
              <div v-if="serv.on"
                class="dark:bg-lime-700 dark:text-neutral-200 bg-lime-500 inline-block text-neutral-100 text-xs py-0.5 px-1 rounded cursor-pointer"
                @click="stopServ(serv.uid)">ON</div>
            </div>
            <div class="table-cell py-0 px-1 align-middle text-center w-12">
              <input type="checkbox" v-model="serv.selected" class="w-4 h-4" />
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
                  @click="editServSettings(serv.uid)">
                  <i class="fas fa-tags"></i>
                </div>
                <div
                  class="dark:bg-cyan-700 bg-cyan-600 dark:text-neutral-300 text-neutral-200 cursor-pointer rounded inline-block text-xs py-0.5 px-1 max-w-[4.5rem] text-ellipsis overflow-hidden whitespace-nowrap my-0.5 mx-0.5"
                  v-for="tag in serv.tags" @click="editServSettings(serv.uid)">{{ tag }}</div>
              </div>
            </div>
            <div class="table-cell py-0 px-1 align-middle text-center w-16">
              <button class="text-xl my-0 mx-1 text-red-700" @click="restartServ(serv.uid)">
                <i class="fa fa-play"></i>
              </button>
              <button class="text-xl my-0 mx-1" @click="editServConfig(serv.uid)">
                <i class="fas fa-edit"></i>
              </button>
            </div>
          </div>
        </li>
      </VueDraggableNext>
    </ul>
    <div class="block grow h-10"></div>
  </div>
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
          <i class="fas fa-search"></i>
        </div>
      </div>
    </div>
    <div class="dark:bg-slate-500 bg-slate-200 h-3/4 w-0.5 m-1"></div>
    <div class="m-0 text-2xl">
      <button @click="selectAll" class="my-0 mx-1"><i class="fas fa-check-circle"></i></button>
      <button @click="invertSelection" class="my-0 mx-1"><i class="fas fa-adjust"></i></button>
    </div>
    <div class="dark:bg-slate-500 bg-slate-200 h-3/4 w-0.5 m-1"></div>
    <div class="m-0 text-2xl">
      <button @click="openEmptyJsonEditor" class="my-0 mx-1"><i class="fas fa-plus"></i></button>
      <button @click="deleteSelected" class="my-0 mx-1"><i class="fas fa-trash-alt"></i></button>
    </div>
  </div>
  <div
    class="dark:bg-slate-800 pagh-8 py-0 px-5 flex grow justify-left items-center fixed z-10 right-0 bottom-0 bg-neutral-200"
    v-if="pages > 1">
    <VPagination v-model="curPageNum" :pages="pages" :range-size="2" class="dark:bg-slate-800" active-color="#DCEDFF"
      @update:modelValue="refresh" />
    <input v-model="curPageNum" class="dark:bg-slate-600 text-center text-sm my-1 mx-2 w-12" @keyup.enter="refresh" />
    <button @click="refresh" class="text-sm">{{ t('jump') }}</button>
  </div>
  <div v-if="isServSettingsEditorVisible"
    class="dark:bg-slate-700 bg-slate-300 left-0 md:left-56 opacity-95 fixed z-50 flex flex-col right-0 bottom-0 p-4 top-0">
    <div class="dark:bg-slate-600 block grow w-full h-4/5 p-4 bg-neutral-200">
      <div v-for="key in servSettingKeys">
        <div class="flex items-center h-9">
          <div class="py-0 px-4 w-24">{{ key }}</div>
          <div class="flex grow py-0 px-4">
            <input type="text" v-model="servSettings[key]" class="dark:bg-slate-500 bg-neutral-100 grow" />
          </div>
        </div>
      </div>
    </div>
    <div class="flex w-full h-10 justify-center items-end">
      <button @click="saveServSettings" class="my-0 mx-4">{{ t('save') }}</button>
      <button @click="closeServSettingsEditor" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
  </div>
  <div v-if="isJsonEditorVisible"
    class="dark:bg-slate-700 bg-slate-300 left-0 md:left-56 opacity-95 fixed z-50 flex flex-col right-0 bottom-0 p-4 top-0">
    <!-- 
      <div class="block grow w-full h-4/5" id="json-editor-container">
      
      <textarea v-on:keydown="bindJsonEditorKeydownEvent($event)" class="dark:bg-slate-500 w-full h-full bg-amber-50"
        v-model="servConfig" />
    </div>
  -->
    <JsonEditor v-model="servConfig" />
    <div class="flex w-full h-10 justify-center items-end">
      <button @click="saveServConfig" class="my-0 mx-4">{{ GenSaveButtonText() }}</button>
      <button @click="closeJsonEditor" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
  </div>
</template>

<style scoped>
.ghost {
  opacity: 60%;
  background-color: rgb(100, 116, 139);
}
</style>
