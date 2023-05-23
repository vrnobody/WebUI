<script setup>
import utils from '@/misc/utils.js'
import { computed, ref, onMounted, onUnmounted, nextTick } from 'vue'

const props = defineProps(['filename', 'op'])
const emit = defineEmits(['update:filename', 'onClose', 'onSave'])

const t = utils.getTranslator()

const op = computed({
    get() {
        return props.op
    }
})

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
    let path = filename.value
    if (path && path.length > 0) {
        path += '\\'
    }
    const next = function (info) {
        try {
            // console.log(info)
            dirInfo.value = JSON.parse(info)
        } catch (err) {
            Swal.fire(err.toString())
        }
    }
    utils.call(next, 'Ls', [path])
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

onMounted(() => {
    refresh()
})

</script>
<template>
    <div class="text-base p-0 mb-2">
        <input type="text" v-model="filename" class="w-full px-2" @change="refresh" />
    </div>
    <div class="dark:bg-slate-600 block grow w-full h-4/5 p-4 bg-neutral-200 overflow-y-auto">
        <ul>
            <li>
                <button @click="goback">
                    <i class="fas fa-backward"></i> ..
                </button>
            </li>
            <li v-for="d in dirInfo.folders">
                <button @click="append(d)"><i class="fas fa-folder"></i> {{ d }}</button>
            </li>
            <li v-for="f in dirInfo.files">
                <button @click="append(f)"><i class="fas fa-file"></i> {{ f }}</button>
            </li>
        </ul>
    </div>

    <div class="flex w-full h-10 justify-center items-end">
        <button @click="save" class="my-0 mx-4">{{ t(op) }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>