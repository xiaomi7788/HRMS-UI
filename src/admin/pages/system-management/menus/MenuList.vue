<template>
  <div class="menu-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>菜单管理</span>
        </div>
      </template>

      <div class="toolbar-section">
        <el-button type="primary" @click="handleAdd()">新增根菜单</el-button>
        <el-button type="success" @click="handleExpandAll()">展开/收起</el-button>
      </div>

      <el-table
        ref="menuTableRef"
        :data="menuTableData"
        style="width: 100%; margin-top: 20px;"
        border
        row-key="id"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        default-expand-all
      >
        <el-table-column prop="menuName" label="菜单名称" width="200" />
        <el-table-column prop="icon" label="图标" width="100" align="center">
          <template #default="{ row }">
            <el-icon v-if="row.icon">
              <component :is="row.icon" />
            </el-icon>
          </template>
        </el-table-column>
        <el-table-column prop="menuType" label="类型" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getMenuTypeTag(row.menuType)" size="small">
              {{ getMenuTypeLabel(row.menuType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="perms" label="权限标识" width="180" />
        <el-table-column prop="path" label="路由路径" width="200" />
        <el-table-column prop="component" label="组件路径" width="200" />
        <el-table-column prop="sort" label="排序" width="80" align="center" />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '显示' : '隐藏' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.menuType !== 2" size="small" @click="handleAdd(row)">新增子菜单</el-button>
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑菜单对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      :before-close="handleCloseDialog"
    >
      <el-form
        ref="menuFormRef"
        :model="currentMenu"
        :rules="menuRules"
        label-width="100px"
      >
        <el-form-item label="父菜单" prop="parentId" v-if="!isRoot">
          <el-tree-select
            v-model="currentMenu.parentId"
            :data="parentMenuOptions"
            :props="{ label: 'menuName', value: 'id', children: 'children' }"
            placeholder="请选择父菜单"
            clearable
            check-strictly
          />
        </el-form-item>
        <el-form-item label="菜单名称" prop="menuName">
          <el-input v-model="currentMenu.menuName" placeholder="请输入菜单名称" />
        </el-form-item>
        <el-form-item label="菜单类型" prop="menuType">
          <el-radio-group v-model="currentMenu.menuType">
            <el-radio :value="0">目录</el-radio>
            <el-radio :value="1">菜单</el-radio>
            <el-radio :value="2">按钮</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="图标" prop="icon">
          <el-input v-model="currentMenu.icon" placeholder="请输入图标名称（如：Setting）" />
        </el-form-item>
        <el-form-item label="权限标识" prop="perms" v-if="currentMenu.menuType !== 0">
          <el-input v-model="currentMenu.perms" placeholder="请输入权限标识（如：sys:user:add）" />
        </el-form-item>
        <el-form-item label="路由路径" prop="path" v-if="currentMenu.menuType !== 2">
          <el-input v-model="currentMenu.path" placeholder="请输入路由路径（如：/sys/user）" />
        </el-form-item>
        <el-form-item label="组件路径" prop="component" v-if="currentMenu.menuType === 1">
          <el-input v-model="currentMenu.component" placeholder="请输入组件路径（如：system/User）" />
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="currentMenu.sort" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="currentMenu.status">
            <el-radio :value="1">显示</el-radio>
            <el-radio :value="0">隐藏</el-radio>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getMenuTree,
  createMenu,
  updateMenu,
  deleteMenu,
  type SysMenu
} from '@/api/menu'

const menuTableRef = ref()
const menuTableData = ref<SysMenu[]>([])
const isExpandAll = ref(true)

const dialogVisible = ref(false)
const dialogTitle = ref('')
const isRoot = ref(false)
const currentMenu = reactive<SysMenu>({
  parentId: 0,
  menuName: '',
  perms: '',
  menuType: 1,
  path: '',
  component: '',
  icon: '',
  sort: 0,
  status: 1
})

const menuFormRef = ref<FormInstance>()
const parentMenuOptions = ref<SysMenu[]>([])

const menuRules: FormRules = {
  menuName: [
    { required: true, message: '请输入菜单名称', trigger: 'blur' }
  ],
  menuType: [
    { required: true, message: '请选择菜单类型', trigger: 'change' }
  ],
  path: [
    { required: true, message: '请输入路由路径', trigger: 'blur' }
  ],
  component: [
    { required: true, message: '请输入组件路径', trigger: 'blur' }
  ]
}

const getMenuTypeLabel = (type: number) => {
  const map: Record<number, string> = {
    0: '目录',
    1: '菜单',
    2: '按钮'
  }
  return map[type] || ''
}

const getMenuTypeTag = (type: number) => {
  const map: Record<number, string> = {
    0: '',
    1: 'success',
    2: 'warning'
  }
  return map[type] || ''
}

const loadMenuTree = async () => {
  try {
    const menus = await getMenuTree()
    menuTableData.value = buildMenuTree(menus)
    parentMenuOptions.value = buildParentMenuOptions(menus)
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

// 构建父菜单选项（排除按钮类型）
const buildParentMenuOptions = (menus: SysMenu[]) => {
  const validMenus = menus.filter(m => m.menuType !== 2)
  const map = new Map<number, SysMenu & { children: SysMenu[] }>()
  const menuWithChildren = validMenus.map(menu => ({ ...menu, children: [] as SysMenu[] }))

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

const handleAdd = (row?: SysMenu) => {
  dialogTitle.value = row ? '新增子菜单' : '新增根菜单'
  isRoot.value = !row
  Object.assign(currentMenu, {
    parentId: row?.id || 0,
    menuName: '',
    perms: '',
    menuType: 1,
    path: '',
    component: '',
    icon: '',
    sort: 0,
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: SysMenu) => {
  dialogTitle.value = '编辑菜单'
  isRoot.value = row.parentId === 0
  Object.assign(currentMenu, {
    id: row.id,
    parentId: row.parentId,
    menuName: row.menuName,
    perms: row.perms,
    menuType: row.menuType,
    path: row.path,
    component: row.component,
    icon: row.icon,
    sort: row.sort,
    status: row.status
  })
  dialogVisible.value = true
}

const handleSave = async () => {
  if (!menuFormRef.value) return
  await menuFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (currentMenu.id) {
          await updateMenu(currentMenu)
          ElMessage.success('更新菜单成功')
        } else {
          await createMenu(currentMenu)
          ElMessage.success('新增菜单成功')
        }
        dialogVisible.value = false
        loadMenuTree()
      } catch (error) {
        console.error('保存菜单失败:', error)
      }
    }
  })
}

const handleCloseDialog = () => {
  dialogVisible.value = false
  menuFormRef.value?.resetFields()
}

const handleDelete = (row: SysMenu) => {
  ElMessageBox.confirm(`确定要删除菜单 "${row.menuName}" 吗?`, '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteMenu(row.id!)
      ElMessage.success('删除成功')
      loadMenuTree()
    } catch (error) {
      console.error('删除菜单失败:', error)
    }
  }).catch(() => {})
}

const handleExpandAll = () => {
  isExpandAll.value = !isExpandAll.value
  const rows = menuTableRef.value?.store.states.data.value || []
  rows.forEach((row: any) => {
    menuTableRef.value?.toggleRowExpansion(row, isExpandAll.value)
  })
}

onMounted(() => {
  loadMenuTree()
})
</script>

<style scoped>
.menu-list-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.toolbar-section {
  display: flex;
  gap: 10px;
}
</style>
