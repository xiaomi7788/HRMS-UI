<template>
  <div class="evaluation-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">绩效评估管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleAdd">新增评估</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="绩效方案">
          <el-select
            v-model="queryParams.planId"
            placeholder="全部方案"
            clearable
            filterable
            style="width: 200px"
            @change="handleQuery"
          >
            <el-option
              v-for="plan in planList"
              :key="plan.id"
              :label="plan.planName"
              :value="plan.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="员工">
          <el-select
            v-model="queryParams.employeeId"
            placeholder="全部员工"
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
        <el-form-item label="状态">
          <el-select
            v-model="queryParams.status"
            placeholder="全部状态"
            clearable
            style="width: 150px"
            @change="handleQuery"
          >
            <el-option label="待评估" :value="0" />
            <el-option label="已评估" :value="1" />
            <el-option label="已校准" :value="2" />
            <el-option label="已确认" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 数据表格 -->
      <el-table :data="tableData" stripe v-loading="loading" row-key="id">
        <el-table-column prop="empCode" label="工号" width="120" />
        <el-table-column prop="empName" label="姓名" width="100" />
        <el-table-column prop="deptName" label="部门" width="150" />
        <el-table-column prop="kpiScore" label="KPI得分" width="100" sortable>
          <template #default="{ row }">
            <span>{{ row.kpiScore || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="behaviorScore" label="行为评分" width="100" sortable>
          <template #default="{ row }">
            <span>{{ row.behaviorScore || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="evaluationScore" label="360评分" width="100" sortable>
          <template #default="{ row }">
            <span>{{ row.evaluationScore || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="totalScore" label="综合得分" width="100" sortable>
          <template #default="{ row }">
            <span class="score">{{ row.totalScore || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="grade" label="等级" width="100">
          <template #default="{ row }">
            <el-tag :type="getGradeTagType(row.grade)">
              {{ row.grade || '-' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="rating" label="评级" width="120">
          <template #default="{ row }">
            <span v-if="row.rating">{{ getRatingText(row.rating) }}</span>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="evaluatorName" label="评估人" width="120">
          <template #default="{ row }">
            <span v-if="row.evaluatorName">{{ row.evaluatorName }}</span>
            <span v-else class="text-gray">-</span>
          </template>
        </el-table-column>
        <el-table-column prop="evaluateTime" label="评估时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.evaluateTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="300" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" link type="primary" size="small" @click="handleEvaluate(row)">
              评估
            </el-button>
            <el-button v-else link type="info" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button link type="warning" size="small" @click="handleCalibrate(row)">
              校准
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              删除
            </el-button>
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

    <!-- 评估/编辑对话框 -->
    <el-dialog
      v-model="evaluateDialogVisible"
      :title="isEdit ? '编辑绩效评估' : '新增绩效评估'"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
        label-position="right"
      >
        <el-form-item label="绩效方案" prop="planId">
          <el-select
            v-model="formData.planId"
            placeholder="请选择绩效方案"
            clearable
            filterable
            style="width: 100%"
            @change="handlePlanChange"
          >
            <el-option
              v-for="plan in planList"
              :key="plan.id"
              :label="plan.planName"
              :value="plan.id"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="员工" prop="employeeId">
          <el-select
            v-model="formData.employeeId"
            placeholder="请选择员工"
            filterable
            remote
            :remote-method="searchEmployeeForForm"
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
        
        <el-form-item label="KPI得分" prop="kpiScore">
          <el-input-number
            v-model="formData.kpiScore"
            :min="0"
            :max="100"
            :step="0.1"
            :precision="1"
            style="width: 100%"
            placeholder="请输入KPI得分(0-100)"
          />
        </el-form-item>
        
        <el-form-item label="行为评分" prop="behaviorScore">
          <el-input-number
            v-model="formData.behaviorScore"
            :min="0"
            :max="100"
            :step="0.1"
            :precision="1"
            style="width: 100%"
            placeholder="请输入行为评分(0-100)"
          />
        </el-form-item>
        
        <el-form-item label="360评分" prop="evaluationScore">
          <el-input-number
            v-model="formData.evaluationScore"
            :min="0"
            :max="100"
            :step="0.1"
            :precision="1"
            style="width: 100%"
            placeholder="请输入360评分(0-100)"
          />
        </el-form-item>
        
        <el-form-item label="绩效等级" prop="grade">
          <el-select
            v-model="formData.grade"
            placeholder="请选择绩效等级"
            style="width: 100%"
          >
            <el-option label="A优秀" value="A" />
            <el-option label="B良好" value="B" />
            <el-option label="C合格" value="C" />
            <el-option label="D待改进" value="D" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="评级" prop="rating">
          <el-select
            v-model="formData.rating"
            placeholder="请选择评级"
            style="width: 100%"
          >
            <el-option label="优秀" value="EXCELLENT" />
            <el-option label="良好" value="GOOD" />
            <el-option label="待改进" value="NEEDS_IMPROVEMENT" />
            <el-option label="不满意" value="UNSATISFACTORY" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="评估意见" prop="comment">
          <el-input
            v-model="formData.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入评估意见"
            maxlength="1000"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="状态" prop="status">
          <el-select
            v-model="formData.status"
            placeholder="请选择状态"
            style="width: 100%"
          >
            <el-option label="待评估" :value="0" />
            <el-option label="已评估" :value="1" />
            <el-option label="已校准" :value="2" />
            <el-option label="已确认" :value="3" />
          </el-select>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="evaluateDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">
            {{ isEdit ? '更新' : '创建' }}
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 校准对话框 -->
    <el-dialog
      v-model="calibrateDialogVisible"
      title="绩效校准"
      width="500px"
      @close="handleCalibrateDialogClose"
    >
      <el-form
        ref="calibrateFormRef"
        :model="calibrateForm"
        :rules="calibrateFormRules"
        label-width="120px"
      >
        <el-form-item label="员工">
          <el-input :value="`${currentResult?.employeeNo} - ${currentResult?.employeeName}`" disabled />
        </el-form-item>
        
        <el-form-item label="当前得分">
          <el-input :value="currentResult?.totalScore" disabled />
        </el-form-item>
        
        <el-form-item label="当前等级">
          <el-tag :type="getGradeTagType(currentResult?.grade)">
            {{ currentResult?.grade || '-' }}
          </el-tag>
        </el-form-item>
        
        <el-form-item label="调整得分" prop="totalScore">
          <el-input-number
            v-model="calibrateForm.totalScore"
            :min="0"
            :max="100"
            :step="0.1"
            :precision="1"
            style="width: 100%"
            placeholder="请输入调整得分"
          />
        </el-form-item>
        
        <el-form-item label="调整等级" prop="grade">
          <el-select
            v-model="calibrateForm.grade"
            placeholder="请选择调整等级"
            style="width: 100%"
          >
            <el-option label="A优秀" value="A" />
            <el-option label="B良好" value="B" />
            <el-option label="C合格" value="C" />
            <el-option label="D待改进" value="D" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="校准意见" prop="comment">
          <el-input
            v-model="calibrateForm.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入校准意见"
            maxlength="1000"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="calibrateDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveCalibrate">确定</el-button>
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
  getResultPage,
  submitResult,
  updateResult,
  calibrateResult,
  deleteResult,
  type PerfResult,
  type ResultPageParams
} from '@/api/performance'
import { getPlanPage, type PerfPlan, type PlanPageParams } from '@/api/performance'
import { getEmployeePage, type Employee } from '@/api/employee'

const loading = ref(false)
const tableData = ref<PerfResult[]>([])
const total = ref(0)
const evaluateDialogVisible = ref(false)
const calibrateDialogVisible = ref(false)
const formRef = ref<FormInstance>()
const calibrateFormRef = ref<FormInstance>()
const isEdit = ref(false)
const currentResult = ref<PerfResult | null>(null)

// 员工相关
interface EmployeeOption {
  id?: number
  name: string
  employeeNo: string
}
const employeeList = ref<EmployeeOption[]>([])
const employeeLoading = ref(false)

// 绩效方案列表
const planList = ref<PerfPlan[]>([])

// 查询参数
const queryParams = reactive<ResultPageParams>({
  pageNum: 1,
  pageSize: 20,
  planId: undefined,
  employeeId: undefined,
  status: undefined
})

// 表单数据
const formData = reactive<PerfResult>({
  planId: undefined,
  employeeId: undefined,
  kpiScore: undefined,
  behaviorScore: undefined,
  evaluationScore: undefined,
  totalScore: undefined,
  grade: undefined,
  rating: undefined,
  comment: '',
  status: 0
})

// 校准表单
const calibrateForm = reactive({
  totalScore: 0,
  grade: '',
  comment: ''
})

// 表单验证规则
const formRules: FormRules = {
  planId: [{ required: true, message: '请选择绩效方案', trigger: 'change' }],
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  kpiScore: [{ required: true, message: '请输入KPI得分', trigger: 'blur' }],
  behaviorScore: [{ required: true, message: '请输入行为评分', trigger: 'blur' }],
  evaluationScore: [{ required: true, message: '请输入360评分', trigger: 'blur' }],
  grade: [{ required: true, message: '请选择绩效等级', trigger: 'change' }]
}

// 校准表单验证规则
const calibrateFormRules: FormRules = {
  totalScore: [{ required: true, message: '请输入调整得分', trigger: 'blur' }],
  grade: [{ required: true, message: '请选择调整等级', trigger: 'change' }]
}

// 加载数据
const loadData = async () => {
  loading.value = true
  try {
    const data = await getResultPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载绩效评估数据失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载绩效方案
const loadPlanList = async () => {
  try {
    const data = await getPlanPage({ pageNum: 1, pageSize: 100 })
    planList.value = data.records
  } catch (error) {
    console.error('加载绩效方案失败:', error)
  }
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

// 表单搜索员工
const searchEmployeeForForm = async (query?: string) => {
  await searchEmployee(query)
}

// 查询
const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

// 重置
const handleReset = () => {
  queryParams.planId = undefined
  queryParams.employeeId = undefined
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadData()
}

// 新增评估
const handleAdd = () => {
  isEdit.value = false
  currentResult.value = null
  
  // 重置表单
  Object.keys(formData).forEach(key => {
    ;(formData as any)[key] = undefined
  })
  formData.kpiScore = undefined
  formData.behaviorScore = undefined
  formData.evaluationScore = undefined
  formData.totalScore = undefined
  formData.grade = undefined
  formData.rating = undefined
  formData.comment = ''
  formData.status = 0
  
  evaluateDialogVisible.value = true
}

// 编辑评估
const handleEdit = (row: PerfResult) => {
  isEdit.value = true
  currentResult.value = row
  
  Object.assign(formData, row)
  evaluateDialogVisible.value = true
}

// 评估（针对待评估状态）
const handleEvaluate = (row: PerfResult) => {
  handleEdit(row)
}

// 保存评估
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // 计算综合得分（如果未提供）
        if (!formData.totalScore && formData.kpiScore && formData.behaviorScore && formData.evaluationScore) {
          // 获取方案权重
          const plan = planList.value.find(p => p.id === formData.planId)
          if (plan) {
            const kpiWeight = plan.kpiWeight || 60
            const behaviorWeight = plan.behaviorWeight || 20
            const evaluationWeight = plan.evaluationWeight || 20
            
            formData.totalScore = (
              (formData.kpiScore * kpiWeight + 
               formData.behaviorScore * behaviorWeight + 
               formData.evaluationScore * evaluationWeight) / 100
            )
          }
        }
        
        if (isEdit.value && currentResult.value?.id) {
          formData.id = currentResult.value.id
          await updateResult(formData)
          ElMessage.success('更新成功')
        } else {
          await submitResult(formData)
          ElMessage.success('创建成功')
        }
        evaluateDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('保存绩效评估失败:', error)
      }
    }
  })
}

// 方案变更处理
const handlePlanChange = (planId: number) => {
  // 可以根据选择的方案更新权重等信息
}

// 校准评估
const handleCalibrate = (row: PerfResult) => {
  currentResult.value = row
  calibrateForm.totalScore = row.totalScore || 0
  calibrateForm.grade = row.grade || ''
  calibrateForm.comment = row.comment || ''
  calibrateDialogVisible.value = true
}

// 保存校准
const handleSaveCalibrate = async () => {
  if (!calibrateFormRef.value) return
  await calibrateFormRef.value.validate(async (valid) => {
    if (valid && currentResult.value?.id) {
      try {
        await calibrateResult(currentResult.value.id, calibrateForm)
        ElMessage.success('校准成功')
        calibrateDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('校准失败:', error)
      }
    }
  })
}

// 删除评估
const handleDelete = (row: PerfResult) => {
  ElMessageBox.confirm('确认删除该绩效评估吗？删除后将无法恢复', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteResult(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除绩效评估失败:', error)
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
  currentResult.value = null
}

const handleCalibrateDialogClose = () => {
  calibrateFormRef.value?.resetFields()
  currentResult.value = null
}

// 格式化日期时间
const formatDateTime = (dateTime?: string) => {
  if (!dateTime) return '-'
  return dateTime.replace('T', ' ').substring(0, 16)
}

// 状态文本
const getStatusText = (status?: number) => {
  const statusMap: Record<number, string> = {
    0: '待评估',
    1: '已评估',
    2: '已校准',
    3: '已确认'
  }
  return statusMap[status || 0] || '-'
}

// 状态标签样式
const getStatusTagType = (status?: number) => {
  const typeMap: Record<number, string> = {
    0: 'warning',
    1: 'info',
    2: 'success',
    3: 'primary'
  }
  return typeMap[status || 0] || ''
}

// 等级标签样式
const getGradeTagType = (grade?: string) => {
  const typeMap: Record<string, string> = {
    'A': 'success',
    'B': 'primary',
    'C': 'info',
    'D': 'warning'
  }
  return typeMap[grade || ''] || ''
}

// 评级文本
const getRatingText = (rating?: string) => {
  const ratingMap: Record<string, string> = {
    'EXCELLENT': '优秀',
    'GOOD': '良好',
    'NEEDS_IMPROVEMENT': '待改进',
    'UNSATISFACTORY': '不满意'
  }
  return ratingMap[rating || ''] || rating || '-'
}

// 初始化加载
onMounted(() => {
  loadPlanList()
  loadData()
})
</script>

<style scoped>
.evaluation-container {
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

.header-actions {
  display: flex;
  gap: 10px;
}

.search-form {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.score {
  font-weight: 600;
  color: #409eff;
}

.text-gray {
  color: #c0c4cc;
}
</style>