import request from '@/utils/request'

export interface AttendanceShift {
  id?: number
  employeeId?: number
  shiftDate?: string
  shiftType?: number
  ruleId?: number
}

export interface ShiftVO {
  id?: number
  employeeId?: number
  shiftDate?: string
  shiftType?: number
  ruleId?: number
  employeeName?: string
  employeeNo?: string
  deptName?: string
  ruleName?: string
  workStart?: string
  workEnd?: string
}

export interface ShiftPageParams {
  pageNum?: number
  pageSize?: number
  keyword?: string
  deptId?: number
  month?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export interface GenerateParams {
  month: string
  deptId?: number
  shiftType?: number
  ruleId: number
  excludeWeekend?: boolean
  count?: number
}

export const getShiftPage = (params: ShiftPageParams) => {
  return request.get<PageResult<ShiftVO>>('/attendance/shift/page', params)
}

export const createShift = (data: Partial<AttendanceShift>) => {
  return request.post('/attendance/shift', data)
}

export const updateShift = (data: Partial<AttendanceShift>) => {
  return request.put('/attendance/shift', data)
}

export const deleteShift = (id: number) => {
  return request.delete(`/attendance/shift/${id}`)
}

export const generateShift = (data: GenerateParams) => {
  return request.post('/attendance/shift/generate', data)
}
