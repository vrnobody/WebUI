<script setup>
import { onMounted, onUnmounted, computed, watch } from 'vue'
import utils from '@/misc/utils.js'
import store from '@/misc/store.js'

const props = defineProps(['config', 'type', 'isfinalconfig'])
const emit = defineEmits(['update:config'])

let editor = null

const isFinalConfig = computed({
    get() {
        return props.isfinalconfig
    }
})

const servConfig = computed({
    get() {
        return props.config
    },
    set(value) {
        emit('update:config', value)
    }
})

const servConfigType = computed({
    get() {
        return props.type
    }
})

watch(store.onThemeChanges, () => {
    utils.updateEditorTheme(editor)
})

onMounted(async () => {
    utils.hideScrollbarY()

    editor = ace.edit('json-editor-container')
    utils.updateEditorTheme(editor)
    let mode = 'ace/mode/json'
    switch (servConfigType.value) {
        case 'yaml':
            mode = 'ace/mode/yaml'
            break
    }
    editor.session.setMode(mode)
    editor.setValue(servConfig.value)
    editor.clearSelection()

    editor.setOptions({
        enableBasicAutocompletion: true,
        enableSnippets: true,
        enableLiveAutocompletion: true
    })

    if (isFinalConfig.value) {
        editor.setReadOnly(true)
    } else {
        editor.on('change', function () {
            servConfig.value = editor.getValue()
        })
    }
})

onUnmounted(() => {
    utils.destroyEditor(editor)
    utils.showScrollbarY()
})
</script>

<template>
    <div class="block h-4/5 w-full grow text-base" id="json-editor-container"></div>
</template>

<style scoped></style>
