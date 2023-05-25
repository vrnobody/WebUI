<script setup>
import utils from '../../misc/utils.js'
import { onMounted, ref, computed } from 'vue'

const props = defineProps(['uid', 'title'])
const emit = defineEmits(['onClose'])

const servSettings = ref({})

const t = utils.getTranslator()

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

const servSettingKeys = ["index", "name", "inbMode", "inbIp", "inbPort", "mark", "remark", "tag1", "tag2", "tag3"]

function loadSettings() {
    const next = function (tags) {
        if (tags) {
            servSettings.value = tags
            return
        }
        Swal.fire(err.toString())
    }
    utils.call(next, "GetServSettings", [servUid.value])
}

function save() {
    const next = function (ok) {
        if (ok) {
            close()
            return
        }
        Swal.fire(t('failed'))
    }
    const uid = servUid.value || ''
    utils.call(next, "SaveServSettings", [uid, servSettings.value])
}

function close() {
    emit('onClose')
}

onMounted(() => {
    loadSettings()
})

</script>
<template>
    <div class="mb-1 text-base">
        {{ servTitle }}
    </div>
    <div class="dark:bg-slate-600 bg-slate-400 block grow w-full h-4/5 p-4">
        <div v-for="key in servSettingKeys">
            <div class="flex items-center h-9">
                <div class="p-0 w-32 mr-4">{{ t(key) }}</div>
                <div class="flex grow p-0">
                    <select v-if="key === 'inbMode'" v-model="servSettings[key]"
                        class="dark:bg-slate-600 bg-neutral-300 border-neutral-400 border grow">
                        <option value="0">Config</option>
                        <option value="1">HTTP</option>
                        <option value="2">SOCKS</option>
                        <option value="3">{{ t('custom') }}</option>
                    </select>
                    <input v-else type="text" v-model="servSettings[key]"
                        class="dark:bg-slate-500 bg-neutral-100 grow px-1" />
                </div>
            </div>
        </div>
    </div>
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="save" class="my-0 mx-4">{{ t('save') }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>