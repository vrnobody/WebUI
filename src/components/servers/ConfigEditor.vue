<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import utils from '../../misc/utils.js'
import JsonEditor from './JsonEditor.vue'
import LoadingWidget from '../widgets/Loading.vue'

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

const servTitle = computed({
    get() {
        return props.title
    }
})

function close() {
    emit('onClose')
}

function loadConfig() {
    const uid = servUid.value
    if (!uid) {
        parseServConfig(null)
    } else {
        utils.call(parseServConfig, "GetServerConfig", [uid])
    }
}

function parseServConfig(config) {
    try {
        let s = '{\n\n}'
        if (config) {
            const j = JSON.parse(config)
            s = JSON.stringify(j, null, 4)
        }
        servConfig.value = s
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
        const config = servConfig.value
        utils.call(next, "SaveServerConfig", [uid, config])
    } catch (err) {
        Swal.fire(err.toString())
    }
}

onMounted(() => {
    loadConfig()
})

onUnmounted(() => {

})

</script>
<template>
    <div v-if="servTitle" class="mb-1 text-base">
        {{ servTitle }}
    </div>
    <JsonEditor v-if="isShowJsonEditor" v-model="servConfig" />
    <LoadingWidget v-else />
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="addNewServ" class="my-0 mx-4">{{ t('add') }}</button>
        <button v-if="servUid" @click="saveServConfig(servUid)" class="my-0 mx-4">{{ t('save') }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>