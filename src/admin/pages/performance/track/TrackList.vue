<template>
  <div class="track-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">绩效跟踪管理</span>
          <el-button type="primary" @click="handleAdd">新增跟踪记录</el-button>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="员工">
          <el-select
            v-model="queryParams.employeeId"
            placeholder="选择员工"
            clearable
            filterable
            remote
            :remote-method="searchEmployee"
            :loading="employeeLoading"
            style="width: 200px"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.name} (${emp.employeeNo})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="跟踪类型">
          <el-select
            v-model="queryParams.trackType"
            placeholder="选择类型"
            clearable
            style="width: 150px"
          >
            <el-option label="反馈" value="FEEDBACK" />
            <el-option label="进度更新" value="PROGRESS" />
            <el-option label="辅导" value="COACHING" />
            <el-option label="预警" value="WARNING" />
          </el-select>
        </el-form-item>
        <el-form-item label="绩效结果ID">
          <el-input-number
            v-model="queryParams.perfResultId"
            placeholder="绩效结果ID"
            :min="1"
            style="width: 150px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" stripe v-loading="loading" row-key="id">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="empName" label="员工" width="150">
          <template #default="{ row }">
            <span v-if="row.empName">{{ row.empName }}</span>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="trackType" label="跟踪类型" width="120">
          <template #default="{ row }">
            <el-tag :type="getTrackTypeTagType(row.trackType)" size="small">
              {{ getTrackTypeText(row.trackType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="content" label="跟踪内容" min-width="200" show-overflow-tooltip />
        <el-table-column prop="progressPercent" label="进度" width="120">
          <template #default="{ row }">
            <div v-if="row.trackType === 'PROGRESS' && row.progressPercent !== undefined" class="progress-cell">
              <el-progress
                :percentage="row.progressPercent"
                :status="getProgressStatus(row.progressPercent)"
                :stroke-width="10"
                :show-text="false"
                style="width: 80px; margin-right: 8px"
              />
              <span>{{ row.progressPercent }}%</span>
            </div>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="trackerName" label="操作人" width="120">
          <template #default="{ row }">
            <span v-if="row.trackerName">{{ row.trackerName }}</span>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="perfResultId" label="绩效结果ID" width="120">
          <template #default="{ row }">
            <span v-if="row.perfResultId">{{ row.perfResultId }}</span>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="trackTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.trackTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑跟踪记录' : '新增跟踪记录'"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
        label-position="right"
      >
        <el-form-item label="跟踪类型" prop="trackType">
          <el-select
            v-model="formData.trackType"
            placeholder="请选择跟踪类型"
            style="width: 100%"
            @change="handleTrackTypeChange"
          >
            <el-option label="反馈" value="FEEDBACK" />
            <el-option label="进度更新" value="PROGRESS" />
            <el-option label="辅导" value="COACHING" />
            <el-option label="预警" value="WARNING" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="员工" prop="employeeId">
          <el-select
            v-model="formData.employeeId"
            placeholder="请选择员工"
            filterable
            remote
            :remote-method="searchEmployee"
            :loading="employeeLoading"
            style="width: 100%"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.name} (${emp.employeeNo})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="绩效结果ID" prop="perfResultId">
          <el-input-number
            v-model="formData.perfResultId"
            placeholder="请输入绩效结果ID"
            :min="1"
            style="width: 100%"
          />
          <div class="form-tips">必填，关联到具体的绩效结果</div>
        </el-form-item>
        
        <el-form-item v-if="formData.trackType === 'PROGRESS'" label="进度百分比" prop="progressPercent">
          <el-input-number
            v-model="formData.progressPercent"
            :min="0"
            :max="100"
            :precision="0"
            style="width: 100%"
            placeholder="请输入进度百分比"
          />
        </el-form-item>
        
        <el-form-item label="跟踪内容" prop="content">
          <el-input
            v-model="formData.content"
            type="textarea"
            :rows="4"
            placeholder="请输入跟踪内容"
            maxlength="1000"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">
            {{ isEdit ? '更新' : '创建' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getTrackPage,
  createTrack,
  updateTrack,
  deleteTrack,
  type PerfTrack,
  type TrackPageParams
} from '@/api/track'
import { getEmployeePage, type Employee } from '@/api/employee'

const loading = ref(false)
const tableData = ref<PerfTrack[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const formRef = ref<FormInstance>()
const isEdit = ref(false)
const currentTrackId = ref<number>()

// 员工相关
interface EmployeeOption {
  id?: number
  name: string
  employeeNo: string
}
const employeeList = ref<EmployeeOption[]>([])
const employeeLoading = ref(false)

// 查询参数
const queryParams = reactive<TrackPageParams>({
  pageNum: 1,
  pageSize: 20,
  perfResultId: undefined,
  employeeId: undefined,
  trackType: undefined
})

// 表单数据
const formData = reactive<PerfTrack>({
  trackType: 'FEEDBACK',
  employeeId: undefined,
  perfResultId: undefined,
  content: '',
  progressPercent: undefined
})

// 表单验证规则
const formRules: FormRules = {
  trackType: [{ required: true, message: '请选择跟踪类型', trigger: 'change' }],
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  perfResultId: [{ required: true, message: '请输入绩效结果ID', trigger: 'blur' }],
  content: [{ required: true, message: '请输入跟踪内容', trigger: 'blur' }],
  progressPercent: [
    { 
      validator: (rule, value, callback) => {
        if (formData.trackType === 'PROGRESS' && (value === undefined || value === null)) {
          callback(new Error('进度更新必须填写进度百分比'))
        } else {
          callback()
        }
      },
      trigger: 'blur' 
    }
  ]
}

// 搜索员工
const searchEmployee = async (query?: string) => {
  if (!query || query.trim() === '') {
    employeeList.value = []
    return
  }
  
  employeeLoading.value = true
  try {
    const data = await getEmployeePage({
      pageNum: 1,
      pageSize: 20,
      keyword: query
    })
    employeeList.value = data.records.map((emp: Employee) => ({
      id: emp.id,
      name: emp.empName || '',
      employeeNo: emp.empCode || ''
    }))
  } catch (error) {
    console.error('搜索员工失败:', error)
    employeeList.value = []
  } finally {
    employeeLoading.value = false
  }
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const data = await getTrackPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载绩效跟踪记录失败:', error)
  } finally {
    loading.value = false
  }
}

// 查询
const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

// 重置
const handleReset = () => {
  queryParams.perfResultId = undefined
  queryParams.employeeId = undefined
  queryParams.trackType = undefined
  queryParams.pageNum = 1
  loadData()
}

// 新增记录
const handleAdd = () => {
  isEdit.value = false
  formData.id = undefined
  formData.trackType = 'FEEDBACK'
  formData.employeeId = undefined
  formData.perfResultId = undefined
  formData.content = ''
  formData.progressPercent = undefined
  dialogVisible.value = true
}

// 编辑记录
const handleEdit = (row: PerfTrack) => {
  isEdit.value = true
  currentTrackId.value = row.id
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 保存记录
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEdit.value && currentTrackId.value) {
          formData.id = currentTrackId.value
          await updateTrack(formData)
          ElMessage.success('更新成功')
        } else {
          await createTrack(formData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('保存绩效跟踪记录失败:', error)
      }
    }
  })
}

// 删除记录
const handleDelete = (row: PerfTrack) => {
  ElMessageBox.confirm('确认删除该绩效跟踪记录吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteTrack(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除绩效跟踪记录失败:', error)
    }
  })
}

// 分页处理
const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

// 对话框关闭处理
const handleDialogClose = () => {
  formRef.value?.resetFields()
  currentTrackId.value = undefined
}

// 跟踪类型变更处理
const handleTrackTypeChange = (type: string) => {
  // 如果不是进度更新类型，清空进度百分比
  if (type !== 'PROGRESS') {
    formData.progressPercent = undefined
  }
}

// 格式化日期时间
const formatDateTime = (dateTime?: string) => {
  if (!dateTime) return '-'
  return dateTime.replace('T', ' ').substring(0, 16)
}

// 跟踪类型标签样式
const getTrackTypeTagType = (type?: string) => {
  const typeMap: Record<string, string> = {
    'FEEDBACK': 'primary',
    'PROGRESS': 'success',
    'COACHING': 'warning',
    'WARNING': 'danger'
  }
  return typeMap[type || ''] || ''
}

// 跟踪类型文本
const getTrackTypeText = (type?: string) => {
  const typeMap: Record<string, string> = {
    'FEEDBACK': '反馈',
    'PROGRESS': '进度更新',
    'COACHING': '辅导',
    'WARNING': '预警'
  }
  return typeMap[type || ''] || type || '-'
}

// 进度状态
const getProgressStatus = (progress: number) => {
  if (progress >= 100) return 'success'
  if (progress >= 80) return 'warning'
  return 'exception'
}

// 初始化加载
onMounted(() => {
  loadData()
})
</script>

<style scoped>
.track-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header .title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.search-form {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.progress-cell {
  display: flex;
  align-items: center;
}

.text-gray {
  color: #c0c4cc;
}

.form-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}
</style>