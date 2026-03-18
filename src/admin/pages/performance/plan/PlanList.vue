<template>
  <div class="plan-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">绩效方案管理</span>
          <el-button type="primary" @click="handleAdd">新增方案</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="年度">
          <el-select v-model="queryParams.year" placeholder="全部年度" clearable style="width: 150px">
            <el-option label="2024" :value="2024" />
            <el-option label="2025" :value="2025" />
            <el-option label="2026" :value="2026" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="planName" label="方案名称" min-width="150" />
        <el-table-column prop="year" label="考核年度" width="100" />
        <el-table-column prop="cycle" label="考核周期" width="100">
          <template #default="{ row }">
            {{ row.cycle }}
          </template>
        </el-table-column>
        <el-table-column prop="period" label="期数" width="80" />
        <el-table-column prop="kpiWeight" label="KPI权重" width="100">
          <template #default="{ row }">
            {{ row.kpiWeight || 0 }}%
          </template>
        </el-table-column>
        <el-table-column prop="behaviorWeight" label="行为评分权重" width="120">
          <template #default="{ row }">
            {{ row.behaviorWeight || 0 }}%
          </template>
        </el-table-column>
        <el-table-column prop="evaluationWeight" label="360评分权重" width="120">
          <template #default="{ row }">
            {{ row.evaluationWeight || 0 }}%
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="primary" size="small" @click="handleResult(row)">评估</el-button>
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

    <!-- 新增/编辑方案对话框 -->
    <el-dialog
      v-model="planDialogVisible"
      :title="isEdit ? '编辑方案' : '新增方案'"
      width="600px"
      @close="handlePlanDialogClose"
    >
      <el-form ref="planFormRef" :model="planForm" :rules="planFormRules" label-width="120px">
        <el-form-item label="方案名称" prop="planName">
          <el-input v-model="planForm.planName" placeholder="请输入方案名称" />
        </el-form-item>
        <el-form-item label="考核年度" prop="year">
          <el-input-number v-model="planForm.year" :min="2020" :max="2030" style="width: 100%" />
        </el-form-item>
        <el-form-item label="考核周期" prop="cycle">
          <el-select v-model="planForm.cycle" placeholder="选择考核周期" style="width: 100%">
            <el-option label="月度" value="月度" />
            <el-option label="季度" value="季度" />
            <el-option label="年度" value="年度" />
          </el-select>
        </el-form-item>
        <el-form-item label="考核期数" prop="period">
          <el-input-number v-model="planForm.period" :min="1" :max="12" style="width: 100%" />
        </el-form-item>
        <el-form-item label="KPI权重(%)" prop="kpiWeight">
          <el-input-number v-model="planForm.kpiWeight" :min="0" :max="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="行为评分权重(%)" prop="behaviorWeight">
          <el-input-number v-model="planForm.behaviorWeight" :min="0" :max="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="360评分权重(%)" prop="evaluationWeight">
          <el-input-number v-model="planForm.evaluationWeight" :min="0" :max="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="planForm.status" placeholder="选择状态" style="width: 100%">
            <el-option label="草稿" :value="0" />
            <el-option label="进行中" :value="1" />
            <el-option label="已完成" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="planForm.description" type="textarea" :rows="4" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="planDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSavePlan">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getPlanPage,
  createPlan,
  updatePlan,
  deletePlan,
  type PerfPlan,
  type PlanPageParams
} from '@/api/performance'

const router = useRouter()
const loading = ref(false)
const tableData = ref<PerfPlan[]>([])
const total = ref(0)
const planDialogVisible = ref(false)
const planFormRef = ref<FormInstance>()
const isEdit = ref(false)

const queryParams = reactive<PlanPageParams>({
  pageNum: 1,
  pageSize: 20,
  year: undefined
})

const planForm = reactive<PerfPlan>({
  planName: '',
  cycle: '月度',
  year: new Date().getFullYear(),
  period: 1,
  kpiWeight: 60,
  behaviorWeight: 20,
  evaluationWeight: 20,
  status: 0,
  description: ''
})

const planFormRules: FormRules = {
  planName: [{ required: true, message: '请输入方案名称', trigger: 'blur' }],
  year: [{ required: true, message: '请输入考核年度', trigger: 'blur' }],
  cycle: [{ required: true, message: '请选择考核周期', trigger: 'change' }],
  period: [{ required: true, message: '请输入考核期数', trigger: 'blur' }]
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getPlanPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载绩效方案列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.year = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  isEdit.value = false
  planForm.id = undefined
  planForm.planName = ''
  planForm.cycle = '月度'
  planForm.year = new Date().getFullYear()
  planForm.period = 1
  planForm.kpiWeight = 60
  planForm.behaviorWeight = 20
  planForm.evaluationWeight = 20
  planForm.status = 0
  planForm.description = ''
  planDialogVisible.value = true
}

const handleEdit = (row: PerfPlan) => {
  isEdit.value = true
  planForm.id = row.id
  planForm.planName = row.planName
  planForm.cycle = row.cycle
  planForm.year = row.year
  planForm.period = row.period
  planForm.kpiWeight = row.kpiWeight
  planForm.behaviorWeight = row.behaviorWeight
  planForm.evaluationWeight = row.evaluationWeight
  planForm.status = row.status
  planForm.description = row.description
  planDialogVisible.value = true
}

const handleSavePlan = async () => {
  if (!planFormRef.value) return
  await planFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEdit.value) {
          await updatePlan(planForm)
          ElMessage.success('更新成功')
        } else {
          await createPlan(planForm)
          ElMessage.success('创建成功')
        }
        planDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('保存方案失败:', error)
      }
    }
  })
}

const handleDelete = (row: PerfPlan) => {
  ElMessageBox.confirm('确认删除该绩效方案吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deletePlan(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除方案失败:', error)
    }
  })
}

const handleResult = (row: PerfPlan) => {
  router.push({ name: 'ResultList', query: { planId: row.id } })
}

const handlePlanDialogClose = () => {
  planFormRef.value?.resetFields()
}

const getStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    0: '草稿',
    1: '进行中',
    2: '已完成'
  }
  return statusMap[status] || '-'
}

const getStatusTagType = (status: number) => {
  const typeMap: Record<number, string> = {
    0: 'info',
    1: 'warning',
    2: 'success'
  }
  return typeMap[status] || ''
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.plan-container {
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
