import request from '@/utils/request'

export interface PerfPlan {
  id?: number
  planName?: string
  cycle?: string
  year?: number
  period?: number
  kpiWeight?: number
  behaviorWeight?: number
  evaluationWeight?: number
  status?: number
  description?: string
}

export interface PerfResult {
  id?: number
  planId?: number
  employeeId?: number
  employeeName?: string
  employeeNo?: string
  empName?: string
  empCode?: string
  deptName?: string
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
}

export interface PlanPageParams {
  pageNum?: number
  pageSize?: number
  year?: number
}

export interface ResultPageParams {
  pageNum?: number
  pageSize?: number
  planId?: number
  employeeId?: number
  keyword?: string
  status?: number
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getPlanPage = (params: PlanPageParams) => {
  return request.get<PageResult<PerfPlan>>('/performance/plan/page', params)
}

export const createPlan = (data: PerfPlan) => {
  return request.post('/performance/plan', data)
}

export const updatePlan = (data: PerfPlan) => {
  return request.put('/performance/plan', data)
}

export const deletePlan = (id: number) => {
  return request.delete(`/performance/plan/${id}`)
}

export const getResultPage = (params: ResultPageParams) => {
  return request.get<PageResult<PerfResult>>('/performance/result/page', params)
}

export const submitResult = (data: PerfResult) => {
  return request.post('/performance/result', data)
}

export const updateResult = (data: PerfResult) => {
  console.log('updateResult', data);

  return request.put('/performance/result', data)
}

export const calibrateResult = (id: number, data: { grade?: string; totalScore?: number; comment?: string }) => {
  return request.put(`/performance/result/${id}/calibrate`, data)
}

export const deleteResult = (id: number) => {
  return request.delete(`/performance/result/${id}`)
}
