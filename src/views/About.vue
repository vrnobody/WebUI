<script setup>
import utils from '@/misc/utils.js'

const t = utils.getTranslator()
</script>

<template>
    <pre class="m-4 dark:text-neutral-100">
<b>WebUI v1.0.1 2023-11</b>
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
