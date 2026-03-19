<template>
  <div class="config-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">薪资档案管理</span>
          <el-button type="primary" @click="handleAdd">新建档案</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="关键词">
          <el-input v-model="queryParams.keyword" placeholder="员工姓名/工号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部" clearable style="width: 120px">
            <el-option label="启用" :value="1" />
            <el-option label="停用" :value="0" />
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
        <el-table-column prop="baseSalary" label="基本工资" width="120">
          <template #default="{ row }">
            {{ row.baseSalary ? `¥${row.baseSalary}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="positionAllowance" label="岗位津贴" width="120">
          <template #default="{ row }">
            {{ row.positionAllowance ? `¥${row.positionAllowance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="transportAllowance" label="交通补贴" width="120">
          <template #default="{ row }">
            {{ row.transportAllowance ? `¥${row.transportAllowance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="mealAllowance" label="餐饮补贴" width="120">
          <template #default="{ row }">
            {{ row.mealAllowance ? `¥${row.mealAllowance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="otherAllowance" label="其他津贴" width="120">
          <template #default="{ row }">
            {{ row.otherAllowance ? `¥${row.otherAllowance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="socialInsuranceRate" label="社保比例" width="100">
          <template #default="{ row }">
            {{ row.socialInsuranceRate ? `${row.socialInsuranceRate}%` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="housingFundRate" label="公积金比例" width="100">
          <template #default="{ row }">
            {{ row.housingFundRate ? `${row.housingFundRate}%` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="effectiveMonth" label="生效月份" width="100" />
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
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

    <!-- 新建/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑薪资档案' : '新建薪资档案'"
      width="700px"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="120px">
        <el-form-item label="员工" prop="employeeId">
          <el-select v-model="formData.employeeId" placeholder="选择员工" filterable style="width: 100%" :disabled="isEdit">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="基本工资" prop="baseSalary">
          <el-input-number v-model="formData.baseSalary" :min="0" :precision="2" :step="1000" style="width: 100%" />
        </el-form-item>
        <el-form-item label="岗位津贴" prop="positionAllowance">
          <el-input-number v-model="formData.positionAllowance" :min="0" :precision="2" :step="500" style="width: 100%" />
        </el-form-item>
        <el-form-item label="交通补贴" prop="transportAllowance">
          <el-input-number v-model="formData.transportAllowance" :min="0" :precision="2" :step="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="餐饮补贴" prop="mealAllowance">
          <el-input-number v-model="formData.mealAllowance" :min="0" :precision="2" :step="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="其他津贴" prop="otherAllowance">
          <el-input-number v-model="formData.otherAllowance" :min="0" :precision="2" :step="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="社保个人比例" prop="socialInsuranceRate">
          <el-input-number v-model="formData.socialInsuranceRate" :min="0" :max="100" :precision="2" :step="1" style="width: 100%" />
          <span style="margin-left: 8px">%</span>
        </el-form-item>
        <el-form-item label="公积金个人比例" prop="housingFundRate">
          <el-input-number v-model="formData.housingFundRate" :min="0" :max="100" :precision="2" :step="1" style="width: 100%" />
          <span style="margin-left: 8px">%</span>
        </el-form-item>
        <el-form-item label="生效月份" prop="effectiveMonth">
          <el-date-picker
            v-model="formData.effectiveMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getConfigPage,
  createConfig,
  updateConfig,
  type SalaryConfig,
  type ConfigPageParams
} from '@/api/salary'
import { getEmployeePage, type Employee } from '@/api/employee'

const loading = ref(false)
const tableData = ref<SalaryConfig[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const formRef = ref<FormInstance>()
const isEdit = ref(false)
const employeeList = ref<Employee[]>([])

const queryParams = reactive<ConfigPageParams>({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  status: undefined as undefined | number
})

const formData = reactive<SalaryConfig>({
  employeeId: undefined,
  baseSalary: undefined,
  positionAllowance: undefined,
  transportAllowance: undefined,
  mealAllowance: undefined,
  otherAllowance: undefined,
  socialInsuranceRate: undefined,
  housingFundRate: undefined,
  effectiveMonth: '',
  status: 1
})

const formRules: FormRules = {
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  baseSalary: [{ required: true, message: '请输入基本工资', trigger: 'blur' }],
  socialInsuranceRate: [{ required: true, message: '请输入社保比例', trigger: 'blur' }],
  housingFundRate: [{ required: true, message: '请输入公积金比例', trigger: 'blur' }],
  effectiveMonth: [{ required: true, message: '请选择生效月份', trigger: 'change' }]
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getConfigPage(queryParams)
    tableData.value = data.records
    console.log(await getConfigPage(queryParams));
    
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载薪资档案列表失败:', error)
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
  queryParams.keyword = undefined
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, {
    employeeId: undefined,
    baseSalary: undefined,
    positionAllowance: undefined,
    transportAllowance: undefined,
    mealAllowance: undefined,
    otherAllowance: undefined,
    socialInsuranceRate: undefined,
    housingFundRate: undefined,
    effectiveMonth: '',
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: SalaryConfig) => {
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEdit.value) {
          await updateConfig(formData)
          ElMessage.success('更新成功')
        } else {
          const { id, createTime, updateTime, deleted, ...createData } = formData
          await createConfig(createData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error: any) {
        console.error('保存失败:', error)
        if (error?.message?.includes('Duplicate entry')) {
          ElMessage.error('该员工已存在薪资档案')
        } else {
          ElMessage.error('保存失败，请稍后重试')
        }
      }
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
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
.config-container {
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
