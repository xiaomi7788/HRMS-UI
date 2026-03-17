import request from '@/utils/request'

// 角色数据类型
export interface SysRole {
  id?: number
  roleName: string
  roleCode: string
  dataScope?: number
  description?: string
  status: number
  createTime?: string
  updateTime?: string
}

// 分页查询参数
export interface RolePageParams {
  pageNum: number
  pageSize: number
  keyword?: string
}

// 分页响应数据
export interface PageResult<T> {
  records: T[]
  total: number
}

// 分页查询角色列表
export function getRolePage(params: RolePageParams) {
  return request.get<PageResult<SysRole>>('/sys/role/page', params)
}

// 角色下拉列表（全量）
export function getRoleList() {
  return request.get<SysRole[]>('/sys/role/list')
}

// 新增角色
export function createRole(data: SysRole) {
  return request.post<void>('/sys/role', data)
}

// 更新角色
export function updateRole(data: SysRole) {
  return request.put<void>('/sys/role', data)
}

// 删除角色
export function deleteRole(id: number) {
  return request.delete<void>(`/sys/role/${id}`)
}

// 查询角色已分配的菜单ID列表
export function getRoleMenus(roleId: number) {
  return request.get<number[]>(`/sys/role/${roleId}/menus`)
}

// 给角色分配菜单
export function assignRoleMenus(roleId: number, menuIds: number[]) {
  return request.put<void>(`/sys/role/${roleId}/menus`, { menuIds })
}
