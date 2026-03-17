-- ====================================================
-- HRM 系统完整建表脚本 v2.0.0
-- 数据库: hrm_db
-- 字符集: utf8mb4
-- 说明: 合并并优化所有历史SQL文件中的表结构
-- ====================================================

CREATE DATABASE IF NOT EXISTS hrm_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hrm_db;

-- ====================================================
-- 1. 系统管理模块
-- ====================================================

-- 系统用户表
DROP TABLE IF EXISTS t_sys_user;
CREATE TABLE t_sys_user (
    id           BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    username     VARCHAR(64)  NOT NULL COMMENT '用户名',
    password     VARCHAR(128) NOT NULL COMMENT '密码（BCrypt加密）',
    real_name    VARCHAR(64)  COMMENT '真实姓名',
    email        VARCHAR(128) COMMENT '邮箱',
    phone        VARCHAR(32)  COMMENT '手机号',
    avatar       VARCHAR(256) COMMENT '头像URL',
    employee_id  BIGINT       COMMENT '关联员工ID',
    status       TINYINT      NOT NULL DEFAULT 1 COMMENT '状态（0禁用/1启用）',
    last_login_ip VARCHAR(64) COMMENT '最后登录IP',
    last_login_time DATETIME  COMMENT '最后登录时间',
    pwd_update_time DATETIME  COMMENT '密码更新时间',
    create_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    is_deleted   TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除（0否/1是）',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- 角色表
DROP TABLE IF EXISTS t_sys_role;
CREATE TABLE t_sys_role (
    id           BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    role_name    VARCHAR(64)  NOT NULL COMMENT '角色名称',
    role_code    VARCHAR(64)  NOT NULL COMMENT '角色编码',
    description  VARCHAR(256) COMMENT '描述',
    data_scope   TINYINT      NOT NULL DEFAULT 1 COMMENT '数据权限范围（1全部/2本部门及以下/3本部门/4本人/5自定义）',
    status       TINYINT      NOT NULL DEFAULT 1 COMMENT '状态（0禁用/1启用）',
    create_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted   TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_role_code (role_code) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 菜单/权限表
DROP TABLE IF EXISTS t_sys_menu;
CREATE TABLE t_sys_menu (
    id          BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    parent_id   BIGINT       NOT NULL DEFAULT 0 COMMENT '父菜单ID（0顶级）',
    menu_name   VARCHAR(64)  NOT NULL COMMENT '菜单名称',
    perms       VARCHAR(128) COMMENT '权限标识（如 org:dept:add）',
    menu_type   TINYINT      NOT NULL DEFAULT 1 COMMENT '菜单类型（0目录/1菜单/2按钮）',
    path        VARCHAR(256) COMMENT '路由路径',
    component   VARCHAR(256) COMMENT '组件路径',
    icon        VARCHAR(64)  COMMENT '图标',
    sort        INT          NOT NULL DEFAULT 0 COMMENT '排序',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态（0隐藏/1显示）',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted  TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_parent_id (parent_id) USING BTREE,
    KEY idx_menu_type (menu_type) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单权限表';

-- 用户-角色关联表
DROP TABLE IF EXISTS t_sys_user_role;
CREATE TABLE t_sys_user_role (
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role_id BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 角色-菜单关联表
DROP TABLE IF EXISTS t_sys_role_menu;
CREATE TABLE t_sys_role_menu (
    role_id BIGINT NOT NULL COMMENT '角色ID',
    menu_id BIGINT NOT NULL COMMENT '菜单ID',
    PRIMARY KEY (role_id, menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联表';

-- 操作审计日志表
DROP TABLE IF EXISTS t_operation_log;
CREATE TABLE t_operation_log (
    id              BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    user_id         BIGINT       COMMENT '操作用户ID',
    username        VARCHAR(64)  COMMENT '操作用户名',
    module          VARCHAR(64)  COMMENT '操作模块',
    operation_type  VARCHAR(32)  COMMENT '操作类型（CREATE/UPDATE/DELETE/EXPORT/APPROVE）',
    description     VARCHAR(256) COMMENT '操作描述',
    request_uri     VARCHAR(512) COMMENT '请求URI',
    request_method  VARCHAR(16)  COMMENT '请求方法',
    request_params  TEXT         COMMENT '请求参数',
    result          VARCHAR(16)  COMMENT '操作结果（SUCCESS/FAIL）',
    error_msg       VARCHAR(512) COMMENT '错误信息',
    client_ip       VARCHAR(64)  COMMENT '客户端IP',
    user_agent      VARCHAR(512) COMMENT '用户代理',
    cost_time       BIGINT       COMMENT '执行耗时（毫秒）',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_user_id (user_id) USING BTREE,
    KEY idx_module (module) USING BTREE,
    KEY idx_create_time (create_time) USING BTREE,
    KEY idx_operation_type (operation_type) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作审计日志表';

-- 系统公告表
DROP TABLE IF EXISTS t_notice;
CREATE TABLE t_notice (
    id              BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    title           VARCHAR(128) NOT NULL COMMENT '公告标题',
    content         LONGTEXT     COMMENT '公告内容',
    notice_type     VARCHAR(32)  NOT NULL DEFAULT 'NOTICE' COMMENT '公告类型（NOTICE/ALERT/NEWS）',
    target_scope    VARCHAR(32)  NOT NULL DEFAULT 'ALL' COMMENT '目标范围（ALL/DEPT/ROLE）',
    target_ids      VARCHAR(512) COMMENT '目标ID列表（逗号分隔）',
    publisher_id    BIGINT       COMMENT '发布人ID',
    publish_time    DATETIME     COMMENT '发布时间',
    status          TINYINT      NOT NULL DEFAULT 0 COMMENT '状态（0草稿/1发布/2撤回）',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_status (status) USING BTREE,
    KEY idx_publish_time (publish_time) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统公告表';

-- 站内消息表
DROP TABLE IF EXISTS t_message;
CREATE TABLE t_message (
    id              BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    msg_type        VARCHAR(32)  NOT NULL COMMENT '消息类型（NOTICE/APPROVAL/SYSTEM/REMIND）',
    title           VARCHAR(128) NOT NULL COMMENT '消息标题',
    content         VARCHAR(1024) COMMENT '消息内容',
    receiver_id     BIGINT       NOT NULL COMMENT '接收人用户ID',
    sender_id       BIGINT       COMMENT '发送人用户ID',
    related_id      BIGINT       COMMENT '关联业务ID',
    related_type    VARCHAR(32)  COMMENT '关联业务类型',
    is_read         TINYINT      NOT NULL DEFAULT 0 COMMENT '是否已读（0未读/1已读）',
    read_time       DATETIME     COMMENT '已读时间',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_receiver (receiver_id, is_read) USING BTREE,
    KEY idx_create_time (create_time) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内消息表';

-- ====================================================
-- 2. 组织人事模块
-- ====================================================

-- 部门表
DROP TABLE IF EXISTS t_department;
CREATE TABLE t_department (
    id          BIGINT       NOT NULL COMMENT '部门ID（雪花算法）',
    parent_id   BIGINT       NOT NULL DEFAULT 0 COMMENT '父部门ID（0顶级）',
    dept_name   VARCHAR(64)  NOT NULL COMMENT '部门名称',
    dept_code   VARCHAR(32)  COMMENT '部门编码',
    leader_id   BIGINT       COMMENT '负责人员工ID',
    leader_name VARCHAR(64)  COMMENT '负责人姓名（冗余）',
    sort        INT          NOT NULL DEFAULT 0 COMMENT '排序',
    status      TINYINT      NOT NULL DEFAULT 1 COMMENT '状态（0停用/1启用）',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted  TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_dept_code (dept_code) USING BTREE,
    KEY idx_parent_id (parent_id) USING BTREE,
    KEY idx_leader_id (leader_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- 岗位表
DROP TABLE IF EXISTS t_position;
CREATE TABLE t_position (
    id             BIGINT       NOT NULL COMMENT '岗位ID（雪花算法）',
    position_code  VARCHAR(32)  NOT NULL COMMENT '岗位编码',
    position_name  VARCHAR(64)  NOT NULL COMMENT '岗位名称',
    dept_id        BIGINT       COMMENT '所属部门ID',
    level          VARCHAR(32)  COMMENT '岗位级别',
    job_desc       VARCHAR(512) COMMENT '岗位职责描述',
    requirements   VARCHAR(512) COMMENT '任职要求',
    sort           INT          NOT NULL DEFAULT 0,
    status         TINYINT      NOT NULL DEFAULT 1 COMMENT '状态（0停用/1启用）',
    create_time    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted     TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_position_code (position_code) USING BTREE,
    KEY idx_dept_id (dept_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='岗位表';

-- 员工主表
DROP TABLE IF EXISTS t_employee;
CREATE TABLE t_employee (
    id              BIGINT       NOT NULL COMMENT '员工ID（雪花算法）',
    emp_code        VARCHAR(32)  NOT NULL COMMENT '员工工号',
    emp_name        VARCHAR(64)  NOT NULL COMMENT '姓名',
    gender          TINYINT      COMMENT '性别（0女/1男）',
    birthday        DATE         COMMENT '出生日期',
    id_card         VARCHAR(64)  COMMENT '身份证号（AES加密）',
    phone           VARCHAR(32)  COMMENT '手机号（AES加密）',
    email           VARCHAR(128) COMMENT '邮箱',
    dept_id         BIGINT       COMMENT '所属部门ID',
    position_id     BIGINT       COMMENT '岗位ID',
    leader_id       BIGINT       COMMENT '直属上级员工ID',
    entry_date      DATE         COMMENT '入职日期',
    regular_date    DATE         COMMENT '转正日期',
    leave_date      DATE         COMMENT '离职日期',
    work_status     TINYINT      NOT NULL DEFAULT 1 COMMENT '在职状态（1试用/2在职/3离职/4退休）',
    work_type       VARCHAR(32)  COMMENT '用工类型（全职/兼职/实习/劳务）',
    contract_start  DATE         COMMENT '合同开始日期',
    contract_end    DATE         COMMENT '合同结束日期',
    bank_card       VARCHAR(64)  COMMENT '银行卡号（AES加密）',
    bank_name       VARCHAR(64)  COMMENT '开户行',
    education       VARCHAR(32)  COMMENT '学历',
    school          VARCHAR(128) COMMENT '毕业院校',
    major           VARCHAR(64)  COMMENT '专业',
    emergency_contact VARCHAR(32) COMMENT '紧急联系人',
    emergency_phone   VARCHAR(20) COMMENT '紧急联系电话',
    avatar          VARCHAR(256) COMMENT '头像URL',
    remark          VARCHAR(512) COMMENT '备注',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_emp_code (emp_code) USING BTREE,
    KEY idx_dept_id (dept_id) USING BTREE,
    KEY idx_position_id (position_id) USING BTREE,
    KEY idx_leader_id (leader_id) USING BTREE,
    KEY idx_work_status (work_status) USING BTREE,
    KEY idx_entry_date (entry_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工主表';

-- 员工工作履历表
DROP TABLE IF EXISTS t_emp_work_history;
CREATE TABLE t_emp_work_history (
    id            BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id   BIGINT       NOT NULL COMMENT '员工ID',
    company_name  VARCHAR(100) NOT NULL COMMENT '公司名称',
    position      VARCHAR(80)  COMMENT '担任职位',
    start_date    DATE         COMMENT '开始日期',
    end_date      DATE         COMMENT '结束日期',
    leave_reason  VARCHAR(255) COMMENT '离职原因',
    witness       VARCHAR(50)  COMMENT '证明人',
    witness_phone VARCHAR(20)  COMMENT '证明人电话',
    remark        VARCHAR(255) COMMENT '备注',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted    TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工工作履历表';

-- 员工家庭成员表
DROP TABLE IF EXISTS t_emp_family;
CREATE TABLE t_emp_family (
    id           BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id  BIGINT       NOT NULL COMMENT '员工ID',
    relation     VARCHAR(20)  NOT NULL COMMENT '关系（配偶/父亲/母亲/子女/其他）',
    member_name  VARCHAR(50)  NOT NULL COMMENT '成员姓名',
    birthday     DATE         COMMENT '出生日期',
    phone        VARCHAR(20)  COMMENT '联系电话',
    work_unit    VARCHAR(100) COMMENT '工作单位',
    is_emergency TINYINT      NOT NULL DEFAULT 0 COMMENT '是否紧急联系人（0否/1是）',
    remark       VARCHAR(255) COMMENT '备注',
    create_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted   TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_is_emergency (is_emergency) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工家庭成员表';

-- 人事变动记录表
DROP TABLE IF EXISTS t_emp_change;
CREATE TABLE t_emp_change (
    id                  BIGINT       NOT NULL COMMENT '变动记录ID（雪花算法）',
    employee_id         BIGINT       NOT NULL COMMENT '员工ID',
    change_type         VARCHAR(32)  NOT NULL COMMENT '变动类型（ONBOARD入职/TRANSFER调岗/PROMOTION晋升/OFFBOARD离职/REGULAR转正）',
    before_dept_id      BIGINT       COMMENT '变动前部门ID',
    after_dept_id       BIGINT       COMMENT '变动后部门ID',
    before_position_id  BIGINT       COMMENT '变动前岗位ID',
    after_position_id   BIGINT       COMMENT '变动后岗位ID',
    before_leader_id    BIGINT       COMMENT '变动前上级ID',
    after_leader_id     BIGINT       COMMENT '变动后上级ID',
    effective_date      DATE         COMMENT '生效日期',
    operator_id         BIGINT       COMMENT '操作人ID',
    remark              VARCHAR(512) COMMENT '备注',
    create_time         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted          TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_change_type (change_type) USING BTREE,
    KEY idx_effective_date (effective_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='人事变动记录表';

-- 劳动合同表
DROP TABLE IF EXISTS t_emp_contract;
CREATE TABLE t_emp_contract (
    id              BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id     BIGINT       NOT NULL COMMENT '员工ID',
    contract_no     VARCHAR(64)  NOT NULL COMMENT '合同编号',
    contract_type   VARCHAR(32)  NOT NULL COMMENT '合同类型（FIXED固定期限/OPEN无固定期限/PROJECT项目）',
    start_date      DATE         NOT NULL COMMENT '合同开始日期',
    end_date        DATE         COMMENT '合同结束日期（无固定期限时为空）',
    sign_date       DATE         NOT NULL COMMENT '签订日期',
    probation_months INT         COMMENT '试用期（月）',
    probation_end   DATE         COMMENT '试用期结束日期',
    status          TINYINT      NOT NULL DEFAULT 1 COMMENT '合同状态（0草稿/1生效/2到期/3终止/4续签中）',
    file_url        VARCHAR(512) COMMENT '合同文件URL',
    remark          VARCHAR(512) COMMENT '备注',
    create_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_contract_no (contract_no) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_status (status) USING BTREE,
    KEY idx_end_date (end_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='劳动合同表';

-- ====================================================
-- 3. 招聘管理模块
-- ====================================================

-- 招聘职位表
DROP TABLE IF EXISTS t_recruit_job;
CREATE TABLE t_recruit_job (
    id          BIGINT        NOT NULL COMMENT '职位ID（雪花算法）',
    job_name    VARCHAR(64)   NOT NULL COMMENT '职位名称',
    dept_id     BIGINT        COMMENT '所属部门ID',
    dept_name   VARCHAR(64)   COMMENT '部门名称（冗余）',
    headcount   INT           NOT NULL DEFAULT 1 COMMENT '招聘人数',
    hired_count INT           NOT NULL DEFAULT 0 COMMENT '已录用人数',
    education   VARCHAR(32)   COMMENT '学历要求',
    experience  VARCHAR(64)   COMMENT '工作经验要求',
    salary_min  DECIMAL(10,2) COMMENT '最低薪资',
    salary_max  DECIMAL(10,2) COMMENT '最高薪资',
    description TEXT          COMMENT '职位描述',
    requirement TEXT          COMMENT '任职要求',
    deadline    DATE          COMMENT '截止日期',
    status      TINYINT       NOT NULL DEFAULT 1 COMMENT '状态（0关闭/1招募中/2暂停）',
    create_time DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted  TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_dept_id (dept_id) USING BTREE,
    KEY idx_status (status) USING BTREE,
    KEY idx_deadline (deadline) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='招聘职位表';

-- 候选人表
DROP TABLE IF EXISTS t_recruit_candidate;
CREATE TABLE t_recruit_candidate (
    id               BIGINT        NOT NULL COMMENT '候选人ID（雪花算法）',
    job_id           BIGINT        COMMENT '关联职位ID',
    name             VARCHAR(64)   NOT NULL COMMENT '姓名',
    gender           TINYINT       COMMENT '性别（0女/1男）',
    phone            VARCHAR(32)   COMMENT '手机号',
    email            VARCHAR(128)  COMMENT '邮箱',
    education        VARCHAR(32)   COMMENT '学历',
    school           VARCHAR(128)  COMMENT '毕业院校',
    major            VARCHAR(64)   COMMENT '专业',
    graduation_year  INT           COMMENT '毕业年份',
    work_years       INT           COMMENT '工作年限',
    current_company  VARCHAR(128)  COMMENT '当前单位',
    current_position VARCHAR(64)   COMMENT '当前职位',
    resume_url       VARCHAR(256)  COMMENT '简历附件URL',
    source           VARCHAR(32)   COMMENT '来源（猎头/招聘网站/内部推荐/自荐）',
    stage            TINYINT       NOT NULL DEFAULT 0 COMMENT '面试阶段（0简历筛选/1初试/2复试/3终试/4Offer/5已录用/6淘汰/7放弃）',
    expected_salary  VARCHAR(64)   COMMENT '期望薪资',
    offer_salary     DECIMAL(10,2) COMMENT 'Offer薪资',
    interview_times  INT           NOT NULL DEFAULT 0 COMMENT '面试次数',
    evaluator        VARCHAR(64)   COMMENT '面试评价',
    remark           VARCHAR(512)  COMMENT '备注',
    create_time      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_job_id (job_id) USING BTREE,
    KEY idx_stage (stage) USING BTREE,
    KEY idx_phone (phone) USING BTREE,
    KEY idx_email (email) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='候选人表';

-- 面试记录表
DROP TABLE IF EXISTS t_recruit_interview;
CREATE TABLE t_recruit_interview (
    id              BIGINT        NOT NULL COMMENT '面试记录ID（雪花算法）',
    candidate_id    BIGINT        NOT NULL COMMENT '候选人ID',
    job_id          BIGINT        COMMENT '职位ID',
    round           TINYINT       NOT NULL DEFAULT 1 COMMENT '面试轮次',
    interviewer_id  BIGINT        COMMENT '面试官员工ID',
    interviewer_name VARCHAR(64)  COMMENT '面试官姓名（冗余）',
    interview_time  DATETIME      COMMENT '面试时间',
    type            TINYINT       NOT NULL DEFAULT 0 COMMENT '面试方式（0现场/1视频/2电话）',
    result          TINYINT       NOT NULL DEFAULT 0 COMMENT '结果（0待面试/1通过/2不通过/3爽约）',
    score           DECIMAL(5,2)  COMMENT '面试评分',
    comment         TEXT          COMMENT '面试评价',
    next_round      TINYINT       COMMENT '下一轮次（0无/1初试/2复试/3终试）',
    next_time       DATETIME      COMMENT '下次面试时间',
    create_time     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_candidate_id (candidate_id) USING BTREE,
    KEY idx_interviewer_id (interviewer_id) USING BTREE,
    KEY idx_interview_time (interview_time) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='面试记录表';

-- ====================================================
-- 4. 考勤管理模块
-- ====================================================

-- 考勤规则表
DROP TABLE IF EXISTS t_attendance_rule;
CREATE TABLE t_attendance_rule (
    id           BIGINT        NOT NULL COMMENT '规则ID（雪花算法）',
    rule_name    VARCHAR(64)   NOT NULL COMMENT '规则名称',
    rule_code    VARCHAR(32)   COMMENT '规则编码',
    work_start   VARCHAR(8)    COMMENT '上班时间（HH:mm）',
    work_end     VARCHAR(8)    COMMENT '下班时间（HH:mm）',
    flex_minutes INT           NOT NULL DEFAULT 0 COMMENT '弹性分钟数',
    work_type    TINYINT       NOT NULL DEFAULT 0 COMMENT '工时类型（0标准/1综合/2弹性）',
    late_minutes INT           NOT NULL DEFAULT 0 COMMENT '迟到宽容分钟数',
    early_minutes INT          NOT NULL DEFAULT 0 COMMENT '早退宽容分钟数',
    need_checkin TINYINT       NOT NULL DEFAULT 1 COMMENT '是否需要打卡（0否/1是）',
    status       TINYINT       NOT NULL DEFAULT 1 COMMENT '状态（0停用/1启用）',
    create_time  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted   TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_rule_code (rule_code) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤规则表';

-- 员工排班表
DROP TABLE IF EXISTS t_attendance_shift;
CREATE TABLE t_attendance_shift (
    id          BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id BIGINT       NOT NULL COMMENT '员工ID',
    shift_date  DATE         NOT NULL COMMENT '排班日期',
    shift_type  TINYINT      NOT NULL DEFAULT 0 COMMENT '班次类型（0正常班/1早班/2中班/3晚班/4休息/5节假日）',
    rule_id     BIGINT       COMMENT '考勤规则ID',
    start_time  TIME         COMMENT '自定义上班时间',
    end_time    TIME         COMMENT '自定义下班时间',
    remark      VARCHAR(200) COMMENT '备注',
    create_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted  TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_emp_date (employee_id, shift_date) USING BTREE,
    KEY idx_shift_date (shift_date) USING BTREE,
    KEY idx_rule_id (rule_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工排班表';

-- 考勤打卡记录表
DROP TABLE IF EXISTS t_attendance_record;
CREATE TABLE t_attendance_record (
    id               BIGINT    NOT NULL COMMENT '记录ID（雪花算法）',
    employee_id      BIGINT    NOT NULL COMMENT '员工ID',
    attendance_date  DATE      NOT NULL COMMENT '考勤日期',
    check_in_time    DATETIME  COMMENT '签到时间',
    check_out_time   DATETIME  COMMENT '签退时间',
    check_in_type    TINYINT   COMMENT '签到方式（0考勤机/1手机/2电脑）',
    check_out_type   TINYINT   COMMENT '签退方式（0考勤机/1手机/2电脑）',
    work_hours       DECIMAL(5,2) COMMENT '工作时长（小时）',
    status           TINYINT   NOT NULL DEFAULT 0 COMMENT '状态（0正常/1迟到/2早退/3缺勤/4请假/5加班/6出差/7外勤）',
    remark           VARCHAR(256) COMMENT '备注',
    create_time      DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT   NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_date (employee_id, attendance_date) USING BTREE,
    KEY idx_attendance_date (attendance_date) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='考勤打卡记录表';

-- 假期额度表
DROP TABLE IF EXISTS t_holiday_quota;
CREATE TABLE t_holiday_quota (
    id                    BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id           BIGINT       NOT NULL COMMENT '员工ID',
    year                  INT          NOT NULL COMMENT '年度',
    holiday_type          VARCHAR(32)  NOT NULL DEFAULT 'ANNUAL' COMMENT '假期类型（ANNUAL年假/SICK病假/PERSONAL事假/MARRIAGE婚假/MATERNITY产假/FUNERAL丧假）',
    total                 DECIMAL(5,1) NOT NULL DEFAULT 0 COMMENT '总额度（天）',
    used                  DECIMAL(5,1) NOT NULL DEFAULT 0 COMMENT '已用（天）',
    remaining             DECIMAL(5,1) GENERATED ALWAYS AS (total - used) STORED COMMENT '剩余（天，自动计算，MyBatis 禁止写入）',
    carry_over            DECIMAL(5,1) DEFAULT 0 COMMENT '结转（天）',
    expire_date           DATE         COMMENT '过期日期',
    create_time           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted            TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_emp_year_type (employee_id, year, holiday_type) USING BTREE,
    KEY idx_year (year) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工假期额度表';

-- 请假/加班申请表
DROP TABLE IF EXISTS t_attendance_apply;
CREATE TABLE t_attendance_apply (
    id               BIGINT          NOT NULL COMMENT '申请ID（雪花算法）',
    employee_id      BIGINT          NOT NULL COMMENT '员工ID',
    apply_type       TINYINT         NOT NULL COMMENT '申请类型（0请假/1加班/2调休/3出差/4外勤）',
    leave_type       VARCHAR(32)     COMMENT '假期类型（ANNUAL/SICK/PERSONAL等）',
    start_time       DATETIME        NOT NULL COMMENT '开始时间',
    end_time         DATETIME        NOT NULL COMMENT '结束时间',
    duration         DECIMAL(5,1)    NOT NULL DEFAULT 0 COMMENT '时长（天）',
    reason           VARCHAR(512)    COMMENT '申请原因',
    attachment_url   VARCHAR(512)    COMMENT '附件URL',
    approval_status  TINYINT         NOT NULL DEFAULT 0 COMMENT '审批状态（0待审批/1通过/2拒绝/3撤回/4驳回）',
    approver_id      BIGINT          COMMENT '审批人',
    approver_name    VARCHAR(64)     COMMENT '审批人姓名',
    approval_time    DATETIME        COMMENT '审批时间',
    approval_comment VARCHAR(512)    COMMENT '审批意见',
    instance_id      BIGINT          COMMENT '审批流程实例ID',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_approval_status (approval_status) USING BTREE,
    KEY idx_apply_type (apply_type) USING BTREE,
    KEY idx_start_time (start_time) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='请假/加班申请表';

-- ====================================================
-- 5. 薪酬管理模块
-- ====================================================

-- 薪资等级体系表
DROP TABLE IF EXISTS t_salary_grade;
CREATE TABLE t_salary_grade (
    id                  BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    grade_code          VARCHAR(32)     NOT NULL COMMENT '等级编码（如 P1/P2/M1/M2）',
    grade_name          VARCHAR(64)     NOT NULL COMMENT '等级名称',
    series              VARCHAR(32)     COMMENT '职级序列（技术/管理/销售/运营/职能）',
    min_salary          DECIMAL(12,2)   COMMENT '薪资下限',
    max_salary          DECIMAL(12,2)   COMMENT '薪资上限',
    mid_salary          DECIMAL(12,2)   COMMENT '参考中位值',
    position_allowance  DECIMAL(12,2)   COMMENT '岗位津贴参考值',
    promotion_years     INT             COMMENT '晋升参考年限',
    remark              VARCHAR(512)    COMMENT '备注说明',
    status              TINYINT         NOT NULL DEFAULT 1 COMMENT '状态（1启用/0停用）',
    create_time         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted          TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_grade_code (grade_code, is_deleted) USING BTREE,
    KEY idx_series (series) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资等级体系表';

-- 薪资档案表
DROP TABLE IF EXISTS t_salary_config;
CREATE TABLE t_salary_config (
    id                    BIGINT          NOT NULL COMMENT '配置ID（雪花算法）',
    employee_id           BIGINT          NOT NULL COMMENT '员工ID',
    grade_id              BIGINT          COMMENT '薪资等级ID',
    base_salary           DECIMAL(12,2)   NOT NULL DEFAULT 0 COMMENT '基本工资',
    position_allowance    DECIMAL(12,2)   COMMENT '岗位津贴',
    technical_allowance   DECIMAL(12,2)   COMMENT '技术津贴',
    performance_allowance DECIMAL(12,2)   COMMENT '绩效津贴',
    transport_allowance   DECIMAL(12,2)   COMMENT '交通补贴',
    meal_allowance        DECIMAL(12,2)   COMMENT '餐饮补贴',
    communication_allowance DECIMAL(12,2) COMMENT '通讯补贴',
    housing_allowance     DECIMAL(12,2)   COMMENT '住房补贴',
    other_allowance       DECIMAL(12,2)   COMMENT '其他津贴',
    social_insurance_rate DECIMAL(5,2)    NOT NULL DEFAULT 8.00 COMMENT '社保个人缴纳比例(%)',
    housing_fund_rate     DECIMAL(5,2)    NOT NULL DEFAULT 12.00 COMMENT '公积金个人缴纳比例(%)',
    effective_month       VARCHAR(7)      COMMENT '生效月份（yyyy-MM）',
    expire_month          VARCHAR(7)      COMMENT '失效月份（yyyy-MM）',
    status                TINYINT         NOT NULL DEFAULT 1 COMMENT '状态（0停用/1启用）',
    create_time           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted            TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_employee_effect (employee_id, effective_month) USING BTREE,
    KEY idx_grade_id (grade_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪资档案表';

-- 月度薪酬记录表
DROP TABLE IF EXISTS t_salary_record;
CREATE TABLE t_salary_record (
    id               BIGINT          NOT NULL COMMENT '记录ID（雪花算法）',
    employee_id      BIGINT          NOT NULL COMMENT '员工ID',
    pay_month        VARCHAR(7)      NOT NULL COMMENT '薪酬月份（yyyy-MM）',
    base_salary      DECIMAL(12,2)   NOT NULL DEFAULT 0 COMMENT '基本工资',
    allowance        DECIMAL(12,2)   COMMENT '津贴合计',
    bonus            DECIMAL(12,2)   COMMENT '奖金',
    overtime_pay     DECIMAL(12,2)   COMMENT '加班工资',
    commission       DECIMAL(12,2)   COMMENT '提成',
    social_insurance DECIMAL(12,2)   COMMENT '社保（个人）',
    housing_fund     DECIMAL(12,2)   COMMENT '公积金（个人）',
    deduction        DECIMAL(12,2)   COMMENT '其他扣款',
    taxable_income   DECIMAL(12,2)   COMMENT '应纳税所得额',
    personal_tax     DECIMAL(12,2)   COMMENT '个税',
    actual_pay       DECIMAL(12,2)   NOT NULL COMMENT '实发工资',
    work_days        INT             COMMENT '计薪天数',
    status           TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0草稿/1已确认/2已发放/3已冻结）',
    remark           VARCHAR(512)    COMMENT '备注',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_emp_month (employee_id, pay_month) USING BTREE,
    KEY idx_pay_month (pay_month) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='月度薪酬记录表';

-- 薪酬调整申请表
DROP TABLE IF EXISTS t_salary_adjust;
CREATE TABLE t_salary_adjust (
    id              BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id     BIGINT          NOT NULL COMMENT '员工ID',
    adjust_type     VARCHAR(32)     NOT NULL COMMENT '调整类型（UP加薪/DOWN降薪/PROMOTION晋升/SPECIAL特殊）',
    before_salary   DECIMAL(12,2)   COMMENT '调整前基本工资',
    after_salary    DECIMAL(12,2)   NOT NULL COMMENT '调整后基本工资',
    adjust_percent  DECIMAL(8,2)    COMMENT '调整幅度（%）',
    effective_date  DATE            COMMENT '生效日期',
    apply_user_id   BIGINT          NOT NULL COMMENT '申请人ID',
    apply_reason    VARCHAR(512)    COMMENT '申请原因',
    approve_user_id BIGINT          COMMENT '审批人ID',
    approve_comment VARCHAR(512)    COMMENT '审批意见',
    approve_time    DATETIME        COMMENT '审批时间',
    status          TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0待审批/1通过/2拒绝/3撤回）',
    instance_id     BIGINT          COMMENT '审批流程实例ID',
    create_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_status (status) USING BTREE,
    KEY idx_effective_date (effective_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='薪酬调整申请表';

-- ====================================================
-- 6. 绩效管理模块
-- ====================================================

-- 绩效方案表
DROP TABLE IF EXISTS t_perf_plan;
CREATE TABLE t_perf_plan (
    id                  BIGINT        NOT NULL COMMENT '方案ID（雪花算法）',
    plan_name           VARCHAR(64)   NOT NULL COMMENT '方案名称',
    plan_code           VARCHAR(32)   COMMENT '方案编码',
    cycle               VARCHAR(16)   NOT NULL COMMENT '考核周期（MONTHLY月度/QUARTERLY季度/HALFYEAR半年/ANNUAL年度）',
    year                INT           NOT NULL COMMENT '考核年份',
    period              TINYINT       NOT NULL DEFAULT 1 COMMENT '考核期数',
    kpi_weight          INT           NOT NULL DEFAULT 60 COMMENT 'KPI权重(%)',
    behavior_weight     INT           NOT NULL DEFAULT 20 COMMENT '行为评分权重(%)',
    evaluation_weight   INT           NOT NULL DEFAULT 20 COMMENT '360评分权重(%)',
    start_date          DATE          COMMENT '考核开始日期',
    end_date            DATE          COMMENT '考核结束日期',
    status              TINYINT       NOT NULL DEFAULT 0 COMMENT '状态（0草稿/1进行中/2已完成/3已归档）',
    description         VARCHAR(512)  COMMENT '描述',
    create_time         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted          TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_plan_code (plan_code) USING BTREE,
    KEY idx_year_period (year, period) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效方案表';

-- 绩效评估结果表
DROP TABLE IF EXISTS t_perf_result;
CREATE TABLE t_perf_result (
    id                BIGINT          NOT NULL COMMENT '结果ID（雪花算法）',
    plan_id           BIGINT          NOT NULL COMMENT '绩效方案ID',
    employee_id       BIGINT          NOT NULL COMMENT '员工ID',
    kpi_score         DECIMAL(5,2)    COMMENT 'KPI得分',
    behavior_score    DECIMAL(5,2)    COMMENT '行为评分',
    evaluation_score  DECIMAL(5,2)    COMMENT '360评分',
    total_score       DECIMAL(5,2)    COMMENT '综合得分',
    grade             VARCHAR(4)      COMMENT '绩效等级（A/B/C/D/E）',
    rating            VARCHAR(16)     COMMENT '评级（EXCELLENT/GOOD/NEEDS_IMPROVEMENT/UNSATISFACTORY）',
    evaluator_id      BIGINT          COMMENT '评估人',
    evaluator_name    VARCHAR(64)     COMMENT '评估人姓名',
    evaluate_time     DATETIME        COMMENT '评估时间',
    comment           TEXT            COMMENT '评估意见',
    status            TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0待评估/1已评估/2已校准/3已确认）',
    create_time       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted        TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_plan_emp (plan_id, employee_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效评估结果表';

-- 绩效目标表（KPI/OKR 双模式）
DROP TABLE IF EXISTS t_perf_objective;
CREATE TABLE t_perf_objective (
    id                   BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    plan_id              BIGINT          COMMENT '绩效方案ID',
    employee_id          BIGINT          NOT NULL COMMENT '员工ID',
    parent_id            BIGINT          COMMENT '父目标ID（OKR 中 KR 挂在 O 下面）',
    objective_type       VARCHAR(32)     NOT NULL DEFAULT 'KPI' COMMENT '目标类型：OBJECTIVE/KEY_RESULT/KPI',
    title                VARCHAR(256)    NOT NULL COMMENT '目标标题',
    description          TEXT            COMMENT '目标描述',
    priority             VARCHAR(16)     DEFAULT 'MEDIUM' COMMENT '优先级（HIGH/MEDIUM/LOW）',
    weight               INT             DEFAULT 0 COMMENT '权重（0-100）',
    target_value         DECIMAL(18,4)   COMMENT '目标值',
    actual_value         DECIMAL(18,4)   COMMENT '当前值/实际完成值',
    progress_percent     INT             DEFAULT 0 COMMENT '进度百分比（0-100）',
    start_date           DATE            COMMENT '开始日期',
    due_date             DATE            COMMENT '截止日期',
    aligned_objective_id BIGINT          COMMENT '对齐的上级目标ID',
    period               VARCHAR(32)     COMMENT '考核周期标识（如 2026-Q1）',
    status               TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0进行中/1已完成/2已放弃）',
    create_time          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted           TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_plan_id (plan_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_parent_id (parent_id) USING BTREE,
    KEY idx_period (period) USING BTREE,
    KEY idx_status (status) USING BTREE,
    KEY idx_aligned (aligned_objective_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效目标表（KPI/OKR 双模式）';

-- 绩效目标对齐关系表
DROP TABLE IF EXISTS t_perf_objective_align;
CREATE TABLE t_perf_objective_align (
    id                   BIGINT NOT NULL COMMENT '主键ID（雪花算法）',
    source_objective_id  BIGINT NOT NULL COMMENT '发起对齐的目标ID（下级目标）',
    target_objective_id  BIGINT NOT NULL COMMENT '被对齐的目标ID（上级目标）',
    source_employee_id   BIGINT COMMENT '下级员工ID',
    target_employee_id   BIGINT COMMENT '上级员工ID',
    align_desc           VARCHAR(512) COMMENT '对齐说明',
    create_time          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_deleted           TINYINT  NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_source (source_objective_id) USING BTREE,
    KEY idx_target (target_objective_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效目标对齐关系表';

-- 绩效改进计划表（PIP）
DROP TABLE IF EXISTS t_perf_improve_plan;
CREATE TABLE t_perf_improve_plan (
    id               BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    perf_result_id   BIGINT          COMMENT '关联绩效结果ID',
    employee_id      BIGINT          NOT NULL COMMENT '员工ID',
    plan_name        VARCHAR(256)    NOT NULL COMMENT '计划名称',
    period           VARCHAR(32)     COMMENT '改进周期（如 2026-Q1）',
    start_date       DATE            COMMENT '计划开始日期',
    end_date         DATE            COMMENT '计划结束日期',
    problem_desc     TEXT            COMMENT '绩效问题描述',
    improve_goal     TEXT            COMMENT '改进目标',
    support_measures TEXT            COMMENT '支持措施（培训/辅导/资源）',
    milestones       TEXT            COMMENT '里程碑/时间节点（JSON格式）',
    hr_owner_id      BIGINT          COMMENT 'HR负责人ID',
    manager_id       BIGINT          COMMENT '直属上级ID',
    result           VARCHAR(32)     COMMENT '最终结果（PASS/FAIL/IN_PROGRESS）',
    result_comment   TEXT            COMMENT '结果说明',
    status           TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0制定中/1进行中/2已完成/3已取消）',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_perf_result_id (perf_result_id) USING BTREE,
    KEY idx_manager_id (manager_id) USING BTREE,
    KEY idx_hr_owner_id (hr_owner_id) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效改进计划（PIP）';

-- 绩效过程跟踪表
DROP TABLE IF EXISTS t_perf_track;
CREATE TABLE t_perf_track (
    id              BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    perf_result_id  BIGINT          NOT NULL COMMENT '绩效结果ID',
    employee_id     BIGINT          NOT NULL COMMENT '员工ID',
    track_type      VARCHAR(32)     NOT NULL COMMENT '跟踪类型（FEEDBACK反馈/PROGRESS进度/COACHING辅导/REVIEW评审）',
    content         TEXT            COMMENT '跟踪内容',
    progress_percent INT            COMMENT '进度百分比（0-100）',
    operator_id     BIGINT          COMMENT '操作人ID',
    operator_name   VARCHAR(64)     COMMENT '操作人姓名',
    create_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_perf_result (perf_result_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='绩效过程跟踪表';

-- ====================================================
-- 7. 培训管理模块
-- ====================================================

-- 培训课程表
DROP TABLE IF EXISTS t_training_course;
CREATE TABLE t_training_course (
    id              BIGINT        NOT NULL COMMENT '课程ID（雪花算法）',
    course_name     VARCHAR(128)  NOT NULL COMMENT '课程名称',
    course_code     VARCHAR(32)   COMMENT '课程编码',
    category        VARCHAR(32)   COMMENT '课程分类',
    course_type     TINYINT       NOT NULL DEFAULT 0 COMMENT '课程类型（0内部/1外部）',
    instructor      VARCHAR(64)   COMMENT '讲师',
    duration        DECIMAL(5,1)  COMMENT '时长（小时）',
    credits         INT           COMMENT '学分',
    description     TEXT          COMMENT '课程描述',
    objectives      TEXT          COMMENT '学习目标',
    target_audience VARCHAR(512)  COMMENT '适用对象',
    attachment_url  VARCHAR(256)  COMMENT '资料附件URL',
    cover_url       VARCHAR(256)  COMMENT '封面图片URL',
    status          TINYINT       NOT NULL DEFAULT 1 COMMENT '状态（0下架/1上架）',
    create_time     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_code (course_code) USING BTREE,
    KEY idx_category (category) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训课程表';

-- 培训讲师表
DROP TABLE IF EXISTS t_training_instructor;
CREATE TABLE t_training_instructor (
    id               BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    name             VARCHAR(64)     NOT NULL COMMENT '讲师姓名',
    employee_id      BIGINT          COMMENT '关联员工ID（外部讲师为NULL）',
    instructor_type  TINYINT         NOT NULL DEFAULT 0 COMMENT '类型（0内部/1外部）',
    expertise        VARCHAR(512)    COMMENT '专业领域（逗号分隔）',
    title            VARCHAR(64)     COMMENT '职称/头衔',
    bio              TEXT            COMMENT '个人简介',
    contact          VARCHAR(128)    COMMENT '联系方式',
    avatar_url       VARCHAR(256)    COMMENT '头像URL',
    teach_hours      INT             DEFAULT 0 COMMENT '累计授课时长（小时）',
    rating           DECIMAL(3,1)    DEFAULT 5.0 COMMENT '评分（1.0~5.0）',
    status           TINYINT         NOT NULL DEFAULT 1 COMMENT '状态（0停用/1启用）',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训讲师表';

-- 培训需求表
DROP TABLE IF EXISTS t_training_need;
CREATE TABLE t_training_need (
    id               BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    year             INT             COMMENT '需求年度',
    dept_id          BIGINT          COMMENT '提报部门ID',
    dept_name        VARCHAR(64)     COMMENT '部门名称（冗余）',
    employee_id      BIGINT          COMMENT '提报员工ID',
    employee_name    VARCHAR(64)     COMMENT '提报人姓名（冗余）',
    need_title       VARCHAR(256)    NOT NULL COMMENT '需求标题',
    need_desc        TEXT            COMMENT '需求描述',
    category         VARCHAR(64)     COMMENT '培训类别',
    priority         TINYINT         DEFAULT 2 COMMENT '优先级（1低/2中/3高）',
    expected_time    DATE            COMMENT '期望培训时间',
    participants     INT             COMMENT '预计参与人数',
    status           TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0待审核/1已纳入计划/2已拒绝/3已完成）',
    plan_activity_id BIGINT          COMMENT '关联培训活动ID',
    remark           VARCHAR(512)    COMMENT '备注',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_dept_id (dept_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_year (year) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训需求表';

-- 培训活动表
DROP TABLE IF EXISTS t_training_activity;
CREATE TABLE t_training_activity (
    id                      BIGINT        NOT NULL COMMENT '活动ID（雪花算法）',
    course_id               BIGINT        COMMENT '关联课程ID',
    instructor_id           BIGINT        COMMENT '讲师ID',
    title                   VARCHAR(128)  NOT NULL COMMENT '活动标题',
    start_date              DATE          COMMENT '开始日期',
    end_date                DATE          COMMENT '结束日期',
    start_time              TIME          COMMENT '开始时间',
    end_time                TIME          COMMENT '结束时间',
    location                VARCHAR(128)  COMMENT '培训地点',
    registration_deadline   DATE          COMMENT '报名截止日期',
    max_participants        INT           COMMENT '最大人数',
    current_participants    INT           NOT NULL DEFAULT 0 COMMENT '当前报名人数',
    actual_participants     INT           NOT NULL DEFAULT 0 COMMENT '实际参加人数',
    hours                   DECIMAL(5,1)  COMMENT '培训时长（小时）',
    credit                  INT           COMMENT '可获得学分',
    exam_required           TINYINT       NOT NULL DEFAULT 0 COMMENT '是否需要考试（0否/1是）',
    pass_score              INT           COMMENT '及格分数',
    status                  TINYINT       NOT NULL DEFAULT 0 COMMENT '状态（0草稿/1报名中/2进行中/3已完成/4已取消）',
    create_time             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted              TINYINT       NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_course_id (course_id) USING BTREE,
    KEY idx_instructor_id (instructor_id) USING BTREE,
    KEY idx_status (status) USING BTREE,
    KEY idx_start_date (start_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训活动表';

-- 培训报名学习记录表
DROP TABLE IF EXISTS t_training_record;
CREATE TABLE t_training_record (
    id                  BIGINT    NOT NULL COMMENT '记录ID（雪花算法）',
    activity_id         BIGINT    NOT NULL COMMENT '培训活动ID',
    employee_id         BIGINT    NOT NULL COMMENT '员工ID',
    enroll_status       TINYINT   NOT NULL DEFAULT 0 COMMENT '报名状态（0待审核/1已通过/2已拒绝/3已取消/4已签到）',
    enroll_time         DATETIME  COMMENT '报名时间',
    enroll_remark       VARCHAR(256) COMMENT '报名备注',
    completion_status   TINYINT   NOT NULL DEFAULT 0 COMMENT '完成状态（0未完成/1已完成）',
    exam_score          INT       COMMENT '考试得分',
    exam_status         TINYINT   COMMENT '考试状态（0未开始/1进行中/2已完成）',
    satisfaction_score  TINYINT   COMMENT '满意度（1-5）',
    feedback            TEXT      COMMENT '学习反馈',
    certificate_url     VARCHAR(256) COMMENT '证书URL',
    create_time         DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time         DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted          TINYINT   NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_activity_emp (activity_id, employee_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_enroll_status (enroll_status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训报名学习记录表';

-- 培训签到表
DROP TABLE IF EXISTS t_training_checkin;
CREATE TABLE t_training_checkin (
    id               BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    activity_id      BIGINT          NOT NULL COMMENT '培训活动ID',
    employee_id      BIGINT          NOT NULL COMMENT '员工ID',
    checkin_date     DATE            NOT NULL COMMENT '签到日期（冗余字段，用于唯一索引，兼容 MySQL 5.7）',
    checkin_time     DATETIME        COMMENT '签到时间',
    checkout_time    DATETIME        COMMENT '签退时间',
    checkin_type     TINYINT         DEFAULT 0 COMMENT '签到方式（0手动/1扫码/2人脸）',
    is_late          TINYINT         DEFAULT 0 COMMENT '是否迟到（0否/1是）',
    leave_early      TINYINT         DEFAULT 0 COMMENT '是否早退（0否/1是）',
    duration_minutes INT             COMMENT '参与时长（分钟）',
    remark           VARCHAR(512)    COMMENT '备注',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_activity_id (activity_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    UNIQUE KEY uk_activity_emp_day (activity_id, employee_id, checkin_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训签到表';

-- 在线学习进度表
DROP TABLE IF EXISTS t_training_learn_progress;
CREATE TABLE t_training_learn_progress (
    id               BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    course_id        BIGINT          NOT NULL COMMENT '课程ID',
    employee_id      BIGINT          NOT NULL COMMENT '员工ID',
    chapter_index    INT             DEFAULT 0 COMMENT '当前章节序号',
    progress_pct     INT             DEFAULT 0 COMMENT '进度百分比（0~100）',
    study_minutes    INT             DEFAULT 0 COMMENT '累计学习时长（分钟）',
    last_position    INT             DEFAULT 0 COMMENT '视频播放位置（秒）',
    last_study_time  DATETIME        COMMENT '最后学习时间',
    is_completed     TINYINT         DEFAULT 0 COMMENT '是否完成（0否/1是）',
    complete_time    DATETIME        COMMENT '完成时间',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_course_id (course_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    UNIQUE KEY uk_course_employee (course_id, employee_id, is_deleted) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='在线学习进度表';

-- 培训效果报告表
DROP TABLE IF EXISTS t_training_effect_report;
CREATE TABLE t_training_effect_report (
    id               BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    activity_id      BIGINT          NOT NULL COMMENT '关联培训活动ID',
    report_title     VARCHAR(256)    NOT NULL COMMENT '报告标题',
    total_enrolled   INT             DEFAULT 0 COMMENT '总报名人数',
    total_completed  INT             DEFAULT 0 COMMENT '完成培训人数',
    completion_rate  DECIMAL(5,2)    DEFAULT 0 COMMENT '完成率（%）',
    avg_exam_score   DECIMAL(5,2)    COMMENT '平均考核分',
    avg_satisfaction DECIMAL(3,1)    COMMENT '平均满意度（1~5）',
    pass_rate        DECIMAL(5,2)    COMMENT '通过率（%）',
    pass_threshold   INT             COMMENT '及格线分数',
    summary          TEXT            COMMENT '综合总结',
    suggestions      TEXT            COMMENT '改进建议',
    data_detail      TEXT            COMMENT '详细统计数据（JSON）',
    status           TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0草稿/1已发布）',
    create_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted       TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_activity_id (activity_id) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='培训效果报告表';

-- ====================================================
-- 8. 福利管理模块
-- ====================================================

-- 福利项目表
DROP TABLE IF EXISTS t_welfare_item;
CREATE TABLE t_welfare_item (
    id          BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    item_name   VARCHAR(64)     NOT NULL COMMENT '福利名称',
    item_code   VARCHAR(32)     NOT NULL COMMENT '福利编码',
    item_type   VARCHAR(32)     NOT NULL COMMENT '福利类型（CASH现金/GIFT实物/INSURANCE保险/OTHER其他）',
    amount      DECIMAL(12,2)   COMMENT '金额/价值',
    frequency   VARCHAR(32)     COMMENT '发放频率（MONTHLY/QUARTERLY/ANNUALLY/ONCE）',
    applicable_to VARCHAR(512)  COMMENT '适用对象（全员/部门/岗位）',
    status      TINYINT         NOT NULL DEFAULT 1 COMMENT '状态（1启用/0停用）',
    description VARCHAR(512)    COMMENT '描述',
    create_time DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted  TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_item_code (item_code) USING BTREE,
    KEY idx_item_type (item_type) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='福利项目表';

-- 福利发放记录表
DROP TABLE IF EXISTS t_welfare_record;
CREATE TABLE t_welfare_record (
    id              BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    item_id         BIGINT          NOT NULL COMMENT '福利项目ID',
    employee_id     BIGINT          NOT NULL COMMENT '员工ID',
    grant_month     VARCHAR(7)      COMMENT '发放月份（yyyy-MM）',
    grant_date      DATE            COMMENT '发放日期',
    actual_amount   DECIMAL(12,2)   COMMENT '实际发放金额',
    status          TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0待发放/1已发放/2已取消）',
    remark          VARCHAR(512)    COMMENT '备注',
    create_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_item_id (item_id) USING BTREE,
    KEY idx_grant_month (grant_month) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='福利发放记录表';

-- ====================================================
-- 9. 社保公积金管理模块
-- ====================================================

-- 社保公积金账户表
DROP TABLE IF EXISTS t_social_security;
CREATE TABLE t_social_security (
    id                      BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id             BIGINT          NOT NULL COMMENT '员工ID',
    social_security_no      VARCHAR(64)     COMMENT '社保账号',
    housing_fund_no         VARCHAR(64)     COMMENT '公积金账号',
    city                    VARCHAR(64)     COMMENT '缴纳城市',
    start_month             VARCHAR(7)      COMMENT '开始缴纳月份（yyyy-MM）',
    end_month               VARCHAR(7)      COMMENT '停保月份（yyyy-MM）',
    social_base             DECIMAL(12,2)   COMMENT '社保缴纳基数',
    fund_base               DECIMAL(12,2)   COMMENT '公积金缴纳基数',
    personal_social_rate    DECIMAL(6,4)    COMMENT '个人社保比例（%）',
    company_social_rate     DECIMAL(6,4)    COMMENT '企业社保比例（%）',
    personal_fund_rate      DECIMAL(6,4)    COMMENT '个人公积金比例（%）',
    company_fund_rate       DECIMAL(6,4)    COMMENT '企业公积金比例（%）',
    status                  TINYINT         NOT NULL DEFAULT 1 COMMENT '状态（1正常/0停保）',
    remark                  VARCHAR(512)    COMMENT '备注',
    create_time             DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time             DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted              TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_id (employee_id) USING BTREE,
    KEY idx_city (city) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社保公积金账户表';

-- 社保公积金月度缴纳记录
DROP TABLE IF EXISTS t_social_security_record;
CREATE TABLE t_social_security_record (
    id              BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    employee_id     BIGINT          NOT NULL COMMENT '员工ID',
    pay_month       VARCHAR(7)      NOT NULL COMMENT '缴纳月份（yyyy-MM）',
    social_base     DECIMAL(12,2)   COMMENT '社保缴纳基数',
    personal_social DECIMAL(12,2)   COMMENT '个人社保金额',
    company_social  DECIMAL(12,2)   COMMENT '企业社保金额',
    fund_base       DECIMAL(12,2)   COMMENT '公积金缴纳基数',
    personal_fund   DECIMAL(12,2)   COMMENT '个人公积金金额',
    company_fund    DECIMAL(12,2)   COMMENT '企业公积金金额',
    total_personal  DECIMAL(12,2)   GENERATED ALWAYS AS (personal_social + personal_fund) STORED COMMENT '个人缴纳合计（自动计算，MyBatis 禁止写入）',
    total_company   DECIMAL(12,2)   GENERATED ALWAYS AS (company_social + company_fund) STORED COMMENT '企业缴纳合计（自动计算，MyBatis 禁止写入）',
    status          TINYINT         NOT NULL DEFAULT 0 COMMENT '申报状态（0未申报/1已申报/2已缴纳）',
    remark          VARCHAR(512)    COMMENT '备注',
    create_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_employee_pay (employee_id, pay_month) USING BTREE,
    KEY idx_pay_month (pay_month) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社保公积金月度缴纳记录';

-- ====================================================
-- 10. BPM工作流模块
-- ====================================================

-- 审批流程模板表
DROP TABLE IF EXISTS t_approval_template;
CREATE TABLE t_approval_template (
    id            BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    process_name  VARCHAR(100) NOT NULL COMMENT '流程名称',
    business_type VARCHAR(50)  NOT NULL COMMENT '业务类型：LEAVE/OVERTIME/TRANSFER/SALARY_ADJUST/CUSTOM',
    description   VARCHAR(500) COMMENT '流程描述',
    node_order    INT          NOT NULL DEFAULT 1 COMMENT '节点序号（从1开始，升序执行）',
    node_name     VARCHAR(100) NOT NULL COMMENT '节点名称',
    approver_role VARCHAR(100) COMMENT '审批人角色编码',
    approver_type TINYINT      NOT NULL DEFAULT 0 COMMENT '审批人类型（0角色/1指定用户/2上级/3部门负责人）',
    approver_ids  VARCHAR(500) COMMENT '指定审批人ID列表（逗号分隔）',
    action_type   VARCHAR(50)  NOT NULL DEFAULT 'APPROVE_REJECT' COMMENT '操作类型：APPROVE_REJECT=审批通过/驳回 NOTIFY=仅通知',
    enabled       TINYINT      NOT NULL DEFAULT 1 COMMENT '是否启用（0禁用/1启用）',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted    TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_business_type (business_type, node_order) USING BTREE,
    KEY idx_enabled (enabled) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审批流程模板';

-- 审批流程实例表
DROP TABLE IF EXISTS t_approval_instance;
CREATE TABLE t_approval_instance (
    id                BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    process_name      VARCHAR(100) NOT NULL COMMENT '流程名称',
    business_type     VARCHAR(50)  NOT NULL COMMENT '业务类型',
    business_id       BIGINT       NOT NULL DEFAULT 0 COMMENT '业务单据ID',
    business_title    VARCHAR(200) NOT NULL DEFAULT '' COMMENT '业务摘要',
    initiator_id      BIGINT       NOT NULL COMMENT '发起人员工ID',
    initiator_name    VARCHAR(50)  NOT NULL DEFAULT '' COMMENT '发起人姓名',
    current_node_order INT         NOT NULL DEFAULT 1 COMMENT '当前节点序号',
    current_node_name VARCHAR(100) NOT NULL DEFAULT '' COMMENT '当前节点名称',
    process_status    TINYINT      NOT NULL DEFAULT 0 COMMENT '流程状态（0审批中/1已通过/2已拒绝/3已撤回/4已取消）',
    finish_time       DATETIME     COMMENT '完成时间',
    final_comment     VARCHAR(500) COMMENT '最终审批意见',
    create_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted        TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_business (business_type, business_id) USING BTREE,
    KEY idx_initiator_id (initiator_id) USING BTREE,
    KEY idx_process_status (process_status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审批流程实例';

-- 审批节点执行记录表
DROP TABLE IF EXISTS t_approval_node_record;
CREATE TABLE t_approval_node_record (
    id            BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    instance_id   BIGINT       NOT NULL COMMENT '所属流程实例ID',
    node_order    INT          NOT NULL COMMENT '节点序号',
    node_name     VARCHAR(100) NOT NULL DEFAULT '' COMMENT '节点名称',
    approver_role VARCHAR(50)  NOT NULL DEFAULT '' COMMENT '审批人角色',
    approver_id   BIGINT       COMMENT '实际审批人ID',
    approver_name VARCHAR(50)  COMMENT '实际审批人姓名',
    node_status   TINYINT      NOT NULL DEFAULT 0 COMMENT '节点状态（0待审批/1已通过/2已拒绝/3跳过/4已撤回）',
    approve_time  DATETIME     COMMENT '审批时间',
    comment       VARCHAR(500) COMMENT '审批意见',
    action_type   VARCHAR(30)  NOT NULL DEFAULT 'APPROVE_REJECT' COMMENT '操作类型',
    create_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted    TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_instance_id (instance_id) USING BTREE,
    KEY idx_node_status (node_status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='审批节点执行记录';

-- ====================================================
-- 11. 人才发展模块
-- ====================================================

-- 继任者计划表
DROP TABLE IF EXISTS t_succession_plan;
CREATE TABLE t_succession_plan (
    id                    BIGINT       NOT NULL COMMENT '主键ID（雪花算法）',
    target_position_id    BIGINT       NOT NULL COMMENT '目标岗位ID',
    target_position_name  VARCHAR(100) NOT NULL COMMENT '目标岗位名称（冗余）',
    successor_id          BIGINT       NOT NULL COMMENT '继任者员工ID',
    successor_name        VARCHAR(50)  NOT NULL COMMENT '继任者姓名（冗余）',
    successor_code        VARCHAR(30)  COMMENT '继任者工号（冗余）',
    current_holder_id     BIGINT       COMMENT '当前岗位持有者员工ID',
    current_holder_name   VARCHAR(50)  COMMENT '当前岗位持有者姓名（冗余）',
    readiness             VARCHAR(10)  NOT NULL DEFAULT 'LOW' COMMENT '继任准备度：HIGH/MEDIUM/LOW',
    expected_date         DATE         COMMENT '预计继任日期',
    development_plan      TEXT         COMMENT '发展计划/备注',
    status                TINYINT      NOT NULL DEFAULT 0 COMMENT '状态：0=规划中/1=培养中/2=已就绪/3=已终止',
    create_time           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted            TINYINT      NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_target_position_id (target_position_id) USING BTREE,
    KEY idx_successor_id (successor_id) USING BTREE,
    KEY idx_status (status) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='继任者计划表';

-- ====================================================
-- 12. 调查问卷模块
-- ====================================================

-- 员工调查问卷表
DROP TABLE IF EXISTS t_survey;
CREATE TABLE t_survey (
    id              BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    title           VARCHAR(128)    NOT NULL COMMENT '问卷标题',
    description     VARCHAR(512)    COMMENT '问卷描述',
    survey_type     VARCHAR(32)     NOT NULL DEFAULT 'SATISFACTION' COMMENT '问卷类型（SATISFACTION满意度/ENGAGEMENT敬业度/CULTURE文化/OPINION意见）',
    questions       LONGTEXT        COMMENT '问卷题目（JSON格式）',
    start_date      DATE            COMMENT '开始日期',
    end_date        DATE            COMMENT '结束日期',
    anonymous       TINYINT         NOT NULL DEFAULT 0 COMMENT '是否匿名（0否/1是）',
    target_scope    VARCHAR(32)     NOT NULL DEFAULT 'ALL' COMMENT '目标范围（ALL/DEPT/ROLE）',
    target_ids      VARCHAR(512)    COMMENT '目标ID列表',
    status          TINYINT         NOT NULL DEFAULT 0 COMMENT '状态（0草稿/1进行中/2已结束/3已归档）',
    creator_id      BIGINT          COMMENT '创建人ID',
    creator_name    VARCHAR(64)     COMMENT '创建人姓名',
    create_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_survey_type (survey_type) USING BTREE,
    KEY idx_status (status) USING BTREE,
    KEY idx_date_range (start_date, end_date) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='员工调查问卷表';

-- 问卷答卷表
DROP TABLE IF EXISTS t_survey_answer;
CREATE TABLE t_survey_answer (
    id              BIGINT          NOT NULL COMMENT '主键ID（雪花算法）',
    survey_id       BIGINT          NOT NULL COMMENT '问卷ID',
    employee_id     BIGINT          NOT NULL COMMENT '填写人员工ID',
    answers         LONGTEXT        COMMENT '答案（JSON格式）',
    submit_time     DATETIME        COMMENT '提交时间',
    ip_address      VARCHAR(64)     COMMENT '提交IP',
    duration_seconds INT            COMMENT '填写时长（秒）',
    create_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted      TINYINT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_survey_id (survey_id) USING BTREE,
    KEY idx_employee_id (employee_id) USING BTREE,
    UNIQUE KEY uk_survey_employee (survey_id, employee_id, is_deleted) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='问卷答卷表';

-- ====================================================
-- 完成提示
-- ====================================================
SELECT CONCAT('HRM 系统完整建表脚本 v2.0.0 执行完成，共创建 ', COUNT(*), ' 张表') AS result
FROM information_schema.tables
WHERE table_schema = 'hrm_db';