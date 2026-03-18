import request from '@/utils/request'

// ==================== 个人档案 ====================

// 个人档案信息
export interface SelfProfile {
  id: number
  employeeId: number
  realName: string
  phone: string
  email: string
  departmentName: string
  positionName: string
  entryDate: string
  status: number
  avatar?: string
}

// 获取个人档案
export function getSelfProfile() {
  return request.get<SelfProfile>('/self/profile')
}

// ==================== 考勤申请 ====================

// 请假加班申请（后端字段映射）
export interface AttendanceApply {
  id?: number
  employeeId?: number
  employeeName?: string
  applyType?: number // 0请假/1加班/2调休
  leaveType?: string
  startTime?: string
  endTime?: string
  duration?: number
  reason?: string
  approvalStatus?: number // 0待审批/1通过/2拒绝/3撤回
  approverName?: string
  approvalTime?: string
  approvalComment?: string
  createTime?: string
  updateTime?: string
}

// 考勤申请列表
export interface AttendanceApplyPageResult {
  total: number
  records: AttendanceApply[]
}

export interface AttendanceApplyQuery {
  pageNum?: number
  pageSize?: number
  applyType?: number
  approvalStatus?: number
}

// 获取我的请假-加班申请列表
export function getAttendanceApplies(params: AttendanceApplyQuery) {
  return request.get<AttendanceApplyPageResult>('/self/attendance/applies', { params })
}

// 提交请假-加班申请
export function submitAttendanceApply(data: AttendanceApply) {
  return request.post<void>('/self/attendance/apply', data)
}

// 撤回请假申请
export function withdrawAttendanceApply(id: number) {
  return request.put<void>(`/self/attendance/apply/${id}/withdraw`)
}

// 考勤记录（后端字段映射）
export interface AttendanceRecord {
  id: number
  employeeId?: number
  employeeName?: string
  deptName?: string
  attendanceDate?: string
  checkInTime?: string
  checkOutTime?: string
  status?: number // 0正常/1迟到/2早退/3缺勤/4请假/5加班
  checkInType?: number
  checkOutType?: number
  workHours?: string
  remark?: string
  createTime?: string
}

export interface AttendanceRecordPageResult {
  total: number
  records: AttendanceRecord[]
}

// 获取我的考勤记录
export function getAttendanceRecords(params: { pageNum?: number; pageSize?: number }) {
  return request.get<AttendanceRecordPageResult>('/self/attendance/records', { params })
}

// ==================== 绩效结果 ====================

// 绩效结果（后端字段映射）
export interface PerformanceResult {
  id: number
  planId?: number
  employeeId?: number
  kpiScore?: number
  behaviorScore?: number
  evaluationScore?: number
  totalScore?: number
  grade?: string
  rating?: string
  evaluatorId?: number
  evaluatorName?: string
  evaluateTime?: string
  comment?: string
  status?: number
  createTime?: string
  updateTime?: string
}

export interface PerformanceResultPageResult {
  total: number
  records: PerformanceResult[]
}

// 获取我的绩效结果
export function getPerformanceResults(params: { pageNum?: number; pageSize?: number }) {
  return request.get<PerformanceResultPageResult>('/self/performance/results', { params })
}

// ==================== 薪酬记录 ====================

// 工资条记录（后端字段映射）
export interface SalaryRecord {
  id: number
  employeeId?: number
  payMonth?: string
  baseSalary?: number
  allowance?: number
  bonus?: number
  overtimePay?: number
  socialInsurance?: number
  housingFund?: number
  deduction?: number
  taxableIncome?: number
  personalTax?: number
  actualPay?: number
  workDays?: number
  status?: number
  remark?: string
  createTime?: string
}

export interface SalaryRecordPageResult {
  total: number
  records: SalaryRecord[]
}

// 获取我的工资条
export function getSalaryRecords(params: { pageNum?: number; pageSize?: number }) {
  return request.get<SalaryRecordPageResult>('/self/salary/records', { params })
}

// ==================== 培训活动 ====================

// 培训活动（后端字段映射）
export interface TrainingActivity {
  id: number
  courseId?: number
  title?: string
  startDate?: string
  endDate?: string
  location?: string
  registrationDeadline?: string
  maxParticipants?: number
  currentParticipants?: number
  status?: number
  createTime?: string
}

export interface TrainingActivityPageResult {
  total: number
  records: TrainingActivity[]
}

// 获取培训活动列表
export function getTrainingActivities(params: { pageNum?: number; pageSize?: number } = { pageNum: 1, pageSize: 10 }) {
  return request.get<TrainingActivityPageResult>('/self/training/activities', { params })
}

// ==================== 员工关怀 ====================

// 生日员工
export interface BirthdayEmployee {
  id: number
  employeeId: number
  employeeName: string
  departmentName: string
  positionName: string
  birthday: string
  avatar?: string
}

// 获取本月生日员工
export function getBirthdayEmployees() {
  return request.get<BirthdayEmployee[]>('/self/care/birthday')
}

// 入职周年员工
export interface AnniversaryEmployee {
  id: number
  employeeId: number
  employeeName: string
  departmentName: string
  positionName: string
  entryDate: string
  workYears: number
  avatar?: string
}

// 获取本月入职周年员工
export function getAnniversaryEmployees() {
  return request.get<AnniversaryEmployee[]>('/self/care/anniversary')
}

// ==================== 福利发放 ====================

// 福利发放记录
export interface WelfareRecord {
  id: number
  employeeId: number
  employeeName: string
  welfareName: string
  welfareType: string
  amount?: number
  issueDate: string
  description?: string
}

export interface WelfareRecordPageResult {
  records: WelfareRecord[]
  total: number
  size: number
  current: number
}

// 获取我的福利发放记录
export function getWelfareRecords(params: { pageNum?: number; pageSize?: number }) {
  return request.get<WelfareRecordPageResult>('/self/welfare/records', { params })
}
