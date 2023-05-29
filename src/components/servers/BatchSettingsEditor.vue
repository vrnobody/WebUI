<script setup>
import utils from '../../misc/utils.js'
import { onMounted, ref } from 'vue'

const emit = defineEmits(['onClose'])

const servSettings = ref({})

const t = utils.getTranslator()

const servSettingKeys = ["inbMode", "inbIp", "inbPort", "isAutoRun", "mark", "remark", "tag1", "tag2", "tag3"]

const selection = {}

function initSelection() {
    for (const key of servSettingKeys) {
        selection[key] = false
    }
}

function getElementType(key) {
    switch (key) {
        case 'inbMode':
            return 'select'
        case 'isAutoRun':
            return 'checkbox'
        default:
            break
    }
    return 'text'
}

function loadSettings() {
    initSelection()

    const next = function (tags) {
        if (tags) {
            servSettings.value = tags
            return
        }
        Swal.fire(err.toString())
    }

    utils.call(next, "GetFirstSelectedServerSettings")
}

function save() {
    const s = {}
    for (const key of servSettingKeys) {
        if (selection[key]) {
            s[key] = servSettings.value[key]
        }
    }

    const next = function (ok) {
        if (ok) {
            close()
            return
        }
        Swal.fire(t('failed'))
    }

    utils.call(next, "ChangeSelectedServersSetting", [s])
}

function close() {
    emit('onClose')
}

onMounted(() => {
    loadSettings()
})

</script>
<template>
    <div class="dark:bg-slate-600 bg-slate-400 block grow w-full h-4/5 p-4">
        <div v-for="key in servSettingKeys">
            <div class="flex items-center h-9">
                <div class="p-0 w-12 mx-2">
                    <input type="checkbox" v-model="selection[key]" class="w-4 h-4 px-1" />
                </div>
                <div class="p-0 w-32 mx-2">{{ t(key) }}</div>
                <div class="flex grow p-0 mx-2">
                    <select v-if="getElementType(key) === 'select'" v-model="servSettings[key]"
                        class="dark:bg-slate-600 bg-neutral-300 border-neutral-400 border grow">
                        <option value="0">Config</option>
                        <option value="1">HTTP</option>
                        <option value="2">SOCKS</option>
                        <option value="3">{{ t('custom') }}</option>
                    </select>
                    <input v-if="getElementType(key) === 'text'" type="text" v-model="servSettings[key]"
                        class="dark:bg-slate-500 bg-neutral-100 grow px-1" />
                    <input v-if="getElementType(key) === 'checkbox'" type="checkbox" v-model="servSettings[key]"
                        class="w-4 h-4 px-1" />
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