# 福利管理模块

## 功能概述
福利管理模块包含两个主要功能：
1. **福利项目管理** - 管理福利项目的基本信息
2. **福利发放记录管理** - 管理福利的发放记录

## 路由地址
- `/admin/salary/welfare` - 福利管理主页面

## 后端API接口
### 福利项目管理
- `GET /api/salary/welfare/item/page` - 分页查询福利项目
- `GET /api/salary/welfare/item/list` - 查询所有启用的福利项目
- `POST /api/salary/welfare/item` - 新增福利项目
- `PUT /api/salary/welfare/item` - 更新福利项目
- `DELETE /api/salary/welfare/item/{id}` - 删除福利项目

### 福利发放记录管理
- `GET /api/salary/welfare/record/page` - 分页查询发放记录
- `POST /api/salary/welfare/record` - 新增发放记录（支持批量）
- `PUT /api/salary/welfare/record` - 更新发放记录
- `DELETE /api/salary/welfare/record/{id}` - 删除发放记录

## 页面功能
### 1. 福利项目管理
- 分页查询福利项目
- 支持按关键字和状态筛选
- 新增、编辑、删除福利项目
- 福利项目字段：
  - 福利编码（唯一）
  - 福利名称
  - 福利类型（补贴/实物/保险/其他）
  - 金额
  - 发放周期（每月/每季度/每年/不定期）
  - 状态（启用/停用）
  - 描述

### 2. 福利发放记录管理
- 分页查询发放记录
- 支持按员工、福利项目、发放月份、状态筛选
- 新增、编辑、删除发放记录
- 支持单个员工和批量员工发放
- 发放记录字段：
  - 福利项目
  - 员工（单个或多个）
  - 发放月份（yyyy-MM）
  - 发放日期
  - 发放金额
  - 状态（待发放/已发放）
  - 备注

## 组件说明
### EmployeeMultiSelect.vue
支持多选的员工选择器组件，用于批量发放福利时选择多个员工。

### WelfareManagement.vue
福利管理主页面，包含两个标签页：
- 福利项目管理
- 福利发放记录管理

## 数据模型
### WelfareItem（福利项目）
```typescript
interface WelfareItem {
  id?: number
  itemCode?: string      // 福利编码（唯一）
  name?: string          // 福利名称
  welfareType?: string   // 福利类型：SUBSIDY/GOODS/INSURANCE/OTHER
  amount?: number        // 金额
  cycle?: string         // 发放周期：MONTHLY/QUARTERLY/YEARLY/IRREGULAR
  status?: number        // 状态：1启用/0停用
  description?: string   // 描述
  createTime?: string    // 创建时间
}
```

### WelfareRecord（福利发放记录）
```typescript
interface WelfareRecord {
  id?: number
  itemId?: number        // 福利项目ID
  itemName?: string      // 福利项目名称
  employeeId?: number    // 员工ID（单个）
  employeeName?: string  // 员工姓名
  employeeIds?: number[] // 员工ID数组（批量）
  grantMonth?: string    // 发放月份（yyyy-MM）
  grantDate?: string     // 发放日期
  amount?: number        // 发放金额
  status?: number        // 状态：0待发放/1已发放
  remark?: string        // 备注
  createTime?: string    // 创建时间
}
```

## 使用说明
1. 首先在"福利项目"标签页中创建福利项目
2. 然后在"发放记录"标签页中为员工发放福利
3. 支持单个员工发放和批量员工发放
4. 发放后可以标记为"已发放"状态

## 注意事项
1. 福利编码必须唯一
2. 批量发放时，所有选中的员工将获得相同的福利金额
3. 已停用的福利项目不会出现在发放记录的选择列表中
4. 发放记录的状态可以随时更新