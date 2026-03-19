<template>
  <div class="goal-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">绩效目标管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleAdd">新建目标</el-button>
          </div>
        </div>
      </template>

      <!-- 视图切换 -->
      <div class="view-tabs">
        <el-radio-group v-model="activeView" @change="handleViewChange">
          <el-radio-button label="list">列表视图</el-radio-button>
          <el-radio-button label="tree">树形视图</el-radio-button>
        </el-radio-group>
      </div>

      <!-- 搜索表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="绩效方案">
          <el-select
            v-model="queryParams.planId"
            placeholder="全部方案"
            clearable
            filterable
            style="width: 200px"
            @change="handleQuery"
          >
            <el-option
              v-for="plan in planList"
              :key="plan.id"
              :label="plan.planName"
              :value="plan.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="考核周期">
          <el-input
            v-model="queryParams.period"
            placeholder="如: 2026-Q1"
            clearable
            style="width: 150px"
            @keyup.enter="handleQuery"
          />
        </el-form-item>
        <el-form-item label="目标类型">
          <el-select
            v-model="queryParams.objectiveType"
            placeholder="全部类型"
            clearable
            style="width: 150px"
            @change="handleQuery"
          >
            <el-option label="目标(OBJECTIVE)" value="OBJECTIVE" />
            <el-option label="关键结果(KEY_RESULT)" value="KEY_RESULT" />
            <el-option label="KPI指标" value="KPI" />
          </el-select>
        </el-form-item>
        <el-form-item label="员工">
          <el-select
            v-model="queryParams.employeeId"
            placeholder="全部员工"
            clearable
            filterable
            remote
            :remote-method="searchEmployee"
            :loading="employeeLoading"
            style="width: 200px"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.name} (${emp.employeeNo})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 列表视图 -->
      <div v-if="activeView === 'list'">
        <el-table :data="tableData" stripe v-loading="loading" row-key="id">
          <el-table-column prop="title" label="目标标题" min-width="200" show-overflow-tooltip />
          <el-table-column prop="employeeName" label="负责人" width="120">
            <template #default="{ row }">
              <span v-if="row.employeeName">{{ row.employeeName }}</span>
              <span v-else class="text-gray">-</span>
            </template>
          </el-table-column>
          <el-table-column prop="objectiveType" label="目标类型" width="120">
            <template #default="{ row }">
              <el-tag :type="getObjectiveTypeTagType(row.objectiveType)" size="small">
                {{ getObjectiveTypeText(row.objectiveType) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="priority" label="优先级" width="100">
            <template #default="{ row }">
              <el-tag v-if="row.priority" :type="getPriorityTagType(row.priority)" size="small">
                {{ getPriorityText(row.priority) }}
              </el-tag>
              <span v-else class="text-gray">-</span>
            </template>
          </el-table-column>
          <el-table-column prop="progressPercent" label="进度" width="120">
            <template #default="{ row }">
              <div class="progress-cell">
                <el-progress
                  :percentage="row.progressPercent || 0"
                  :status="getProgressStatus(row.progressPercent)"
                  :stroke-width="10"
                  :show-text="false"
                  style="width: 80px; margin-right: 8px"
                />
                <span>{{ row.progressPercent || 0 }}%</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusTagType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="startDate" label="开始日期" width="120">
            <template #default="{ row }">
              {{ formatDate(row.startDate) }}
            </template>
          </el-table-column>
          <el-table-column prop="dueDate" label="截止日期" width="120">
            <template #default="{ row }">
              {{ formatDate(row.dueDate) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
              <el-button link type="success" size="small" @click="handleUpdateProgress(row)">更新进度</el-button>
              <el-button link type="warning" size="small" @click="handleAlign(row)">目标对齐</el-button>
              <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
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
      </div>

      <!-- 树形视图 - 表格形式 -->
      <div v-else class="tree-view-container">
        <div class="tree-controls">
          <el-button type="primary" @click="toggleExpandAll">{{ isExpandAll ? '收起全部' : '展开全部' }}</el-button>
        </div>
        <el-table
          ref="goalTableRef"
          :data="treeData"
          style="width: 100%"
          row-key="id"
          :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
          :default-expand-all="isExpandAll"
          border
        >
          <el-table-column prop="title" label="目标标题" min-width="200" show-overflow-tooltip />
          <el-table-column prop="objectiveType" label="类型" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="getObjectiveTypeTagType(row.objectiveType)" size="small">
                {{ getObjectiveTypeText(row.objectiveType) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="priority" label="优先级" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="getPriorityTagType(row.priority)" size="small">
                {{ getPriorityText(row.priority) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="90" align="center">
            <template #default="{ row }">
              <el-tag :type="getStatusTagType(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="employeeName" label="负责人" width="100" align="center" />
          <el-table-column label="时间范围" width="180">
            <template #default="{ row }">
              {{ formatDate(row.startDate) }} ~ {{ formatDate(row.dueDate) }}
            </template>
          </el-table-column>
          <el-table-column prop="progressPercent" label="进度" width="150" align="center">
            <template #default="{ row }">
              <el-progress 
                :percentage="row.progressPercent || 0" 
                :color="getProgressColor(row.progressPercent)"
                :stroke-width="10"
              />
            </template>
          </el-table-column>
        </el-table>
      </div>
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑绩效目标' : '新建绩效目标'"
      width="700px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
        label-position="right"
      >
        <el-form-item label="目标标题" prop="title">
          <el-input
            v-model="formData.title"
            placeholder="请输入目标标题"
            maxlength="256"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="目标类型" prop="objectiveType">
          <el-select
            v-model="formData.objectiveType"
            placeholder="请选择目标类型"
            style="width: 100%"
          >
            <el-option label="目标(OBJECTIVE)" value="OBJECTIVE" />
            <el-option label="关键结果(KEY_RESULT)" value="KEY_RESULT" />
            <el-option label="KPI指标" value="KPI" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="父目标" prop="parentId">
          <el-select
            v-model="formData.parentId"
            placeholder="选择父目标（留空表示顶级目标）"
            clearable
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="parent in parentObjectiveList"
              :key="parent.id"
              :label="parent.title"
              :value="parent.id"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="负责人" prop="employeeId">
          <el-select
            v-model="formData.employeeId"
            placeholder="请选择负责人"
            filterable
            remote
            :remote-method="searchEmployeeForForm"
            :loading="employeeLoading"
            style="width: 100%"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.name} (${emp.employeeNo})`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="绩效方案" prop="planId">
          <el-select
            v-model="formData.planId"
            placeholder="请选择绩效方案"
            clearable
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="plan in planList"
              :key="plan.id"
              :label="plan.planName"
              :value="plan.id"
            />
          </el-select>
        </el-form-item>
        
        <el-form-item label="考核周期" prop="period">
          <el-input
            v-model="formData.period"
            placeholder="如: 2026-Q1"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="优先级" prop="priority">
          <el-select
            v-model="formData.priority"
            placeholder="请选择优先级"
            style="width: 100%"
          >
            <el-option label="高" value="HIGH" />
            <el-option label="中" value="MEDIUM" />
            <el-option label="低" value="LOW" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="权重" prop="weight">
          <el-input-number
            v-model="formData.weight"
            :min="0"
            :max="100"
            style="width: 100%"
            placeholder="请输入权重(0-100)"
          />
        </el-form-item>
        
        <el-form-item label="目标值" prop="targetValue">
          <el-input-number
            v-model="formData.targetValue"
            :min="0"
            :precision="2"
            style="width: 100%"
            placeholder="请输入目标值"
          />
        </el-form-item>
        
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker
            v-model="formData.startDate"
            type="date"
            placeholder="请选择开始日期"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="截止日期" prop="dueDate">
          <el-date-picker
            v-model="formData.dueDate"
            type="date"
            placeholder="请选择截止日期"
            style="width: 100%"
          />
        </el-form-item>
        
        <el-form-item label="目标描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="4"
            placeholder="请输入目标描述"
            maxlength="1000"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSave">
            {{ isEdit ? '更新' : '创建' }}
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 更新进度对话框 -->
    <el-dialog
      v-model="progressDialogVisible"
      title="更新目标进度"
      width="400px"
    >
      <el-form
        ref="progressFormRef"
        :model="progressForm"
        label-width="100px"
      >
        <el-form-item label="进度百分比" prop="progressPercent">
          <el-input-number
            v-model="progressForm.progressPercent"
            :min="0"
            :max="100"
            :precision="0"
            style="width: 100%"
            placeholder="请输入进度百分比(0-100)"
          />
        </el-form-item>
        
        <el-form-item label="实际值" prop="actualValue">
          <el-input-number
            v-model="progressForm.actualValue"
            :min="0"
            :precision="2"
            style="width: 100%"
            placeholder="请输入实际完成值"
          />
        </el-form-item>
        
        <el-form-item label="状态" prop="status">
          <el-select
            v-model="progressForm.status"
            placeholder="请选择状态"
            style="width: 100%"
          >
            <el-option label="进行中" :value="0" />
            <el-option label="已完成" :value="1" />
            <el-option label="已放弃" :value="2" />
          </el-select>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="progressDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleProgressSave">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 目标对齐对话框 -->
    <el-dialog
      v-model="alignDialogVisible"
      title="目标对齐"
      width="500px"
    >
      <el-form label-width="100px">
        <el-form-item label="对齐到目标">
          <el-select
            v-model="alignForm.alignedObjectiveId"
            placeholder="请选择要对齐的目标"
            filterable
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="candidate in alignCandidates"
              :key="candidate.id"
              :label="`${candidate.title} (${candidate.employeeName})`"
              :value="candidate.id"
            />
          </el-select>
          <div class="form-tips">选择要对齐的上级或公司级目标</div>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="alignDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleAlignSave">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import type Node from 'element-plus/es/components/tree/src/model/node'
import {
  getObjectivePage,
  getObjectiveTree,
  createObjective,
  updateObjective,
  deleteObjective,
  updateProgress,
  alignObjective,
  getAlignCandidates,
  type PerfObjective,
  type ObjectivePageParams,
  type ProgressUpdateParams,
  type AlignParams
} from '@/api/objective'
import { getPlanPage, type PerfPlan, type PlanPageParams } from '@/api/performance'
import { getEmployeePage, type Employee } from '@/api/employee'

const loading = ref(false)
const tableData = ref<PerfObjective[]>([])
const total = ref(0)
const treeData = ref<any[]>([])
const goalTableRef = ref()
const isExpandAll = ref(true)
const activeView = ref('list')
const dialogVisible = ref(false)
const progressDialogVisible = ref(false)
const alignDialogVisible = ref(false)
const formRef = ref<FormInstance>()
const progressFormRef = ref<FormInstance>()
const isEdit = ref(false)
const currentObjectiveId = ref<number>()

// 员工相关
interface EmployeeOption {
  id?: number
  name: string
  employeeNo: string
}
const employeeList = ref<EmployeeOption[]>([])
const employeeLoading = ref(false)

// 绩效方案列表
const planList = ref<PerfPlan[]>([])

// 父目标列表
const parentObjectiveList = ref<PerfObjective[]>([])

// 对齐候选目标
const alignCandidates = ref<PerfObjective[]>([])

// 查询参数
const queryParams = reactive<ObjectivePageParams>({
  pageNum: 1,
  pageSize: 20,
  planId: undefined,
  employeeId: undefined,
  period: undefined,
  objectiveType: undefined
})

// 表单数据
const formData = reactive<PerfObjective>({
  title: '',
  objectiveType: 'OBJECTIVE',
  parentId: undefined,
  employeeId: undefined,
  planId: undefined,
  period: '',
  priority: 'MEDIUM',
  weight: undefined,
  targetValue: undefined,
  actualValue: undefined,
  progressPercent: 0,
  startDate: undefined,
  dueDate: undefined,
  description: '',
  status: 0
})

// 进度表单
const progressForm = reactive<ProgressUpdateParams>({
  progressPercent: undefined,
  actualValue: undefined,
  status: undefined
})

// 对齐表单
const alignForm = reactive<AlignParams>({
  alignedObjectiveId: undefined
})

// 表单验证规则
const formRules: FormRules = {
  title: [{ required: true, message: '请输入目标标题', trigger: 'blur' }],
  objectiveType: [{ required: true, message: '请选择目标类型', trigger: 'change' }],
  employeeId: [{ required: true, message: '请选择负责人', trigger: 'change' }],
  planId: [{ required: true, message: '请选择绩效方案', trigger: 'change' }],
  period: [{ required: true, message: '请输入考核周期', trigger: 'blur' }],
  startDate: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
  dueDate: [{ required: true, message: '请选择截止日期', trigger: 'change' }]
}

// 树形配置
const treeProps = {
  label: 'title',
  children: 'children'
}

// 加载数据
const loadData = async () => {
  if (activeView.value === 'list') {
    await loadListData()
  } else {
    await loadTreeData()
  }
}

// 加载列表数据
const loadListData = async () => {
  loading.value = true
  try {
    const data = await getObjectivePage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载绩效目标失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载树形数据
const loadTreeData = async () => {
  loading.value = true
  try {
    const data = await getObjectiveTree({
      planId: queryParams.planId,
      employeeId: queryParams.employeeId,
      period: queryParams.period,
      objectiveType: queryParams.objectiveType
    })
    treeData.value = data
  } catch (error) {
    console.error('加载目标树失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载绩效方案
const loadPlanList = async () => {
  try {
    const data = await getPlanPage({ pageNum: 1, pageSize: 100 })
    planList.value = data.records
  } catch (error) {
    console.error('加载绩效方案失败:', error)
  }
}

// 搜索员工
const searchEmployee = async (query?: string) => {
  if (!query || query.trim() === '') {
    employeeList.value = []
    return
  }
  
  employeeLoading.value = true
  try {
    const data = await getEmployeePage({
      pageNum: 1,
      pageSize: 20,
      keyword: query
    })
    employeeList.value = data.records.map((emp: Employee) => ({
      id: emp.id,
      name: emp.empName || '',
      employeeNo: emp.empCode || ''
    }))
  } catch (error) {
    console.error('搜索员工失败:', error)
    employeeList.value = []
  } finally {
    employeeLoading.value = false
  }
}

// 表单搜索员工
const searchEmployeeForForm = async (query?: string) => {
  await searchEmployee(query)
}

// 查询
const handleQuery = () => {
  if (activeView.value === 'list') {
    queryParams.pageNum = 1
  }
  loadData()
}

// 重置
const handleReset = () => {
  queryParams.planId = undefined
  queryParams.employeeId = undefined
  queryParams.period = undefined
  queryParams.objectiveType = undefined
  if (activeView.value === 'list') {
    queryParams.pageNum = 1
  }
  loadData()
}

// 视图切换
const handleViewChange = () => {
  loadData()
}

// 新增记录
const handleAdd = async () => {
  isEdit.value = false
  currentObjectiveId.value = undefined
  
  // 重置表单
  Object.keys(formData).forEach(key => {
    if (key === 'objectiveType') {
      formData.objectiveType = 'OBJECTIVE'
    } else if (key === 'priority') {
      formData.priority = 'MEDIUM'
    } else if (key === 'progressPercent') {
      formData.progressPercent = 0
    } else if (key === 'status') {
      formData.status = 0
    } else {
      ;(formData as any)[key] = undefined
    }
  })
  formData.title = ''
  formData.description = ''
  
  // 加载父目标列表（只查询顶级目标OBJECTIVE）
  try {
    const listData = await getObjectivePage({
      pageNum: 1,
      pageSize: 100,
      objectiveType: 'OBJECTIVE',
      parentOnly: true
    })
    // 编辑时排除当前目标，避免选择自己作为父目标
    if (isEdit.value && currentObjectiveId.value) {
      parentObjectiveList.value = listData.records.filter((obj: PerfObjective) => obj.id !== currentObjectiveId.value)
    } else {
      parentObjectiveList.value = listData.records
    }
  } catch (error) {
    console.error('加载父目标列表失败:', error)
    parentObjectiveList.value = []
  }
  
  dialogVisible.value = true
}

// 解析日期字符串为 Date 对象（用于编辑回显）
const parseDateFromBackend = (dateStr: string | undefined): string | undefined => {
  if (!dateStr) return undefined
  // 后端返回的格式是 yyyy-MM-dd，直接返回即可，el-date-picker 会识别
  return dateStr
}

// 编辑记录
const handleEdit = async (row: PerfObjective) => {
  isEdit.value = true
  currentObjectiveId.value = row.id
  
  // 加载父目标列表（只查询顶级目标OBJECTIVE）
  try {
    const listData = await getObjectivePage({
      pageNum: 1,
      pageSize: 100,
      objectiveType: 'OBJECTIVE',
      parentOnly: true
    })
    // 排除当前目标，避免选择自己作为父目标
    parentObjectiveList.value = listData.records.filter((obj: PerfObjective) => obj.id !== row.id)
  } catch (error) {
    console.error('加载父目标列表失败:', error)
    parentObjectiveList.value = []
  }
  
  // 复制数据并处理日期格式
  Object.assign(formData, {
    ...row,
    startDate: parseDateFromBackend(row.startDate),
    dueDate: parseDateFromBackend(row.dueDate)
  })
  dialogVisible.value = true
}

// 格式化日期为 yyyy-MM-dd 格式
const formatDateForSubmit = (date: any): string | undefined => {
  if (!date) return undefined
  if (typeof date === 'string') {
    // 如果已经是字符串，取前10位
    return date.substring(0, 10)
  }
  // 如果是 Date 对象，格式化
  const d = new Date(date)
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

// 保存记录
const handleSave = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        // 复制表单数据并格式化日期
        const submitData = { ...formData }
        submitData.startDate = formatDateForSubmit(submitData.startDate)
        submitData.dueDate = formatDateForSubmit(submitData.dueDate)
        
        if (isEdit.value && currentObjectiveId.value) {
          submitData.id = currentObjectiveId.value
          await updateObjective(submitData)
          ElMessage.success('更新成功')
        } else {
          await createObjective(submitData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('保存绩效目标失败:', error)
      }
    }
  })
}

// 更新进度
const handleUpdateProgress = (row: PerfObjective) => {
  currentObjectiveId.value = row.id
  progressForm.progressPercent = row.progressPercent || 0
  progressForm.actualValue = row.actualValue
  progressForm.status = row.status
  progressDialogVisible.value = true
}

// 保存进度
const handleProgressSave = async () => {
  if (!currentObjectiveId.value) return
  
  try {
    await updateProgress(currentObjectiveId.value, progressForm)
    ElMessage.success('更新进度成功')
    progressDialogVisible.value = false
    loadData()
  } catch (error) {
    console.error('更新进度失败:', error)
  }
}

// 目标对齐
const handleAlign = async (row: PerfObjective) => {
  currentObjectiveId.value = row.id
  alignForm.alignedObjectiveId = row.alignedObjectiveId || undefined
  
  // 加载对齐候选目标
  try {
    const data = await getAlignCandidates({
      period: row.period,
      excludeEmployeeId: row.employeeId
    })
    alignCandidates.value = data
  } catch (error) {
    console.error('加载对齐候选目标失败:', error)
  }
  
  alignDialogVisible.value = true
}

// 保存对齐
const handleAlignSave = async () => {
  if (!currentObjectiveId.value) return
  
  try {
    await alignObjective(currentObjectiveId.value, alignForm)
    ElMessage.success('目标对齐成功')
    alignDialogVisible.value = false
    loadData()
  } catch (error) {
    console.error('目标对齐失败:', error)
  }
}

// 删除记录
const handleDelete = (row: PerfObjective) => {
  ElMessageBox.confirm('确认删除该绩效目标吗？删除后将无法恢复', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteObjective(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除绩效目标失败:', error)
    }
  })
}

// 分页处理
const handleSizeChange = () => {
  loadListData()
}

const handleCurrentChange = () => {
  loadListData()
}

// 对话框关闭处理
const handleDialogClose = () => {
  formRef.value?.resetFields()
  currentObjectiveId.value = undefined
}

// 格式化日期
const formatDate = (date?: string) => {
  if (!date) return '-'
  return date.substring(0, 10)
}

// 目标类型标签样式
const getObjectiveTypeTagType = (type?: string) => {
  const typeMap: Record<string, string> = {
    'OBJECTIVE': 'primary',
    'KEY_RESULT': 'success',
    'KPI': 'warning'
  }
  return typeMap[type || ''] || ''
}

// 目标类型文本
const getObjectiveTypeText = (type?: string) => {
  const typeMap: Record<string, string> = {
    'OBJECTIVE': '目标',
    'KEY_RESULT': '关键结果',
    'KPI': 'KPI'
  }
  return typeMap[type || ''] || type || '-'
}

// 优先级标签样式
const getPriorityTagType = (priority?: string) => {
  const typeMap: Record<string, string> = {
    'HIGH': 'danger',
    'MEDIUM': 'warning',
    'LOW': 'info'
  }
  return typeMap[priority || ''] || ''
}

// 优先级文本
const getPriorityText = (priority?: string) => {
  const typeMap: Record<string, string> = {
    'HIGH': '高',
    'MEDIUM': '中',
    'LOW': '低'
  }
  return typeMap[priority || ''] || priority || '-'
}

// 状态标签样式
const getStatusTagType = (status?: number) => {
  const typeMap: Record<number, string> = {
    0: 'primary',
    1: 'success',
    2: 'info'
  }
  return typeMap[status || 0] || ''
}

// 状态文本
const getStatusText = (status?: number) => {
  const typeMap: Record<number, string> = {
    0: '进行中',
    1: '已完成',
    2: '已放弃'
  }
  return typeMap[status || 0] || '-'
}

// 进度状态
const getProgressStatus = (progress?: number) => {
  if (!progress) return 'exception'
  if (progress >= 100) return 'success'
  if (progress >= 80) return 'warning'
  return 'exception'
}

// 进度颜色
const getProgressColor = (progress?: number) => {
  if (!progress || progress === 0) return '#909399'
  if (progress >= 100) return '#67c23a'
  if (progress >= 50) return '#409eff'
  return '#e6a23c'
}

// 表格展开/收起
const toggleExpandAll = () => {
  isExpandAll.value = !isExpandAll.value
  const rows = goalTableRef.value?.store.states.data.value || []
  rows.forEach((row: any) => {
    goalTableRef.value?.toggleRowExpansion(row, isExpandAll.value)
  })
}

// 初始化加载
onMounted(() => {
  loadPlanList()
  loadData()
})
</script>

<style scoped>
.goal-container {
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

.header-actions {
  display: flex;
  gap: 10px;
}

.view-tabs {
  margin-bottom: 20px;
}

.search-form {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.tree-view-container {
  margin-top: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e7ed 100%);
  border-radius: 8px;
  padding: 20px;
}

.tree-controls {
  margin-bottom: 16px;
  display: flex;
  gap: 10px;
}

.tree-controls .el-button {
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 100%);
  border: none;
  color: #fff;
  transition: all 0.3s ease;
}

.tree-controls .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

/* 树节点容器 */
:deep(.el-tree-node__content) {
  height: auto !important;
  padding: 12px 8px;
  margin: 4px 0;
  border-radius: 8px;
  background: #fff;
  border: 1px solid #ebeef5;
  transition: all 0.3s ease;
}

:deep(.el-tree-node__content:hover) {
  background: linear-gradient(135deg, #ecf5ff 0%, #f0f9ff 100%);
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(64, 158, 255, 0.15);
}

:deep(.el-tree-node__content > .el-tree-node__expand-icon) {
  padding: 6px;
  color: #409eff;
}

:deep(.el-tree-node__content > .el-tree-node__expand-icon.is-leaf) {
  color: transparent;
}

/* 树节点单行布局样式 */
.tree-node-row {
  display: flex;
  align-items: center;
  width: 100%;
  gap: 12px;
  flex-wrap: nowrap;
}

.tree-node-label {
  font-weight: 600;
  font-size: 14px;
  min-width: 150px;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.tree-node-tag {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
  border: 1px solid;
  background: transparent;
  white-space: nowrap;
}

.tree-node-text {
  font-size: 12px;
  color: #606266;
  white-space: nowrap;
}

.tree-node-progress {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 120px;
}

.progress-track {
  flex: 1;
  height: 6px;
  background: #ebeef5;
  border-radius: 3px;
  overflow: hidden;
}

.progress-value {
  height: 100%;
  border-radius: 3px;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 11px;
  font-weight: 600;
  min-width: 30px;
}


/* 操作按钮 */
.tree-node-actions {
  display: flex;
  gap: 4px;
  margin-left: auto;
  opacity: 0;
  transition: opacity 0.3s ease;
}

:deep(.el-tree-node__content:hover) .tree-node-actions {
  opacity: 1;
}

:deep(.el-tree-node__content:hover) .tree-node-actions {
  opacity: 1;
}

.progress-cell {
  display: flex;
  align-items: center;
}

.text-gray {
  color: #c0c4cc;
}

.form-tips {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.ml-2 {
  margin-left: 8px;
}
</style>