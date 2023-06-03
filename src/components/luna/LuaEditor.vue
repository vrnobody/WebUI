<script setup>
import { onMounted, onUnmounted, computed, watch, ref } from 'vue'
import utils from '@/misc/utils.js'
import store from '@/misc/store.js'
import config from '@/config'

const t = utils.getTranslator()
const props = defineProps(['script', 'logPanelVisible'])
const emit = defineEmits(['update:script', 'update:logPanelVisible', 'onFullScreen'])

const script = computed({
  get() {
    return props.script
  },
  set(value) {
    emit('update:script', value)
  }
})

const isLogPanelVisible = computed({
  get() {
    return props.logPanelVisible
  },
  set(value) {
    emit('update:logPanelVisible', value)
  }
})

let editor = null
const curAst = ref({})
const globalVarList = ref([])
const functionList = ref([])

watch(props, (newProps) => {
  if (editor === null) {
    return
  }
  const v = newProps.script
  updateEditorContent(v)
})

const isFullScreen = ref(false)

function toggleFullScreen() {
  const v = !isFullScreen.value
  isFullScreen.value = v
  emit('onFullScreen', v)
}

function toggleLogPanel() {
  isLogPanelVisible.value = !isLogPanelVisible.value
}

function updateEditorContent(content) {
  if (editor.getValue() === content) {
    return
  }
  editor.setValue(content)
  editor.clearSelection()
  updateModuleSnippets(content)
}

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

function measureSimilarity(target, snippet) {
  const tlen = target.length
  const slen = snippet.length

  if (tlen > slen || tlen < 1) {
    return 0
  }

  let score = 0
  let j = 0
  for (let i = 0; i < slen; i++) {
    if (target[j] === snippet[i]) {
      score = score + (tlen - j) * 2 + (100 - i)
      j++
    }
    if (j >= tlen) {
      break
    }
  }
  return score
}

function genBestMatchSnippets(prefix) {
  let r = []
  const slen = staticSnippetsLower.length
  const target = prefix.toLowerCase().split('')
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
  identifierRegexps: [/[a-zA-Z_0-9:.(",]/],
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
    editor.completers.splice(index, 1)
  }
}

function updateStaticSnippets(snippets) {
  try {
    const j = JSON.parse(snippets)
    staticSnippets = j
    let keywords = []
    let lowers = []
    for (const snippet of staticSnippets) {
      lowers.push(snippet.value.toLowerCase().split(''))
      if (snippet.meta === 'keyword') {
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

function caseInSensitiveComparer(a, b) {
  return a.toLowerCase().localeCompare(b.toLowerCase())
}

function replaceCurAst(ast) {
  try {
    const o = JSON.parse(ast)
    curAst.value = o
    globalVarList.value = Object.keys(o.vars).sort(caseInSensitiveComparer)
    functionList.value = Object.keys(o.funcs).sort(caseInSensitiveComparer)
  } catch (err) {
    console.log(err)
  }
}

function replaceModuleSnippets(snippets) {
  if (!snippets) {
    return
  }
  try {
    moduleSnippets = JSON.parse(snippets)
  } catch (err) {
    console.log(err)
  }
}

let curCode = ''
function updateModuleSnippets(code) {
  if (!code || code === curCode) {
    return
  }
  curCode = code
  const cb = (function () {
    const capture = code
    return function () {
      if (capture !== curCode) {
        return
      }
      utils.call(replaceModuleSnippets, 'GenLuaModuleSnippets', [capture])
      utils.call(replaceCurAst, 'LuaAnalyzeCode', [capture])
    }
  })()
  setTimeout(cb, 1500)
}

function initEditor(editor) {
  utils.updateEditorTheme(editor)
  editor.session.setMode('ace/mode/lua')

  updateEditorContent(script.value)

  editor.setOptions({
    enableBasicAutocompletion: true,
    enableSnippets: false,
    enableLiveAutocompletion: true
  })

  editor.completers.unshift(staticCompleter)
  editor.completers.push(moduleCompleter)

  addCustomCommands(editor)
  bindEventHandler(editor)
}

let cursorHistoryIndex = -1
let cursorHistoryCache = []

function isDupCursorPosition(row) {
  const idx = cursorHistoryIndex
  const cache = cursorHistoryCache
  if (idx < cache.length && cache.length > 0 && idx >= 0 && cache[idx] === row) {
    return true
  }
  return false
}

function pushCursorPosition() {
  const row = editor.getCursorPosition().row
  if (isDupCursorPosition(row)) {
    return
  }

  if (cursorHistoryIndex < cursorHistoryCache.length) {
    cursorHistoryIndex++
  }
  if (cursorHistoryIndex >= cursorHistoryCache.length) {
    cursorHistoryCache.push(row)
    cursorHistoryIndex = cursorHistoryCache.length - 1
  } else {
    cursorHistoryCache[cursorHistoryIndex] = row
    cursorHistoryCache = cursorHistoryCache.slice(0, cursorHistoryIndex + 1)
  }
}

function bindEventHandler(editor) {
  editor.on('click', function () {
    pushCursorPosition()
  })

  editor.on('change', function () {
    script.value = editor.getValue()
    const code = getTextWithoutCurrentLine()
    updateModuleSnippets(code)
  })
}

function getTextWithoutCurrentLine() {
  let lines = editor.session.getDocument().getAllLines()
  const row = editor.getCursorPosition().row
  if (row < 0 || row >= lines.length) {
    return lines.join('\n')
  }
  lines[row] = ''
  return lines.join('\n')
}

function gotoLine(row) {
  if (row < 1) {
    return
  }
  editor.gotoLine(row)
}

function moveCursor(isForward) {
  cursorHistoryIndex = cursorHistoryIndex + (isForward ? 1 : -1)
  if (cursorHistoryIndex >= cursorHistoryCache.length) {
    cursorHistoryIndex = cursorHistoryCache.length - 1
  }
  if (cursorHistoryIndex < 0) {
    cursorHistoryIndex = 0
    return
  }
  const row = cursorHistoryCache[cursorHistoryIndex]
  gotoLine(row + 1)
}

function getWordAtCursor(editor) {
  // https://stackoverflow.com/questions/5173316/finding-the-word-at-a-position-in-javascript
  const pos = editor.getCursorPosition()
  let str = editor.session.getDocument().getLine(pos.row)
  const col = pos.column

  // Search for the word's beginning and end.
  let left = str.slice(0, col + 1).search(/\w+$/)
  let right = str.slice(col).search(/\W/)

  // The last word in the string is a special case.
  if (right < 0) {
    return str.slice(left)
  }

  // Return the word, using the located bounds to extract it from the string.
  return str.slice(left, right + col)
}

function getLineNumberFromAst(word) {
  const ast = curAst.value
  for (const key in ast.vars) {
    if (key === word) {
      return ast.vars[key]
    }
  }
  for (const key in ast.funcs) {
    if (key === word) {
      return ast.funcs[key].line
    }
  }
  return 0
}

function gotoDefinition() {
  const t = getWordAtCursor(editor)
  const row = getLineNumberFromAst(t)
  if (row > 0) {
    gotoLine(row)
    pushCursorPosition()
  }
}

function addCustomCommands(editor) {
  editor.commands.addCommand({
    name: 'goto definition',
    bindKey: { win: 'F12', mac: 'F12' },
    exec: function () {
      gotoDefinition()
    },
    readOnly: false
  })
}

function selectGlobalVar(evt) {
  const name = evt.target.value
  const row = getLineNumberFromAst(name)
  gotoLine(row)
  pushCursorPosition()
}

function selectFunction(evt) {
  const name = evt.target.value
  const row = getLineNumberFromAst(name)
  gotoLine(row)
  pushCursorPosition()
}

function onKeyDown(e) {
  if (!e.ctrlKey) {
    return
  }

  switch (e.key) {
    case '-':
      e.preventDefault()
      moveCursor(false)
      break
    case '=':
      e.preventDefault()
      moveCursor(true)
      break
  }
}

onMounted(async () => {
  utils.call(updateStaticSnippets, 'GetLuaStaticSnippets')

  editor = ace.edit('lua-editor-container')

  if (config.isDevMode) {
    console.log('export window.editor for debugging')
    window.editor = editor
  }

  initEditor(editor)
  document.addEventListener('keydown', onKeyDown)
  utils.hideScrollbarY()
})

onUnmounted(() => {
  document.removeEventListener('keydown', onKeyDown)
  utils.destroyEditor(editor)
  removeCompleter(staticCompleter)
  removeCompleter(moduleCompleter)
  utils.showScrollbarY()
})
</script>

<template>
  <div class="mt-1 flex bg-slate-400 px-2 py-1 dark:bg-slate-500">
    <label class="px-1">{{ t('vars') }}</label>
    <select
      class="h-6 min-w-0 grow bg-slate-300 dark:bg-slate-600"
      @change="selectGlobalVar($event)"
      onfocus="this.selectedIndex = -1;"
    >
      <option v-for="v in globalVarList" :key="v" :value="v">{{ v }}</option>
    </select>
    <label class="ml-2 px-1">{{ t('funcs') }}</label>
    <select
      class="h-6 min-w-0 grow bg-slate-300 dark:bg-slate-600"
      @change="selectFunction($event)"
      onfocus="this.selectedIndex = -1;"
    >
      <option v-for="v in functionList" :key="v" :value="v">{{ v }}</option>
    </select>
    <button @click="toggleFullScreen" class="w-6 shrink-0 px-2">
      <div v-if="isFullScreen">
        <i class="fas fa-compress-arrows-alt"></i>
      </div>
      <div v-else>
        <i class="fas fa-expand-arrows-alt"></i>
      </div>
    </button>
    <button @click="toggleLogPanel" class="w-6 shrink-0 px-2">
      <div v-if="isLogPanelVisible">
        <i class="fas fa-arrow-right"></i>
      </div>
      <div v-else>
        <i class="fas fa-arrow-left"></i>
      </div>
    </button>
  </div>
  <div class="mt-1 grow text-base" id="lua-editor-container"></div>
</template>

<style scoped></style>
