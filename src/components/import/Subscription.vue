<script setup>
import utils from '@/misc/utils.js'
import { ref, onMounted } from 'vue'
import FadeTransition from '@/components/transitions/FadeTransition.vue'
import { VueDraggableNext } from 'vue-draggable-next'
import SubEditor from './SubEditor.vue'

const t = utils.getTranslator()

const subs = ref([])

function selectAll() {
    for (let sub of subs.value) {
        sub.isUse = true
    }
    saveSubs(() => {})
}

function inverseSelections() {
    for (let sub of subs.value) {
        sub.isUse = !sub.isUse
    }
    saveSubs(() => {})
}

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
    if (index < 0 || index >= subs.value.length) {
        subs.value.push(sub)
    } else {
        subs.value[index] = sub
    }
    closeSubEditorWindow()
}

function saveSubs(callback) {
    const s = JSON.stringify(subs.value)
    const next =
        typeof callback === 'function'
            ? callback
            : function () {
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
    <div
        class="fixed left-12 right-0 top-12 z-10 flex grow flex-col bg-slate-400 dark:bg-slate-500 lg:left-56"
    >
        <div class="table h-6 grow text-xs text-neutral-600 dark:text-neutral-700">
            <div class="table-cell w-12 px-1 py-0 text-center align-middle">{{ t('enable') }}</div>
            <div class="table-cell w-12 px-1 py-0 text-center align-middle">{{ t('mark') }}</div>
            <div class="table-cell w-16 px-1 py-0 text-center align-middle">{{ t('index') }}</div>
            <div class="table-cell px-1 py-0 text-center align-middle">{{ t('name') }}</div>
            <div class="table-cell w-24 px-1 py-0 text-center align-middle">
                {{ t('controls') }}
            </div>
        </div>
    </div>

    <!-- empty list -->
    <div v-if="subs.length <= 0" class="flex justify-center">
        <div class="mt-8 text-lg">{{ t('listIsEmpty') }}</div>
    </div>

    <!-- subs list -->
    <div v-else class="flex flex-col">
        <div class="block h-6 w-full"></div>
        <ul>
            <VueDraggableNext ghost-class="ghost" :list="subs">
                <li
                    v-for="(sub, index) in subs"
                    :key="index"
                    class="odd:bg-neutral-200 dark:odd:bg-slate-600"
                >
                    <div class="table h-8 w-full grow cursor-grab text-base">
                        <div class="table-cell w-12 px-1 py-0 text-center align-middle">
                            <input type="checkbox" v-model="sub.isUse" class="h-4 w-4" />
                        </div>
                        <div class="table-cell w-12 px-1 py-0 text-center align-middle">
                            <input type="checkbox" v-model="sub.isSetMark" class="h-4 w-4" />
                        </div>
                        <div class="table-cell w-16 px-1 py-0 text-center align-middle">
                            {{ index + 1 }}
                        </div>
                        <div class="table-cell break-all px-2 py-1 text-left align-middle">
                            <p class="whitespace-pre-wrap">{{ sub.alias }}</p>
                        </div>
                        <div class="table-cell w-24 px-1 py-0 text-center align-middle">
                            <button class="mx-1 my-0 text-xl" @click="editSub(index)">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="mx-1 my-0 text-xl" @click="removeSub(index)">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </li>
            </VueDraggableNext>
        </ul>
    </div>
    <div class="block h-10 grow"></div>

    <!-- bottom controls -->
    <div class="fixed bottom-0 right-0 z-10 flex-col bg-slate-400 px-1 py-1 dark:bg-slate-500">
        <div class="text-base">
            <button @click="selectAll" class="px-2">
                <i class="fas fa-check-double"></i> {{ t('selectAll') }}
            </button>
            <button @click="inverseSelections" class="px-2">
                <i class="fas fa-adjust"></i> {{ t('inverseSelection') }}
            </button>
            <button @click="editSub(-1)" class="px-2">
                <i class="fas fa-plus"></i> {{ t('add') }}
            </button>
            <button @click="saveSubs" class="px-2">
                <i class="fas fa-save"></i> {{ t('save') }}
            </button>
            <button @click="updateSubs" class="px-2">
                <i class="fas fa-download"></i> {{ t('update') }}
            </button>
        </div>
    </div>

    <!-- popup window -->
    <FadeTransition>
        <div
            v-if="isSubEditorVisible"
            class="fixed bottom-0 left-0 right-0 top-0 z-50 flex flex-col bg-slate-300 p-4 opacity-95 transition-transform dark:bg-slate-700 lg:left-56"
        >
            <SubEditor
                @onClose="closeSubEditorWindow"
                @onSave="onSaveCurSub"
                v-model:subs="curSubSettings"
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
