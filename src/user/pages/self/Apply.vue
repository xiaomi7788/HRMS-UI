<template>
  <div class="self-apply">
    <el-card class="apply-card">
      <template #header>
        <div class="card-header">
          <span>我的申请</span>
          <el-button type="primary" @click="handleApply">
            <el-icon><Plus /></el-icon>
            新增申请
          </el-button>
        </div>
      </template>

      <!-- 筛选栏 -->
      <el-form :inline="true" :model="queryParams" class="filter-form">
        <el-form-item label="申请类型">
          <el-select v-model="queryParams.applyType" placeholder="全部" clearable>
            <el-option label="全部" :value="undefined" />
            <el-option label="请假" :value="0" />
            <el-option label="加班" :value="1" />
            <el-option label="调休" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="审批状态">
          <el-select v-model="queryParams.approvalStatus" placeholder="全部" clearable>
            <el-option label="全部" :value="undefined" />
            <el-option label="待审批" :value="0" />
            <el-option label="已通过" :value="1" />
            <el-option label="已拒绝" :value="2" />
            <el-option label="已撤回" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">
            <el-icon><Search /></el-icon>
            查询
          </el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 表格 -->
      <el-table :data="applyList" v-loading="loading" stripe>
        <el-table-column prop="applyType" label="申请类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getTypeTagType(row.applyType)">
              {{ getTypeName(row.applyType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="leaveType" label="假期类型" width="100">
          <template #default="{ row }">
            {{ row.leaveType || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="startTime" label="开始时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.startTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="endTime" label="结束时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.endTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="duration" label="时长" width="80">
          <template #default="{ row }">
            {{ row.duration ? row.duration + '天' : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="reason" label="申请原因" min-width="200" show-overflow-tooltip />
        <el-table-column prop="approvalStatus" label="审批状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.approvalStatus)">
              {{ getStatusName(row.approvalStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="approverName" label="审批人" width="100" />
        <el-table-column prop="approvalTime" label="审批时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.approvalTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.approvalStatus === 0"
              type="danger"
              link
              @click="handleWithdraw(row)"
            >
              撤回
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
        @change="handleQuery"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>

    <!-- 新增申请对话框 -->
    <el-dialog v-model="applyDialog" title="新增申请" width="600px">
      <el-form :model="applyForm" label-width="100px" :rules="applyRules" ref="applyFormRef">
        <el-form-item label="申请类型" prop="applyType">
          <el-select v-model="applyForm.applyType">
            <el-option label="请假" :value="0" />
            <el-option label="加班" :value="1" />
            <el-option label="调休" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="假期类型" prop="leaveType" v-if="applyForm.applyType === 0">
          <el-select v-model="applyForm.leaveType">
            <el-option label="年假" value="ANNUAL" />
            <el-option label="事假" value="PERSONAL" />
            <el-option label="病假" value="SICK" />
          </el-select>
        </el-form-item>
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker
            v-model="applyForm.startTime"
            type="datetime"
            placeholder="选择开始时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker
            v-model="applyForm.endTime"
            type="datetime"
            placeholder="选择结束时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="申请原因" prop="reason">
          <el-input
            v-model="applyForm.reason"
            type="textarea"
            :rows="4"
            placeholder="请输入申请原因"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="applyDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitApply">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import {
  getAttendanceApplies,
  submitAttendanceApply,
  withdrawAttendanceApply,
  type AttendanceApply,
  type AttendanceApplyQuery
} from '@/api/self'

const loading = ref(false)
const applyList = ref<AttendanceApply[]>([])
const total = ref(0)
const applyDialog = ref(false)
const applyFormRef = ref<FormInstance>()

const queryParams = reactive<AttendanceApplyQuery>({
  pageNum: 1,
  pageSize: 10
})

const applyForm = reactive<AttendanceApply>({
  applyType: 0,
  startTime: '',
  endTime: '',
  reason: ''
})

const applyRules = {
  applyType: [{ required: true, message: '请选择申请类型', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endTime: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  reason: [{ required: true, message: '请输入申请原因', trigger: 'blur' }]
}

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function getTypeName(type: number) {
  const map: Record<number, string> = {
    0: '请假',
    1: '加班',
    2: '调休',
    3: '出差'
  }
  return map[type] || '未知'
}

function getTypeTagType(type: number) {
  const map: Record<number, string> = {
    0: 'warning',
    1: 'danger',
    2: 'info',
    3: 'primary'
  }
  return map[type] || ''
}

function getStatusName(status: number) {
  const map: Record<number, string> = {
    0: '待审批',
    1: '已通过',
    2: '已拒绝',
    3: '已撤回'
  }
  return map[status] || '未知'
}

function getStatusTagType(status: number) {
  const map: Record<number, string> = {
    0: 'warning',
    1: 'success',
    2: 'danger',
    3: 'info'
  }
  return map[status] || ''
}

async function handleQuery() {
  loading.value = true
  try {
    const result = await getAttendanceApplies(queryParams)
    applyList.value = result.records || []
    total.value = result.total || 0
  } catch (error) {
    ElMessage.error('获取申请列表失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  queryParams.pageNum = 1
  queryParams.applyType = undefined
  queryParams.approvalStatus = undefined
  handleQuery()
}

function handleApply() {
  applyDialog.value = true
  applyForm.applyType = 0
  applyForm.leaveType = ''
  applyForm.startTime = ''
  applyForm.endTime = ''
  applyForm.reason = ''
}

async function handleSubmitApply() {
  if (!applyFormRef.value) return
  await applyFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await submitAttendanceApply(applyForm)
        ElMessage.success('申请提交成功')
        applyDialog.value = false
        handleQuery()
      } catch (error) {
        ElMessage.error('申请提交失败')
      }
    }
  })
}

async function handleWithdraw(row: AttendanceApply) {
  try {
    await ElMessageBox.confirm('确认撤回此申请吗?', '提示', {
      type: 'warning'
    })
    await withdrawAttendanceApply(row.id!)
    ElMessage.success('撤回成功')
    handleQuery()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('撤回失败')
    }
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.self-apply {
  padding: 20px;
}

.apply-card {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-form {
  margin-bottom: 20px;
}
</style>
