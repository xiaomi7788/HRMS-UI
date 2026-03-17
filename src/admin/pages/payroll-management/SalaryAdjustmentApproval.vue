<template>
  <div class="salary-adjustment-approval-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>薪酬调整审批</span>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="申请日期">
          <el-date-picker
            v-model="searchForm.applicationDateRange"
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

      <el-table :data="adjustmentApplications" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="applicationDate" label="申请日期"></el-table-column>
        <el-table-column prop="originalSalary" label="原薪资"></el-table-column>
        <el-table-column prop="adjustedSalary" label="调整后薪资"></el-table-column>
        <el-table-column prop="reason" label="调整原因"></el-table-column>
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

    <!-- 薪酬调整详情对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="薪酬调整详情"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentApplication" label-width="120px">
        <el-form-item label="员工姓名">{{ currentApplication.employeeName }}</el-form-item>
        <el-form-item label="申请日期">{{ currentApplication.applicationDate }}</el-form-item>
        <el-form-item label="原薪资">{{ currentApplication.originalSalary }}</el-form-item>
        <el-form-item label="调整后薪资">{{ currentApplication.adjustedSalary }}</el-form-item>
        <el-form-item label="调整原因">{{ currentApplication.reason }}</el-form-item>
        <el-form-item label="审批状态">
          <el-tag :type="getApprovalStatusTag(currentApplication.approvalStatus)">
            {{ currentApplication.approvalStatus }}
          </el-tag>
        </el-form-item>
        <el-form-item v-if="currentApplication.approvalComments" label="审批意见">
          {{ currentApplication.approvalComments }}
        </el-form-item>
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
import { ElMessage, ElMessageBox } from 'element-plus';

interface SalaryAdjustmentApplication {
  id: number;
  employeeName: string;
  applicationDate: string;
  originalSalary: number;
  adjustedSalary: number;
  reason: string;
  approvalStatus: '待审批' | '已批准' | '已拒绝';
  approvalComments?: string;
}

const allAdjustmentApplications: SalaryAdjustmentApplication[] = [
  { id: 1, employeeName: '张三', applicationDate: '2024-03-10', originalSalary: 8000, adjustedSalary: 9000, reason: '绩效优秀，晋升', approvalStatus: '待审批' },
  { id: 2, employeeName: '李四', applicationDate: '2024-03-05', originalSalary: 12000, adjustedSalary: 13000, reason: '岗位职责增加', approvalStatus: '已批准', approvalComments: '同意调整' },
  { id: 3, employeeName: '王五', applicationDate: '2024-03-01', originalSalary: 6000, adjustedSalary: 6000, reason: '试用期评估未通过', approvalStatus: '已拒绝', approvalComments: '暂不调整' },
];

const adjustmentApplications = ref<SalaryAdjustmentApplication[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const currentApplication = ref<SalaryAdjustmentApplication>({
  id: 0,
  employeeName: '',
  applicationDate: '',
  originalSalary: 0,
  adjustedSalary: 0,
  reason: '',
  approvalStatus: '待审批',
});

const searchForm = ref({
  employeeName: '',
  applicationDateRange: [],
  approvalStatus: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allAdjustmentApplications;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(app =>
      app.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.applicationDateRange && searchForm.value.applicationDateRange.length === 2) {
    const [startDate, endDate] = searchForm.value.applicationDateRange;
    filteredRecords = filteredRecords.filter(app => {
      const appDate = new Date(app.applicationDate);
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
  adjustmentApplications.value = filteredRecords.slice(start, end);
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

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    employeeName: '',
    applicationDateRange: [],
    approvalStatus: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: SalaryAdjustmentApplication) => {
  currentApplication.value = { ...row };
  dialogVisible.value = true;
};

const handleApprove = (row: SalaryAdjustmentApplication) => {
  ElMessageBox.prompt('请输入审批意见', '批准薪酬调整', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.approvalStatus = '已批准';
      row.approvalComments = value;
      ElMessage.success('薪酬调整已批准！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消批准');
    });
};

const handleReject = (row: SalaryAdjustmentApplication) => {
  ElMessageBox.prompt('请输入拒绝理由', '拒绝薪酬调整', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.approvalStatus = '已拒绝';
      row.approvalComments = value;
      ElMessage.success('薪酬调整已拒绝！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消拒绝');
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
.salary-adjustment-approval-container {
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
