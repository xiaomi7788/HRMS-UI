<template>
  <div class="calculate-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">薪酬核算</span>
          <div>
            <el-button type="primary" @click="handleBatchCalculate">批量核算</el-button>
            <el-button type="primary" @click="handleSingleCalculate">单个核算</el-button>
          </div>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="员工">
          <el-select v-model="queryParams.employeeId" placeholder="选择员工" filterable clearable style="width: 200px">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="薪酬月份">
          <el-date-picker
            v-model="queryParams.payMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 150px"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="选择状态" clearable style="width: 120px">
            <el-option label="草稿" :value="0" />
            <el-option label="已确认" :value="1" />
            <el-option label="已发放" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="empCode" label="工号" width="120" />
        <el-table-column prop="empName" label="姓名" width="100" />
        <el-table-column prop="payMonth" label="薪酬月份" width="100" />
        <el-table-column prop="baseSalary" label="基本工资" width="120">
          <template #default="{ row }">
            {{ row.baseSalary ? `¥${row.baseSalary}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="allowance" label="津贴合计" width="120">
          <template #default="{ row }">
            {{ row.allowance ? `¥${row.allowance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="bonus" label="奖金" width="120">
          <template #default="{ row }">
            {{ row.bonus ? `¥${row.bonus}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="overtimePay" label="加班工资" width="120">
          <template #default="{ row }">
            {{ row.overtimePay ? `¥${row.overtimePay}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="socialInsurance" label="社保" width="100">
          <template #default="{ row }">
            {{ row.socialInsurance ? `¥${row.socialInsurance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="housingFund" label="公积金" width="100">
          <template #default="{ row }">
            {{ row.housingFund ? `¥${row.housingFund}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="deduction" label="其他扣款" width="120">
          <template #default="{ row }">
            {{ row.deduction ? `¥${row.deduction}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="personalTax" label="个税" width="100">
          <template #default="{ row }">
            {{ row.personalTax ? `¥${row.personalTax}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="actualPay" label="实发工资" width="120">
          <template #default="{ row }">
            {{ row.actualPay ? `¥${row.actualPay}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" link type="primary" @click="handleConfirm(row)">确认发放</el-button>
            <el-button link type="primary" @click="handleViewDetail(row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
      />
    </el-card>

    <!-- 单个核算对话框 -->
    <el-dialog
      v-model="singleVisible"
      title="单个核算"
      width="600px"
      @close="handleSingleClose"
    >
      <el-form ref="singleFormRef" :model="singleForm" :rules="singleRules" label-width="120px">
        <el-form-item label="员工" prop="employeeId">
          <el-select v-model="singleForm.employeeId" placeholder="选择员工" filterable style="width: 100%">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="薪酬月份" prop="payMonth">
          <el-date-picker
            v-model="singleForm.payMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="奖金" prop="bonus">
          <el-input-number v-model="singleForm.bonus" :min="0" :precision="2" :step="1000" style="width: 100%" />
        </el-form-item>
        <el-form-item label="加班工资" prop="overtimePay">
          <el-input-number v-model="singleForm.overtimePay" :min="0" :precision="2" :step="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="其他扣款" prop="deduction">
          <el-input-number v-model="singleForm.deduction" :min="0" :precision="2" :step="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="singleForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="singleVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSingleSubmit">核算</el-button>
      </template>
    </el-dialog>

    <!-- 批量核算对话框 -->
    <el-dialog
      v-model="batchVisible"
      title="批量核算"
      width="600px"
      @close="handleBatchClose"
    >
      <el-form ref="batchFormRef" :model="batchForm" :rules="batchRules" label-width="120px">
        <el-form-item label="薪酬月份" prop="payMonth">
          <el-date-picker
            v-model="batchForm.payMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="全员奖金" prop="bonus">
          <el-input-number v-model="batchForm.bonus" :min="0" :precision="2" :step="1000" style="width: 100%" placeholder="可选，为空则不发放" />
        </el-form-item>
        <el-form-item label="全员加班工资" prop="overtimePay">
          <el-input-number v-model="batchForm.overtimePay" :min="0" :precision="2" :step="100" style="width: 100%" placeholder="可选，为空则不发放" />
        </el-form-item>
        <el-form-item label="全员其他扣款" prop="deduction">
          <el-input-number v-model="batchForm.deduction" :min="0" :precision="2" :step="100" style="width: 100%" placeholder="可选，为空则不扣除" />
        </el-form-item>
        <el-alert title="批量核算将计算所有员工的薪酬，已核算的员工将被跳过" type="warning" :closable="false" style="margin-bottom: 20px" />
      </el-form>
      <template #footer>
        <el-button @click="batchVisible = false">取消</el-button>
        <el-button type="primary" @click="handleBatchSubmit">批量核算</el-button>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="薪酬详情" width="800px">
      <el-descriptions v-if="currentRecord" :column="2" border>
        <el-descriptions-item label="工号">{{ currentRecord.employeeNo }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ currentRecord.employeeName }}</el-descriptions-item>
        <el-descriptions-item label="薪酬月份">{{ currentRecord.payMonth }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentRecord.status)">{{ getStatusText(currentRecord.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="基本工资">¥{{ currentRecord.baseSalary }}</el-descriptions-item>
        <el-descriptions-item label="津贴合计">¥{{ currentRecord.allowance }}</el-descriptions-item>
        <el-descriptions-item label="奖金">¥{{ currentRecord.bonus }}</el-descriptions-item>
        <el-descriptions-item label="加班工资">¥{{ currentRecord.overtimePay }}</el-descriptions-item>
        <el-descriptions-item label="社保个人">¥{{ currentRecord.socialInsurance }}</el-descriptions-item>
        <el-descriptions-item label="公积金个人">¥{{ currentRecord.housingFund }}</el-descriptions-item>
        <el-descriptions-item label="其他扣款">¥{{ currentRecord.deduction }}</el-descriptions-item>
        <el-descriptions-item label="个税">¥{{ currentRecord.personalTax }}</el-descriptions-item>
        <el-descriptions-item label="实发工资" :span="2">
          <span style="font-size: 18px; font-weight: bold; color: #f56c6c">¥{{ currentRecord.actualPay }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ currentRecord.remark }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getRecordPage,
  calculate,
  batchCalculate,
  confirmRecord,
  type SalaryRecord,
  type RecordPageParams,
  type CalculateParams,
  type BatchCalculateParams
} from '@/api/salary'
import { getEmployeePage, type Employee } from '@/api/employee'

const loading = ref(false)
const tableData = ref<SalaryRecord[]>([])
const total = ref(0)
const singleVisible = ref(false)
const batchVisible = ref(false)
const detailVisible = ref(false)
const singleFormRef = ref<FormInstance>()
const batchFormRef = ref<FormInstance>()
const employeeList = ref<Employee[]>([])
const currentRecord = ref<SalaryRecord | null>(null)

const queryParams = reactive<RecordPageParams>({
  pageNum: 1,
  pageSize: 20,
  employeeId: undefined,
  payMonth: undefined,
  status: undefined
})

const singleForm = reactive<CalculateParams>({
  employeeId: undefined as any,
  payMonth: '',
  bonus: undefined,
  overtimePay: undefined,
  deduction: undefined,
  remark: ''
})

const batchForm = reactive<BatchCalculateParams>({
  payMonth: '',
  bonus: undefined,
  overtimePay: undefined,
  deduction: undefined
})

const singleRules: FormRules = {
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  payMonth: [{ required: true, message: '请选择薪酬月份', trigger: 'change' }]
}

const batchRules: FormRules = {
  payMonth: [{ required: true, message: '请选择薪酬月份', trigger: 'change' }]
}

const getStatusType = (status: number | undefined) => {
  const map: Record<number, string> = { 0: 'info', 1: 'warning', 2: 'success' }
  return map[status ?? 0] || 'info'
}

const getStatusText = (status: number | undefined) => {
  const map: Record<number, string> = { 0: '草稿', 1: '已确认', 2: '已发放' }
  return map[status ?? 0] || '未知'
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getRecordPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载薪酬记录列表失败:', error)
  } finally {
    loading.value = false
  }
}

const loadEmployeeList = async () => {
  try {
    const data = await getEmployeePage({ pageNum: 1, pageSize: 10000 })
    employeeList.value = data.records || []
  } catch (error) {
    console.error('加载员工列表失败:', error)
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.employeeId = undefined
  queryParams.payMonth = undefined
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleSingleCalculate = () => {
  Object.assign(singleForm, {
    employeeId: undefined,
    payMonth: '',
    bonus: undefined,
    overtimePay: undefined,
    deduction: undefined,
    remark: ''
  })
  singleVisible.value = true
}

const handleSingleClose = () => {
  singleFormRef.value?.resetFields()
}

const handleSingleSubmit = async () => {
  if (!singleFormRef.value) return
  await singleFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await calculate(singleForm)
        ElMessage.success('核算成功')
        singleVisible.value = false
        loadData()
      } catch (error) {
        console.error('核算失败:', error)
        ElMessage.error('核算失败，请稍后重试')
      }
    }
  })
}

const handleBatchCalculate = () => {
  Object.assign(batchForm, {
    payMonth: '',
    bonus: undefined,
    overtimePay: undefined,
    deduction: undefined
  })
  batchVisible.value = true
}

const handleBatchClose = () => {
  batchFormRef.value?.resetFields()
}

const handleBatchSubmit = async () => {
  if (!batchFormRef.value) return
  await batchFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const result = await batchCalculate(batchForm)
        ElMessage.success(`批量核算完成，共核算 ${result.calculated} 人`)
        batchVisible.value = false
        loadData()
      } catch (error) {
        console.error('批量核算失败:', error)
        ElMessage.error('批量核算失败，请稍后重试')
      }
    }
  })
}

const handleConfirm = (row: SalaryRecord) => {
  ElMessageBox.confirm(`确认发放 ${row.employeeName} ${row.payMonth} 的薪酬吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await confirmRecord(row.id!)
      ElMessage.success('确认发放成功')
      loadData()
    } catch (error) {
      console.error('确认发放失败:', error)
      ElMessage.error('确认发放失败，请稍后重试')
    }
  })
}

const handleViewDetail = (row: SalaryRecord) => {
  currentRecord.value = row
  detailVisible.value = true
}

const handleCurrentChange = () => {
  loadData()
}

const handleSizeChange = () => {
  queryParams.pageNum = 1
  loadData()
}

onMounted(() => {
  loadEmployeeList()
  loadData()
})
</script>

<style scoped>
.calculate-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.search-form {
  margin-bottom: 20px;
}

.el-pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
