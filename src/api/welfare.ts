import request from '@/utils/request'

// ==================== 福利项目 ====================

// 福利项目
export interface WelfareItem {
  id?: number
  itemCode: string
  name: string
  welfareType: string
  amount?: number
  cycle?: string
  status: number
  isActive?: boolean
  description?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
}

// 福利项目分页结果
export interface WelfareItemPageResult {
  records: WelfareItem[]
  total: number
}

// 福利项目分页查询参数
export interface WelfareItemPageQuery {
  pageNum: number
  pageSize: number
  keyword?: string
  status?: number
}

// ==================== 福利发放记录 ====================

// 福利发放记录
export interface WelfareRecord {
  id?: number
  itemId: number
  itemName?: string
  employeeId: number
  employeeName?: string
  grantMonth: string
  amount: number
  grantDate: string
  status: number
  remark?: string
  createTime?: string
  updateTime?: string
  isDeleted?: number
}

// 福利发放记录分页结果
export interface WelfareRecordPageResult {
  records: WelfareRecord[]
  total: number
}

// 福利发放记录分页查询参数
export interface WelfareRecordPageQuery {
  pageNum: number
  pageSize: number
  employeeId?: number
  itemId?: number
  grantMonth?: string
  status?: number
}

// 新增福利项目
export function createWelfareItem(data: WelfareItem) {
  return request.post<void>('/salary/welfare/item', data)
}

// 更新福利项目
export function updateWelfareItem(data: WelfareItem) {
  return request.put<void>('/salary/welfare/item', data)
}

// 福利项目列表分页查询
export function getWelfareItemPage(params: WelfareItemPageQuery) {
  return request.get<WelfareItemPageResult>('/salary/welfare/item/page', params)
}

// 查询所有启用的福利项目
export function getWelfareItemList() {
  return request.get<WelfareItem[]>('/salary/welfare/item/list')
}

// 删除福利项目
export function deleteWelfareItem(id: number) {
  return request.delete<void>(`/salary/welfare/item/${id}`)
}

// 新增发放记录（支持多员工批量）
export function createWelfareRecord(data: {
  itemId: number
  employeeIds?: number[]
  employeeId?: number
  amount: number
  grantDate: string
  grantMonth: string
  remark?: string
}) {
  return request.post<void>('/salary/welfare/record', data)
}

// 更新发放记录（含标记已发放）
export function updateWelfareRecord(data: WelfareRecord) {
  return request.put<void>('/salary/welfare/record', data)
}

// 发放记录分页查询
export function getWelfareRecordPage(params: WelfareRecordPageQuery) {
  return request.get<WelfareRecordPageResult>('/salary/welfare/record/page', params)
}

// 删除发放记录
export function deleteWelfareRecord(id: number) {
  return request.delete<void>(`/salary/welfare/record/${id}`)
}

// ==================== 枚举值定义 ====================

// 福利类型
export enum WelfareType {
  SUBSIDY = 'SUBSIDY',
  GOODS = 'GOODS',
  INSURANCE = 'INSURANCE',
  OTHER = 'OTHER'
}

export const WELFARE_TYPE_OPTIONS = [
  { label: '补贴', value: WelfareType.SUBSIDY },
  { label: '实物', value: WelfareType.GOODS },
  { label: '保险', value: WelfareType.INSURANCE },
  { label: '其他', value: WelfareType.OTHER }
]

// 发放周期
export enum CycleType {
  MONTHLY = 'MONTHLY',
  QUARTERLY = 'QUARTERLY',
  YEARLY = 'YEARLY',
  IRREGULAR = 'IRREGULAR'
}

export const CYCLE_TYPE_OPTIONS = [
  { label: '每月', value: CycleType.MONTHLY },
  { label: '每季度', value: CycleType.QUARTERLY },
  { label: '每年', value: CycleType.YEARLY },
  { label: '不定期', value: CycleType.IRREGULAR }
]

// 福利状态
export enum WelfareStatus {
  DISABLED = 0,
  ENABLED = 1
}

export const WELFARE_STATUS_OPTIONS = [
  { label: '停用', value: WelfareStatus.DISABLED },
  { label: '启用', value: WelfareStatus.ENABLED }
]

// 发放记录状态
export enum RecordStatus {
  PENDING = 0,
  GRANTED = 1
}

export const RECORD_STATUS_OPTIONS = [
  { label: '待发放', value: RecordStatus.PENDING },
  { label: '已发放', value: RecordStatus.GRANTED }
]
