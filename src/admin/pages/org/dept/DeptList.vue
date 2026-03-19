<template>
  <div class="dept-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>部门管理</span>
          <el-button type="primary" @click="handleAdd(null)">新增顶级部门</el-button>
        </div>
      </template>

      <el-table
        :data="deptList"
        row-key="id"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        border
        default-expand-all
      >
        <el-table-column prop="deptName" label="部门名称" min-width="200" />
        <el-table-column prop="leaderName" label="负责人" width="120" />
        <el-table-column prop="sort" label="排序" width="80" align="center" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260" align="center">
          <template #default="{ row }">
            <el-button size="small" @click="handleAdd(row)">新增子部门</el-button>
            <el-button size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-popconfirm title="确定要删除该部门吗?" @confirm="handleDelete(row)">
              <template #reference>
                <el-button size="small" type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑部门对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="上级部门" prop="parentId">
          <el-tree-select
            v-model="formData.parentId"
            :data="deptList"
            :props="{ label: 'deptName', value: 'id' }"
            :render-after-expand="false"
            placeholder="请选择上级部门"
            clearable
            check-strictly
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="部门名称" prop="deptName">
          <el-input v-model="formData.deptName" placeholder="请输入部门名称" />
        </el-form-item>
        <el-form-item label="负责人" prop="leaderId">
          <el-select
            v-model="formData.leaderId"
            filterable
            allow-create
            clearable
            placeholder="请输入或选择负责人"
            style="width: 100%;"
          >
            <el-option
              v-for="user in userList"
              :key="user.id"
              :label="user.realName"
              :value="user.id"
            >
              <span>{{ user.realName }}</span>
              <span style="float: right; color: #8492a6; font-size: 12px;">ID: {{ user.id }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model.number="formData.sort" :min="0" style="width: 100%;" placeholder="请输入排序" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import {
  getDeptTree,
  createDept,
  updateDept,
  deleteDept,
  type Department
} from '@/api/dept'
import { getUserPage, type SysUser } from '@/api/user'
import { lo } from 'element-plus/es/locale/index.mjs'

const deptList = ref<Department[]>([])
const userList = ref<SysUser[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const isEditMode = ref(false)
const formRef = ref<FormInstance>()

const formData = reactive<Partial<Department>>({
  id: undefined,
  parentId: 0,
  deptName: '',
  leaderId: undefined,
  sort: 0,
  status: 1
})

const rules: FormRules = {
  deptName: [
    { required: true, message: '请输入部门名称', trigger: 'blur' }
  ],
  parentId: [
    { required: true, message: '请选择上级部门', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

const loadDeptTree = async () => {
  try {
    deptList.value = await getDeptTree()
    console.log('loadDeptTree',await getDeptTree());
    
  } catch (error) {
    console.error('加载部门树失败:', error)
  }
}

const loadUserList = async () => {
  try {
    const res = await getUserPage({ pageNum: 1, pageSize: 1000 })
    userList.value = res.records || []
  } catch (error) {
    console.error('加载用户列表失败:', error)
  }
}

const handleAdd = (row: Department | null) => {
  isEditMode.value = false
  dialogTitle.value = '新增部门'
  Object.assign(formData, {
    id: undefined,
    parentId: row ? row.id : 0,
    deptName: '',
    leaderId: undefined,
    sort: 0,
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: Department) => {
  isEditMode.value = true
  dialogTitle.value = '编辑部门'
  Object.assign(formData, {
    id: row.id,
    parentId: row.parentId,
    deptName: row.deptName,
    leaderId: row.leaderId,
    sort: row.sort,
    status: row.status
  })
  dialogVisible.value = true
}

const handleSave = async () => {
  if (!formRef.value) return
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEditMode.value) {
          await updateDept(formData)
          ElMessage.success('更新部门成功')
        } else {
          await createDept(formData)
          ElMessage.success('新增部门成功')
        }
        dialogVisible.value = false
        loadDeptTree()
      } catch (error) {
        console.error('保存部门失败:', error)
      }
    }
  })
}

const handleDelete = async (row: Department) => {
  try {
    await deleteDept(row.id!)
    ElMessage.success('删除部门成功')
    loadDeptTree()
  } catch (error) {
    console.error('删除部门失败:', error)
  }
}

onMounted(() => {
  loadDeptTree()
  loadUserList()
})
</script>

<style scoped>
.dept-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
}
</style>
