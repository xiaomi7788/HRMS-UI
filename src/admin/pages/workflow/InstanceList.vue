<template>
  <div class="workflow-instance">
    <el-card class="instance-card">
      <template #header>
        <div class="card-header">
          <span>流程实例</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleStart">
              <el-icon><Plus /></el-icon>
              发起流程
            </el-button>
          </div>
        </div>
      </template>

      <!-- 统计卡片 -->
      <div class="statistics-cards">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-value">{{ statistics.total }}</div>
            <div class="stat-label">总数</div>
          </div>
        </el-card>
        <el-card class="stat-card warning" shadow="hover">
          <div class="stat-content">
            <div class="stat-value">{{ statistics.pending }}</div>
            <div class="stat-label">审批中</div>
          </div>
        </el-card>
        <el-card class="stat-card success" shadow="hover">
          <div class="stat-content">
            <div class="stat-value">{{ statistics.approved }}</div>
            <div class="stat-label">已通过</div>
          </div>
        </el-card>
        <el-card class="stat-card danger" shadow="hover">
          <div class="stat-content">
            <div class="stat-value">{{ statistics.rejected }}</div>
            <div class="stat-label">已拒绝</div>
          </div>
        </el-card>
        <el-card class="stat-card info" shadow="hover">
          <div class="stat-content">
            <div class="stat-value">{{ statistics.withdrawn }}</div>
            <div class="stat-label">已撤回</div>
          </div>
        </el-card>
      </div>

      <!-- 筛选栏 -->
      <el-form :inline="true" :model="queryParams" class="filter-form">
        <el-form-item label="业务类型">
          <el-select v-model="queryParams.businessType" placeholder="全部" clearable>
            <el-option label="全部" :value="undefined" />
            <el-option
              v-for="item in BUSINESS_TYPE_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="流程状态">
          <el-select v-model="queryParams.processStatus" placeholder="全部" clearable>
            <el-option label="全部" :value="undefined" />
            <el-option
              v-for="item in PROCESS_STATUS_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="发起人">
          <el-input v-model="queryParams.initiatorName" placeholder="请输入发起人姓名" clearable />
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
      <el-table :data="instanceList" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="processName" label="流程名称" min-width="150" />
        <el-table-column prop="businessType" label="业务类型" width="120">
          <template #default="{ row }">
            {{ getBusinessTypeName(row.businessType) }}
          </template>
        </el-table-column>
        <el-table-column prop="businessTitle" label="业务摘要" min-width="200" show-overflow-tooltip />
        <el-table-column prop="initiatorName" label="发起人" width="100" />
        <el-table-column prop="currentNodeName" label="当前节点" width="120" />
        <el-table-column prop="processStatus" label="流程状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getProcessStatusTagType(row.processStatus)">
              {{ getProcessStatusName(row.processStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="finishTime" label="完成时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.finishTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看详情</el-button>
            <el-button
              v-if="row.processStatus === 0"
              type="success"
              link
              @click="handleApprove(row)"
            >
              审批
            </el-button>
            <el-button
              v-if="row.processStatus === 0"
              type="warning"
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

    <!-- 发起流程对话框 -->
    <el-dialog v-model="startDialogVisible" title="发起流程" width="600px">
      <el-form :model="startForm" :rules="startFormRules" ref="startFormRef" label-width="120px">
        <el-form-item label="业务类型" prop="businessType">
          <el-select v-model="startForm.businessType" placeholder="请选择业务类型" style="width: 100%">
            <el-option
              v-for="item in BUSINESS_TYPE_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="业务单据ID" prop="businessId">
          <el-input-number v-model="startForm.businessId" :min="1" style="width: 100%" />
        </el-form-item>
        <el-form-item label="业务摘要" prop="businessTitle">
          <el-input v-model="startForm.businessTitle" placeholder="请输入业务摘要" />
        </el-form-item>
        <el-form-item label="发起人ID" prop="initiatorId">
          <el-input-number v-model="startForm.initiatorId" :min="1" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="startDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleStartSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 审批对话框 -->
    <el-dialog v-model="approveDialogVisible" title="审批操作" width="500px">
      <el-form :model="approveForm" :rules="approveFormRules" ref="approveFormRef" label-width="100px">
        <el-form-item label="审批结果" prop="approveResult">
          <el-radio-group v-model="approveForm.approveResult">
            <el-radio value="APPROVE">通过</el-radio>
            <el-radio value="REJECT">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审批意见" prop="comment">
          <el-input
            v-model="approveForm.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入审批意见"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleApproveSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 流程详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="流程详情" width="800px">
      <el-descriptions v-if="currentInstance" :column="2" border>
        <el-descriptions-item label="流程名称">{{ currentInstance.processName }}</el-descriptions-item>
        <el-descriptions-item label="业务类型">
          {{ getBusinessTypeName(currentInstance.businessType) }}
        </el-descriptions-item>
        <el-descriptions-item label="业务摘要">{{ currentInstance.businessTitle }}</el-descriptions-item>
        <el-descriptions-item label="发起人">{{ currentInstance.initiatorName }}</el-descriptions-item>
        <el-descriptions-item label="当前节点">{{ currentInstance.currentNodeName }}</el-descriptions-item>
        <el-descriptions-item label="流程状态">
          <el-tag :type="getProcessStatusTagType(currentInstance.processStatus)">
            {{ getProcessStatusName(currentInstance.processStatus) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ formatDateTime(currentInstance.createTime) }}</el-descriptions-item>
        <el-descriptions-item label="完成时间">{{ formatDateTime(currentInstance.finishTime) }}</el-descriptions-item>
        <el-descriptions-item label="最终意见" :span="2">{{ currentInstance.finalComment }}</el-descriptions-item>
      </el-descriptions>

      <el-divider content-position="left">审批记录</el-divider>

      <el-timeline v-if="nodeRecords.length > 0">
        <el-timeline-item
          v-for="record in nodeRecords"
          :key="record.id"
          :timestamp="formatDateTime(record.approveTime)"
          :type="getNodeStatusType(record.nodeStatus)"
        >
          <div class="timeline-content">
            <div class="timeline-title">
              <strong>{{ record.nodeName }}</strong>
              <el-tag :type="getNodeStatusTagType(record.nodeStatus)" size="small">
                {{ getNodeStatusName(record.nodeStatus) }}
              </el-tag>
            </div>
            <div class="timeline-info">审批人：{{ record.approverName || record.approverRole }}</div>
            <div v-if="record.comment" class="timeline-comment">审批意见：{{ record.comment }}</div>
          </div>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-else description="暂无审批记录" />
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import {
  getProcessInstancePage,
  startProcessInstance,
  getNodeRecords,
  approveInstance,
  withdrawInstance,
  getProcessStatistics,
  type ProcessInstance,
  type ProcessInstancePageQuery,
  type NodeRecord,
  ProcessStatus,
  NodeStatus,
  BUSINESS_TYPE_OPTIONS,
  PROCESS_STATUS_OPTIONS
} from '@/api/workflow'

const loading = ref(false)
const instanceList = ref<ProcessInstance[]>([])
const total = ref(0)
const statistics = ref({
  total: 0,
  pending: 0,
  approved: 0,
  rejected: 0,
  withdrawn: 0
})

const startDialogVisible = ref(false)
const approveDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const startFormRef = ref<FormInstance>()
const approveFormRef = ref<FormInstance>()

const currentInstance = ref<ProcessInstance | null>(null)
const currentNodeId = ref<number | null>(null)
const nodeRecords = ref<NodeRecord[]>([])

const queryParams = reactive<ProcessInstancePageQuery>({
  pageNum: 1,
  pageSize: 10
})

const startForm = reactive({
  businessType: '',
  businessId: 0,
  businessTitle: '',
  initiatorId: 0
})

const startFormRules = {
  businessType: [{ required: true, message: '请选择业务类型', trigger: 'change' }],
  businessId: [{ required: true, message: '请输入业务单据ID', trigger: 'blur' }],
  businessTitle: [{ required: true, message: '请输入业务摘要', trigger: 'blur' }],
  initiatorId: [{ required: true, message: '请输入发起人ID', trigger: 'blur' }]
}

const approveForm = reactive({
  approveResult: 'APPROVE' as 'APPROVE' | 'REJECT',
  comment: ''
})

const approveFormRules = {
  approveResult: [{ required: true, message: '请选择审批结果', trigger: 'change' }]
}

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function getBusinessTypeName(type: string) {
  const option = BUSINESS_TYPE_OPTIONS.find(item => item.value === type)
  return option?.label || type
}

function getProcessStatusName(status: number) {
  const option = PROCESS_STATUS_OPTIONS.find(item => item.value === status)
  return option?.label || '未知'
}

function getProcessStatusTagType(status: number) {
  const option = PROCESS_STATUS_OPTIONS.find(item => item.value === status)
  return (option as any)?.type || ''
}

function getNodeStatusName(status: number) {
  const map: Record<number, string> = {
    0: '待审批',
    1: '已通过',
    2: '已拒绝',
    3: '跳过',
    4: '已撤回'
  }
  return map[status] || '未知'
}

function getNodeStatusTagType(status: number) {
  const map: Record<number, string> = {
    0: 'warning',
    1: 'success',
    2: 'danger',
    3: 'info',
    4: 'info'
  }
  return map[status] || ''
}

function getNodeStatusType(status: number) {
  const map: Record<number, any> = {
    0: 'primary',
    1: 'success',
    2: 'danger',
    3: 'info',
    4: 'info'
  }
  return map[status]
}

async function handleQuery() {
  loading.value = true
  try {
    const [instanceResult, statsResult] = await Promise.all([
      getProcessInstancePage(queryParams),
      getProcessStatistics()
    ])
    instanceList.value = instanceResult.records || []
    total.value = Number(instanceResult.total || 0)
    statistics.value = statsResult || {
      total: 0,
      pending: 0,
      approved: 0,
      rejected: 0,
      withdrawn: 0
    }
  } catch (error) {
    ElMessage.error('获取流程实例列表失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  queryParams.pageNum = 1
  queryParams.businessType = ''
  queryParams.processStatus = undefined
  queryParams.initiatorName = ''
  handleQuery()
}

function handleStart() {
  Object.assign(startForm, {
    businessType: '',
    businessId: 0,
    businessTitle: '',
    initiatorId: 0
  })
  startDialogVisible.value = true
}

async function handleStartSubmit() {
  if (!startFormRef.value) return
  await startFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await startProcessInstance(startForm)
        ElMessage.success('流程发起成功')
        startDialogVisible.value = false
        handleQuery()
      } catch (error) {
        ElMessage.error('流程发起失败')
      }
    }
  })
}

async function handleView(row: ProcessInstance) {
  currentInstance.value = row
  try {
    const records = await getNodeRecords(row.id)
    nodeRecords.value = records || []
  } catch (error) {
    ElMessage.error('获取审批记录失败')
  }
  detailDialogVisible.value = true
}

function handleApprove(row: ProcessInstance) {
  currentNodeId.value = row.id
  Object.assign(approveForm, {
    approveResult: 'APPROVE',
    comment: ''
  })
  approveDialogVisible.value = true
}

async function handleApproveSubmit() {
  if (!approveFormRef.value || !currentNodeId.value) return
  await approveFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await approveInstance(currentNodeId.value, approveForm)
        ElMessage.success('审批成功')
        approveDialogVisible.value = false
        handleQuery()
      } catch (error) {
        ElMessage.error('审批失败')
      }
    }
  })
}

async function handleWithdraw(row: ProcessInstance) {
  try {
    await ElMessageBox.confirm('确认撤回此流程吗?', '提示', {
      type: 'warning'
    })
    await withdrawInstance(row.id)
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
.workflow-instance {
  padding: 20px;
}

.instance-card {
  max-width: 1600px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.statistics-cards {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  text-align: center;
  padding: 10px;
}

.stat-card.warning {
  border-color: #e6a23c;
}

.stat-card.success {
  border-color: #67c23a;
}

.stat-card.danger {
  border-color: #f56c6c;
}

.stat-card.info {
  border-color: #909399;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  margin-bottom: 8px;
}

.stat-label {
  color: #606266;
  font-size: 14px;
}

.filter-form {
  margin-bottom: 20px;
}

.timeline-content {
  padding: 10px;
}

.timeline-title {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.timeline-info {
  color: #606266;
  font-size: 14px;
  margin-bottom: 5px;
}

.timeline-comment {
  color: #909399;
  font-size: 13px;
  padding: 8px;
  background: #f5f7fa;
  border-radius: 4px;
}
</style>
