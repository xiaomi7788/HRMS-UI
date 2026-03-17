import request from '@/utils/request'

export interface RecruitCandidate {
  id?: number
  jobId?: number
  jobName?: string
  name?: string
  gender?: number
  phone?: string
  email?: string
  education?: string
  school?: string
  major?: string
  graduationYear?: number
  workYears?: number
  currentCompany?: string
  currentPosition?: string
  resumeUrl?: string
  source?: string
  stage?: number
  expectedSalary?: string
  offerSalary?: number
  interviewTimes?: number
  evaluator?: string
  remark?: string
  createTime?: string
  updateTime?: string
}

export interface CandidatePageParams {
  pageNum?: number
  pageSize?: number
  jobId?: number
  stage?: number
  keyword?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getCandidatePage = (params: CandidatePageParams) => {
  return request.get<PageResult<RecruitCandidate>>('/recruit/candidate/page', params)
}

export const deleteCandidate = (id: number) => {
  return request.delete(`/recruit/candidate/${id}`)
}
