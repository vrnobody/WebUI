<script setup>
import utils from '../../misc/utils.js'
const t = utils.getTranslator()
</script>
<template>
    <div class="flex justify-center items-baseline w-full grow ">
        <div class="animate-bounce text-xl mt-8">{{ t('loading') }}</div>
    </div>
</template>
<style scoped></style>