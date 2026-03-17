<template>
  <div class="manager-approval-center-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>审批中心</span>
        </div>
      </template>
      <el-tabs v-model="activeTab" class="approval-tabs">
        <el-tab-pane label="待我审批" name="pending">
          <el-table :data="pendingApprovals" style="width: 100%" border>
            <el-table-column prop="applicant" label="申请人" width="120"></el-table-column>
            <el-table-column prop="type" label="申请类型" width="100"></el-table-column>
            <el-table-column prop="title" label="标题"></el-table-column>
            <el-table-column prop="applyDate" label="申请日期" width="120"></el-table-column>
            <el-table-column label="操作" width="180">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewApprovalDetail(row)">查看</el-button>
                <el-button link type="success" size="small" @click="approveApplication(row)">通过</el-button>
                <el-button link type="danger" size="small" @click="rejectApplication(row)">驳回</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="pendingCurrentPage"
            v-model:page-size="pendingPageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="totalPending"
            @size-change="handlePendingSizeChange"
            @current-change="handlePendingCurrentChange"
            background
            class="pagination-container"
          />
        </el-tab-pane>
        <el-tab-pane label="已我审批" name="approved">
          <el-table :data="approvedApprovals" style="width: 100%" border>
            <el-table-column prop="applicant" label="申请人" width="120"></el-table-column>
            <el-table-column prop="type" label="申请类型" width="100"></el-table-column>
            <el-table-column prop="title" label="标题"></el-table-column>
            <el-table-column prop="applyDate" label="申请日期" width="120"></el-table-column>
            <el-table-column prop="status" label="审批结果" width="100">
              <template #default="{ row }">
                <el-tag :type="getApprovalStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewApprovalDetail(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="approvedCurrentPage"
            v-model:page-size="approvedPageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="totalApproved"
            @size-change="handleApprovedSizeChange"
            @current-change="handleApprovedCurrentChange"
            background
            class="pagination-container"
          />
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';

const activeTab = ref('pending');

// 待我审批
const pendingApprovals = ref([
  { id: 1, applicant: '张三', type: '请假', title: '年假申请', applyDate: '2023-11-01' },
  { id: 2, applicant: '李四', type: '加班', title: '项目紧急加班', applyDate: '2023-10-30' },
]);
const pendingCurrentPage = ref(1);
const pendingPageSize = ref(10);
const totalPending = ref(pendingApprovals.value.length);

const viewApprovalDetail = (row: any) => {
  ElMessage.info(`查看审批详情: ${row.title}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const approveApplication = (row: any) => {
  ElMessage.success(`已通过 ${row.applicant} 的 ${row.type} 申请: ${row.title}`);
  // 实际应用中会调用API更新审批状态
  // 模拟从待审批列表中移除，添加到已审批列表
  approvedApprovals.value.push({ ...row, status: '已通过' });
  pendingApprovals.value = pendingApprovals.value.filter(item => item.id !== row.id);
  totalPending.value = pendingApprovals.value.length;
  totalApproved.value = approvedApprovals.value.length;
};

const rejectApplication = (row: any) => {
  ElMessage.error(`已驳回 ${row.applicant} 的 ${row.type} 申请: ${row.title}`);
  // 实际应用中会调用API更新审批状态
  // 模拟从待审批列表中移除，添加到已审批列表
  approvedApprovals.value.push({ ...row, status: '已驳回' });
  pendingApprovals.value = pendingApprovals.value.filter(item => item.id !== row.id);
  totalPending.value = pendingApprovals.value.length;
  totalApproved.value = approvedApprovals.value.length;
};

const handlePendingSizeChange = (val: number) => {
  pendingPageSize.value = val;
  // 重新获取数据
};

const handlePendingCurrentChange = (val: number) => {
  pendingCurrentPage.value = val;
  // 重新获取数据
};

// 已我审批
const approvedApprovals = ref([
  { id: 3, applicant: '王五', type: '请假', title: '病假申请', applyDate: '2023-10-25', status: '已通过' },
  { id: 4, applicant: '赵六', type: '调休', title: '加班调休', applyDate: '2023-10-20', status: '已驳回' },
]);
const approvedCurrentPage = ref(1);
const approvedPageSize = ref(10);
const totalApproved = ref(approvedApprovals.value.length);

const handleApprovedSizeChange = (val: number) => {
  approvedPageSize.value = val;
  // 重新获取数据
};

const handleApprovedCurrentChange = (val: number) => {
  approvedCurrentPage.value = val;
  // 重新获取数据
};

const getApprovalStatusType = (status: string) => {
  switch (status) {
    case '已通过': return 'success';
    case '已驳回': return 'danger';
    default: return '';
  }
};

onMounted(() => {
  // 模拟数据加载
});
</script>

<style scoped>
.manager-approval-center-container {
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

.approval-tabs {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  justify-content: flex-end;
  display: flex;
}
</style>
