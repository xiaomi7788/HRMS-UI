<template>
  <div class="employee-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工管理</span>
          <div>
            <el-button @click="handleExport">导出花名册</el-button>
            <el-button type="primary" @click="handleAdd">新增员工</el-button>
          </div>
        </div>
      </template>

      <div class="search-section">
        <el-select
          v-model="searchForm.deptId"
          placeholder="请选择部门"
          clearable
          style="width: 200px; margin-right: 10px;"
          @change="handleSearch"
        >
          <el-option
            v-for="dept in deptList"
            :key="dept.id"
            :label="dept.deptName"
            :value="dept.id"
          />
        </el-select>
        <el-select
          v-model="searchForm.workStatus"
          placeholder="请选择在职状态"
          clearable
          style="width: 150px; margin-right: 10px;"
          @change="handleSearch"
        >
          <el-option label="试用期" :value="1" />
          <el-option label="在职" :value="2" />
          <el-option label="离职" :value="3" />
          <el-option label="退休" :value="4" />
        </el-select>
        <el-input
          v-model="searchForm.keyword"
          placeholder="请输入姓名或工号"
          clearable
          style="width: 250px; margin-right: 10px;"
          @keyup.enter="handleSearch"
          @clear="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>

      <el-table
        :data="employeeList"
        border
        stripe
        style="margin-top: 20px;"
      >
        <el-table-column prop="empCode" label="工号" width="100" />
        <el-table-column label="姓名" width="100">
          <template #default="{ row }">
            <div style="display: flex; align-items: center;">
              <el-avatar v-if="row.avatar" :src="row.avatar" :size="32" style="margin-right: 10px;" />
              <span>{{ row.empName }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="deptName" label="部门" width="120" />
        <el-table-column prop="positionName" label="岗位" width="120" />
        <el-table-column prop="phone" label="手机号" width="120" />
        <el-table-column prop="entryDate" label="入职日期" width="110" />
        <el-table-column prop="workStatus" label="在职状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="getWorkStatusTagType(row.workStatus)" size="small">
              {{ getWorkStatusText(row.workStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="320" align="center" fixed="right">
          <template #default="{ row }">
            <el-button size="small" link type="primary" @click="handleDetail(row)">详情</el-button>
            <el-button size="small" link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button v-if="row.workStatus === 1" size="small" link type="success" @click="handleRegular(row)">转正</el-button>
            <el-button v-if="row.workStatus === 2" size="small" link type="warning" @click="handleTransfer(row)">调岗</el-button>
            <el-button v-if="row.workStatus === 2" size="small" link type="danger" @click="handleLeave(row)">离职</el-button>
            <el-popconfirm title="确定要删除该员工吗?" @confirm="handleDelete(row)">
              <template #reference>
                <el-button size="small" link type="danger">删除</el-button>
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
        @current-change="loadEmployeePage"
        @size-change="handleSizeChange"
      />
    </el-card>

    <!-- 新增/编辑员工对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        label-width="120px"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="员工工号" prop="empCode">
              <el-input v-model="formData.empCode" placeholder="如：EMP001" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" prop="empName">
              <el-input v-model="formData.empName" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-radio-group v-model="formData.gender">
                <el-radio :value="0">女</el-radio>
                <el-radio :value="1">男</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="出生日期" prop="birthday">
              <el-date-picker
                v-model="formData.birthday"
                type="date"
                placeholder="请选择出生日期"
                value-format="YYYY-MM-DD"
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="身份证号" prop="idCard">
              <el-input v-model="formData.idCard" placeholder="请输入身份证号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="formData.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="formData.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="用工形式" prop="workType">
              <el-select v-model="formData.workType" placeholder="请选择用工形式" style="width: 100%;">
                <el-option label="全职" value="全职" />
                <el-option label="兼职" value="兼职" />
                <el-option label="实习" value="实习" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="所属部门" prop="deptId">
              <el-tree-select
                v-model="formData.deptId"
                :data="deptList"
                :props="{ label: 'deptName', value: 'id' }"
                :render-after-expand="false"
                placeholder="请选择部门"
                clearable
                check-strictly
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="岗位" prop="positionId">
              <el-select v-model="formData.positionId" placeholder="请选择岗位" style="width: 100%;" clearable>
                <el-option
                  v-for="pos in positionList"
                  :key="pos.id"
                  :label="pos.positionName"
                  :value="pos.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="直属上级" prop="leaderId">
              <el-select v-model="formData.leaderId" placeholder="请选择直属上级" style="width: 100%;" clearable filterable>
                <el-option
                  v-for="emp in employeeList"
                  :key="emp.id"
                  :label="`${emp.empName} (${emp.empCode})`"
                  :value="emp.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="入职日期" prop="entryDate">
              <el-date-picker
                v-model="formData.entryDate"
                type="date"
                placeholder="请选择入职日期"
                value-format="YYYY-MM-DD"
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="转正日期" prop="regularDate">
              <el-date-picker
                v-model="formData.regularDate"
                type="date"
                placeholder="请选择转正日期"
                value-format="YYYY-MM-DD"
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="合同开始" prop="contractStart">
              <el-date-picker
                v-model="formData.contractStart"
                type="date"
                placeholder="请选择合同开始日期"
                value-format="YYYY-MM-DD"
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="合同结束" prop="contractEnd">
              <el-date-picker
                v-model="formData.contractEnd"
                type="date"
                placeholder="请选择合同结束日期"
                value-format="YYYY-MM-DD"
                style="width: 100%;"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="学历" prop="education">
              <el-select v-model="formData.education" placeholder="请选择学历" style="width: 100%;">
                <el-option label="本科" value="本科" />
                <el-option label="硕士" value="硕士" />
                <el-option label="博士" value="博士" />
                <el-option label="高中" value="高中" />
                <el-option label="大专" value="大专" />
                <el-option label="其他" value="其他" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="毕业院校" prop="school">
              <el-input v-model="formData.school" placeholder="请输入毕业院校" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="专业" prop="major">
              <el-input v-model="formData.major" placeholder="请输入专业" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="紧急联系人" prop="emergencyContact">
              <el-input v-model="formData.emergencyContact" placeholder="请输入紧急联系人" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="紧急联系电话" prop="emergencyPhone">
              <el-input v-model="formData.emergencyPhone" placeholder="请输入紧急联系电话" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="银行卡号" prop="bankAccount">
              <el-input v-model="formData.bankAccount" placeholder="请输入银行卡号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="开户银行" prop="bankName">
              <el-input v-model="formData.bankName" placeholder="请输入开户银行" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="remark">
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

    <!-- 员工详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="员工详情"
      width="700px"
    >
      <el-descriptions :column="2" border v-if="currentEmployee">
        <el-descriptions-item label="工号">{{ currentEmployee.empCode }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ currentEmployee.empName }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ currentEmployee.gender === 1 ? '男' : '女' }}</el-descriptions-item>
        <el-descriptions-item label="出生日期">{{ currentEmployee.birthday }}</el-descriptions-item>
        <el-descriptions-item label="身份证号">{{ currentEmployee.idCard }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentEmployee.phone }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ currentEmployee.email }}</el-descriptions-item>
        <el-descriptions-item label="用工形式">{{ currentEmployee.workType }}</el-descriptions-item>
        <el-descriptions-item label="部门">{{ currentEmployee.deptName }}</el-descriptions-item>
        <el-descriptions-item label="岗位">{{ currentEmployee.positionName }}</el-descriptions-item>
        <el-descriptions-item label="直属上级">{{ currentEmployee.leaderName }}</el-descriptions-item>
        <el-descriptions-item label="入职日期">{{ currentEmployee.entryDate }}</el-descriptions-item>
        <el-descriptions-item label="转正日期">{{ currentEmployee.regularDate }}</el-descriptions-item>
        <el-descriptions-item label="合同开始">{{ currentEmployee.contractStart }}</el-descriptions-item>
        <el-descriptions-item label="合同结束">{{ currentEmployee.contractEnd }}</el-descriptions-item>
        <el-descriptions-item label="学历">{{ currentEmployee.education }}</el-descriptions-item>
        <el-descriptions-item label="毕业院校">{{ currentEmployee.school }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ currentEmployee.major }}</el-descriptions-item>
        <el-descriptions-item label="紧急联系人">{{ currentEmployee.emergencyContact }}</el-descriptions-item>
        <el-descriptions-item label="紧急联系电话">{{ currentEmployee.emergencyPhone }}</el-descriptions-item>
        <el-descriptions-item label="银行卡号">{{ currentEmployee.bankAccount }}</el-descriptions-item>
        <el-descriptions-item label="开户银行">{{ currentEmployee.bankName }}</el-descriptions-item>
        <el-descriptions-item label="在职状态">
          <el-tag :type="getWorkStatusTagType(currentEmployee.workStatus)" size="small">
            {{ getWorkStatusText(currentEmployee.workStatus) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ currentEmployee.remark }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 调岗对话框 -->
    <el-dialog
      v-model="transferDialogVisible"
      title="员工调岗"
      width="500px"
    >
      <el-form
        ref="transferFormRef"
        :model="transferForm"
        :rules="transferRules"
        label-width="120px"
      >
        <el-form-item label="调入部门" prop="deptId">
          <el-tree-select
            v-model="transferForm.deptId"
            :data="deptList"
            :props="{ label: 'deptName', value: 'id' }"
            :render-after-expand="false"
            placeholder="请选择调入部门"
            clearable
            check-strictly
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="调入岗位" prop="positionId">
          <el-select v-model="transferForm.positionId" placeholder="请选择调入岗位" style="width: 100%;" clearable>
            <el-option
              v-for="pos in positionList"
              :key="pos.id"
              :label="pos.positionName"
              :value="pos.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="生效日期" prop="effectiveDate">
          <el-date-picker
            v-model="transferForm.effectiveDate"
            type="date"
            placeholder="请选择生效日期"
            value-format="YYYY-MM-DD"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="调岗备注">
          <el-input v-model="transferForm.remark" type="textarea" :rows="3" placeholder="请输入调岗备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="transferDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveTransfer">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 离职对话框 -->
    <el-dialog
      v-model="leaveDialogVisible"
      title="员工离职"
      width="500px"
    >
      <el-form
        ref="leaveFormRef"
        :model="leaveForm"
        :rules="leaveRules"
        label-width="120px"
      >
        <el-form-item label="离职日期" prop="leaveDate">
          <el-date-picker
            v-model="leaveForm.leaveDate"
            type="date"
            placeholder="请选择离职日期"
            value-format="YYYY-MM-DD"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="离职原因" prop="reason">
          <el-input v-model="leaveForm.reason" type="textarea" :rows="4" placeholder="请输入离职原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="leaveDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveLeave">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 转正对话框 -->
    <el-dialog
      v-model="regularDialogVisible"
      title="员工转正"
      width="400px"
    >
      <el-form
        ref="regularFormRef"
        :model="regularForm"
        :rules="regularRules"
        label-width="120px"
      >
        <el-form-item label="转正日期" prop="regularDate">
          <el-date-picker
            v-model="regularForm.regularDate"
            type="date"
            placeholder="请选择转正日期"
            value-format="YYYY-MM-DD"
            style="width: 100%;"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="regularDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveRegular">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, type FormInstance, type FormRules, type UploadProps } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import {
  getEmployeePage,
  getEmployee,
  createEmployee,
  updateEmployee,
  deleteEmployee,
  transferEmployee,
  regularEmployee,
  leaveEmployee,
  exportEmployee,
  type Employee,
  type EmployeePageParams,
  type TransferDTO,
  type LeaveDTO
} from '@/api/employee'
import { getDeptTree, type Department } from '@/api/dept'
import { getPositionList, type Position } from '@/api/position'

const employeeList = ref<Employee[]>([])
const deptList = ref<Department[]>([])
const positionList = ref<Position[]>([])
const dialogVisible = ref(false)
const detailDialogVisible = ref(false)
const transferDialogVisible = ref(false)
const leaveDialogVisible = ref(false)
const regularDialogVisible = ref(false)
const dialogTitle = ref('')
const isEditMode = ref(false)
const formRef = ref<FormInstance>()
const transferFormRef = ref<FormInstance>()
const leaveFormRef = ref<FormInstance>()
const regularFormRef = ref<FormInstance>()

const currentEmployee = ref<Employee | null>(null)
const currentEmployeeId = ref<number>()

const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const searchForm = reactive({
  deptId: undefined as number | undefined,
  workStatus: undefined as number | undefined,
  keyword: ''
})

const formData = reactive<Partial<Employee>>({
  id: undefined,
  empCode: '',
  empName: '',
  gender: 1,
  birthday: '',
  idCard: '',
  phone: '',
  email: '',
  workType: '全职',
  deptId: undefined,
  positionId: undefined,
  leaderId: undefined,
  entryDate: '',
  regularDate: '',
  contractStart: '',
  contractEnd: '',
  education: '',
  school: '',
  major: '',
  emergencyContact: '',
  emergencyPhone: '',
  bankAccount: '',
  bankName: '',
  remark: ''
})

const transferForm = reactive<TransferDTO>({
  deptId: 0,
  positionId: undefined,
  effectiveDate: '',
  remark: ''
})

const leaveForm = reactive<LeaveDTO>({
  leaveDate: '',
  reason: ''
})

const regularForm = reactive({
  regularDate: ''
})

const rules: FormRules = {
  empCode: [
    { required: true, message: '请输入员工工号', trigger: 'blur' }
  ],
  empName: [
    { required: true, message: '请输入姓名', trigger: 'blur' }
  ],
  deptId: [
    { required: true, message: '请选择所属部门', trigger: 'change' }
  ],
  entryDate: [
    { required: true, message: '请选择入职日期', trigger: 'change' }
  ]
}

const transferRules: FormRules = {
  deptId: [
    { required: true, message: '请选择调入部门', trigger: 'change' }
  ],
  effectiveDate: [
    { required: true, message: '请选择生效日期', trigger: 'change' }
  ]
}

const leaveRules: FormRules = {
  leaveDate: [
    { required: true, message: '请选择离职日期', trigger: 'change' }
  ],
  reason: [
    { required: true, message: '请输入离职原因', trigger: 'blur' }
  ]
}

const regularRules: FormRules = {
  regularDate: [
    { required: true, message: '请选择转正日期', trigger: 'change' }
  ]
}

const loadDeptTree = async () => {
  try {
    deptList.value = await getDeptTree()
  } catch (error) {
    console.error('加载部门树失败:', error)
  }
}

const loadPositionList = async () => {
  try {
    positionList.value = await getPositionList()
  } catch (error) {
    console.error('加载岗位列表失败:', error)
  }
}

const loadEmployeePage = async () => {
  try {
    const params: EmployeePageParams = {
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      deptId: searchForm.deptId,
      workStatus: searchForm.workStatus,
      keyword: searchForm.keyword || undefined
    }
    const res = await getEmployeePage(params)
    employeeList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载员工列表失败:', error)
  }
}

const getWorkStatusText = (status?: number) => {
  const map: Record<number, string> = {
    1: '试用期',
    2: '在职',
    3: '离职',
    4: '退休'
  }
  return status !== undefined ? map[status] || '-' : '-'
}

const getWorkStatusTagType = (status?: number) => {
  const map: Record<number, string> = {
    1: 'warning',
    2: 'success',
    3: 'danger',
    4: 'info'
  }
  return status !== undefined ? map[status] : 'info'
}

const handleSearch = () => {
  pageNum.value = 1
  loadEmployeePage()
}

const handleReset = () => {
  searchForm.deptId = undefined
  searchForm.workStatus = undefined
  searchForm.keyword = ''
  pageNum.value = 1
  pageSize.value = 20
  loadEmployeePage()
}

const handleSizeChange = () => {
  pageNum.value = 1
  loadEmployeePage()
}

const handleExport = () => {
  exportEmployee({
    deptId: searchForm.deptId,
    workStatus: searchForm.workStatus,
    keyword: searchForm.keyword || undefined
  })
  ElMessage.success('导出花名册成功')
}

const handleAdd = () => {
  isEditMode.value = false
  dialogTitle.value = '新增员工'
  Object.assign(formData, {
    id: undefined,
    empCode: '',
    empName: '',
    gender: 1,
    birthday: '',
    idCard: '',
    phone: '',
    email: '',
    workType: '全职',
    deptId: undefined,
    positionId: undefined,
    leaderId: undefined,
    entryDate: '',
    regularDate: '',
    contractStart: '',
    contractEnd: '',
    education: '',
    school: '',
    major: '',
    emergencyContact: '',
    emergencyPhone: '',
    bankAccount: '',
    bankName: '',
    remark: ''
  })
  dialogVisible.value = true
}

const handleEdit = async (row: Employee) => {
  isEditMode.value = true
  dialogTitle.value = '编辑员工'
  try {
    const detail = await getEmployee(row.id!)
    Object.assign(formData, detail)
    dialogVisible.value = true
  } catch (error) {
    console.error('加载员工详情失败:', error)
  }
}

const handleDetail = async (row: Employee) => {
  try {
    currentEmployee.value = await getEmployee(row.id!)
    detailDialogVisible.value = true
  } catch (error) {
    console.error('加载员工详情失败:', error)
  }
}

const handleSave = async () => {
  if (!formRef.value) return
  formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEditMode.value) {
          await updateEmployee(formData)
          ElMessage.success('更新员工成功')
        } else {
          await createEmployee(formData)
          ElMessage.success('新增员工成功')
        }
        dialogVisible.value = false
        loadEmployeePage()
      } catch (error) {
        console.error('保存员工失败:', error)
      }
    }
  })
}

const handleDelete = async (row: Employee) => {
  try {
    await deleteEmployee(row.id!)
    ElMessage.success('删除员工成功')
    loadEmployeePage()
  } catch (error) {
    console.error('删除员工失败:', error)
  }
}

const handleTransfer = (row: Employee) => {
  currentEmployeeId.value = row.id
  Object.assign(transferForm, {
    deptId: row.deptId,
    positionId: row.positionId,
    effectiveDate: '',
    remark: ''
  })
  transferDialogVisible.value = true
}

const handleSaveTransfer = async () => {
  if (!transferFormRef.value || !currentEmployeeId.value) return
  transferFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await transferEmployee(currentEmployeeId.value, transferForm)
        ElMessage.success('调岗成功')
        transferDialogVisible.value = false
        loadEmployeePage()
      } catch (error) {
        console.error('调岗失败:', error)
      }
    }
  })
}

const handleLeave = (row: Employee) => {
  currentEmployeeId.value = row.id
  Object.assign(leaveForm, {
    leaveDate: '',
    reason: ''
  })
  leaveDialogVisible.value = true
}

const handleSaveLeave = async () => {
  if (!leaveFormRef.value || !currentEmployeeId.value) return
  leaveFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await leaveEmployee(currentEmployeeId.value, leaveForm)
        ElMessage.success('离职办理成功')
        leaveDialogVisible.value = false
        loadEmployeePage()
      } catch (error) {
        console.error('离职办理失败:', error)
      }
    }
  })
}

const handleRegular = (row: Employee) => {
  currentEmployeeId.value = row.id
  Object.assign(regularForm, {
    regularDate: ''
  })
  regularDialogVisible.value = true
}

const handleSaveRegular = async () => {
  if (!regularFormRef.value || !currentEmployeeId.value) return
  regularFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await regularEmployee(currentEmployeeId.value, regularForm.regularDate || undefined)
        ElMessage.success('转正成功')
        regularDialogVisible.value = false
        loadEmployeePage()
      } catch (error) {
        console.error('转正失败:', error)
      }
    }
  })
}

onMounted(() => {
  loadDeptTree()
  loadPositionList()
  loadEmployeePage()
})
</script>

<style scoped>
.employee-container {
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
