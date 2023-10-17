<script setup>
import config from '@/config.js'
import utils from '@/misc/utils.js'
import { useI18n } from '@yangss/vue3-i18n'

const t = utils.getTranslator()

const { locale } = useI18n()

function switchLang(lang) {
    const langs = ['en-US', 'zh-CN']
    const index = langs.indexOf(lang)
    locale.value = langs[index < 0 ? 0 : index]
    config.set('lang', locale.value)
}

function clearPassword() {
    function onYes() {
        config.set('token', '')
        config.saveAdminToken('')
        config.save()
        utils.reloadPage()
    }
    utils.confirm(t('clearPassword'), onYes)
}

function isTokenSet() {
    const token = config.get('token')
    // console.log("token:", token)
    return token && token.length > 1
}
</script>

<template>
    <div class="inline-flex h-full w-full items-center justify-end">
        <ul class="text-neutral-600 dark:text-neutral-400">
            <li v-if="isTokenSet()" class="m-0 inline-block pr-2.5">
                <a href="javascript:" @click.prevent="clearPassword()" class="m-0 p-0 text-sm"
                    ><i class="fas fa-sign-out-alt"></i>{{ t('logout') }}</a
                >
            </li>
            <li class="m-0 inline-block pr-2.5">
                <a href="javascript:" @click.prevent="switchLang('en-US')" class="m-0 p-0 text-sm"
                    >English</a
                >
            </li>
            <li class="m-0 inline-block pr-2.5">
                <a href="javascript:" @click.prevent="switchLang('zh-CN')" class="m-0 p-0 text-sm"
                    >简体中文</a
                >
            </li>
        </ul>
    </div>
</template>

<style scoped></style>
