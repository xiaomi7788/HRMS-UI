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
        <el-form-item prop="captcha">
          <div class="captcha-wrapper">
            <el-input v-model="form.captcha" placeholder="请输入验证码" :prefix-icon="CircleCheck" size="large" style="flex: 1;" />
            <img :src="captchaImage" alt="验证码" class="captcha-img" @click="fetchCaptcha" title="点击刷新验证码" />
          </div>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" native-type="submit" :loading="loading" style="width: 100%;" size="large">登录</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import type { FormInstance, FormRules } from 'element-plus'
import { User, Lock, CircleCheck } from '@element-plus/icons-vue'
import { getCaptcha, login } from '@/api/auth'
import { getRoleList } from '@/api/role'

const router = useRouter()
const userStore = useUserStore()
const loginForm = ref<FormInstance>()
const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  captcha: '',
  captchaKey: '',
})

const captchaImage = ref('')

const rules = reactive<FormRules>({
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  captcha: [{ required: true, message: '请输入验证码', trigger: 'blur' }],
})

async function fetchCaptcha() {
  try {
    const data = await getCaptcha()
    form.captchaKey = data.key
    captchaImage.value = data.image
  } catch (error) {
    console.error('获取验证码失败:', error)
  }
}

async function handleLogin() {
  if (!loginForm.value) return
  const valid = await loginForm.value.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    const result = await login({
      username: form.username,
      password: form.password,
      captcha: form.captcha,
      captchaKey: form.captchaKey,
    })

    console.log('登录返回结果:', result)
    console.log('result.roles:', result.roles)

    localStorage.setItem('hrm_token', result.token)
    userStore.setUserInfo({
      id: result.userId,
      username: result.username,
      nickname: result.realName,
      avatar: result.avatar,
      roles: result.roles,
      role: result.roles?.[0] || 'user',
      token: result.token,
      roleId: result.roleId, // 角色ID
    })

    console.log('userStore.roles:', userStore.roles)
    console.log('userStore.userInfo:', userStore.userInfo)

    ElMessage.success('登录成功')

    // 加载角色列表
    try {
      const roles = await getRoleList()
      userStore.setRoleList(roles)
    } catch (error) {
      console.error('加载角色列表失败:', error)
    }

    // 简化逻辑：只要角色编码不是 EMPLOYEE 就跳转到管理端，否则跳转到用户端
    const isEmployee = result.roles.some(role => role.toUpperCase() === 'EMPLOYEE')

    if (isEmployee) {
      router.push('/user')
    } else {
      router.push('/admin')
    }
  } catch (error) {
    console.error('登录失败:', error)
    fetchCaptcha()
    form.captcha = ''
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchCaptcha()
})
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

.captcha-wrapper {
  display: flex;
  gap: 10px;
  width: 100%;
}

.captcha-img {
  width: 120px;
  height: 40px;
  cursor: pointer;
  border-radius: 4px;
  border: 1px solid #dcdfe6;
}
</style>
