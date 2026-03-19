<template>
  <div class="social-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>社保公积金管理</span>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="员工姓名">
          <el-input
            v-model="queryParams.keyword"
            placeholder="请输入员工姓名"
            clearable
            style="width: 150px"
            @clear="handleQuery"
          />
        </el-form-item>
        <el-form-item label="城市">
          <el-select
            v-model="queryParams.city"
            placeholder="请选择城市"
            clearable
            @change="handleQuery"
          >
            <el-option label="北京" value="北京" />
            <el-option label="上海" value="上海" />
            <el-option label="广州" value="广州" />
            <el-option label="深圳" value="深圳" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="queryParams.status"
            placeholder="请选择状态"
            clearable
            @change="handleQuery"
          >
            <el-option label="正常" :value="1" />
            <el-option label="已停保" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-bar">
        <el-button type="primary" @click="handleAdd">新增账户</el-button>
        <el-button type="success" @click="showRecordDialog">缴纳记录</el-button>
        <el-button type="warning" @click="showSummaryDialog">月度汇总</el-button>
      </div>

      <!-- 账户列表 -->
      <el-table
        v-loading="loading"
        :data="accountList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="empCode" label="员工编号" width="120" />
        <el-table-column prop="empName" label="员工姓名" width="120" />
        <el-table-column prop="city" label="城市" width="100" />
        <el-table-column label="社保基数/比例" width="180">
          <template #default="{ row }">
            {{ row.socialBase }} / 个人{{ (row.personalSocialRate * 100).toFixed(2) }}% 企业{{ (row.companySocialRate * 100).toFixed(2) }}%
          </template>
        </el-table-column>
        <el-table-column label="公积金基数/比例" width="180">
          <template #default="{ row }">
            {{ row.fundBase }} / 个人{{ (row.personalFundRate * 100).toFixed(2) }}% 企业{{ (row.companyFundRate * 100).toFixed(2) }}%
          </template>
        </el-table-column>
        <el-table-column prop="startMonth" label="参保月份" width="120" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '正常' : '已停保' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button
              v-if="row.status === 1"
              link
              type="warning"
              size="small"
              @click="handleStop(row)"
            >
              停保
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
        @size-change="handleQuery"
        @current-change="handleQuery"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="800px"
      @close="resetForm"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="140px"
      >
        <el-divider content-position="left">基本信息</el-divider>
        <el-form-item label="员工" prop="employeeId">
          <el-select
            v-model="formData.employeeId"
            placeholder="请选择员工"
            filterable
            style="width: 100%"
            :disabled="isEdit"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="社保账号" prop="socialSecurityNo">
          <el-input v-model="formData.socialSecurityNo" placeholder="请输入社保账号" />
        </el-form-item>
        <el-form-item label="公积金账号" prop="housingFundNo">
          <el-input v-model="formData.housingFundNo" placeholder="请输入公积金账号" />
        </el-form-item>
        <el-form-item label="城市" prop="city">
          <el-select v-model="formData.city" placeholder="请选择城市" style="width: 100%">
            <el-option label="北京" value="北京" />
            <el-option label="上海" value="上海" />
            <el-option label="广州" value="广州" />
            <el-option label="深圳" value="深圳" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="参保月份" prop="startMonth">
          <el-date-picker
            v-model="formData.startMonth"
            type="month"
            placeholder="请选择参保月份"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="停保月份" prop="endMonth">
          <el-date-picker
            v-model="formData.endMonth"
            type="month"
            placeholder="请选择停保月份"
            value-format="YYYY-MM"
            style="width: 100%"
            :disabled="formData.status === 1"
          />
        </el-form-item>

        <el-divider content-position="left">社保设置</el-divider>
        <el-form-item label="社保基数" prop="socialBase">
          <el-input-number
            v-model="formData.socialBase"
            :min="0"
            :precision="2"
            style="width: 100%"
          />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="个人社保比例" prop="personalSocialRate">
              <el-input-number
                v-model="formData.personalSocialRate"
                :min="0"
                :max="1"
                :step="0.01"
                :precision="4"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="企业社保比例" prop="companySocialRate">
              <el-input-number
                v-model="formData.companySocialRate"
                :min="0"
                :max="1"
                :step="0.01"
                :precision="4"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>

        <el-divider content-position="left">公积金设置</el-divider>
        <el-form-item label="公积金基数" prop="fundBase">
          <el-input-number
            v-model="formData.fundBase"
            :min="0"
            :precision="2"
            style="width: 100%"
          />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="个人公积金比例" prop="personalFundRate">
              <el-input-number
                v-model="formData.personalFundRate"
                :min="0"
                :max="1"
                :step="0.01"
                :precision="4"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="企业公积金比例" prop="companyFundRate">
              <el-input-number
                v-model="formData.companyFundRate"
                :min="0"
                :max="1"
                :step="0.01"
                :precision="4"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="formData.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 缴纳记录对话框 -->
    <el-dialog
      v-model="recordDialogVisible"
      title="社保公积金缴纳记录"
      width="95%"
      top="5vh"
    >
      <el-form :inline="true" :model="recordQueryParams" class="search-form">
        <el-form-item label="员工姓名">
          <el-input
            v-model="recordQueryParams.keyword"
            placeholder="请输入员工姓名"
            clearable
            @clear="handleRecordQuery"
          />
        </el-form-item>
        <el-form-item label="月份">
          <el-date-picker
            v-model="recordQueryParams.payMonth"
            type="month"
            placeholder="请选择月份"
            value-format="YYYY-MM"
            clearable
            @change="handleRecordQuery"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="recordQueryParams.status"
            placeholder="请选择状态"
            clearable
            @change="handleRecordQuery"
          >
            <el-option label="未申报" :value="0" />
            <el-option label="已申报" :value="1" />
            <el-option label="已缴纳" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleRecordQuery">查询</el-button>
          <el-button @click="resetRecordQuery">重置</el-button>
          <el-button type="success" @click="handleGenerateRecords">批量生成记录</el-button>
        </el-form-item>
      </el-form>

      <el-table
        v-loading="recordLoading"
        :data="recordList"
        border
        stripe
        style="width: 100%; margin-top: 10px"
      >
        <el-table-column prop="empCode" label="员工编号" width="100" fixed />
        <el-table-column prop="employeeName" label="员工姓名" width="100" fixed />
        <el-table-column prop="city" label="城市" width="80" />
        <el-table-column prop="payMonth" label="月份" width="100" />
        <el-table-column label="个人养老" width="80" align="right">
          <template #default="{ row }">
            {{ row.personalPension?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="企业养老" width="80" align="right">
          <template #default="{ row }">
            {{ row.companyPension?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="个人医疗" width="80" align="right">
          <template #default="{ row }">
            {{ row.personalMedical?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="企业医疗" width="80" align="right">
          <template #default="{ row }">
            {{ row.companyMedical?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="个人失业" width="80" align="right">
          <template #default="{ row }">
            {{ row.personalUnemployment?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="企业失业" width="80" align="right">
          <template #default="{ row }">
            {{ row.companyUnemployment?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="企业工伤" width="80" align="right">
          <template #default="{ row }">
            {{ row.companyInjury?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="企业生育" width="80" align="right">
          <template #default="{ row }">
            {{ row.companyMaternity?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="个人公积金" width="90" align="right">
          <template #default="{ row }">
            {{ row.personalHousingFund?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="企业公积金" width="90" align="right">
          <template #default="{ row }">
            {{ row.companyHousingFund?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column label="个人合计" width="90" align="right">
          <template #default="{ row }">
            <span style="color: #f56c6c; font-weight: bold">
              {{ row.personalTotal?.toFixed(2) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="企业合计" width="90" align="right">
          <template #default="{ row }">
            <span style="color: #409eff; font-weight: bold">
              {{ row.companyTotal?.toFixed(2) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="总计" width="90" align="right">
          <template #default="{ row }">
            <span style="color: #67c23a; font-weight: bold">
              {{ row.total?.toFixed(2) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="declareDate" label="申报日期" width="110" />
        <el-table-column prop="payDate" label="缴纳日期" width="110" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.status === 0"
              link
              type="primary"
              size="small"
              @click="handleUpdateStatus(row, 1)"
            >
              申报
            </el-button>
            <el-button
              v-if="row.status === 1"
              link
              type="success"
              size="small"
              @click="handleUpdateStatus(row, 2)"
            >
              缴纳
            </el-button>
            <el-button
              v-if="row.status === 2"
              link
              type="warning"
              size="small"
              @click="handleUpdateStatus(row, 1)"
            >
              撤销缴纳
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="recordQueryParams.pageNum"
        v-model:page-size="recordQueryParams.pageSize"
        :total="recordTotal"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
        @size-change="handleRecordQuery"
        @current-change="handleRecordQuery"
      />
    </el-dialog>

    <!-- 月度汇总对话框 -->
    <el-dialog
      v-model="summaryDialogVisible"
      title="月度社保公积金汇总"
      width="90%"
      top="5vh"
    >
      <el-form :inline="true" :model="summaryQueryParams" class="search-form">
        <el-form-item label="月份">
          <el-date-picker
            v-model="summaryQueryParams.payMonth"
            type="month"
            placeholder="请选择月份"
            value-format="YYYY-MM"
            clearable
            @change="handleSummaryQuery"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSummaryQuery">查询</el-button>
          <el-button @click="resetSummaryQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table
        v-loading="summaryLoading"
        :data="summaryList"
        border
        stripe
        style="width: 100%; margin-top: 10px"
        show-summary
        :summary-method="getSummaries"
      >
        <el-table-column prop="empCode" label="员工编号" width="120" />
        <el-table-column prop="employeeName" label="员工姓名" width="120" />
        <el-table-column prop="payMonth" label="月份" width="100" />
        <el-table-column label="个人合计" width="120" align="right">
          <template #default="{ row }">
            <span style="color: #f56c6c; font-weight: bold">
              {{ row.personalTotal?.toFixed(2) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="企业合计" width="120" align="right">
          <template #default="{ row }">
            <span style="color: #409eff; font-weight: bold">
              {{ row.companyTotal?.toFixed(2) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="总计" width="120" align="right">
          <template #default="{ row }">
            <span style="color: #67c23a; font-weight: bold">
              {{ row.total?.toFixed(2) }}
            </span>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getAccountPage,
  createAccount,
  updateAccount,
  stopAccount,
  deleteAccount,
  getRecordPage,
  generateRecords,
  updateRecordStatus,
  getRecordSummary,
  type SocialAccount,
  type AccountPageParams,
  type RecordPageParams
} from '@/api/social'
import { getEmployeePage } from '@/api/employee'

// 账户列表
const loading = ref(false)
const accountList = ref<SocialAccount[]>([])
const total = ref(0)
const queryParams = reactive<AccountPageParams & { keyword?: string }>({
  pageNum: 1,
  pageSize: 10,
  keyword: undefined,
  status: undefined,
  city: undefined
})

// 员工列表
const employeeList = ref<any[]>([])

// 新增/编辑对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增社保公积金账户')
const isEdit = ref(false)
const formRef = ref<FormInstance>()
const formData = reactive<Partial<SocialAccount>>({})

const formRules: FormRules = {
  employeeId: [{ required: true, message: '请选择员工', trigger: 'change' }],
  city: [{ required: true, message: '请选择城市', trigger: 'change' }],
  startMonth: [{ required: true, message: '请选择参保月份', trigger: 'change' }],
  socialBase: [{ required: true, message: '请输入社保基数', trigger: 'blur' }],
  personalSocialRate: [{ required: true, message: '请输入个人社保比例', trigger: 'blur' }],
  companySocialRate: [{ required: true, message: '请输入企业社保比例', trigger: 'blur' }],
  fundBase: [{ required: true, message: '请输入公积金基数', trigger: 'blur' }],
  personalFundRate: [{ required: true, message: '请输入个人公积金比例', trigger: 'blur' }],
  companyFundRate: [{ required: true, message: '请输入企业公积金比例', trigger: 'blur' }]
}

// 缴纳记录对话框
const recordDialogVisible = ref(false)
const recordLoading = ref(false)
const recordList = ref<any[]>([])
const recordTotal = ref(0)
const recordQueryParams = reactive<RecordPageParams & { keyword?: string }>({
  pageNum: 1,
  pageSize: 20,
  keyword: undefined,
  payMonth: undefined,
  status: undefined
})

// 月度汇总对话框
const summaryDialogVisible = ref(false)
const summaryLoading = ref(false)
const summaryList = ref<any[]>([])
const summaryQueryParams = reactive<{ payMonth?: string }>({
  payMonth: undefined
})

// 查询账户列表
const handleQuery = async () => {
  loading.value = true
  try {
    const params = { ...queryParams }
    if (params.keyword) {
      // 如果有关键词，需要先查询员工
      const employeeRes = await getEmployeePage({
        pageNum: 1,
        pageSize: 100,
        keyword: params.keyword
      })
      if (employeeRes.records && employeeRes.records.length > 0) {
        params.employeeId = employeeRes.records[0].id
      }
    }
    delete params.keyword

    const res = await getAccountPage(params)
    accountList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取账户列表失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.keyword = undefined
  queryParams.status = undefined
  queryParams.city = undefined
  handleQuery()
}

// 新增账户
const handleAdd = () => {
  dialogTitle.value = '新增社保公积金账户'
  isEdit.value = false
  dialogVisible.value = true
}

// 编辑账户
const handleEdit = (row: SocialAccount) => {
  dialogTitle.value = '编辑社保公积金账户'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 停保
const handleStop = async (row: SocialAccount) => {
  try {
    const { value: endMonth } = await ElMessageBox.prompt('请输入停保月份', '停保确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputPattern: /^\d{4}-\d{2}$/,
      inputErrorMessage: '请输入正确的月份格式，如：2026-03'
    })
    if (endMonth) {
      await stopAccount(row.id!, endMonth)
      ElMessage.success('停保成功')
      handleQuery()
    }
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('停保失败:', error)
      ElMessage.error(error.message || '停保失败')
    }
  }
}

// 删除账户
const handleDelete = async (row: SocialAccount) => {
  try {
    await ElMessageBox.confirm('确认要删除该账户吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteAccount(row.id!)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return

    try {
      if (isEdit.value) {
        await updateAccount(formData as SocialAccount)
        ElMessage.success('更新成功')
      } else {
        const { id, createTime, updateTime, isDeleted, ...createData } = formData
        await createAccount(createData as SocialAccount)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      handleQuery()
    } catch (error: any) {
      ElMessage.error(error.message || '操作失败')
    }
  })
}

// 重置表单
const resetForm = () => {
  Object.keys(formData).forEach((key) => {
    delete formData[key as keyof SocialAccount]
  })
  formRef.value?.resetFields()
}

// 显示缴纳记录对话框
const showRecordDialog = () => {
  recordDialogVisible.value = true
  handleRecordQuery()
}

// 查询缴纳记录
const handleRecordQuery = async () => {
  recordLoading.value = true
  try {
    const params = { ...recordQueryParams }
    if (params.keyword) {
      const employeeRes = await getEmployeePage({
        pageNum: 1,
        pageSize: 100,
        keyword: params.keyword
      })
      if (employeeRes.records && employeeRes.records.length > 0) {
        params.employeeId = employeeRes.records[0].id
      }
    }
    delete params.keyword

    const res = await getRecordPage(params)
    recordList.value = res.records
    recordTotal.value = res.total
  } catch (error) {
    ElMessage.error('获取缴纳记录失败')
  } finally {
    recordLoading.value = false
  }
}

// 重置缴纳记录查询
const resetRecordQuery = () => {
  recordQueryParams.pageNum = 1
  recordQueryParams.pageSize = 20
  recordQueryParams.keyword = undefined
  recordQueryParams.payMonth = undefined
  recordQueryParams.status = undefined
  handleRecordQuery()
}

// 批量生成记录
const handleGenerateRecords = async () => {
  try {
    await ElMessageBox.confirm('确认要批量生成本月缴纳记录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const currentMonth = new Date().toISOString().slice(0, 7)
    await generateRecords({ payMonth: currentMonth })
    ElMessage.success('批量生成成功')
    handleRecordQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('批量生成失败')
    }
  }
}

// 更新申报/缴纳状态
const handleUpdateStatus = async (row: any, status: number) => {
  try {
    await updateRecordStatus(row.id, { status })
    ElMessage.success('更新状态成功')
    handleRecordQuery()
  } catch (error) {
    ElMessage.error('更新状态失败')
  }
}

// 显示月度汇总对话框
const showSummaryDialog = () => {
  summaryDialogVisible.value = true
  handleSummaryQuery()
}

// 查询月度汇总
const handleSummaryQuery = async () => {
  summaryLoading.value = true
  try {
    const res = await getRecordSummary(summaryQueryParams.payMonth)
    summaryList.value = Array.isArray(res) ? res : []
  } catch (error) {
    ElMessage.error('获取月度汇总失败')
    summaryList.value = []
  } finally {
    summaryLoading.value = false
  }
}

// 重置月度汇总查询
const resetSummaryQuery = () => {
  summaryQueryParams.payMonth = undefined
  handleSummaryQuery()
}

// 获取状态文本
const getStatusText = (status: number) => {
  const map: Record<number, string> = {
    0: '未申报',
    1: '已申报',
    2: '已缴纳'
  }
  return map[status] || '未知'
}

// 获取状态类型
const getStatusType = (status: number) => {
  const map: Record<number, string> = {
    0: 'info',
    1: 'warning',
    2: 'success'
  }
  return map[status] || 'info'
}

// 汇总行
const getSummaries = (param: any) => {
  const { columns, data } = param
  const sums: string[] = []
  columns.forEach((column: any, index: number) => {
    if (index === 0) {
      sums[index] = '合计'
      return
    }
    if (index >= 3) {
      const values = data.map((item: any) => Number(item[column.property]))
      if (!values.every((value: number) => Number.isNaN(value))) {
        sums[index] = values.reduce((prev: number, curr: number) => {
          const value = Number(curr)
          if (!Number.isNaN(value)) {
            return prev + curr
          }
          return prev
        }, 0).toFixed(2)
      } else {
        sums[index] = ''
      }
    }
  })
  return sums
}

// 加载员工列表
const loadEmployeeList = async () => {
  try {
    const res = await getEmployeePage({ pageNum: 1, pageSize: 1000 })
    employeeList.value = res.records
  } catch (error) {
    console.error('加载员工列表失败', error)
  }
}

onMounted(() => {
  handleQuery()
  loadEmployeeList()
})
</script>

<style scoped>
.social-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.operation-bar {
  margin: 20px 0;
  display: flex;
  gap: 10px;
}
</style>
