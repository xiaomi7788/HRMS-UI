import request from '@/utils/request'

// ==================== 审批流程模板 ====================

// 审批流程模板
export interface ApprovalTemplate {
  id?: number
  processName: string
  businessType: string
  description?: string
  nodeOrder: number
  nodeName: string
  approverType: number
  approverRole?: string
  approverIds?: string
  actionType: string
  enabled: number
  createTime?: string
  updateTime?: string
  isDeleted?: number
}

// 审批流程模板分页结果
export interface ApprovalTemplatePageResult {
  records: ApprovalTemplate[]
  total: number
}

// 审批流程模板分页查询参数
export interface ApprovalTemplatePageQuery {
  pageNum: number
  pageSize: number
  processName?: string
  businessType?: string
}

// 新增审批模板
export function createApprovalTemplate(data: ApprovalTemplate) {
  return request.post<void>('/sys/approval-template', data)
}

// 更新审批模板
export function updateApprovalTemplate(data: ApprovalTemplate) {
  return request.put<void>('/sys/approval-template', data)
}

// 审批流程模板分页查询
export function getApprovalTemplatePage(params: ApprovalTemplatePageQuery) {
  console.log('getApprovalTemplatePage--->', params);
  
  return request.get<ApprovalTemplatePageResult>('/sys/approval-template/page', params)
}

// 查询指定业务类型的全部审批节点
export function getApprovalTemplateList(businessType?: string) {
  return request.get<ApprovalTemplate[]>('/sys/approval-template/list', {
    params: { businessType }
  })
}

// 删除审批模板
export function deleteApprovalTemplate(id: number) {
  return request.delete<void>(`/sys/approval-template/${id}`)
}

// ==================== 流程实例 ====================

// 流程实例
export interface ProcessInstance {
  id: number
  processName: string
  businessType: string
  businessId: number
  businessTitle: string
  initiatorId: number
  initiatorName: string
  currentNodeOrder: number
  currentNodeName: string
  processStatus: number
  finishTime?: string
  finalComment?: string
  createTime: string
  updateTime?: string
  isDeleted?: number
}

// 流程实例分页结果
export interface ProcessInstancePageResult {
  records: ProcessInstance[]
  total: number
}

// 流程实例分页查询参数
export interface ProcessInstancePageQuery {
  pageNum: number
  pageSize: number
  businessType?: string
  processStatus?: number
  initiatorName?: string
}

// 流程统计数据
export interface ProcessStatistics {
  total: number
  pending: number
  approved: number
  rejected: number
  withdrawn: number
}

// 审批节点记录
export interface NodeRecord {
  id: number
  instanceId: number
  nodeOrder: number
  nodeName: string
  approverRole: string
  approverId?: number
  approverName?: string
  nodeStatus: number
  approveTime?: string
  comment?: string
  actionType: string
  createTime?: string
  updateTime?: string
}

// 发起流程实例
export function startProcessInstance(data: {
  businessType: string
  businessId: number
  businessTitle: string
  initiatorId: number
}) {
  return request.post<number>('/sys/bpm/instance/start', data)
}

// 流程实例分页查询
export function getProcessInstancePage(params: ProcessInstancePageQuery) {
  return request.get<ProcessInstancePageResult>('/sys/bpm/instance/page', params)
}

// 获取流程节点记录
export function getNodeRecords(instanceId: number) {
  return request.get<NodeRecord[]>(`/sys/bpm/instance/${instanceId}/records`)
}

// 审批操作
export function approveInstance(id: number, data: {
  approveResult: 'APPROVE' | 'REJECT'
  comment?: string
}) {
  return request.post<void>(`/sys/bpm/instance/${id}/approve`, data)
}

// 撤回流程
export function withdrawInstance(id: number) {
  return request.post<void>(`/sys/bpm/instance/${id}/withdraw`)
}

// 获取流程统计数据
export function getProcessStatistics() {
  return request.get<ProcessStatistics>('/sys/bpm/statistics')
}

// ==================== 枚举值定义 ====================

// 业务类型
export enum BusinessType {
  LEAVE = 'LEAVE',
  OVERTIME = 'OVERTIME',
  TRANSFER = 'TRANSFER',
  SALARY_ADJUST = 'SALARY_ADJUST',
  CUSTOM = 'CUSTOM'
}

export const BUSINESS_TYPE_OPTIONS = [
  { label: '请假审批', value: BusinessType.LEAVE },
  { label: '加班申请', value: BusinessType.OVERTIME },
  { label: '调岗申请', value: BusinessType.TRANSFER },
  { label: '薪酬调整', value: BusinessType.SALARY_ADJUST },
  { label: '自定义', value: BusinessType.CUSTOM }
]

// 审批人类型
export enum ApproverType {
  ROLE = 0,
  USER = 1,
  SUPERIOR = 2,
  DEPT_LEADER = 3
}

export const APPROVER_TYPE_OPTIONS = [
  { label: '角色', value: ApproverType.ROLE },
  { label: '指定用户', value: ApproverType.USER },
  { label: '上级', value: ApproverType.SUPERIOR },
  { label: '部门负责人', value: ApproverType.DEPT_LEADER }
]

// 操作类型
export enum ActionType {
  APPROVE_REJECT = 'APPROVE_REJECT',
  NOTIFY = 'NOTIFY'
}

export const ACTION_TYPE_OPTIONS = [
  { label: '审批通过/驳回', value: ActionType.APPROVE_REJECT },
  { label: '仅通知', value: ActionType.NOTIFY }
]

// 流程状态
export enum ProcessStatus {
  PENDING = 0,
  APPROVED = 1,
  REJECTED = 2,
  WITHDRAWN = 3,
  CANCELLED = 4
}

export const PROCESS_STATUS_OPTIONS = [
  { label: '审批中', value: ProcessStatus.PENDING, type: 'warning' },
  { label: '已通过', value: ProcessStatus.APPROVED, type: 'success' },
  { label: '已拒绝', value: ProcessStatus.REJECTED, type: 'danger' },
  { label: '已撤回', value: ProcessStatus.WITHDRAWN, type: 'info' },
  { label: '已取消', value: ProcessStatus.CANCELLED, type: 'info' }
]

// 节点状态
export enum NodeStatus {
  PENDING = 0,
  APPROVED = 1,
  REJECTED = 2,
  SKIPPED = 3,
  WITHDRAWN = 4
}

export const NODE_STATUS_OPTIONS = [
  { label: '待审批', value: NodeStatus.PENDING, type: 'warning' },
  { label: '已通过', value: NodeStatus.APPROVED, type: 'success' },
  { label: '已拒绝', value: NodeStatus.REJECTED, type: 'danger' },
  { label: '跳过', value: NodeStatus.SKIPPED, type: 'info' },
  { label: '已撤回', value: NodeStatus.WITHDRAWN, type: 'info' }
]
