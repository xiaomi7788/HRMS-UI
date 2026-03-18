import request from '@/utils/request'

export interface AttendanceApply {
  id?: number
  employeeId?: number
  applyType?: number
  leaveType?: string
  startTime?: string
  endTime?: string
  duration?: number
  reason?: string
  attachmentUrl?: string
  approvalStatus?: number
  approverId?: number
  approverName?: string
  approvalTime?: string
  approvalComment?: string
  instanceId?: number
  employeeName?: string
}

export interface ApplyPageParams {
  pageNum?: number
  pageSize?: number
  employeeId?: number
  applyType?: number
  approvalStatus?: number
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getApplyPage = (params: ApplyPageParams) => {
  return request.get<PageResult<AttendanceApply>>('/attendance/apply/page', params)
}

export const createApply = (data: AttendanceApply) => {
  return request.post('/attendance/apply', data)
}

export const approveApply = (id: number, data: { approvalStatus: number; approvalComment?: string }) => {
  return request.put(`/attendance/apply/${id}/approve`, data)
}

export const withdrawApply = (id: number) => {
  return request.put(`/attendance/apply/${id}/withdraw`)
}
