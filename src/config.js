const isDevMode = import.meta.env.DEV

const skey = isDevMode ? 'V2RayGConWebUiSettingsDev' : 'V2RayGConWebUiSettings'
const tkey = isDevMode ? 'V2RayGConWebUiThemeDev' : 'V2RayGConWebUiTheme'

let isSaving = false
let userSettings = {}

function getThemeMode() {
    return localStorage.getItem(tkey)
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
    isDevMode,
    devHostUrl: 'http://localhost:4000',
    releaseHostUrl: '/',
    supportedServerVersions: ['0.0.2.3'],
    supportedAppVersion: '1.7.0.4',
    get,
    set,
    reload,
    getThemeMode,
    saveThemeMode
}
