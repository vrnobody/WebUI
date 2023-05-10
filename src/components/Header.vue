<script setup>
import { useI18n } from '@yangss/vue3-i18n'

const { locale } = useI18n()

function switchLang(lang) {
  const langs = ['enUS', 'zhCN']
  if (langs.indexOf(lang) >= 0) {
    locale.value = lang
  } else {
    locale.value = langs[0]
  }
}
</script>

<template>
  <div class="h-full inline-flex justify-end items-center w-full bg-neutral-100">
    <ul>
      <li class="pr-2.5 m-0 inline-block">
        <a href="javascript:" @click.prevent="switchLang('enUS')" class="text-sm m-0 p-0 text-zinc-500">English</a>
      </li>
      <li class="pr-2.5 m-0 inline-block">
        <a href="javascript:" @click.prevent="switchLang('zhCN')" class="text-sm m-0 p-0 text-zinc-500">简体中文</a>
      </li>
    </ul>
  </div>
</template>

<style scoped></style>
