<script setup>
import utils from '@/misc/utils.js'
const t = utils.getTranslator()
</script>
<template>
    <div class="flex w-full grow items-baseline justify-center">
        <div class="mt-8 animate-bounce text-xl">{{ t('loading') }}</div>
    </div>
</template>
<style scoped></style>
