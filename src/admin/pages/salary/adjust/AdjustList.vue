<template>
  <div class="adjust-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">薪酬调整管理</span>
          <el-button type="primary" @click="handleAdd">发起调薪</el-button>
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
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="选择状态" clearable style="width: 120px">
            <el-option label="待审批" :value="0" />
            <el-option label="通过" :value="1" />
            <el-option label="拒绝" :value="2" />
            <el-option label="已撤回" :value="3" />
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
        <el-table-column prop="adjustType" label="调整类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getAdjustTypeColor(row.adjustType)">{{ getAdjustTypeText(row.adjustType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="beforeSalary" label="调整前" width="120">
          <template #default="{ row }">¥{{ row.beforeSalary }}</template>
        </el-table-column>
        <el-table-column prop="afterSalary" label="调整后" width="120">
          <template #default="{ row }">¥{{ row.afterSalary }}</template>
        </el-table-column>
        <el-table-column prop="adjustPercent" label="调整幅度" width="100">
          <template #default="{ row }">{{ row.adjustPercent }}%</template>
        </el-table-column>
        <el-table-column prop="effectiveDate" label="生效日期" width="120" />
        <el-table-column prop="applyUserName" label="申请人" width="100" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="applyReason" label="申请原因" min-width="150" show-overflow-tooltip />
        <el-table-column prop="createTime" label="申请时间" width="170" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" link type="primary" @click="handleApprove(row)">审批</el-button>
            <el-button v-if="row.status === 0" link type="warning" @click="handleWithdraw(row)">撤回</el-button>
            <el-button v-if="row.status === 3" link type="danger" @click="handleDelete(row)">删除</el-button>
            <el-button link type="info" @click="handleView(row)">查看</el-button>
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

    <!-- 发起调薪对话框 -->
    <el-dialog
      v-model="applyVisible"
      title="发起调薪申请"
      width="700px"
      @close="handleApplyClose"
    >
      <el-form ref="applyFormRef" :model="applyForm" :rules="applyRules" label-width="120px">
        <el-form-item label="员工" prop="employeeId">
          <el-select v-model="applyForm.employeeId" placeholder="选择员工" filterable style="width: 100%" @change="handleEmployeeChange">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="调整类型" prop="adjustType">
          <el-select v-model="applyForm.adjustType" placeholder="选择调整类型" style="width: 100%">
            <el-option label="上调" value="UP" />
            <el-option label="下调" value="DOWN" />
            <el-option label="晋升" value="PROMOTION" />
            <el-option label="特殊调整" value="SPECIAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="调整前工资" prop="beforeSalary">
          <el-input-number v-model="applyForm.beforeSalary" :min="0" :precision="2" :step="1000" style="width: 100%" :disabled="true" />
        </el-form-item>
        <el-form-item label="调整后工资" prop="afterSalary">
          <el-input-number v-model="applyForm.afterSalary" :min="0" :precision="2" :step="1000" style="width: 100%" @change="calculatePercent" />
        </el-form-item>
        <el-form-item label="调整幅度">
          <span style="font-size: 16px; font-weight: bold">{{ applyForm.adjustPercent }}%</span>
        </el-form-item>
        <el-form-item label="生效日期" prop="effectiveDate">
          <el-date-picker
            v-model="applyForm.effectiveDate"
            type="date"
            placeholder="选择生效日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="申请原因" prop="applyReason">
          <el-input v-model="applyForm.applyReason" type="textarea" :rows="4" placeholder="请输入调薪原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="applyVisible = false">取消</el-button>
        <el-button type="primary" @click="handleApplySubmit">提交申请</el-button>
      </template>
    </el-dialog>

    <!-- 审批对话框 -->
    <el-dialog
      v-model="approveVisible"
      title="审批调薪申请"
      width="600px"
      @close="handleApproveClose"
    >
      <el-descriptions v-if="currentAdjust" :column="2" border>
        <el-descriptions-item label="工号">{{ currentAdjust.employeeNo }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ currentAdjust.employeeName }}</el-descriptions-item>
        <el-descriptions-item label="调整类型">
          <el-tag :type="getAdjustTypeColor(currentAdjust.adjustType)">{{ getAdjustTypeText(currentAdjust.adjustType) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="调整前">¥{{ currentAdjust.beforeSalary }}</el-descriptions-item>
        <el-descriptions-item label="调整后">¥{{ currentAdjust.afterSalary }}</el-descriptions-item>
        <el-descriptions-item label="调整幅度">{{ currentAdjust.adjustPercent }}%</el-descriptions-item>
        <el-descriptions-item label="生效日期" :span="2">{{ currentAdjust.effectiveDate }}</el-descriptions-item>
        <el-descriptions-item label="申请原因" :span="2">{{ currentAdjust.applyReason }}</el-descriptions-item>
        <el-descriptions-item label="申请人">{{ currentAdjust.applyUserName }}</el-descriptions-item>
        <el-descriptions-item label="申请时间">{{ currentAdjust.createTime }}</el-descriptions-item>
      </el-descriptions>
      <el-form ref="approveFormRef" :model="approveForm" :rules="approveRules" label-width="120px" style="margin-top: 20px">
        <el-form-item label="审批结果" prop="passed">
          <el-radio-group v-model="approveForm.passed">
            <el-radio :value="true">通过</el-radio>
            <el-radio :value="false">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审批意见" prop="comment">
          <el-input v-model="approveForm.comment" type="textarea" :rows="3" placeholder="请输入审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveVisible = false">取消</el-button>
        <el-button type="primary" @click="handleApproveSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 查看详情对话框 -->
    <el-dialog v-model="viewVisible" title="调薪详情" width="800px">
      <el-descriptions v-if="currentAdjust" :column="2" border>
        <el-descriptions-item label="工号">{{ currentAdjust.employeeNo }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ currentAdjust.employeeName }}</el-descriptions-item>
        <el-descriptions-item label="调整类型">
          <el-tag :type="getAdjustTypeColor(currentAdjust.adjustType)">{{ getAdjustTypeText(currentAdjust.adjustType) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusType(currentAdjust.status)">{{ getStatusText(currentAdjust.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="调整前">¥{{ currentAdjust.beforeSalary }}</el-descriptions-item>
        <el-descriptions-item label="调整后">¥{{ currentAdjust.afterSalary }}</el-descriptions-item>
        <el-descriptions-item label="调整幅度">{{ currentAdjust.adjustPercent }}%</el-descriptions-item>
        <el-descriptions-item label="生效日期">{{ currentAdjust.effectiveDate }}</el-descriptions-item>
        <el-descriptions-item label="申请人">{{ currentAdjust.applyUserName }}</el-descriptions-item>
        <el-descriptions-item label="申请时间">{{ currentAdjust.createTime }}</el-descriptions-item>
        <el-descriptions-item label="审批人">{{ currentAdjust.approveUserName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="审批时间">{{ currentAdjust.approveTime || '-' }}</el-descriptions-item>
        <el-descriptions-item label="申请原因" :span="2">{{ currentAdjust.applyReason }}</el-descriptions-item>
        <el-descriptions-item label="审批意见" :span="2">{{ currentAdjust.approveComment || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="viewVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getAdjustPage,
  applyAdjust,
  approveAdjust,
  withdrawAdjust,
  deleteAdjust,
  type SalaryAdjust,
  type AdjustPageParams
} from '@/api/adjust'
import { getEmployeePage, type Employee } from '@/api/employee'
import { getConfigByEmployeeId } from '@/api/salary'

const loading = ref(false)
const tableData = ref<SalaryAdjust[]>([])
const total = ref(0)
const applyVisible = ref(false)
const approveVisible = ref(false)
const viewVisible = ref(false)
const applyFormRef = ref<FormInstance>()
const approveFormRef = ref<FormInstance>()
const employeeList = ref<Employee[]>([])
const currentAdjust = ref<SalaryAdjust | null>(null)

const queryParams = reactive<AdjustPageParams>({
  pageNum: 1,
  pageSize: 20,
  employeeId: undefined,
  status: undefined
})

const applyForm = reactive<SalaryAdjust>({
  employeeId: undefined,
  adjustType: '',
  beforeSalary: 0,
  afterSalary: undefined,
  adjustPercent: 0,
  effectiveDate: '',
  applyReason: ''
})

const approveForm = reactive({
  passed: true,
  comment: ''
})

const applyRules: FormRules = {
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  adjustType: [{ required: true, message: '请选择调整类型', trigger: 'change' }],
  afterSalary: [{ required: true, message: '请输入调整后工资', trigger: 'blur' }],
  effectiveDate: [{ required: true, message: '请选择生效日期', trigger: 'change' }],
  applyReason: [{ required: true, message: '请输入申请原因', trigger: 'blur' }]
}

const approveRules: FormRules = {
  comment: [{ required: true, message: '请输入审批意见', trigger: 'blur' }]
}

const getAdjustTypeColor = (type: string | undefined) => {
  const map: Record<string, string> = { 'UP': 'success', 'DOWN': 'warning', 'PROMOTION': 'primary', 'SPECIAL': 'info' }
  return map[type ?? ''] || 'info'
}

const getAdjustTypeText = (type: string | undefined) => {
  const map: Record<string, string> = { 'UP': '上调', 'DOWN': '下调', 'PROMOTION': '晋升', 'SPECIAL': '特殊' }
  return map[type ?? ''] || type
}

const getStatusType = (status: number | undefined) => {
  const map: Record<number, string> = { 0: 'warning', 1: 'success', 2: 'danger', 3: 'info' }
  return map[status ?? 0] || 'info'
}

const getStatusText = (status: number | undefined) => {
  const map: Record<number, string> = { 0: '待审批', 1: '通过', 2: '拒绝', 3: '已撤回' }
  return map[status ?? 0] || '未知'
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getAdjustPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载调薪申请列表失败:', error)
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
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  Object.assign(applyForm, {
    employeeId: undefined,
    adjustType: '',
    beforeSalary: 0,
    afterSalary: undefined,
    adjustPercent: 0,
    effectiveDate: '',
    applyReason: ''
  })
  applyVisible.value = true
}

const handleEmployeeChange = async (employeeId: number) => {
  try {
    const config = await getConfigByEmployeeId(employeeId)
    applyForm.beforeSalary = config.baseSalary || 0
    calculatePercent()
  } catch (error) {
    console.error('获取员工薪资失败:', error)
  }
}

const calculatePercent = () => {
  if (applyForm.beforeSalary && applyForm.afterSalary) {
    applyForm.adjustPercent = ((applyForm.afterSalary - applyForm.beforeSalary) / applyForm.beforeSalary * 100).toFixed(2)
  }
}

const handleApplySubmit = async () => {
  if (!applyFormRef.value) return
  await applyFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const { id, createTime, updateTime, deleted, ...submitData } = applyForm
        await applyAdjust(submitData)
        ElMessage.success('提交成功')
        applyVisible.value = false
        loadData()
      } catch (error) {
        console.error('提交失败:', error)
        ElMessage.error('提交失败，请稍后重试')
      }
    }
  })
}

const handleApplyClose = () => {
  applyFormRef.value?.resetFields()
}

const handleApprove = (row: SalaryAdjust) => {
  currentAdjust.value = row
  Object.assign(approveForm, { passed: true, comment: '' })
  approveVisible.value = true
}

const handleApproveSubmit = async () => {
  if (!approveFormRef.value) return
  await approveFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await approveAdjust(currentAdjust.value!.id!, approveForm.passed, approveForm.comment)
        ElMessage.success(approveForm.passed ? '审批通过' : '已拒绝')
        approveVisible.value = false
        loadData()
      } catch (error) {
        console.error('审批失败:', error)
        ElMessage.error('审批失败，请稍后重试')
      }
    }
  })
}

const handleApproveClose = () => {
  approveFormRef.value?.resetFields()
}

const handleWithdraw = (row: SalaryAdjust) => {
  ElMessageBox.confirm(`确认撤回 ${row.employeeName} 的调薪申请吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await withdrawAdjust(row.id!)
      ElMessage.success('撤回成功')
      loadData()
    } catch (error) {
      console.error('撤回失败:', error)
      ElMessage.error('撤回失败，请稍后重试')
    }
  })
}

const handleDelete = (row: SalaryAdjust) => {
  ElMessageBox.confirm(`确认删除该调薪申请吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteAdjust(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除失败:', error)
      ElMessage.error('删除失败，请稍后重试')
    }
  })
}

const handleView = (row: SalaryAdjust) => {
  currentAdjust.value = row
  viewVisible.value = true
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
.adjust-container {
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
