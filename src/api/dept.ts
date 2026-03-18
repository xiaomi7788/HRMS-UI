import request from '@/utils/request'

export interface Department {
  id?: number
  parentId?: number
  deptName?: string
  leaderId?: number
  leaderName?: string
  sort?: number
  status?: number
  children?: Department[]
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export interface DeptPageParams {
  pageNum?: number
  pageSize?: number
  deptName?: string
  status?: number
}

export const getDeptTree = (): Promise<Department[]> => {
  return request.get('/org/dept/tree')
}

export const getDeptPage = (params: DeptPageParams): Promise<PageResult<Department>> => {
  return request.get('/org/dept/page', params)
}

export const createDept = (data: Partial<Department>) => {
  return request.post('/org/dept', data)
}

export const updateDept = (data: Partial<Department>) => {
  return request.put('/org/dept', data)
}

export const deleteDept = (id: number) => {
  return request.delete(`/org/dept/${id}`)
}
