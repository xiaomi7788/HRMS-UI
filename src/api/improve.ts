import request from '@/utils/request'

export interface PerfImprovePlan {
  id?: number
  perfResultId?: number
  employeeId?: number
  employeeName?: string
  employeeNo?: string
  deptId?: number
  planName?: string
  period?: string
  startDate?: string
  endDate?: string
  problemDesc?: string
  improveGoal?: string
  supportMeasures?: string
  milestones?: string
  hrOwnerId?: number
  managerId?: number
  result?: string
  resultComment?: string
  status?: number
  createTime?: string
  updateTime?: string
  deleted?: number
}

export interface ImprovePageParams {
  pageNum?: number
  pageSize?: number
  employeeId?: number
  period?: string
  status?: number
}

export interface CompleteParams {
  result?: string
  resultComment?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getImprovePage = (params: ImprovePageParams) => {
  return request.get<PageResult<PerfImprovePlan>>('/performance/improve/page', params)
}

export const createImprove = (data: PerfImprovePlan) => {
  return request.post('/performance/improve', data)
}

export const updateImprove = (data: PerfImprovePlan) => {
  return request.put('/performance/improve', data)
}

export const completeImprove = (id: number, data: CompleteParams) => {
  return request.put(`/performance/improve/${id}/complete`, data)
}

export const deleteImprove = (id: number) => {
  return request.delete(`/performance/improve/${id}`)
}
