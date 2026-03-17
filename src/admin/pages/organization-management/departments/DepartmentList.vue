<template>
  <div class="department-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>部门管理</span>
        </div>
      </template>

      <div class="action-section">
        <el-button type="success" @click="addDepartment">新增部门</el-button>
      </div>

      <el-table
        :data="departmentData"
        style="width: 100%; margin-top: 20px;"
        row-key="id"
        border
        default-expand-all
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
      >
        <el-table-column prop="name" label="部门名称" />
        <el-table-column prop="manager" label="部门负责人" />
        <el-table-column prop="description" label="部门描述" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="addChildrenDepartment(scope.row.id)">新增子部门</el-button>
            <el-button size="small" @click="editDepartment(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteDepartment(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑部门的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
      append-to-body
    >
      <el-form :model="currentEditingDepartment" label-width="100px">
        <el-form-item label="部门名称">
          <el-input v-model="currentEditingDepartment.name"></el-input>
        </el-form-item>
        <el-form-item label="部门负责人">
          <el-input v-model="currentEditingDepartment.manager"></el-input>
        </el-form-item>
        <el-form-item label="部门描述">
          <el-input type="textarea" v-model="currentEditingDepartment.description"></el-input>
        </el-form-item>
        <el-form-item v-if="!isEditing" label="父级部门">
          <el-tree-select
            v-model="parentDepartmentId"
            :data="departmentData"
            :props="{ label: 'name', value: 'id', children: 'children' }"
            check-strictly
            clearable
            placeholder="选择父级部门 (可选)"
            style="width: 100%;"
            :teleported="true"
            popper-class="department-tree-select"
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

interface Department {
  id: number;
  name: string;
  manager: string;
  description: string;
  children?: Department[];
}

const departmentData = ref<Department[]>([
  {
    id: 1,
    name: '总经办',
    manager: '张三',
    description: '公司最高管理层',
  },
  {
    id: 2,
    name: '人力资源部',
    manager: '李四',
    description: '负责人力资源管理',
    children: [
      {
        id: 21,
        name: '招聘组',
        manager: '王五',
        description: '负责招聘工作',
      },
      {
        id: 22,
        name: '薪酬组',
        manager: '赵六',
        description: '负责薪酬福利',
      },
    ],
  },
  {
    id: 3,
    name: '技术部',
    manager: '陈七',
    description: '负责技术研发',
    children: [
      {
        id: 31,
        name: '前端组',
        manager: '孙八',
        description: '负责前端开发',
      },
      {
        id: 32,
        name: '后端组',
        manager: '周九',
        description: '负责后端开发',
      },
    ],
  },
]);

const dialogVisible = ref(false);
const dialogTitle = ref('');
const isEditing = ref(false);
const parentDepartmentId = ref<number | null>(null);
const currentEditingDepartment = ref<Department>({
  id: 0,
  name: '',
  manager: '',
  description: '',
});

// 辅助函数：查找部门项
const findDepartmentItem = (departments: Department[], id: number): Department | undefined => {
  for (const dept of departments) {
    if (dept.id === id) {
      return dept;
    }
    if (dept.children) {
      const found = findDepartmentItem(dept.children, id);
      if (found) {
        return found;
      }
    }
  }
  return undefined;
};

// 辅助函数：添加部门项
const addDepartmentItem = (departments: Department[], parentId: number | null, newItem: Department): boolean => {
  if (parentId === null) {
    departments.push(newItem);
    return true;
  }
  for (const dept of departments) {
    if (dept.id === parentId) {
      if (!dept.children) {
        dept.children = [];
      }
      dept.children.push(newItem);
      return true;
    }
    if (dept.children && addDepartmentItem(dept.children, parentId, newItem)) {
      return true;
    }
  }
  return false;
};

// 辅助函数：更新部门项
const updateDepartmentItem = (departments: Department[], updatedItem: Department): boolean => {
  for (let i = 0; i < departments.length; i++) {
    if (departments[i].id === updatedItem.id) {
      departments[i] = { ...updatedItem, children: departments[i].children }; // 保留原有子部门
      return true;
    }
    const children = departments[i].children;
    if (children && updateDepartmentItem(children, updatedItem)) {
      return true;
    }
  }
  return false;
};

// 辅助函数：删除部门项
const removeDepartmentItem = (departments: Department[], id: number): boolean => {
  for (let i = 0; i < departments.length; i++) {
    if (departments[i].id === id) {
      departments.splice(i, 1);
      return true;
    }
    const children = departments[i].children;
    if (children && removeDepartmentItem(children, id)) {
      return true;
    }
  }
  return false;
};

const addDepartment = () => {
  dialogTitle.value = '新增部门';
  isEditing.value = false;
  parentDepartmentId.value = null;
  currentEditingDepartment.value = {
    id: 0,
    name: '',
    manager: '',
    description: '',
  };
  dialogVisible.value = true;
};

const addChildrenDepartment = (parentId: number) => {
  dialogTitle.value = '新增子部门';
  isEditing.value = false;
  parentDepartmentId.value = parentId;
  currentEditingDepartment.value = {
    id: 0,
    name: '',
    manager: '',
    description: '',
  };
  dialogVisible.value = true;
};

const editDepartment = (departmentId: number) => {
  dialogTitle.value = '编辑部门';
  isEditing.value = true;
  parentDepartmentId.value = null; // 编辑时不改变父级
  const departmentToEdit = findDepartmentItem(departmentData.value, departmentId);
  if (departmentToEdit) {
    currentEditingDepartment.value = { ...departmentToEdit };
    dialogVisible.value = true;
  } else {
    ElMessage.error('未找到要编辑的部门！');
  }
};

const deleteDepartment = (departmentId: number) => {
  ElMessageBox.confirm('此操作将永久删除该部门及其所有子部门, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      if (removeDepartmentItem(departmentData.value, departmentId)) {
        ElMessage.success('删除成功!');
        // 强制更新视图，因为splice可能不会触发响应式
        departmentData.value = [...departmentData.value];
      } else {
        ElMessage.error('删除失败，未找到部门！');
      }
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};

const handleSubmit = () => {
  if (currentEditingDepartment.value.name.trim() === '') {
    ElMessage.warning('部门名称不能为空！');
    return;
  }

  if (isEditing.value) {
    // 编辑操作
    if (updateDepartmentItem(departmentData.value, currentEditingDepartment.value)) {
      ElMessage.success('部门更新成功!');
    } else {
      ElMessage.error('部门更新失败！');
    }
  }
  else {
    // 新增操作
    const newId = Math.max(...departmentData.value.flatMap(d => [d.id, ...(d.children || []).map(c => c.id)])) + 1;
    const newItem = { ...currentEditingDepartment.value, id: newId };
    if (addDepartmentItem(departmentData.value, parentDepartmentId.value, newItem)) {
      ElMessage.success('部门新增成功!');
    } else {
      ElMessage.error('部门新增失败，未找到父级部门！');
    }
  }
  dialogVisible.value = false;
  // 强制更新视图，确保树形结构正确显示
  departmentData.value = [...departmentData.value];
};

const handleCloseDialog = () => {
  dialogVisible.value = false;
};
</script>

<style scoped>
.department-list-container {
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

.department-tree-select {
  z-index: 9999 !important;
}

.el-dialog {
  overflow: visible;
}
</style>
