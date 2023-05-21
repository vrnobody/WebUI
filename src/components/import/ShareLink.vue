<script setup>
import utils from '@/misc/utils.js'
import { ref } from 'vue'

const t = utils.getTranslator()

const content = ref("")
const mark = ref("")

function report(count) {
  const msg = t('nNewServerImported', {
    count: count
  })
  Swal.fire(msg)
}

function scanQrCode() {
  const mk = mark.value
  utils.call(report, "ScanQrCode", [mk])
}

function importShareLinks() {
  const links = content.value
  const mk = mark.value
  utils.call(report, "ImportShareLinks", [links, mk])
}

</script>

<template>
  <div class="dark:bg-slate-500 bg-slate-400 md:left-56 flex fixed flex-col left-0 top-12 right-0 bottom-0 p-3">
    <div class="dark:text-neutral-300 text-neutral-500 flex items-center justify-start">
      {{ t('mark') }}
    </div>
    <div class="w-full h-10">
      <input v-model="mark" type="text" class="dark:bg-slate-700 bg-neutral-100 w-full py-1 px-2" />
    </div>
    <div class="dark:text-neutral-300  text-neutral-500 flex items-center justify-start">
      {{ t('shareLinks') }}
    </div>
    <div class="flex w-full grow">
      <textarea v-model="content" class="dark:bg-slate-700 bg-neutral-100 w-full h-full py-1 px-2"
        placeholder="vmess://... vless://... trojan://...">
      </textarea>
    </div>
    <div class="flex justify-center items-end h-8 w-full">
      <button @click="importShareLinks" class="mx-2">{{ t('import') }}</button>
      <button @click="scanQrCode" class="mx-2">{{ t('scanQrCode') }}</button>
    </div>

  </div>
</template>

<style scoped></style>
