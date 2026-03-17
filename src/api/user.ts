import request from '@/utils/request'

// 用户数据类型
export interface SysUser {
  id?: number
  username: string
  password?: string
  realName?: string
  email?: string
  phone?: string
  avatar?: string
  status: number
  employeeId?: number
  roleIds?: number[]
  createTime?: string
  roles?: string[]
}

// 分页查询参数
export interface UserPageParams {
  pageNum: number
  pageSize: number
  keyword?: string
}

// 分页响应数据
export interface PageResult<T> {
  records: T[]
  total: number
}

// 分页查询用户列表
export function getUserPage(params: UserPageParams) {
  return request.get<PageResult<SysUser>>('/sys/user/page', params)
}

// 新增用户
export function createUser(data: SysUser) {
  return request.post<void>('/sys/user', data)
}

// 更新用户
export function updateUser(data: SysUser) {
  return request.put<void>('/sys/user', data)
}

// 删除用户
export function deleteUser(id: number) {
  return request.delete<void>(`/sys/user/${id}`)
}

// 获取用户已分配角色ID列表
export function getUserRoles(id: number) {
  return request.get<number[]>(`/sys/user/${id}/roles`)
}

// 给用户分配角色
export function assignUserRoles(id: number, roleIds: number[]) {
  return request.put<void>(`/sys/user/${id}/roles`, { roleIds })
}

// 重置密码
export function resetPassword(id: number, newPassword: string) {
  return request.put<void>(`/sys/user/${id}/password`, { newPassword })
}
