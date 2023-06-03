<script setup>
import { computed, ref, onMounted, onUnmounted, nextTick } from 'vue'
import utils from '@/misc/utils.js'
import config from '@/config.js'

const props = defineProps(['filename', 'op'])
const emit = defineEmits(['update:filename', 'onClose', 'onSave'])

const t = utils.getTranslator()

const exts = ref('')

const filename = computed({
    get() {
        return props.filename
    },
    set(value) {
        emit('update:filename', value)
    }
})

const dirInfo = ref({})

function refresh() {
    let path = filename.value || ''
    if (path && path.length > 0) {
        path += '\\'
    }
    const next = function (info) {
        try {
            dirInfo.value = JSON.parse(info)
        } catch (err) {
            Swal.fire(err.toString())
        }
    }
    utils.call(next, 'Ls', [path, exts.value])
}

function joinPath(parts) {
    return parts.join('\\')
}

function splitPath(path) {
    return path.split(/[\\/]+/).filter((el) => el)
}

function append(d) {
    const parts = splitPath(filename.value)
    if (!parts || parts.length < 1) {
        filename.value = d
    } else {
        parts.push(d)
        filename.value = joinPath(parts)
    }
    nextTick(refresh)
}

function goback() {
    if (filename.value) {
        let parts = splitPath(filename.value)
        if (parts && parts.length > 0) {
            parts.pop()
        }
        if (!parts || parts.length < 1) {
            filename.value = ''
        } else {
            filename.value = joinPath(parts)
        }
    }
    nextTick(refresh)
}

function save() {
    emit('onSave')
}

function close() {
    emit('onClose')
}

const fileBrowserHistoryKey = 'FileBrowserHistoryPath'
const fileBrowserExtsKey = 'FileBrowserExts'

onMounted(() => {
    filename.value = config.get(fileBrowserHistoryKey) || ''
    exts.value = config.get(fileBrowserExtsKey) || 'lua|json|txt'
    nextTick(refresh)
})

onUnmounted(() => {
    config.set(fileBrowserHistoryKey, filename.value)
    config.set(fileBrowserExtsKey, exts.value)
})
</script>
<template>
    <!-- inputs -->
    <div class="flex p-0 text-base">
        <ul class="grow">
            <li class="mb-2 flex">
                <div class="w-24 shrink-0">{{ t('file') }}</div>
                <input
                    type="text"
                    v-model="filename"
                    class="grow bg-neutral-100 px-2 dark:bg-slate-500"
                    @change="refresh"
                />
            </li>
            <li class="mb-2 flex">
                <div class="w-24 shrink-0">{{ t('extensions') }}</div>
                <input
                    type="text"
                    v-model="exts"
                    class="grow bg-neutral-100 px-2 dark:bg-slate-500"
                    @change="refresh"
                />
            </li>
        </ul>
    </div>

    <!-- directory content -->
    <div class="block h-4/5 w-full grow overflow-y-auto bg-slate-400 p-4 dark:bg-slate-500">
        <ul>
            <li>
                <button @click="goback"><i class="fas fa-backward"></i> ..</button>
            </li>
            <li v-for="d in dirInfo.folders" :key="d" class="flex">
                <button @click="append(d)" class="overflow-hidden text-ellipsis whitespace-nowrap">
                    <span class="text-amber-400"><i class="fas fa-folder"></i></span> {{ d }}
                </button>
            </li>
            <li v-for="f in dirInfo.files" :key="f" class="flex">
                <button @click="append(f)" class="overflow-hidden text-ellipsis whitespace-nowrap">
                    <span class="text-neutral-200"><i class="fas fa-file"></i></span> {{ f }}
                </button>
            </li>
        </ul>
    </div>

    <!-- controls -->
    <div class="flex h-10 w-full items-end justify-center">
        <button @click="save" class="mx-4 my-0">{{ t(props.op) }}</button>
        <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>
