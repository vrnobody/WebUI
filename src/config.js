const isDevMode = import.meta.env.DEV

const skey = isDevMode ? 'V2RayGConWebUiSettingsDev' : 'V2RayGConWebUiSettings'
const tkey = isDevMode ? 'V2RayGConWebUiThemeDev' : 'V2RayGConWebUiTheme'
const adminSessionKey = 'V2RayGConAdministratorToken'

let isSaving = false
let userSettings = {}

function getThemeMode() {
    return localStorage.getItem(tkey)
}

function saveAdminToken(token) {
    sessionStorage.setItem(adminSessionKey, token)
}

function getAdminToken() {
    return sessionStorage.getItem(adminSessionKey)
}

function saveThemeMode(mode) {
    const modes = ['system', 'light', 'dark']
    let index = modes.indexOf(mode)
    index = index < 0 ? 0 : index
    localStorage.setItem(tkey, modes[index])
}

function loadSettings() {
    try {
        const s = localStorage.getItem(skey)
        const j = JSON.parse(s)
        return j
    } catch (err) {
        console.log('load user settings error!', err.toString())
    }
    return null
}

function saveSettings(settings) {
    try {
        const s = JSON.stringify(settings)
        localStorage.setItem(skey, s)
        return true
    } catch (err) {
        console.log('save user settings error!', err.toString())
    }
    return false
}

function save() {
    return saveSettings(userSettings)
}

function reload() {
    const s = loadSettings()
    userSettings = s || {}
    return s != null
}

function init() {
    reload()
}

function saveLater(delay) {
    if (isSaving) {
        return
    }
    isSaving = true

    delay = delay < 1 ? 0 : delay

    setTimeout(() => {
        isSaving = false
        try {
            save()
        } catch {
            // pass
        }
    }, delay)
}

function set(key, value) {
    userSettings[key] = value
    saveLater(1000)
}

function get(key) {
    return userSettings[key]
}

init()

export default {

    webUiVersion: '1.0.2', // only display in About.vue
    supportedServerVersions: ['1.0.2.0'], // must match server.lua exactly
    supportedAppVersion: '2.0.6.0', // lowest compactible VGC version. e.g. 1.2.3.0

    isDevMode,
    devHostUrl: 'http://localhost:4000',
    releaseHostUrl: './',
    get,
    set,
    save,
    reload,
    getThemeMode,
    saveThemeMode,
    saveAdminToken,
    getAdminToken
}
