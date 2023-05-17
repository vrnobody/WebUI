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

function genSaveButtonText() {
    if (servUid.value) {
        return t('save')
    }
    return t('add')
}

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

function saveServConfig() {
    const next = function (err) {
        if (err) {
            Swal.fire(t(err))
            return
        }
        close()
    }

    try {
        const uid = servUid.value
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
        <button @click="saveServConfig" class="my-0 mx-4">{{ genSaveButtonText() }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>