<script setup>
import { useI18n } from '@yangss/vue3-i18n'
import cfg from '../config.js'

const { locale } = useI18n()

function switchLang(lang) {
  const langs = ['en-US', 'zh-CN']
  const index = langs.indexOf(lang)
  locale.value = langs[index < 0 ? 0 : index]
  cfg.set('lang', locale.value)
}
</script>

<template>
  <div class="h-full inline-flex justify-end items-center w-full bg-neutral-100">
    <ul>
      <li class="pr-2.5 m-0 inline-block">
        <a href="javascript:" @click.prevent="switchLang('en-US')" class="text-sm m-0 p-0 text-zinc-500">English</a>
      </li>
      <li class="pr-2.5 m-0 inline-block">
        <a href="javascript:" @click.prevent="switchLang('zh-CN')" class="text-sm m-0 p-0 text-zinc-500">简体中文</a>
      </li>
    </ul>
  </div>
</template>

<style scoped></style>
