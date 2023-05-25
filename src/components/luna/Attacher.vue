<script setup>
import { computed, ref, onMounted, onUnmounted, nextTick } from 'vue'
import utils from '@/misc/utils.js'

const emit = defineEmits(['onAttach', 'onClose'])

const t = utils.getTranslator()

const vmInfos = ref({})

function refresh() {
    const next = function (info) {
        try {
            vmInfos.value = JSON.parse(info)
        } catch (err) {
            Swal.fire(err.toString())
        }
    }
    utils.call(next, 'GetAllLuaVmsInfo')
}

function cleanup() {
    const onYes = function () {
        utils.call(refresh, 'RemoveAllStoppedLuaVms')
    }
    const msg = t('confirmRemoveAllStoppedLuaVm')
    utils.confirm(msg, onYes)
}

function removeVm(uid, name) {
    const msg = t('confirmRemoveLuaVm', { name: name })
    const onYes = function () {
        utils.call(refresh, 'RemoveLuaVm', [uid])
    }
    utils.confirm(msg, onYes)
}

function attachTo(uid, name) {
    emit('onAttach', uid, name)
}

function close() {
    emit('onClose')
}

onMounted(() => {
    refresh()
})

onUnmounted(() => {
})

</script>
<template>
    <!-- header -->
    <div class="dark:bg-slate-600 dark:text-neutral-200 bg-slate-400 text-xs text-neutral-600 grow-0 table h-6 w-full">
        <div class="table-cell py-0 px-1 align-middle text-center w-[4rem]">{{ t('status') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center w-[22rem]">{{ t('uuid') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center">{{ t('name') }}</div>
        <div class="table-cell py-0 px-1 align-middle text-center w-[7rem]">{{ t('controls') }}</div>
    </div>

    <!-- empty list -->
    <div v-if="Object.keys(vmInfos).length <= 0" class="grow flex justify-center">
        <div class="text-lg mt-8">{{ t('listIsEmpty') }}</div>
    </div>

    <!-- content -->
    <div v-else class="dark:bg-slate-400  bg-neutral-100 block grow w-full overflow-y-auto">
        <ul>
            <li v-for="(v, uid) in vmInfos" class="dark:odd:bg-slate-500 odd:bg-neutral-200 text-base table w-full h-8">
                <div class="leading-[0rem] table-cell py-0 px-1 align-middle text-center w-[4rem]">
                    <span v-if="v.on"
                        class="dark:bg-lime-600 dark:text-neutral-100 bg-lime-500 text-neutral-100 text-xs py-0.5 px-1 rounded">{{
                            t('on') }}</span>
                    <span v-else
                        class="dark:bg-red-700 dark:text-neutral-100 bg-red-600 text-neutral-100 text-xs py-0.5 px-1 rounded">{{
                            t('off') }}</span>
                </div>
                <div class="table-cell py-0 px-1 align-middle text-center w-[22rem]">
                    <input type="text" :value="uid"
                        class="w-full px-1 text-center border border-neutral-400 dark:border-0 dark:bg-slate-600 bg-neutral-300"
                        readonly />
                </div>
                <div class="table-cell py-0 px-1 align-middle text-center">
                    <input type="text" :value="v.name"
                        class="w-full px-1  border border-neutral-400 dark:border-0 dark:bg-slate-600 bg-neutral-300"
                        readonly />
                </div>
                <div class="table-cell py-0 px-1 align-middle text-center w-[7rem] text-base">
                    <button @click="attachTo(uid, v.name)" class="mx-2"> {{ t('attach') }} </button>
                    <button @click="removeVm(uid, v.name)" class="mx-2"> {{ t('remove') }} </button>
                </div>
            </li>
        </ul>
    </div>

    <!-- controls -->
    <div class="flex w-full h-10 justify-center items-end">
        <button @click="refresh" class="my-0 mx-4">{{ t('refresh') }}</button>
        <button @click="cleanup" class="my-0 mx-4">{{ t('cleanup') }}</button>
        <button @click="close" class="my-0 mx-4">{{ t('close') }}</button>
    </div>
</template>
<style scoped></style>