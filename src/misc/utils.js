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
    if (dark) {
        document.documentElement.classList.add('dark')
    } else {
        document.documentElement.classList.remove('dark')
    }
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

            if (callback === null) {
                return
            }

            try {
                callback(r)
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

function call(callback, fn, ps) {
    let req = {
        fn: fn,
        ps: ps || [],
    }
    post(callback, JSON.stringify(req))
}

async function init(tt) {
    t = tt

    const localLinterUrl = window.location.origin + "/ace/linters/"
    let provider = LanguageProvider.fromCdn(localLinterUrl);

    const schema = await import('../assets/v4-config-schema.json')

    provider.setGlobalOptions("json", {
        schemas: [
            {
                uri: "common.schema.json",
                schema: JSON.stringify(schema),
            }
        ]
    });
    window.jsonLintProvider = provider
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

export default {
    updateEditorTheme,
    showScrollbarY,
    hideScrollbarY,
    call,
    init,
    reloadThemeMode,
}