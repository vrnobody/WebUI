<script setup>
import utils from '@/misc/utils.js'
import { onMounted, onUnmounted, ref, nextTick, computed } from 'vue'

const t = utils.getTranslator()
const props = defineProps(['uid', 'title'])
const emit = defineEmits(['onClose'])

const logContainer = ref(null)
const logContent = ref('')
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
    <div class="flex h-4/5 w-full grow bg-neutral-200 p-4 dark:bg-slate-600">
        <textarea
            readonly
            class="grow resize-none bg-neutral-200 p-1 dark:bg-slate-600"
            v-model="logContent"
            ref="logContainer"
        ></textarea>
    </div>
    <div class="flex h-10 w-full items-end justify-center">
        <button @click="copy" class="mx-4 my-0">{{ t('copy') }}</button>
        <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
    </div>
</template>

<style scoped></style>
