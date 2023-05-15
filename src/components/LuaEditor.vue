<script setup>
import { onMounted, onUnmounted, computed, watch } from 'vue'
import utils from '../misc/utils.js'
import store from '../misc/store.js'

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
let moduleSnippets = []

const moduleCompleter = {
  getCompletions: function (source, session, pos, prefix, callback) {
    if (session !== editor.session) {
      return
    }
    callback(null, moduleSnippets)
  }
}

const staticCompleter = {
  getCompletions: function (source, session, pos, prefix, callback) {
    if (session !== editor.session) {
      console.log('staticCompleter: wrong session, pass!')
      return
    }
    callback(null, staticSnippets)
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
  } catch (err) {
    Swal.fire(err.toString())
  }
}

function replaceModuleSnippets(snippets) {
  if (!snippets || snippets.length < 1) {
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

  window.debugEditor = editor

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
