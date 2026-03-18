import request from '@/utils/request'

export interface SocialAccount {
  id?: number
  employeeId?: number
  employeeName?: string
  empCode?: string
  socialSecurityNo?: string
  housingFundNo?: string
  city?: string
  startMonth?: string
  endMonth?: string
  socialBase?: number
  fundBase?: number
  personalSocialRate?: number
  companySocialRate?: number
  personalFundRate?: number
  companyFundRate?: number
  status?: number
  remark?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
}

export interface SocialRecord {
  id?: number
  accountId?: number
  employeeId?: number
  employeeName?: string
  empCode?: string
  city?: string
  payMonth?: string
  personalPension?: number
  companyPension?: number
  personalMedical?: number
  companyMedical?: number
  personalUnemployment?: number
  companyUnemployment?: number
  companyInjury?: number
  companyMaternity?: number
  personalHousingFund?: number
  companyHousingFund?: number
  personalTotal?: number
  companyTotal?: number
  total?: number
  status?: number
  declareDate?: string
  payDate?: string
  remark?: string
  createTime?: string
  updateTime?: string
}

export interface SocialSummary {
  employeeId?: number
  employeeName?: string
  empCode?: string
  payMonth?: string
  personalTotal?: number
  companyTotal?: number
  total?: number
}

export interface AccountPageParams {
  pageNum?: number
  pageSize?: number
  employeeId?: number
  status?: number
  city?: string
}

export interface RecordPageParams {
  pageNum?: number
  pageSize?: number
  employeeId?: number
  payMonth?: string
  status?: number
}

export interface GenerateRecordParams {
  payMonth: string
}

export interface UpdateStatusParams {
  status: number
  declareDate?: string
  payDate?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

// 账户管理
export const getAccountPage = (params: AccountPageParams) => {
  return request.get<PageResult<SocialAccount>>('/salary/social/page', params)
}

export const createAccount = (data: SocialAccount) => {
  return request.post('/salary/social', data)
}

export const updateAccount = (data: SocialAccount) => {
  return request.put('/salary/social', data)
}

export const stopAccount = (id: number) => {
  return request.put(`/salary/social/${id}/stop`)
}

export const deleteAccount = (id: number) => {
  return request.delete(`/salary/social/${id}`)
}

// 缴纳记录
export const getRecordPage = (params: RecordPageParams) => {
  return request.get<PageResult<SocialRecord>>('/salary/social/record/page', params)
}

export const generateRecords = (data: GenerateRecordParams) => {
  return request.post('/salary/social/record/generate', data)
}

export const updateRecordStatus = (id: number, data: UpdateStatusParams) => {
  return request.put(`/salary/social/record/${id}/status`, data)
}

export const getRecordSummary = (payMonth?: string) => {
  return request.get<SocialSummary[]>('/salary/social/record/summary', payMonth ? { payMonth } : undefined)
}
