import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useUiStore } from '@/stores/ui'
import { ElMessage } from 'element-plus'
import { getRoleList } from '@/api/role'

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
        path: 'sys/user',
        name: 'UserList',
        component: () => import('@/admin/pages/system-management/users/UserList.vue'),
        meta: { title: '用户管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'sys/role',
        name: 'RoleList',
        component: () => import('@/admin/pages/system-management/roles/RoleList.vue'),
        meta: { title: '角色管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'sys/menu',
        name: 'MenuList',
        component: () => import('@/admin/pages/system-management/menus/MenuList.vue'),
        meta: { title: '菜单管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'sys/log',
        name: 'LogList',
        component: () => import('@/admin/pages/system-management/logs/LogList.vue'),
        meta: { title: '操作日志', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'sys/workflow',
        name: 'WorkflowTemplate',
        component: () => import('@/admin/pages/system-management/workflow/WorkflowTemplate.vue'),
        meta: { title: '审批流程模板', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'attendance/schedule',
        name: 'ScheduleList',
        component: () => import('@/admin/pages/attendance/schedule/ScheduleList.vue'),
        meta: { title: '排班管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'org/dept',
        name: 'DeptList',
        component: () => import('@/admin/pages/org/dept/DeptList.vue'),
        meta: { title: '部门管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'org/position',
        name: 'PositionList',
        component: () => import('@/admin/pages/org/position/PositionList.vue'),
        meta: { title: '岗位管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'org/employee',
        name: 'EmployeeList',
        component: () => import('@/admin/pages/org/employee/EmployeeList.vue'),
        meta: { title: '员工管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'org/contract',
        name: 'ContractList',
        component: () => import('@/admin/pages/org/contract/ContractList.vue'),
        meta: { title: '劳动合同管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'org/talent',
        name: 'TalentList',
        component: () => import('@/admin/pages/org/talent/TalentList.vue'),
        meta: { title: '人才梯队管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'org/contact',
        name: 'ContactList',
        component: () => import('@/admin/pages/org/contact/ContactList.vue'),
        meta: { title: '通讯录', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruit/job',
        name: 'JobList',
        component: () => import('@/admin/pages/recruit/job/JobList.vue'),
        meta: { title: '招聘职位管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruit/candidate',
        name: 'CandidateList',
        component: () => import('@/admin/pages/recruit/candidate/CandidateList.vue'),
        meta: { title: '候选人库', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruit/interview',
        name: 'InterviewList',
        component: () => import('@/admin/pages/recruit/interview/InterviewList.vue'),
        meta: { title: '安排面试', requiresAuth: true, roles: ['admin', 'superadmin'] },
      },
      {
        path: 'recruit/offer',
        name: 'OfferList',
        component: () => import('@/admin/pages/recruit/offer/OfferList.vue'),
        meta: { title: 'Offer管理', requiresAuth: true, roles: ['admin', 'superadmin'] },
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
    // 加载角色列表（如果未加载）
    if (!userStore.roleList || userStore.roleList.length === 0) {
      try {
        const roles = await getRoleList()
        userStore.setRoleList(roles)
      } catch (error) {
        console.error('加载角色列表失败:', error)
      }
    }
    const userRoles = userStore.roles
    console.log('beforeEach: userRoles', userRoles);
    // 简化逻辑：只要角色编码不是 EMPLOYEE 就跳转到管理端，否则跳转到用户端
    const isEmployee = userRoles.some(role => role.toUpperCase() === 'EMPLOYEE')
    if (isEmployee) {
      next({ path: '/user' })
    } else {
      next({ path: '/admin' })
    }
  } else if (requiresAuth && token) {
    // 已登录且需要权限的页面
    console.log('beforeEach: requiresAuth and token exists');
    if (!userStore.userInfo) {
      // 如果用户信息不存在，尝试从本地存储恢复或重新获取
      console.log('beforeEach: userStore.userInfo is null, loading from localStorage');
      await userStore.loadUserInfo()
      console.log('beforeEach: userStore.userInfo after loadUserInfo', userStore.userInfo);
    } else {
      console.log('beforeEach: userStore.userInfo exists', userStore.userInfo);
    }
    // 加载角色列表（如果未加载）
    if (!userStore.roleList || userStore.roleList.length === 0) {
      try {
        const roles = await getRoleList()
        userStore.setRoleList(roles)
      } catch (error) {
        console.error('加载角色列表失败:', error)
      }
    }
    const userRoles = userStore.roles
    const requiredRoles = to.meta?.roles as string[]
    console.log('beforeEach: userRoles', userRoles);
    console.log('beforeEach: requiredRoles', requiredRoles);
    console.log('beforeEach: to.path', to.path);
    console.log('beforeEach: userStore.userInfo', userStore.userInfo);

    if (requiredRoles && requiredRoles.length > 0) {
      // 简化权限逻辑：只要不是 EMPLOYEE 角色就允许访问所有需要 admin/superadmin 权限的页面
      // EMPLOYEE 只能访问需要 user 权限的页面
      const isEmployee = userRoles.some(role => role.toUpperCase() === 'EMPLOYEE')

      console.log('beforeEach: isEmployee', isEmployee);

      if (isEmployee) {
        // EMPLOYEE 只能访问用户端页面
        const allowed = requiredRoles.includes('user')
        console.log('beforeEach: EMPLOYEE user, allowed to access user pages only, allowed:', allowed);
        if (allowed) {
          next()
        } else {
          ElMessage.error('无权访问该页面！')
          next({ path: '/' })
        }
      } else {
        // 非EMPLOYEE角色（ADMIN、HR、MANAGER、FINANCE等）可以访问所有管理端页面
        console.log('beforeEach: non-EMPLOYEE user, allowed to access admin pages');
        next()
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
