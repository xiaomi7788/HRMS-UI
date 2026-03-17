-- =============================================
-- 人力资源管理系统 - 导航菜单SQL插入语句
-- 生成时间: 2026-03-17
-- 说明: 包含管理端和用户端两套导航菜单
-- 管理端路由: /admin/*
-- 用户端路由: /user/*
-- 菜单类型: 0=目录 1=菜单 2=按钮
-- 状态: 0=隐藏 1=显示
-- =============================================

-- 清空现有菜单数据（可选）
-- DELETE FROM t_sys_menu WHERE id > 0;

-- ---------------------------------------------
-- 第一部分：管理端菜单 (id: 1-99)
-- 路由前缀: /admin/*
-- ---------------------------------------------

-- 1. 系统管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1, 0, '系统管理', '', 0, '/admin/system', '', 'Setting', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 1.1 用户管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(11, 1, '用户管理', 'system:user:list', 1, '/admin/system/user', 'system/User', 'User', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 1.2 角色管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(12, 1, '角色管理', 'system:role:list', 1, '/admin/system/role', 'system/Role', 'UserFilled', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 1.3 菜单管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(13, 1, '菜单管理', 'system:menu:list', 1, '/admin/system/menu', 'system/Menu', 'Menu', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 1.4 系统日志
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(14, 1, '系统日志', 'system:log:list', 1, '/admin/system/log', 'system/Log', 'Document', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2. 组织人事管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(2, 0, '组织人事', '', 0, '/admin/org', '', 'OfficeBuilding', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.1 部门管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(21, 2, '部门管理', 'org:dept:list', 1, '/admin/org/department', 'org/Department', 'Folder', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.2 岗位管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(22, 2, '岗位管理', 'org:position:list', 1, '/admin/org/position', 'org/Position', 'Briefcase', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.3 员工档案
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(23, 2, '员工档案', 'org:employee:list', 1, '/admin/org/employee', 'org/Employee', 'Tickets', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.4 入职办理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(24, 2, '入职办理', 'org:employee:entry', 1, '/admin/org/entry', 'org/Entry', 'Plus', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.5 转正管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(25, 2, '转正管理', 'org:employee:probation', 1, '/admin/org/probation', 'org/Probation', 'SuccessFilled', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.6 调动管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(26, 2, '调动管理', 'org:employee:transfer', 1, '/admin/org/transfer', 'org/Transfer', 'Switch', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.7 离职管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(27, 2, '离职管理', 'org:employee:quit', 1, '/admin/org/quit', 'org/Quit', 'CloseBold', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.8 劳动合同
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(28, 2, '劳动合同', 'org:contract:list', 1, '/admin/org/contract', 'org/Contract', 'DocumentSigned', 8, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.9 异动记录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(29, 2, '异动记录', 'org:change:list', 1, '/admin/org/change', 'org/Change', 'History', 9, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.10 花名册
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(210, 2, '花名册', 'org:roster:list', 1, '/admin/org/roster', 'org/Roster', 'List', 10, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.11 人员统计
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(211, 2, '人员统计', 'org:statistics:list', 1, '/admin/org/statistics', 'org/Statistics', 'TrendCharts', 11, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.12 通讯录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(212, 2, '通讯录', 'org:address:list', 1, '/admin/org/address', 'org/Address', 'Phone', 12, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.13 组织架构
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(213, 2, '组织架构', 'org:tree:view', 1, '/admin/org/tree', 'org/OrgTree', 'Share', 13, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 2.14 继任计划
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(214, 2, '继任计划', 'org:succession:list', 1, '/admin/org/succession', 'org/Succession', 'Connection', 14, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3. 招聘管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(3, 0, '招聘管理', '', 0, '/admin/recruit', '', 'Search', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.1 招聘需求
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(31, 3, '招聘需求', 'recruit:demand:list', 1, '/admin/recruit/demand', 'recruit/Demand', 'DocumentAdd', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.2 职位发布
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(32, 3, '职位发布', 'recruit:job:list', 1, '/admin/recruit/job', 'recruit/Job', 'Promotion', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.3 简历库
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(33, 3, '简历库', 'recruit:resume:list', 1, '/admin/recruit/resume', 'recruit/Resume', 'Files', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.4 人才池
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(34, 3, '人才池', 'recruit:talent:list', 1, '/admin/recruit/talent', 'recruit/Talent', 'Avatar', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.5 面试安排
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(35, 3, '面试安排', 'recruit:interview:list', 1, '/admin/recruit/interview', 'recruit/Interview', 'Calendar', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.6 面试官管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(36, 3, '面试官管理', 'recruit:interviewer:list', 1, '/admin/recruit/interviewer', 'recruit/Interviewer', 'User', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.7 录用审批
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(37, 3, '录用审批', 'recruit:approval:list', 1, '/admin/recruit/approval', 'recruit/Approval', 'Check', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 3.8 Offer管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(38, 3, 'Offer管理', 'recruit:offer:list', 1, '/admin/recruit/offer', 'recruit/Offer', 'Medal', 8, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4. 考勤管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(4, 0, '考勤管理', '', 0, '/admin/attendance', '', 'Clock', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.1 考勤规则
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(41, 4, '考勤规则', 'attendance:rule:list', 1, '/admin/attendance/rule', 'attendance/Rule', 'SetUp', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.2 排班管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(42, 4, '排班管理', 'attendance:shift:list', 1, '/admin/attendance/shift', 'attendance/Shift', 'Schedule', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.3 打卡记录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(43, 4, '打卡记录', 'attendance:record:list', 1, '/admin/attendance/record', 'attendance/Record', 'Timer', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.4 异常处理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(44, 4, '异常处理', 'attendance:exception:list', 1, '/admin/attendance/exception', 'attendance/Exception', 'Warning', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.5 加班申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(45, 4, '加班申请', 'attendance:overtime:list', 1, '/admin/attendance/overtime', 'attendance/Overtime', 'AlarmClock', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.6 请假管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(46, 4, '请假管理', 'attendance:leave:list', 1, '/admin/attendance/leave', 'attendance/Leave', 'CalendarLeft', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.7 考勤报表
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(47, 4, '考勤报表', 'attendance:report:list', 1, '/admin/attendance/report', 'attendance/Report', 'DataAnalysis', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 4.8 假期额度
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(48, 4, '假期额度', 'attendance:quota:list', 1, '/admin/attendance/quota', 'attendance/Quota', 'Coin', 8, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5. 薪酬管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(5, 0, '薪酬管理', '', 0, '/admin/salary', '', 'Money', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.1 薪酬体系
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(51, 5, '薪酬体系', 'salary:grade:list', 1, '/admin/salary/grade', 'salary/Grade', 'Grid', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.2 薪资核算
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(52, 5, '薪资核算', 'salary:calculate:list', 1, '/admin/salary/calculate', 'salary/Calculate', 'Cpu', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.3 个税申报
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(53, 5, '个税申报', 'salary:tax:list', 1, '/admin/salary/tax', 'salary/Tax', 'Ticket', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.4 社保公积金
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(54, 5, '社保公积金', 'salary:social:list', 1, '/admin/salary/social', 'salary/Social', 'Shield', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.5 薪酬调整
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(55, 5, '薪酬调整', 'salary:adjust:list', 1, '/admin/salary/adjust', 'salary/Adjust', 'EditPen', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.6 薪酬报表
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(56, 5, '薪酬报表', 'salary:report:list', 1, '/admin/salary/report', 'salary/Report', 'TrendCharts', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 5.7 福利管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(57, 5, '福利管理', 'salary:welfare:list', 1, '/admin/salary/welfare', 'salary/Welfare', 'Gift', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6. 绩效管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(6, 0, '绩效管理', '', 0, '/admin/performance', '', 'DataBoard', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6.1 绩效方案
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(61, 6, '绩效方案', 'perf:plan:list', 1, '/admin/performance/plan', 'perf/Plan', 'Operation', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6.2 目标管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(62, 6, '目标管理', 'perf:objective:list', 1, '/admin/performance/objective', 'perf/Objective', 'Aim', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6.3 过程跟踪
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(63, 6, '过程跟踪', 'perf:track:list', 1, '/admin/performance/track', 'perf/Track', 'Monitor', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6.4 绩效评估
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(64, 6, '绩效评估', 'perf:evaluate:list', 1, '/admin/performance/evaluate', 'perf/Evaluate', 'Star', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6.5 绩效结果
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(65, 6, '绩效结果', 'perf:result:list', 1, '/admin/performance/result', 'perf/Result', 'Finished', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 6.6 改进计划
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(66, 6, '改进计划', 'perf:improve:list', 1, '/admin/performance/improve', 'perf/Improve', 'Opportunity', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7. 培训管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(7, 0, '培训管理', '', 0, '/admin/training', '', 'Reading', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.1 培训计划
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(71, 7, '培训计划', 'training:plan:list', 1, '/admin/training/plan', 'training/Plan', 'Calendar', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.2 课程管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(72, 7, '课程管理', 'training:course:list', 1, '/admin/training/course', 'training/Course', 'VideoCamera', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.3 讲师管理
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(73, 7, '讲师管理', 'training:instructor:list', 1, '/admin/training/instructor', 'training/Instructor', 'Avatar', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.4 培训活动
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(74, 7, '培训活动', 'training:activity:list', 1, '/admin/training/activity', 'training/Activity', 'CalendarBoard', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.5 培训报名
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(75, 7, '培训报名', 'training:enroll:list', 1, '/admin/training/enroll', 'training/Enroll', 'Plus', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.6 培训记录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(76, 7, '培训记录', 'training:record:list', 1, '/admin/training/record', 'training/Record', 'Document', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 7.7 效果评估
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(77, 7, '效果评估', 'training:effect:list', 1, '/admin/training/effect', 'training/Effect', 'DataAnalysis', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 8. 审批管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(8, 0, '审批管理', '', 0, '/admin/approval', '', 'CircleCheck', 8, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 8.1 审批模板
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(81, 8, '审批模板', 'approval:template:list', 1, '/admin/approval/template', 'approval/Template', 'FolderOpened', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 8.2 审批流程
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(82, 8, '审批流程', 'approval:instance:list', 1, '/admin/approval/instance', 'approval/Instance', 'Guide', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 8.3 我的待办
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(83, 8, '我的待办', 'approval:todo:list', 1, '/admin/approval/todo', 'approval/Todo', 'List', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 8.4 我的已办
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(84, 8, '我的已办', 'approval:done:list', 1, '/admin/approval/done', 'approval/Done', 'Select', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 9. 员工关怀 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(9, 0, '员工关怀', '', 0, '/admin/care', '', 'Present', 9, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 9.1 公告通知
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(91, 9, '公告通知', 'care:notice:list', 1, '/admin/care/notice', 'care/Notice', 'Bell', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 9.2 生日祝福
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(92, 9, '生日祝福', 'care:birthday:list', 1, '/admin/care/birthday', 'care/Birthday', 'Cake', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 9.3 员工调查
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(93, 9, '员工调查', 'care:survey:list', 1, '/admin/care/survey', 'care/Survey', 'PieChart', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 10. 数据分析 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(10, 0, '数据分析', '', 0, '/admin/analysis', '', 'DataAnalysis', 10, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 10.1 人力分析
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(101, 10, '人力分析', 'analysis:hr:view', 1, '/admin/analysis/hr', 'analysis/Hr', 'UserFilled', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 10.2 成本分析
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(102, 10, '成本分析', 'analysis:cost:view', 1, '/admin/analysis/cost', 'analysis/Cost', 'Money', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 10.3 离职分析
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(103, 10, '离职分析', 'analysis:turnover:view', 1, '/admin/analysis/turnover', 'analysis/Turnover', 'TrendCharts', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);


-- ---------------------------------------------
-- 第二部分：用户端菜单 (id: 100-199)
-- 路由前缀: /user/*
-- ---------------------------------------------

-- 100. 工作台 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(100, 0, '工作台', '', 0, '/user', '', 'HomeFilled', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 100.1 首页
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1001, 100, '首页', 'user:home:view', 1, '/user/home', 'user/Home', 'HomeFilled', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 101. 我的档案 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(101, 0, '我的档案', '', 0, '/user/profile', '', 'Tickets', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 101.1 基本信息
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1011, 101, '基本信息', 'user:profile:view', 1, '/user/profile/basic', 'user/profile/Basic', 'User', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 101.2 工作履历
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1012, 101, '工作履历', 'user:profile:workhistory', 1, '/user/profile/workhistory', 'user/profile/WorkHistory', 'Briefcase', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 101.3 家庭信息
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1013, 101, '家庭信息', 'user:profile:family', 1, '/user/profile/family', 'user/profile/Family', 'House', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 101.4 劳动合同
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1014, 101, '劳动合同', 'user:profile:contract', 1, '/user/profile/contract', 'user/profile/Contract', 'DocumentSigned', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102. 考勤管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(102, 0, '考勤管理', '', 0, '/user/attendance', '', 'Clock', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.1 每日打卡
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1021, 102, '每日打卡', 'user:attendance:clock', 1, '/user/attendance/clock', 'user/attendance/Clock', 'Pointer', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.2 考勤记录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1022, 102, '考勤记录', 'user:attendance:record', 1, '/user/attendance/record', 'user/attendance/Record', 'Timer', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.3 请假申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1023, 102, '请假申请', 'user:attendance:leave', 1, '/user/attendance/leave', 'user/attendance/Leave', 'CalendarLeft', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.4 加班申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1024, 102, '加班申请', 'user:attendance:overtime', 1, '/user/attendance/overtime', 'user/attendance/Overtime', 'AlarmClock', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.5 出差申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1025, 102, '出差申请', 'user:attendance:business', 1, '/user/attendance/business', 'user/attendance/Business', 'Plane', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.6 补卡申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1026, 102, '补卡申请', 'user:attendance:remedial', 1, '/user/attendance/remedial', 'user/attendance/Remedial', 'Refresh', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 102.7 假期余额
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1027, 102, '假期余额', 'user:attendance:quota', 1, '/user/attendance/quota', 'user/attendance/Quota', 'Coin', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 103. 薪酬管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(103, 0, '薪酬管理', '', 0, '/user/salary', '', 'Money', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 103.1 薪资查询
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1031, 103, '薪资查询', 'user:salary:query', 1, '/user/salary/query', 'user/salary/Query', 'Search', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 103.2 薪资条
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1032, 103, '薪资条', 'user:salary:slip', 1, '/user/salary/slip', 'user/salary/Slip', 'Document', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 103.3 收入证明
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1033, 103, '收入证明', 'user:salary:certificate', 1, '/user/salary/certificate', 'user/salary/Certificate', 'Ticket', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 104. 绩效管理 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(104, 0, '绩效管理', '', 0, '/user/performance', '', 'DataBoard', 5, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 104.1 我的目标
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1041, 104, '我的目标', 'user:perf:objective', 1, '/user/performance/objective', 'user/performance/Objective', 'Aim', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 104.2 绩效自评
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1042, 104, '绩效自评', 'user:perf:self', 1, '/user/performance/self', 'user/performance/Self', 'EditPen', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 104.3 绩效结果
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1043, 104, '绩效结果', 'user:perf:result', 1, '/user/performance/result', 'user/performance/Result', 'Finished', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 104.4 改进计划
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1044, 104, '改进计划', 'user:perf:improve', 1, '/user/performance/improve', 'user/performance/Improve', 'Opportunity', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 105. 培训学习 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(105, 0, '培训学习', '', 0, '/user/training', '', 'Reading', 6, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 105.1 培训报名
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1051, 105, '培训报名', 'user:training:enroll', 1, '/user/training/enroll', 'user/training/Enroll', 'Plus', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 105.2 我的课程
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1052, 105, '我的课程', 'user:training:course', 1, '/user/training/course', 'user/training/Course', 'VideoCamera', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 105.3 学习记录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1053, 105, '学习记录', 'user:training:record', 1, '/user/training/record', 'user/training/Record', 'Document', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 105.4 培训签到
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1054, 105, '培训签到', 'user:training:checkin', 1, '/user/training/checkin', 'user/training/Checkin', 'Pointer', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 106. 我的申请 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(106, 0, '我的申请', '', 0, '/user/apply', '', 'List', 7, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 106.1 我的待办
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1061, 106, '我的待办', 'user:apply:todo', 1, '/user/apply/todo', 'user/apply/Todo', 'List', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 106.2 我的已办
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1062, 106, '我的已办', 'user:apply:done', 1, '/user/apply/done', 'user/apply/Done', 'Select', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 106.3 我发起的
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1063, 106, '我发起的', 'user:apply:mine', 1, '/user/apply/mine', 'user/apply/Mine', 'Edit', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 107. 组织与通讯录 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(107, 0, '组织与通讯录', '', 0, '/user/org', '', 'Phone', 8, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 107.1 组织架构
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1071, 107, '组织架构', 'user:org:tree', 1, '/user/org/tree', 'user/org/Tree', 'Share', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 107.2 企业通讯录
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1072, 107, '企业通讯录', 'user:org:address', 1, '/user/org/address', 'user/org/Address', 'Contact', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 108. 消息中心 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(108, 0, '消息中心', '', 0, '/user/message', '', 'Bell', 9, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 108.1 系统通知
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1081, 108, '系统通知', 'user:message:system', 1, '/user/message/system', 'user/message/System', 'Notification', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 108.2 公告通知
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1082, 108, '公告通知', 'user:message:notice', 1, '/user/message/notice', 'user/message/Notice', 'Bell', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 108.3 生日祝福
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1083, 108, '生日祝福', 'user:message:birthday', 1, '/user/message/birthday', 'user/message/Birthday', 'Cake', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 109. 员工自助 (顶级目录)
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(109, 0, '员工自助', '', 0, '/user/self', '', 'User', 10, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 109.1 信息修改申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1091, 109, '信息修改申请', 'user:self:info', 1, '/user/self/info', 'user/self/Info', 'Edit', 1, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 109.2 证明申请
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1092, 109, '证明申请', 'user:self:certificate', 1, '/user/self/certificate', 'user/self/Certificate', 'Ticket', 2, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 109.3 福利领取
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1093, 109, '福利领取', 'user:self:welfare', 1, '/user/self/welfare', 'user/self/Welfare', 'Gift', 3, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- 109.4 问卷调查
INSERT INTO t_sys_menu (id, parent_id, menu_name, perms, menu_type, path, component, icon, sort, status, create_time, update_time, is_deleted) VALUES
(1094, 109, '问卷调查', 'user:self:survey', 1, '/user/self/survey', 'user/self/Survey', 'PieChart', 4, 1, '2026-03-17 13:25:58', '2026-03-17 13:25:58', 0);

-- ---------------------------------------------
-- 说明汇总
-- ---------------------------------------------
-- 管理端顶级菜单(10个): 
-- 1.系统管理 2.组织人事 3.招聘管理 4.考勤管理 5.薪酬管理 
-- 6.绩效管理 7.培训管理 8.审批管理 9.员工关怀 10.数据分析
--
-- 用户端顶级菜单(10个):
-- 100.工作台 101.我的档案 102.考勤管理 103.薪酬管理 
-- 104.绩效管理 105.培训学习 106.我的申请 107.组织与通讯录 108.消息中心 109.员工自助
--
-- 路由前缀说明:
-- 管理端: /admin/*
-- 用户端: /user/*
--
-- 菜单类型说明:
-- 0 = 目录(可展开的分组)
-- 1 = 菜单(具体的页面)
-- 2 = 按钮(功能权限点)
--
-- 状态说明:
-- 0 = 隐藏
-- 1 = 显示
