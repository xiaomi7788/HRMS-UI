<template>
  <div class="self-profile">
    <el-card class="profile-card">
      <template #header>
        <div class="card-header">
          <span>个人档案</span>
          <el-button type="primary" @click="handleEdit" v-if="!editing">
            <el-icon><Edit /></el-icon>
            编辑
          </el-button>
          <template v-else>
            <el-button @click="handleCancel">取消</el-button>
            <el-button type="primary" @click="handleSave">保存</el-button>
          </template>
        </div>
      </template>

      <el-descriptions v-if="profile" :column="2" border>
        <el-descriptions-item label="姓名">{{ profile.realName }}</el-descriptions-item>
        <el-descriptions-item label="工号">{{ profile.id }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ profile.phone }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ profile.email }}</el-descriptions-item>
        <el-descriptions-item label="部门">{{ profile.departmentName }}</el-descriptions-item>
        <el-descriptions-item label="岗位">{{ profile.positionName }}</el-descriptions-item>
        <el-descriptions-item label="入职日期">{{ formatDate(profile.entryDate) }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="profile.status === 1 ? 'success' : 'danger'">
            {{ profile.status === 1 ? '在职' : '离职' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 编辑表单 -->
    <el-dialog v-model="editing" title="编辑个人档案" width="600px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="手机号">
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="handleCancel">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Edit } from '@element-plus/icons-vue'
import { getSelfProfile, type SelfProfile } from '@/api/self'

const profile = ref<SelfProfile>()
const editing = ref(false)
const form = ref({
  phone: '',
  email: ''
})

function formatDate(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN')
}

async function loadProfile() {
  try {
    profile.value = await getSelfProfile()
    form.value.phone = profile.value.phone
    form.value.email = profile.value.email
  } catch (error) {
    ElMessage.error('获取个人档案失败')
  }
}

function handleEdit() {
  editing.value = true
}

function handleCancel() {
  editing.value = false
  form.value.phone = profile.value?.phone || ''
  form.value.email = profile.value?.email || ''
}

function handleSave() {
  ElMessage.success('保存成功')
  editing.value = false
  loadProfile()
}

onMounted(() => {
  loadProfile()
})
</script>

<style scoped>
.self-profile {
  padding: 20px;
}

.profile-card {
  max-width: 900px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
