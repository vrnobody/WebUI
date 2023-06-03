<script setup>
import utils from '@/misc/utils.js'
import { onMounted, ref } from 'vue'

const emit = defineEmits(['onClose'])

const servSettings = ref({})

const t = utils.getTranslator()

const servSettingKeys = [
  'inbMode',
  'inbIp',
  'inbPort',
  'isAutoRun',
  'mark',
  'remark',
  'tag1',
  'tag2',
  'tag3'
]

const selection = {}

function initSelection() {
  for (const key of servSettingKeys) {
    selection[key] = false
  }
}

function getElementType(key) {
  switch (key) {
    case 'inbMode':
      return 'select'
    case 'isAutoRun':
      return 'checkbox'
    default:
      break
  }
  return 'text'
}

function loadSettings() {
  initSelection()

  const next = function (tags) {
    if (tags) {
      servSettings.value = tags
      return
    }
    Swal.fire(t('failed'))
  }

  utils.call(next, 'GetFirstSelectedServerSettings')
}

function save() {
  const s = {}
  for (const key of servSettingKeys) {
    if (selection[key]) {
      s[key] = servSettings.value[key]
    }
  }

  const next = function (ok) {
    if (ok) {
      close()
      return
    }
    Swal.fire(t('failed'))
  }

  utils.call(next, 'ChangeSelectedServersSetting', [s])
}

function close() {
  emit('onClose')
}

onMounted(() => {
  loadSettings()
})
</script>
<template>
  <div class="block h-4/5 w-full grow bg-slate-400 p-4 dark:bg-slate-600">
    <div v-for="key in servSettingKeys" :key="key">
      <div class="flex h-9 items-center">
        <div class="mx-2 w-12 p-0">
          <input type="checkbox" v-model="selection[key]" class="h-4 w-4 px-1" />
        </div>
        <div class="mx-2 w-32 p-0">{{ t(key) }}</div>
        <div class="mx-2 flex grow p-0">
          <select
            v-if="getElementType(key) === 'select'"
            v-model="servSettings[key]"
            class="grow border border-neutral-400 bg-neutral-300 dark:bg-slate-600"
          >
            <option value="0">Config</option>
            <option value="1">HTTP</option>
            <option value="2">SOCKS</option>
            <option value="3">{{ t('custom') }}</option>
          </select>
          <input
            v-if="getElementType(key) === 'text'"
            type="text"
            v-model="servSettings[key]"
            class="grow bg-neutral-100 px-1 dark:bg-slate-500"
          />
          <input
            v-if="getElementType(key) === 'checkbox'"
            type="checkbox"
            v-model="servSettings[key]"
            class="h-4 w-4 px-1"
          />
        </div>
      </div>
    </div>
  </div>
  <div class="flex h-10 w-full items-end justify-center">
    <button @click="save" class="mx-4 my-0">{{ t('save') }}</button>
    <button @click="close" class="mx-4 my-0">{{ t('close') }}</button>
  </div>
</template>
<style scoped></style>
