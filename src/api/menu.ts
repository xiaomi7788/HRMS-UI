import request from '@/utils/request'

// 菜单数据类型
export interface SysMenu {
  id: number
  parentId: number
  menuName: string
  perms?: string
  menuType: number
  path?: string
  component?: string
  icon?: string
  sort: number
  status: number
  createTime?: string
  updateTime?: string
  children?: SysMenu[]
}

// 获取菜单树（用于前端路由渲染）
export function getMenuTree() {
  return request.get<SysMenu[]>('/sys/menu/tree')
}

// 获取所有菜单（平铺，用于角色分配权限）
export function getMenuList() {
  return request.get<SysMenu[]>('/sys/menu/list')
}

// 新增菜单
export function createMenu(data: SysMenu) {
  return request.post<void>('/sys/menu', data)
}

// 更新菜单
export function updateMenu(data: SysMenu) {
  return request.put<void>('/sys/menu', data)
}

// 删除菜单
export function deleteMenu(id: number) {
  return request.delete<void>(`/sys/menu/${id}`)
}
