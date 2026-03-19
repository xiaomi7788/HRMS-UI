<template>
  <div class="position-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>岗位管理</span>
          <el-button type="primary" @click="handleAdd">新增岗位</el-button>
        </div>
      </template>

      <div class="search-section">
        <el-tree-select
          v-model="searchForm.deptId"
          :data="deptList"
          :props="{ label: 'deptName', value: 'id' }"
          :render-after-expand="false"
          placeholder="请选择部门"
          clearable
          check-strictly
          style="width: 200px; margin-right: 10px;"
          @change="handleSearch"
        />
        <el-input
          v-model="searchForm.keyword"
          placeholder="请输入岗位名称或编码"
          clearable
          style="width: 250px; margin-right: 10px;"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-table
        :data="positionList"
        border
        stripe
        style="margin-top: 20px;"
      >
        <el-table-column prop="positionCode" label="岗位编码" width="120" />
        <el-table-column prop="positionName" label="岗位名称" width="150" />
        <el-table-column prop="deptName" label="所属部门" width="150">
          <template #default="{ row }">
            {{ getDeptName(row.deptId) }}
          </template>
        </el-table-column>
        <el-table-column prop="level" label="岗位级别" width="100" />
        <el-table-column prop="sort" label="排序" width="80" align="center" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="jobDesc" label="岗位职责" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-popconfirm title="确定要删除该岗位吗?" @confirm="handleDelete(row)">
              <template #reference>
                <el-button size="small" type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pageNum"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end; display: flex;"
        @current-change="loadPositionPage"
        @size-change="handleSizeChange"
      />
    </el-card>

    <!-- 新增/编辑岗位对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="120px"
      >
        <el-form-item label="岗位编码" prop="positionCode">
          <el-input v-model="formData.positionCode" placeholder="如：MGR001" />
        </el-form-item>
        <el-form-item label="岗位名称" prop="positionName">
          <el-input v-model="formData.positionName" placeholder="如：技术经理" />
        </el-form-item>
        <el-form-item label="所属部门" prop="deptId">
          <el-tree-select
            v-model="formData.deptId"
            :data="deptList"
            :props="{ label: 'deptName', value: 'id' }"
            :render-after-expand="false"
            placeholder="请选择部门"
            clearable
            check-strictly
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="岗位级别" prop="level">
          <el-input v-model="formData.level" placeholder="如：P6/M1" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model.number="formData.sort" :min="0" style="width: 100%;" placeholder="请输入排序" />
        </el-form-item>
        <el-form-item label="岗位职责" prop="jobDesc">
          <el-input v-model="formData.jobDesc" type="textarea" :rows="4" placeholder="请输入岗位职责描述" />
        </el-form-item>
        <el-form-item label="任职要求" prop="requirements">
          <el-input v-model="formData.requirements" type="textarea" :rows="4" placeholder="请输入任职要求" />
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
import { Search } from '@element-plus/icons-vue'
import {
  getPositionPage,
  createPosition,
  updatePosition,
  deletePosition,
  type Position,
  type PositionPageParams
} from '@/api/position'
import { getDeptTree, type Department } from '@/api/dept'

const positionList = ref<Position[]>([])
const deptList = ref<Department[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const isEditMode = ref(false)
const formRef = ref<FormInstance>()

const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const searchForm = reactive({
  deptId: undefined as number | undefined,
  keyword: ''
})

const formData = reactive<Partial<Position>>({
  id: undefined,
  positionCode: '',
  positionName: '',
  deptId: undefined,
  level: '',
  sort: 0,
  jobDesc: '',
  requirements: '',
  status: 1
})

const rules: FormRules = {
  positionCode: [
    { required: true, message: '请输入岗位编码', trigger: 'blur' }
  ],
  positionName: [
    { required: true, message: '请输入岗位名称', trigger: 'blur' }
  ],
  deptId: [
    { required: true, message: '请选择所属部门', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

const loadDeptTree = async () => {
  try {
    deptList.value = await getDeptTree()
  } catch (error) {
    console.error('加载部门树失败:', error)
  }
}

const loadPositionPage = async () => {
  try {
    const params: PositionPageParams = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      deptId: searchForm.deptId,
      keyword: searchForm.keyword || undefined
    }
    const res = await getPositionPage(params)
    positionList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载岗位列表失败:', error)
  }
}

const getDeptName = (deptId?: number) => {
  if (!deptId) return '-'
  const findDept = (list: Department[]): Department | null => {
    for (const dept of list) {
      if (dept.id === deptId) return dept
      if (dept.children) {
        const found = findDept(dept.children)
        if (found) return found
      }
    }
    return null
  }
  const dept = findDept(deptList.value)
  return dept?.deptName || '-'
}

const handleSearch = () => {
  pageNum.value = 1
  loadPositionPage()
}

const handleReset = () => {
  searchForm.deptId = undefined
  searchForm.keyword = ''
  pageNum.value = 1
  pageSize.value = 20
  loadPositionPage()
}

const handleSizeChange = () => {
  pageNum.value = 1
  loadPositionPage()
}

const handleAdd = () => {
  isEditMode.value = false
  dialogTitle.value = '新增岗位'
  Object.assign(formData, {
    id: undefined,
    positionCode: '',
    positionName: '',
    deptId: undefined,
    level: '',
    sort: 0,
    jobDesc: '',
    requirements: '',
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: Position) => {
  isEditMode.value = true
  dialogTitle.value = '编辑岗位'
  Object.assign(formData, {
    id: row.id,
    positionCode: row.positionCode,
    positionName: row.positionName,
    deptId: row.deptId,
    level: row.level,
    sort: row.sort,
    jobDesc: row.jobDesc,
    requirements: row.requirements,
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
          await updatePosition(formData)
          ElMessage.success('更新岗位成功')
        } else {
          await createPosition(formData)
          ElMessage.success('新增岗位成功')
        }
        dialogVisible.value = false
        loadPositionPage()
      } catch (error) {
        console.error('保存岗位失败:', error)
      }
    }
  })
}

const handleDelete = async (row: Position) => {
  try {
    await deletePosition(row.id!)
    ElMessage.success('删除岗位成功')
    loadPositionPage()
  } catch (error) {
    console.error('删除岗位失败:', error)
  }
}

onMounted(() => {
  loadDeptTree()
  loadPositionPage()
})
</script>

<style scoped>
.position-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
}

.search-section {
  display: flex;
  align-items: center;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 8px;
}
</style>
