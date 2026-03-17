import request from '@/utils/request'

export interface Employee {
  id?: number
  empCode?: string
  empName?: string
  gender?: number
  birthday?: string
  idCard?: string
  phone?: string
  email?: string
  bankAccount?: string
  bankName?: string
  education?: string
  school?: string
  major?: string
  emergencyContact?: string
  emergencyPhone?: string
  workType?: string
  remark?: string
  deptId?: number
  deptName?: string
  positionId?: number
  positionName?: string
  leaderId?: number
  leaderName?: string
  entryDate?: string
  regularDate?: string
  leaveDate?: string
  workStatus?: number
  contractStart?: string
  contractEnd?: string
  avatar?: string
  createTime?: string
}

export interface EmployeePageParams {
  pageNum: number
  pageSize: number
  deptId?: number
  workStatus?: number
  keyword?: string
}

export interface PageResult<T> {
  records: T[]
  total: number
}

export interface TransferDTO {
  deptId: number
  positionId?: number
  effectiveDate: string
  remark?: string
}

export interface LeaveDTO {
  leaveDate: string
  reason?: string
}

export const getEmployeePage = (params: EmployeePageParams): Promise<PageResult<Employee>> => {
  return request.get('/org/employee/page', params)
}

export const getEmployee = (id: number): Promise<Employee> => {
  return request.get(`/org/employee/${id}`)
}

export const createEmployee = (data: Partial<Employee>) => {
  return request.post('/org/employee', data)
}

export const updateEmployee = (data: Partial<Employee>) => {
  return request.put('/org/employee', data)
}

export const deleteEmployee = (id: number) => {
  return request.delete(`/org/employee/${id}`)
}

export const transferEmployee = (id: number, data: TransferDTO) => {
  return request.put(`/org/employee/${id}/transfer`, data)
}

export const regularEmployee = (id: number, regularDate?: string) => {
  return request.put(`/org/employee/${id}/regular`, { regularDate })
}

export const leaveEmployee = (id: number, data: LeaveDTO) => {
  return request.put(`/org/employee/${id}/leave`, data)
}

export const uploadAvatar = (id: number, file: File): Promise<string> => {
  const formData = new FormData()
  formData.append('file', file)
  return request.post(`/org/employee/${id}/avatar`, formData)
}

export const exportEmployee = (params?: { deptId?: number; workStatus?: number; keyword?: string }) => {
  const queryString = new URLSearchParams()
  if (params?.deptId) queryString.append('deptId', params.deptId.toString())
  if (params?.workStatus !== undefined) queryString.append('workStatus', params.workStatus.toString())
  if (params?.keyword) queryString.append('keyword', params.keyword)
  window.location.href = `/api/org/employee/export?${queryString.toString()}`
}
