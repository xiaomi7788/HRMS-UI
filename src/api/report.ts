import request from '@/utils/request'

export interface MonthSummaryVO {
  totalEmployees: number
  workDays: number
  lateCount: number
  earlyCount: number
  absentDays: number
  leaveDays: number
}

export interface MonthlyReportVO {
  employeeId?: number
  employeeName?: string
  employeeNo?: string
  deptName?: string
  workDays?: number
  lateCount?: number
  earlyCount?: number
  absentDays?: number
  annualLeaveUsed?: number
  sickLeaveUsed?: number
  personalLeaveUsed?: number
  overtimeHours?: number
  compLeaveDays?: number
}

export interface DailyDetailVO {
  attendanceDate?: string
  weekDay?: string
  checkInTime?: string
  checkOutTime?: string
  status?: number
  remark?: string
}

export interface ReportPageParams {
  pageNum?: number
  pageSize?: number
  month?: string
  deptId?: number
  keyword?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getMonthSummary = (month?: string) => {
  return request.get<MonthSummaryVO>('/attendance/report/monthly/summary', { month })
}

export const getMonthlyReportPage = (params: ReportPageParams) => {
  return request.get<PageResult<MonthlyReportVO>>('/attendance/report/monthly/page', params)
}

export const getEmployeeDailyDetail = (employeeId: number, month?: string) => {
  return request.get<DailyDetailVO[]>('/attendance/report/employee/daily', { employeeId, month })
}

export const exportMonthlyReport = (params: { month?: string; deptId?: number; keyword?: string }) => {
  const queryParams = new URLSearchParams()
  if (params.month) queryParams.append('month', params.month)
  if (params.deptId) queryParams.append('deptId', params.deptId.toString())
  if (params.keyword) queryParams.append('keyword', params.keyword)

  window.location.href = `/api/attendance/report/monthly/export?${queryParams.toString()}`
}
