<template>
  <div class="record-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">月度薪酬记录</span>
          <div>
            <el-button @click="showCostTrend = true">成本趋势</el-button>
            <el-button @click="showCostSummary = true">成本汇总</el-button>
          </div>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="员工">
          <el-select v-model="queryParams.employeeId" placeholder="选择员工" filterable clearable style="width: 200px">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.employeeNo} - ${emp.employeeName}`"
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
        <el-table-column prop="employeeNo" label="工号" width="120" />
        <el-table-column prop="employeeName" label="姓名" width="100" />
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
        <el-table-column prop="deduction" label="其他扣款" width="100">
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

    <!-- 成本汇总对话框 -->
    <el-dialog v-model="showCostSummary" title="月度薪酬成本汇总" width="800px">
      <el-form :inline="true">
        <el-form-item label="月份">
          <el-date-picker
            v-model="summaryMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            @change="loadCostSummary"
          />
        </el-form-item>
      </el-form>
      <el-descriptions v-if="costSummary" :column="2" border>
        <el-descriptions-item label="统计月份">{{ costSummary.payMonth }}</el-descriptions-item>
        <el-descriptions-item label="员工人数">{{ costSummary.employeeCount }}</el-descriptions-item>
        <el-descriptions-item label="基本工资合计">¥{{ costSummary.totalBaseSalary }}</el-descriptions-item>
        <el-descriptions-item label="津贴合计">¥{{ costSummary.totalAllowance }}</el-descriptions-item>
        <el-descriptions-item label="奖金合计">¥{{ costSummary.totalBonus }}</el-descriptions-item>
        <el-descriptions-item label="加班工资合计">¥{{ costSummary.totalOvertimePay }}</el-descriptions-item>
        <el-descriptions-item label="社保个人合计">¥{{ costSummary.totalSocialInsurance }}</el-descriptions-item>
        <el-descriptions-item label="公积金个人合计">¥{{ costSummary.totalHousingFund }}</el-descriptions-item>
        <el-descriptions-item label="其他扣款合计">¥{{ costSummary.totalDeduction }}</el-descriptions-item>
        <el-descriptions-item label="个税合计">¥{{ costSummary.totalPersonalTax }}</el-descriptions-item>
        <el-descriptions-item label="应发合计">¥{{ costSummary.totalGrossPay }}</el-descriptions-item>
        <el-descriptions-item label="实发合计">¥{{ costSummary.totalActualPay }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="showCostSummary = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 成本趋势对话框 -->
    <el-dialog v-model="showCostTrend" title="薪酬成本趋势" width="1000px">
      <el-form :inline="true">
        <el-form-item label="起始月份">
          <el-date-picker
            v-model="trendStartMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          />
        </el-form-item>
        <el-form-item label="结束月份">
          <el-date-picker
            v-model="trendEndMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="loadCostTrend">查询</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="costTrend" stripe style="margin-top: 20px">
        <el-table-column prop="payMonth" label="月份" width="120" />
        <el-table-column prop="employeeCount" label="员工人数" width="100" />
        <el-table-column prop="totalBaseSalary" label="基本工资" width="120">
          <template #default="{ row }">¥{{ row.totalBaseSalary }}</template>
        </el-table-column>
        <el-table-column prop="totalAllowance" label="津贴" width="120">
          <template #default="{ row }">¥{{ row.totalAllowance }}</template>
        </el-table-column>
        <el-table-column prop="totalBonus" label="奖金" width="120">
          <template #default="{ row }">¥{{ row.totalBonus }}</template>
        </el-table-column>
        <el-table-column prop="totalOvertimePay" label="加班工资" width="120">
          <template #default="{ row }">¥{{ row.totalOvertimePay }}</template>
        </el-table-column>
        <el-table-column prop="totalGrossPay" label="应发合计" width="120">
          <template #default="{ row }">¥{{ row.totalGrossPay }}</template>
        </el-table-column>
        <el-table-column prop="totalActualPay" label="实发合计" width="120">
          <template #default="{ row }">¥{{ row.totalActualPay }}</template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="showCostTrend = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getRecordPage,
  getCostSummary,
  getCostTrend,
  type SalaryRecord,
  type RecordPageParams
} from '@/api/salary'
import { getEmployeePage, type Employee } from '@/api/employee'

const loading = ref(false)
const tableData = ref<SalaryRecord[]>([])
const total = ref(0)
const showCostSummary = ref(false)
const showCostTrend = ref(false)
const employeeList = ref<Employee[]>([])
const summaryMonth = ref('')
const costSummary = ref<any>(null)
const costTrend = ref<any[]>([])
const trendStartMonth = ref('')
const trendEndMonth = ref('')

const queryParams = reactive<RecordPageParams>({
  pageNum: 1,
  pageSize: 20,
  employeeId: undefined,
  payMonth: undefined,
  status: undefined
})

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

const loadCostSummary = async () => {
  if (!summaryMonth.value) {
    ElMessage.warning('请选择月份')
    return
  }
  try {
    costSummary.value = await getCostSummary(summaryMonth.value)
  } catch (error) {
    console.error('加载成本汇总失败:', error)
    ElMessage.error('加载成本汇总失败')
  }
}

const loadCostTrend = async () => {
  try {
    costTrend.value = await getCostTrend(trendStartMonth.value, trendEndMonth.value)
  } catch (error) {
    console.error('加载成本趋势失败:', error)
    ElMessage.error('加载成本趋势失败')
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
.record-container {
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
