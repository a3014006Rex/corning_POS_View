import { createApp } from 'vue'
import { createPinia } from 'pinia'
import CoreuiVue from '@coreui/vue'
import '@coreui/coreui/dist/css/coreui.min.css'
import './styles/base.css'
import App from './App.vue'
import router from './router/index.js'

createApp(App).use(createPinia()).use(router).use(CoreuiVue).mount('#app')
