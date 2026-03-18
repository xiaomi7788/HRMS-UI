<template>
  <div class="quota-container">
    <el-card shadow="never">
      <template #header>
        <span class="title">假期额度管理</span>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="员工">
          <el-input v-model="queryParams.keyword" placeholder="姓名/工号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="年度">
          <el-select v-model="queryParams.year" placeholder="选择年度" clearable style="width: 150px">
            <el-option label="2023" :value="2023" />
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
        <el-table-column prop="employeeNo" label="工号" width="120" />
        <el-table-column prop="employeeName" label="姓名" width="100" />
        <el-table-column prop="deptName" label="部门" width="150" />
        <el-table-column prop="year" label="年度" width="80" />
        <el-table-column label="年假" width="180">
          <template #default="{ row }">
            <div>总额: {{ row.annualLeaveTotal || 0 }}</div>
            <div>已用: {{ row.annualLeaveUsed || 0 }}</div>
            <div class="remaining">余额: {{ row.annualLeaveRemaining || 0 }}</div>
          </template>
        </el-table-column>
        <el-table-column label="病假" width="180">
          <template #default="{ row }">
            <div>总额: {{ row.sickLeaveTotal || 0 }}</div>
            <div>已用: {{ row.sickLeaveUsed || 0 }}</div>
            <div class="remaining">余额: {{ row.sickLeaveRemaining || 0 }}</div>
          </template>
        </el-table-column>
        <el-table-column label="事假" width="180">
          <template #default="{ row }">
            <div>总额: {{ row.personalLeaveTotal || 0 }}</div>
            <div>已用: {{ row.personalLeaveUsed || 0 }}</div>
            <div class="remaining">余额: {{ row.personalLeaveRemaining || 0 }}</div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleAdjust(row)">调整</el-button>
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

    <!-- 调整额度对话框 -->
    <el-dialog
      v-model="adjustDialogVisible"
      title="调整假期额度"
      width="500px"
      @close="handleAdjustDialogClose"
    >
      <el-form ref="adjustFormRef" :model="adjustForm" :rules="adjustFormRules" label-width="120px">
        <el-form-item label="员工">
          <el-input :value="`${currentQuota?.employeeNo} - ${currentQuota?.employeeName}`" disabled />
        </el-form-item>
        <el-form-item label="假期类型" prop="type">
          <el-select v-model="adjustForm.type" placeholder="选择假期类型" style="width: 100%" @change="handleTypeChange">
            <el-option label="年假" value="ANNUAL" />
            <el-option label="病假" value="SICK" />
            <el-option label="事假" value="PERSONAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="当前余额">
          <el-input :value="currentRemaining + ' 天'" disabled />
        </el-form-item>
        <el-form-item label="调整余额" prop="adjustAmount">
          <el-input-number
            v-model="adjustForm.adjustAmount"
            :min="0"
            :max="9999"
            :step="0.5"
            style="width: 100%"
          />
          <span style="margin-left: 10px; color: #909399">天</span>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="adjustForm.remark" type="textarea" :rows="3" placeholder="请输入调整备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="adjustDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveAdjust">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getQuotaPage,
  adjustQuota,
  type HolidayQuotaVO,
  type QuotaPageParams
} from '@/api/quota'

const loading = ref(false)
const tableData = ref<HolidayQuotaVO[]>([])
const total = ref(0)
const adjustDialogVisible = ref(false)
const adjustFormRef = ref<FormInstance>()
const currentQuota = ref<HolidayQuotaVO | null>(null)

const queryParams = reactive<QuotaPageParams>({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  year: new Date().getFullYear()
})

const adjustForm = reactive({
  type: 'ANNUAL',
  adjustAmount: 0,
  remark: ''
})

const currentRemaining = ref<number>(0)

const adjustFormRules: FormRules = {
  type: [{ required: true, message: '请选择假期类型', trigger: 'change' }],
  adjustAmount: [{ required: true, message: '请输入调整金额', trigger: 'blur' }]
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getQuotaPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载假期额度列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.keyword = ''
  queryParams.year = new Date().getFullYear()
  queryParams.pageNum = 1
  loadData()
}

const handleTypeChange = () => {
  const quota = currentQuota.value
  const type = adjustForm.type
  if (type === 'ANNUAL') {
    currentRemaining.value = quota?.annualLeaveRemaining || 0
  } else if (type === 'SICK') {
    currentRemaining.value = quota?.sickLeaveRemaining || 0
  } else if (type === 'PERSONAL') {
    currentRemaining.value = quota?.personalLeaveRemaining || 0
  }
}

const handleAdjust = (row: HolidayQuotaVO) => {
  currentQuota.value = row
  adjustForm.type = 'ANNUAL'
  currentRemaining.value = row.annualLeaveRemaining || 0
  adjustForm.adjustAmount = 0
  adjustForm.remark = ''
  adjustDialogVisible.value = true
}

const handleSaveAdjust = async () => {
  if (!adjustFormRef.value) return
  await adjustFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await adjustQuota(currentQuota.value!.id!, adjustForm)
        ElMessage.success('调整成功')
        adjustDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('调整额度失败:', error)
      }
    }
  })
}

const handleAdjustDialogClose = () => {
  adjustFormRef.value?.resetFields()
  currentQuota.value = null
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
.quota-container {
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

.remaining {
  color: #67c23a;
  font-weight: 600;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
