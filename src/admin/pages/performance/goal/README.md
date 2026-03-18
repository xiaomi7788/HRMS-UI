# 绩效目标管理页面

## 功能概述
绩效目标管理页面提供了完整的OKR（目标与关键成果）管理系统，支持列表视图和树形视图两种展示方式。

## 路由地址
- `/admin/performance/goal`

## 主要功能

### 1. 视图切换
- **列表视图**：表格形式展示目标，支持分页、排序和筛选
- **OKR树形视图**：树形结构展示目标层级关系，直观显示目标对齐关系

### 2. 数据管理
- **新增目标**：创建新的绩效目标
- **编辑目标**：修改已有目标信息
- **删除目标**：删除不再需要的目标
- **更新进度**：实时更新目标完成进度
- **目标对齐**：将个人目标与上级或公司级目标对齐

### 3. 筛选查询
- 按绩效方案筛选
- 按员工筛选（支持远程搜索）
- 按考核周期筛选（Q1-Q4、H1-H2、年度）
- 按目标类型筛选（公司级、部门级、个人级）
- **我的目标**：快速查看当前登录用户的目标

### 4. 数据展示
- 目标标题、类型、优先级
- 权重、目标值、实际值
- 进度百分比（可视化进度条）
- 考核周期、起止日期
- 对齐目标信息
- 状态标签（未开始、进行中、已完成、已延期）

## API接口对应

页面调用的API接口与后端完全对应：

| 功能 | 接口 | 方法 |
|------|------|------|
| 分页查询 | `/api/performance/objective/page` | GET |
| 获取树形数据 | `/api/performance/objective/tree` | GET |
| 获取详情 | `/api/performance/objective/{id}` | GET |
| 新建目标 | `/api/performance/objective` | POST |
| 更新目标 | `/api/performance/objective` | PUT |
| 更新进度 | `/api/performance/objective/{id}/progress` | PUT |
| 目标对齐 | `/api/performance/objective/{id}/align` | PUT |
| 删除目标 | `/api/performance/objective/{id}` | DELETE |
| 我的目标 | `/api/performance/objective/my` | GET |
| 可对齐目标 | `/api/performance/objective/align-candidates` | GET |

## 技术实现

### 前端技术栈
- Vue 3 + TypeScript
- Element Plus UI组件库
- Composition API

### 主要组件
- `el-table`：数据表格展示
- `el-tree`：树形结构展示
- `el-dialog`：表单对话框
- `el-form`：表单验证
- `el-select`：下拉选择
- `el-progress`：进度条显示

### 状态管理
- 使用Vue 3的ref和reactive进行响应式状态管理
- 表单验证使用Element Plus的Form Rules

## 使用说明

1. **访问页面**：通过左侧菜单或直接访问 `/admin/performance/goal`
2. **切换视图**：使用顶部的标签页切换列表视图和树形视图
3. **查询数据**：使用筛选条件查询特定目标
4. **管理目标**：通过操作列的按钮进行增删改查
5. **更新进度**：点击"更新进度"按钮实时更新目标完成情况
6. **目标对齐**：点击"对齐"按钮将目标与上级目标关联

## 注意事项

1. 员工搜索功能需要后端支持远程搜索
2. 目标对齐功能需要先加载可对齐的目标列表
3. 树形视图的性能取决于数据量，大量数据时建议使用列表视图
4. 所有操作都有确认提示，防止误操作