import request from '@/utils/request'

// 审批流程模板数据类型
export interface ApprovalTemplate {
  id?: number
  processName?: string
  businessType?: string
  description?: string
  nodeOrder?: number
  nodeName?: string
  approverType?: number
  approverRole?: string
  approverIds?: string
  actionType?: string
  enabled?: number
  createTime?: string
  updateTime?: string
}

// 分页查询参数
export interface ApprovalPageParams {
  pageNum: number
  pageSize: number
  processName?: string
  businessType?: string
}

// 分页响应数据
export interface PageResult<T> {
  records: T[]
  total: number
}

// 分页查询审批流程模板
export function getApprovalPage(params: ApprovalPageParams) {
  return request.get<PageResult<ApprovalTemplate>>('/sys/approval-template/page', params)
}

// 查询指定业务类型的全部审批节点
export function getApprovalList(businessType?: string) {
  return request.get<ApprovalTemplate[]>('/sys/approval-template/list', { businessType })
}

// 新增审批节点
export function createApproval(data: ApprovalTemplate) {
  return request.post<void>('/sys/approval-template', data)
}

// 更新审批节点
export function updateApproval(data: ApprovalTemplate) {
  return request.put<void>('/sys/approval-template', data)
}

// 删除审批节点
export function deleteApproval(id: number) {
  return request.delete<void>(`/sys/approval-template/${id}`)
}
