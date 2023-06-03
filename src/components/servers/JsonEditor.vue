<script setup>
import { onMounted, onUnmounted, computed, watch } from 'vue'
import utils from '@/misc/utils.js'
import store from '@/misc/store.js'

const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])

let editor = null

const servConfig = computed({
    get() {
        return props.modelValue
    },
    set(value) {
        emit('update:modelValue', value)
    }
})

watch(store.onThemeChanges, () => {
    utils.updateEditorTheme(editor)
})

async function createJsonConfigV4LintSvcProvider() {
    const localLinterUrl = window.location.origin + '/ace/linters/'
    const provider = LanguageProvider.fromCdn(localLinterUrl)

    const r = await fetch('/ace/linters/v4-config-schema.json')
    const schema = await r.text()

    provider.setGlobalOptions('json', {
        schemas: [
            {
                uri: 'common.schema.json',
                schema: schema
            }
        ]
    })

    return provider
}

onMounted(async () => {
    utils.hideScrollbarY()

    editor = ace.edit('json-editor-container')
    utils.updateEditorTheme(editor)
    editor.session.setMode('ace/mode/json')
    editor.setValue(servConfig.value)
    editor.clearSelection()

    editor.setOptions({
        enableBasicAutocompletion: true,
        enableSnippets: true,
        enableLiveAutocompletion: true
    })

    const provider = window.aceJsonLintSvcProvider || (await createJsonConfigV4LintSvcProvider())
    provider.registerEditor(editor)
    provider.setSessionOptions(editor.session, { schemaUri: 'common.schema.json' })
    window.aceJsonLintSvcProvider = provider

    editor.on('change', function () {
        servConfig.value = editor.getValue()
    })
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
