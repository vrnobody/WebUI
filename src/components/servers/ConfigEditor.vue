<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import utils from '@/misc/utils.js'
import JsonEditor from './JsonEditor.vue'
import LoadingWidget from '@/components/widgets/Loading.vue'

const t = utils.getTranslator()

const props = defineProps(['uid', 'title'])
const emit = defineEmits(['onClose'])
const servConfig = ref('{}')
const isShowJsonEditor = ref(false)

const servUid = computed({
    get() {
        return props.uid
    }
})

const propTitle = computed({
    get() {
        return props.title
    }
})

const servTitle = ref('')

function close() {
    emit('onClose')
}

function loadConfig() {
    const uid = servUid.value
    if (!uid) {
        parseServConfig(null)
    } else {
        utils.call(parseServConfig, 'GetServerConfig', [uid])
    }
}

function parseServConfig(config) {
    try {
        servConfig.value = config
        isShowJsonEditor.value = true
    } catch (err) {
        Swal.fire(err.toString())
    }
}

function addNewServ() {
    saveServConfig('')
}

function saveServConfig(uid) {
    const next = function (err) {
        if (err) {
            Swal.fire(t(err))
            return
        }
        close(false)
    }

    try {
        uid = uid || ''
        const config = servConfig.value || ''
        const title = servTitle.value || ''
        utils.call(next, 'SaveServerConfig', [uid, title, config])
    } catch (err) {
        Swal.fire(err.toString())
    }
}

onMounted(() => {
    servTitle.value = propTitle.value
    loadConfig()
})

onUnmounted(() => {})
</script>
<template>
    <div v-if="propTitle" class="mb-1 flex text-base">
        <span>{{ servTitle }}</span>
    </div>
    <div v-else class="mb-1 flex text-base">
        <span class="mr-1 w-12">{{ t('name') }}</span>
        <input type="text" v-model="servTitle" class="grow bg-neutral-100 px-1 dark:bg-slate-500" />
    </div>
    <JsonEditor v-if="isShowJsonEditor" v-model="servConfig" />
    <LoadingWidget v-else />
    <div class="flex h-10 w-full items-end justify-center">
        <button @click="addNewServ" class="mx-4 my-0">{{ t('add') }}</button>
        <button v-if="servUid" @click="saveServConfig(servUid)" class="mx-4 my-0">
            {{ t('save') }}
        </button>
        <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>
