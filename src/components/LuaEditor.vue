<script setup>
import { onMounted, onUnmounted, computed, watch } from 'vue'
import utils from '../misc/utils.js'
import store from '../misc/store.js'
import config from '../config';

const props = defineProps(['modelValue'])
const emit = defineEmits(['update:modelValue'])

const script = computed({
  get() {
    return props.modelValue
  },
  set(value) {
    emit('update:modelValue', value)
  }
})

let editor = null

watch(props, (newProps) => {
  if (editor === null) {
    return
  }
  const v = newProps.modelValue
  if (editor.getValue() !== v) {
    editor.setValue(v)
  }
})

watch(store.onThemeChanges, () => {
  utils.updateEditorTheme(editor)
})

/*
snippets usage:

callback(null, [
  {
    caption: 'kvp', // 匹配关键词
    value: 'for k, v in ipairs(t) do\n    print(k, v)\nend',   // 把匹配到的替换为这个
    score: 100, // 越大越靠前
    meta: "snippet" // 随便写
  }
])
*/

let staticSnippets = []
let staticSnippetsLower = []
let staticKeywordSnippets = []
let moduleSnippets = []

const moduleCompleter = {
  getCompletions: function (source, session, pos, prefix, callback) {
    if (session !== editor.session) {
      return
    }
    callback(null, moduleSnippets)
  }
}

function measureSimilarity(target, standar) {
  const tlen = target.length
  const slen = standar.length

  if (tlen > slen) {
    return 0
  }

  target = target.toLowerCase()
  let score = 0
  let tIdx = 0
  for (let i = 0; i < slen; i++) {
    if (target.charAt(tIdx) === standar.charAt(i)) {
      score = score + (tlen - tIdx) * 2 + (100 - i)
      tIdx++
    }
    if (tIdx >= tlen) {
      break;
    }
  }
  return score
}

function genBestMatchSnippets(prefix) {
  let r = []
  const slen = staticSnippetsLower.length
  const target = prefix.toLowerCase()
  for (let i = 0; i < slen; i++) {
    const snippet = staticSnippetsLower[i]
    const score = measureSimilarity(target, snippet)
    if (score > 0) {
      const snp = staticSnippets[i]
      r.push(snp)
    }
  }
  return r
}

const staticCompleter = {
  identifierRegexps: [/[a-zA-Z_0-9:\.\(\",]/],
  getCompletions: function (source, session, pos, prefix, callback) {
    if (session !== editor.session) {
      console.log('staticCompleter: wrong session, pass!')
      return
    }
    if (prefix.length < 2) {
      callback(null, staticKeywordSnippets)
      return
    }
    let snippets = genBestMatchSnippets(prefix)
    callback(null, snippets)
  }
}

function removeCompleter(completer) {
  if (!editor) {
    return
  }
  const index = editor.completers.indexOf(completer)
  if (index >= 0) {
    editor.completers.splice(index, 1);
  }
}

function updateStaticSnippets(snippets) {
  try {
    const j = JSON.parse(snippets)
    staticSnippets = j
    let keywords = []
    let lowers = []
    for (const snippet of staticSnippets) {
      lowers.push(snippet.value.toLowerCase())
      if (snippet.meta === "keyword") {
        snippet['score'] = 100
        keywords.push(snippet)
      }
    }
    staticSnippetsLower = lowers
    staticKeywordSnippets = keywords
  } catch (err) {
    Swal.fire(err.toString())
  }
}

function replaceModuleSnippets(snippets) {
  if (!snippets) {
    return
  }
  try {
    moduleSnippets = JSON.parse(snippets)
  } catch (error) {
    console.log(error)
  }
}

let curCode = ""
function updateModuleSnippets(code) {
  if (!code || code === curCode) {
    return
  }
  curCode = code
  const cb = function () {
    const capture = code
    return function () {
      if (capture !== curCode) {
        return
      }
      utils.call(replaceModuleSnippets, 'GenLuaModuleSnippets', [capture])
    }
  }()
  setTimeout(cb, 2000)
}

onMounted(async () => {

  utils.call(updateStaticSnippets, "GetLuaStaticSnippets")

  editor = ace.edit('lua-editor-container')

  utils.updateEditorTheme(editor)
  editor.session.setMode("ace/mode/lua")
  editor.setValue(script.value)

  editor.setOptions({
    enableBasicAutocompletion: true,
    enableSnippets: false,
    enableLiveAutocompletion: true
  })

  editor.completers.unshift(staticCompleter)
  editor.completers.push(moduleCompleter)

  if (config.isDevMode) {
    console.log('export window.debugEditor for debugging')
    window.debugEditor = editor
  }


  editor.on('change', function () {
    const text = editor.getValue()
    script.value = text
    updateModuleSnippets(text)
  })
})

onUnmounted(() => {
  utils.destroyEditor(editor)
  removeCompleter(staticCompleter)
  removeCompleter(moduleCompleter)
})

</script>

<template>
  <div class="grow mr-1 mt-1 text-base" id="lua-editor-container"></div>
</template>

<style scoped></style>
