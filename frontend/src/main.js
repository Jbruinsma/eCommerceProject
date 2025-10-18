import { createApp } from 'vue'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate' // Import the plugin

import App from './App.vue'
import router from './router'

const app = createApp(App)

// Create a Pinia instance and tell it to use the plugin
const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

app.use(pinia) // Use the configured Pinia instance
app.use(router)

app.mount('#app')
