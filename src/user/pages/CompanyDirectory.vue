<template>
  <div class="company-directory-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>公司通讯录</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="部门">
          <el-select v-model="queryForm.department" placeholder="选择部门" clearable popper-append-to-body>
            <el-option label="技术部" value="技术部"></el-option>
            <el-option label="市场部" value="市场部"></el-option>
            <el-option label="销售部" value="销售部"></el-option>
            <el-option label="人事部" value="人事部"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="姓名/工号">
          <el-input v-model="queryForm.keyword" placeholder="输入姓名或工号" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="searchEmployees">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="employeeList" style="width: 100%" border v-loading="loading">
        <el-table-column prop="name" label="姓名" width="120"></el-table-column>
        <el-table-column prop="employeeId" label="工号" width="100"></el-table-column>
        <el-table-column prop="department" label="部门" width="120"></el-table-column>
        <el-table-column prop="position" label="岗位" width="150"></el-table-column>
        <el-table-column prop="contact" label="联系方式"></el-table-column>
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
  department: '',
  keyword: '',
});

const allEmployees = [
  // 模拟数据
  { id: 1, name: '张三', employeeId: 'HRM001', department: '技术部', position: '前端开发工程师', contact: '13800001111' },
  { id: 2, name: '李四', employeeId: 'HRM002', department: '技术部', position: '后端开发工程师', contact: '13800002222' },
  { id: 3, name: '王五', employeeId: 'HRM003', department: '市场部', position: '市场专员', contact: '13800003333' },
  { id: 4, name: '赵六', employeeId: 'HRM004', department: '销售部', position: '销售经理', contact: '13800004444' },
  { id: 5, name: '钱七', employeeId: 'HRM005', department: '人事部', position: 'HRBP', contact: '13800005555' },
  { id: 6, name: '孙八', employeeId: 'HRM006', department: '技术部', position: '测试工程师', contact: '13800006666' },
];
const employeeList = ref([...allEmployees]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(employeeList.value.length);

const searchEmployees = () => {
  loading.value = true;
  setTimeout(() => {
    let filtered = allEmployees;
    if (queryForm.department) {
      filtered = filtered.filter(emp => emp.department === queryForm.department);
    }
    if (queryForm.keyword) {
      filtered = filtered.filter(emp =>
        emp.name.includes(queryForm.keyword) || emp.employeeId.includes(queryForm.keyword)
      );
    }
    employeeList.value = filtered;
    total.value = filtered.length;
    ElMessage.success('查询成功！');
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.department = '';
  queryForm.keyword = '';
  employeeList.value = [...allEmployees];
  total.value = allEmployees.length;
  ElMessage.info('查询条件已重置。');
};

const viewEmployeeDetail = (row: any) => {
  ElMessage.info(`查看员工详情: ${row.name} (${row.employeeId})`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  searchEmployees();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  searchEmployees();
};

onMounted(() => {
  searchEmployees();
});
</script>

<style scoped>
.company-directory-container {
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
