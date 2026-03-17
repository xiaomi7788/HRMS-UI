<template>
  <div class="team-performance-view-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>团队绩效查看</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="员工姓名/工号">
          <el-input v-model="queryForm.keyword" placeholder="输入姓名或工号" clearable></el-input>
        </el-form-item>
        <el-form-item label="年份">
          <el-date-picker
            v-model="queryForm.year"
            type="year"
            placeholder="选择年份"
            value-format="YYYY"
          />
        </el-form-item>
        <el-form-item label="季度">
          <el-select v-model="queryForm.quarter" placeholder="选择季度" clearable popper-append-to-body>
            <el-option label="第一季度" value="Q1"></el-option>
            <el-option label="第二季度" value="Q2"></el-option>
            <el-option label="第三季度" value="Q3"></el-option>
            <el-option label="第四季度" value="Q4"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchTeamPerformanceData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="teamPerformanceData" style="width: 100%" border v-loading="loading">
        <el-table-column prop="name" label="姓名" width="120"></el-table-column>
        <el-table-column prop="employeeId" label="工号" width="100"></el-table-column>
        <el-table-column prop="year" label="年份" width="80"></el-table-column>
        <el-table-column prop="quarter" label="季度" width="80"></el-table-column>
        <el-table-column prop="score" label="绩效得分" width="100"></el-table-column>
        <el-table-column prop="rating" label="绩效等级" width="100">
          <template #default="{ row }">
            <el-tag :type="getRatingType(row.rating)">{{ row.rating }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="viewDetail(row)">查看详情</el-button>
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
  year: new Date().getFullYear().toString(),
  quarter: '',
});

const allTeamPerformanceData = [
  // 模拟数据
  { id: 1, name: '张三', employeeId: 'HRM001', year: '2023', quarter: 'Q3', score: 90, rating: 'A' },
  { id: 2, name: '李四', employeeId: 'HRM002', year: '2023', quarter: 'Q3', score: 85, rating: 'B' },
  { id: 3, name: '孙八', employeeId: 'HRM006', year: '2023', quarter: 'Q3', score: 92, rating: 'A' },
  { id: 4, name: '周九', employeeId: 'HRM007', year: '2023', quarter: 'Q3', score: 78, rating: 'C' },
];
const teamPerformanceData = ref([...allTeamPerformanceData]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(teamPerformanceData.value.length);

const getRatingType = (rating: string) => {
  switch (rating) {
    case 'A': return 'success';
    case 'B': return 'primary';
    case 'C': return 'warning';
    case 'D': return 'danger';
    default: return '';
  }
};

const fetchTeamPerformanceData = () => {
  loading.value = true;
  setTimeout(() => {
    let filtered = allTeamPerformanceData;
    if (queryForm.keyword) {
      filtered = filtered.filter(emp =>
        emp.name.includes(queryForm.keyword) || emp.employeeId.includes(queryForm.keyword)
      );
    }
    if (queryForm.year) {
      filtered = filtered.filter(emp => emp.year === queryForm.year);
    }
    if (queryForm.quarter) {
      filtered = filtered.filter(emp => emp.quarter === queryForm.quarter);
    }
    teamPerformanceData.value = filtered;
    total.value = filtered.length;
    ElMessage.success('查询成功！');
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.keyword = '';
  queryForm.year = new Date().getFullYear().toString();
  queryForm.quarter = '';
  teamPerformanceData.value = [...allTeamPerformanceData];
  total.value = allTeamPerformanceData.length;
  ElMessage.info('查询条件已重置。');
};

const viewDetail = (row: any) => {
  ElMessage.info(`查看 ${row.name} (${row.employeeId}) 的绩效详情`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchTeamPerformanceData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchTeamPerformanceData();
};

onMounted(() => {
  fetchTeamPerformanceData();
});
</script>

<style scoped>
.team-performance-view-container {
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
