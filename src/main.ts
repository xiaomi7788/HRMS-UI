import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import router from './router'
import App from './App.vue'
import './assets/styles/index.scss' // 引入全局 SCSS 样式

const app = createApp(App)

// 注册 Pinia
app.use(createPinia())

// 注册 Vue Router
app.use(router)

// 注册 Element Plus（中文语言包）
app.use(ElementPlus, {
  locale: zhCn,
  zIndex: 9999, // 设置 Element Plus 全局 z-index
})

app.mount('#app')
