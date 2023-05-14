<script setup>
import { onMounted, onUnmounted, computed, watch } from 'vue'
import utils from '../misc/utils.js'
import store from '../misc/store.js'

const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])

const servConfig = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

let editor = null

watch(store.onThemeChanges, () => {
  utils.updateEditorTheme(editor)
})

onMounted(async () => {

  utils.hideScrollbarY()

  editor = ace.edit('json-editor-container')
  utils.updateEditorTheme(editor)
  editor.session.setMode("ace/mode/json")
  editor.setValue(servConfig.value)

  editor.setOptions({
    enableBasicAutocompletion: true,
    enableSnippets: true,
    enableLiveAutocompletion: true
  })

  jsonLintProvider.registerEditor(editor);
  jsonLintProvider.setSessionOptions(editor.session, { schemaUri: "common.schema.json" });

  editor.on('change', function () {
    servConfig.value = editor.getValue()
  })
})

onUnmounted(() => {
  if (editor) {
    editor.destroy()
    editor.container.remove()
  }
  utils.showScrollbarY()
})

</script>

<template>
  <div class="text-base block grow w-full h-4/5" id="json-editor-container">
  </div>
</template>

<style scoped></style>
