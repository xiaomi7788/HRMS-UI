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
  pageNum?: number
  pageSize?: number
  employeeNo?: string
  employeeName?: string
  deptId?: number
  positionId?: number
  status?: number
}

export interface TransferDTO {
  id: number
  targetDeptId: number
  targetPositionId: number
  effectiveDate: string
  reason?: string
}

export interface LeaveDTO {
  id: number
  leaveDate: string
  reason?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getEmployeePage = (params: EmployeePageParams) => {
  return request.get<PageResult<Employee>>('/org/employee/page', params)
}

export const getEmployeeById = (id: number) => {
  return request.get<Employee>(`/org/employee/${id}`)
}

export const createEmployee = (data: Employee) => {
  return request.post('/org/employee', data)
}

export const updateEmployee = (data: Employee) => {
  return request.put('/org/employee', data)
}

export const deleteEmployee = (id: number) => {
  return request.delete(`/org/employee/${id}`)
}

export const exportEmployee = (params?: EmployeePageParams) => {
  return request.get('/org/employee/export', params, { responseType: 'blob' })
}

export const transferEmployee = (data: TransferDTO) => {
  return request.put(`/org/employee/${data.id}/transfer`, data)
}

export const regularEmployee = (id: number, data: { regularDate: string; comment?: string }) => {
  return request.put(`/org/employee/${id}/regular`, { regularDate: data.regularDate })
}

export const leaveEmployee = (data: LeaveDTO) => {
  return request.put(`/org/employee/${data.id}/leave`, data)
}
