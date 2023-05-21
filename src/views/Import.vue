<script setup>

import { ref, markRaw } from 'vue'
import CompShareLink from '@/components/import/ShareLink.vue'
import CompSubs from '@/components/import/Subscription.vue'
import utils from '@/misc/utils.js'

const t = utils.getTranslator()

const curComponent = ref(null)

const curCompIdx = ref(-1)

function switchTo(idx) {
  const comps = [
    CompSubs,
    CompShareLink,
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
      <div @click="switchTo(0)" class="inline-block px-6 py-1 cursor-pointer"
        :class="{ 'dark:bg-slate-500 bg-slate-400 rounded-t': curCompIdx == 0 }">
        <i class="fas fa-star"></i> {{ t('subscriptions') }}
      </div>
      <div @click="switchTo(1)" class="inline-block px-6 py-1 cursor-pointer"
        :class="{ 'dark:bg-slate-500 bg-slate-400 rounded-t': curCompIdx == 1 }">
        <i class="fas fa-share-alt"></i> {{ t('shareLinks') }}
      </div>
    </div>
  </div>

  <!-- body -->
  <div class="dark:text-neutral-300 text-neutral-800">
    <component :is="curComponent"></component>
  </div>
</template>

<style scoped></style>
