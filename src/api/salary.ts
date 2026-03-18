import request from '@/utils/request'

export interface SalaryConfig {
  id?: number
  employeeId?: number
  baseSalary?: number
  positionAllowance?: number
  transportAllowance?: number
  mealAllowance?: number
  otherAllowance?: number
  socialInsuranceRate?: number
  housingFundRate?: number
  effectiveMonth?: string
  status?: number
  createTime?: string
  updateTime?: string
  deleted?: number
  employeeName?: string
  employeeNo?: string
}

export interface SalaryRecord {
  id?: number
  employeeId?: number
  employeeName?: string
  employeeNo?: string
  payMonth?: string
  baseSalary?: number
  allowance?: number
  bonus?: number
  overtimePay?: number
  socialInsurance?: number
  housingFund?: number
  deduction?: number
  taxableIncome?: number
  personalTax?: number
  actualPay?: number
  status?: number
  remark?: string
  createTime?: string
  updateTime?: string
}

export interface ConfigPageParams {
  pageNum?: number
  pageSize?: number
  keyword?: string
}

export interface RecordPageParams {
  pageNum?: number
  pageSize?: number
  employeeId?: number
  payMonth?: string
  status?: number
}

export interface CalculateParams {
  employeeId: number
  payMonth: string
  bonus?: number
  overtimePay?: number
  deduction?: number
  remark?: string
}

export interface BatchCalculateParams {
  payMonth: string
  bonus?: number
  overtimePay?: number
  deduction?: number
}

export interface PageResult<T> {
  total: number
  records: T[]
}

// 薪资档案
export const getConfigPage = (params: ConfigPageParams) => {
  return request.get<PageResult<SalaryConfig>>('/salary/config/page', params)
}

export const getConfigByEmployeeId = (employeeId: number) => {
  return request.get<SalaryConfig>(`/salary/config/${employeeId}`)
}

export const createConfig = (data: SalaryConfig) => {
  return request.post('/salary/config', data)
}

export const updateConfig = (data: SalaryConfig) => {
  return request.put('/salary/config', data)
}

// 薪酬记录
export const getRecordPage = (params: RecordPageParams) => {
  return request.get<PageResult<SalaryRecord>>('/salary/record/page', params)
}

export const calculate = (data: CalculateParams) => {
  return request.post<SalaryRecord>('/salary/record/calculate', data)
}

export const batchCalculate = (data: BatchCalculateParams) => {
  return request.post<{ calculated: number; records: SalaryRecord[] }>('/salary/record/batch-calculate', data)
}

export const confirmRecord = (id: number) => {
  return request.put(`/salary/record/${id}/confirm`)
}

export const getCostSummary = (payMonth?: string) => {
  return request.get('/salary/record/cost-summary', payMonth ? { payMonth } : undefined)
}

export const getCostTrend = (startMonth?: string, endMonth?: string) => {
  return request.get('/salary/record/cost-trend', { startMonth, endMonth })
}
