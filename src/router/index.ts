import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useUiStore } from '@/stores/ui' // 引入 UI Store
import { ElMessage } from 'element-plus'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/login',
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/user/Login.vue'),
    meta: { title: '登录', requiresAuth: false },
  },
  {
    path: '/user',
    name: 'User',
    component: () => import('@/user/UserLayout.vue'),
    meta: { title: '用户端', requiresAuth: true, roles: ['user', 'manager'] },
    children: [
      {
        path: '', // 默认子路由
        name: 'UserPersonalCenter',
        component: () => import('@/user/pages/PersonalCenter.vue'),
        meta: { title: '个人中心', requiresAuth: true, roles: ['user', 'manager'] },
      },

      {
        path: 'self-service/salary-query',
        name: 'UserSalaryQuery',
        component: () => import('@/user/pages/self-service/SalaryQuery.vue'),
        meta: { title: '薪资查询', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'self-service/attendance-query',
        name: 'UserAttendanceQuery',
        component: () => import('@/user/pages/self-service/AttendanceQuery.vue'),
        meta: { title: '考勤查询', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'self-service/leave-overtime-apply',
        name: 'UserLeaveOvertimeApply',
        component: () => import('@/user/pages/self-service/LeaveOvertimeApply.vue'),
        meta: { title: '请假/加班申请', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'self-service/personal-flow-center',
        name: 'UserPersonalFlowCenter',
        component: () => import('@/user/pages/self-service/PersonalFlowCenter.vue'),
        meta: { title: '个人流程中心', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'training-center',
        name: 'UserTrainingCenter',
        component: () => import('@/user/pages/TrainingCenter.vue'),
        meta: { title: '培训中心', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'company-directory',
        name: 'UserCompanyDirectory',
        component: () => import('@/user/pages/CompanyDirectory.vue'),
        meta: { title: '公司通讯录', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'announcement-notification',
        name: 'UserAnnouncementNotification',
        component: () => import('@/user/pages/AnnouncementNotification.vue'),
        meta: { title: '公告通知中心', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'employee-care-reminders',
        name: 'UserEmployeeCareReminders',
        component: () => import('@/user/pages/EmployeeCareReminders.vue'),
        meta: { title: '员工关怀提醒', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'welfare/welfare-item-view',
        name: 'UserWelfareItemView',
        component: () => import('@/user/pages/welfare/WelfareItemView.vue'),
        meta: { title: '福利项目查看', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'performance/my-performance',
        name: 'UserMyPerformance',
        component: () => import('@/user/pages/performance/MyPerformance.vue'),
        meta: { title: '我的绩效', requiresAuth: true, roles: ['user', 'manager'] },
      },
      {
        path: 'survey/employee-survey',
        name: 'UserEmployeeSurvey',
        component: () => import('@/user/pages/survey/EmployeeSurvey.vue'),
        meta: { title: '员工调查与问卷', requiresAuth: true, roles: ['user', 'manager'] },
      },
      // 部门经理附加功能
      {
        path: 'manager/team-employee-list',
        name: 'UserManagerTeamEmployeeList',
        component: () => import('@/user/pages/manager/TeamEmployeeList.vue'),
        meta: { title: '团队员工列表', requiresAuth: true, roles: ['manager'] },
      },
      {
        path: 'manager/team-attendance-view',
        name: 'UserManagerTeamAttendanceView',
        component: () => import('@/user/pages/manager/TeamAttendanceView.vue'),
        meta: { title: '团队考勤查看', requiresAuth: true, roles: ['manager'] },
      },
      {
        path: 'manager/team-performance-view',
        name: 'UserManagerTeamPerformanceView',
        component: () => import('@/user/pages/manager/TeamPerformanceView.vue'),
        meta: { title: '团队绩效查看', requiresAuth: true, roles: ['manager'] },
      },
      {
        path: 'manager/approval-center',
        name: 'UserManagerApprovalCenter',
        component: () => import('@/user/pages/manager/ApprovalCenter.vue'),
        meta: { title: '审批中心', requiresAuth: true, roles: ['manager'] },
      },
    ],
  },
  {
    path: '/superadmin',
    name: 'SuperAdmin',
    component: () => import('@/admin/pages/SuperAdminDashboard.vue'), // 假设超级管理员有自己的布局或页面
    meta: { title: '超级管理员后台', requiresAuth: true, roles: ['superadmin'] },
  },
  {
    path: '/admin',
    name: 'Admin',
    component: () => import('@/admin/Layout.vue'),
    meta: { title: '管理后台', requiresAuth: true, roles: ['admin', 'superadmin'] },
    children: [
      {
        path: '', // 默认子路由
        name: 'AdminDashboard',
        component: () => import('@/admin/pages/AdminDashboard.vue'),
        meta: { title: '管理仪表盘', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'system-management/users',
        name: 'UserList',
        component: () => import('@/admin/pages/system-management/users/UserList.vue'),
        meta: { title: '用户列表', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'system-management/roles',
        name: 'RoleList',
        component: () => import('@/admin/pages/system-management/roles/RoleList.vue'),
        meta: { title: '角色列表', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'system-management/menus',
        name: 'MenuList',
        component: () => import('@/admin/pages/system-management/menus/MenuList.vue'),
        meta: { title: '菜单管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'organization-management/departments',
        name: 'DepartmentList',
        component: () => import('@/admin/pages/organization-management/departments/DepartmentList.vue'),
        meta: { title: '部门管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'organization-management/positions',
        name: 'PositionList',
        component: () => import('@/admin/pages/organization-management/positions/PositionList.vue'),
        meta: { title: '岗位管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'employee-management/list',
        name: 'EmployeeList',
        component: () => import('@/admin/pages/employee-management/EmployeeList.vue'),
        meta: { title: '员工列表', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'employee-management/lifecycle',
        name: 'EmployeeLifecycleManagement',
        component: () => import('@/admin/pages/employee-management/EmployeeLifecycleManagement.vue'),
        meta: { title: '员工入转调离', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'employee-management/contracts',
        name: 'ContractManagement',
        component: () => import('@/admin/pages/employee-management/ContractManagement.vue'),
        meta: { title: '劳动合同管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'employee-management/movement-statistics',
        name: 'PersonnelMovementStatistics',
        component: () => import('@/admin/pages/employee-management/PersonnelMovementStatistics.vue'),
        meta: { title: '人事异动统计', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'employee-management/roster',
        name: 'EmployeeRosterManagement',
        component: () => import('@/admin/pages/employee-management/EmployeeRosterManagement.vue'),
        meta: { title: '员工花名册', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'employee-management/succession-planning',
        name: 'SuccessionPlanning',
        component: () => import('@/admin/pages/employee-management/SuccessionPlanning.vue'),
        meta: { title: '继任者计划', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruitment-management/demand-list',
        name: 'RecruitmentDemandList',
        component: () => import('@/admin/pages/recruitment-management/RecruitmentDemandList.vue'),
        meta: { title: '招聘需求管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruitment-management/job-posting',
        name: 'JobPostingManagement',
        component: () => import('@/admin/pages/recruitment-management/JobPostingManagement.vue'),
        meta: { title: '职位发布管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruitment-management/candidates',
        name: 'CandidateManagement',
        component: () => import('@/admin/pages/recruitment-management/CandidateManagement.vue'),
        meta: { title: '候选人管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruitment-management/interviews',
        name: 'InterviewManagement',
        component: () => import('@/admin/pages/recruitment-management/InterviewManagement.vue'),
        meta: { title: '面试管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruitment-management/evaluation-approval',
        name: 'InterviewEvaluationApproval',
        component: () => import('@/admin/pages/recruitment-management/InterviewEvaluationApproval.vue'),
        meta: { title: '面试评价与审批', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruitment-management/offer-onboarding',
        name: 'OfferOnboardingManagement',
        component: () => import('@/admin/pages/recruitment-management/OfferOnboardingManagement.vue'),
        meta: { title: 'Offer与入职管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'attendance-management/rule-config',
        name: 'AttendanceRuleConfig',
        component: () => import('@/admin/pages/attendance-management/AttendanceRuleConfig.vue'),
        meta: { title: '考勤规则配置', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'attendance-management/data-processing',
        name: 'AttendanceDataProcessing',
        component: () => import('@/admin/pages/attendance-management/AttendanceDataProcessing.vue'),
        meta: { title: '考勤数据处理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'attendance-management/leave-management',
        name: 'LeaveManagement',
        component: () => import('@/admin/pages/attendance-management/LeaveManagement.vue'),
        meta: { title: '假期管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'attendance-management/overtime-management',
        name: 'OvertimeManagement',
        component: () => import('@/admin/pages/attendance-management/OvertimeManagement.vue'),
        meta: { title: '加班管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'attendance-management/monthly-report',
        name: 'MonthlyAttendanceReport',
        component: () => import('@/admin/pages/attendance-management/MonthlyAttendanceReport.vue'),
        meta: { title: '月度考勤报表', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'payroll-management/structure-design',
        name: 'PayrollStructureDesign',
        component: () => import('@/admin/pages/payroll-management/PayrollStructureDesign.vue'),
        meta: { title: '薪酬结构设计', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'payroll-management/monthly-calculation',
        name: 'MonthlyPayrollCalculation',
        component: () => import('@/admin/pages/payroll-management/MonthlyPayrollCalculation.vue'),
        meta: { title: '月度薪酬核算', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'payroll-management/social-security-provident-fund',
        name: 'SocialSecurityProvidentFundManagement',
        component: () => import('@/admin/pages/payroll-management/SocialSecurityProvidentFundManagement.vue'),
        meta: { title: '社保公积金管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'payroll-management/salary-adjustment-approval',
        name: 'SalaryAdjustmentApproval',
        component: () => import('@/admin/pages/payroll-management/SalaryAdjustmentApproval.vue'),
        meta: { title: '薪酬调整审批', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'payroll-management/report-cost-analysis',
        name: 'PayrollReportCostAnalysis',
        component: () => import('@/admin/pages/payroll-management/PayrollReportCostAnalysis.vue'),
        meta: { title: '薪酬报表与分析', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'payroll-management/benefit-management',
        name: 'BenefitManagement',
        component: () => import('@/admin/pages/payroll-management/BenefitManagement.vue'),
        meta: { title: '福利项目管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'performance-management/plan-design',
        name: 'PerformancePlanDesign',
        component: () => import('@/admin/pages/performance-management/PerformancePlanDesign.vue'),
        meta: { title: '绩效方案设计', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'performance-management/goal-setting',
        name: 'PerformanceGoalSetting',
        component: () => import('@/admin/pages/performance-management/PerformanceGoalSetting.vue'),
        meta: { title: '绩效目标制定', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'performance-management/tracking-feedback',
        name: 'PerformanceTrackingFeedback',
        component: () => import('@/admin/pages/performance-management/PerformanceTrackingFeedback.vue'),
        meta: { title: '绩效跟踪与反馈', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'performance-management/evaluation-calibration',
        name: 'PerformanceEvaluationCalibration',
        component: () => import('@/admin/pages/performance-management/PerformanceEvaluationCalibration.vue'),
        meta: { title: '绩效评估与校准', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'performance-management/result-improvement',
        name: 'PerformanceResultImprovement',
        component: () => import('@/admin/pages/performance-management/PerformanceResultImprovement.vue'),
        meta: { title: '绩效结果应用与改进', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'training-management/plan-form',
        name: 'TrainingPlanForm',
        component: () => import('@/admin/pages/training-management/TrainingPlanForm.vue'),
        meta: { title: '培训计划制定', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'workflow-approval/process-design',
        name: 'ApprovalProcessDesign',
        component: () => import('@/admin/pages/workflow-approval/ApprovalProcessDesign.vue'),
        meta: { title: '审批流程设计', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'data-reports-bi/hr-structure-analysis',
        name: 'HumanResourceStructureAnalysis',
        component: () => import('@/admin/pages/data-reports-bi/HumanResourceStructureAnalysis.vue'),
        meta: { title: '人力结构分析', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'system-audit-logs/operation-log-list',
        name: 'OperationLogList',
        component: () => import('@/admin/pages/system-audit-logs/OperationLogList.vue'),
        meta: { title: '操作日志记录', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
    ],
  },
  // 404 页面
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/components/NotFound.vue'),
    meta: { title: '页面不存在' },
  },
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
})

// 全局前置守卫
router.beforeEach(async (to, _from, next) => {
  console.log('Navigating to:', to); // 添加调试信息
  const uiStore = useUiStore()
  uiStore.setLoading(true) // 开始加载动画

  // 设置页面标题
  if (to.meta?.title) {
    document.title = `HRM - ${to.meta.title}`
  }

  const requiresAuth = to.meta?.requiresAuth !== false
  const token = localStorage.getItem('hrm_token')
  const userStore = useUserStore()
  console.log('beforeEach: initial userStore.userInfo', userStore.userInfo);
  console.log('beforeEach: initial token', token);

  if (requiresAuth && !token) {
    // 需要登录但未登录，跳转到登录页
    console.log('beforeEach: requiresAuth and no token, redirect to login');
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (to.name === 'Login' && token) {
    // 已登录时访问登录页，根据用户角色跳转到对应页面
    console.log('beforeEach: logged in and trying to access login page');
    if (!userStore.userInfo) {
      console.log('beforeEach: userStore.userInfo is null, loading from localStorage');
      await userStore.loadUserInfo()
      console.log('beforeEach: userStore.userInfo after loadUserInfo', userStore.userInfo);
    }
    const userRole = userStore.userInfo?.role
    console.log('beforeEach: userRole', userRole);
    if (userRole === 'admin') {
      next({ path: '/admin' })
    } else if (userRole === 'superadmin') {
      next({ path: '/superadmin' })
    } else if (userRole === 'user' || userRole === 'manager') { // 将 manager 角色也重定向到用户端仪表盘
      next({ path: '/user' })
    } else {
      next({ path: '/' }) // 默认跳转
    }
  } else if (requiresAuth && token) {
    // 已登录且需要权限的页面
    console.log('beforeEach: requiresAuth and token exists');
    if (!userStore.userInfo?.role) {
      // 如果用户信息不存在，尝试从本地存储恢复或重新获取
      console.log('beforeEach: userStore.userInfo.role is null, loading from localStorage');
      await userStore.loadUserInfo()
      console.log('beforeEach: userStore.userInfo after loadUserInfo', userStore.userInfo);
    }
    const userRole = userStore.userInfo?.role
    const requiredRoles = to.meta?.roles as string[]
    console.log('beforeEach: userRole', userRole);
    console.log('beforeEach: requiredRoles', requiredRoles);

    if (requiredRoles && requiredRoles.length > 0) {
      if (userRole && requiredRoles.includes(userRole)) {
        console.log('beforeEach: role matched, next()');
        next()
      } else {
        ElMessage.error('无权访问该页面！')
        console.log('beforeEach: role not matched, redirect to /');
        next({ path: '/' }) // 无权限跳转到首页
      }
    } else {
      console.log('beforeEach: no specific roles required, next()');
      next() // 不需要特定角色权限的已登录页面
    }
  } else {
    console.log('beforeEach: no auth required or no token, next()');
    next()
  }
})

router.afterEach(() => {
  const uiStore = useUiStore()
  uiStore.setLoading(false) // 结束加载动画
})

export default router
