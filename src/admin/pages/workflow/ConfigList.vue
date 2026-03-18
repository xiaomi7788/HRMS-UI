<template>
  <div class="workflow-config">
    <el-card class="config-card">
      <template #header>
        <div class="card-header">
          <span>流程配置</span>
          <el-button type="primary" @click="handleAdd">
            <el-icon><Plus /></el-icon>
            新增审批节点
          </el-button>
        </div>
      </template>

      <!-- 筛选栏 -->
      <el-form :inline="true" :model="queryParams" class="filter-form">
        <el-form-item label="流程名称">
          <el-input v-model="queryParams.processName" placeholder="请输入流程名称" clearable style="width: 180px" />
        </el-form-item>
        <el-form-item label="业务类型">
          <el-select v-model="queryParams.businessType" placeholder="全部" clearable style="width: 150px">
            <el-option label="全部" :value="undefined" />
            <el-option
              v-for="item in BUSINESS_TYPE_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
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
      <el-table :data="templateList" v-loading="loading" stripe>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="processName" label="流程名称" min-width="150" />
        <el-table-column prop="businessType" label="业务类型" width="120">
          <template #default="{ row }">
            {{ getBusinessTypeName(row.businessType) }}
          </template>
        </el-table-column>
        <el-table-column prop="nodeOrder" label="节点序号" width="100" align="center" />
        <el-table-column prop="nodeName" label="节点名称" min-width="120" />
        <el-table-column prop="approverType" label="审批人类型" width="120">
          <template #default="{ row }">
            {{ getApproverTypeName(row.approverType) }}
          </template>
        </el-table-column>
        <el-table-column prop="approverRole" label="审批人角色" width="120">
          <template #default="{ row }">
            {{ row.approverRole || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="approverIds" label="指定审批人" width="120">
          <template #default="{ row }">
            {{ row.approverIds ? `${row.approverIds.split(',').length}人` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="actionType" label="操作类型" width="140">
          <template #default="{ row }">
            {{ getActionTypeName(row.actionType) }}
          </template>
        </el-table-column>
        <el-table-column prop="enabled" label="启用状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.enabled === 1 ? 'success' : 'info'">
              {{ row.enabled === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="150" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
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

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form :model="form" :rules="formRules" ref="formRef" label-width="120px">
        <el-form-item label="流程名称" prop="processName">
          <el-input v-model="form.processName" placeholder="请输入流程名称" />
        </el-form-item>
        <el-form-item label="业务类型" prop="businessType">
          <el-select v-model="form.businessType" placeholder="请选择业务类型" style="width: 100%">
            <el-option
              v-for="item in BUSINESS_TYPE_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="选择节点" prop="selectedNodeId">
          <el-select v-model="form.selectedNodeId" placeholder="请选择节点" style="width: 100%" @change="handleNodeSelect">
            <el-option
              v-for="node in availableNodes"
              :key="node.id"
              :label="`${node.nodeOrder} - ${node.nodeName}`"
              :value="node.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="审批人类型" prop="approverType">
          <el-select v-model="form.approverType" placeholder="请选择审批人类型" style="width: 100%" @change="handleApproverTypeChange">
            <el-option
              v-for="item in APPROVER_TYPE_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item
          v-if="form.approverType === ApproverType.ROLE"
          label="审批人角色"
          prop="approverRole"
        >
          <el-input v-model="form.approverRole" placeholder="请输入角色编码，如：ADMIN, HR" />
        </el-form-item>
        <el-form-item
          v-if="form.approverType === ApproverType.USER"
          label="指定审批人"
          prop="approverIds"
        >
          <el-input
            v-model="form.approverIds"
            type="textarea"
            :rows="2"
            placeholder="请输入审批人ID，多个用逗号分隔"
          />
        </el-form-item>
        <el-form-item label="操作类型" prop="actionType">
          <el-select v-model="form.actionType" placeholder="请选择操作类型" style="width: 100%">
            <el-option
              v-for="item in ACTION_TYPE_OPTIONS"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="启用状态" prop="enabled">
          <el-switch v-model="form.enabled" :active-value="1" :inactive-value="0" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入流程描述"
          />
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
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import {
  getApprovalTemplatePage,
  getApprovalTemplateList,
  createApprovalTemplate,
  updateApprovalTemplate,
  deleteApprovalTemplate,
  type ApprovalTemplate,
  type ApprovalTemplatePageQuery,
  BusinessType,
  ApproverType,
  ActionType,
  BUSINESS_TYPE_OPTIONS,
  APPROVER_TYPE_OPTIONS,
  ACTION_TYPE_OPTIONS
} from '@/api/workflow'

const loading = ref(false)
const templateList = ref<ApprovalTemplate[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const dialogTitle = ref('新增审批节点')
const formRef = ref<FormInstance>()
const availableNodes = ref<ApprovalTemplate[]>([])

const queryParams = reactive<ApprovalTemplatePageQuery>({
  pageNum: 1,
  pageSize: 10
})

const form = reactive<ApprovalTemplate & { selectedNodeId?: number }>({
  processName: '',
  businessType: '',
  nodeOrder: 1,
  nodeName: '',
  approverType: 0,
  approverRole: '',
  approverIds: '',
  actionType: 'APPROVE_REJECT',
  enabled: 1
})

const formRules = {
  selectedNodeId: [{ required: true, message: '请选择节点', trigger: 'change' }],
  processName: [{ required: true, message: '请输入流程名称', trigger: 'blur' }],
  businessType: [{ required: true, message: '请选择业务类型', trigger: 'change' }],
  nodeName: [{ required: true, message: '请输入节点名称', trigger: 'blur' }],
  approverType: [{ required: true, message: '请选择审批人类型', trigger: 'change' }],
  actionType: [{ required: true, message: '请选择操作类型', trigger: 'change' }]
}

// 加载可用节点
async function loadAvailableNodes() {
  const businessType = form.businessType || queryParams.businessType
  if (!businessType) {
    availableNodes.value = []
    return
  }
  try {
    const templates = await getApprovalTemplateList(businessType)
    availableNodes.value = templates.filter(t => !form.id || t.id !== form.id)
  } catch (error) {
    availableNodes.value = []
  }
}

// 处理节点选择
function handleNodeSelect(nodeId: number) {
  const selectedNode = availableNodes.value.find(n => n.id === nodeId)
  if (selectedNode) {
    form.nodeOrder = selectedNode.nodeOrder
    form.nodeName = selectedNode.nodeName
    form.approverType = selectedNode.approverType
    form.approverRole = selectedNode.approverRole || ''
    form.approverIds = selectedNode.approverIds || ''
    form.actionType = selectedNode.actionType
    form.enabled = selectedNode.enabled
  }
}

// 监听业务类型变化，重新加载节点
watch(() => form.businessType, () => {
  if (form.businessType) {
    loadAvailableNodes()
  }
})

// 监听对话框打开，加载节点
watch(dialogVisible, (newVal) => {
  if (newVal) {
    loadAvailableNodes()
  }
})

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function getBusinessTypeName(type: string) {
  const option = BUSINESS_TYPE_OPTIONS.find(item => item.value === type)
  return option?.label || type
}

function getApproverTypeName(type: number) {
  const option = APPROVER_TYPE_OPTIONS.find(item => item.value === type)
  return option?.label || String(type)
}

function getActionTypeName(type: string) {
  const option = ACTION_TYPE_OPTIONS.find(item => item.value === type)
  return option?.label || type
}

function handleApproverTypeChange() {
  form.approverRole = ''
  form.approverIds = ''
}

async function handleQuery() {
  loading.value = true
  try {
    const params = {
      pageNum: queryParams.pageNum,
      pageSize: queryParams.pageSize,
      processName: queryParams.processName || undefined,
      businessType: queryParams.businessType === undefined ? undefined : queryParams.businessType
    }
    const result = await getApprovalTemplatePage(params)
    templateList.value = result.records || []
    total.value = Number(result.total || 0)
  } catch (error) {
    ElMessage.error('获取流程配置列表失败')
  } finally {
    loading.value = false
  }
}

function handleReset() {
  queryParams.pageNum = 1
  queryParams.processName = ''
  queryParams.businessType = ''
  handleQuery()
}

function handleAdd() {
  dialogTitle.value = '新增审批节点'
  Object.assign(form, {
    processName: '',
    businessType: '',
    nodeOrder: 1,
    nodeName: '',
    approverType: 0,
    approverRole: '',
    approverIds: '',
    actionType: 'APPROVE_REJECT',
    enabled: 1,
    selectedNodeId: undefined
  })
  dialogVisible.value = true
}

function handleEdit(row: ApprovalTemplate) {
  dialogTitle.value = '编辑审批节点'
  Object.assign(form, row)
  form.selectedNodeId = row.id
  dialogVisible.value = true
}

function handleDialogClose() {
  formRef.value?.resetFields()
}

async function handleSubmit() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (form.id) {
          await updateApprovalTemplate(form)
          ElMessage.success('更新成功')
        } else {
          await createApprovalTemplate(form)
          ElMessage.success('新增成功')
        }
        dialogVisible.value = false
        handleQuery()
      } catch (error) {
        ElMessage.error(form.id ? '更新失败' : '新增失败')
      }
    }
  })
}

async function handleDelete(row: ApprovalTemplate) {
  try {
    await ElMessageBox.confirm('确认删除此审批节点吗?', '提示', {
      type: 'warning'
    })
    await deleteApprovalTemplate(row.id!)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.workflow-config {
  padding: 20px;
}

.config-card {
  max-width: 1600px;
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
