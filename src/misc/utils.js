import config from '../config.js'
import configs from '../config.js'

const host = config.isDevMode ? configs.devHostUrl : configs.releaseHostUrl

let t = null

function isDarkMode() {
    const mode = configs.getThemeMode()
    if (!mode || mode === "system") {
        return window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    return mode === "dark"
}

function reloadThemeMode() {
    const dark = isDarkMode()
    const css = document.createElement('link')
    css.rel = 'stylesheet'
    if (dark) {
        css.href = '/css/swal-dark.css'
        document.documentElement.classList.add('dark')
    } else {
        css.href = '/css/swal-light.css'
        document.documentElement.classList.remove('dark')
    }
    document.head.appendChild(css)
}

function pop(msg, ps) {
    msg = t && t(msg) || msg
    const m = [msg, ...ps].join('\n')
    Swal.fire(m)
}

function post(callback, content) {
    const httpRequest = new XMLHttpRequest()
    httpRequest.open('POST', host, true)
    httpRequest.onreadystatechange = function () {
        if (httpRequest.readyState == 4 && httpRequest.status == 200) {
            const resp = httpRequest.responseText
            let j = null
            try {
                j = JSON.parse(resp)
            } catch (err) {
                pop('parseRespError', [err])
                return
            }

            const r = j['r']
            if (!j['ok']) {
                pop(r, j['ps'])
                return
            }

            try {
                callback && callback(r)
            } catch (err) {
                const fn = callback.name + "()"
                pop('callbackFuncError', [fn, err])
                return
            }
        }
    }

    httpRequest.onerror = function (err) {
        pop('sendReqError', [err])
    }

    httpRequest.send(content)
}

function copyToClipboard(v) {
    navigator.clipboard.writeText(v)
}

function call(callback, fn, ps) {
    let req = {
        fn: fn,
        ps: ps || [],
    }
    post(callback, JSON.stringify(req))
}

async function init(tt) {
    t = tt
}

function getTranslator() {
    return t
}

function showScrollbarY() {
    document.body.style.overflowY = ''
}

function hideScrollbarY() {
    document.body.style.overflowY = 'hidden'
}

function updateEditorTheme(editor) {
    if (editor === null) {
        return
    }
    const theme = isDarkMode() ? "ace/theme/solarized_dark" : "ace/theme/solarized_light"
    editor.setTheme(theme)
}

function destroyEditor(editor) {
    if (!editor) {
        return
    }
    editor.destroy()
    editor.container.remove()
}

function trim(str, len) {
    if (str.length < len - 3) {
        return str
    }
    return str.slice(0, len - 3) + '...'
}

function confirm(title, onYes, onNo) {
    Swal.fire({
        title: title,
        showDenyButton: true,
        confirmButtonText: t('yes'),
        denyButtonText: t('no'),
    }).then((result) => {
        if (result.isConfirmed) {
            if (typeof (onYes) === 'function') {
                onYes()
            }
        } else {
            if (typeof (onNo) === 'function') {
                onNo()
            }
        }
    })
}

export default {
    copyToClipboard,
    confirm,
    trim,
    getTranslator,
    updateEditorTheme,
    destroyEditor,
    showScrollbarY,
    hideScrollbarY,
    call,
    init,
    reloadThemeMode,
}