<script setup>
import { onMounted, onUnmounted, computed, watch, ref } from 'vue'
import utils from '../../misc/utils.js'
import store from '../../misc/store.js'
import config from '../../config';

const t = utils.getTranslator()
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
const curAst = ref({})
const globalVarList = ref({})
const functionList = ref({})

watch(props, (newProps) => {
  if (editor === null) {
    return
  }
  const v = newProps.modelValue
  updateEditorContent(v)
})

function updateEditorContent(content) {
  if (editor.getValue() === content) {
    return
  }
  editor.setValue(content)
  editor.clearSelection()
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
      break;
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

function replaceCurAst(ast) {
  try {
    const o = JSON.parse(ast)
    curAst.value = o
    globalVarList.value = o.vars
    functionList.value = o.funcs
  } catch (err) {
    console.log(err.toString())
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
      utils.call(replaceCurAst, 'LuaAnalyzeCode', [capture])
    }
  }()
  setTimeout(cb, 1500)
}

function initEditor(editor) {
  utils.updateEditorTheme(editor)
  editor.session.setMode("ace/mode/lua")

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
function pushCursorPosition() {
  const pos = editor.getCursorPosition()
  cursorHistoryIndex++
  if (cursorHistoryIndex >= cursorHistoryCache.length) {
    cursorHistoryCache.push(pos)
    cursorHistoryIndex = cursorHistoryCache.length - 1
  } else {
    cursorHistoryCache[cursorHistoryIndex] = pos
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

function moveCursor(editor, isForward) {
  cursorHistoryIndex = cursorHistoryIndex + (isForward ? 1 : -1)
  if (cursorHistoryIndex >= cursorHistoryCache.length) {
    cursorHistoryIndex = cursorHistoryCache.length - 1
  }
  if (cursorHistoryIndex < 0) {
    cursorHistoryIndex = 0
    return
  }
  const pos = cursorHistoryCache[cursorHistoryIndex]
  gotoLine(pos.row + 1)
}

function getWordAtCursor(editor) {
  // https://stackoverflow.com/questions/5173316/finding-the-word-at-a-position-in-javascript
  const pos = editor.getCursorPosition()
  let str = editor.session.getDocument().getLine(pos.row)
  const col = pos.column;

  // Search for the word's beginning and end.
  let left = str.slice(0, col + 1).search(/\w+$/)
  let right = str.slice(col).search(/\W/);

  // The last word in the string is a special case.
  if (right < 0) {
    return str.slice(left);
  }

  // Return the word, using the located bounds to extract it from the string.
  return str.slice(left, right + col);
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

function addCustomCommands(editor) {
  editor.commands.addCommand({
    name: 'cursor go back',
    bindKey: { win: 'Ctrl--', mac: 'Command--' },
    exec: function (editor) {
      moveCursor(editor, false)
    },
    readOnly: false,
  })
  editor.commands.addCommand({
    name: 'cursor go forward',
    bindKey: { win: 'Ctrl-=', mac: 'Command-=' },
    exec: function (editor) {
      moveCursor(editor, true)
    },
    readOnly: false,
  })
  editor.commands.addCommand({
    name: 'cursor goto definition',
    bindKey: { win: 'F12', mac: 'F12' },
    exec: function (editor) {
      const t = getWordAtCursor(editor)
      const row = getLineNumberFromAst(t)
      if (row > 0) {
        gotoLine(row)
        pushCursorPosition()
      }
    },
    readOnly: false,
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

onMounted(async () => {

  utils.call(updateStaticSnippets, "GetLuaStaticSnippets")

  editor = ace.edit('lua-editor-container')

  if (config.isDevMode) {
    console.log('export window.debugEditor for debugging')
    window.debugEditor = editor
  }

  initEditor(editor)
})

onUnmounted(() => {
  utils.destroyEditor(editor)
  removeCompleter(staticCompleter)
  removeCompleter(moduleCompleter)
})



</script>

<template>
  <div class="dark:bg-slate-500 bg-slate-400 mr-1 mt-1 p-1 flex">
    <label class="flex w-14 justify-end px-2 shrink-0">{{ t('vars') }}</label>
    <select class="dark:bg-slate-600 bg-slate-300 grow h-6 min-w-0" @change="selectGlobalVar($event)">
      <option v-for="(_, key) in globalVarList" :value="key">{{ key }}</option>
    </select>
    <label class="flex w-14 justify-end px-2 shrink-0">{{ t('funcs') }}</label>
    <select class="dark:bg-slate-600 bg-slate-300 grow h-6 min-w-0" @change="selectFunction($event)">
      <option v-for="(_, key) in functionList" :value="key">{{ key }}</option>
    </select>
  </div>
  <div class="grow mr-1 mt-1 text-base" id="lua-editor-container"></div>
</template>

<style scoped></style>
