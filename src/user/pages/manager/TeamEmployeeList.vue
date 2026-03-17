<template>
  <div class="team-employee-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>团队员工列表</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="姓名/工号">
          <el-input v-model="queryForm.keyword" placeholder="输入姓名或工号" clearable></el-input>
        </el-form-item>
        <el-form-item label="岗位">
          <el-select v-model="queryForm.position" placeholder="选择岗位" clearable popper-append-to-body>
            <el-option label="前端开发工程师" value="前端开发工程师"></el-option>
            <el-option label="后端开发工程师" value="后端开发工程师"></el-option>
            <el-option label="测试工程师" value="测试工程师"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchTeamEmployees">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="teamEmployeeList" style="width: 100%" border v-loading="loading">
        <el-table-column prop="name" label="姓名" width="120"></el-table-column>
        <el-table-column prop="employeeId" label="工号" width="100"></el-table-column>
        <el-table-column prop="department" label="部门" width="120"></el-table-column>
        <el-table-column prop="position" label="岗位" width="150"></el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getEmployeeStatusType(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="viewEmployeeDetail(row)">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        background
        class="pagination-container"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue';
import { ElMessage } from 'element-plus';

const loading = ref(false);
const queryForm = reactive({
  keyword: '',
  position: '',
});

const allTeamEmployees = [
  // 模拟数据 (假设部门经理管理技术部)
  { id: 1, name: '张三', employeeId: 'HRM001', department: '技术部', position: '前端开发工程师', status: '在职' },
  { id: 2, name: '李四', employeeId: 'HRM002', department: '技术部', position: '后端开发工程师', status: '在职' },
  { id: 6, name: '孙八', employeeId: 'HRM006', department: '技术部', position: '测试工程师', status: '在职' },
  { id: 7, name: '周九', employeeId: 'HRM007', department: '技术部', position: '前端开发工程师', status: '试用期' },
];
const teamEmployeeList = ref([...allTeamEmployees]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(teamEmployeeList.value.length);

const getEmployeeStatusType = (status: string) => {
  switch (status) {
    case '在职': return 'success';
    case '试用期': return 'warning';
    case '离职': return 'danger';
    default: return '';
  }
};

const searchTeamEmployees = () => {
  loading.value = true;
  setTimeout(() => {
    let filtered = allTeamEmployees;
    if (queryForm.keyword) {
      filtered = filtered.filter(emp =>
        emp.name.includes(queryForm.keyword) || emp.employeeId.includes(queryForm.keyword)
      );
    }
    if (queryForm.position) {
      filtered = filtered.filter(emp => emp.position === queryForm.position);
    }
    teamEmployeeList.value = filtered;
    total.value = filtered.length;
    ElMessage.success('查询成功！');
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.keyword = '';
  queryForm.position = '';
  teamEmployeeList.value = [...allTeamEmployees];
  total.value = allTeamEmployees.length;
  ElMessage.info('查询条件已重置。');
};

const viewEmployeeDetail = (row: any) => {
  ElMessage.info(`查看员工详情: ${row.name} (${row.employeeId})`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  searchTeamEmployees();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  searchTeamEmployees();
};

onMounted(() => {
  searchTeamEmployees();
});
</script>

<style scoped>
.team-employee-list-container {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
  font-weight: bold;
}

.query-form {
  margin-bottom: 20px;
}

.pagination-container {
  margin-top: 20px;
  justify-content: flex-end;
  display: flex;
}
</style>
