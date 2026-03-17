<template>
  <div class="leave-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>假期额度与申请流程管理</span>
          <el-button type="primary" @click="handleAddQuota">新增假期额度</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="假期类型">
          <el-select v-model="searchForm.leaveType" placeholder="请选择假期类型" :teleported="true">
            <el-option label="全部" value=""></el-option>
            <el-option label="年假" value="年假"></el-option>
            <el-option label="调休假" value="调休假"></el-option>
            <el-option label="病假" value="病假"></el-option>
            <el-option label="事假" value="事假"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="申请状态">
          <el-select v-model="searchForm.applicationStatus" placeholder="请选择申请状态">
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

      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane label="假期额度管理" name="quota">
          <el-table :data="leaveQuotas" style="width: 100%" border>
            <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
            <el-table-column prop="leaveType" label="假期类型"></el-table-column>
            <el-table-column prop="totalDays" label="总天数"></el-table-column>
            <el-table-column prop="usedDays" label="已用天数"></el-table-column>
            <el-table-column prop="remainingDays" label="剩余天数"></el-table-column>
            <el-table-column prop="validUntil" label="有效期至"></el-table-column>
            <el-table-column label="操作" width="150" fixed="right">
              <template #default="scope">
                <el-button size="small" @click="handleEditQuota(scope.row)">编辑</el-button>
                <el-button size="small" type="danger" @click="handleDeleteQuota(scope.row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="假期申请审批" name="applications">
          <el-table :data="leaveApplications" style="width: 100%" border>
            <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
            <el-table-column prop="leaveType" label="假期类型"></el-table-column>
            <el-table-column prop="startDate" label="开始日期"></el-table-column>
            <el-table-column prop="endDate" label="结束日期"></el-table-column>
            <el-table-column prop="days" label="天数"></el-table-column>
            <el-table-column prop="reason" label="请假事由"></el-table-column>
            <el-table-column prop="applicationStatus" label="申请状态">
              <template #default="{ row }">
                <el-tag :type="getApplicationStatusTag(row.applicationStatus)">{{ row.applicationStatus }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="scope">
                <el-button size="small" @click="handleViewApplication(scope.row)">查看</el-button>
                <el-button
                  v-if="scope.row.applicationStatus === '待审批'"
                  size="small"
                  type="success"
                  @click="handleApproveApplication(scope.row)"
                >批准</el-button>
                <el-button
                  v-if="scope.row.applicationStatus === '待审批'"
                  size="small"
                  type="danger"
                  @click="handleRejectApplication(scope.row)"
                >拒绝</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>

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

    <!-- 假期额度对话框 -->
    <el-dialog
      v-model="quotaDialogVisible"
      :title="quotaDialogTitle"
      width="40%"
      :before-close="handleCloseQuotaDialog"
    >
      <el-form :model="currentQuota" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentQuota.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="假期类型">
          <el-select v-model="currentQuota.leaveType" placeholder="请选择假期类型" :teleported="true">
            <el-option label="年假" value="年假"></el-option>
            <el-option label="调休假" value="调休假"></el-option>
            <el-option label="病假" value="病假"></el-option>
            <el-option label="事假" value="事假"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="总天数">
          <el-input-number v-model="currentQuota.totalDays" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="已用天数">
          <el-input-number v-model="currentQuota.usedDays" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="有效期至">
          <el-date-picker v-model="currentQuota.validUntil" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="quotaDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmitQuota">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 假期申请详情对话框 -->
    <el-dialog
      v-model="applicationDialogVisible"
      title="假期申请详情"
      width="50%"
      :before-close="handleCloseApplicationDialog"
    >
      <el-form :model="currentApplication" label-width="100px">
        <el-form-item label="员工姓名">{{ currentApplication.employeeName }}</el-form-item>
        <el-form-item label="假期类型">{{ currentApplication.leaveType }}</el-form-item>
        <el-form-item label="开始日期">{{ currentApplication.startDate }}</el-form-item>
        <el-form-item label="结束日期">{{ currentApplication.endDate }}</el-form-item>
        <el-form-item label="天数">{{ currentApplication.days }}</el-form-item>
        <el-form-item label="请假事由">{{ currentApplication.reason }}</el-form-item>
        <el-form-item label="申请状态">
          <el-tag :type="getApplicationStatusTag(currentApplication.applicationStatus)">
            {{ currentApplication.applicationStatus }}
          </el-tag>
        </el-form-item>
        <el-form-item v-if="currentApplication.approvalComments" label="审批意见">
          {{ currentApplication.approvalComments }}
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="applicationDialogVisible = false">关闭</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface LeaveQuota {
  id: number;
  employeeName: string;
  leaveType: string;
  totalDays: number;
  usedDays: number;
  remainingDays: number;
  validUntil: string;
}

interface LeaveApplication {
  id: number;
  employeeName: string;
  leaveType: string;
  startDate: string;
  endDate: string;
  days: number;
  reason: string;
  applicationStatus: '待审批' | '已批准' | '已拒绝';
  approvalComments?: string;
}

const allLeaveQuotas: LeaveQuota[] = [
  { id: 1, employeeName: '张三', leaveType: '年假', totalDays: 10, usedDays: 3, remainingDays: 7, validUntil: '2024-12-31' },
  { id: 2, employeeName: '李四', leaveType: '调休假', totalDays: 5, usedDays: 1, remainingDays: 4, validUntil: '2024-06-30' },
  { id: 3, employeeName: '王五', leaveType: '年假', totalDays: 15, usedDays: 0, remainingDays: 15, validUntil: '2024-12-31' },
];

const allLeaveApplications: LeaveApplication[] = [
  { id: 1, employeeName: '张三', leaveType: '年假', startDate: '2024-04-01', endDate: '2024-04-03', days: 3, reason: '个人事务', applicationStatus: '待审批' },
  { id: 2, employeeName: '李四', leaveType: '调休假', startDate: '2024-03-28', endDate: '2024-03-28', days: 1, reason: '加班调休', applicationStatus: '已批准', approvalComments: '同意调休' },
  { id: 3, employeeName: '王五', leaveType: '事假', startDate: '2024-04-05', endDate: '2024-04-05', days: 1, reason: '家里有事', applicationStatus: '待审批' },
];

const leaveQuotas = ref<LeaveQuota[]>([]);
const leaveApplications = ref<LeaveApplication[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const activeTab = ref('quota'); // 默认显示假期额度管理

const quotaDialogVisible = ref(false);
const quotaDialogTitle = ref('');
const currentQuota = ref<LeaveQuota>({
  id: 0,
  employeeName: '',
  leaveType: '年假',
  totalDays: 0,
  usedDays: 0,
  remainingDays: 0,
  validUntil: '',
});

const applicationDialogVisible = ref(false);
const currentApplication = ref<LeaveApplication>({
  id: 0,
  employeeName: '',
  leaveType: '',
  startDate: '',
  endDate: '',
  days: 0,
  reason: '',
  applicationStatus: '待审批',
});

const searchForm = ref({
  employeeName: '',
  leaveType: '',
  applicationStatus: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  // 假期额度
  let filteredQuotas = allLeaveQuotas;
  if (searchForm.value.employeeName) {
    filteredQuotas = filteredQuotas.filter(quota =>
      quota.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.leaveType) {
    filteredQuotas = filteredQuotas.filter(quota =>
      quota.leaveType === searchForm.value.leaveType
    );
  }
  leaveQuotas.value = filteredQuotas;

  // 假期申请
  let filteredApplications = allLeaveApplications;
  if (searchForm.value.employeeName) {
    filteredApplications = filteredApplications.filter(app =>
      app.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.leaveType) {
    filteredApplications = filteredApplications.filter(app =>
      app.leaveType === searchForm.value.leaveType
    );
  }
  if (searchForm.value.applicationStatus) {
    filteredApplications = filteredApplications.filter(app =>
      app.applicationStatus === searchForm.value.applicationStatus
    );
  }
  leaveApplications.value = filteredApplications;

  // 分页总数根据当前激活的tab来定
  totalRecords.value = activeTab.value === 'quota' ? leaveQuotas.value.length : leaveApplications.value.length;
};

const getApplicationStatusTag = (status: string) => {
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
    leaveType: '',
    applicationStatus: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

// 假期额度管理
const handleAddQuota = () => {
  quotaDialogTitle.value = '新增假期额度';
  currentQuota.value = {
    id: 0,
    employeeName: '',
    leaveType: '年假',
    totalDays: 0,
    usedDays: 0,
    remainingDays: 0,
    validUntil: '',
  };
  quotaDialogVisible.value = true;
};

const handleEditQuota = (row: LeaveQuota) => {
  quotaDialogTitle.value = '编辑假期额度';
  currentQuota.value = { ...row };
  quotaDialogVisible.value = true;
};

const handleDeleteQuota = (row: LeaveQuota) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} 的 ${row.leaveType} 额度吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      ElMessage.success('删除成功！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};

const handleSubmitQuota = () => {
  if (currentQuota.value.id === 0) {
    ElMessage.success('新增成功！');
  } else {
    ElMessage.success('编辑成功！');
  }
  quotaDialogVisible.value = false;
  fetchRecords();
};

const handleCloseQuotaDialog = () => {
  quotaDialogVisible.value = false;
};

// 假期申请审批
const handleViewApplication = (row: LeaveApplication) => {
  currentApplication.value = { ...row };
  applicationDialogVisible.value = true;
};

const handleApproveApplication = (row: LeaveApplication) => {
  ElMessageBox.prompt('请输入审批意见', '批准假期申请', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.applicationStatus = '已批准';
      row.approvalComments = value;
      ElMessage.success('假期申请已批准！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消批准');
    });
};

const handleRejectApplication = (row: LeaveApplication) => {
  ElMessageBox.prompt('请输入拒绝理由', '拒绝假期申请', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.applicationStatus = '已拒绝';
      row.approvalComments = value;
      ElMessage.success('假期申请已拒绝！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消拒绝');
    });
};

const handleCloseApplicationDialog = () => {
  applicationDialogVisible.value = false;
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
.leave-management-container {
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
