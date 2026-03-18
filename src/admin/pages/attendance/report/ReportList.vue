<template>
  <div class="report-container">
    <!-- 汇总统计卡片 -->
    <el-row :gutter="20" class="summary-row">
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-item">
            <div class="summary-icon total">
              <el-icon><User /></el-icon>
            </div>
            <div class="summary-content">
              <div class="summary-label">总人数</div>
              <div class="summary-value">{{ summary.totalEmployees || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-item">
            <div class="summary-icon success">
              <el-icon><Check /></el-icon>
            </div>
            <div class="summary-content">
              <div class="summary-label">出勤天数</div>
              <div class="summary-value">{{ summary.workDays || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-item">
            <div class="summary-icon warning">
              <el-icon><Warning /></el-icon>
            </div>
            <div class="summary-content">
              <div class="summary-label">迟到次数</div>
              <div class="summary-value">{{ summary.lateCount || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="summary-card">
          <div class="summary-item">
            <div class="summary-icon danger">
              <el-icon><CloseBold /></el-icon>
            </div>
            <div class="summary-content">
              <div class="summary-label">请假天数</div>
              <div class="summary-value">{{ summary.leaveDays || 0 }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="report-card">
      <template #header>
        <div class="card-header">
          <span class="title">月度考勤报表</span>
          <el-button type="primary" @click="handleExport">导出报表</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="月份">
          <el-date-picker
            v-model="currentMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 160px"
            @change="handleMonthChange"
          />
        </el-form-item>
        <el-form-item label="部门">
          <el-select v-model="queryParams.deptId" placeholder="全部部门" clearable style="width: 200px">
            <el-option
              v-for="dept in deptList"
              :key="dept.id"
              :label="dept.deptName"
              :value="dept.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="queryParams.keyword" placeholder="姓名/工号" clearable style="width: 200px" />
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
        <el-table-column prop="workDays" label="出勤天数" width="100" sortable />
        <el-table-column prop="lateCount" label="迟到次数" width="100" sortable>
          <template #default="{ row }">
            <span :class="{ 'text-warning': row.lateCount > 0 }">{{ row.lateCount || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="earlyCount" label="早退次数" width="100" sortable>
          <template #default="{ row }">
            <span :class="{ 'text-warning': row.earlyCount > 0 }">{{ row.earlyCount || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="absentDays" label="缺勤天数" width="100" sortable>
          <template #default="{ row }">
            <span :class="{ 'text-danger': row.absentDays > 0 }">{{ row.absentDays || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="annualLeaveUsed" label="年假(天)" width="100" sortable />
        <el-table-column prop="sickLeaveUsed" label="病假(天)" width="100" sortable />
        <el-table-column prop="personalLeaveUsed" label="事假(天)" width="100" sortable />
        <el-table-column prop="overtimeHours" label="加班(小时)" width="120" sortable />
        <el-table-column prop="compLeaveDays" label="调休(天)" width="100" sortable />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleDetail(row)">详情</el-button>
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

    <!-- 详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      :title="`${currentEmployee?.employeeName} - ${currentMonth} 考勤明细`"
      width="800px"
    >
      <el-table :data="dailyDetailData" stripe max-height="500">
        <el-table-column prop="attendanceDate" label="日期" width="120" />
        <el-table-column prop="weekDay" label="星期" width="80" />
        <el-table-column prop="checkInTime" label="上班时间" width="160" />
        <el-table-column prop="checkOutTime" label="下班时间" width="160" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
      </el-table>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { User, Check, Warning, CloseBold } from '@element-plus/icons-vue'
import {
  getMonthSummary,
  getMonthlyReportPage,
  getEmployeeDailyDetail,
  exportMonthlyReport,
  type MonthSummaryVO,
  type MonthlyReportVO,
  type DailyDetailVO,
  type ReportPageParams
} from '@/api/report'
import { getDeptTree, type Department } from '@/api/dept'

const loading = ref(false)
const tableData = ref<MonthlyReportVO[]>([])
const total = ref(0)
const summary = ref<MonthSummaryVO>({
  totalEmployees: 0,
  workDays: 0,
  lateCount: 0,
  earlyCount: 0,
  absentDays: 0,
  leaveDays: 0
})
const deptList = ref<Department[]>([])
const currentMonth = ref('')
const detailDialogVisible = ref(false)
const dailyDetailData = ref<DailyDetailVO[]>([])
const currentEmployee = ref<MonthlyReportVO | null>(null)

const queryParams = reactive<ReportPageParams>({
  pageNum: 1,
  pageSize: 20,
  month: '',
  deptId: undefined,
  keyword: ''
})

const flattenDeptTree = (tree: Department[]): Department[] => {
  const result: Department[] = []
  const traverse = (items: Department[]) => {
    items.forEach(item => {
      result.push(item)
      if (item.children && item.children.length > 0) {
        traverse(item.children)
      }
    })
  }
  traverse(tree)
  return result
}

const loadDeptList = async () => {
  try {
    const data = await getDeptTree()
    deptList.value = flattenDeptTree(data)
  } catch (error) {
    console.error('加载部门列表失败:', error)
  }
}

const loadSummary = async () => {
  try {
    const data = await getMonthSummary(currentMonth.value)
    summary.value = data
  } catch (error) {
    console.error('加载汇总统计失败:', error)
  }
}

const loadData = async () => {
  loading.value = true
  queryParams.month = currentMonth.value
  try {
    const data = await getMonthlyReportPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载考勤报表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
  loadSummary()
}

const handleReset = () => {
  queryParams.deptId = undefined
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadData()
  loadSummary()
}

const handleMonthChange = () => {
  handleQuery()
}

const handleExport = () => {
  try {
    exportMonthlyReport({
      month: queryParams.month,
      deptId: queryParams.deptId,
      keyword: queryParams.keyword
    })
    ElMessage.success('导出请求已发送')
  } catch (error) {
    console.error('导出失败:', error)
  }
}

const handleDetail = async (row: MonthlyReportVO) => {
  currentEmployee.value = row
  try {
    const data = await getEmployeeDailyDetail(row.employeeId!, currentMonth.value)
    dailyDetailData.value = data
    detailDialogVisible.value = true
  } catch (error) {
    console.error('加载考勤明细失败:', error)
  }
}

const getStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    0: '正常',
    1: '迟到',
    2: '早退',
    3: '缺勤',
    4: '请假',
    5: '加班'
  }
  return statusMap[status] || '-'
}

const getStatusTagType = (status: number) => {
  const typeMap: Record<number, string> = {
    0: 'success',
    1: 'warning',
    2: 'warning',
    3: 'danger',
    4: 'info',
    5: 'primary'
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
  const now = new Date()
  currentMonth.value = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
  loadDeptList()
  loadSummary()
  loadData()
})
</script>

<style scoped>
.report-container {
  padding: 20px;
}

.summary-row {
  margin-bottom: 20px;
}

.summary-card {
  cursor: pointer;
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 20px;
}

.summary-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
}

.summary-icon.total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.summary-icon.success {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.summary-icon.warning {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
  color: white;
}

.summary-icon.danger {
  background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);
  color: white;
}

.summary-content {
  flex: 1;
}

.summary-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.summary-value {
  font-size: 28px;
  font-weight: 700;
  color: #303133;
}

.report-card {
  margin-top: 20px;
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

.text-warning {
  color: #e6a23c;
  font-weight: 600;
}

.text-danger {
  color: #f56c6c;
  font-weight: 600;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
