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
    return path.split(/[\\\/]+/).filter(el => el)
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
    <div class="text-base p-0 flex">
        <ul class="grow">
            <li class="flex mb-2">
                <div class="shrink-0 w-24">{{ t('file') }}</div>
                <input type="text" v-model="filename" class="dark:bg-slate-500  bg-neutral-100 grow px-2"
                    @change="refresh" />
            </li>
            <li class="flex mb-2">
                <div class="shrink-0 w-24">{{ t('extensions') }}</div>
                <input type="text" v-model="exts" class="dark:bg-slate-500  bg-neutral-100 grow px-2" @change="refresh" />
            </li>
        </ul>
    </div>

    <!-- directory content -->
    <div class="dark:bg-slate-500  bg-neutral-200 block grow w-full h-4/5 p-4 overflow-y-auto">
        <ul>
            <li>
                <button @click="goback">
                    <i class="fas fa-backward"></i> ..
                </button>
            </li>
            <li v-for="d in dirInfo.folders" class="flex">
                <button @click="append(d)" class=" whitespace-nowrap overflow-hidden text-ellipsis">
                    <i class="fas fa-folder"></i> {{ d }}
                </button>
            </li>
            <li v-for="f in dirInfo.files" class="flex">
                <button @click="append(f)" class=" whitespace-nowrap overflow-hidden text-ellipsis">
                    <i class="fas fa-file"></i> {{ f }}
                </button>
            </li>
        </ul>
    </div>

    <!-- controls -->
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="save" class="my-0 mx-4">{{ t(props.op) }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>