import request from '@/utils/request'

export interface SalaryAdjust {
  id?: number
  employeeId?: number
  employeeName?: string
  employeeNo?: string
  adjustType?: string
  beforeSalary?: number
  afterSalary?: number
  adjustPercent?: number
  effectiveDate?: string
  applyUserId?: number
  applyUserName?: string
  approveUserId?: number
  approveUserName?: string
  status?: number
  applyReason?: string
  approveComment?: string
  approveTime?: string
  createTime?: string
  updateTime?: string
}

export interface AdjustPageParams {
  pageNum?: number
  pageSize?: number
  employeeId?: number
  status?: number
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getAdjustPage = (params: AdjustPageParams) => {
  return request.get<PageResult<SalaryAdjust>>('/salary/adjust/page', params)
}

export const applyAdjust = (data: SalaryAdjust) => {
  return request.post('/salary/adjust', data)
}

export const approveAdjust = (id: number, passed: boolean, comment?: string) => {
  return request.put(`/salary/adjust/${id}/approve`, comment ? { approveRemark: comment } : undefined, { params: { passed } })
}

export const withdrawAdjust = (id: number) => {
  return request.put(`/salary/adjust/${id}/withdraw`)
}

export const deleteAdjust = (id: number) => {
  return request.delete(`/salary/adjust/${id}`)
}
