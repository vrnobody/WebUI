<script setup>
import utils from '../../misc/utils.js'
import { onMounted, ref, computed } from 'vue'

const props = defineProps(['settings'])
const emit = defineEmits(['update:settings', 'onClose', 'onSave'])

const t = utils.getTranslator()

const settings = ref({})

function loadSettings() {
    const s = JSON.parse(JSON.stringify(props.settings))
    settings.value = s
}

function save() {
    emit('update:settings', settings.value)
    emit('onSave')
}

function close() {
    emit('onClose')
}

onMounted(() => {
    loadSettings()
})

</script>
<template>
    <div class="dark:bg-slate-600 block grow w-full h-4/5 p-4 bg-slate-400">
        <div class="flex items-center h-9">
            <div class="py-0 px-4 w-24">{{ t('alias') }}</div>
            <div class="flex grow py-0 px-4">
                <input type="text" v-model="settings.alias" class="dark:bg-slate-500 bg-neutral-100 grow" />
            </div>
        </div>
        <div class="flex items-center h-9">
            <div class="py-0 px-4 w-24">URL</div>
            <div class="flex grow py-0 px-4">
                <input type="text" v-model="settings.url" class="dark:bg-slate-500 bg-neutral-100 grow" />
            </div>
        </div>
        <div class="flex items-center h-9">
            <div class="py-0 px-4 w-24"></div>
            <div class="flex grow py-0 px-4 items-center">
                <input type="checkbox" v-model="settings.isUse" class="w-4 h-4 mr-1" id="is-sub-enabled" />
                <label for="is-sub-enabled">{{ t('enable') }}</label>
                <input type="checkbox" v-model="settings.isSetMark" class="w-4 h-4 ml-4 mr-1" id="is-sub-marked" />
                <label for="is-sub-marked">{{ t('mark') }}</label>
            </div>
        </div>
    </div>
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="save" class="my-0 mx-4">{{ t('save') }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>