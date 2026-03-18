<template>
  <el-container class="common-layout">
    <el-header class="header">
      <div class="header-left">
        <div class="logo-container">
          <img src="@/assets/logo.svg" alt="HRM Logo" class="logo">
          <h3 class="title">HRMS</h3>
        </div>
        <el-menu
          :default-active="activeMenu"
          class="el-menu-demo"
          mode="horizontal"
          router
          background-color="#2b2b2b"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
        >
          <!-- <el-menu-item index="/user">
            <el-icon><House /></el-icon>
            <span>个人中心</span>
          </el-menu-item> -->

          <!-- 动态菜单 -->
          <DynamicMenu :menus="dynamicMenus" v-if="dynamicMenus.length > 0" />

          <!-- 部门经理附加功能 -->
          <el-sub-menu v-if="userStore.hasRole('manager')" index="manager-functions">
            <template #title>
              <el-icon><Management /></el-icon>
              <span>团队管理</span>
            </template>
            <el-menu-item index="/user/manager/team-employee-list">
              <el-icon><UserFilled /></el-icon>
              <span>团队员工列表</span>
            </el-menu-item>
            <el-menu-item index="/user/manager/team-attendance-view">
              <el-icon><Calendar /></el-icon>
              <span>团队考勤查看</span>
            </el-menu-item>
            <el-menu-item index="/user/manager/team-performance-view">
              <el-icon><TrendCharts /></el-icon>
              <span>团队绩效查看</span>
            </el-menu-item>
            <el-menu-item index="/user/manager/approval-center">
              <el-icon><Connection /></el-icon>
              <span>审批中心</span>
            </el-menu-item>
          </el-sub-menu>
        </el-menu>
      </div>
      <div class="header-right">
        <div class="breadcrumb-container">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item v-for="(item, index) in breadcrumbs" :key="index" :to="item.path">
              {{ item.meta.title }}
            </el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="user-info">
          <el-dropdown>
            <span class="el-dropdown-link">
              <el-avatar :size="30" :src="userStore.userInfo?.avatar || 'https://cube.elemecdn.com/3/7c/3ed6826170ee4e3fdeb8e64338717jpeg.jpeg'" class="user-avatar"></el-avatar>
              <span class="username">{{ userStore.username }}</span>
              <el-icon class="el-icon--right"><arrow-down /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </el-header>
    <el-container>
      <el-main class="main-content" v-loading="uiStore.isLoading">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { useUiStore } from '@/stores/ui';
import { ElMessage } from 'element-plus';
import DynamicMenu from '@/components/DynamicMenu.vue';
import { getAllMenus, type SysMenu } from '@/api/auth';
import {
  House,
  Management,
  UserFilled,
  TrendCharts,
  Connection,
} from '@element-plus/icons-vue';

// 匹配 DynamicMenu 组件的菜单类型
interface MenuItem {
  id: number
  parentId: number | null
  title: string
  path: string
  icon?: string
  children?: MenuItem[]
  menuType?: number
}

// 将平铺菜单数据转换为树形结构，并过滤掉没有子菜单的目录
function buildMenuTree(menus: SysMenu[]): MenuItem[] {
  console.log('原始菜单数据:', menus)
  const map = new Map<string, MenuItem>()
  const roots: MenuItem[] = []

  // 处理可能的字段名差异
  menus.forEach(menu => {
    const normalizedMenu: MenuItem = {
      id: Number(menu.id),
      parentId: menu.parentId ? Number(menu.parentId) : 0,
      title: menu.menuName || menu.title || '未命名菜单',
      path: menu.path || '',
      icon: menu.icon,
      children: [],
      menuType: menu.menuType
    }
    map.set(String(menu.id), normalizedMenu)
  })

  menus.forEach(menu => {
    const node = map.get(String(menu.id))!
    const pid = menu.parentId ? String(menu.parentId) : '0'
    if (pid === '0' || pid === 'null' || pid === null || pid === undefined) {
      roots.push(node)
    } else {
      const parent = map.get(pid)
      if (parent) {
        parent.children = parent.children || []
        parent.children.push(node)
      }
    }
  })

  // 递归过滤空目录（目录类型menuType=0且没有子菜单）
  function filterEmptyMenus(items: MenuItem[]): MenuItem[] {
    return items.filter(item => {
      // 如果有子菜单，递归过滤
      if (item.children && item.children.length > 0) {
        item.children = filterEmptyMenus(item.children)
        // 过滤后如果有子菜单，保留；否则如果是目录类型则移除
        return item.children.length > 0
      }
      // 没有子菜单的情况：如果是目录类型(menuType=0)则过滤掉，保留菜单类型(menuType=1)
      return item.menuType !== 0
    })
  }

  const filteredRoots = filterEmptyMenus(roots)
  console.log('转换后的菜单树:', filteredRoots)
  return filteredRoots
}

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const uiStore = useUiStore();

const activeMenu = ref(route.path);
const dynamicMenus = ref<MenuItem[]>([]);

// 加载菜单
async function loadMenus() {
  try {
    const userInfo = userStore.userInfo
    const roles = userInfo?.roles || []

    console.log('loadMenus - userInfo:', userInfo)
    console.log('loadMenus - roles:', roles)

    // 获取所有菜单
    let menus: SysMenu[] = []
    try {
      menus = await getAllMenus()
      console.log('所有菜单原始数据:', menus)
    } catch (error) {
      console.warn('获取菜单失败，降级处理:', error)
      menus = []
    }

    // 收集用户端菜单的父ID
    const userMenuParentIds = new Set<string>()
    
    // 先过滤出用户端菜单
    const userMenuItems = menus.filter(menu => {
      const isSelfPath = menu.path?.startsWith('/self/')
      const isUserSelfPath = menu.path?.startsWith('/user/self/')
      const isUserMenu = isSelfPath || isUserSelfPath
      const isButtonType = menu.menuType === 2
      const hasPath = menu.path && menu.path.length > 0
      console.log(`菜单ID: ${menu.id}, 名称: ${menu.menuName}, 路径: ${menu.path}, 类型: ${menu.menuType}, 是否用户端: ${isUserMenu}, 是否按钮: ${isButtonType}`)
      
      if (isUserMenu && !isButtonType && hasPath) {
        // 记录父ID
        if (menu.parentId && String(menu.parentId) !== '0') {
          userMenuParentIds.add(String(menu.parentId))
        }
        return true
      }
      return false
    })
    console.log('用户端菜单项:', userMenuItems)
    console.log('用户端菜单的父ID:', Array.from(userMenuParentIds))
    
    // 获取用户端菜单的父目录
    const parentMenus = menus.filter(menu => 
      userMenuParentIds.has(String(menu.id))
    )
    console.log('用户端菜单的父目录:', parentMenus)
    
    // 合并用户端菜单和它们的父目录
    const userMenus = [...userMenuItems, ...parentMenus]
    console.log('合并后的用户端菜单:', userMenus)

    // 将平铺数据转换为树形结构
    const menuTree = buildMenuTree(userMenus)
    dynamicMenus.value = menuTree

    // 转换为 SysMenu 类型存入 store（兼容老代码）
    userStore.setMenus(menus as any)
  } catch (error) {
    console.error('获取菜单失败:', error)
  }
}

  onMounted(() => {
    // 如果store中有菜单则使用，否则重新获取
    if (userStore.menus.length > 0) {
      const allMenus = userStore.menus as any
      
      // 收集用户端菜单的父ID
      const userMenuParentIds = new Set<string>()
      
      // 先过滤出用户端菜单
      const userMenuItems = allMenus.filter((menu: any) => {
        const isSelfPath = menu.path?.startsWith('/self/')
        const isUserSelfPath = menu.path?.startsWith('/user/self/')
        const isUserMenu = isSelfPath || isUserSelfPath
        const isButtonType = menu.menuType === 2
        
        if (isUserMenu && !isButtonType) {
          // 记录父ID
          if (menu.parentId && String(menu.parentId) !== '0') {
            userMenuParentIds.add(String(menu.parentId))
          }
          return true
        }
        return false
      })
      
      // 获取用户端菜单的父目录
      const parentMenus = allMenus.filter((menu: any) => 
        userMenuParentIds.has(String(menu.id))
      )
      
      // 合并用户端菜单和它们的父目录
      const userMenus = [...userMenuItems, ...parentMenus]
      dynamicMenus.value = buildMenuTree(userMenus)
    } else {
      loadMenus()
    }
  })

watch(
  () => route.path,
  (newPath) => {
    activeMenu.value = newPath;
  }
);

const breadcrumbs = computed(() => {
  const matched = route.matched.filter(item => item.meta && item.meta.title);
  return matched;
});

const logout = () => {
  userStore.logout();
  ElMessage.success('已退出登录');
  router.push('/login');
};
</script>

<style scoped>
.common-layout {
  height: 100vh;
}

.header {
  background-color: #2b2b2b; /* 与导航栏背景色一致 */
  color: #fff; /* 调整文字颜色以适应深色背景 */
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #d8dce5;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
  height: 60px; /* 保持header高度 */
}

.header-left {
  display: flex;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
}

.logo-container {
  display: flex;
  align-items: center;
  padding-right: 20px; /* 增加logo和菜单之间的间距 */
}

.logo {
  width: 52px;
  height: 52px;
  margin-right: 10px;
}

.title {
  color: #fff; /* 调整标题颜色以适应深色背景 */
  font-size: 18px;
  margin: 0;
}

.el-menu-demo {
  border-bottom: none; /* 移除横向菜单底部的边框 */
  flex-grow: 1; /* 让菜单占据剩余空间 */
  overflow-x: auto; /* 允许横向滚动 */
  white-space: nowrap; /* 防止菜单项换行 */
}

.el-menu--horizontal > .el-menu-item {
  height: 60px; /* 菜单项高度与header一致 */
  line-height: 60px;
}

.el-menu--horizontal > .el-sub-menu .el-sub-menu__title {
  height: 60px;
  line-height: 60px;
}

.breadcrumb-container {
  display: flex;
  align-items: center;
  font-size: 14px;
  margin-right: 20px; /* 面包屑与用户信息之间的间距 */
}
.breadcrumb-container :deep(.el-breadcrumb__inner) {
  color: #fff; /* 将面包屑字体颜色改为白色 */
}

.user-info {
  display: flex;
  align-items: center;
}

.el-dropdown-link {
  cursor: pointer;
  color: #409eff;
  display: flex;
  align-items: center;
  outline: none !important;
  border: none !important;
}

.user-avatar {
  margin-right: 8px;
}

.username {
  margin-right: 8px;
  font-size: 14px;
  color: #fff;
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
  width: 100%;
}
</style>
