import config from '@/config.js'

const host = config.isDevMode ? config.devHostUrl : config.releaseHostUrl

let t = null

function isDarkMode() {
    const mode = config.getThemeMode()
    if (!mode || mode === 'system') {
        return window.matchMedia('(prefers-color-scheme: dark)').matches
    }
    return mode === 'dark'
}

function reloadThemeMode() {
    const dark = isDarkMode()
    const css = document.createElement('link')
    css.rel = 'stylesheet'
    if (dark) {
        css.href = './css/swal-dark.css'
        document.documentElement.classList.add('dark')
    } else {
        css.href = './css/swal-light.css'
        document.documentElement.classList.remove('dark')
    }
    document.head.appendChild(css)
}

function pop(msg, ps) {
    msg = (t && t(msg)) || msg
    const m = [msg, ...ps].join('\n')
    Swal.fire(m)
}

function reloadPage() {
    location.reload()
}

let isChangingPassword = false
function changePassword(isAdmin) {
    if (isChangingPassword) {
        return
    }
    isChangingPassword = true

    const title = isAdmin ? t('enterAdminPassword') : t('enterPassword')

    function genToken(salt) {
        Swal.fire({
            title: title,
            input: 'password',
            inputPlaceholder: t('password'),
            inputAttributes: {
                maxlength: 256,
                autocapitalize: 'off',
                autocorrect: 'off'
            }
        }).then((r) => {
            isChangingPassword = false
            if (!r.isConfirmed || !r.value || r.value.length < 1) {
                return
            }
            const password = salt + r.value
            sha512(password).then((token) => {
                if (isAdmin) {
                    config.saveAdminToken(token)
                } else {
                    config.set('token', token)
                    config.save()
                }
                call(reloadPage(), 'IsValidToken')
            })
        })
    }
    call(genToken, 'GetSalt')
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
                switch (r) {
                    case 'unAuthorizedOperation':
                        changePassword(false)
                        return
                    case 'requireAdminPrivilege':
                        changePassword(true)
                        return
                }
                pop(r, j['ps'])
                return
            }

            try {
                callback && callback(r)
            } catch (err) {
                const fn = callback.name + '()'
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
    const req = {
        fn: fn,
        ps: ps || [],
        token: config.get('token'),
        admintoken: config.getAdminToken()
    }
    post(callback, JSON.stringify(req))
}

async function init(tt) {
    t = tt
}

function getTranslator() {
    return t
}

function scrollToPageTop() {
    window.scrollTo(0, 0)
}

function showScrollbarY() {
    document.body.style.overflowY = ''
}

function hideScrollbarY() {
    document.body.style.overflowY = 'hidden'
}

function hideScrollbarX() {
    document.body.style.overflowX = 'hidden'
}

function updateEditorTheme(editor) {
    if (editor === null) {
        return
    }
    const theme = isDarkMode() ? 'ace/theme/solarized_dark' : 'ace/theme/solarized_light'
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
        denyButtonText: t('no')
    }).then((result) => {
        if (result.isConfirmed) {
            if (typeof onYes === 'function') {
                onYes()
            }
        } else {
            if (typeof onNo === 'function') {
                onNo()
            }
        }
    })
}

async function sha512(message) {
    // https://developer.mozilla.org/en-US/docs/Web/API/SubtleCrypto/digest
    // usage:
    // sha512('hello!').then((hex) => console.log(hex))

    const msgUint8 = new TextEncoder().encode(message) // encode as (utf-8) Uint8Array
    const hashBuffer = await crypto.subtle.digest('SHA-512', msgUint8) // hash the message
    const hashArray = Array.from(new Uint8Array(hashBuffer)) // convert buffer to byte array
    const hashHex = hashArray.map((b) => b.toString(16).padStart(2, '0')).join('') // convert bytes to hex string
    return hashHex
}

export default {
    sha512,
    scrollToPageTop,
    copyToClipboard,
    confirm,
    trim,
    getTranslator,
    updateEditorTheme,
    destroyEditor,
    showScrollbarY,
    hideScrollbarY,
    hideScrollbarX,
    call,
    init,
    reloadPage,
    reloadThemeMode
}
