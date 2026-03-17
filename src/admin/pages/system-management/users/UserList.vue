<template>
  <div class="user-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="keyword"
          placeholder="搜索用户名、姓名、手机号"
          clearable
          style="width: 250px; margin-right: 10px;"
          @clear="loadUserList"
          @keyup.enter="loadUserList"
        />
        <el-button type="primary" @click="loadUserList">查询</el-button>
        <el-button type="success" @click="handleAdd">新增用户</el-button>
      </div>

      <el-table :data="userList" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="用户ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="realName" label="真实姓名" width="100" />
        <el-table-column prop="email" label="邮箱" width="180" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column label="角色" width="180">
          <template #default="{ row }">
            <el-tag v-for="role in row.roles" :key="role" size="small" style="margin-right: 5px;">
              {{ role }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="320" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" @click="handleAssignRoles(row)">分配角色</el-button>
            <el-button size="small" type="warning" @click="handleResetPassword(row)">重置密码</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
        <template #empty>
          <el-empty description="暂无数据" />
        </template>
      </el-table>

      <div v-if="total > 0" style="display: flex; justify-content: flex-end; margin-top: 20px;">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @current-change="loadUserList"
          @size-change="loadUserList"
        />
      </div>
    </el-card>

    <!-- 新增/编辑用户对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :before-close="handleCloseDialog"
    >
      <el-form
        ref="userFormRef"
        :model="currentUser"
        :rules="userRules"
        label-width="100px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input v-model="currentUser.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!currentUser.id">
          <el-input
            v-model="currentUser.password"
            type="password"
            placeholder="请输入密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="currentUser.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="currentUser.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="currentUser.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="currentUser.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="关联员工ID">
          <el-input-number v-model="currentUser.employeeId" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button type="primary" @click="handleSave">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 分配角色对话框 -->
    <el-dialog
      v-model="roleDialogVisible"
      title="分配角色"
      width="500px"
      :before-close="handleCloseRoleDialog"
    >
      <el-checkbox-group v-model="selectedRoleIds">
        <el-checkbox
          v-for="role in allRoles"
          :key="role.id"
          :value="role.id"
          :label="role.roleName"
        />
      </el-checkbox-group>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleCloseRoleDialog">取消</el-button>
          <el-button type="primary" @click="handleSaveRoles">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 重置密码对话框 -->
    <el-dialog
      v-model="passwordDialogVisible"
      title="重置密码"
      width="400px"
      :before-close="handleClosePasswordDialog"
    >
      <el-form
        ref="passwordFormRef"
        :model="passwordForm"
        :rules="passwordRules"
        label-width="80px"
      >
        <el-form-item label="新密码" prop="newPassword">
          <el-input
            v-model="passwordForm.newPassword"
            type="password"
            placeholder="请输入新密码"
            show-password
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input
            v-model="passwordForm.confirmPassword"
            type="password"
            placeholder="请再次输入密码"
            show-password
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleClosePasswordDialog">取消</el-button>
          <el-button type="primary" @click="handleSavePassword">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getUserPage,
  createUser,
  updateUser,
  deleteUser,
  getUserRoles,
  assignUserRoles,
  resetPassword,
  type SysUser,
  type PageResult
} from '@/api/user'
import { getRoleList, type SysRole as RoleType } from '@/api/role'

const userList = ref<SysUser[]>([])
const keyword = ref('')
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const dialogVisible = ref(false)
const dialogTitle = ref('')
const currentUser = reactive<SysUser>({
  username: '',
  realName: '',
  email: '',
  phone: '',
  status: 1,
  employeeId: undefined,
  roleIds: []
})

const userFormRef = ref<FormInstance>()
const userRules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 32, message: '用户名长度3-32位', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  realName: [
    { required: true, message: '请输入真实姓名', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ]
}

const roleDialogVisible = ref(false)
const selectedRoleIds = ref<number[]>([])
const allRoles = ref<RoleType[]>([])
const currentUserId = ref<number>(0)

const passwordDialogVisible = ref(false)
const passwordFormRef = ref<FormInstance>()
const passwordForm = reactive({
  newPassword: '',
  confirmPassword: ''
})
const passwordRules: FormRules = {
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

const loadUserList = async () => {
  try {
    const res: PageResult<SysUser> = await getUserPage({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: keyword.value || undefined
    })
    userList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载用户列表失败:', error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增用户'
  Object.assign(currentUser, {
    username: '',
    password: '',
    realName: '',
    email: '',
    phone: '',
    status: 1,
    employeeId: undefined,
    roleIds: []
  })
  dialogVisible.value = true
}

const handleEdit = (row: SysUser) => {
  dialogTitle.value = '编辑用户'
  Object.assign(currentUser, {
    id: row.id,
    username: row.username,
    password: '',
    realName: row.realName,
    email: row.email,
    phone: row.phone,
    status: row.status,
    employeeId: row.employeeId,
    roleIds: row.roleIds
  })
  dialogVisible.value = true
}

const handleSave = async () => {
  if (!userFormRef.value) return
  await userFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (currentUser.id) {
          await updateUser(currentUser)
          ElMessage.success('更新用户成功')
        } else {
          await createUser(currentUser)
          ElMessage.success('新增用户成功')
        }
        dialogVisible.value = false
        loadUserList()
      } catch (error) {
        console.error('保存用户失败:', error)
      }
    }
  })
}

const handleCloseDialog = () => {
  dialogVisible.value = false
  userFormRef.value?.resetFields()
}

const handleDelete = (row: SysUser) => {
  ElMessageBox.confirm(`确定要删除用户 "${row.username}" 吗?`, '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteUser(row.id!)
      ElMessage.success('删除成功')
      loadUserList()
    } catch (error) {
      console.error('删除用户失败:', error)
    }
  }).catch(() => {})
}

const handleAssignRoles = async (row: SysUser) => {
  currentUserId.value = row.id!
  try {
    const roleIds = await getUserRoles(row.id!)
    selectedRoleIds.value = roleIds
    roleDialogVisible.value = true
  } catch (error) {
    console.error('获取用户角色失败:', error)
  }
}

const handleSaveRoles = async () => {
  try {
    await assignUserRoles(currentUserId.value, selectedRoleIds.value)
    ElMessage.success('分配角色成功')
    roleDialogVisible.value = false
    loadUserList()
  } catch (error) {
    console.error('分配角色失败:', error)
  }
}

const handleCloseRoleDialog = () => {
  roleDialogVisible.value = false
}

const handleResetPassword = (row: SysUser) => {
  currentUserId.value = row.id!
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  passwordFormRef.value?.resetFields()
  passwordDialogVisible.value = true
}

const handleSavePassword = async () => {
  if (!passwordFormRef.value) return
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await resetPassword(currentUserId.value, passwordForm.newPassword)
        ElMessage.success('重置密码成功')
        passwordDialogVisible.value = false
      } catch (error) {
        console.error('重置密码失败:', error)
      }
    }
  })
}

const handleClosePasswordDialog = () => {
  passwordDialogVisible.value = false
  passwordFormRef.value?.resetFields()
}

const loadAllRoles = async () => {
  try {
    allRoles.value = await getRoleList()
  } catch (error) {
    console.error('加载角色列表失败:', error)
  }
}

onMounted(() => {
  loadUserList()
  loadAllRoles()
})
</script>

<style scoped>
.user-list-container {
  padding: 20px;
}
.card-header {
  font-size: 18px;
  font-weight: bold;
}
.search-filter-section {
  display: flex;
  align-items: center;
}
</style>
