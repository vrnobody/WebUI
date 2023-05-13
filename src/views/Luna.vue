<script setup>

import { ref, markRaw } from 'vue'
import CompEditor from '../components/LunaEditor.vue'
import CompManager from '../components/LunaManager.vue'

const curComponent = ref(null)

function switchTo(name) {
  const comps = {
    CompEditor,
    CompManager,
  }
  curComponent.value = markRaw(comps[name])
}

switchTo('CompManager')

</script>

<template>
  <!-- toolstrip -->
  <div
    class="dark:text-neutral-300 text-neutral-800 md:left-56 left-8 top-0 h-12 py-0 px-4 flex grow justify-left items-center fixed z-20">
    <div class="m-0 text-4xl">
      <button @click="switchTo('CompManager')" class="my-0 mx-1"><i class="fas fa-list-alt"></i></button>
      <button @click="switchTo('CompEditor')" class="my-0 mx-1"><i class="fas fa-pen-square"></i></button>
    </div>
  </div>

  <!-- body -->
  <div class="dark:text-neutral-300 text-neutral-800">
    <component :is="curComponent"></component>
  </div>
</template>

<style scoped></style>
