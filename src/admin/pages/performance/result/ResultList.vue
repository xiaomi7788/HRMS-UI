<template>
  <div class="result-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">绩效评估管理</span>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="绩效方案">
          <el-select v-model="queryParams.planId" placeholder="选择方案" clearable style="width: 200px">
            <el-option
              v-for="plan in planList"
              :key="plan.id"
              :label="plan.planName"
              :value="plan.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="员工">
          <el-input v-model="queryParams.keyword" placeholder="姓名/工号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="empCode" label="工号" width="120" />
        <el-table-column prop="empName" label="姓名" width="100" />
        <el-table-column prop="deptName" label="部门" width="150" />
        <el-table-column prop="kpiScore" label="KPI得分" width="100" sortable />
        <el-table-column prop="behaviorScore" label="行为评分" width="100" sortable />
        <el-table-column prop="evaluationScore" label="360评分" width="100" sortable />
        <el-table-column prop="totalScore" label="综合得分" width="100" sortable>
          <template #default="{ row }">
            <span class="score">{{ row.totalScore || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="grade" label="等级" width="100">
          <template #default="{ row }">
            <el-tag :type="getGradeTagType(row.grade)">{{ row.grade || '-' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" link type="primary" size="small" @click="handleEvaluate(row)">
              评估
            </el-button>
            <el-button link type="primary" size="small" @click="handleCalibrate(row)">
              校准
            </el-button>
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

    <!-- 评估对话框 -->
    <el-dialog
      v-model="evaluateDialogVisible"
      title="绩效评估"
      width="500px"
      @close="handleEvaluateDialogClose"
    >
      <el-form ref="evaluateFormRef" :model="evaluateForm" :rules="evaluateFormRules" label-width="120px">
        <el-form-item label="员工">
          <el-input :value="`${currentResult?.employeeNo} - ${currentResult?.employeeName}`" disabled />
        </el-form-item>
        <el-form-item label="KPI得分" prop="kpiScore">
          <el-input-number v-model="evaluateForm.kpiScore" :min="0" :max="100" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="行为评分" prop="behaviorScore">
          <el-input-number v-model="evaluateForm.behaviorScore" :min="0" :max="100" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="360评分" prop="evaluationScore">
          <el-input-number v-model="evaluateForm.evaluationScore" :min="0" :max="100" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="评估意见" prop="comment">
          <el-input v-model="evaluateForm.comment" type="textarea" :rows="4" placeholder="请输入评估意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="evaluateDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveEvaluate">确定</el-button>
      </template>
    </el-dialog>

    <!-- 校准对话框 -->
    <el-dialog
      v-model="calibrateDialogVisible"
      title="绩效校准"
      width="500px"
      @close="handleCalibrateDialogClose"
    >
      <el-form ref="calibrateFormRef" :model="calibrateForm" :rules="calibrateFormRules" label-width="120px">
        <el-form-item label="员工">
          <el-input :value="`${currentResult?.employeeNo} - ${currentResult?.employeeName}`" disabled />
        </el-form-item>
        <el-form-item label="当前得分">
          <el-input :value="currentResult?.totalScore" disabled />
        </el-form-item>
        <el-form-item label="当前等级">
          <el-tag :type="getGradeTagType(currentResult?.grade)">{{ currentResult?.grade || '-' }}</el-tag>
        </el-form-item>
        <el-form-item label="调整得分" prop="totalScore">
          <el-input-number v-model="calibrateForm.totalScore" :min="0" :max="100" :step="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="调整等级" prop="grade">
          <el-select v-model="calibrateForm.grade" placeholder="选择等级" style="width: 100%">
            <el-option label="A优秀" value="A" />
            <el-option label="B良好" value="B" />
            <el-option label="C合格" value="C" />
            <el-option label="D待改进" value="D" />
          </el-select>
        </el-form-item>
        <el-form-item label="校准意见">
          <el-input v-model="calibrateForm.comment" type="textarea" :rows="4" placeholder="请输入校准意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="calibrateDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveCalibrate">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useRoute } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getResultPage,
  submitResult,
  updateResult,
  calibrateResult,
  getPlanPage,
  type PerfResult,
  type PerfPlan,
  type ResultPageParams
} from '@/api/performance'

const route = useRoute()
const loading = ref(false)
const tableData = ref<PerfResult[]>([])
const total = ref(0)
const planList = ref<PerfPlan[]>([])
const evaluateDialogVisible = ref(false)
const calibrateDialogVisible = ref(false)
const evaluateFormRef = ref<FormInstance>()
const calibrateFormRef = ref<FormInstance>()
const currentResult = ref<PerfResult | null>(null)

const queryParams = reactive<ResultPageParams>({
  pageNum: 1,
  pageSize: 20,
  planId: undefined as any,
  keyword: ''
})

const evaluateForm = reactive<PerfResult>({
  planId: undefined,
  employeeId: undefined,
  kpiScore: 0,
  behaviorScore: 0,
  evaluationScore: 0,
  comment: ''
})

const calibrateForm = reactive({
  totalScore: 0,
  grade: '',
  comment: ''
})

const evaluateFormRules: FormRules = {
  kpiScore: [{ required: true, message: '请输入KPI得分', trigger: 'blur' }],
  behaviorScore: [{ required: true, message: '请输入行为评分', trigger: 'blur' }],
  evaluationScore: [{ required: true, message: '请输入360评分', trigger: 'blur' }]
}

const calibrateFormRules: FormRules = {
  totalScore: [{ required: true, message: '请输入调整得分', trigger: 'blur' }],
  grade: [{ required: true, message: '请选择调整等级', trigger: 'change' }]
}

const loadPlanList = async () => {
  try {
    const data = await getPlanPage({ pageNum: 1, pageSize: 100 })
    planList.value = data.records
    if (route.query.planId) {
      queryParams.planId = Number(route.query.planId)
    }
  } catch (error) {
    console.error('加载方案列表失败:', error)
  }
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getResultPage(queryParams)
    console.log('绩效评估结果数据:', data)
    console.log('数据记录:', data.records)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载评估结果列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.planId = undefined
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadData()
}

const handleEvaluate = (row: PerfResult) => {
  currentResult.value = row
  evaluateForm.planId = row.planId
  evaluateForm.employeeId = row.employeeId
  evaluateForm.kpiScore = row.kpiScore || 0
  evaluateForm.behaviorScore = row.behaviorScore || 0
  evaluateForm.evaluationScore = row.evaluationScore || 0
  evaluateForm.comment = row.comment || ''
  evaluateDialogVisible.value = true
}

const handleSaveEvaluate = async () => {
  if (!evaluateFormRef.value) return
  await evaluateFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (currentResult.value?.id) {
          await updateResult(evaluateForm)
        } else {
          await submitResult(evaluateForm)
        }
        ElMessage.success('保存成功')
        evaluateDialogVisible.value = false
        await loadData()
      } catch (error) {
        console.error('保存评估失败:', error)
      }
    }
  })
}

const handleCalibrate = (row: PerfResult) => {
  currentResult.value = row
  calibrateForm.totalScore = row.totalScore || 0
  calibrateForm.grade = row.grade || ''
  calibrateForm.comment = row.comment || ''
  calibrateDialogVisible.value = true
}

const handleSaveCalibrate = async () => {
  if (!calibrateFormRef.value) return
  await calibrateFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await calibrateResult(currentResult.value!.id!, calibrateForm)
        ElMessage.success('校准成功')
        calibrateDialogVisible.value = false
        await loadData()
      } catch (error) {
        console.error('校准失败:', error)
      }
    }
  })
}

const handleEvaluateDialogClose = () => {
  evaluateFormRef.value?.resetFields()
  currentResult.value = null
}

const handleCalibrateDialogClose = () => {
  calibrateFormRef.value?.resetFields()
  currentResult.value = null
}

const getStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    0: '待评估',
    1: '已评估',
    2: '已校准',
    3: '已确认'
  }
  return statusMap[status] || '-'
}

const getStatusTagType = (status: number) => {
  const typeMap: Record<number, string> = {
    0: 'warning',
    1: 'info',
    2: 'success',
    3: 'primary'
  }
  return typeMap[status] || ''
}

const getGradeTagType = (grade: string) => {
  const typeMap: Record<string, string> = {
    A: 'success',
    B: 'primary',
    C: 'info',
    D: 'warning'
  }
  return typeMap[grade] || ''
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadPlanList()
  loadData()
})
</script>

<style scoped>
.result-container {
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

.score {
  font-weight: 600;
  color: #409eff;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
