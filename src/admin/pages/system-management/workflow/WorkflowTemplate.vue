<template>
  <div class="workflow-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>审批流程模板</span>
        </div>
      </template>

      <div class="search-filter-section">
        <div class="business-type-tabs">
          <el-radio-group v-model="businessType" @change="loadApprovalPage">
            <el-radio-button value="">全部</el-radio-button>
            <el-radio-button value="LEAVE">请假审批</el-radio-button>
            <el-radio-button value="OVERTIME">加班申请审批</el-radio-button>
            <el-radio-button value="TRANSFER">调岗申请审批</el-radio-button>
            <el-radio-button value="SALARY_ADJUST">薪酬调整审批</el-radio-button>
            <el-radio-button value="CUSTOM">自定义</el-radio-button>
          </el-radio-group>
        </div>
        <el-input
          v-model="processName"
          placeholder="流程名称"
          clearable
          style="width: 200px; margin-left: 10px;"
          @clear="loadApprovalPage"
          @keyup.enter="loadApprovalPage"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="success" @click="handleAddProcess" style="margin-left: 10px;">+ 新增流程</el-button>
      </div>

      <!-- 流程卡片列表 -->
      <div class="process-cards">
        <div v-for="process in groupedProcessList" :key="`${process.processName}-${process.businessType}`" class="process-card">
          <div class="process-card-header">
            <div class="process-title">
              <h3>{{ process.processName }}</h3>
              <el-tag size="small" type="info">{{ getBusinessTypeText(process.businessType) }}</el-tag>
            </div>
            <div class="process-actions">
              <el-button size="small" @click="handleAddNode(process)">+ 添加节点</el-button>
              <el-button size="small" @click="handleEditProcess(process)">编辑</el-button>
              <el-popconfirm title="确定要删除该流程吗?" @confirm="handleDeleteProcess(process)">
                <template #reference>
                  <el-button size="small" type="danger">删除</el-button>
                </template>
              </el-popconfirm>
            </div>
          </div>

          <div v-if="process.description" class="process-description">
            {{ process.description }}
          </div>

          <!-- 流程节点 -->
          <div class="flow-nodes">
            <div class="flow-start">
              <div class="circle start">开始</div>
            </div>

            <div v-for="(node, index) in process.nodes" :key="node.id" class="flow-node-item">
              <div class="flow-line" v-if="index > 0"></div>

              <div class="node-box" :class="{ disabled: node.enabled === 0 }">
                <div class="node-header">
                  <span class="node-order">第{{ node.nodeOrder }}步</span>
                  <el-tag size="small" :type="getNodeTypeTag(node.approverType)">
                    {{ getApproverTypeText(node.approverType) }}
                  </el-tag>
                  <el-tag size="small" :type="node.actionType === 'NOTIFY' ? 'warning' : 'success'">
                    {{ getActionTypeText(node.actionType) }}
                  </el-tag>
                  <el-tag v-if="node.enabled === 0" type="danger" size="small">禁用</el-tag>
                </div>
                <div class="node-body">
                  <div class="node-name">{{ node.nodeName }}</div>
                  <div class="node-approver">
                    <el-icon><User /></el-icon>
                    <span>{{ node.approverType === 0 ? node.approverRole : (node.approverType === 1 ? `用户ID: ${node.approverIds}` : (node.approverType === 2 ? '上级' : '部门负责人')) }}</span>
                  </div>
                </div>
                <div class="node-actions">
                  <el-button size="small" link type="primary" @click="handleEditNode(node)">编辑</el-button>
                  <el-button size="small" link type="danger" @click="handleDeleteNode(node)">删除</el-button>
                </div>
              </div>

              <div class="flow-line-arrow" v-if="index < process.nodes.length - 1">
                <el-icon><ArrowDown /></el-icon>
              </div>
            </div>

            <div v-if="process.nodes.length === 0" class="empty-nodes">
              <el-empty description="暂无审批节点" :image-size="80" />
            </div>

            <div class="flow-end" v-if="process.nodes.length > 0">
              <div class="circle end">结束</div>
            </div>
          </div>

          <div class="process-footer">
            <span class="create-time">创建时间: {{ process.createTime }}</span>
          </div>
        </div>
      </div>

      <div v-if="groupedProcessList.length === 0" class="empty-process">
        <el-empty description="暂无流程数据" />
      </div>
    </el-card>

    <!-- 新增/编辑流程对话框 -->
    <el-dialog
      v-model="processDialogVisible"
      :title="processDialogTitle"
      width="500px"
    >
      <el-form
        ref="processFormRef"
        :model="currentProcess"
        :rules="processRules"
        label-width="100px"
      >
        <el-form-item label="流程名称" prop="processName">
          <el-input v-model="currentProcess.processName" placeholder="如：请假审批流程" />
        </el-form-item>
        <el-form-item label="业务类型" prop="businessType">
          <el-select v-model="currentProcess.businessType" placeholder="请选择业务类型" style="width: 100%;">
            <el-option value="LEAVE" label="请假" />
            <el-option value="OVERTIME" label="加班" />
            <el-option value="TRANSFER" label="调岗" />
            <el-option value="SALARY_ADJUST" label="调薪" />
            <el-option value="CUSTOM" label="自定义" />
          </el-select>
        </el-form-item>
        <el-form-item label="流程描述">
          <el-input v-model="currentProcess.description" type="textarea" :rows="3" placeholder="请输入流程描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="processDialogVisible = false">取消</el-button>
          <el-button v-if="isEditMode" type="primary" @click="handleUpdateProcess">更新流程</el-button>
          <el-button v-else type="primary" @click="handleSaveProcess">下一步:添加节点</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 新增/编辑审批节点对话框 -->
    <el-dialog
      v-model="nodeDialogVisible"
      :title="nodeDialogTitle"
      width="500px"
    >
      <el-form
        ref="nodeFormRef"
        :model="currentNode"
        :rules="nodeRules"
        label-width="120px"
      >
        <el-form-item label="流程名称">
          <el-input v-model="currentNode.processName" disabled />
        </el-form-item>
        <el-form-item label="业务类型">
          <el-select v-model="currentNode.businessType" disabled style="width: 100%;">
            <el-option value="LEAVE" label="请假" />
            <el-option value="OVERTIME" label="加班" />
            <el-option value="TRANSFER" label="调岗" />
            <el-option value="SALARY_ADJUST" label="调薪" />
            <el-option value="CUSTOM" label="自定义" />
          </el-select>
        </el-form-item>
        <el-form-item label="节点序号" prop="nodeOrder">
          <el-input-number v-model="currentNode.nodeOrder" :min="1" :max="100" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="节点名称" prop="nodeName">
          <el-input v-model="currentNode.nodeName" placeholder="如：直属上级审批" />
        </el-form-item>
        <el-form-item label="审批人类型" prop="approverType">
          <el-select v-model="currentNode.approverType" placeholder="请选择审批人类型" style="width: 100%;">
            <el-option :value="0" label="角色" />
            <el-option :value="1" label="指定用户" />
            <el-option :value="2" label="上级" />
            <el-option :value="3" label="部门负责人" />
          </el-select>
        </el-form-item>
        <el-form-item label="审批人角色" prop="approverRole" v-if="currentNode.approverType === 0">
          <el-input v-model="currentNode.approverRole" placeholder="如：ROLE_MANAGER" />
        </el-form-item>
        <el-form-item label="审批人ID" prop="approverIds" v-if="currentNode.approverType === 1">
          <el-input v-model="currentNode.approverIds" placeholder="多个用户ID用逗号分隔，如：1,2,3" />
        </el-form-item>
        <el-form-item label="审批操作" prop="actionType">
          <el-radio-group v-model="currentNode.actionType">
            <el-radio value="APPROVE_REJECT">审批通过/驳回</el-radio>
            <el-radio value="NOTIFY">仅通知</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态" prop="enabled">
          <el-radio-group v-model="currentNode.enabled">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="nodeDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSaveNode">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { ArrowDown, User, Search } from '@element-plus/icons-vue'
import {
  getApprovalPage,
  createApproval,
  updateApproval,
  deleteApproval,
  type ApprovalTemplate,
  type PageResult
} from '@/api/approval'

interface ProcessGroup {
  processName: string
  businessType: string
  description: string
  nodes: ApprovalTemplate[]
  createTime: string
}

const approvalList = ref<ApprovalTemplate[]>([])
const processName = ref('')
const businessType = ref('')
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const processDialogVisible = ref(false)
const processDialogTitle = ref('新增流程')
const isEditMode = ref(false)
const editingProcess = ref<ProcessGroup | null>(null)
const currentProcess = reactive({
  processName: '',
  businessType: '',
  description: ''
})

const nodeDialogVisible = ref(false)
const nodeDialogTitle = ref('')
const currentNode = reactive<ApprovalTemplate>({
  id: undefined,
  processName: '',
  businessType: '',
  description: '',
  nodeOrder: 1,
  nodeName: '',
  approverType: 0,
  approverRole: '',
  approverIds: '',
  actionType: 'APPROVE_REJECT',
  enabled: 1
})

const processFormRef = ref<FormInstance>()
const nodeFormRef = ref<FormInstance>()

const processRules: FormRules = {
  processName: [
    { required: true, message: '请输入流程名称', trigger: 'blur' }
  ],
  businessType: [
    { required: true, message: '请选择业务类型', trigger: 'change' }
  ]
}

const nodeRules: FormRules = {
  nodeOrder: [
    { required: true, message: '请输入节点序号', trigger: 'blur' }
  ],
  nodeName: [
    { required: true, message: '请输入节点名称', trigger: 'blur' }
  ],
  approverType: [
    { required: true, message: '请选择审批人类型', trigger: 'change' }
  ],
  approverRole: [
    {
      validator: (rule, value, callback) => {
        if (currentNode.approverType === 0 && !value) {
          callback(new Error('请输入审批人角色'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  approverIds: [
    {
      validator: (rule, value, callback) => {
        if (currentNode.approverType === 1 && !value) {
          callback(new Error('请输入审批人ID'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  actionType: [
    { required: true, message: '请选择审批操作', trigger: 'change' }
  ]
}

const groupedProcessList = computed(() => {
  const groups: Record<string, ProcessGroup> = {}
  approvalList.value.forEach(item => {
    const key = `${item.processName}-${item.businessType}`
    if (!groups[key]) {
      groups[key] = {
        processName: item.processName,
        businessType: item.businessType,
        description: item.description || '',
        nodes: [],
        createTime: item.createTime || ''
      }
    }
    groups[key].nodes.push(item)
  })
  Object.values(groups).forEach(group => {
    group.nodes.sort((a, b) => (a.nodeOrder || 0) - (b.nodeOrder || 0))
  })
  return Object.values(groups)
})

const loadApprovalPage = async () => {
  try {
    const res: PageResult<ApprovalTemplate> = await getApprovalPage({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      processName: processName.value || undefined,
      businessType: businessType.value || undefined
    })
    approvalList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载审批流程模板列表失败:', error)
  }
}

const handleReset = () => {
  processName.value = ''
  businessType.value = ''
  pageNum.value = 1
  pageSize.value = 20
  loadApprovalPage()
}

const handleAddProcess = () => {
  Object.assign(currentProcess, {
    processName: '',
    businessType: '',
    description: ''
  })
  isEditMode.value = false
  processDialogTitle.value = '新增流程'
  processDialogVisible.value = true
}

const handleSaveProcess = () => {
  if (!processFormRef.value) return
  processFormRef.value.validate((valid) => {
    if (valid) {
      processDialogVisible.value = false
      nodeDialogTitle.value = '新增审批节点'
      Object.assign(currentNode, {
        id: undefined,
        processName: currentProcess.processName,
        businessType: currentProcess.businessType,
        description: currentProcess.description,
        nodeOrder: 1,
        nodeName: '',
        approverType: 0,
        approverRole: '',
        approverIds: '',
        actionType: 'APPROVE_REJECT',
        enabled: 1
      })
      nodeDialogVisible.value = true
    }
  })
}

const handleEditProcess = (process: ProcessGroup) => {
  isEditMode.value = true
  editingProcess.value = process
  processDialogTitle.value = '编辑流程'
  Object.assign(currentProcess, {
    processName: process.processName,
    businessType: process.businessType,
    description: process.description
  })
  processDialogVisible.value = true
}

const handleUpdateProcess = async () => {
  if (!processFormRef.value) return
  processFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const process = editingProcess.value
        if (!process) return

        for (const node of process.nodes) {
          await updateApproval({
            ...node,
            processName: currentProcess.processName,
            businessType: currentProcess.businessType,
            description: currentProcess.description
          })
        }
        ElMessage.success('更新流程成功')
        processDialogVisible.value = false
        loadApprovalPage()
      } catch (error) {
        console.error('更新流程失败:', error)
      }
    }
  })
}

const handleAddNode = (process: ProcessGroup) => {
  nodeDialogTitle.value = '新增审批节点'
  const nextOrder = process.nodes.length + 1
  Object.assign(currentNode, {
    id: undefined,
    processName: process.processName,
    businessType: process.businessType,
    description: process.description,
    nodeOrder: nextOrder,
    nodeName: '',
    approverType: 0,
    approverRole: '',
    approverIds: '',
    actionType: 'APPROVE_REJECT',
    enabled: 1
  })
  nodeDialogVisible.value = true
}

const handleEditNode = (node: ApprovalTemplate) => {
  nodeDialogTitle.value = '编辑审批节点'
  Object.assign(currentNode, {
    id: node.id,
    processName: node.processName,
    businessType: node.businessType,
    description: node.description,
    nodeOrder: node.nodeOrder,
    nodeName: node.nodeName,
    approverType: node.approverType,
    approverRole: node.approverRole,
    approverIds: node.approverIds,
    actionType: node.actionType,
    enabled: node.enabled
  })
  nodeDialogVisible.value = true
}

const handleDeleteNode = async (node: ApprovalTemplate) => {
  try {
    await deleteApproval(node.id!)
    ElMessage.success('删除节点成功')
    loadApprovalPage()
  } catch (error) {
    console.error('删除节点失败:', error)
  }
}

const handleSaveNode = async () => {
  if (!nodeFormRef.value) return
  nodeFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const nodeData = {
          processName: currentNode.processName,
          businessType: currentNode.businessType,
          description: currentNode.description,
          nodeOrder: currentNode.nodeOrder,
          nodeName: currentNode.nodeName,
          approverType: currentNode.approverType,
          approverRole: currentNode.approverType === 0 ? currentNode.approverRole : undefined,
          approverIds: currentNode.approverType === 1 ? currentNode.approverIds : undefined,
          actionType: currentNode.actionType,
          enabled: currentNode.enabled
        }
        if (currentNode.id) {
          await updateApproval({ ...currentNode, ...nodeData })
          ElMessage.success('更新审批节点成功')
        } else {
          await createApproval(nodeData)
          ElMessage.success('新增审批节点成功')
        }
        nodeDialogVisible.value = false
        loadApprovalPage()
      } catch (error) {
        console.error('保存审批节点失败:', error)
      }
    }
  })
}

const handleDeleteProcess = async (process: ProcessGroup) => {
  try {
    for (const node of process.nodes) {
      await deleteApproval(node.id!)
    }
    ElMessage.success('删除流程成功')
    loadApprovalPage()
  } catch (error) {
    console.error('删除流程失败:', error)
  }
}

const getBusinessTypeText = (type?: string) => {
  const map: Record<string, string> = {
    LEAVE: '请假',
    OVERTIME: '加班',
    TRANSFER: '调岗',
    SALARY_ADJUST: '调薪',
    CUSTOM: '自定义'
  }
  return type ? map[type] || type : '-'
}

const getApproverTypeText = (type?: number) => {
  const map: Record<number, string> = {
    0: '角色',
    1: '指定用户',
    2: '上级',
    3: '部门负责人'
  }
  return type !== undefined ? map[type] || '-' : '-'
}

const getNodeTypeTag = (type?: number) => {
  const map: Record<number, string> = {
    0: 'success',
    1: 'warning',
    2: 'info',
    3: 'primary'
  }
  return type !== undefined ? map[type] : 'info'
}

const getActionTypeText = (type?: string) => {
  const map: Record<string, string> = {
    APPROVE_REJECT: '审批',
    NOTIFY: '通知'
  }
  return type ? map[type] || type : '-'
}

onMounted(() => {
  loadApprovalPage()
})
</script>

<style scoped>
.workflow-container {
  padding: 20px;
}

.card-header {
  font-size: 18px;
  font-weight: bold;
}

.search-filter-section {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 0;
  background-color: #f5f7fa;
  border-radius: 8px;
  padding: 15px;
}

.business-type-tabs {
  display: flex;
  align-items: center;
}

/* 流程卡片容器 */
.process-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(600px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.process-card {
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  padding: 20px;
  background-color: #fff;
  transition: box-shadow 0.3s;
}

.process-card:hover {
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

/* 卡片头部 */
.process-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 12px;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 12px;
}

.process-title {
  display: flex;
  align-items: center;
  gap: 10px;
}

.process-title h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.process-actions {
  display: flex;
  gap: 8px;
}

/* 流程描述 */
.process-description {
  color: #909399;
  font-size: 14px;
  margin-bottom: 16px;
  padding: 8px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

/* 流程节点可视化 */
.flow-nodes {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0;
  min-height: 100px;
  padding: 10px 0;
}

/* 开始/结束圆圈 */
.flow-start,
.flow-end {
  display: flex;
  align-items: center;
  justify-content: center;
}

.circle {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: bold;
  color: #fff;
}

.circle.start {
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
}

.circle.end {
  background: linear-gradient(135deg, #f56c6c 0%, #f78989 100%);
}

/* 节点项 */
.flow-node-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
}

/* 节点盒子 */
.node-box {
  width: 100%;
  max-width: 400px;
  border: 2px solid #409eff;
  border-radius: 8px;
  background-color: #fff;
  overflow: hidden;
  transition: all 0.3s;
}

.node-box:hover {
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.node-box.disabled {
  border-color: #dcdfe6;
  opacity: 0.6;
}

/* 节点头部 */
.node-header {
  background-color: #ecf5ff;
  padding: 8px 12px;
  display: flex;
  align-items: center;
  gap: 8px;
  border-bottom: 1px solid #d9ecff;
}

.node-order {
  font-weight: bold;
  color: #409eff;
  font-size: 14px;
}

/* 节点主体 */
.node-body {
  padding: 12px;
}

.node-name {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 8px;
}

.node-approver {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #606266;
  font-size: 14px;
}

/* 节点操作 */
.node-actions {
  padding: 8px 12px;
  background-color: #f5f7fa;
  border-top: 1px solid #ebeef5;
  display: flex;
  gap: 8px;
}

/* 流程连线箭头 */
.flow-line-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #909399;
  font-size: 20px;
  margin: 8px 0;
}

/* 空节点提示 */
.empty-nodes {
  width: 100%;
  text-align: center;
  padding: 40px 0;
  color: #909399;
}

/* 流程底部 */
.process-footer {
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
  text-align: right;
}

.create-time {
  font-size: 12px;
  color: #909399;
}

/* 空数据 */
.empty-process {
  text-align: center;
  padding: 60px 20px;
  color: #909399;
}
</style>
