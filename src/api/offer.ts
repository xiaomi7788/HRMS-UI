import request from '@/utils/request'
import type { RecruitInterview } from './interview'

export interface UpdateInterviewResult {
  result: number
  comment?: string
}

export const updateInterviewResult = (interviewId: number, data: UpdateInterviewResult) => {
  return request.put(`/recruit/candidate/interview/${interviewId}/result`, data)
}

export const getCandidatePage = (params: any) => {
  return request.get('/recruit/candidate/page', params)
}

export const listInterviews = (candidateId: number) => {
  return request.get<RecruitInterview[]>(`/recruit/candidate/${candidateId}/interview`)
}
