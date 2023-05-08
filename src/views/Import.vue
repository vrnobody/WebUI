<script setup>
import utils from '../misc/utils.js'
import { ref } from 'vue'
import { useI18n } from '@yangss/vue3-i18n'

const { _, t } = useI18n()

let content = ref("")
let mark = ref("")

function importShareLinks() {
  let links = content.value
  let mk = mark.value
  let next = function (count) {
    let msg = t('nNewServerImported', {
      count: count
    })
    console.log(msg)
    Swal.fire(msg)
  }
  utils.call(next, "ImportShareLinks", [links, mk])
}

</script>

<template>
  <div class="main-wrapper">
    <div class="title-wrapper">
      {{ t('mark') }}
    </div>
    <div class="mark-wrapper">
      <input v-model="mark" type="text" class="mark" />
    </div>
    <div class="title-wrapper">
      {{ t('shareLinks') }}
    </div>
    <div class="content-wrapper">
      <textarea v-model="content" class="content" placeholder="vmess://... vless://... trojan://...">
      </textarea>
    </div>
    <div class="controls-wrapper">
      <button @click="importShareLinks">{{ t('import') }}</button>
    </div>

  </div>
</template>

<style scoped>
@media (max-width: 800px) {
  body .main-wrapper {
    left: 0rem;
  }
}

.mark {
  background-color: #fafafa;
  padding: 0.2rem 0.5rem;
  width: 100%;
}

.title-wrapper {
  display: flex;
  align-items: center;
  justify-content: start;
  color: #999;
}

.mark-wrapper {
  width: 100%;
  height: 2.5rem;
}

.content-wrapper {
  display: flex;
  width: 100%;
  flex-grow: 1;
}

.content {
  width: 100%;
  height: 100%;
  padding: 0.2rem 0.5rem;
}

.controls-wrapper {
  display: flex;
  justify-content: center;
  align-items: end;
  height: 2rem;
  width: 100%;
}

.main-wrapper {
  display: flex;
  position: fixed;
  top: 3rem;
  left: 14rem;
  flex-direction: column;
  right: 0rem;
  bottom: 0rem;
  background-color: #eee;
  padding: 0.8rem;
}
</style>
