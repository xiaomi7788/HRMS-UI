import request from '@/utils/request'

export interface PerfTrack {
  id?: number
  perfResultId?: number
  perfResult?: PerfResultInfo
  employeeId?: number
  trackType?: string
  content?: string
  progressPercent?: number
  operatorId?: number
  operatorName?: string
  period?: string
  createTime?: string
  updateTime?: string
  deleted?: number
}

export interface PerfResultInfo {
  id?: number
  employeeName?: string
  employeeNo?: string
  totalScore?: number
  grade?: string
}

export interface TrackPageParams {
  pageNum?: number
  pageSize?: number
  perfResultId?: number
  employeeId?: number
  trackType?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getTrackPage = (params: TrackPageParams) => {
  return request.get<PageResult<PerfTrack>>('/performance/track/page', params)
}

export const createTrack = (data: PerfTrack) => {
  return request.post('/performance/track', data)
}

export const updateTrack = (data: PerfTrack) => {
  return request.put('/performance/track', data)
}

export const deleteTrack = (id: number) => {
  return request.delete(`/performance/track/${id}`)
}