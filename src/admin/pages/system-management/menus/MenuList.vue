<template>
  <div class="menu-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>菜单管理</span>
        </div>
      </template>

      <div class="action-section">
        <el-button type="success" @click="addMenu">新增菜单</el-button>
      </div>

      <el-table
        :data="menuData"
        style="width: 100%; margin-top: 20px;"
        row-key="id"
        border
        default-expand-all
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
      >
        <el-table-column prop="name" label="菜单名称" />
        <el-table-column prop="path" label="路由路径" />
        <el-table-column prop="component" label="组件路径" />
        <el-table-column prop="permission" label="权限标识" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="addChildrenMenu(scope.row.id)">新增子菜单</el-button>
            <el-button size="small" @click="editMenu(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteMenu(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑菜单的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEditingMenu" label-width="100px">
        <el-form-item label="菜单名称">
          <el-input v-model="currentEditingMenu.name"></el-input>
        </el-form-item>
        <el-form-item label="路由路径">
          <el-input v-model="currentEditingMenu.path"></el-input>
        </el-form-item>
        <el-form-item label="组件路径">
          <el-input v-model="currentEditingMenu.component"></el-input>
        </el-form-item>
        <el-form-item label="权限标识">
          <el-input v-model="currentEditingMenu.permission"></el-input>
        </el-form-item>
        <el-form-item v-if="!isEditing" label="父级菜单">
          <el-tree-select
            v-model="parentMenuId"
            :data="menuData"
            :props="{ label: 'name', value: 'id', children: 'children' }"
            check-strictly
            clearable
            placeholder="选择父级菜单 (可选)"
            style="width: 100%;"
            popper-append-to-body
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button type="primary" @click="handleSubmit">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface MenuItem {
  id: number;
  name: string;
  path: string;
  component?: string;
  permission?: string;
  children?: MenuItem[];
}

const menuData = ref<MenuItem[]>([
  {
    id: 1,
    name: '系统管理',
    path: '/admin/system-management',
    children: [
      {
        id: 11,
        name: '用户管理',
        path: '/admin/system-management/users',
        component: 'admin/pages/system-management/users/UserList.vue',
        permission: 'sys:user:list',
      },
      {
        id: 12,
        name: '角色权限',
        path: '/admin/system-management/roles',
        component: 'admin/pages/system-management/roles/RoleList.vue',
        permission: 'sys:role:list',
      },
      {
        id: 13,
        name: '菜单管理',
        path: '/admin/system-management/menus',
        component: 'admin/pages/system-management/menus/MenuList.vue',
        permission: 'sys:menu:list',
      },
    ],
  },
  {
    id: 2,
    name: '组织架构',
    path: '/admin/organization-management',
    children: [
      {
        id: 21,
        name: '部门管理',
        path: '/admin/organization-management/departments',
        component: 'admin/pages/organization-management/DepartmentList.vue',
        permission: 'org:dept:list',
      },
    ],
  },
]);

const dialogVisible = ref(false);
const dialogTitle = ref('');
const isEditing = ref(false);
const parentMenuId = ref<number | null>(null);
const currentEditingMenu = ref<MenuItem>({
  id: 0,
  name: '',
  path: '',
  component: '',
  permission: '',
});

// 辅助函数：查找菜单项
const findMenuItem = (menus: MenuItem[], id: number): MenuItem | undefined => {
  for (const menu of menus) {
    if (menu.id === id) {
      return menu;
    }
    if (menu.children) {
      const found = findMenuItem(menu.children, id);
      if (found) {
        return found;
      }
    }
  }
  return undefined;
};

// 辅助函数：添加菜单项
const addMenuItem = (menus: MenuItem[], parentId: number | null, newItem: MenuItem): boolean => {
  if (parentId === null) {
    menus.push(newItem);
    return true;
  }
  for (const menu of menus) {
    if (menu.id === parentId) {
      if (!menu.children) {
        menu.children = [];
      }
      menu.children.push(newItem);
      return true;
    }
    if (menu.children && addMenuItem(menu.children, parentId, newItem)) {
      return true;
    }
  }
  return false;
};

// 辅助函数：更新菜单项
const updateMenuItem = (menus: MenuItem[], updatedItem: MenuItem): boolean => {
  for (let i = 0; i < menus.length; i++) {
    if (menus[i].id === updatedItem.id) {
      menus[i] = { ...updatedItem, children: menus[i].children }; // 保留原有子菜单
      return true;
    }
    const children = menus[i].children;
    if (children && updateMenuItem(children, updatedItem)) {
      return true;
    }
  }
  return false;
};

// 辅助函数：删除菜单项
const removeMenuItem = (menus: MenuItem[], id: number): boolean => {
  for (let i = 0; i < menus.length; i++) {
    if (menus[i].id === id) {
      menus.splice(i, 1);
      return true;
    }
    const children = menus[i].children;
    if (children && removeMenuItem(children, id)) {
      return true;
    }
  }
  return false;
};

const addMenu = () => {
  dialogTitle.value = '新增菜单';
  isEditing.value = false;
  parentMenuId.value = null;
  currentEditingMenu.value = {
    id: 0,
    name: '',
    path: '',
    component: '',
    permission: '',
  };
  dialogVisible.value = true;
};

const addChildrenMenu = (parentId: number) => {
  dialogTitle.value = '新增子菜单';
  isEditing.value = false;
  parentMenuId.value = parentId;
  currentEditingMenu.value = {
    id: 0,
    name: '',
    path: '',
    component: '',
    permission: '',
  };
  dialogVisible.value = true;
};

const editMenu = (menuId: number) => {
  dialogTitle.value = '编辑菜单';
  isEditing.value = true;
  parentMenuId.value = null; // 编辑时不改变父级
  const menuToEdit = findMenuItem(menuData.value, menuId);
  if (menuToEdit) {
    currentEditingMenu.value = { ...menuToEdit };
    dialogVisible.value = true;
  } else {
    ElMessage.error('未找到要编辑的菜单！');
  }
};

const deleteMenu = (menuId: number) => {
  ElMessageBox.confirm('此操作将永久删除该菜单及其所有子菜单, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      if (removeMenuItem(menuData.value, menuId)) {
        ElMessage.success('删除成功!');
        // 强制更新视图，因为splice可能不会触发响应式
        menuData.value = [...menuData.value];
      } else {
        ElMessage.error('删除失败，未找到菜单！');
      }
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};

const handleSubmit = () => {
  if (currentEditingMenu.value.name.trim() === '' || currentEditingMenu.value.path.trim() === '') {
    ElMessage.warning('菜单名称和路由路径不能为空！');
    return;
  }

  if (isEditing.value) {
    // 编辑操作
    if (updateMenuItem(menuData.value, currentEditingMenu.value)) {
      ElMessage.success('菜单更新成功!');
    } else {
      ElMessage.error('菜单更新失败！');
    }
  } else {
    // 新增操作
    const newId = Math.max(...menuData.value.flatMap(m => [m.id, ...(m.children || []).map(c => c.id)])) + 1;
    const newItem = { ...currentEditingMenu.value, id: newId };
    if (addMenuItem(menuData.value, parentMenuId.value, newItem)) {
      ElMessage.success('菜单新增成功!');
    } else {
      ElMessage.error('菜单新增失败，未找到父级菜单！');
    }
  }
  dialogVisible.value = false;
  // 强制更新视图，确保树形结构正确显示
  menuData.value = [...menuData.value];
};

const handleCloseDialog = () => {
  dialogVisible.value = false;
};
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

.action-section {
  margin-bottom: 20px;
}

.dialog-footer {
  text-align: right;
}
</style>
