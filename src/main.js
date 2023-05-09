import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import i18n from './i18n/config.js'

import './assets/main.css'
import "@hennge/vue3-pagination/dist/vue3-pagination.css";

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(i18n)

app.mount('#app')