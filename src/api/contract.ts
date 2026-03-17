import request from '@/utils/request'

export interface Contract {
  id?: number
  employeeId?: number
  empName?: string
  empCode?: string
  deptName?: string
  contractNo?: string
  contractType?: string
  startDate?: string
  endDate?: string
  signDate?: string
  probationEnd?: string
  status?: number
  fileUrl?: string
  remark?: string
  createTime?: string
  daysToExpire?: number
}

export interface ContractPageParams {
  pageNum: number
  pageSize: number
  keyword?: string
  status?: number
  expiringDays?: number
}

export interface PageResult<T> {
  records: T[]
  total: number
}

export const getContractPage = (params: ContractPageParams): Promise<PageResult<Contract>> => {
  return request.get('/org/contract/page', params)
}

export const getExpiringContracts = (days?: number): Promise<Contract[]> => {
  return request.get('/org/contract/expiring', { days: days || 30 })
}

export const createContract = (data: Partial<Contract>) => {
  return request.post('/org/contract', data)
}

export const updateContract = (data: Partial<Contract>) => {
  return request.put('/org/contract', data)
}

export const terminateContract = (id: number) => {
  return request.put(`/org/contract/${id}/terminate`)
}

export const renewContract = (oldId: number, data: Partial<Contract>) => {
  return request.post(`/org/contract/${oldId}/renew`, data)
}

export const deleteContract = (id: number) => {
  return request.delete(`/org/contract/${id}`)
}
