<template>
  <div class="overtime-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>加班申请与核算</span>
          <el-button type="primary" @click="handleAdd">新增加班申请</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="加班日期">
          <el-date-picker
            v-model="searchForm.overtimeDateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="审批状态">
          <el-select v-model="searchForm.approvalStatus" placeholder="请选择审批状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待审批" value="待审批"></el-option>
            <el-option label="已批准" value="已批准"></el-option>
            <el-option label="已拒绝" value="已拒绝"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="overtimeApplications" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="overtimeDate" label="加班日期"></el-table-column>
        <el-table-column prop="startTime" label="开始时间"></el-table-column>
        <el-table-column prop="endTime" label="结束时间"></el-table-column>
        <el-table-column prop="hours" label="加班时长(小时)"></el-table-column>
        <el-table-column prop="reason" label="加班事由"></el-table-column>
        <el-table-column prop="approvalStatus" label="审批状态">
          <template #default="{ row }">
            <el-tag :type="getApprovalStatusTag(row.approvalStatus)">{{ row.approvalStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.approvalStatus === '待审批'"
              size="small"
              type="success"
              @click="handleApprove(scope.row)"
            >批准</el-button>
            <el-button
              v-if="scope.row.approvalStatus === '待审批'"
              size="small"
              type="danger"
              @click="handleReject(scope.row)"
            >拒绝</el-button>
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

    <!-- 新增/编辑加班申请的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentApplication" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentApplication.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="加班日期">
          <el-date-picker v-model="currentApplication.overtimeDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="开始时间">
          <el-time-picker v-model="currentApplication.startTime" placeholder="选择时间"></el-time-picker>
        </el-form-item>
        <el-form-item label="结束时间">
          <el-time-picker v-model="currentApplication.endTime" placeholder="选择时间"></el-time-picker>
        </el-form-item>
        <el-form-item label="加班事由">
          <el-input type="textarea" v-model="currentApplication.reason"></el-input>
        </el-form-item>
        <el-form-item label="审批状态">
          <el-select v-model="currentApplication.approvalStatus" placeholder="请选择审批状态" popper-append-to-body>
            <el-option label="待审批" value="待审批"></el-option>
            <el-option label="已批准" value="已批准"></el-option>
            <el-option label="已拒绝" value="已拒绝"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item v-if="currentApplication.approvalComments" label="审批意见">
          <el-input type="textarea" v-model="currentApplication.approvalComments" :disabled="true"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface OvertimeApplication {
  id: number;
  employeeName: string;
  overtimeDate: string | Date | null;
  startTime: string | Date | null;
  endTime: string | Date | null;
  hours: number;
  reason: string;
  approvalStatus: '待审批' | '已批准' | '已拒绝';
  approvalComments?: string;
}

const allOvertimeApplications: OvertimeApplication[] = [
  { id: 1, employeeName: '张三', overtimeDate: '2024-03-20', startTime: '18:00', endTime: '20:00', hours: 2, reason: '项目紧急开发', approvalStatus: '待审批' },
  { id: 2, employeeName: '李四', overtimeDate: '2024-03-19', startTime: '19:00', endTime: '22:00', hours: 3, reason: '系统维护', approvalStatus: '已批准', approvalComments: '同意加班' },
  { id: 3, employeeName: '王五', overtimeDate: '2024-03-18', startTime: '18:30', endTime: '21:00', hours: 2.5, reason: '处理客户紧急问题', approvalStatus: '已拒绝', approvalComments: '非紧急情况，不予批准' },
];

const overtimeApplications = ref<OvertimeApplication[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentApplication = ref<OvertimeApplication>({
  id: 0,
  employeeName: '',
  overtimeDate: null,
  startTime: null,
  endTime: null,
  hours: 0,
  reason: '',
  approvalStatus: '待审批',
});

const searchForm = ref({
  employeeName: '',
  overtimeDateRange: [],
  approvalStatus: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allOvertimeApplications;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(app =>
      app.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.overtimeDateRange && searchForm.value.overtimeDateRange.length === 2) {
    const [startDate, endDate] = searchForm.value.overtimeDateRange;
    filteredRecords = filteredRecords.filter(app => {
      const appDate = new Date(app.overtimeDate as string);
      return appDate >= new Date(startDate) && appDate <= new Date(endDate);
    });
  }
  if (searchForm.value.approvalStatus) {
    filteredRecords = filteredRecords.filter(app =>
      app.approvalStatus === searchForm.value.approvalStatus
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  overtimeApplications.value = filteredRecords.slice(start, end);
};

const getApprovalStatusTag = (status: string) => {
  switch (status) {
    case '待审批':
      return 'warning';
    case '已批准':
      return 'success';
    case '已拒绝':
      return 'danger';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增加班申请';
  currentApplication.value = {
    id: 0,
    employeeName: '',
    overtimeDate: null,
    startTime: null,
    endTime: null,
    hours: 0,
    reason: '',
    approvalStatus: '待审批',
  };
  dialogVisible.value = true;
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    employeeName: '',
    overtimeDateRange: [],
    approvalStatus: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: OvertimeApplication) => {
  dialogTitle.value = '查看加班申请详情';
  // 将字符串时间转换为 Date 对象，以便 el-time-picker 正确显示
  currentApplication.value = {
    ...row,
    overtimeDate: row.overtimeDate ? new Date(row.overtimeDate) : null,
    startTime: row.startTime ? new Date(`2000-01-01T${row.startTime}`) : null,
    endTime: row.endTime ? new Date(`2000-01-01T${row.endTime}`) : null,
  };
  dialogVisible.value = true;
};

const handleApprove = (row: OvertimeApplication) => {
  ElMessageBox.prompt('请输入审批意见', '批准加班申请', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.approvalStatus = '已批准';
      row.approvalComments = value;
      ElMessage.success('加班申请已批准！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消批准');
    });
};

const handleReject = (row: OvertimeApplication) => {
  ElMessageBox.prompt('请输入拒绝理由', '拒绝加班申请', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.approvalStatus = '已拒绝';
      row.approvalComments = value;
      ElMessage.success('加班申请已拒绝！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消拒绝');
    });
};

const handleSubmit = () => {
  // 模拟计算加班时长
  let calculatedHours = 0;
  if (currentApplication.value.startTime instanceof Date && currentApplication.value.endTime instanceof Date) {
    const start = currentApplication.value.startTime;
    const end = currentApplication.value.endTime;
    const diff = (end.getTime() - start.getTime()) / (1000 * 60 * 60);
    calculatedHours = parseFloat(diff.toFixed(1));
  }
  currentApplication.value.hours = calculatedHours;

  // 将 Date 对象转换回字符串，以便与 mockData 格式一致
  const submittedApplication = {
    ...currentApplication.value,
    overtimeDate: currentApplication.value.overtimeDate instanceof Date ? currentApplication.value.overtimeDate.toISOString().slice(0, 10) : null,
    startTime: currentApplication.value.startTime instanceof Date ? currentApplication.value.startTime.toTimeString().slice(0, 5) : null,
    endTime: currentApplication.value.endTime instanceof Date ? currentApplication.value.endTime.toTimeString().slice(0, 5) : null,
  };

  if (submittedApplication.id === 0) {
    // 模拟新增
    const newId = Math.max(...allOvertimeApplications.map(app => app.id)) + 1;
    allOvertimeApplications.push({ ...submittedApplication, id: newId } as OvertimeApplication);
    ElMessage.success('新增成功！');
  } else {
    // 模拟编辑
    const index = allOvertimeApplications.findIndex(app => app.id === submittedApplication.id);
    if (index !== -1) {
      allOvertimeApplications[index] = submittedApplication as OvertimeApplication;
      ElMessage.success('编辑成功！');
    }
  }
  dialogVisible.value = false;
  fetchRecords();
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
.overtime-management-container {
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
