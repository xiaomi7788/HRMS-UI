<template>
  <el-container class="common-layout">
    <el-aside width="200px" class="aside">
      <div class="logo-container">
        <img src="@/assets/logo.svg" alt="HRM Logo" class="logo">
        <h3 class="title">HRMS</h3>
      </div>
      <el-menu
        :default-active="activeMenu"
        class="el-menu-vertical-demo"
        router
        background-color="#2b2b2b"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/admin">
          <el-icon><House /></el-icon>
          <span>仪表盘</span>
        </el-menu-item>
        <el-sub-menu index="system-management">
          <template #title>
            <el-icon><Setting /></el-icon>
            <span>系统管理</span>
          </template>
          <el-menu-item index="/admin/system-management/users">
            <el-icon><User /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/system-management/roles">
            <el-icon><Key /></el-icon>
            <span>角色权限</span>
          </el-menu-item>
          <el-menu-item index="/admin/system-management/menus">
            <el-icon><Menu /></el-icon>
            <span>菜单管理</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="system-audit-logs">
          <template #title>
            <el-icon><Monitor /></el-icon>
            <span>系统审计与日志</span>
          </template>
          <el-menu-item index="/admin/system-audit-logs/operation-log-list">
            <el-icon><List /></el-icon>
            <span>操作日志记录</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="data-reports-bi">
          <template #title>
            <el-icon><DataAnalysis /></el-icon>
            <span>数据报表与BI</span>
          </template>
          <el-menu-item index="/admin/data-reports-bi/hr-structure-analysis">
            <el-icon><Histogram /></el-icon>
            <span>人力结构分析</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="workflow-approval">
          <template #title>
            <el-icon><Connection /></el-icon>
            <span>工作流审批管理</span>
          </template>
          <el-menu-item index="/admin/workflow-approval/process-design">
            <el-icon><Setting /></el-icon>
            <span>审批流程设计</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="training-management">
          <template #title>
            <el-icon><Reading /></el-icon>
            <span>培训管理</span>
          </template>
          <el-menu-item index="/admin/training-management/plan-form">
            <el-icon><Document /></el-icon>
            <span>培训计划制定</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="performance-management">
          <template #title>
            <el-icon><TrendCharts /></el-icon>
            <span>绩效管理</span>
          </template>
          <el-menu-item index="/admin/performance-management/plan-design">
            <el-icon><Edit /></el-icon>
            <span>绩效方案设计</span>
          </el-menu-item>
          <el-menu-item index="/admin/performance-management/evaluation-calibration">
            <el-icon><Monitor /></el-icon>
            <span>绩效评估与校准</span>
          </el-menu-item>
          <el-menu-item index="/admin/performance-management/result-improvement">
            <el-icon><DataAnalysis /></el-icon>
            <span>绩效结果应用与改进</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="payroll-management">
          <template #title>
            <el-icon><Money /></el-icon>
            <span>薪酬管理</span>
          </template>
          <el-menu-item index="/admin/payroll-management/structure-design">
            <el-icon><Coin /></el-icon>
            <span>薪酬结构设计</span>
          </el-menu-item>
          <el-menu-item index="/admin/payroll-management/monthly-calculation">
            <el-icon><Money /></el-icon>
            <span>月度薪酬核算</span>
          </el-menu-item>
          <el-menu-item index="/admin/payroll-management/social-security-provident-fund">
            <el-icon><OfficeBuilding /></el-icon>
            <span>社保公积金管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/payroll-management/salary-adjustment-approval">
            <el-icon><Edit /></el-icon>
            <span>薪酬调整审批</span>
          </el-menu-item>
          <el-menu-item index="/admin/payroll-management/report-cost-analysis">
            <el-icon><DataAnalysis /></el-icon>
            <span>薪酬报表与分析</span>
          </el-menu-item>

          <el-menu-item index="/admin/payroll-management/benefit-management">
            <el-icon><Coin /></el-icon>
            <span>福利项目管理</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="attendance-management">
          <template #title>
            <el-icon><Calendar /></el-icon>
            <span>考勤管理</span>
          </template>
          <el-menu-item index="/admin/attendance-management/rule-config">
            <el-icon><Setting /></el-icon>
            <span>考勤规则配置</span>
          </el-menu-item>
          <el-menu-item index="/admin/attendance-management/data-processing">
            <el-icon><DataAnalysis /></el-icon>
            <span>考勤数据处理</span>
          </el-menu-item>
          <el-menu-item index="/admin/attendance-management/leave-management">
            <el-icon><Calendar /></el-icon>
            <span>假期管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/attendance-management/overtime-management">
            <el-icon><Coin /></el-icon>
            <span>加班管理</span>
          </el-menu-item>

          <el-menu-item index="/admin/attendance-management/monthly-report">
            <el-icon><Histogram /></el-icon>
            <span>月度考勤报表</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="recruitment-management">
          <template #title>
            <el-icon><Suitcase /></el-icon>
            <span>招聘管理</span>
          </template>
          <el-menu-item index="/admin/recruitment-management/demand-list">
            <el-icon><Document /></el-icon>
            <span>招聘需求管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/recruitment-management/job-posting">
            <el-icon><Edit /></el-icon>
            <span>职位发布管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/recruitment-management/candidates">
            <el-icon><UserFilled /></el-icon>
            <span>候选人管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/recruitment-management/interviews">
            <el-icon><Calendar /></el-icon>
            <span>面试管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/recruitment-management/evaluation-approval">
            <el-icon><DocumentChecked /></el-icon>
            <span>面试评价与审批</span>
          </el-menu-item>
          <el-menu-item index="/admin/recruitment-management/offer-onboarding">
            <el-icon><Suitcase /></el-icon>
            <span>Offer与入职管理</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="employee-management">
          <template #title>
            <el-icon><Avatar /></el-icon>
            <span>员工档案管理</span>
          </template>
          <el-menu-item index="/admin/employee-management/list">
            <el-icon><UserFilled /></el-icon>
            <span>员工信息维护</span>
          </el-menu-item>
          <el-menu-item index="/admin/employee-management/lifecycle">
            <el-icon><List /></el-icon>
            <span>员工入转调离</span>
          </el-menu-item>
          <el-menu-item index="/admin/employee-management/contracts">
            <el-icon><DocumentCopy /></el-icon>
            <span>劳动合同管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/employee-management/movement-statistics">
            <el-icon><List /></el-icon>
            <span>人事异动查询与统计</span>
          </el-menu-item>
          <el-menu-item index="/admin/employee-management/roster">
            <el-icon><Postcard /></el-icon>
            <span>员工花名册</span>
          </el-menu-item>
          <el-menu-item index="/admin/employee-management/succession-planning">
            <el-icon><TrendCharts /></el-icon>
            <span>继任者计划</span>
          </el-menu-item>
        </el-sub-menu>
        <el-sub-menu index="organization-management">
          <template #title>
            <el-icon><OfficeBuilding /></el-icon>
            <span>组织架构管理</span>
          </template>
          <el-menu-item index="/admin/organization-management/departments">
            <el-icon><Management /></el-icon>
            <span>部门管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/organization-management/positions">
            <el-icon><Postcard /></el-icon>
            <span>岗位管理</span>
          </el-menu-item>
        </el-sub-menu>
        <!-- 更多菜单项 -->
      </el-menu>
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
import { ref, computed, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useUserStore } from '@/stores/user';
import { useUiStore } from '@/stores/ui'; // 引入 UI Store
import { ElMessage } from 'element-plus';
import { House, Setting, User, Key, Menu, ArrowDown, OfficeBuilding, Management, Postcard, Avatar, UserFilled, Suitcase, Document, Calendar, Money, Coin, TrendCharts, Edit, Reading, Connection, DataAnalysis, Histogram, Monitor, List, DocumentCopy, DocumentChecked } from '@element-plus/icons-vue';

const router = useRouter();
const route = useRoute();
const userStore = useUserStore();
const uiStore = useUiStore(); // 获取 UI Store 实例

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

.aside {
  background-color: #2b2b2b;
  color: #fff;
}

.logo-container {
  display: flex;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #2b2b2b;
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
  outline: none !important; /* 移除焦点和hover时的边框 */
  border: none !important; /* 移除可能的边框 */
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
  width: 100%; /* 确保主内容区域宽度占满 */
}
</style>
