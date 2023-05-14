<script setup>
import { onMounted, onUnmounted, computed, watch } from 'vue'
import utils from '../misc/utils.js'
import store from '../misc/store.js'

const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])

const script = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

let editor = null

watch(props, (newProps) => {
  if (editor === null) {
    return
  }
  const v = newProps.modelValue
  if (editor.getValue() !== v) {
    editor.setValue(v)
  }
})

watch(store.onThemeChanges, () => {
  utils.updateEditorTheme(editor)
})


onMounted(async () => {

  editor = ace.edit('lua-editor-container')

  utils.updateEditorTheme(editor)
  editor.session.setMode("ace/mode/lua")
  editor.setValue(script.value)

  editor.setOptions({
    enableBasicAutocompletion: true,
    enableSnippets: true,
    enableLiveAutocompletion: true
  })

  editor.on('change', function () {
    script.value = editor.getValue()
  })
})

onUnmounted(() => {
  if (editor) {
    editor.destroy()
    editor.container.remove()
  }
})

</script>

<template>
  <div class="grow mr-1 mt-1 text-base" id="lua-editor-container"></div>
</template>

<style scoped></style>
