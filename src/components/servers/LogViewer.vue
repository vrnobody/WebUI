<script setup>
import utils from '../../misc/utils.js'
import { onMounted, onUnmounted, ref, nextTick, computed } from 'vue'

const t = utils.getTranslator()
const props = defineProps(['uid', 'title'])
const emit = defineEmits(['onClose'])

const logContainer = ref(null)
const logContent = ref("")
let logUpdateTimer = 0

const servUid = computed({
    get() {
        return props.uid
    }
})

const servTitle = computed({
    get() {
        return props.title
    }
})

function copy() {
    utils.copyToClipboard(logContent.value)
    Swal.fire(t('copied'))
}

function close() {
    emit('onClose')
}

function updateLog(log) {
    if (logContent.value === log) {
        return
    }
    logContent.value = log
    nextTick(() => {
        logContainer.value.scrollTop = logContainer.value.scrollHeight + 120
    })
}

function fetchLog() {
    utils.call(updateLog, 'GetLog', [servUid.value])
}

function startRefreshTimer() {
    clearInterval(logUpdateTimer)
    logUpdateTimer = setInterval(fetchLog, 1000)
}

onMounted(() => {
    utils.hideScrollbarY()
    fetchLog()
    startRefreshTimer()
})

onUnmounted(() => {
    clearInterval(logUpdateTimer)
    utils.showScrollbarY()
})
</script>

<template>
    <div v-if="servTitle" class="mb-1 text-base">
        {{ servTitle }}
    </div>
    <div class="dark:bg-slate-600 flex grow w-full h-4/5 p-4 bg-neutral-200">
        <textarea readonly class="dark:bg-slate-600 bg-neutral-200 grow p-1 resize-none" v-model="logContent"
            ref="logContainer"></textarea>
    </div>
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="copy" class="my-0 mx-4">{{ t('copy') }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>

<style scoped></style>