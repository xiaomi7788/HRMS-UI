<template>
  <div class="personal-flow-center-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>个人流程中心</span>
        </div>
      </template>
      <el-tabs v-model="activeTab" class="flow-tabs">
        <el-tab-pane label="我的申请" name="myApplications">
          <el-table :data="myApplications" style="width: 100%" border>
            <el-table-column prop="type" label="类型" width="100"></el-table-column>
            <el-table-column prop="title" label="标题"></el-table-column>
            <el-table-column prop="applyDate" label="申请日期" width="120"></el-table-column>
            <el-table-column prop="status" label="审批状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getApprovalStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewApplicationDetail(row)">查看</el-button>
                <el-button link type="danger" size="small" @click="withdrawApplication(row)" :disabled="row.status !== '待审批'">撤回</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="totalApplications"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
            background
            class="pagination-container"
          />
        </el-tab-pane>
        <el-tab-pane label="审批进度查看" name="approvalProgress">
          <el-timeline style="max-width: 600px">
            <el-timeline-item
              v-for="(activity, index) in approvalProgress"
              :key="index"
              :timestamp="activity.timestamp"
              :type="activity.type"
              :hollow="activity.hollow"
            >
              {{ activity.content }}
            </el-timeline-item>
          </el-timeline>
        </el-tab-pane>
        <el-tab-pane label="审批历史记录" name="approvalHistory">
          <el-table :data="approvalHistory" style="width: 100%" border>
            <el-table-column prop="type" label="类型" width="100"></el-table-column>
            <el-table-column prop="title" label="标题"></el-table-column>
            <el-table-column prop="applicant" label="申请人" width="100"></el-table-column>
            <el-table-column prop="applyDate" label="申请日期" width="120"></el-table-column>
            <el-table-column prop="status" label="审批结果" width="100">
              <template #default="{ row }">
                <el-tag :type="getApprovalStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="80">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewApplicationDetail(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="historyCurrentPage"
            v-model:page-size="historyPageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="totalHistory"
            @size-change="handleHistorySizeChange"
            @current-change="handleHistoryCurrentChange"
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

const activeTab = ref('myApplications');

// 我的申请
const myApplications = ref([
  { id: 1, type: '请假', title: '年假申请', applyDate: '2023-10-26', status: '待审批' },
  { id: 2, type: '加班', title: '项目加班', applyDate: '2023-10-25', status: '已通过' },
  { id: 3, type: '调休', title: '加班调休', applyDate: '2023-10-24', status: '已拒绝' },
  { id: 4, type: '请假', title: '病假申请', applyDate: '2023-10-23', status: '已通过' },
]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalApplications = ref(myApplications.value.length);

const viewApplicationDetail = (row: any) => {
  ElMessage.info(`查看申请详情: ${row.title}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const withdrawApplication = (row: any) => {
  ElMessage.warning(`撤回申请: ${row.title}`);
  // 实际应用中会调用API撤回申请
  row.status = '已撤回'; // 模拟状态更新
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  // 重新获取数据
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  // 重新获取数据
};

// 审批进度查看
const approvalProgress = ref([
  { content: '提交请假申请', timestamp: '2023-10-26 10:00', type: 'primary', hollow: false },
  { content: '部门经理审批通过', timestamp: '2023-10-26 14:30', type: 'success', hollow: false },
  { content: 'HR审批中', timestamp: '2023-10-27 09:00', type: 'warning', hollow: true },
]);

// 审批历史记录
const approvalHistory = ref([
  { id: 1, type: '请假', title: '年假申请', applicant: '张三', applyDate: '2023-09-10', status: '已通过' },
  { id: 2, type: '加班', title: '紧急项目加班', applicant: '李四', applyDate: '2023-09-05', status: '已通过' },
  { id: 3, type: '调休', title: '个人调休', applicant: '王五', applyDate: '2023-08-20', status: '已拒绝' },
]);
const historyCurrentPage = ref(1);
const historyPageSize = ref(10);
const totalHistory = ref(approvalHistory.value.length);

const handleHistorySizeChange = (val: number) => {
  historyPageSize.value = val;
  // 重新获取数据
};

const handleHistoryCurrentChange = (val: number) => {
  historyCurrentPage.value = val;
  // 重新获取数据
};

const getApprovalStatusType = (status: string) => {
  switch (status) {
    case '待审批': return 'warning';
    case '已通过': return 'success';
    case '已拒绝':
    case '已撤回': return 'danger';
    default: return '';
  }
};

onMounted(() => {
  // 模拟数据加载
});
</script>

<style scoped>
.personal-flow-center-container {
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

.flow-tabs {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  justify-content: flex-end;
  display: flex;
}
</style>
