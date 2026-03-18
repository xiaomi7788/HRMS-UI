<template>
  <div class="overtime-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">加班申请管理</span>
          <el-button type="primary" @click="handleAdd">新增申请</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="申请人">
          <el-input v-model="queryParams.keyword" placeholder="姓名/工号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="申请类型">
          <el-select v-model="queryParams.applyType" placeholder="全部" clearable style="width: 150px">
            <el-option label="请假" :value="0" />
            <el-option label="加班" :value="1" />
            <el-option label="调休" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="审批状态">
          <el-select v-model="queryParams.approvalStatus" placeholder="全部" clearable style="width: 150px">
            <el-option label="待审批" :value="0" />
            <el-option label="通过" :value="1" />
            <el-option label="拒绝" :value="2" />
            <el-option label="撤回" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="employeeName" label="申请人" width="120" />
        <el-table-column label="申请类型" width="100">
          <template #default="{ row }">
            {{ getApplyTypeText(row.applyType) }}
          </template>
        </el-table-column>
        <el-table-column prop="leaveType" label="假期类型" width="120" />
        <el-table-column prop="startTime" label="开始时间" width="180" />
        <el-table-column prop="endTime" label="结束时间" width="180" />
        <el-table-column prop="duration" label="时长（天）" width="100" />
        <el-table-column prop="reason" label="申请原因" min-width="200" show-overflow-tooltip />
        <el-table-column label="审批状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.approvalStatus)">
              {{ getStatusText(row.approvalStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="approverName" label="审批人" width="100" />
        <el-table-column prop="approvalTime" label="审批时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button 
              v-if="row.approvalStatus === 0" 
              link 
              type="primary" 
              size="small" 
              @click="handleApprove(row)"
            >
              审批
            </el-button>
            <el-button link type="info" size="small" @click="handleView(row)">详情</el-button>
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

    <!-- 新增申请对话框 -->
    <el-dialog
      v-model="addDialogVisible"
      title="新增申请"
      width="600px"
      @close="handleAddDialogClose"
    >
      <el-form ref="addFormRef" :model="addForm" :rules="addFormRules" label-width="120px">
        <el-form-item label="申请类型" prop="applyType">
          <el-select v-model="addForm.applyType" placeholder="选择申请类型" style="width: 100%" @change="handleApplyTypeChange">
            <el-option label="请假" :value="0" />
            <el-option label="加班" :value="1" />
            <el-option label="调休" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="addForm.applyType === 0" label="假期类型" prop="leaveType">
          <el-select v-model="addForm.leaveType" placeholder="选择假期类型" style="width: 100%">
            <el-option label="年假" value="年假" />
            <el-option label="事假" value="事假" />
            <el-option label="病假" value="病假" />
            <el-option label="产假" value="产假" />
            <el-option label="调休" value="调休" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            v-model="addForm.startTime"
            type="datetime"
            placeholder="选择开始时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker
            v-model="addForm.endTime"
            type="datetime"
            placeholder="选择结束时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="时长（天）" prop="duration">
          <el-input-number v-model="addForm.duration" :min="0.1" :max="365" :step="0.5" style="width: 100%" />
        </el-form-item>
        <el-form-item label="申请原因" prop="reason">
          <el-input v-model="addForm.reason" type="textarea" :rows="4" placeholder="请输入申请原因" />
        </el-form-item>
        <el-form-item label="附件">
          <el-input v-model="addForm.attachmentUrl" placeholder="附件URL" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveAdd">提交</el-button>
      </template>
    </el-dialog>

    <!-- 审批对话框 -->
    <el-dialog
      v-model="approveDialogVisible"
      title="审批申请"
      width="500px"
      @close="handleApproveDialogClose"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="申请人">{{ currentApply?.employeeName }}</el-descriptions-item>
        <el-descriptions-item label="申请类型">{{ getApplyTypeText(currentApply?.applyType) }}</el-descriptions-item>
        <el-descriptions-item v-if="currentApply?.leaveType" label="假期类型">{{ currentApply?.leaveType }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ currentApply?.startTime }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ currentApply?.endTime }}</el-descriptions-item>
        <el-descriptions-item label="时长">{{ currentApply?.duration }} 天</el-descriptions-item>
        <el-descriptions-item label="申请原因">{{ currentApply?.reason }}</el-descriptions-item>
      </el-descriptions>
      <el-form ref="approveFormRef" :model="approveForm" :rules="approveFormRules" label-width="100px" style="margin-top: 20px">
        <el-form-item label="审批结果" prop="approvalStatus">
          <el-radio-group v-model="approveForm.approvalStatus">
            <el-radio :value="1">通过</el-radio>
            <el-radio :value="2">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审批意见" prop="approvalComment">
          <el-input v-model="approveForm.approvalComment" type="textarea" :rows="4" placeholder="请输入审批意见" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveApprove">确定</el-button>
      </template>
    </el-dialog>

    <!-- 详情对话框 -->
    <el-dialog
      v-model="viewDialogVisible"
      title="申请详情"
      width="500px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="申请人">{{ currentApply?.employeeName }}</el-descriptions-item>
        <el-descriptions-item label="申请类型">{{ getApplyTypeText(currentApply?.applyType) }}</el-descriptions-item>
        <el-descriptions-item v-if="currentApply?.leaveType" label="假期类型">{{ currentApply?.leaveType }}</el-descriptions-item>
        <el-descriptions-item label="开始时间">{{ currentApply?.startTime }}</el-descriptions-item>
        <el-descriptions-item label="结束时间">{{ currentApply?.endTime }}</el-descriptions-item>
        <el-descriptions-item label="时长">{{ currentApply?.duration }} 天</el-descriptions-item>
        <el-descriptions-item label="申请原因">{{ currentApply?.reason }}</el-descriptions-item>
        <el-descriptions-item label="审批状态">
          <el-tag :type="getStatusTagType(currentApply?.approvalStatus)">
            {{ getStatusText(currentApply?.approvalStatus) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item v-if="currentApply?.approverName" label="审批人">{{ currentApply?.approverName }}</el-descriptions-item>
        <el-descriptions-item v-if="currentApply?.approvalTime" label="审批时间">{{ currentApply?.approvalTime }}</el-descriptions-item>
        <el-descriptions-item v-if="currentApply?.approvalComment" label="审批意见">{{ currentApply?.approvalComment }}</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="viewDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { useUserStore } from '@/stores/user'
import {
  getApplyPage,
  createApply,
  approveApply,
  type AttendanceApply,
  type ApplyPageParams
} from '@/api/overtime'

const userStore = useUserStore()

const loading = ref(false)
const tableData = ref<AttendanceApply[]>([])
const total = ref(0)
const addDialogVisible = ref(false)
const approveDialogVisible = ref(false)
const viewDialogVisible = ref(false)
const addFormRef = ref<FormInstance>()
const approveFormRef = ref<FormInstance>()
const currentApply = ref<AttendanceApply | null>(null)

const queryParams = reactive<ApplyPageParams>({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  applyType: undefined,
  approvalStatus: undefined
})

const addForm = reactive<AttendanceApply>({
  applyType: 1,
  leaveType: '',
  startTime: '',
  endTime: '',
  duration: 1,
  reason: '',
  attachmentUrl: ''
})

const approveForm = reactive({
  approvalStatus: 1,
  approvalComment: ''
})

const addFormRules: FormRules = {
  applyType: [{ required: true, message: '请选择申请类型', trigger: 'change' }],
  leaveType: [{ required: true, message: '请选择假期类型', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  duration: [{ required: true, message: '请输入时长', trigger: 'blur' }],
  reason: [{ required: true, message: '请输入申请原因', trigger: 'blur' }]
}

const approveFormRules: FormRules = {
  approvalStatus: [{ required: true, message: '请选择审批结果', trigger: 'change' }]
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getApplyPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载申请列表失败:', error)
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
  queryParams.applyType = undefined
  queryParams.approvalStatus = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  addDialogVisible.value = true
}

const handleApplyTypeChange = (value: number) => {
  if (value !== 0) {
    addForm.leaveType = ''
  }
}

const handleSaveAdd = async () => {
  if (!addFormRef.value) return
  await addFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const submitData = {
          ...addForm,
          employeeId: userStore.userInfo?.employeeId
        }
        await createApply(submitData)
        ElMessage.success('提交成功')
        addDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('提交申请失败:', error)
      }
    }
  })
}

const handleApprove = (row: AttendanceApply) => {
  currentApply.value = row
  approveForm.approvalStatus = 1
  approveForm.approvalComment = ''
  approveDialogVisible.value = true
}

const handleSaveApprove = async () => {
  if (!approveFormRef.value) return
  await approveFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await approveApply(currentApply.value!.id!, approveForm)
        ElMessage.success('审批成功')
        approveDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('审批失败:', error)
      }
    }
  })
}

const handleView = (row: AttendanceApply) => {
  currentApply.value = row
  viewDialogVisible.value = true
}

const handleAddDialogClose = () => {
  addFormRef.value?.resetFields()
  addForm.applyType = 1
}

const handleApproveDialogClose = () => {
  approveFormRef.value?.resetFields()
  currentApply.value = null
}

const getApplyTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    0: '请假',
    1: '加班',
    2: '调休'
  }
  return typeMap[type] || '-'
}

const getStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    0: '待审批',
    1: '通过',
    2: '拒绝',
    3: '撤回'
  }
  return statusMap[status] || '-'
}

const getStatusTagType = (status: number) => {
  const typeMap: Record<number, string> = {
    0: 'warning',
    1: 'success',
    2: 'danger',
    3: 'info'
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
  loadData()
})
</script>

<style scoped>
.overtime-container {
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

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
