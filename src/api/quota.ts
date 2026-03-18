import request from '@/utils/request'

export interface HolidayQuotaVO {
  id?: number
  employeeId?: number
  employeeName?: string
  employeeNo?: string
  deptName?: string
  year?: number
  annualLeaveTotal?: number
  annualLeaveUsed?: number
  annualLeaveRemaining?: number
  sickLeaveTotal?: number
  sickLeaveUsed?: number
  sickLeaveRemaining?: number
  personalLeaveTotal?: number
  personalLeaveUsed?: number
  personalLeaveRemaining?: number
}

export interface QuotaPageParams {
  pageNum?: number
  pageSize?: number
  keyword?: string
  year?: number
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getQuotaPage = (params: QuotaPageParams) => {
  return request.get<PageResult<HolidayQuotaVO>>('/attendance/quota/page', params)
}

export const adjustQuota = (id: number, data: { type: string; adjustAmount: number; remark?: string }) => {
  const params: Record<string, any> = { remark: data.remark }
  if (data.type === 'ANNUAL') {
    params.annualLeaveAdjust = data.adjustAmount
  } else if (data.type === 'SICK') {
    params.sickLeaveAdjust = data.adjustAmount
  } else if (data.type === 'PERSONAL') {
    params.personalLeaveAdjust = data.adjustAmount
  }
  return request.put(`/attendance/quota/${id}/adjust`, params)
}
