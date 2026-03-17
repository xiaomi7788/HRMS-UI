import request from '@/utils/request'
import { type RecruitCandidate } from './candidate'

export interface RecruitInterview {
  id?: number
  candidateId?: number
  jobId?: number
  round?: number
  interviewerId?: number
  interviewerName?: string
  interviewTime?: string
  type?: number
  result?: number
  score?: number
  comment?: string
  nextRound?: number
  nextTime?: string
  createTime?: string
  updateTime?: string
}

export const addInterview = (candidateId: number, data: Partial<RecruitInterview>) => {
  return request.post(`/recruit/candidate/${candidateId}/interview`, data)
}

export const listInterviews = (candidateId: number) => {
  return request.get<RecruitInterview[]>(`/recruit/candidate/${candidateId}/interview`)
}

export const updateStage = (candidateId: number, stage: number) => {
  return request.put(`/recruit/candidate/${candidateId}/stage`, { stage })
}

export const updateCandidate = (data: Partial<RecruitCandidate>) => {
  return request.put('/recruit/candidate', data)
}

export const createCandidate = (data: Partial<RecruitCandidate>) => {
  return request.post('/recruit/candidate', data)
}
