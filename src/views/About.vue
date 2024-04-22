<script setup>
import utils from '@/misc/utils.js'
import config from '@/config.js'

const t = utils.getTranslator()
const ver = config.webUiVersion
</script>

<template>
    <pre class="m-4 dark:text-neutral-100">
<b>WebUI v{{ver}} 2024-04</b>
<a href="https://github.com/vrnobody/WebUI">https://github.com/vrnobody/WebUI</a>

<b>{{ t('servPanelAndLunaManagerTitle') }}</b>
{{ t('servPanelAndLunaManagerContent') }}

<b>{{ t('lunaEditorKeyboardShortcutsTitle') }}</b>
{{ t('lunaEditorKeyboardShortcutsContent') }}

<b>{{ t('creditsTitle') }}</b>
{{ t('creditsContent') }}
  </pre>
</template>

<style scoped></style>
