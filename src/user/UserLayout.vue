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
          <el-menu-item index="/user">
            <el-icon><House /></el-icon>
            <span>个人中心</span>
          </el-menu-item>
          <el-sub-menu index="self-service">
            <template #title>
              <el-icon><Service /></el-icon>
              <span>员工自助服务</span>
            </template>
            <el-menu-item index="/user/self-service/salary-query">
              <el-icon><Money /></el-icon>
              <span>薪资查询</span>
            </el-menu-item>
            <el-menu-item index="/user/self-service/attendance-query">
              <el-icon><Calendar /></el-icon>
              <span>考勤查询</span>
            </el-menu-item>
            <el-menu-item index="/user/self-service/leave-overtime-apply">
              <el-icon><DocumentAdd /></el-icon>
              <span>请假/加班申请</span>
            </el-menu-item>
            <el-menu-item index="/user/self-service/personal-flow-center">
              <el-icon><List /></el-icon>
              <span>个人流程中心</span>
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item index="/user/training-center">
            <el-icon><Reading /></el-icon>
            <span>培训中心</span>
          </el-menu-item>
          <el-sub-menu index="info-center">
            <template #title>
              <el-icon><Bell /></el-icon>
              <span>信息中心</span>
            </template>
            <el-menu-item index="/user/company-directory">
              <el-icon><User /></el-icon>
              <span>公司通讯录</span>
            </el-menu-item>
            <el-menu-item index="/user/announcement-notification">
              <el-icon><Bell /></el-icon>
              <span>公告通知中心</span>
            </el-menu-item>
          </el-sub-menu>
          <el-sub-menu index="welfare-care">
            <template #title>
              <el-icon><Present /></el-icon>
              <span>关怀福利</span>
            </template>
            <el-menu-item index="/user/employee-care-reminders">
              <el-icon><Present /></el-icon>
              <span>员工关怀提醒</span>
            </el-menu-item>
            <el-menu-item index="/user/welfare/welfare-item-view">
              <el-icon><Present /></el-icon>
              <span>福利项目查看</span>
            </el-menu-item>
            <el-menu-item index="/user/performance/my-performance">
              <el-icon><TrendCharts /></el-icon>
              <span>我的绩效</span>
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item index="/user/survey/employee-survey">
            <el-icon><Document /></el-icon>
            <span>员工调查与问卷</span>
          </el-menu-item>
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
import { ref, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { useUiStore } from '@/stores/ui';
import { ElMessage } from 'element-plus';
import {
  House,
  Service,
  Money,
  Calendar,
  DocumentAdd,
  List,
  Reading,
  User,
  Bell,
  Present,
  Management,
  UserFilled,
  TrendCharts,
  Connection,
  ArrowDown,
  Document,
} from '@element-plus/icons-vue';

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const uiStore = useUiStore();

const activeMenu = ref(route.path);

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
