import configs from '../config.js'

const host = import.meta.env.DEV ? configs.devHostUrl : configs.releaseHostUrl

let t = null

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

function init(tt) {
    t = tt
}

export default {
    call,
    init,
}