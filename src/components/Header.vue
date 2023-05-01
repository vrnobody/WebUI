<script setup>
import { useI18n } from '@yangss/vue3-i18n'

const { locale } = useI18n()

function switchLang(lang) {
  let langs = ['enUS', 'zhCN']
  if (langs.indexOf(lang) >= 0) {
    locale.value = lang
  } else {
    locale.value = langs[0]
  }
}
</script>

<template>
  <div class="app-name">V2RayGCon</div>
  <div class="tools-box">
    <ul>
      <li>
        <a href="javascript:" @click.prevent="switchLang('enUS')">English</a>
      </li>
      <li>
        <a href="javascript:" @click.prevent="switchLang('zhCN')">简体中文</a>
      </li>
    </ul>
  </div>
</template>

<style scoped>
ul {
  display: block;
  margin: 0rem;
  padding: 0rem;
}

li {
  padding-right: 0.6rem;
  margin: 0rem;
  display: inline-block;
}

li a {
  font-size: 0.8em;
  text-decoration: none;
  margin: 0rem;
  padding: 0rem;
  color: gray;
}

.app-name {
  flex-basis: 14rem;
  flex-grow: 0;
  flex-shrink: 0;
  height: 100%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  float: left;
  background-color: #333;
  color: whitesmoke;
  font-size: 1.5em;
  font-family: Segoe UI, monospace;
}

.tools-box {
  height: 100%;
  display: inline-flex;
  justify-content: end;
  align-items: center;
  width: 100%;
  background-color: whitesmoke;
  font-family: Segoe UI, monospace;
}
</style>
