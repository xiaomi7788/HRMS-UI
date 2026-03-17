<template>
  <div class="role-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>角色管理</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="keyword"
          placeholder="搜索角色名称"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="loadRoleList"
          @keyup.enter="loadRoleList"
        />
        <el-button type="primary" @click="loadRoleList">查询</el-button>
        <el-button type="success" @click="handleAdd">新增角色</el-button>
      </div>

      <el-table :data="roleList" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="roleName" label="角色名称" width="150" />
        <el-table-column prop="roleCode" label="角色编码" width="150" />
        <el-table-column label="数据权限范围" width="150">
          <template #default="{ row }">
            {{ getDataScopeText(row.dataScope) }}
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" @click="handleAssignMenus(row)">分配菜单</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="total > 0" style="display: flex; justify-content: flex-end; margin-top: 20px;">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          background
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @current-change="loadRoleList"
          @size-change="loadRoleList"
        />
      </div>
    </el-card>

    <!-- 新增/编辑角色对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      :before-close="handleCloseDialog"
    >
      <el-form
        ref="roleFormRef"
        :model="currentRole"
        :rules="roleRules"
        label-width="120px"
      >
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="currentRole.roleName" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="角色编码" prop="roleCode">
          <el-select
            v-if="currentRole.id"
            v-model="currentRole.roleCode"
            placeholder="请选择角色编码"
          >
            <el-option value="ADMIN" label="ADMIN" />
            <el-option value="HR" label="HR" />
            <el-option value="MANAGER" label="MANAGER" />
            <el-option value="EMPLOYEE" label="EMPLOYEE" />
            <el-option value="FINANCE" label="FINANCE" />
          </el-select>
          <el-select
            v-else
            v-model="currentRole.roleCode"
            placeholder="请选择或输入角色编码"
            filterable
            allow-create
          >
            <el-option value="ADMIN" label="ADMIN" />
            <el-option value="HR" label="HR" />
            <el-option value="MANAGER" label="MANAGER" />
            <el-option value="EMPLOYEE" label="EMPLOYEE" />
            <el-option value="FINANCE" label="FINANCE" />
          </el-select>
        </el-form-item>
        <el-form-item label="数据权限范围" prop="dataScope">
          <el-select v-model="currentRole.dataScope" placeholder="请选择数据权限范围">
            <el-option :value="1" label="全部数据" />
            <el-option :value="2" label="本部门及以下" />
            <el-option :value="3" label="本部门" />
            <el-option :value="4" label="仅本人" />
            <el-option :value="5" label="自定义" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="currentRole.description" type="textarea" placeholder="请输入描述" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="currentRole.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button type="primary" @click="handleSave">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 分配菜单对话框 -->
    <el-dialog
      v-model="menuDialogVisible"
      title="分配菜单"
      width="600px"
      :before-close="handleCloseMenuDialog"
    >
      <el-tabs v-model="activeMenuTab">
        <el-tab-pane label="管理端菜单" name="admin">
          <el-tree
            ref="adminMenuTreeRef"
            :data="adminMenuTree"
            show-checkbox
            node-key="id"
            :props="{ label: 'menuName', children: 'children' }"
            default-expand-all
          />
        </el-tab-pane>
        <el-tab-pane label="用户端菜单" name="user">
          <el-tree
            ref="userMenuTreeRef"
            :data="userMenuTree"
            show-checkbox
            node-key="id"
            :props="{ label: 'menuName', children: 'children' }"
            default-expand-all
          />
        </el-tab-pane>
      </el-tabs>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleCloseMenuDialog">取消</el-button>
          <el-button type="primary" @click="handleSaveMenus">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getRolePage,
  createRole,
  updateRole,
  deleteRole,
  getRoleMenus,
  assignRoleMenus,
  type SysRole,
  type PageResult
} from '@/api/role'
import { getMenuList, type SysMenu } from '@/api/menu'

const roleList = ref<SysRole[]>([])
const keyword = ref('')
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const dialogVisible = ref(false)
const dialogTitle = ref('')
const currentRole = reactive<SysRole>({
  roleName: '',
  roleCode: '',
  dataScope: 1,
  description: '',
  status: 1
})

const roleFormRef = ref<FormInstance>()
const roleRules: FormRules = {
  roleName: [
    { required: true, message: '请输入角色名称', trigger: 'blur' }
  ],
  roleCode: [
    { required: true, message: '请输入角色编码', trigger: 'blur' }
  ],
  dataScope: [
    { required: true, message: '请选择数据权限范围', trigger: 'change' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

const menuDialogVisible = ref(false)
const activeMenuTab = ref('admin')
const adminMenuTreeRef = ref()
const userMenuTreeRef = ref()
const adminMenuTree = ref<any[]>([])
const userMenuTree = ref<any[]>([])
const currentRoleId = ref<number>(0)

const dataScopeOptions: Record<number, string> = {
  1: '全部数据',
  2: '本部门及以下',
  3: '本部门',
  4: '仅本人',
  5: '自定义'
}

const getDataScopeText = (scope?: number) => {
  return scope !== undefined ? dataScopeOptions[scope] || '-' : '-'
}

const loadRoleList = async () => {
  try {
    const res: PageResult<SysRole> = await getRolePage({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: keyword.value || undefined
    })
    roleList.value = res.records || []
    total.value = Number(res.total || 0)
  } catch (error) {
    console.error('加载角色列表失败:', error)
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增角色'
  Object.assign(currentRole, {
    roleName: '',
    roleCode: '',
    dataScope: 1,
    description: '',
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: SysRole) => {
  dialogTitle.value = '编辑角色'
  Object.assign(currentRole, {
    id: row.id,
    roleName: row.roleName,
    roleCode: row.roleCode,
    dataScope: row.dataScope,
    description: row.description,
    status: row.status
  })
  dialogVisible.value = true
}

const handleSave = async () => {
  if (!roleFormRef.value) return
  await roleFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (currentRole.id) {
          await updateRole(currentRole)
          ElMessage.success('更新角色成功')
        } else {
          await createRole(currentRole)
          ElMessage.success('新增角色成功')
        }
        dialogVisible.value = false
        loadRoleList()
      } catch (error) {
        console.error('保存角色失败:', error)
      }
    }
  })
}

const handleCloseDialog = () => {
  dialogVisible.value = false
  roleFormRef.value?.resetFields()
}

const handleDelete = (row: SysRole) => {
  ElMessageBox.confirm(`确定要删除角色 "${row.roleName}" 吗?`, '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteRole(row.id!)
      ElMessage.success('删除成功')
      loadRoleList()
    } catch (error) {
      console.error('删除角色失败:', error)
    }
  }).catch(() => {})
}

const handleAssignMenus = async (row: SysRole) => {
  currentRoleId.value = row.id!
  activeMenuTab.value = 'admin'
  try {
    const menuIds = await getRoleMenus(row.id!)
    await loadMenuTrees(menuIds)
    menuDialogVisible.value = true
  } catch (error) {
    console.error('获取角色菜单失败:', error)
  }
}

const loadMenuTrees = async (checkedIds: number[] = []) => {
  try {
    const allMenus = await getMenuList()

    // 区分管理端菜单（ID 1-99）和用户端菜单（ID 100+）
    const adminMenus = allMenus.filter((m: SysMenu) => m.id < 100)
    const userMenus = allMenus.filter((m: SysMenu) => m.id >= 100)

    adminMenuTree.value = buildMenuTree(adminMenus)
    userMenuTree.value = buildMenuTree(userMenus)

    // 延迟设置选中的菜单
    setTimeout(() => {
      const adminChecked = checkedIds.filter(id => id < 100)
      const userChecked = checkedIds.filter(id => id >= 100)

      if (adminMenuTreeRef.value) {
        adminMenuTreeRef.value.setCheckedKeys(adminChecked)
      }
      if (userMenuTreeRef.value) {
        userMenuTreeRef.value.setCheckedKeys(userChecked)
      }
    }, 100)
  } catch (error) {
    console.error('加载菜单树失败:', error)
  }
}

// 构建菜单树
const buildMenuTree = (menus: SysMenu[]) => {
  const map = new Map<number, SysMenu & { children: SysMenu[] }>()
  const menuWithChildren = menus.map(menu => ({ ...menu, children: [] as SysMenu[] }))

  menuWithChildren.forEach(menu => {
    map.set(menu.id, menu)
  })

  const tree: SysMenu[] = []
  menuWithChildren.forEach(menu => {
    if (menu.parentId === 0 || !map.has(menu.parentId)) {
      tree.push(menu)
    } else {
      const parent = map.get(menu.parentId)
      if (parent) {
        parent.children.push(menu)
      }
    }
  })

  return tree
}

const handleSaveMenus = async () => {
  const adminChecked = adminMenuTreeRef.value?.getCheckedKeys() || []
  const adminHalfChecked = adminMenuTreeRef.value?.getHalfCheckedKeys() || []
  const userChecked = userMenuTreeRef.value?.getCheckedKeys() || []
  const userHalfChecked = userMenuTreeRef.value?.getHalfCheckedKeys() || []

  const allCheckedKeys = [
    ...adminChecked,
    ...adminHalfChecked,
    ...userChecked,
    ...userHalfChecked
  ]

  try {
    await assignRoleMenus(currentRoleId.value, allCheckedKeys as number[])
    ElMessage.success('分配菜单成功')
    menuDialogVisible.value = false
  } catch (error) {
    console.error('分配菜单失败:', error)
  }
}

const handleCloseMenuDialog = () => {
  menuDialogVisible.value = false
}

onMounted(() => {
  loadRoleList()
})
</script>

<style scoped>
.role-list-container {
  padding: 20px;
}
.card-header {
  font-size: 18px;
  font-weight: bold;
}
.search-filter-section {
  display: flex;
  align-items: center;
}
</style>
