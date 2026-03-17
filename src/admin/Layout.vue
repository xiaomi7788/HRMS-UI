<template>
  <el-container class="common-layout">
    <el-aside width="200px" class="aside">
      <div class="logo-container">
        <img src="@/assets/logo.svg" alt="HRM Logo" class="logo">
        <h3 class="title">HRMS</h3>
      </div>
      <div class="menu-container">
        <el-menu
          :default-active="activeMenu"
          class="el-menu-vertical-demo"
          router
          background-color="#2b2b2b"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
        >
          <!-- 仪表盘固定显示 -->
          <el-menu-item index="/admin">
            <el-icon><House /></el-icon>
            <span>仪表盘</span>
          </el-menu-item>

          <!-- 动态菜单 -->
          <DynamicMenu :menus="dynamicMenus" v-if="dynamicMenus.length > 0" />

          <!-- 如果没有动态菜单，显示提示 -->
          <el-menu-item v-else index="" disabled>
            <span>暂无菜单权限</span>
          </el-menu-item>
        </el-menu>
      </div>
    </el-aside>
    <el-container>
      <el-header class="header">
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
      </el-header>
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
import { House, ArrowDown } from '@element-plus/icons-vue';
import DynamicMenu from '@/components/DynamicMenu.vue';
import { getAllMenus, type SysMenu } from '@/api/auth';

// 匹配 DynamicMenu 组件的菜单类型
interface MenuItem {
  id: number
  parentId: number | null
  title: string
  path: string
  icon?: string
  children?: MenuItem[]
}

// 将平铺菜单数据转换为树形结构
function buildMenuTree(menus: SysMenu[]): MenuItem[] {
  console.log('原始菜单数据:', menus)
  // 后端返回的 id 和 parentId 可能是字符串，使用 string 作为 key
  const map = new Map<string, MenuItem>()
  const roots: MenuItem[] = []

  // 处理可能的字段名差异
  menus.forEach(menu => {
    // 后端使用 menuName，前端使用 title，需要统一
    const normalizedMenu: MenuItem = {
      id: Number(menu.id),
      parentId: menu.parentId ? Number(menu.parentId) : 0,
      title: menu.menuName || menu.title || '未命名菜单',
      path: menu.path || '',
      icon: menu.icon,
      children: []
    }
    // 使用字符串作为 key，兼容后端返回的字符串 id
    map.set(String(menu.id), normalizedMenu)
  })

  menus.forEach(menu => {
    const node = map.get(String(menu.id))!
    // parentId 为 0、'0'、null、undefined 时作为根节点
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

  console.log('转换后的菜单树:', roots)
  return roots
}

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const uiStore = useUiStore();

const activeMenu = ref(route.path);
const dynamicMenus = ref<MenuItem[]>([]);

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

// 加载菜单
async function loadMenus() {
  try {
    const userInfo = userStore.userInfo
    const roles = userInfo?.roles || []
    console.log('loadMenus - userInfo:', userInfo)
    console.log('loadMenus - roles:', roles)

    // 获取菜单
    let menus: SysMenu[] = []
    try {
      menus = await getAllMenus()
      console.log('所有菜单原始数据:', menus)
      console.log('菜单数量:', menus.length)
    } catch (error) {
      console.warn('获取菜单失败，降级处理:', error)
      menus = []
    }

    // 过滤管理端菜单 (只保留管理端相关的菜单)
    // 超级管理员: 显示所有管理端菜单(不包括用户端专用菜单)
    // 普通管理员: 显示其角色分配的菜单
    const adminMenuIds = new Set([
      // 顶级目录
      2001, 2002, 2003, 2004, 2005, 2006, 2007, 2009, 2010,
      // 系统管理子菜单
      2011, 2012, 2013, 2014, 2015,
      // 组织人事子菜单
      2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028,
      // 招聘管理子菜单
      2031, 2032, 2033, 2034, 2035,
      // 考勤管理子菜单
      2041, 2042, 2043, 2044, 2045, 2046, 2047,
      // 绩效管理子菜单
      2051, 2052, 2053, 2054, 2055, 2056,
      // 薪酬管理子菜单
      2061, 2062, 2063, 2064, 2065, 2066, 2067, 2068,
      // 培训管理子菜单
      2071, 2072, 2073, 2074, 2075, 2076, 2077,
      // 工作流子菜单
      2091, 2092, 2093, 2094,
      // 数据报表子菜单
      2101, 2102, 2103, 2104, 2105, 2106,
    ])

    // 过滤菜单:
    // 1. 只保留管理端菜单 (排除员工自助菜单2008及其子菜单)
    // 2. 排除按钮权限菜单 (menuType=2)
    console.log('开始过滤菜单, 总数:', menus.length)
    console.log('菜单ID列表:', menus.map(m => ({ id: m.id, name: m.menuName, type: m.menuType, parent: m.parentId })))
    const adminMenus = menus.filter(menu => {
      // 转换为数字类型进行比较
      const menuId = Number(menu.id)
      const isAdminMenu = adminMenuIds.has(menuId)
      const isButtonType = menu.menuType === 2
      console.log(`菜单ID: ${menu.id} (${menuId}), 名称: ${menu.menuName}, 类型: ${menu.menuType}, 是否管理端: ${isAdminMenu}, 是否按钮: ${isButtonType}`)
      return isAdminMenu && !isButtonType
    })
    console.log('过滤后的管理端菜单:', adminMenus)

    // 将平铺数据转换为树形结构
    const menuTree = buildMenuTree(adminMenus)
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
    // 转换为 MenuItem 类型并过滤按钮类型
    const filteredMenus = userStore.menus.filter((menu: any) => menu.menuType !== 2)
    dynamicMenus.value = buildMenuTree(filteredMenus)
  } else {
    loadMenus()
  }
})

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

.aside {
  background-color: #2b2b2b;
  color: #fff;
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

.logo-container {
  display: flex;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #3d3d3d;
  flex-shrink: 0;
}

.menu-container {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}

.menu-container::-webkit-scrollbar {
  width: 6px;
}

.menu-container::-webkit-scrollbar-thumb {
  background-color: #4a4a4a;
  border-radius: 3px;
}

.menu-container::-webkit-scrollbar-track {
  background-color: #2b2b2b;
}

.logo {
  width: 52px;
  height: 52px;
  margin-right: 10px;
}

.title {
  color: #fff;
  font-size: 18px;
  margin: 0;
}

.el-menu-vertical-demo {
  border-right: none;
}

.header {
  background-color: #fff;
  color: #333;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #d8dce5;
  padding: 0 20px;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
}

.breadcrumb-container {
  display: flex;
  align-items: center;
  font-size: 14px;
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
  color: #333;
}

.main-content {
  background-color: #f0f2f5;
  padding: 20px;
  width: 100%;
}
</style>
