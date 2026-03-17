<template>
  <div class="contract-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>劳动合同管理</span>
          <el-button type="primary" @click="handleAdd">新增合同</el-button>
        </div>
      </template>

      <div class="search-section">
        <el-input
          v-model="searchForm.keyword"
          placeholder="请输入合同编号或员工姓名"
          clearable
          style="width: 250px; margin-right: 10px;"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-select
          v-model="searchForm.status"
          placeholder="请选择合同状态"
          clearable
          style="width: 150px; margin-right: 10px;"
          @change="handleSearch"
        >
          <el-option :value="0" label="草稿" />
          <el-option :value="1" label="生效" />
          <el-option :value="2" label="到期" />
          <el-option :value="3" label="终止" />
        </el-select>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
        <el-button type="warning" @click="handleExpiring">即将到期(30天)</el-button>
      </div>

      <el-table
        :data="contractList"
        border
        stripe
        style="margin-top: 20px;"
      >
        <el-table-column prop="contractNo" label="合同编号" width="150" />
        <el-table-column prop="empName" label="员工姓名" width="100" />
        <el-table-column prop="empCode" label="员工工号" width="120" />
        <el-table-column prop="deptName" label="部门" width="120" />
        <el-table-column prop="contractType" label="合同类型" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.contractType === 'FIXED'" type="primary" size="small">固定期限</el-tag>
            <el-tag v-else-if="row.contractType === 'OPEN'" type="success" size="small">无固定期限</el-tag>
            <el-tag v-else-if="row.contractType === 'PROJECT'" type="warning" size="small">项目合同</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="startDate" label="开始日期" width="110" />
        <el-table-column prop="endDate" label="结束日期" width="110" />
        <el-table-column prop="signDate" label="签订日期" width="110" />
        <el-table-column prop="probationEnd" label="试用期结束" width="110" />
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="daysToExpire" label="距到期天数" width="100" align="center">
          <template #default="{ row }">
            <span :style="{ color: row.daysToExpire !== undefined && row.daysToExpire <= 30 ? 'red' : '' }">
              {{ row.daysToExpire !== undefined ? row.daysToExpire + '天' : '-' }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" align="center" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button v-if="row.status === 1" size="small" type="success" @click="handleRenew(row)">续签</el-button>
            <el-button v-if="row.status === 1" size="small" type="warning" @click="handleTerminate(row)">终止</el-button>
            <el-popconfirm title="确定要删除该合同吗?" @confirm="handleDelete(row)">
              <template #reference>
                <el-button size="small" type="danger">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="pageNum"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end; display: flex;"
        @current-change="loadContractPage"
        @size-change="handleSizeChange"
      />
    </el-card>

    <!-- 新增/编辑合同对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="120px"
      >
        <el-form-item label="员工" prop="employeeId">
          <el-select
            v-model="formData.employeeId"
            filterable
            placeholder="请选择员工"
            style="width: 100%;"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empName} (${emp.empCode})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="合同编号" prop="contractNo">
          <el-input v-model="formData.contractNo" placeholder="如：HT2024001" />
        </el-form-item>
        <el-form-item label="合同类型" prop="contractType">
          <el-select v-model="formData.contractType" placeholder="请选择合同类型" style="width: 100%;">
            <el-option value="FIXED" label="固定期限" />
            <el-option value="OPEN" label="无固定期限" />
            <el-option value="PROJECT" label="项目合同" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker
            v-model="formData.startDate"
            type="date"
            placeholder="请选择开始日期"
            style="width: 100%;"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker
            v-model="formData.endDate"
            type="date"
            placeholder="无固定期限可不填"
            style="width: 100%;"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="签订日期" prop="signDate">
          <el-date-picker
            v-model="formData.signDate"
            type="date"
            placeholder="请选择签订日期"
            style="width: 100%;"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="试用期结束">
          <el-date-picker
            v-model="formData.probationEnd"
            type="date"
            placeholder="请选择试用期结束日期"
            style="width: 100%;"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="合同文件">
          <el-input v-model="formData.fileUrl" placeholder="请输入合同文件URL" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import {
  getContractPage,
  getExpiringContracts,
  createContract,
  updateContract,
  terminateContract,
  renewContract,
  deleteContract,
  type Contract,
  type ContractPageParams
} from '@/api/contract'
import { getEmployeePage, type Employee } from '@/api/employee'

const contractList = ref<Contract[]>([])
const employeeList = ref<Employee[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const isEditMode = ref(false)
const isRenewMode = ref(false)
const renewingContractId = ref<number>()
const formRef = ref<FormInstance>()

const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const searchForm = reactive({
  keyword: '',
  status: undefined as number | undefined
})

const formData = reactive<Partial<Contract>>({
  id: undefined,
  employeeId: undefined,
  contractNo: '',
  contractType: '',
  startDate: '',
  endDate: '',
  signDate: '',
  probationEnd: '',
  fileUrl: '',
  remark: ''
})

const rules: FormRules = {
  employeeId: [
    { required: true, message: '请选择员工', trigger: 'change' }
  ],
  contractNo: [
    { required: true, message: '请输入合同编号', trigger: 'blur' }
  ],
  contractType: [
    { required: true, message: '请选择合同类型', trigger: 'change' }
  ],
  startDate: [
    { required: true, message: '请选择开始日期', trigger: 'change' }
  ],
  signDate: [
    { required: true, message: '请选择签订日期', trigger: 'change' }
  ]
}

const loadEmployeeList = async () => {
  try {
    const res = await getEmployeePage({ pageNum: 1, pageSize: 1000, workStatus: 2 })
    employeeList.value = res.records || []
  } catch (error) {
    console.error('加载员工列表失败:', error)
  }
}

const loadContractPage = async () => {
  try {
    const params: ContractPageParams = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: searchForm.keyword || undefined,
      status: searchForm.status
    }
    const res = await getContractPage(params)
    contractList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载合同列表失败:', error)
  }
}

const getStatusType = (status?: number) => {
  switch (status) {
    case 0: return 'info'
    case 1: return 'success'
    case 2: return 'warning'
    case 3: return 'danger'
    default: return ''
  }
}

const getStatusText = (status?: number) => {
  switch (status) {
    case 0: return '草稿'
    case 1: return '生效'
    case 2: return '到期'
    case 3: return '终止'
    default: return ''
  }
}

const handleSearch = () => {
  pageNum.value = 1
  loadContractPage()
}

const handleReset = () => {
  searchForm.keyword = ''
  searchForm.status = undefined
  pageNum.value = 1
  pageSize.value = 20
  loadContractPage()
}

const handleSizeChange = () => {
  pageNum.value = 1
  loadContractPage()
}

const handleExpiring = async () => {
  try {
    const expiring = await getExpiringContracts(30)
    if (expiring && expiring.length > 0) {
      ElMessage.success(`查询到 ${expiring.length} 份即将到期合同`)
      contractList.value = expiring
      total.value = expiring.length
    } else {
      ElMessage.info('暂无即将到期的合同')
      contractList.value = []
      total.value = 0
    }
  } catch (error) {
    console.error('查询即将到期合同失败:', error)
  }
}

const handleAdd = () => {
  isEditMode.value = false
  isRenewMode.value = false
  dialogTitle.value = '新增合同'
  Object.assign(formData, {
    id: undefined,
    employeeId: undefined,
    contractNo: '',
    contractType: '',
    startDate: '',
    endDate: '',
    signDate: '',
    probationEnd: '',
    fileUrl: '',
    remark: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row: Contract) => {
  isEditMode.value = true
  isRenewMode.value = false
  dialogTitle.value = '编辑合同'
  Object.assign(formData, {
    id: row.id,
    employeeId: row.employeeId,
    contractNo: row.contractNo,
    contractType: row.contractType,
    startDate: row.startDate,
    endDate: row.endDate,
    signDate: row.signDate,
    probationEnd: row.probationEnd,
    fileUrl: row.fileUrl,
    remark: row.remark
  })
  dialogVisible.value = true
}

const handleRenew = (row: Contract) => {
  isRenewMode.value = true
  isEditMode.value = false
  renewingContractId.value = row.id
  dialogTitle.value = '续签合同'
  Object.assign(formData, {
    id: undefined,
    employeeId: row.employeeId,
    contractNo: '',
    contractType: row.contractType,
    startDate: '',
    endDate: '',
    signDate: '',
    probationEnd: '',
    fileUrl: '',
    remark: `续签自合同编号:${row.contractNo}`
  })
  dialogVisible.value = true
}

const handleTerminate = async (row: Contract) => {
  try {
    await terminateContract(row.id!)
    ElMessage.success('终止合同成功')
    loadContractPage()
  } catch (error) {
    console.error('终止合同失败:', error)
  }
}

const handleSave = async () => {
  if (!formRef.value) return
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isRenewMode.value && renewingContractId.value) {
          await renewContract(renewingContractId.value, formData)
          ElMessage.success('续签合同成功')
        } else if (isEditMode.value) {
          await updateContract(formData)
          ElMessage.success('更新合同成功')
        } else {
          await createContract(formData)
          ElMessage.success('新增合同成功')
        }
        dialogVisible.value = false
        loadContractPage()
      } catch (error) {
        console.error('保存合同失败:', error)
      }
    }
  })
}

const handleDelete = async (row: Contract) => {
  try {
    await deleteContract(row.id!)
    ElMessage.success('删除合同成功')
    loadContractPage()
  } catch (error) {
    console.error('删除合同失败:', error)
  }
}

onMounted(() => {
  loadEmployeeList()
  loadContractPage()
})
</script>

<style scoped>
.contract-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 18px;
  font-weight: bold;
}

.search-section {
  display: flex;
  align-items: center;
  padding: 15px;
  background-color: #f5f7fa;
  border-radius: 8px;
}
</style>
