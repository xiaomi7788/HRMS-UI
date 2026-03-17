<template>
  <div class="attendance-data-processing-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>考勤数据处理</span>
          <el-button type="primary" @click="handleImport">导入考勤数据</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="异常类型">
          <el-select v-model="searchForm.exceptionType" placeholder="请选择异常类型">
            <el-option label="全部" value=""></el-option>
            <el-option label="迟到" value="迟到"></el-option>
            <el-option label="早退" value="早退"></el-option>
            <el-option label="缺勤" value="缺勤"></el-option>
            <el-option label="未打卡" value="未打卡"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="attendanceRecords" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="date" label="日期"></el-table-column>
        <el-table-column prop="checkInTime" label="上班打卡"></el-table-column>
        <el-table-column prop="checkOutTime" label="下班打卡"></el-table-column>
        <el-table-column prop="exceptionType" label="异常类型">
          <template #default="{ row }">
            <el-tag v-if="row.exceptionType" :type="getExceptionTypeTag(row.exceptionType)">{{ row.exceptionType }}</el-tag>
            <span v-else>正常</span>
          </template>
        </el-table-column>
        <el-table-column prop="processingStatus" label="处理状态">
          <template #default="{ row }">
            <el-tag :type="getProcessingStatusTag(row.processingStatus)">{{ row.processingStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.exceptionType && scope.row.processingStatus === '待处理'"
              size="small"
              type="primary"
              @click="handleProcess(scope.row)"
            >处理</el-button>
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

    <!-- 处理考勤异常的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="处理考勤异常"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentRecord" label-width="100px">
        <el-form-item label="员工姓名">{{ currentRecord.employeeName }}</el-form-item>
        <el-form-item label="日期">{{ currentRecord.date }}</el-form-item>
        <el-form-item label="异常类型">
          <el-tag :type="getExceptionTypeTag(currentRecord.exceptionType)">{{ currentRecord.exceptionType }}</el-tag>
        </el-form-item>
        <el-form-item label="处理方式">
          <el-select v-model="currentRecord.processingMethod" placeholder="请选择处理方式">
            <el-option label="请假冲抵" value="请假冲抵"></el-option>
            <el-option label="加班冲抵" value="加班冲抵"></el-option>
            <el-option label="出差冲抵" value="出差冲抵"></el-option>
            <el-option label="无需处理" value="无需处理"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="处理说明">
          <el-input type="textarea" v-model="currentRecord.processingNotes"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmitProcessing">提交处理</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface AttendanceRecord {
  id: number;
  employeeName: string;
  date: string;
  checkInTime: string;
  checkOutTime: string;
  exceptionType: '迟到' | '早退' | '缺勤' | '未打卡' | '';
  processingStatus: '待处理' | '已处理';
  processingMethod?: string;
  processingNotes?: string;
}

const allAttendanceRecords: AttendanceRecord[] = [
  { id: 1, employeeName: '张三', date: '2024-03-01', checkInTime: '09:05', checkOutTime: '18:00', exceptionType: '迟到', processingStatus: '待处理' },
  { id: 2, employeeName: '李四', date: '2024-03-01', checkInTime: '09:00', checkOutTime: '17:50', exceptionType: '早退', processingStatus: '待处理' },
  { id: 3, employeeName: '王五', date: '2024-03-01', checkInTime: '09:00', checkOutTime: '18:00', exceptionType: '', processingStatus: '已处理' },
  { id: 4, employeeName: '赵六', date: '2024-03-02', checkInTime: '09:00', checkOutTime: '18:00', exceptionType: '未打卡', processingStatus: '待处理' },
  { id: 5, employeeName: '钱七', date: '2024-03-02', checkInTime: '09:00', checkOutTime: '18:00', exceptionType: '', processingStatus: '已处理' },
  { id: 6, employeeName: '孙八', date: '2024-03-03', checkInTime: '09:10', checkOutTime: '18:00', exceptionType: '迟到', processingStatus: '已处理', processingMethod: '请假冲抵', processingNotes: '因交通堵塞迟到，已提交请假申请' },
];

const attendanceRecords = ref<AttendanceRecord[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const currentRecord = ref<AttendanceRecord>({
  id: 0,
  employeeName: '',
  date: '',
  checkInTime: '',
  checkOutTime: '',
  exceptionType: '',
  processingStatus: '待处理',
});

const searchForm = ref({
  employeeName: '',
  dateRange: [],
  exceptionType: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allAttendanceRecords;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(record =>
      record.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
    const [startDate, endDate] = searchForm.value.dateRange;
    filteredRecords = filteredRecords.filter(record => {
      const recordDate = new Date(record.date);
      return recordDate >= new Date(startDate) && recordDate <= new Date(endDate);
    });
  }
  if (searchForm.value.exceptionType) {
    filteredRecords = filteredRecords.filter(record =>
      record.exceptionType === searchForm.value.exceptionType
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  attendanceRecords.value = filteredRecords.slice(start, end);
};

const getExceptionTypeTag = (type: string) => {
  switch (type) {
    case '迟到':
    case '早退':
    case '缺勤':
    case '未打卡':
      return 'danger';
    default:
      return '';
  }
};

const getProcessingStatusTag = (status: string) => {
  switch (status) {
    case '待处理':
      return 'warning';
    case '已处理':
      return 'success';
    default:
      return '';
  }
};

const handleImport = () => {
  ElMessage.info('模拟导入考勤数据');
  // 实际项目中会触发文件上传或API调用
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    employeeName: '',
    dateRange: [],
    exceptionType: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: AttendanceRecord) => {
  currentRecord.value = { ...row };
  dialogVisible.value = true;
};

const handleProcess = (row: AttendanceRecord) => {
  currentRecord.value = { ...row };
  dialogVisible.value = true;
};

const handleSubmitProcessing = () => {
  ElMessageBox.confirm('确定提交考勤异常处理吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟处理操作
      currentRecord.value.processingStatus = '已处理';
      ElMessage.success('处理成功！');
      dialogVisible.value = false;
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消处理');
    });
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
.attendance-data-processing-container {
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
