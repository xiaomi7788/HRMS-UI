<template>
  <div class="team-attendance-view-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>团队考勤查看</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="员工姓名/工号">
          <el-input v-model="queryForm.keyword" placeholder="输入姓名或工号" clearable></el-input>
        </el-form-item>
        <el-form-item label="月份">
          <el-date-picker
            v-model="queryForm.month"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchTeamAttendanceData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="teamAttendanceData" style="width: 100%" border v-loading="loading">
        <el-table-column prop="name" label="姓名" width="120"></el-table-column>
        <el-table-column prop="employeeId" label="工号" width="100"></el-table-column>
        <el-table-column prop="month" label="月份" width="100"></el-table-column>
        <el-table-column prop="attendanceDays" label="出勤天数" width="100"></el-table-column>
        <el-table-column prop="lateCount" label="迟到次数" width="100"></el-table-column>
        <el-table-column prop="earlyLeaveCount" label="早退次数" width="100"></el-table-column>
        <el-table-column prop="absenceDays" label="缺勤天数" width="100"></el-table-column>
        <el-table-column prop="overtimeHours" label="加班时长(小时)" width="120"></el-table-column>
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
  month: new Date().toISOString().slice(0, 7), // YYYY-MM
});

const allTeamAttendanceData = [
  // 模拟数据
  { id: 1, name: '张三', employeeId: 'HRM001', month: '2023-10', attendanceDays: 22, lateCount: 1, earlyLeaveCount: 0, absenceDays: 0, overtimeHours: 5 },
  { id: 2, name: '李四', employeeId: 'HRM002', month: '2023-10', attendanceDays: 20, lateCount: 2, earlyLeaveCount: 1, absenceDays: 1, overtimeHours: 8 },
  { id: 3, name: '孙八', employeeId: 'HRM006', month: '2023-10', attendanceDays: 23, lateCount: 0, earlyLeaveCount: 0, absenceDays: 0, overtimeHours: 10 },
  { id: 4, name: '周九', employeeId: 'HRM007', month: '2023-10', attendanceDays: 21, lateCount: 1, earlyLeaveCount: 0, absenceDays: 0, overtimeHours: 3 },
];
const teamAttendanceData = ref([...allTeamAttendanceData]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(teamAttendanceData.value.length);

const fetchTeamAttendanceData = () => {
  loading.value = true;
  setTimeout(() => {
    let filtered = allTeamAttendanceData;
    if (queryForm.keyword) {
      filtered = filtered.filter(emp =>
        emp.name.includes(queryForm.keyword) || emp.employeeId.includes(queryForm.keyword)
      );
    }
    if (queryForm.month) {
      filtered = filtered.filter(emp => emp.month === queryForm.month);
    }
    teamAttendanceData.value = filtered;
    total.value = filtered.length;
    ElMessage.success('查询成功！');
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.keyword = '';
  queryForm.month = new Date().toISOString().slice(0, 7);
  teamAttendanceData.value = [...allTeamAttendanceData];
  total.value = allTeamAttendanceData.length;
  ElMessage.info('查询条件已重置。');
};

const viewDetail = (row: any) => {
  ElMessage.info(`查看 ${row.name} (${row.employeeId}) 的考勤详情`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchTeamAttendanceData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchTeamAttendanceData();
};

onMounted(() => {
  fetchTeamAttendanceData();
});
</script>

<style scoped>
.team-attendance-view-container {
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
