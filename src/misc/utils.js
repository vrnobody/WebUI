import configs from '../config.js'

const host = import.meta.env.DEV ? configs.devHostUrl : configs.releaseHostUrl

function post(callback, content) {
    let httpRequest = new XMLHttpRequest()
    httpRequest.open('POST', host, true)
    httpRequest.onreadystatechange = function () {
        if (httpRequest.readyState == 4 && httpRequest.status == 200) {
            let resp = httpRequest.responseText
            let msg = ""
            try {
                let j = JSON.parse(resp)
                let r = j['r']
                if (j['ok']) {
                    callback(r)
                    return
                } else {
                    msg = r
                }
            } catch (err) {
                msg = `parse response error!\n${err.toString()}`
                return
            }
            if (msg && msg.length > 0) {
                Swal.fire(msg)
            }
        }
    }

    httpRequest.onerror = function (err) {
        Swal.fire(`send request error:\n${err.toString()}`)
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

export default {
    call,
}