<script setup>
import utils from '@/misc/utils.js'
import { onMounted, ref, computed, nextTick } from 'vue'

const props = defineProps(['uid', 'title'])
const emit = defineEmits(['onClose'])

const shareLink = ref('')

const t = utils.getTranslator()

const servUid = computed({
  get() {
    return props.uid
  }
})

const servTitle = computed({
  get() {
    return props.title
  }
})

function loadShareLink() {
  const next = function (link) {
    shareLink.value = link
    nextTick(updateQrCode)
  }
  utils.call(next, 'GetShareLink', [servUid.value])
}

function close() {
  emit('onClose')
}

function copyShareLink() {
  utils.copyToClipboard(shareLink.value)
  Swal.fire(t('copied'))
}

let qrCode = null
function updateQrCode() {
  const link = shareLink.value
  if (qrCode) {
    qrCode.set({
      value: link
    })
    qrCode.update()
  } else {
    qrCode = new QRious({
      element: document.getElementById('share-link-qrcode'),
      size: 300,
      value: link
    })
  }
}

onMounted(() => {
  loadShareLink()
})
</script>
<template>
  <div class="mb-1 text-base">
    {{ servTitle }}
  </div>
  <div class="block h-4/5 w-full grow bg-slate-400 p-4 dark:bg-slate-600">
    <div class="mb-1 flex w-full items-center">
      <span class="inline-block w-24 shrink-0 text-left">{{ t('shareLink') }}</span>
      <input
        class="inline-flex w-[4rem] grow bg-neutral-100 px-2 py-1 dark:bg-slate-500"
        type="text"
        v-model="shareLink"
        @change="updateQrCode"
      />
      <button class="w-16 shrink-0" @click="copyShareLink">{{ t('copy') }}</button>
    </div>
    <div class="flex w-full grow justify-center p-4">
      <canvas id="share-link-qrcode" class="min-h-[16rem] min-w-[16rem]"></canvas>
    </div>
  </div>
  <div class="flex h-10 w-full items-end justify-center">
    <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
  </div>
</template>
<style scoped></style>
