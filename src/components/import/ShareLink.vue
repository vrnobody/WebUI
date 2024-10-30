<script setup>
import utils from '@/misc/utils.js'
import { ref } from 'vue'

const t = utils.getTranslator()

const content = ref('')
const mark = ref('')

function report(count) {
    const msg = t('nNewServerImported', {
        count: count
    })
    Swal.fire(msg)
}

function importShareLinks() {
    const links = content.value || ''
    const mk = mark.value || ''
    utils.call(report, 'ImportShareLinks', [links, mk])
}
</script>

<template>
    <div
        class="fixed bottom-0 left-12 right-0 top-12 flex flex-col bg-slate-400 p-3 dark:bg-slate-500 lg:left-56"
    >
        <div class="flex items-center justify-start text-neutral-500 dark:text-neutral-300">
            {{ t('mark') }}
        </div>
        <div class="h-10 w-full">
            <input
                v-model="mark"
                type="text"
                class="w-full bg-neutral-100 px-2 py-1 dark:bg-slate-700"
            />
        </div>
        <div class="flex items-center justify-start text-neutral-500 dark:text-neutral-300">
            {{ t('shareLinks') }}
        </div>
        <div class="flex w-full grow">
            <textarea
                v-model="content"
                class="h-full w-full bg-neutral-100 px-2 py-1 dark:bg-slate-700"
                placeholder="vmess://... vless://... trojan://..."
            >
            </textarea>
        </div>
        <div class="flex h-8 w-full items-end justify-center">
            <button @click="importShareLinks" class="mx-2">{{ t('import') }}</button>
        </div>
    </div>
</template>

<style scoped></style>
