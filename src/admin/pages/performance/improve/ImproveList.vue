<template>
  <div class="improve-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">绩效改进计划</span>
          <el-button type="primary" @click="handleAdd">新建计划</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="改进周期">
          <el-select v-model="queryParams.period" placeholder="选择周期" clearable style="width: 150px">
            <el-option label="2026-Q1" value="2026-Q1" />
            <el-option label="2026-Q2" value="2026-Q2" />
            <el-option label="2026-Q3" value="2026-Q3" />
            <el-option label="2026-Q4" value="2026-Q4" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="选择状态" clearable style="width: 120px">
            <el-option label="制定中" :value="0" />
            <el-option label="进行中" :value="1" />
            <el-option label="已完成" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="employeeNo" label="工号" width="120" />
        <el-table-column prop="employeeName" label="姓名" width="100" />
        <el-table-column prop="planName" label="计划名称" width="180" />
        <el-table-column prop="period" label="改进周期" width="100" />
        <el-table-column prop="startDate" label="开始日期" width="110" />
        <el-table-column prop="endDate" label="结束日期" width="110" />
        <el-table-column prop="problemDesc" label="问题描述" min-width="150" show-overflow-tooltip />
        <el-table-column prop="improveGoal" label="改进目标" min-width="150" show-overflow-tooltip />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="结果" width="90">
          <template #default="{ row }">
            <el-tag v-if="row.result" :type="getResultTagType(row.result)">
              {{ getResultText(row.result) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleView(row)">详情</el-button>
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button v-if="row.status === 1" link type="success" size="small" @click="handleComplete(row)">
              完成
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

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

    <!-- 新建/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑改进计划' : '新建改进计划'"
      width="700px"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="120px">
        <el-form-item label="员工" prop="employeeId">
          <el-select v-model="formData.employeeId" placeholder="选择员工" filterable style="width: 100%">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="计划名称" prop="planName">
          <el-input v-model="formData.planName" placeholder="请输入计划名称" />
        </el-form-item>
        <el-form-item label="改进周期" prop="period">
          <el-select v-model="formData.period" placeholder="选择周期" style="width: 100%">
            <el-option label="2026-Q1" value="2026-Q1" />
            <el-option label="2026-Q2" value="2026-Q2" />
            <el-option label="2026-Q3" value="2026-Q3" />
            <el-option label="2026-Q4" value="2026-Q4" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker v-model="formData.startDate" type="date" placeholder="选择日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="结束日期" prop="endDate">
          <el-date-picker v-model="formData.endDate" type="date" placeholder="选择日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="问题描述" prop="problemDesc">
          <el-input v-model="formData.problemDesc" type="textarea" :rows="3" placeholder="请描述绩效问题" />
        </el-form-item>
        <el-form-item label="改进目标" prop="improveGoal">
          <el-input v-model="formData.improveGoal" type="textarea" :rows="3" placeholder="请输入改进目标" />
        </el-form-item>
        <el-form-item label="支持措施" prop="supportMeasures">
          <el-input v-model="formData.supportMeasures" type="textarea" :rows="3" placeholder="请输入支持措施（培训/辅导/资源）" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="0">制定中</el-radio>
            <el-radio :value="1">进行中</el-radio>
            <el-radio :value="2">已完成</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="改进计划详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="工号">{{ currentImprove?.employeeNo }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ currentImprove?.employeeName }}</el-descriptions-item>
        <el-descriptions-item label="计划名称" :span="2">{{ currentImprove?.planName }}</el-descriptions-item>
        <el-descriptions-item label="改进周期">{{ currentImprove?.period }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusTagType(currentImprove?.status)">
            {{ getStatusText(currentImprove?.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="开始日期">{{ currentImprove?.startDate }}</el-descriptions-item>
        <el-descriptions-item label="结束日期">{{ currentImprove?.endDate }}</el-descriptions-item>
        <el-descriptions-item label="问题描述" :span="2">{{ currentImprove?.problemDesc }}</el-descriptions-item>
        <el-descriptions-item label="改进目标" :span="2">{{ currentImprove?.improveGoal }}</el-descriptions-item>
        <el-descriptions-item label="支持措施" :span="2">{{ currentImprove?.supportMeasures }}</el-descriptions-item>
        <el-descriptions-item label="结果" :span="2">
          <el-tag v-if="currentImprove?.result" :type="getResultTagType(currentImprove?.result)">
            {{ getResultText(currentImprove?.result) }}
          </el-tag>
          <span v-else>-</span>
        </el-descriptions-item>
        <el-descriptions-item label="结果说明" :span="2">{{ currentImprove?.resultComment || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 完成对话框 -->
    <el-dialog v-model="completeVisible" title="完成改进计划" width="600px">
      <el-form ref="completeFormRef" :model="completeForm" :rules="completeRules" label-width="100px">
        <el-form-item label="结果" prop="result">
          <el-radio-group v-model="completeForm.result">
            <el-radio value="PASS">通过</el-radio>
            <el-radio value="FAIL">未通过</el-radio>
            <el-radio value="IN_PROGRESS">进行中</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="结果说明" prop="resultComment">
          <el-input v-model="completeForm.resultComment" type="textarea" :rows="4" placeholder="请输入结果说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="completeVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveComplete">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getImprovePage,
  createImprove,
  updateImprove,
  completeImprove,
  deleteImprove,
  type PerfImprovePlan,
  type ImprovePageParams
} from '@/api/improve'
import { getEmployeePage, type Employee, type EmployeePageParams } from '@/api/employee'

const loading = ref(false)
const tableData = ref<PerfImprovePlan[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const detailVisible = ref(false)
const completeVisible = ref(false)
const formRef = ref<FormInstance>()
const completeFormRef = ref<FormInstance>()
const currentImprove = ref<PerfImprovePlan | null>(null)
const employeeList = ref<Employee[]>([])
const isEdit = ref(false)

const queryParams = reactive<ImprovePageParams>({
  pageNum: 1,
  pageSize: 20,
  period: undefined,
  status: undefined
})

const formData = reactive<PerfImprovePlan>({
  employeeId: undefined,
  planName: '',
  period: '',
  startDate: '',
  endDate: '',
  problemDesc: '',
  improveGoal: '',
  supportMeasures: '',
  status: 1
})

const completeForm = reactive({
  result: 'PASS',
  resultComment: ''
})

const formRules: FormRules = {
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  planName: [{ required: true, message: '请输入计划名称', trigger: 'blur' }],
  period: [{ required: true, message: '请选择改进周期', trigger: 'change' }],
  startDate: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择结束日期', trigger: 'change' }],
  problemDesc: [{ required: true, message: '请描述绩效问题', trigger: 'blur' }],
  improveGoal: [{ required: true, message: '请输入改进目标', trigger: 'blur' }]
}

const completeRules: FormRules = {
  result: [{ required: true, message: '请选择结果', trigger: 'change' }],
  resultComment: [{ required: true, message: '请输入结果说明', trigger: 'blur' }]
}

const loadEmployeeList = async () => {
  try {
    const data = await getEmployeePage({ pageNum: 1, pageSize: 10000 })
    console.log('员工列表数据:', data)
    employeeList.value = data.records || []
  } catch (error) {
    console.error('加载员工列表失败:', error)
  }
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getImprovePage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载改进计划列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.period = undefined
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, {
    employeeId: undefined,
    planName: '',
    period: '',
    startDate: '',
    endDate: '',
    problemDesc: '',
    improveGoal: '',
    supportMeasures: '',
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: PerfImprovePlan) => {
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

const handleView = (row: PerfImprovePlan) => {
  currentImprove.value = row
  detailVisible.value = true
}

const handleComplete = (row: PerfImprovePlan) => {
  currentImprove.value = row
  completeForm.result = 'PASS'
  completeForm.resultComment = ''
  completeVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // 转换日期格式
        const submitData = {
          ...formData,
          startDate: formData.startDate ? new Date(formData.startDate).toISOString().split('T')[0] : undefined,
          endDate: formData.endDate ? new Date(formData.endDate).toISOString().split('T')[0] : undefined
        }
        
        if (isEdit.value) {
          await updateImprove(submitData)
          ElMessage.success('更新成功')
        } else {
          await createImprove(submitData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('保存失败:', error)
      }
    }
  })
}

const handleSaveComplete = async () => {
  if (!completeFormRef.value) return
  await completeFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await completeImprove(currentImprove.value!.id!, completeForm)
        ElMessage.success('完成成功')
        completeVisible.value = false
        loadData()
      } catch (error) {
        console.error('完成失败:', error)
      }
    }
  })
}

const handleDelete = (row: PerfImprovePlan) => {
  ElMessageBox.confirm('确定要删除该改进计划吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteImprove(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除失败:', error)
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

const getStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    0: '制定中',
    1: '进行中',
    2: '已完成'
  }
  return statusMap[status] || '-'
}

const getStatusTagType = (status: number) => {
  const typeMap: Record<number, string> = {
    0: 'warning',
    1: 'primary',
    2: 'success'
  }
  return typeMap[status] || ''
}

const getResultText = (result: string) => {
  const resultMap: Record<string, string> = {
    PASS: '通过',
    FAIL: '未通过',
    IN_PROGRESS: '进行中'
  }
  return resultMap[result] || '-'
}

const getResultTagType = (result: string) => {
  const typeMap: Record<string, string> = {
    PASS: 'success',
    FAIL: 'danger',
    IN_PROGRESS: 'warning'
  }
  return typeMap[result] || ''
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadEmployeeList()
  loadData()
})
</script>

<style scoped>
.improve-container {
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
</style>
