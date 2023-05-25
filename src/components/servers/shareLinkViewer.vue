<script setup>
import utils from '../../misc/utils.js'
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
    utils.call(next, "GetShareLink", [servUid.value])
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
    if (qrCode) {
        qrCode.clear()
        qrCode.makeCode(shareLink.value)
    } else {
        qrCode = new QRCode(document.getElementById('share-link-qrcode'), shareLink.value)
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
    <div class="dark:bg-slate-600 bg-slate-400 block grow w-full h-4/5 p-4 ">
        <div class="flex w-full mb-1 items-center">
            <span class="inline-block w-24 text-left shrink-0">{{ t('shareLink') }}</span>
            <input class="dark:bg-slate-500 bg-neutral-100 px-2 py-1 inline-flex grow" type="text" v-model="shareLink"
                @change="updateQrCode" />
            <button class="shrink-0 w-16" @click="copyShareLink">{{ t('copy') }}</button>
        </div>
        <div class="grow w-full flex justify-center p-4">
            <div id="share-link-qrcode" class="flex justify-center"></div>
        </div>
    </div>
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>