<template>
  <div class="monthly-attendance-report-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>月度考勤报表</span>
          <el-button type="primary" @click="handleExport">导出报表</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="月份">
          <el-date-picker
            v-model="searchForm.month"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="attendanceReports" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="month" label="月份"></el-table-column>
        <el-table-column prop="totalWorkDays" label="应出勤天数"></el-table-column>
        <el-table-column prop="actualWorkDays" label="实际出勤天数"></el-table-column>
        <el-table-column prop="lateCount" label="迟到次数"></el-table-column>
        <el-table-column prop="earlyLeaveCount" label="早退次数"></el-table-column>
        <el-table-column prop="absentDays" label="缺勤天数"></el-table-column>
        <el-table-column prop="leaveDays" label="请假天数"></el-table-column>
        <el-table-column prop="overtimeHours" label="加班时长(小时)"></el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看详情</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="totalRecords"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        ></el-pagination>
      </div>
    </el-card>

    <!-- 报表详情对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="月度考勤详情"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentReport" label-width="120px">
        <el-form-item label="员工姓名">{{ currentReport.employeeName }}</el-form-item>
        <el-form-item label="月份">{{ currentReport.month }}</el-form-item>
        <el-form-item label="应出勤天数">{{ currentReport.totalWorkDays }}</el-form-item>
        <el-form-item label="实际出勤天数">{{ currentReport.actualWorkDays }}</el-form-item>
        <el-form-item label="迟到次数">{{ currentReport.lateCount }}</el-form-item>
        <el-form-item label="早退次数">{{ currentReport.earlyLeaveCount }}</el-form-item>
        <el-form-item label="缺勤天数">{{ currentReport.absentDays }}</el-form-item>
        <el-form-item label="请假天数">{{ currentReport.leaveDays }}</el-form-item>
        <el-form-item label="加班时长(小时)">{{ currentReport.overtimeHours }}</el-form-item>
        <el-form-item label="备注">{{ currentReport.notes }}</el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';

interface AttendanceReport {
  id: number;
  employeeName: string;
  month: string;
  totalWorkDays: number;
  actualWorkDays: number;
  lateCount: number;
  earlyLeaveCount: number;
  absentDays: number;
  leaveDays: number;
  overtimeHours: number;
  notes: string;
}

const allAttendanceReports: AttendanceReport[] = [
  { id: 1, employeeName: '张三', month: '2024-03', totalWorkDays: 22, actualWorkDays: 20, lateCount: 2, earlyLeaveCount: 0, absentDays: 0, leaveDays: 2, overtimeHours: 5, notes: '3月考勤正常' },
  { id: 2, employeeName: '李四', month: '2024-03', totalWorkDays: 22, actualWorkDays: 21, lateCount: 0, earlyLeaveCount: 1, absentDays: 0, leaveDays: 1, overtimeHours: 3, notes: '3月考勤正常' },
  { id: 3, employeeName: '王五', month: '2024-03', totalWorkDays: 22, actualWorkDays: 18, lateCount: 1, earlyLeaveCount: 0, absentDays: 3, leaveDays: 0, overtimeHours: 0, notes: '3月有3天缺勤' },
];

const attendanceReports = ref<AttendanceReport[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const currentReport = ref<AttendanceReport>({
  id: 0,
  employeeName: '',
  month: '',
  totalWorkDays: 0,
  actualWorkDays: 0,
  lateCount: 0,
  earlyLeaveCount: 0,
  absentDays: 0,
  leaveDays: 0,
  overtimeHours: 0,
  notes: '',
});

const searchForm = ref({
  employeeName: '',
  month: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredReports = allAttendanceReports;

  if (searchForm.value.employeeName) {
    filteredReports = filteredReports.filter(report =>
      report.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.month) {
    filteredReports = filteredReports.filter(report =>
      report.month === searchForm.value.month
    );
  }

  totalRecords.value = filteredReports.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  attendanceReports.value = filteredReports.slice(start, end);
};

const handleExport = () => {
  ElMessage.success('模拟导出报表成功！');
  // 实际项目中会触发文件下载
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    employeeName: '',
    month: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: AttendanceReport) => {
  currentReport.value = { ...row };
  dialogVisible.value = true;
};

const handleCloseDialog = () => {
  dialogVisible.value = false;
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchRecords();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchRecords();
};
</script>

<style scoped>
.monthly-attendance-report-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
  padding: 20px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
