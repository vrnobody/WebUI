<script setup>
import config from '@/config.js'
import utils from '@/misc/utils.js'
import { useI18n } from '@yangss/vue3-i18n'
import { onMounted, ref } from 'vue'

const t = utils.getTranslator()

const { locale } = useI18n()

const curLang = ref('')

const langs = ['en-US', 'zh-CN']

function switchLang(s) {
    const index = Math.max(0, langs.indexOf(s))
    const lang = langs[index]
    locale.value = lang
    config.set('lang', lang)
    curLang.value = lang
}

onMounted(() => {
    curLang.value = locale.value
})
</script>

<template>
    <div class="inline-flex h-full w-full items-center justify-end">
        <ul class="text-neutral-600 dark:text-neutral-400">
            <li v-if="curLang !== 'en-US'" class="m-0 inline-block pr-2.5">
                <a href="javascript:" @click.prevent="switchLang('en-US')" class="m-0 p-0 text-sm"
                    >English</a
                >
            </li>
            <li v-if="curLang !== 'zh-CN'" class="m-0 inline-block pr-2.5">
                <a href="javascript:" @click.prevent="switchLang('zh-CN')" class="m-0 p-0 text-sm"
                    >简体中文</a
                >
            </li>
        </ul>
    </div>
</template>

<style scoped></style>
