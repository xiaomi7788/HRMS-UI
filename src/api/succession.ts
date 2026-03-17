import request from '@/utils/request'

export interface SuccessionPlan {
  id?: number
  targetPositionId?: number
  targetPositionName?: string
  successorId?: number
  successorName?: string
  successorCode?: string
  currentHolderId?: number
  currentHolderName?: string
  readiness?: string
  expectedDate?: string
  developmentPlan?: string
  status?: number
  createTime?: string
  updateTime?: string
}

export interface SuccessionPageParams {
  pageNum: number
  pageSize: number
  positionName?: string
  successorName?: string
  status?: number
}

export interface PageResult<T> {
  records: T[]
  total: number
}

export const getSuccessionPage = (params: SuccessionPageParams): Promise<PageResult<SuccessionPlan>> => {
  return request.get('/hr/succession-plan/page', params)
}

export const createSuccessionPlan = (data: Partial<SuccessionPlan>) => {
  return request.post('/hr/succession-plan', data)
}

export const updateSuccessionPlan = (data: Partial<SuccessionPlan>) => {
  return request.put('/hr/succession-plan', data)
}

export const deleteSuccessionPlan = (id: number) => {
  return request.delete(`/hr/succession-plan/${id}`)
}
