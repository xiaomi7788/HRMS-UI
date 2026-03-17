<template>
  <div class="talent-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>人才梯队管理</span>
          <el-button type="primary" @click="handleAdd">新增继任计划</el-button>
        </div>
      </template>

      <div class="search-section">
        <el-input
          v-model="searchForm.positionName"
          placeholder="请输入目标岗位名称"
          clearable
          style="width: 200px; margin-right: 10px;"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-input
          v-model="searchForm.successorName"
          placeholder="请输入继任者姓名"
          clearable
          style="width: 200px; margin-right: 10px;"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        />
        <el-select
          v-model="searchForm.status"
          placeholder="请选择状态"
          clearable
          style="width: 150px; margin-right: 10px;"
          @change="handleSearch"
        >
          <el-option :value="0" label="规划中" />
          <el-option :value="1" label="培养中" />
          <el-option :value="2" label="已就绪" />
          <el-option :value="3" label="已终止" />
        </el-select>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-table
        :data="successionList"
        border
        stripe
        style="margin-top: 20px;"
      >
        <el-table-column prop="targetPositionName" label="目标岗位" width="150" />
        <el-table-column prop="currentHolderName" label="当前岗位持有者" width="120" />
        <el-table-column prop="successorName" label="继任者" width="120" />
        <el-table-column prop="successorCode" label="继任者工号" width="120" />
        <el-table-column prop="readiness" label="继任准备度" width="120" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.readiness === 'HIGH'" type="success" size="small">高</el-tag>
            <el-tag v-else-if="row.readiness === 'MEDIUM'" type="warning" size="small">中</el-tag>
            <el-tag v-else-if="row.readiness === 'LOW'" type="danger" size="small">低</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="expectedDate" label="预计继任日期" width="120" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="developmentPlan" label="发展计划" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="150" align="center" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-popconfirm title="确定要删除该继任计划吗?" @confirm="handleDelete(row)">
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
        @current-change="loadSuccessionPage"
        @size-change="handleSizeChange"
      />
    </el-card>

    <!-- 新增/编辑继任计划对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="140px"
      >
        <el-form-item label="目标岗位" prop="targetPositionId">
          <el-select
            v-model="formData.targetPositionId"
            filterable
            placeholder="请选择目标岗位"
            style="width: 100%;"
          >
            <el-option
              v-for="pos in positionList"
              :key="pos.id"
              :label="pos.positionName"
              :value="pos.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="继任者" prop="successorId">
          <el-select
            v-model="formData.successorId"
            filterable
            placeholder="请选择继任者"
            style="width: 100%;"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empName} (${emp.empCode})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="当前岗位持有者">
          <el-select
            v-model="formData.currentHolderId"
            filterable
            clearable
            placeholder="请选择当前岗位持有者"
            style="width: 100%;"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empName} (${emp.empCode})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="继任准备度" prop="readiness">
          <el-select v-model="formData.readiness" placeholder="请选择继任准备度" style="width: 100%;">
            <el-option value="HIGH" label="高" />
            <el-option value="MEDIUM" label="中" />
            <el-option value="LOW" label="低" />
          </el-select>
        </el-form-item>
        <el-form-item label="预计继任日期">
          <el-date-picker
            v-model="formData.expectedDate"
            type="date"
            placeholder="请选择预计继任日期"
            style="width: 100%;"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="formData.status" placeholder="请选择状态" style="width: 100%;">
            <el-option :value="0" label="规划中" />
            <el-option :value="1" label="培养中" />
            <el-option :value="2" label="已就绪" />
            <el-option :value="3" label="已终止" />
          </el-select>
        </el-form-item>
        <el-form-item label="发展计划">
          <el-input v-model="formData.developmentPlan" type="textarea" :rows="4" placeholder="请输入发展计划" />
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
  getSuccessionPage,
  createSuccessionPlan,
  updateSuccessionPlan,
  deleteSuccessionPlan,
  type SuccessionPlan,
  type SuccessionPageParams
} from '@/api/succession'
import { getEmployeePage, type Employee } from '@/api/employee'
import { getPositionList, type Position } from '@/api/position'

const successionList = ref<SuccessionPlan[]>([])
const employeeList = ref<Employee[]>([])
const positionList = ref<Position[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const isEditMode = ref(false)
const formRef = ref<FormInstance>()

const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const searchForm = reactive({
  positionName: '',
  successorName: '',
  status: undefined as number | undefined
})

const formData = reactive<Partial<SuccessionPlan>>({
  id: undefined,
  targetPositionId: undefined,
  successorId: undefined,
  currentHolderId: undefined,
  readiness: '',
  expectedDate: '',
  status: 0,
  developmentPlan: ''
})

const rules: FormRules = {
  targetPositionId: [
    { required: true, message: '请选择目标岗位', trigger: 'change' }
  ],
  successorId: [
    { required: true, message: '请选择继任者', trigger: 'change' }
  ],
  readiness: [
    { required: true, message: '请选择继任准备度', trigger: 'change' }
  ]
}

const loadEmployeeList = async () => {
  try {
    const res = await getEmployeePage({ pageNum: 1, pageSize: 1000, workStatus: 2 })
    employeeList.value = res.records || []
  } catch (error) {
    console.error('加载员工列表失败:', error)
  }
}

const loadPositionList = async () => {
  try {
    positionList.value = await getPositionList()
  } catch (error) {
    console.error('加载岗位列表失败:', error)
  }
}

const loadSuccessionPage = async () => {
  try {
    const params: SuccessionPageParams = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      positionName: searchForm.positionName || undefined,
      successorName: searchForm.successorName || undefined,
      status: searchForm.status
    }
    const res = await getSuccessionPage(params)
    successionList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载继任计划列表失败:', error)
  }
}

const getStatusType = (status?: number) => {
  switch (status) {
    case 0: return 'info'
    case 1: return 'primary'
    case 2: return 'success'
    case 3: return 'danger'
    default: return ''
  }
}

const getStatusText = (status?: number) => {
  switch (status) {
    case 0: return '规划中'
    case 1: return '培养中'
    case 2: return '已就绪'
    case 3: return '已终止'
    default: return ''
  }
}

const handleSearch = () => {
  pageNum.value = 1
  loadSuccessionPage()
}

const handleReset = () => {
  searchForm.positionName = ''
  searchForm.successorName = ''
  searchForm.status = undefined
  pageNum.value = 1
  pageSize.value = 20
  loadSuccessionPage()
}

const handleSizeChange = () => {
  pageNum.value = 1
  loadSuccessionPage()
}

const handleAdd = () => {
  isEditMode.value = false
  dialogTitle.value = '新增继任计划'
  Object.assign(formData, {
    id: undefined,
    targetPositionId: undefined,
    successorId: undefined,
    currentHolderId: undefined,
    readiness: '',
    expectedDate: '',
    status: 0,
    developmentPlan: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row: SuccessionPlan) => {
  isEditMode.value = true
  dialogTitle.value = '编辑继任计划'
  Object.assign(formData, {
    id: row.id,
    targetPositionId: row.targetPositionId,
    successorId: row.successorId,
    currentHolderId: row.currentHolderId,
    readiness: row.readiness,
    expectedDate: row.expectedDate,
    status: row.status,
    developmentPlan: row.developmentPlan
  })
  dialogVisible.value = true
}

const handleSave = async () => {
  if (!formRef.value) return
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEditMode.value) {
          await updateSuccessionPlan(formData)
          ElMessage.success('更新继任计划成功')
        } else {
          await createSuccessionPlan(formData)
          ElMessage.success('新增继任计划成功')
        }
        dialogVisible.value = false
        loadSuccessionPage()
      } catch (error) {
        console.error('保存继任计划失败:', error)
      }
    }
  })
}

const handleDelete = async (row: SuccessionPlan) => {
  try {
    await deleteSuccessionPlan(row.id!)
    ElMessage.success('删除继任计划成功')
    loadSuccessionPage()
  } catch (error) {
    console.error('删除继任计划失败:', error)
  }
}

onMounted(() => {
  loadEmployeeList()
  loadPositionList()
  loadSuccessionPage()
})
</script>

<style scoped>
.talent-container {
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
