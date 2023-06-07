<script setup>
import utils from '@/misc/utils.js'
import { onMounted, ref } from 'vue'

const props = defineProps(['subs'])
const emit = defineEmits(['update:subs', 'onClose', 'onSave'])

const t = utils.getTranslator()

const settings = ref({})

function loadSettings() {
    const s = JSON.parse(JSON.stringify(props.subs))
    settings.value = s
}

function save() {
    emit('update:subs', settings.value)
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
    <div class="block h-4/5 w-full grow bg-slate-400 p-4 dark:bg-slate-600">
        <div class="flex h-9 items-center">
            <div class="w-24 px-4 py-0">{{ t('alias') }}</div>
            <div class="flex grow px-4 py-0">
                <input
                    type="text"
                    v-model="settings.alias"
                    class="grow bg-neutral-100 dark:bg-slate-500"
                />
            </div>
        </div>
        <div class="flex h-9 items-center">
            <div class="w-24 px-4 py-0">URL</div>
            <div class="flex grow px-4 py-0">
                <input
                    type="text"
                    v-model="settings.url"
                    class="grow bg-neutral-100 dark:bg-slate-500"
                />
            </div>
        </div>
        <div class="flex h-9 items-center">
            <div class="w-24 px-4 py-0"></div>
            <div class="flex grow items-center px-4 py-0">
                <input
                    type="checkbox"
                    v-model="settings.isUse"
                    class="mr-1 h-4 w-4"
                    id="is-sub-enabled"
                />
                <label for="is-sub-enabled">{{ t('enable') }}</label>
                <input
                    type="checkbox"
                    v-model="settings.isSetMark"
                    class="ml-4 mr-1 h-4 w-4"
                    id="is-sub-marked"
                />
                <label for="is-sub-marked">{{ t('mark') }}</label>
            </div>
        </div>
    </div>
    <div class="flex h-10 w-full items-end justify-center">
        <button @click="save" class="mx-4 my-0">{{ t('save') }}</button>
        <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>
