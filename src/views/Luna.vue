<script setup>

import { ref, markRaw } from 'vue'
import CompEditor from '../components/LunaEditor.vue'
import CompManager from '../components/LunaManager.vue'
import { useI18n } from '@yangss/vue3-i18n'
const { _, t } = useI18n()

const curComponent = ref(null)

const curCompIdx = ref(-1)

function switchTo(idx) {
  const comps = [
    CompManager,
    CompEditor,
  ]
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
    class="dark:text-neutral-300 text-neutral-800 md:left-56 left-8 top-0 h-12 py-0 px-4 flex grow justify-left items-end fixed z-20">
    <div class="m-0 text-lg">
      <div @click="switchTo(0)" class="inline-block px-6 py-1"
        :class="{ 'dark:bg-slate-500 bg-slate-400 rounded-t': curCompIdx == 0 }">
        <i class="fas fa-list-alt"></i> {{ t('manager') }}
      </div>
      <div @click="switchTo(1)" class="inline-block px-6 py-1"
        :class="{ 'dark:bg-slate-500 bg-slate-400 rounded-t': curCompIdx == 1 }">
        <i class="fas fa-pen-square"></i> {{ t('editor') }}
      </div>
    </div>
  </div>

  <!-- body -->
  <div class="dark:text-neutral-300 text-neutral-800">
    <component :is="curComponent"></component>
  </div>
</template>

<style scoped></style>
