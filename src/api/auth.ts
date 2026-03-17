import request from '@/utils/request'

export interface LoginParams {
  username: string
  password: string
  captcha: string
  captchaKey: string
}

export interface CaptchaResult {
  key: string
  image: string
}

export interface LoginResult {
  token: string
  userId: number
  username: string
  realName: string
  avatar: string
  roles: string[]
  perms: string[]
  employeeId: number
  roleId?: number // 角色ID
}

// 获取验证码
export function getCaptcha() {
  return request.get<CaptchaResult>('/auth/captcha')
}

// 登录
export function login(data: LoginParams) {
  return request.post<LoginResult>('/auth/login', data)
}

// 退出登录
export function logout() {
  return request.post('/auth/logout')
}

// 获取当前用户信息
export function getUserInfo() {
  return request.get<LoginResult>('/auth/info')
}

// 菜单类型定义（匹配后端 SysMenu 实体）
export interface SysMenu {
  id: number
  parentId: number | null
  menuName?: string     // 后端字段：菜单名称
  title?: string       // 前端兼容字段
  path: string
  name?: string
  icon?: string
  component?: string
  sort?: number         // 后端字段：排序
  status?: number      // 后端字段：状态
  perms?: string
  menuType?: number     // 后端字段：菜单类型 (0目录/1菜单/2按钮)
  children?: SysMenu[]
}

// 获取菜单树（所有菜单）
export function getMenuTree() {
  return request.get<SysMenu[]>('/sys/menu/tree')
}

// 获取角色已分配的菜单
export function getRoleMenus(roleId: number) {
  return request.get<SysMenu[]>(`/sys/role/${roleId}/menus`)
}

// 获取所有菜单树（无需角色权限）
export function getAllMenus() {
  return request.get<SysMenu[]>('/sys/menu/tree')
}
