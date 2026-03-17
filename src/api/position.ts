import request from '@/utils/request'

export interface Position {
  id?: number
  positionCode?: string
  positionName?: string
  deptId?: number
  level?: string
  sort?: number
  jobDesc?: string
  requirements?: string
  status?: number
  createTime?: string
  updateTime?: string
}

export interface PositionPageParams {
  pageNum: number
  pageSize: number
  deptId?: number
  keyword?: string
}

export interface PageResult<T> {
  records: T[]
  total: number
}

export const getPositionPage = (params: PositionPageParams): Promise<PageResult<Position>> => {
  return request.get('/org/position/page', params)
}

export const getPositionList = (deptId?: number): Promise<Position[]> => {
  return request.get('/org/position/list', { deptId })
}

export const createPosition = (data: Partial<Position>) => {
  return request.post('/org/position', data)
}

export const updatePosition = (data: Partial<Position>) => {
  return request.put('/org/position', data)
}

export const deletePosition = (id: number) => {
  return request.delete(`/org/position/${id}`)
}
