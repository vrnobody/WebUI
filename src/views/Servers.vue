<script setup>
import { useI18n } from '@yangss/vue3-i18n'
import utils from '../misc/utils.js'
import { onMounted, ref, defineAsyncComponent } from 'vue'
import { VueDraggableNext } from 'vue-draggable-next'

const VPagination = defineAsyncComponent(() => import("@hennge/vue3-pagination"))

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

function GenSaveButtonText() {
  if (curServUid && curServUid.length > 0) {
    return t('save')
  }
  return t('add')
}

let isServSettingsEditorVisible = ref(false)
let servSettings = ref({})

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
      Swal.fire(err)
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
  selectedUids = {}
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
  <div class="header-wrapper">
    <div class="header">
      <div class="align-center status">{{ t('status') }}</div>
      <div class="align-center server-selector">{{ t('select') }}</div>
      <div class="align-center index">{{ t('index') }}</div>
      <div class="align-center">{{ t('title') }}</div>
      <div class="align-center summary">{{ t('summary') }}</div>
      <div class="align-center tags">{{ t('tags') }}</div>
      <div class="align-center controls">{{ t('controls') }}</div>
    </div>
  </div>
  <div class="main-div">
    <div class="head-blank"></div>
    <ul>
      <VueDraggableNext ghost-class="ghost" :list="data" @change="servOrderChanged">
        <li v-for="serv in data" :key="serv.uid">
          <div class="server-list">
            <div class="align-center status">
              <div v-if="serv.on" class="round-div" @click="stopServ(serv.uid)">ON</div>
            </div>
            <div class="align-center server-selector">
              <input type="checkbox" v-model="serv.selected" />
            </div>
            <div class="align-center index">{{ serv['index'] }}</div>
            <div class="align-left">
              <p style="white-space: pre-wrap">{{ serv['name'] }}</p>
            </div>
            <div class="align-left summary">{{ serv['summary'] }}</div>
            <div class="align-left tags">
              <div class="tags-content">
                <div v-if="serv.tags && serv.tags.length < 1" class="add-tags" @click="editServSettings(serv.uid)">
                  <i class="fas fa-tags"></i>
                </div>
                <div class="round-tag" v-for="tag in serv.tags" @click="editServSettings(serv.uid)">{{ tag }}</div>
              </div>
            </div>
            <div class="align-center controls">
              <button style="color: darkred;" @click="restartServ(serv.uid)">
                <i class="fa fa-play"></i>
              </button>
              <button style="color: black" @click="editServConfig(serv.uid)">
                <i class="fas fa-edit"></i>
              </button>
            </div>
          </div>
        </li>
      </VueDraggableNext>
    </ul>
    <div class="bottom-blank"></div>
  </div>
  <div class="tools-strip">
    <div class="searcher">
      <select v-model="searchType" class="search-selector">
        <option value="summary" selected>{{ t('summary') }}</option>
        <option value="title">{{ t('title') }}</option>
        <option value="tags">{{ t('tags') }}</option>
        <option value="index">{{ t('index') }}</option>
      </select>
      <div style="position:relative;">
        <input v-model="searchKeyword" @keyup.enter="search" type="text" class="search-box" :placeholder="t('search')" />
        <div class="search-icon">
          <i class="fas fa-search"></i>
        </div>
      </div>
    </div>
    <div class="vertical-line"></div>
    <div class="tools-icons">
      <button @click="selectAll"><i class="fas fa-check-circle"></i></button>
      <button @click="invertSelection"><i class="fas fa-adjust"></i></button>
    </div>
    <div class="vertical-line"></div>
    <div class="tools-icons">
      <button @click="openEmptyJsonEditor"><i class="fas fa-plus"></i></button>
      <button @click="deleteSelected"><i class="fas fa-trash-alt"></i></button>
    </div>
  </div>
  <div class="pager" v-if="pages > 1">
    <VPagination v-model="curPageNum" :pages="pages" :range-size="2" active-color="#DCEDFF"
      @update:modelValue="refresh" />
    <input v-model="curPageNum" class="text-current-page-number" @keyup.enter="refresh" />
    <button @click="refresh" class="jump-button">{{ t('jump') }}</button>
  </div>
  <div v-if="isServSettingsEditorVisible" class="editor-wrapper">
    <div class="editor-content-wrapper" style="background-color: darkgray; padding: 1rem;">
      <div v-for="key in servSettingKeys">
        <div class="serv-setting-line">
          <div class="serv-setting-key">{{ key }}</div>
          <div class="serv-setting-value">
            <input type="text" v-model="servSettings[key]" class="serv-setting-text-box" />
          </div>
        </div>
      </div>

    </div>
    <div class="editor-buttons-wrapper">
      <button @click="saveServSettings">{{ t('save') }}</button>
      <button @click="closeServSettingsEditor">{{ t('close') }}</button>
    </div>
  </div>
  <div v-if="isJsonEditorVisible" class="editor-wrapper">
    <div class="editor-content-wrapper">
      <textarea v-on:keydown="bindJsonEditorKeydownEvent($event)" class="editor-content" v-model="servConfig" />
    </div>
    <div class="editor-buttons-wrapper">
      <button @click="saveServConfig">{{ GenSaveButtonText() }}</button>
      <button @click="closeJsonEditor">{{ t('close') }}</button>
    </div>
  </div>
</template>

<style scoped>
.serv-setting-line {
  height: 2.2rem;
  display: flex;
  align-items: center;
}

.serv-setting-key {
  width: 6rem;
  padding: 0rem 1rem;

}

.serv-setting-value {
  display: flex;
  flex-grow: 1;
  padding: 0rem 1rem;

}

.serv-setting-text-box {
  flex-grow: 1;
}

.search-icon {
  position: absolute;
  margin: 0rem;
  right: 1.5rem;
  top: 0rem;
  color: lightgray;
}

.ghost {
  opacity: 0.8;
  background: #666;
}

@media (max-width: 600px) {
  body .summary {
    display: none;
  }

  body .searcher {
    display: none;
  }

}


@media (max-width: 800px) {

  body .tags {
    display: none;
  }

  body .header-wrapper {
    left: 0rem;
  }

  body .tools-strip {
    left: 2rem;
  }

  body .search-selector {
    width: 5rem;
  }

  body .search-box {
    width: 10rem;
  }

  body .editor-wrapper {
    left: 0rem;
  }
}


.tools-icons button {
  margin: 0rem 0.2rem;
}

.tools-icons {
  font-size: 1.5rem;
  margin: 0rem;
}

.vertical-line {
  background-color: #ddd;
  height: 70%;
  width: 0.1rem;
  margin: 0.3rem;
}

.editor-buttons-wrapper button {
  margin: 0rem 1rem;
}

.editor-buttons-wrapper {
  width: 100%;
  height: 2.5rem;
  align-items: end;
  justify-content: center;
  display: flex;
}

.editor-content {
  width: 100%;
  background-color: ivory;
  height: 100%;
}

.editor-content-wrapper {
  display: block;
  flex-grow: 1;
  width: 100%;
  height: 92%;
}

.editor-wrapper {
  background-color: #666;
  opacity: 0.95;
  position: fixed;
  z-index: 500;
  display: flex;
  flex-direction: column;
  right: 0rem;
  bottom: 0rem;
  left: 14rem;
  padding: 1rem;
  top: 0rem;
}

.controls button {
  font-size: 1.2rem;
  margin: 0rem 0.2rem;
}

.search-selector {
  color: #777;
  width: 6rem;
  display: inline-block;
}

.search-box {
  width: 12rem;
  margin: 0rem 1rem;
  display: inline-block;
}

.jump-button {
  font-size: 0.8rem;
}

.text-current-page-number {
  text-align: center;
  font-size: 0.8rem;
  margin: 0.2rem 0.5rem;
  width: 3rem;
}

.bottom-blank {
  display: block;
  flex-grow: 1;
  height: 2.5rem;
}

.searcher {
  display: flex;
}

.tools-strip {
  top: 0rem;
  height: 3rem;
  left: 14rem;
  padding: 0rem 1rem;
  display: flex;
  flex-grow: 1;
  justify-content: left;
  align-items: center;
  position: fixed;
  z-index: 200;
}

.pager {
  height: 2rem;
  padding: 0rem 1.2rem;
  display: flex;
  flex-grow: 1;
  justify-content: left;
  align-items: center;
  position: fixed;
  z-index: 200;
  right: 0rem;
  background-color: #eee;
  bottom: 0rem;
}

.round-div {
  background-color: orange;
  display: inline-block;
  color: white;
  font-size: 0.6rem;
  padding: 0.1rem 0.3rem;
  border-radius: 0.3rem;
  cursor: pointer;
}

ul {
  margin: 0rem;
  padding: 0rem;
  list-style-type: none;
}

li {
  margin: 0rem;
  padding: 0rem;
}

li:nth-child(odd) {
  background-color: #e6e6e6;
}

.add-tags {
  font-size: 1rem;
  padding: 0rem 0.3rem;
  cursor: pointer;
  color: cornflowerblue;
}

.server-list {
  cursor: grab;
  flex-grow: 1;
  font-size: 1rem;
  display: table;
  width: 100%;
  height: 2rem;
}

.server-selector {
  width: 3rem;
}

.status {
  width: 3rem;
}

.index {
  width: 4rem;
}

.summary {
  width: 28%;
}

.tags {
  width: 18%;
}

.tags-content {
  display: flex;
  flex-wrap: wrap;
  justify-content: start;
}

.round-tag {
  cursor: pointer;
  background-color: powderblue;
  display: inline-block;
  color: gray;
  font-family: monospace;
  font-size: 0.6rem;
  padding: 0.05rem 0.3em;
  border-radius: 0.2rem;
  max-width: 5rem;
  text-overflow: ellipsis;
  overflow: hidden;
  white-space: nowrap;
  margin: 0.1rem 0.2rem;
}

.controls {
  width: 4rem;
}

.align-left {
  display: table-cell;
  padding: 0.2rem 0.5rem;
  vertical-align: middle;
  text-align: left;
  overflow-wrap: anywhere;
}

.align-center {
  display: table-cell;
  padding: 0rem 0.2rem;
  vertical-align: middle;
  text-align: center;
}

.head-blank {
  display: block;
  width: 100%;
  height: 1.5rem;
}

.header-wrapper {
  display: flex;
  position: fixed;
  top: 3rem;
  left: 14rem;
  right: 0rem;
  flex-grow: 1;
  z-index: 100;
}

.header {
  flex-grow: 1;
  background-color: #eee;
  font-size: 0.8rem;
  color: darkgray;
  display: table;
  height: 1.5rem;
}

.main-div {
  display: flex;
  flex-flow: column;
}
</style>
