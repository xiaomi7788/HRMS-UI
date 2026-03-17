<template>
  <div class="user-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索用户名或邮箱"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        />
        <el-select
          v-model="filterStatus"
          placeholder="筛选状态"
          style="width: 120px; margin-right: 10px;"
          @change="handleFilter"
        >
          <el-option label="所有" value="所有" />
          <el-option label="启用" value="启用" />
          <el-option label="禁用" value="禁用" />
        </el-select>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button type="success" @click="addUser">新增用户</el-button>
      </div>

      <el-table :data="paginatedUsers" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="scope.row.status === '启用' ? 'success' : 'danger'">
              {{ scope.row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button
              size="small"
              :type="scope.row.status === '启用' ? 'warning' : 'success'"
              @click="toggleUserStatus(scope.row.id)"
            >
              {{ scope.row.status === '启用' ? '禁用' : '启用' }}
            </el-button>
            <el-button size="small" @click="editUser(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteUser(scope.row.id)">删除</el-button>
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
        :total="totalUsers"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>

    <!-- 新增/编辑用户的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEditingUser" label-width="80px">
        <el-form-item label="用户名">
          <el-input v-model="currentEditingUser.username"></el-input>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="currentEditingUser.email"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="currentEditingUser.status">
            <el-radio label="启用">启用</el-radio>
            <el-radio label="禁用">禁用</el-radio>
          </el-radio-group>
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
import { ref, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface User {
  id: number;
  username: string;
  email: string;
  status: '启用' | '禁用';
}

const users = ref<User[]>([
  { id: 1, username: 'admin', email: 'admin@example.com', status: '启用' },
  { id: 2, username: 'zhangsan', email: 'zhangsan@example.com', status: '禁用' },
  { id: 3, username: 'lisi', email: 'lisi@example.com', status: '启用' },
  { id: 4, username: 'wangwu', email: 'wangwu@example.com', status: '禁用' },
  { id: 5, username: 'zhaoliu', email: 'zhaoliu@example.com', status: '启用' },
  { id: 6, username: 'qianqi', email: 'qianqi@example.com', status: '启用' },
  { id: 7, username: 'sunba', email: 'sunba@example.com', status: '禁用' },
  { id: 8, username: 'zhoujiu', email: 'zhoujiu@example.com', status: '启用' },
  { id: 9, username: 'wushi', email: 'wushi@example.com', status: '禁用' },
  { id: 10, username: 'zhengyi', email: 'zhengyi@example.com', status: '启用' },
  { id: 11, username: 'chener', email: 'chener@example.com', status: '启用' },
  { id: 12, username: 'liusan', email: 'liusan@example.com', status: '禁用' },
]);

const searchQuery = ref('');
const filterStatus = ref('所有');
const currentPage = ref(1);
const pageSize = ref(10);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentEditingUser = ref<User>({
  id: 0,
  username: '',
  email: '',
  status: '启用',
});

const filteredUsers = computed(() => {
  let result = users.value;
  if (filterStatus.value !== '所有') {
    result = result.filter(user => user.status === filterStatus.value);
  }
  if (searchQuery.value) {
    result = result.filter(user =>
      user.username.includes(searchQuery.value) || user.email.includes(searchQuery.value)
    );
  }
  return result;
});

const totalUsers = computed(() => filteredUsers.value.length);

const paginatedUsers = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredUsers.value.slice(start, end);
});

const handleSearch = () => {
  currentPage.value = 1; // 搜索时重置到第一页
};

const handleFilter = () => {
  currentPage.value = 1; // 筛选时重置到第一页
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  currentPage.value = 1; // 改变每页大小时重置到第一页
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
};

const toggleUserStatus = (userId: number) => {
  const user = users.value.find(u => u.id === userId);
  if (user) {
    user.status = user.status === '启用' ? '禁用' : '启用';
    ElMessage.success(`${user.username} 已${user.status}`);
  }
};

const addUser = () => {
  dialogTitle.value = '新增用户';
  currentEditingUser.value = {
    id: 0,
    username: '',
    email: '',
    status: '启用',
  };
  dialogVisible.value = true;
};

const editUser = (userId: number) => {
  dialogTitle.value = '编辑用户';
  const userToEdit = users.value.find(u => u.id === userId);
  if (userToEdit) {
    currentEditingUser.value = { ...userToEdit };
    dialogVisible.value = true;
  }
};

const deleteUser = (userId: number) => {
  ElMessageBox.confirm('此操作将永久删除该用户, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      const index = users.value.findIndex(u => u.id === userId);
      if (index !== -1) {
        users.value.splice(index, 1);
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
  if (currentEditingUser.value.id === 0) {
    // 新增用户
    const newId = Math.max(...users.value.map(u => u.id)) + 1;
    users.value.push({ ...currentEditingUser.value, id: newId });
    ElMessage.success('新增用户成功!');
  } else {
    // 编辑用户
    const index = users.value.findIndex(u => u.id === currentEditingUser.value.id);
    if (index !== -1) {
      users.value[index] = { ...currentEditingUser.value };
      ElMessage.success('编辑用户成功!');
    }
  }
  dialogVisible.value = false;
  // 重新计算分页，确保新增/编辑后页面显示正确
  handleSearch();
};

const handleCloseDialog = () => {
  dialogVisible.value = false;
};
</script>

<style scoped>
.user-list-container {
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
