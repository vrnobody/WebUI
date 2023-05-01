import { createI18n } from '@yangss/vue3-i18n'
import zhCN from "./zhCN.js"
import enUS from "./enUS.js"

export default createI18n({
    locale: 'zhCN',
    fallbackLocale: 'enUS',
    messages: {
        'zhCN': zhCN,
        'enUS': enUS,
    }
})