<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <!-- <img src="@/assets/hero.png" alt="HRM Logo" class="logo"> -->
        <h1>HRMS 人力资源管理系统</h1>
      </div>
      <el-form :model="form" :rules="rules" ref="loginForm" @submit.native.prevent="handleLogin">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" :prefix-icon="User" size="large" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" :prefix-icon="Lock" show-password size="large" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="loading" style="width: 100%;" size="large">登录</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import type { FormInstance, FormRules } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'

const mockUsers = [
  { username: 'user', password: '123', role: 'user', token: 'user_token', avatar: 'https://cube.elemecdn.com/0/88/03b0dff359653ee253905facf436ff86.jpeg' },
  { username: 'admin', password: '123', role: 'admin', token: 'admin_token', avatar: 'https://cube.elemecdn.com/9/c2/f0ee84449c283d713a9653e751e45.jpeg' },
  { username: 'superadmin', password: '123', role: 'superadmin', token: 'superadmin_token', avatar: 'https://cube.elemecdn.com/3/7c/3ed6826170ee4e3fdeb8e64338717jpeg.jpeg' },
  { username: 'manager', password: '123', role: 'manager', token: 'manager_token', avatar: 'https://cube.elemecdn.com/6/94/4cb3355d2d8e5f227d0d3f010e688jpeg.jpeg' },
];

const router = useRouter()
const userStore = useUserStore()
const loginForm = ref<FormInstance>()
const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
})

const rules = reactive<FormRules>({
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
})

async function handleLogin() {
  if (!loginForm.value) return
  const valid = await loginForm.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    await new Promise(resolve => setTimeout(resolve, 1000))

    const user = mockUsers.find(
      u => u.username === form.username && u.password === form.password
    )

    if (user) {
      userStore.setUserInfo({ username: user.username, role: user.role, avatar: user.avatar })
      ElMessage.success('登录成功')
      if (user.role === 'admin') {
        router.push('/admin')
      } else if (user.role === 'superadmin') {
        router.push('/superadmin')
      } else {
        router.push('/user')
      }
    } else {
      ElMessage.error('登录失败，请检查用户名和密码')
    }
  } catch {
    ElMessage.error('登录失败，请检查用户名和密码')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-image: linear-gradient(to top, #a18cd1 0%, #fbc2eb 100%);
}

.login-card {
  width: 400px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 10px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.login-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 30px;
}

.logo {
  width: 80px;
  height: auto;
  margin-bottom: 15px;
}

h1 {
  font-size: 24px;
  color: #333;
  margin: 0;
}
</style>
