<template>
  <div class="position-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>岗位管理</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索岗位名称"
          clearable
          style="width: 200px; margin-right: 10px;"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button type="success" @click="addPosition">新增岗位</el-button>
      </div>

      <el-table :data="paginatedPositions" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" />
        <el-table-column prop="name" label="岗位名称" />
        <el-table-column prop="department" label="所属部门" />
        <el-table-column prop="description" label="岗位描述" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="editPosition(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deletePosition(scope.row.id)">删除</el-button>
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
        :total="totalPositions"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>

    <!-- 新增/编辑岗位的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEditingPosition" label-width="80px">
        <el-form-item label="岗位名称">
          <el-input v-model="currentEditingPosition.name"></el-input>
        </el-form-item>
        <el-form-item label="所属部门">
          <el-select v-model="currentEditingPosition.department" placeholder="请选择部门" :teleported="true">
            <el-option label="技术部-前端组" value="技术部-前端组"></el-option>
            <el-option label="技术部-后端组" value="技术部-后端组"></el-option>
            <el-option label="人力资源部" value="人力资源部"></el-option>
            <el-option label="人力资源部-招聘组" value="人力资源部-招聘组"></el-option>
            <el-option label="人力资源部-薪酬组" value="人力资源部-薪酬组"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="岗位描述">
          <el-input type="textarea" v-model="currentEditingPosition.description"></el-input>
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

interface Position {
  id: number;
  name: string;
  department: string;
  description: string;
}

const positions = ref<Position[]>([
  { id: 1, name: '前端开发工程师', department: '技术部-前端组', description: '负责前端页面开发' },
  { id: 2, name: '后端开发工程师', department: '技术部-后端组', description: '负责后端接口开发' },
  { id: 3, name: 'HRBP', department: '人力资源部', description: '人力资源业务伙伴' },
  { id: 4, name: '招聘专员', department: '人力资源部-招聘组', description: '负责人才招聘' },
  { id: 5, name: '薪酬福利专员', department: '人力资源部-薪酬组', description: '负责薪酬核算' },
]);

const searchQuery = ref('');
const currentPage = ref(1);
const pageSize = ref(10);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentEditingPosition = ref<Position>({
  id: 0,
  name: '',
  department: '',
  description: '',
});

const filteredPositions = computed(() => {
  let result = positions.value;
  if (searchQuery.value) {
    result = result.filter(position =>
      position.name.includes(searchQuery.value) ||
      position.department.includes(searchQuery.value) ||
      position.description.includes(searchQuery.value)
    );
  }
  return result;
});

const totalPositions = computed(() => filteredPositions.value.length);

const paginatedPositions = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredPositions.value.slice(start, end);
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

const addPosition = () => {
  dialogTitle.value = '新增岗位';
  currentEditingPosition.value = {
    id: 0,
    name: '',
    department: '',
    description: '',
  };
  dialogVisible.value = true;
};

const editPosition = (positionId: number) => {
  dialogTitle.value = '编辑岗位';
  const positionToEdit = positions.value.find(p => p.id === positionId);
  if (positionToEdit) {
    currentEditingPosition.value = { ...positionToEdit };
    dialogVisible.value = true;
  }
};

const deletePosition = (positionId: number) => {
  ElMessageBox.confirm('此操作将永久删除该岗位, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      const index = positions.value.findIndex(p => p.id === positionId);
      if (index !== -1) {
        positions.value.splice(index, 1);
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
  if (currentEditingPosition.value.name.trim() === '' || currentEditingPosition.value.department.trim() === '') {
    ElMessage.warning('岗位名称和所属部门不能为空！');
    return;
  }

  if (currentEditingPosition.value.id === 0) {
    // 新增岗位
    const newId = Math.max(...positions.value.map(p => p.id)) + 1;
    positions.value.push({ ...currentEditingPosition.value, id: newId });
    ElMessage.success('新增岗位成功!');
  } else {
    // 编辑岗位
    const index = positions.value.findIndex(p => p.id === currentEditingPosition.value.id);
    if (index !== -1) {
      positions.value[index] = { ...currentEditingPosition.value };
      ElMessage.success('编辑岗位成功!');
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
.position-list-container {
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
