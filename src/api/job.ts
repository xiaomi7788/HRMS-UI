import request from '@/utils/request'

export interface RecruitJob {
  id?: number
  jobName?: string
  deptId?: number
  deptName?: string
  headcount?: number
  hiredCount?: number
  education?: string
  experience?: string
  salaryMin?: number
  salaryMax?: number
  description?: string
  requirement?: string
  deadline?: string
  status?: number
  createTime?: string
  updateTime?: string
}

export interface JobPageParams {
  pageNum?: number
  pageSize?: number
  keyword?: string
  status?: number
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getJobPage = (params: JobPageParams) => {
  return request.get<PageResult<RecruitJob>>('/recruit/job/page', params)
}

export const createJob = (data: Partial<RecruitJob>) => {
  return request.post('/recruit/job', data)
}

export const updateJob = (data: Partial<RecruitJob>) => {
  return request.put('/recruit/job', data)
}

export const deleteJob = (id: number) => {
  return request.delete(`/recruit/job/${id}`)
}

export const closeJob = (id: number) => {
  return request.put(`/recruit/job/${id}/close`)
}

export const getJobList = (status?: number) => {
  return request.get<RecruitJob[]>('/recruit/job/list', status !== undefined ? { status } : undefined)
}
