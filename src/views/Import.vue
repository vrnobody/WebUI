<script setup>
import utils from '../misc/utils.js'
import { ref } from 'vue'
import { useI18n } from '@yangss/vue3-i18n'

const { _, t } = useI18n()

let content = ref("")
let mark = ref("")

function importShareLinks() {
  let links = content.value
  let mk = mark.value
  let next = function (count) {
    let msg = t('nNewServerImported', {
      count: count
    })
    console.log(msg)
    Swal.fire(msg)
  }
  utils.call(next, "ImportShareLinks", [links, mk])
}

</script>

<template>
  <div class="dark:bg-slate-700 md:left-56 flex  bg-neutral-200 fixed flex-col left-0 top-12 right-0 bottom-0 p-3">
    <div class="dark:text-neutral-300 text-neutral-500 flex items-center justify-start">
      {{ t('mark') }}
    </div>
    <div class="w-full h-10">
      <input v-model="mark" type="text" class="dark:bg-slate-500 bg-neutral-100 w-full py-1 px-2" />
    </div>
    <div class="dark:text-neutral-300  text-neutral-500 flex items-center justify-start">
      {{ t('shareLinks') }}
    </div>
    <div class="flex w-full grow">
      <textarea v-model="content" class="dark:bg-slate-500 bg-neutral-100 w-full h-full py-1 px-2"
        placeholder="vmess://... vless://... trojan://...">
      </textarea>
    </div>
    <div class="flex justify-center items-end h-8 w-full">
      <button @click="importShareLinks">{{ t('import') }}</button>
    </div>

  </div>
</template>

<style scoped></style>
