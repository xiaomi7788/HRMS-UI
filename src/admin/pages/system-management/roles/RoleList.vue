<template>
  <div class="role-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>角色权限管理</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索角色名称"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button type="success" @click="addRole">新增角色</el-button>
      </div>

      <el-table :data="paginatedRoles" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" />
        <el-table-column prop="name" label="角色名称" />
        <el-table-column prop="description" label="角色描述" />
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="assignPermissions(scope.row.id)">分配权限</el-button>
            <el-button size="small" @click="editRole(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteRole(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :small="false"
        :disabled="false"
        :background="true"
        layout="total, sizes, prev, pager, next, jumper"
        :total="totalRoles"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>

    <!-- 新增/编辑角色的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEditingRole" label-width="80px">
        <el-form-item label="角色名称">
          <el-input v-model="currentEditingRole.name"></el-input>
        </el-form-item>
        <el-form-item label="角色描述">
          <el-input type="textarea" v-model="currentEditingRole.description"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleCloseDialog">取消</el-button>
          <el-button type="primary" @click="handleSubmit">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 权限分配对话框 -->
    <el-dialog
      v-model="permissionDialogVisible"
      title="分配权限"
      width="40%"
      :before-close="handleClosePermissionDialog"
    >
      <el-tree
        ref="permissionTreeRef"
        :data="allPermissions"
        show-checkbox
        node-key="id"
        :props="{ label: 'name', children: 'children' }"
        default-expand-all
        popper-append-to-body
      />
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleClosePermissionDialog">取消</el-button>
          <el-button type="primary" @click="handleSavePermissions">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from 'vue';
import { ElMessage, ElMessageBox, ElTree } from 'element-plus';

interface Role {
  id: number;
  name: string;
  description: string;
  permissions?: number[]; // 新增权限ID数组
}

interface Permission {
  id: number;
  name: string;
  children?: Permission[];
}

const roles = ref<Role[]>([
  { id: 1, name: '超级管理员', description: '拥有系统所有权限', permissions: [1, 11, 12, 13, 2, 21] },
  { id: 2, name: '管理员', description: '管理后台大部分功能', permissions: [1, 11, 12, 2, 21] },
  { id: 3, name: 'HR管理员', description: '负责人力资源相关管理', permissions: [1, 11, 2, 21] },
  { id: 4, name: 'HR专员', description: '处理日常HR事务', permissions: [11, 21] },
  { id: 5, name: '部门负责人', description: '管理本部门员工', permissions: [21] },
]);

const allPermissions: Permission[] = [
  {
    id: 1,
    name: '系统管理',
    children: [
      { id: 11, name: '用户管理' },
      { id: 12, name: '角色权限' },
      { id: 13, name: '菜单管理' },
    ],
  },
  {
    id: 2,
    name: '组织架构',
    children: [
      { id: 21, name: '部门管理' },
      { id: 22, name: '岗位管理' },
    ],
  },
  {
    id: 3,
    name: '员工管理',
    children: [
      { id: 31, name: '员工信息维护' },
      { id: 32, name: '员工入转调离管理' },
      { id: 33, name: '劳动合同管理' },
      { id: 34, name: '人事异动查询与统计' },
      { id: 35, name: '花名册管理' },
      { id: 36, name: '继任者计划与人才梯队管理' },
    ],
  },
  {
    id: 4,
    name: '招聘管理',
    children: [
      { id: 41, name: '职位发布管理' },
      { id: 42, name: '候选人简历库与人才池管理' },
      { id: 43, name: '面试流程安排与面试官管理' },
      { id: 44, name: '面试评价与录用审批线上流转' },
      { id: 45, name: 'Offer发放与入职预约' },
    ],
  },
  {
    id: 5,
    name: '考勤与工时管理',
    children: [
      { id: 51, name: '考勤数据处理' },
      { id: 52, name: '假期额度与申请流程管理' },
      { id: 53, name: '加班申请与核算' },
      { id: 54, name: '月度考勤报表' },
    ],
  },
  {
    id: 6,
    name: '薪酬与福利管理',
    children: [
      { id: 61, name: '月度薪酬核算与个税计算' },
      { id: 62, name: '社保、公积金账户管理与缴纳' },
      { id: 63, name: '薪酬调整审批流程' },
      { id: 64, name: '薪酬报表与成本分析' },
      { id: 65, name: '福利项目发放与登记' },
    ],
  },
  {
    id: 7,
    name: '绩效管理',
    children: [
      { id: 71, name: '绩效目标制定与对齐' },
      { id: 72, name: '绩效过程跟踪与反馈记录' },
      { id: 73, name: '绩效评估与校准会议支持' },
      { id: 74, name: '绩效结果应用与改进计划' },
    ],
  },
];

const searchQuery = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentEditingRole = ref<Role>({
  id: 0,
  name: '',
  description: '',
  permissions: [],
});

const permissionDialogVisible = ref(false);
const currentAssigningRoleId = ref<number | null>(null);
const permissionTreeRef = ref<InstanceType<typeof ElTree>>();

const filteredRoles = computed(() => {
  let result = roles.value;
  if (searchQuery.value) {
    result = result.filter(role => role.name.includes(searchQuery.value) || role.description.includes(searchQuery.value));
  }
  return result;
});

const totalRoles = computed(() => filteredRoles.value.length);

const paginatedRoles = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredRoles.value.slice(start, end);
});

const handleSearch = () => {
  currentPage.value = 1; // 搜索时重置到第一页
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  currentPage.value = 1; // 改变每页大小时重置到第一页
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
};

const addRole = () => {
  dialogTitle.value = '新增角色';
  currentEditingRole.value = {
    id: 0,
    name: '',
    description: '',
    permissions: [],
  };
  dialogVisible.value = true;
};

const assignPermissions = (roleId: number) => {
  currentAssigningRoleId.value = roleId;
  const role = roles.value.find(r => r.id === roleId);
  if (role && permissionTreeRef.value) {
    permissionDialogVisible.value = true;
    nextTick(() => {
      permissionTreeRef.value?.setCheckedKeys(role.permissions || [], false);
    });
  } else {
    ElMessage.error('未找到角色或权限树未初始化！');
  }
};

const editRole = (roleId: number) => {
  dialogTitle.value = '编辑角色';
  const roleToEdit = roles.value.find(r => r.id === roleId);
  if (roleToEdit) {
    currentEditingRole.value = { ...roleToEdit };
    dialogVisible.value = true;
  }
};

const deleteRole = (roleId: number) => {
  ElMessageBox.confirm('此操作将永久删除该角色, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      const index = roles.value.findIndex(r => r.id === roleId);
      if (index !== -1) {
        roles.value.splice(index, 1);
        ElMessage.success('删除成功!');
        // 重新计算分页，确保删除后页面显示正确
        handleSearch();
      }
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};

const handleSubmit = () => {
  if (currentEditingRole.value.name.trim() === '') {
    ElMessage.warning('角色名称不能为空！');
    return;
  }

  if (currentEditingRole.value.id === 0) {
    // 新增角色
    const newId = Math.max(...roles.value.map(r => r.id)) + 1;
    roles.value.push({ ...currentEditingRole.value, id: newId });
    ElMessage.success('新增角色成功!');
  } else {
    // 编辑角色
    const index = roles.value.findIndex(r => r.id === currentEditingRole.value.id);
    if (index !== -1) {
      roles.value[index] = { ...currentEditingRole.value };
      ElMessage.success('编辑角色成功!');
    }
  }
  dialogVisible.value = false;
  // 重新计算分页，确保新增/编辑后页面显示正确
  handleSearch();
};

const handleCloseDialog = () => {
  dialogVisible.value = false;
};

const handleSavePermissions = () => {
  if (currentAssigningRoleId.value !== null && permissionTreeRef.value) {
    const checkedKeys = permissionTreeRef.value.getCheckedKeys(false) as number[]; // 只获取叶子节点的key
    const role = roles.value.find(r => r.id === currentAssigningRoleId.value);
    if (role) {
      role.permissions = checkedKeys;
      ElMessage.success(`角色 ${role.name} 的权限已更新！`);
    } else {
      ElMessage.error('保存权限失败，未找到角色！');
    }
  }
  permissionDialogVisible.value = false;
};

const handleClosePermissionDialog = () => {
  permissionDialogVisible.value = false;
};
</script>

<style scoped>
.role-list-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-filter-section {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.dialog-footer {
  text-align: right;
}
</style>
