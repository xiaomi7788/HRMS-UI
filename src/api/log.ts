import request from '@/utils/request'

// 操作日志数据类型
export interface OperationLog {
  id?: number
  userId?: number
  username?: string
  module?: string
  operationType?: string
  description?: string
  requestUri?: string
  requestMethod?: string
  requestParams?: string
  result?: string
  errorMsg?: string
  clientIp?: string
  userAgent?: string
  costTime?: number
  createTime?: string
}

// 分页查询参数
export interface LogPageParams {
  pageNum: number
  pageSize: number
  userId?: number
  module?: string
  operationType?: string
  result?: string
  startTime?: string
  endTime?: string
}

// 分页响应数据
export interface PageResult<T> {
  records: T[]
  total: number
}

// 分页查询操作日志列表
export function getLogPage(params: LogPageParams) {
  return request.get<PageResult<OperationLog>>('/sys/log/page', params)
}

// 获取日志详情
export function getLogDetail(id: number) {
  return request.get<OperationLog>(`/sys/log/${id}`)
}
