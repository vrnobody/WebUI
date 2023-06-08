<script setup>
import utils from '@/misc/utils.js'
import config from '@/config.js'
import { onMounted, onUnmounted, ref, defineAsyncComponent, nextTick } from 'vue'
import { VueDraggableNext } from 'vue-draggable-next'

import ConfigEditor from '@/components/servers/ConfigEditor.vue'
import LogViewer from '@/components/servers/LogViewer.vue'
import SettingsEditor from '@/components/servers/SettingsEditor.vue'
import BatchSettingsEditor from '@/components/servers/BatchSettingsEditor.vue'
import FadeTransition from '@/components/transitions/FadeTransition.vue'
import LoadingWidget from '@/components/widgets/Loading.vue'
import QrcodeViewer from '@/components/servers/QrcodeViewer.vue'

import Tooltips from '@/components/widgets/Tooltips.vue'

import DropdownMenu from 'v-dropdown-menu'
import '@/assets/v-dropdown-menu.css'

const VPagination = defineAsyncComponent(() => import('@hennge/vue3-pagination'))

const t = utils.getTranslator()

const curPageNum = ref(1)
const curPageNumText = ref('1')
const pages = ref(0)
const searchType = ref('summary')
const searchKeyword = ref('')
const isLoading = ref(true)
const curServUid = ref('')
const curServTitle = ref('')

let servsInfo = ref([])
const servsCount = ref(0)
const servsSelected = ref(0)
const isTesting = ref(false)

const tagNames = ['isAutoRun', 'status', 'mark', 'remark', 'tag1', 'tag2', 'tag3']

const hWnds = {
    logViwer: ref(false),
    configEditor: ref(false),
    settingsEditor: ref(false),
    qrCodeViwer: ref(false),
    batchSettingsEditor: ref(false)
}

const selections = ref({})

function selectAll(isCurPage) {
    if (isCurPage) {
        for (const serv of servsInfo.value) {
            selections.value[serv.uid] = true
        }
        return
    }

    utils.call(replaceSelections, 'GetAllServersUid')
}

function replaceSelections(uids) {
    selections.value = {}
    for (let uid of uids) {
        selections.value[uid] = true
    }
}

function selectNone(isCurPage) {
    if (isCurPage) {
        for (const serv of servsInfo.value) {
            selections.value[serv.uid] = false
        }
        return
    }
    selections.value = {}
}

function selectNotTestedGlobal() {
    utils.call(replaceSelections, 'GetAllNotTtestedServersUid')
}

function selectNotTimeoutGlobal() {
    utils.call(replaceSelections, 'GetAllNotTimeoutedServersUid')
}

function selectTimeoutGlobal() {
    utils.call(replaceSelections, 'GetAllTimeoutedServersUid')
}

function invertSelection(isCurPage) {
    if (isCurPage) {
        for (const serv of servsInfo.value) {
            selections.value[serv.uid] = !selections.value[serv.uid]
        }
        return
    }
    function next(uids) {
        for (let uid of uids) {
            selections.value[uid] = selections.value[uid] !== true
        }
    }
    utils.call(next, 'GetAllServersUid')
}

function getSelectedUids() {
    const s = selections.value
    return Object.keys(s).filter((k) => s[k])
}

function countSelected() {
    return getSelectedUids().length
}

function sortSelectedBy(condition) {
    if (!isSelectAnyServer()) {
        return
    }

    let fn = 'SortServersByLatency'
    switch (condition) {
        case 'time':
            fn = 'SortServersByModifyDate'
            break
        case 'summary':
            fn = 'SortServersBySummary'
            break
        case 'latency':
            break
        case 'reverse':
            fn = 'ReverseServersByIndex'
            break
        default:
            break
    }

    const uids = getSelectedUids()
    utils.call(refresh, fn, [uids])
}

function openBatchSettingsEditor() {
    if (!isSelectAnyServer()) {
        return
    }
    openWindow(hWnds.batchSettingsEditor, '')
}

function copyShareLinkOfSelectedServers() {
    if (!isSelectAnyServer()) {
        return
    }

    const next = function (links) {
        if (!links) {
            Swal.fire(t('failed'))
            return
        }
        utils.copyToClipboard(links)
        Swal.fire(t('success'))
    }

    const uids = getSelectedUids()
    utils.call(next, 'CopyShareLinkOfServers', [uids])
}

function runLatencyTestOnSelectedServers() {
    if (!isSelectAnyServer()) {
        return
    }

    const next = function (ok) {
        if (ok) {
            refresh()
            return
        }
        Swal.fire(t('failed'))
    }

    const uids = getSelectedUids()
    utils.call(next, 'RunLatencyTestOnServers', [uids])
}

function runLatencyTest(uid) {
    utils.call(refresh, 'RunLatencyTestByUid', [uid])
}

function isSelectAnyServer() {
    const count = countSelected()
    if (count < 1) {
        Swal.fire(t('noServerSelected'))
        return false
    }
    return true
}

function stopLatencyTest() {
    const next = function () {
        Swal.fire(t('ok'))
    }
    utils.call(next, 'StopLatencyTest')
}

function deleteSelected() {
    if (!isSelectAnyServer()) {
        return
    }

    const uids = getSelectedUids()
    const count = uids.length
    const next = function (c) {
        selections.value = {}
        const msg = t('serversDeleted', { count: c })
        Swal.fire(msg)
        refresh()
    }

    const title = t('confirmDeleteNServers', { count: count })
    utils.confirm(title, function () {
        utils.call(next, 'DeleteServByUids', [uids])
    })
}

function deleteServer(uid, name) {
    const next = function (c) {
        selections.value[uid] = false
        const msg = t('serversDeleted', { count: c })
        Swal.fire(msg)
        refresh()
    }

    const onYes = function () {
        utils.call(next, 'DeleteServByUids', [[uid]])
    }

    const msg = t('confirmDelete', { name: name })
    utils.confirm(msg, onYes)
}

function stopServ(uid) {
    utils.call(refresh, 'StopServ', [uid])
}

function restartServ(uid) {
    utils.call(refresh, 'RestartServ', [uid || '', true])
}

function restartOneServ(uid) {
    utils.call(refresh, 'RestartServ', [uid || '', false])
}

function search() {
    curPageNum.value = 1
    refresh(true)
}

let lastRefreshTimestamp = -1
function refresh(isScrollToTop) {
    const next = function (r) {
        curPageNumText.value = curPageNum.value.toString()
        pages.value = r.pages
        servsInfo.value = r.data
        servsCount.value = r.count
        servsSelected.value = r.selected
        isTesting.value = r.isTesting
        isLoading.value = false

        if (isScrollToTop === true) {
            utils.scrollToPageTop()
        }

        if (!isTesting.value) {
            return
        }

        const now = new Date().getTime()
        lastRefreshTimestamp = now
        setTimeout(() => {
            if (lastRefreshTimestamp === now) {
                refresh()
            }
        }, 2000)
    }

    utils.call(next, 'GetSerializedServers', [
        curPageNum.value,
        searchType.value || '',
        searchKeyword.value
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

    const uid = curServ.uid || ''
    utils.call(next, 'ChangeServIndex', [uid, idx])
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
    refresh(true)
}

function copyShareLink(uid) {
    const next = function (link) {
        if (!link) {
            Swal.fire(t('failed'))
            return
        }
        utils.copyToClipboard(link)
        Swal.fire(t('copied'))
    }
    utils.call(next, 'GetShareLink', [uid])
}

function getInboundAndLastModifiedDate(serv) {
    const inbAddr = serv['inbound']
    const tick = serv['modified'] * 1000
    const date = new Date(tick)
    const lang = config.get('lang') || navigator.language
    return inbAddr + '\n' + date.toLocaleString(lang)
}

function countTags(tags) {
    if (!tags) {
        return 0
    }
    let count = 0
    for (var key in tags) {
        if (tags[key]) {
            count++
        }
    }
    return count
}

onMounted(() => {
    refresh()
})

onUnmounted(() => {})
</script>

<template>
    <!-- toolstrip -->
    <div
        class="justify-left fixed left-8 top-0 z-20 flex h-12 grow items-center px-4 py-0 md:left-56"
    >
        <div class="hidden sm:flex">
            <select
                v-model="searchType"
                class="inline-block w-20 border border-neutral-400 bg-neutral-200 dark:bg-slate-600 dark:text-neutral-300 md:w-24"
            >
                <option value="summary" selected>{{ t('summary') }}</option>
                <option value="title">{{ t('title') }}</option>
                <option value="tags">{{ t('tags') }}</option>
                <option value="index">{{ t('index') }}</option>
            </select>
            <div class="relative">
                <input
                    v-model="searchKeyword"
                    @click="$event.target.select()"
                    @keyup.enter="search"
                    type="text"
                    class="mx-4 my-0 w-40 bg-neutral-50 px-1 dark:bg-slate-500 md:w-48"
                    :placeholder="t('search')"
                />
                <div class="absolute right-6 top-0 m-0 text-neutral-300 dark:text-neutral-700">
                    <button @click="clearSearchKeyword"><i class="fas fa-search"></i></button>
                </div>
            </div>
        </div>
        <div class="m-1 h-3/4 w-0.5 bg-slate-200 dark:bg-slate-500"></div>
        <div class="m-0 shrink-0 text-2xl">
            <DropdownMenu withDropdownCloser>
                <template #trigger>
                    <button class="mx-1 my-0"><i class="fas fa-check-circle"></i></button>
                </template>
                <template #body>
                    <ul
                        class="min-w-[10rem] bg-slate-300 p-2 text-base text-neutral-700 dark:bg-slate-600 dark:text-neutral-300"
                    >
                        <li>
                            <span class="text-sm text-neutral-500 dark:text-neutral-400">{{
                                t('curPage')
                            }}</span>
                        </li>
                        <li>
                            <hr />
                        </li>
                        <li>
                            <button @click="selectAll(true)" dropdown-closer>
                                {{ t('selectAll') }}
                            </button>
                        </li>
                        <li>
                            <button @click="invertSelection(true)" dropdown-closer>
                                {{ t('invertSelection') }}
                            </button>
                        </li>
                        <li>
                            <button @click="selectNone(true)" dropdown-closer>
                                {{ t('selectNone') }}
                            </button>
                        </li>
                        <li class="h-2"></li>
                        <li>
                            <span class="text-sm text-neutral-500 dark:text-neutral-400">{{
                                t('global')
                            }}</span>
                        </li>
                        <li>
                            <hr />
                        </li>
                        <li>
                            <button @click="selectAll(false)" dropdown-closer>
                                {{ t('selectAll') }}
                            </button>
                        </li>
                        <li>
                            <button @click="invertSelection(false)" dropdown-closer>
                                {{ t('invertSelection') }}
                            </button>
                        </li>
                        <li>
                            <button @click="selectNone(false)" dropdown-closer>
                                {{ t('selectNone') }}
                            </button>
                        </li>
                        <li>
                            <button @click="selectTimeoutGlobal()" dropdown-closer>
                                {{ t('selectTimeout') }}
                            </button>
                        </li>
                        <li>
                            <button @click="selectNotTimeoutGlobal()" dropdown-closer>
                                {{ t('selectNotTimeout') }}
                            </button>
                        </li>
                        <li>
                            <button @click="selectNotTestedGlobal()" dropdown-closer>
                                {{ t('selectNotTested') }}
                            </button>
                        </li>
                    </ul>
                </template>
            </DropdownMenu>
            <DropdownMenu withDropdownCloser>
                <template #trigger>
                    <button class="mx-1 my-0"><i class="fas fa-sort-alpha-down"></i></button>
                </template>
                <template #body>
                    <ul
                        class="min-w-[10rem] bg-slate-300 p-2 text-base text-neutral-700 dark:bg-slate-600 dark:text-neutral-300"
                    >
                        <li>
                            <button @click="sortSelectedBy('latency')" dropdown-closer>
                                {{ t('sortSelectedByLatency') }}
                            </button>
                        </li>
                        <li>
                            <button @click="sortSelectedBy('time')" dropdown-closer>
                                {{ t('sortSelectedByModifyTime') }}
                            </button>
                        </li>
                        <li>
                            <button @click="sortSelectedBy('summary')" dropdown-closer>
                                {{ t('sortSelectedBySummary') }}
                            </button>
                        </li>
                        <li>
                            <button @click="sortSelectedBy('reverse')" dropdown-closer>
                                {{ t('reverseServersByIndex') }}
                            </button>
                        </li>
                    </ul>
                </template>
            </DropdownMenu>
            <DropdownMenu withDropdownCloser>
                <template #trigger>
                    <button class="mx-1 my-0"><i class="fas fa-angle-double-down"></i></button>
                </template>
                <template #body>
                    <ul
                        class="min-w-[10rem] bg-slate-300 p-2 text-base text-neutral-700 dark:bg-slate-600 dark:text-neutral-300"
                    >
                        <li>
                            <button @click="copyShareLinkOfSelectedServers" dropdown-closer>
                                {{ t('copyShareLinks') }}
                            </button>
                        </li>
                        <li>
                            <button @click="openBatchSettingsEditor" dropdown-closer>
                                {{ t('modifySelected') }}
                            </button>
                        </li>
                        <li>
                            <button @click="runLatencyTestOnSelectedServers" dropdown-closer>
                                {{ t('runLatencyTest') }}
                            </button>
                        </li>
                        <li>
                            <button @click="stopLatencyTest" dropdown-closer>
                                {{ t('stopLatencyTest') }}
                            </button>
                        </li>
                        <li>
                            <button @click="deleteSelected" dropdown-closer>
                                {{ t('deleteSelectedServers') }}
                            </button>
                        </li>
                    </ul>
                </template>
            </DropdownMenu>
        </div>
        <div class="m-1 h-3/4 w-0.5 bg-slate-200 dark:bg-slate-500"></div>
        <div class="m-0 shrink-0 text-2xl">
            <Tooltips :css="'mt-8'" :tip="t('newConfig')">
                <button @click="openWindow(hWnds.configEditor, null)" class="mx-1 my-0">
                    <i class="fas fa-plus"></i>
                </button>
            </Tooltips>
            <Tooltips :css="'mt-8'" :tip="t('viewLogs')">
                <button @click="openWindow(hWnds.logViwer, null)" class="mx-1 my-0">
                    <i class="fas fa-file-alt"></i>
                </button>
            </Tooltips>
        </div>
    </div>

    <!-- header -->
    <div class="fixed left-0 right-0 top-12 z-10 flex grow md:left-56">
        <div
            class="table h-6 grow bg-slate-400 text-xs text-neutral-600 dark:bg-slate-500 dark:text-neutral-700"
        >
            <div class="table-cell w-12 px-1 py-0 text-center align-middle">{{ t('status') }}</div>
            <div class="table-cell w-12 px-1 py-0 text-center align-middle">{{ t('select') }}</div>
            <div class="table-cell w-16 px-1 py-0 text-center align-middle">{{ t('index') }}</div>
            <div class="table-cell px-1 py-0 text-center align-middle">{{ t('title') }}</div>
            <div class="hidden w-60 px-1 py-0 text-center align-middle sm:table-cell lg:w-[28%]">
                {{ t('summary') }}
            </div>
            <div class="hidden w-56 px-1 py-0 text-center align-middle lg:table-cell">
                {{ t('tags') }}
            </div>
            <div class="table-cell w-24 px-1 py-0 text-center align-middle">
                {{ t('controls') }}
            </div>
        </div>
    </div>

    <!-- loading -->
    <LoadingWidget v-if="isLoading" />

    <!-- empty list -->
    <div v-if="servsInfo.length <= 0" class="flex justify-center">
        <div v-if="!isLoading" class="mt-8 text-lg">{{ t('listIsEmpty') }}</div>
    </div>

    <!-- servers list -->
    <div v-else class="flex flex-col">
        <div class="block h-6 w-full"></div>
        <ul>
            <VueDraggableNext ghost-class="ghost" :list="servsInfo" @change="servOrderChanged">
                <li
                    v-for="serv in servsInfo"
                    :key="serv.uid"
                    class="odd:bg-neutral-200 dark:odd:bg-slate-600"
                >
                    <div class="table h-8 w-full grow cursor-grab text-base">
                        <div class="table-cell w-12 px-1 py-0 text-center align-middle leading-[0]">
                            <button
                                v-if="serv.on"
                                class="cursor-pointer rounded bg-lime-500 px-1 py-0.5 text-xs text-neutral-100 dark:bg-lime-700 dark:text-neutral-200"
                                @click="stopServ(serv.uid)"
                            >
                                ON
                            </button>
                        </div>
                        <div class="table-cell w-12 px-1 py-0 text-center align-middle leading-[0]">
                            <input
                                type="checkbox"
                                v-model="selections[serv.uid]"
                                class="inline-block h-4 w-4"
                            />
                        </div>
                        <div class="table-cell w-16 px-1 py-0 text-center align-middle">
                            {{ serv['index'] }}
                        </div>
                        <div class="table-cell break-all px-2 py-1 text-left align-middle">
                            <Tooltips
                                :css="'ml-[3rem] mt-8'"
                                :tip="getInboundAndLastModifiedDate(serv)"
                            >
                                <button
                                    @click="restartServ(serv.uid)"
                                    class="whitespace-pre-wrap text-left"
                                >
                                    {{ serv['name'] }}
                                </button>
                            </Tooltips>
                        </div>
                        <div
                            class="hidden w-60 break-all px-2 py-1 text-left align-middle sm:table-cell lg:w-[28%]"
                        >
                            {{ serv['summary'] }}
                        </div>
                        <div
                            class="hidden w-56 break-all px-2 py-1 text-left align-middle lg:table-cell"
                        >
                            <div class="flex flex-wrap justify-start">
                                <div
                                    v-if="countTags(serv.tags) < 1"
                                    class="cursor-pointer px-1 py-0 text-base text-blue-400"
                                    @click="openWindow(hWnds.settingsEditor, serv.uid)"
                                >
                                    <i class="fas fa-tags"></i>
                                </div>
                                <div v-for="tagName in tagNames" :key="tagName" class="flex">
                                    <div
                                        v-if="serv.tags[tagName]"
                                        class="mx-0.5 my-0.5 inline-block max-w-[4.5rem] cursor-pointer overflow-hidden text-ellipsis whitespace-nowrap rounded bg-cyan-600 px-1 py-0.5 text-xs text-neutral-200 dark:bg-cyan-700 dark:text-neutral-300"
                                        @click="openWindow(hWnds.settingsEditor, serv.uid)"
                                    >
                                        {{ tagName == 'isAutoRun' ? 'A' : serv.tags[tagName] }}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="table-cell w-24 px-1 py-0 text-center align-middle">
                            <Tooltips :css="'mt-8'" :tip="t('single')">
                                <button class="mx-1 my-0 text-xl" @click="restartServ(serv.uid)">
                                    <i class="fas fa-angle-right"></i>
                                </button>
                            </Tooltips>
                            <Tooltips :css="'mt-8 right-2'" :tip="t('parallel')">
                                <button class="mx-1 my-0 text-xl" @click="restartOneServ(serv.uid)">
                                    <i class="fas fa-angle-double-right"></i>
                                </button>
                            </Tooltips>
                            <DropdownMenu :direction="'right'" withDropdownCloser>
                                <template #trigger>
                                    <button class="mx-1 my-0 text-xl">
                                        <i class="fas fa-bars"></i>
                                    </button>
                                </template>
                                <template #body>
                                    <ul
                                        class="right-4 min-w-[7rem] bg-slate-300 p-2 text-left text-sm text-neutral-700 dark:bg-slate-600 dark:text-neutral-300"
                                    >
                                        <li>
                                            <button
                                                @click="openWindow(hWnds.configEditor, serv.uid)"
                                                dropdown-closer
                                            >
                                                {{ t('editConfig') }}
                                            </button>
                                        </li>
                                        <li>
                                            <button
                                                @click="openWindow(hWnds.settingsEditor, serv.uid)"
                                                dropdown-closer
                                            >
                                                {{ t('changeSettings') }}
                                            </button>
                                        </li>
                                        <li>
                                            <button
                                                @click="copyShareLink(serv.uid)"
                                                dropdown-closer
                                            >
                                                {{ t('copyShareLink') }}
                                            </button>
                                        </li>
                                        <li>
                                            <button
                                                @click="openWindow(hWnds.qrCodeViwer, serv.uid)"
                                                dropdown-closer
                                            >
                                                {{ t('showQrCode') }}
                                            </button>
                                        </li>
                                        <li>
                                            <button
                                                @click="deleteServer(serv.uid, serv.name)"
                                                dropdown-closer
                                            >
                                                {{ t('deleteServer') }}
                                            </button>
                                        </li>
                                        <li>
                                            <button
                                                @click="runLatencyTest(serv.uid)"
                                                dropdown-closer
                                            >
                                                {{ t('runLatencyTest') }}
                                            </button>
                                        </li>
                                        <li>
                                            <button
                                                @click="openWindow(hWnds.logViwer, serv.uid)"
                                                dropdown-closer
                                            >
                                                {{ t('viewLogs') }}
                                            </button>
                                        </li>
                                    </ul>
                                </template>
                            </DropdownMenu>
                        </div>
                    </div>
                </li>
            </VueDraggableNext>
        </ul>
        <div class="block h-14 grow"></div>
    </div>

    <div
        class="fixed bottom-0 right-0 z-10 flex items-center bg-slate-400 px-2 text-sm text-neutral-800 dark:bg-slate-500"
    >
        <!-- pager -->
        <div class="inline-flex" v-if="pages > 1">
            <VPagination
                v-model="curPageNum"
                :pages="pages"
                active-color="#DCEDFF"
                @update:modelValue="refresh(true)"
            />
            <input
                v-model="curPageNumText"
                class="mx-2 my-1 inline-block w-12 bg-slate-200 text-center text-sm dark:bg-slate-200"
                @click="$event.target.select()"
                @keyup.enter="jumpToPage"
            />
        </div>
        <!-- counter -->
        <div class="inline-flex py-1">
            <span class="px-1">{{ t('count') }}: {{ servsCount }} </span>
            <span class="px-1"> {{ t('selected') }}: {{ countSelected() }}</span>
            <span v-if="isTesting" class="px-1"
                ><b> {{ t('testing') }} </b></span
            >
        </div>
    </div>

    <!-- popup window -->
    <FadeTransition>
        <div
            v-if="isShowPopWindow()"
            class="fixed bottom-0 left-0 right-0 top-0 z-50 flex flex-col bg-slate-300 p-4 opacity-95 transition-transform dark:bg-slate-700 md:left-56"
        >
            <SettingsEditor
                v-if="hWnds.settingsEditor.value"
                @onClose="closeWindow(hWnds.settingsEditor)"
                v-model:uid="curServUid"
                v-model:title="curServTitle"
            />
            <ConfigEditor
                v-if="hWnds.configEditor.value"
                @onClose="closeWindow(hWnds.configEditor)"
                v-model:uid="curServUid"
                v-model:title="curServTitle"
            />
            <LogViewer
                v-if="hWnds.logViwer.value"
                @onClose="closeWindow(hWnds.logViwer)"
                v-model:uid="curServUid"
                v-model:title="curServTitle"
            />
            <QrcodeViewer
                v-if="hWnds.qrCodeViwer.value"
                v-model:title="curServTitle"
                v-model:uid="curServUid"
                @onClose="closeWindow(hWnds.qrCodeViwer)"
            />
            <BatchSettingsEditor
                v-if="hWnds.batchSettingsEditor.value"
                :uids="getSelectedUids()"
                @onClose="closeWindow(hWnds.batchSettingsEditor)"
            />
        </div>
    </FadeTransition>
</template>

<style scoped>
.ghost {
    opacity: 60%;
    background-color: rgb(100, 116, 139);
}
</style>
