import request from '@/utils/request'

export interface EmployeeVO {
  id?: number
  empCode?: string
  empName?: string
  gender?: number
  phone?: string
  email?: string
  deptId?: number
  deptName?: string
  positionId?: number
  positionName?: string
  workStatus?: number
  entryDate?: string
  birthday?: string
  idCard?: string
  bankCard?: string
  address?: string
}

export interface DirectoryParams {
  pageNum?: number
  pageSize?: number
  deptId?: number
  keyword?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getDirectory = (params: DirectoryParams) => {
  return request.get<PageResult<EmployeeVO>>('/self/directory', params)
}
