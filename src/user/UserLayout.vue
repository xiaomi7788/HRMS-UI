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
          :ellipsis="false"
          background-color="#2b2b2b"
          text-color="#bfcbd9"
          active-text-color="#409EFF"
        >
          <!-- 显示所有菜单 -->
          <el-menu-item
            v-for="menu in firstItem"
            :key="menu.id"
            :index="menu.path"
          >
            <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
            <span>{{ menu.menuName }}</span>
          </el-menu-item>
          <el-sub-menu index="#" v-if="secondItem.length > 0">
            <template #title>更多</template>
            <el-menu-item v-for="menu1 in secondItem" :index="menu1.path" :key="menu1.id">
              <el-icon><component :is="getIcon(menu1.icon)" /></el-icon>
              <span>{{ menu1.menuName }}</span>
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
import { getAllMenus, type SysMenu } from '@/api/auth';
import {
  Management,
  UserFilled,
  TrendCharts,
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
  sort?: number
}

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const uiStore = useUiStore();

const activeMenu = ref(route.path);
const userMenuItems = ref<SysMenu[]>([]);
const firstItem = ref<SysMenu[]>([]);
const secondItem = ref<SysMenu[]>([]);

// 计算平铺显示的菜单（前5个）
const visibleMenus = computed(() => {
  // 直接使用用户端菜单项
  const sorted = userMenuItems.value.sort((a, b) => {
    const aSort = a.sort || 0
    const bSort = b.sort || 0
    return aSort - bSort
  })
  
  // 返回前4个
  return sorted.slice(0, 4)
})

// 获取图标组件
function getIcon(iconName?: string) {
  if (!iconName) return 'Folder'
  const iconMap: Record<string, any> = {
    'House': House,
    'User': UserFilled,
    'Setting': 'Setting',
    'Document': 'Document',
    'Folder': 'Folder',
    'FolderOpened': 'FolderOpened',
    'Files': 'Files',
    'List': 'List',
    'Grid': 'Grid',
    'Menu': 'Menu',
    'Search': 'Search',
    'Bell': 'Bell',
    'Message': 'Message',
    'Star': 'Star',
    'StarFilled': 'StarFilled',
    'Clock': 'Clock',
    'Calendar': 'Calendar',
    'Money': 'Money',
    'Wallet': 'Wallet',
    'TrendCharts': TrendCharts,
    'DataLine': 'DataLine',
    'PieChart': 'PieChart',
    'Histogram': 'Histogram',
    'Management': Management,
    'Tools': 'Tools',
    'Brush': 'Brush',
    'Lock': 'Lock',
    'Key': 'Key',
    'Medal': 'Medal',
    'Trophy': 'Trophy',
    'Briefcase': 'Briefcase',
    'School': 'School',
    'Reading': 'Reading',
    'Film': 'Film',
    'Camera': 'Camera',
    'Picture': 'Picture',
    'Upload': 'Upload',
    'Download': 'Download',
    'Link': 'Link',
    'Phone': 'Phone',
    'MessageBox': 'MessageBox',
    'Postcard': 'Postcard',
    'OfficeBuilding': 'OfficeBuilding',
    'HomeFilled': 'HomeFilled',
    'UserFilled': 'UserFilled',
    'Cherry': 'Cherry',
    'Food': 'Food',
    'Present': 'Present',
    'Sunrise': 'Sunrise',
    'Sunset': 'Sunset',
    'Cloudy': 'Cloudy',
    'Sunny': 'Sunny',
    'Moon': 'Moon',
    'Ticket': 'Ticket',
    'Flag': 'Flag',
    'Location': 'Location',
    'Aim': 'Aim',
    'Promotion': 'Promotion',
    'Pointer': 'Pointer',
    'MagicStick': 'MagicStick',
    'Headset': 'Headset',
    'Microphone': 'Microphone',
    'Coffee': 'Coffee',
    'GobletFull': 'GobletFull',
    'Watermelon': 'Watermelon',
    'Grape': 'Grape',
    'Apple': 'Apple',
    'Orange': 'Orange',
  }
  return iconMap[iconName] || 'Folder'
}

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

    // 过滤用户端菜单：path以/user/开头，不是按钮，有路径
    const filteredUserMenuItems = menus.filter(menu => {
      const isUserPath = menu.path?.startsWith('/user/')
      const isButtonType = menu.menuType === 2
      const hasPath = menu.path && menu.path.length > 0
      console.log(`菜单ID: ${menu.id}, 名称: ${menu.menuName}, 路径: ${menu.path}, 类型: ${menu.menuType}, 是否用户端: ${isUserPath}`)

      // 只显示用户端菜单：/user/开头，不是按钮，有路径
      return isUserPath && !isButtonType && hasPath
    })
    console.log('过滤后的用户端菜单项:', filteredUserMenuItems)

    // 保存用户端菜单项到响应式变量
    userMenuItems.value = filteredUserMenuItems as any
    firstItem.value = userMenuItems.value.slice(0, 4);
    secondItem.value = userMenuItems.value.slice(4);
  } catch (error) {
    console.error('获取菜单失败:', error)
  }
}

onMounted(() => {
    console.log('onMounted->',userStore);

    // 如果store中有菜单则使用，否则重新获取
    if (userStore.menus.length > 0) {
      const allMenus = userStore.menus as any

      // 过滤用户端菜单：path以/user/开头，不是按钮，有路径
      const filteredUserMenuItems = allMenus.filter((menu: any) => {
        const isUserPath = menu.path?.startsWith('/user/')
        const isButtonType = menu.menuType === 2
        const hasPath = menu.path && menu.path.length > 0

        // 只显示用户端菜单：/user/开头，不是按钮，有路径
        return isUserPath && !isButtonType && hasPath
      })

      // 保存用户端菜单项到响应式变量
      userMenuItems.value = filteredUserMenuItems
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
