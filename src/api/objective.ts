import request from '@/utils/request'

export interface PerfObjective {
  id?: number
  planId?: number
  employeeId?: number
  parentId?: number | null
  objectiveType?: string
  title?: string
  description?: string
  priority?: string
  weight?: number
  targetValue?: number
  actualValue?: number
  progressPercent?: number
  startDate?: string
  dueDate?: string
  alignedObjectiveId?: number | null
  status?: number
  period?: string
  createTime?: string
  updateTime?: string
  deleted?: number
  employeeName?: string
  employeeNo?: string
  alignedObjectiveTitle?: string
  children?: PerfObjective[]
}

export interface ObjectivePageParams {
  pageNum?: number
  pageSize?: number
  planId?: number
  employeeId?: number
  period?: string
  objectiveType?: string
}

export interface ProgressUpdateParams {
  progressPercent?: number
  actualValue?: number
  status?: number
}

export interface AlignParams {
  alignedObjectiveId?: number | null
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getObjectivePage = (params: ObjectivePageParams) => {
  return request.get<PageResult<PerfObjective>>('/performance/objective/page', params)
}

export const getObjectiveTree = (params?: { planId?: number; employeeId?: number; period?: string }) => {
  return request.get<PerfObjective[]>('/performance/objective/tree', params)
}

export const getObjectiveDetail = (id: number) => {
  return request.get<PerfObjective>(`/performance/objective/${id}`)
}

export const createObjective = (data: PerfObjective) => {
  return request.post('/performance/objective', data)
}

export const updateObjective = (data: PerfObjective) => {
  return request.put('/performance/objective', data)
}

export const updateProgress = (id: number, data: ProgressUpdateParams) => {
  return request.put(`/performance/objective/${id}/progress`, data)
}

export const alignObjective = (id: number, data: AlignParams) => {
  return request.put(`/performance/objective/${id}/align`, data)
}

export const deleteObjective = (id: number) => {
  return request.delete(`/performance/objective/${id}`)
}

export const getMyObjectives = (params?: { period?: string; objectiveType?: string }) => {
  return request.get<PerfObjective[]>('/performance/objective/my', params)
}

export const getAlignCandidates = (params?: { period?: string; excludeEmployeeId?: number }) => {
  return request.get<PerfObjective[]>('/performance/objective/align-candidates', params)
}
