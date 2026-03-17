<template>
  <div class="employee-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工信息维护</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索员工姓名、工号或部门"
          clearable
          style="width: 250px; margin-right: 10px;"
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
          <el-option label="在职" value="在职" />
          <el-option label="离职" value="离职" />
          <el-option label="试用期" value="试用期" />
        </el-select>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button type="success" @click="addEmployee">新增员工</el-button>
      </div>

      <el-table :data="paginatedEmployees" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="employeeId" label="工号" />
        <el-table-column prop="department" label="部门" />
        <el-table-column prop="position" label="岗位" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="getStatusTagType(scope.row.status)">
              {{ scope.row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="viewEmployee(scope.row.id)">查看</el-button>
            <el-button size="small" @click="editEmployee(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteEmployee(scope.row.id)">删除</el-button>
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
        :total="totalEmployees"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface Employee {
  id: number;
  name: string;
  employeeId: string;
  department: string;
  position: string;
  status: '在职' | '离职' | '试用期';
}

const employees = ref<Employee[]>([
  { id: 1, name: '张三', employeeId: 'HRM001', department: '技术部', position: '前端开发工程师', status: '在职' },
  { id: 2, name: '李四', employeeId: 'HRM002', department: '人力资源部', position: 'HRBP', status: '在职' },
  { id: 3, name: '王五', employeeId: 'HRM003', department: '技术部', position: '后端开发工程师', status: '试用期' },
  { id: 4, name: '赵六', employeeId: 'HRM004', department: '市场部', position: '市场专员', status: '离职' },
  { id: 5, name: '陈七', employeeId: 'HRM005', department: '销售部', position: '销售经理', status: '在职' },
  { id: 6, name: '孙八', employeeId: 'HRM006', department: '技术部', position: '测试工程师', status: '在职' },
  { id: 7, name: '周九', employeeId: 'HRM007', department: '人力资源部', position: '招聘专员', status: '试用期' },
  { id: 8, name: '吴十', employeeId: 'HRM008', department: '财务部', position: '会计', status: '在职' },
]);

const searchQuery = ref('');
const filterStatus = ref('所有');
const currentPage = ref(1);
const pageSize = ref(10);

const filteredEmployees = computed(() => {
  let result = employees.value;
  if (filterStatus.value !== '所有') {
    result = result.filter(employee => employee.status === filterStatus.value);
  }
  if (searchQuery.value) {
    result = result.filter(employee =>
      employee.name.includes(searchQuery.value) ||
      employee.employeeId.includes(searchQuery.value) ||
      employee.department.includes(searchQuery.value)
    );
  }
  return result;
});

const totalEmployees = computed(() => filteredEmployees.value.length);

const paginatedEmployees = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredEmployees.value.slice(start, end);
});

const getStatusTagType = (status: Employee['status']) => {
  switch (status) {
    case '在职':
      return 'success';
    case '离职':
      return 'danger';
    case '试用期':
      return 'warning';
    default:
      return '';
  }
};

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

const addEmployee = () => {
  ElMessage.info('新增员工功能待实现');
};

const viewEmployee = (employeeId: number) => {
  ElMessage.info(`查看员工 ${employeeId} 详情功能待实现`);
};

const editEmployee = (employeeId: number) => {
  ElMessage.info(`编辑员工 ${employeeId} 功能待实现`);
};

const deleteEmployee = (employeeId: number) => {
  ElMessageBox.confirm('此操作将永久删除该员工, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      const index = employees.value.findIndex(e => e.id === employeeId);
      if (index !== -1) {
        employees.value.splice(index, 1);
        ElMessage.success('删除成功!');
      }
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};
</script>

<style scoped>
.employee-list-container {
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
</style>
