import request from '@/utils/request'

// ==================== 仪表盘数据 ====================

// 综合仪表盘摘要
export interface DashboardSummary {
  onJobCount: number
  deptCount: number
  pendingApproval: number
  salaryCalculatedThisMonth: number
}

// 人员概览统计
export interface EmployeeOverview {
  total: number
  onJob: number
  leaved: number
  probation: number
  newHiresThisMonth: number
  leavedThisMonth: number
  leaveRateThisMonth: number
}

// 部门人员分布
export interface DeptDistribution {
  deptId: number
  count: number
}

// 薪酬趋势
export interface SalaryTrend {
  months: string[]
  totalPay: number[]
}

// 绩效等级分布
export interface PerfDistribution {
  A: number
  B: number
  C: number
  D: number
}

// 招聘漏斗数据
export interface RecruitFunnel {
  total: number
  stageDistribution: Record<number, number>
}

// 考勤统计
export interface AttendanceStats {
  totalLeave: number
  totalOvertime: number
  pendingApproval: number
}

// 获取综合仪表盘摘要
export function getDashboardSummary() {
  return request.get<DashboardSummary>('/sys/dashboard/summary')
}

// 获取人员概览统计
export function getEmployeeOverview() {
  return request.get<EmployeeOverview>('/sys/dashboard/employee-overview')
}

// 获取部门人员分布
export function getDeptDistribution() {
  return request.get<DeptDistribution[]>('/sys/dashboard/dept-distribution')
}

// 获取薪酬趋势
export function getSalaryTrend() {
  return request.get<SalaryTrend>('/sys/dashboard/salary-trend')
}

// 获取绩效等级分布
export function getPerfDistribution() {
  return request.get<PerfDistribution>('/sys/dashboard/perf-distribution')
}

// 获取招聘漏斗数据
export function getRecruitFunnel() {
  return request.get<RecruitFunnel>('/sys/dashboard/recruit-funnel')
}

// 获取考勤统计
export function getAttendanceStats() {
  return request.get<AttendanceStats>('/sys/dashboard/attendance-stats')
}
