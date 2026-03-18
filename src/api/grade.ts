import request from '@/utils/request'

export interface SalaryGrade {
  id?: number
  gradeCode?: string
  gradeName?: string
  series?: string
  minSalary?: number
  maxSalary?: number
  midSalary?: number
  positionAllowance?: number
  remark?: string
  status?: number
  createTime?: string
  updateTime?: string
  deleted?: number
}

export interface GradePageParams {
  pageNum?: number
  pageSize?: number
  series?: string
  status?: number
  keyword?: string
}

export interface PageResult<T> {
  total: number
  records: T[]
}

export const getGradePage = (params: GradePageParams) => {
  return request.get<PageResult<SalaryGrade>>('/salary/grade/page', params)
}

export const getGradeList = () => {
  return request.get<SalaryGrade[]>('/salary/grade/list')
}

export const createGrade = (data: SalaryGrade) => {
  return request.post('/salary/grade', data)
}

export const updateGrade = (data: SalaryGrade) => {
  return request.put('/salary/grade', data)
}

export const deleteGrade = (id: number) => {
  return request.delete(`/salary/grade/${id}`)
}
