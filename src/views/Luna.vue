<script setup>
import { ref, markRaw } from 'vue'
import CompEditor from '@/components/luna/LunaEditor.vue'
import CompManager from '@/components/luna/LunaManager.vue'
import utils from '@/misc/utils.js'

const t = utils.getTranslator()

const curComponent = ref(null)
const curCompIdx = ref(-1)
const scriptName = ref('')

function editScript(name) {
    scriptName.value = name
    switchTo(1)
}

function switchTo(idx) {
    const comps = [CompManager, CompEditor]
    if (idx >= 0 && idx < comps.length && idx !== curCompIdx.value) {
        curComponent.value = markRaw(comps[idx])
        curCompIdx.value = idx
    }
}

switchTo(0)
</script>

<template>
    <!-- toolstrip -->
    <div
        class="justify-left fixed left-12 top-0 z-20 flex h-12 grow items-end px-4 py-0 text-neutral-800 dark:text-neutral-300 lg:left-56"
    >
        <div class="m-0 text-lg">
            <div
                @click="switchTo(0)"
                class="inline-block cursor-pointer px-6 py-1"
                :class="{ 'rounded-t bg-slate-400 dark:bg-slate-500': curCompIdx == 0 }"
            >
                <i class="fas fa-list-alt"></i> {{ t('manager') }}
            </div>
            <div
                @click="switchTo(1)"
                class="inline-block cursor-pointer px-6 py-1"
                :class="{ 'rounded-t bg-slate-400 dark:bg-slate-500': curCompIdx == 1 }"
            >
                <i class="fas fa-pen-square"></i> {{ t('editor') }}
            </div>
        </div>
    </div>

    <!-- body -->
    <div class="text-neutral-800 dark:text-neutral-300">
        <component
            :is="curComponent"
            @onEditScript="editScript"
            v-model:scriptName="scriptName"
        ></component>
    </div>
</template>

<style scoped></style>
