<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
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

onUnmounted(() => {})
</script>
<template>
  <!-- header -->
  <div
    class="table h-6 w-full grow-0 bg-slate-400 text-xs text-neutral-600 dark:bg-slate-600 dark:text-neutral-200"
  >
    <div class="table-cell w-[4rem] px-1 py-0 text-center align-middle">{{ t('status') }}</div>
    <div class="table-cell w-[22rem] px-1 py-0 text-center align-middle">{{ t('uuid') }}</div>
    <div class="table-cell px-1 py-0 text-center align-middle">{{ t('name') }}</div>
    <div class="table-cell w-[7rem] px-1 py-0 text-center align-middle">{{ t('controls') }}</div>
  </div>

  <!-- empty list -->
  <div v-if="Object.keys(vmInfos).length <= 0" class="flex grow justify-center">
    <div class="mt-8 text-lg">{{ t('listIsEmpty') }}</div>
  </div>

  <!-- content -->
  <div v-else class="block w-full grow overflow-y-auto bg-neutral-100 dark:bg-slate-400">
    <ul>
      <li
        v-for="(v, uid) in vmInfos"
        :key="uid"
        class="table h-8 w-full text-base odd:bg-neutral-200 dark:odd:bg-slate-500"
      >
        <div class="table-cell w-[4rem] px-1 py-0 text-center align-middle leading-[0rem]">
          <span
            v-if="v.on"
            class="rounded bg-lime-500 px-1 py-0.5 text-xs text-neutral-100 dark:bg-lime-600 dark:text-neutral-100"
            >{{ t('on') }}</span
          >
          <span
            v-else
            class="rounded bg-red-600 px-1 py-0.5 text-xs text-neutral-100 dark:bg-red-700 dark:text-neutral-100"
            >{{ t('off') }}</span
          >
        </div>
        <div class="table-cell w-[22rem] px-1 py-0 text-center align-middle">
          <input
            type="text"
            :value="uid"
            class="w-full border border-neutral-400 bg-neutral-300 px-1 text-center dark:border-0 dark:bg-slate-600"
            readonly
          />
        </div>
        <div class="table-cell px-1 py-0 text-center align-middle">
          <input
            type="text"
            :value="v.name"
            class="w-full border border-neutral-400 bg-neutral-300 px-1 dark:border-0 dark:bg-slate-600"
            readonly
          />
        </div>
        <div class="table-cell w-[7rem] px-1 py-0 text-center align-middle text-base">
          <button @click="attachTo(uid, v.name)" class="mx-2">{{ t('attach') }}</button>
          <button @click="removeVm(uid, v.name)" class="mx-2">{{ t('remove') }}</button>
        </div>
      </li>
    </ul>
  </div>

  <!-- controls -->
  <div class="flex h-10 w-full items-end justify-center">
    <button @click="refresh" class="mx-4 my-0">{{ t('refresh') }}</button>
    <button @click="cleanup" class="mx-4 my-0">{{ t('cleanup') }}</button>
    <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
  </div>
</template>
<style scoped></style>
