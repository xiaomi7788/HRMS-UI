import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { SysMenu } from '@/api/auth'
import type { SysRole } from '@/api/role'

export interface UserInfo {
  id?: number
  username: string
  nickname?: string
  avatar?: string
  roles?: string[]
  role: string
  token?: string
  perms?: string[]
  roleId?: number // 角色ID
}

export const useUserStore = defineStore(
  'user',
  () => {
    // state
    const userInfo = ref<UserInfo | null>(null)
    const token = ref<string>(localStorage.getItem('hrm_token') || '')
    const menus = ref<SysMenu[]>([])
    const perms = ref<string[]>([])
    const roleList = ref<SysRole[]>([])

    // getters
    const isLoggedIn = computed(() => !!token.value)
    const username = computed(() => userInfo.value?.nickname || userInfo.value?.username || '')
    const roles = computed(() => userInfo.value?.roles || (userInfo.value?.role ? [userInfo.value.role] : []))

    // actions
    function setToken(newToken: string) {
      token.value = newToken
      if (newToken) {
        localStorage.setItem('hrm_token', newToken)
        console.log('setToken: token saved to localStorage', newToken);
      } else {
        localStorage.removeItem('hrm_token')
        console.log('setToken: token removed from localStorage');
      }
    }

    function setUserInfo(info: UserInfo) {
      userInfo.value = info
      if (info.token) {
        setToken(info.token)
      } else {
        // 如果没有提供token，但用户已登录，则生成一个简单的token
        setToken('mock_token_' + info.username)
      }
      localStorage.setItem('hrm_user_info', JSON.stringify(info))
      console.log('setUserInfo: userInfo saved to localStorage', info);
    }

    function loadUserInfo() {
      const storedToken = localStorage.getItem('hrm_token')
      const storedUserInfo = localStorage.getItem('hrm_user_info')
      if (storedToken && storedUserInfo) {
        token.value = storedToken
        userInfo.value = JSON.parse(storedUserInfo)
        console.log('loadUserInfo: userInfo and token loaded from localStorage', userInfo.value, token.value);
      } else {
        console.log('loadUserInfo: no userInfo or token found in localStorage');
      }
    }

    function logout() {
      userInfo.value = null
      token.value = ''
      localStorage.removeItem('hrm_token')
      localStorage.removeItem('hrm_user_info')
      console.log('logout: userInfo and token removed from localStorage');
    }

    function hasRole(role: string) {
      return roles.value.includes(role)
    }

    function setMenus(newMenus: SysMenu[]) {
      menus.value = newMenus
    }

    function setPerms(newPerms: string[]) {
      perms.value = newPerms
    }

    function hasPerm(perm: string) {
      return perms.value.includes(perm)
    }

    function setRoleList(newRoleList: SysRole[]) {
      roleList.value = newRoleList
    }

    function getRoleByCode(roleCode: string) {
      return roleList.value.find(role => role.roleCode === roleCode)
    }

    return {
      userInfo,
      token,
      menus,
      perms,
      roleList,
      isLoggedIn,
      username,
      roles,
      setToken,
      setUserInfo,
      setMenus,
      setPerms,
      hasPerm,
      loadUserInfo,
      logout,
      hasRole,
      setRoleList,
      getRoleByCode,
    }
  },
)
