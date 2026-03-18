import request from '@/utils/request'

export interface TrainingNeed {
  id?: number
  year?: number
  deptId?: number
  employeeId?: number
  needTitle?: string
  needDesc?: string
  category?: string
  priority?: number
  expectedTime?: string
  participants?: number
  status?: number
  planActivityId?: number
  remark?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
  deptName?: string
  employeeName?: string
}

export interface TrainingActivity {
  id?: number
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
  updateTime?: string
  isDeleted?: number
  courseName?: string
}

export interface TrainingRecord {
  id?: number
  activityId?: number
  employeeId?: number
  enrollStatus?: number
  completionStatus?: number
  examScore?: number
  satisfactionScore?: number
  feedback?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
  employeeName?: string
  employeeNo?: string
  activityTitle?: string
}

export interface TrainingEffectReport {
  id?: number
  activityId?: number
  reportTitle?: string
  totalEnrolled?: number
  totalCompleted?: number
  completionRate?: number
  avgExamScore?: number
  avgSatisfaction?: number
  passRate?: number
  passThreshold?: number
  summary?: string
  suggestions?: string
  status?: number
  createTime?: string
  updateTime?: string
  isDeleted?: number
  activityTitle?: string
}

export interface TrainingLearnProgress {
  id?: number
  courseId?: number
  employeeId?: number
  chapterIndex?: number
  progressPct?: number
  studyMinutes?: number
  lastPosition?: number
  isCompleted?: number
  completeTime?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
  employeeName?: string
  employeeNo?: string
  courseName?: string
}

export interface TrainingCheckin {
  id?: number
  activityId?: number
  employeeId?: number
  checkinDate?: string
  checkinTime?: string
  checkoutTime?: string
  checkinType?: number
  isLate?: number
  leaveEarly?: number
  durationMinutes?: number
  remark?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
  employeeName?: string
  employeeNo?: string
  deptName?: string
  activityTitle?: string
}

export interface TrainingCourse {
  id?: number
  courseName?: string
  category?: string
  courseType?: number
  instructor?: string
  duration?: number
  description?: string
  attachmentUrl?: string
  status?: number
  createTime?: string
  updateTime?: string
  isDeleted?: number
}

export interface NeedPageParams {
  pageNum?: number
  pageSize?: number
  year?: number
  deptId?: number
  employeeId?: number
  status?: number
  category?: string
}

export interface ActivityPageParams {
  pageNum?: number
  pageSize?: number
  courseId?: number
  status?: number
}

export interface RecordPageParams {
  pageNum?: number
  pageSize?: number
  activityId?: number
  employeeId?: number
  enrollStatus?: number
}

export interface ReportPageParams {
  pageNum?: number
  pageSize?: number
  activityId?: number
  status?: number
}

export interface LearnPageParams {
  pageNum?: number
  pageSize?: number
  courseId?: number
  employeeId?: number
}

export interface CheckinPageParams {
  pageNum?: number
  pageSize?: number
  activityId?: number
  employeeId?: number
  checkinDate?: string
}

export interface CoursePageParams {
  pageNum?: number
  pageSize?: number
  category?: string
  courseType?: number
  status?: number
}

export interface AuditParams {
  status: number
  planActivityId?: number
  remark?: string
}

export interface GenerateReportParams {
  activityId: number
  passThreshold?: number
}

export interface BatchCheckinParams {
  activityId: number
  employeeIds: number[]
}

export interface PageResult<T> {
  total: number
  records: T[]
}

// 培训需求
export const getNeedPage = (params: NeedPageParams) => {
  return request.get<PageResult<TrainingNeed>>('/training/need/page', params)
}

export const createNeed = (data: TrainingNeed) => {
  return request.post('/training/need', data)
}

export const updateNeed = (data: TrainingNeed) => {
  return request.put('/training/need', data)
}

export const deleteNeed = (id: number) => {
  return request.delete(`/training/need/${id}`)
}

export const auditNeed = (id: number, data: AuditParams) => {
  return request.put(`/training/need/${id}/audit`, data)
}

// 培训活动
export const getActivityPage = (params: ActivityPageParams) => {
  return request.get<PageResult<TrainingActivity>>('/training/activity/page', params)
}

export const createActivity = (data: TrainingActivity) => {
  return request.post('/training/activity', data)
}

export const updateActivity = (data: TrainingActivity) => {
  return request.put('/training/activity', data)
}

export const deleteActivity = (id: number) => {
  return request.delete(`/training/activity/${id}`)
}

export const enrollActivity = (id: number) => {
  return request.post(`/training/activity/${id}/enroll`)
}

// 学习记录
export const getRecordPage = (params: RecordPageParams) => {
  return request.get<PageResult<TrainingRecord>>('/training/record/page', params)
}

export const auditRecord = (id: number, data: { status: number; remark?: string }) => {
  return request.put(`/training/record/${id}/audit`, data)
}

export const completeRecord = (id: number, data: { completionStatus: number; examScore?: number; satisfactionScore?: number; feedback?: string }) => {
  return request.put(`/training/record/${id}/complete`, data)
}

// 效果报告
export const getReportPage = (params: ReportPageParams) => {
  return request.get<PageResult<TrainingEffectReport>>('/training/report/page', params)
}

export const getReportById = (id: number) => {
  return request.get<TrainingEffectReport>(`/training/report/${id}`)
}

export const createReport = (data: TrainingEffectReport) => {
  return request.post('/training/report', data)
}

export const updateReport = (data: TrainingEffectReport) => {
  return request.put('/training/report', data)
}

export const deleteReport = (id: number) => {
  return request.delete(`/training/report/${id}`)
}

export const generateReport = (data: GenerateReportParams) => {
  return request.post('/training/report/generate', data)
}

export const publishReport = (id: number) => {
  return request.put(`/training/report/${id}/publish`)
}

// 学习进度
export const getLearnPage = (params: LearnPageParams) => {
  return request.get<PageResult<TrainingLearnProgress>>('/training/learn/page', params)
}

// 培训签到
export const getCheckinPage = (params: CheckinPageParams) => {
  return request.get<PageResult<TrainingCheckin>>('/training/checkin/page', params)
}

export const batchCheckin = (data: BatchCheckinParams) => {
  return request.post('/training/checkin/batch', data)
}

export const deleteCheckin = (id: number) => {
  return request.delete(`/training/checkin/${id}`)
}

// 课程管理
export const getCoursePage = (params: CoursePageParams) => {
  return request.get<PageResult<TrainingCourse>>('/training/course/page', params)
}

export const createCourse = (data: TrainingCourse) => {
  return request.post('/training/course', data)
}

export const updateCourse = (data: TrainingCourse) => {
  return request.put('/training/course', data)
}

export const deleteCourse = (id: number) => {
  return request.delete(`/training/course/${id}`)
}
