import request from '@/utils/request'

export interface AttendanceRule {
  id?: number
  ruleName?: string
  workStart?: string
  workEnd?: string
  lateThreshold?: number
  earlyThreshold?: number
  status?: number
}

export const getRuleList = () => {
  return request.get<AttendanceRule[]>('/attendance/rule/list')
}
