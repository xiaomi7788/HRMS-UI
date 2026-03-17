import request from '@/utils/request'

export interface LoginParams {
  username: string
  password: string
}

export interface LoginResult {
  token: string
  id: number
  username: string
  nickname: string
  avatar: string
  roles: string[]
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
