import { createI18n } from '@yangss/vue3-i18n'
import zhCN from "./zhCN.js"
import enUS from "./enUS.js"
import cfg from "../config.js"

const lang = cfg.get("lang") || navigator.language

export default createI18n({
    locale: lang,
    fallbackLocale: 'en-US',
    messages: {
        'zh-CN': zhCN,
        'en-US': enUS,
    }
})