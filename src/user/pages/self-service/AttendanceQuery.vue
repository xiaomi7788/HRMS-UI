<template>
  <div class="attendance-query-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>考勤查询</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="月份">
          <el-date-picker
            v-model="queryForm.month"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchAttendanceData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-tabs v-model="activeTab" class="attendance-tabs">
        <el-tab-pane label="每日考勤" name="daily">
          <el-table :data="dailyAttendanceData" style="width: 100%" border v-loading="loading">
            <el-table-column prop="date" label="日期" width="120"></el-table-column>
            <el-table-column prop="signInTime" label="签到时间" width="120"></el-table-column>
            <el-table-column prop="signOutTime" label="签退时间" width="120"></el-table-column>
            <el-table-column prop="status" label="状态">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注"></el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="月度统计" name="monthly">
          <el-descriptions
            class="margin-top"
            :column="3"
            border
          >
            <el-descriptions-item label="出勤天数">{{ monthlyStats.attendanceDays }}天</el-descriptions-item>
            <el-descriptions-item label="迟到次数">{{ monthlyStats.lateCount }}次</el-descriptions-item>
            <el-descriptions-item label="早退次数">{{ monthlyStats.earlyLeaveCount }}次</el-descriptions-item>
            <el-descriptions-item label="缺勤天数">{{ monthlyStats.absenceDays }}天</el-descriptions-item>
            <el-descriptions-item label="加班时长">{{ monthlyStats.overtimeHours }}小时</el-descriptions-item>
            <el-descriptions-item label="请假天数">{{ monthlyStats.leaveDays }}天</el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>
        <el-tab-pane label="加班记录" name="overtime">
          <el-table :data="overtimeRecords" style="width: 100%" border v-loading="loading">
            <el-table-column prop="date" label="日期" width="120"></el-table-column>
            <el-table-column prop="startTime" label="开始时间" width="120"></el-table-column>
            <el-table-column prop="endTime" label="结束时间" width="120"></el-table-column>
            <el-table-column prop="duration" label="时长(小时)" width="100"></el-table-column>
            <el-table-column prop="reason" label="原因"></el-table-column>
            <el-table-column prop="status" label="审批状态">
              <template #default="{ row }">
                <el-tag :type="getApprovalStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>

      <el-pagination
        v-if="activeTab === 'daily'"
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="totalDaily"
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
const activeTab = ref('daily');

const queryForm = reactive({
  month: new Date().toISOString().slice(0, 7), // YYYY-MM
});

const dailyAttendanceData = ref([
  // 模拟数据
  { date: '2023-10-01', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
  { date: '2023-10-02', signInTime: '09:15', signOutTime: '18:00', status: '迟到', remark: '交通堵塞' },
  { date: '2023-10-03', signInTime: '09:00', signOutTime: '17:45', status: '早退', remark: '提前离岗' },
  { date: '2023-10-04', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
  { date: '2023-10-05', signInTime: '', signOutTime: '', status: '缺勤', remark: '未打卡' },
  { date: '2023-10-06', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
  { date: '2023-10-07', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
  { date: '2023-10-08', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
  { date: '2023-10-09', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
  { date: '2023-10-10', signInTime: '09:00', signOutTime: '18:00', status: '正常', remark: '' },
]);

const monthlyStats = reactive({
  attendanceDays: 20,
  lateCount: 2,
  earlyLeaveCount: 1,
  absenceDays: 1,
  overtimeHours: 10,
  leaveDays: 2,
});

const overtimeRecords = ref([
  // 模拟数据
  { date: '2023-10-15', startTime: '18:00', endTime: '20:00', duration: 2, reason: '项目紧急', status: '已通过' },
  { date: '2023-10-20', startTime: '18:00', endTime: '21:00', duration: 3, reason: '需求变更', status: '待审批' },
]);

const currentPage = ref(1);
const pageSize = ref(10);
const totalDaily = ref(dailyAttendanceData.value.length);

const getStatusType = (status: string) => {
  switch (status) {
    case '正常': return 'success';
    case '迟到':
    case '早退': return 'warning';
    case '缺勤': return 'danger';
    default: return '';
  }
};

const getApprovalStatusType = (status: string) => {
  switch (status) {
    case '已通过': return 'success';
    case '待审批': return 'warning';
    case '已拒绝': return 'danger';
    default: return '';
  }
};

const fetchAttendanceData = () => {
  loading.value = true;
  // 模拟 API 请求
  setTimeout(() => {
    ElMessage.success(`查询 ${queryForm.month} 考勤数据成功！`);
    // 根据查询条件过滤数据，这里只是模拟
    totalDaily.value = dailyAttendanceData.value.length;
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.month = new Date().toISOString().slice(0, 7);
  fetchAttendanceData();
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchAttendanceData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchAttendanceData();
};

onMounted(() => {
  fetchAttendanceData();
});
</script>

<style scoped>
.attendance-query-container {
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

.attendance-tabs {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  justify-content: flex-end;
  display: flex;
}
</style>
