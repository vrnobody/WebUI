<script setup>
import utils from '@/misc/utils.js'
import { ref, onMounted, onUnmounted } from 'vue'
import FadeTransition from '@/components/transitions/FadeTransition.vue'
import { VueDraggableNext } from 'vue-draggable-next'
import SubEditor from './SubEditor.vue'

const t = utils.getTranslator()

const subs = ref([])

function refresh() {
    const next = function (str) {
        try {
            const j = JSON.parse(str)
            subs.value = j
        } catch (err) {
            Swal.fire(err.toString())
        }
    }

    utils.call(next, 'GetSubscriptions')
}

const isSubEditorVisible = ref(false)
const curSubIndex = ref(-1)
const curSubSettings = ref({})

function editSub(index) {
    curSubIndex.value = index
    const s = subs.value
    if (index >= 0 && index < s.length) {
        curSubSettings.value = s[index]
    } else {
        curSubSettings.value = {}
    }
    isSubEditorVisible.value = true
}

function closeSubEditorWindow() {
    isSubEditorVisible.value = false
}

function onSaveCurSub() {
    const index = curSubIndex.value
    const sub = curSubSettings.value
    if (index < 0 || index >= subs.length) {
        subs.value.push(sub)
    } else {
        subs.value[index] = sub
    }
    closeSubEditorWindow()
}

function saveSubs(callback) {
    const s = JSON.stringify(subs.value)
    const next = typeof (callback) === 'function' ? callback : function () {
        refresh()
        Swal.fire(t('done'))
    }
    utils.call(next, 'SaveSubscriptions', [s])
}

function updateSubs() {
    const done = function (num) {
        const msg = t('nNewServerImported', { count: num })
        Swal.fire(msg)
    }
    const next = function () {
        utils.call(done, 'UpdateSubscriptions')
    }
    saveSubs(next)
    Swal.fire(t('updating'))
}

function removeSub(index) {
    const s = subs.value[index]
    const name = s.alias
    const title = t('confirmRemoveSub', { name: name })
    const onYes = function () {
        subs.value.splice(index, 1)
    }
    utils.confirm(title, onYes)
}

onMounted(() => {
    refresh()
})

</script>
<template>
    <!-- header -->
    <div class="dark:bg-slate-500 bg-slate-400 left-0 md:left-56 flex fixed top-12 right-0 grow z-10 flex-col">

        <div class="dark:text-neutral-700 grow text-xs text-neutral-600 table h-6">
            <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('enable') }}</div>
            <div class="table-cell py-0 px-1 align-middle text-center w-12">{{ t('mark') }}</div>
            <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ t('index') }}</div>
            <div class="table-cell py-0 px-1 align-middle text-center">{{ t('name') }}</div>
            <div class="table-cell py-0 px-1 align-middle text-center w-24">{{ t('controls') }}</div>
        </div>
    </div>

    <!-- subs list -->
    <div class="flex flex-col">
        <div class="block w-full h-6"></div>
        <ul>
            <VueDraggableNext ghost-class="ghost" :list="subs">
                <li v-for="(sub, index) in subs" class="dark:odd:bg-slate-600 odd:bg-neutral-200">
                    <div class="cursor-grab grow text-base table w-full h-8">
                        <div class="table-cell py-0 px-1 align-middle text-center w-12">
                            <input type="checkbox" v-model="sub.isUse" class="w-4 h-4" />
                        </div>
                        <div class="table-cell py-0 px-1 align-middle text-center w-12">
                            <input type="checkbox" v-model="sub.isSetMark" class="w-4 h-4" />
                        </div>
                        <div class="table-cell py-0 px-1 align-middle text-center w-16">{{ index + 1 }}</div>
                        <div class="table-cell py-1 px-2 align-middle text-left break-all">
                            <p class="whitespace-pre-wrap">{{ sub.alias }}</p>
                        </div>
                        <div class="table-cell py-0 px-1 align-middle text-center w-24">
                            <button class="text-xl my-0 mx-1" @click="editSub(index)">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="text-xl my-0 mx-1" @click="removeSub(index)">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </li>
            </VueDraggableNext>
        </ul>
    </div>
    <div class="block grow h-10"></div>

    <!-- bottom controls -->
    <div class="dark:bg-slate-500 bg-slate-400 fixed bottom-0 right-0 z-10 flex-col py-1 px-1">
        <div class="text-base">
            <button @click="editSub(-1)" class="px-2"><i class="fas fa-plus"></i> {{ t('add') }}</button>
            <button @click="saveSubs" class="px-2"><i class="fas fa-save"></i> {{ t('save') }}</button>
            <button @click="updateSubs" class="px-2"><i class="fas fa-download"></i> {{ t('update') }}</button>
        </div>
    </div>

    <!-- popup window -->
    <FadeTransition>
        <div v-if="isSubEditorVisible"
            class="transition-transform dark:bg-slate-700 bg-slate-300 left-0 md:left-56 opacity-95 fixed z-50 flex flex-col right-0 bottom-0 p-4 top-0">
            <SubEditor @onClose="closeSubEditorWindow" @onSave="onSaveCurSub" v-model:settings="curSubSettings" />
        </div>
    </FadeTransition>
</template>
<style scoped>
.ghost {
    opacity: 60%;
    background-color: rgb(100, 116, 139);
}
</style>