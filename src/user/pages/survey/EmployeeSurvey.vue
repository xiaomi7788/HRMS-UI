<template>
  <div class="employee-survey-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工调查与问卷</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="问卷名称">
          <el-input v-model="queryForm.surveyName" placeholder="请输入问卷名称"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryForm.status" placeholder="选择状态" popper-append-to-body>
            <el-option label="全部" value=""></el-option>
            <el-option label="进行中" value="in_progress"></el-option>
            <el-option label="已完成" value="completed"></el-option>
            <el-option label="未开始" value="not_started"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchSurveyData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="surveyData" style="width: 100%" border v-loading="loading">
        <el-table-column prop="surveyName" label="问卷名称"></el-table-column>
        <el-table-column prop="publishDate" label="发布日期"></el-table-column>
        <el-table-column prop="endDate" label="截止日期"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleParticipate(row)" v-if="row.status === 'in_progress'">参与</el-button>
            <el-button link type="info" size="small" @click="handleViewResult(row)" v-if="row.status === 'completed'">查看结果</el-button>
            <el-button link type="info" size="small" @click="handleViewDetails(row)">查看详情</el-button>
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
import { ElMessage, ElMessageBox } from 'element-plus';

const loading = ref(false);
const queryForm = reactive({
  surveyName: '',
  status: '',
});

const surveyData = ref([
  { id: 1, surveyName: '员工满意度调查', publishDate: '2023-03-01', endDate: '2023-03-15', status: 'completed' },
  { id: 2, surveyName: '公司文化建设问卷', publishDate: '2023-05-10', endDate: '2023-05-30', status: 'in_progress' },
  { id: 3, surveyName: '福利待遇意见征集', publishDate: '2023-07-01', endDate: '2023-07-15', status: 'not_started' },
  { id: 4, surveyName: '年度培训需求调研', publishDate: '2023-09-01', endDate: '2023-09-30', status: 'in_progress' },
]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(surveyData.value.length);

const getStatusText = (status: string) => {
  switch (status) {
    case 'in_progress':
      return '进行中';
    case 'completed':
      return '已完成';
    case 'not_started':
      return '未开始';
    default:
      return '未知';
  }
};

const getStatusType = (status: string) => {
  switch (status) {
    case 'in_progress':
      return 'primary';
    case 'completed':
      return 'success';
    case 'not_started':
      return 'info';
    default:
      return 'default';
  }
};

const fetchSurveyData = () => {
  loading.value = true;
  // 模拟 API 请求
  setTimeout(() => {
    ElMessage.success('查询问卷数据成功！');
    // 根据查询条件过滤数据，这里只是模拟
    total.value = surveyData.value.length;
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.surveyName = '';
  queryForm.status = '';
  fetchSurveyData();
};

const handleParticipate = (row: any) => {
  ElMessageBox.alert(`您将参与问卷 “${row.surveyName}”。`, '参与问卷', {
    confirmButtonText: '确定',
    callback: () => {
      ElMessage.success(`已开始参与 “${row.surveyName}”`);
      // 实际操作中会跳转到问卷填写页面
    },
  });
};

const handleViewResult = (row: any) => {
  ElMessageBox.alert(`查看问卷 “${row.surveyName}” 的结果。`, '查看结果', {
    confirmButtonText: '确定',
    callback: () => {
      ElMessage.info(`正在查看 “${row.surveyName}” 的结果`);
      // 实际操作中会跳转到问卷结果页面
    },
  });
};

const handleViewDetails = (row: any) => {
  ElMessageBox.alert(`
    <p><strong>问卷名称:</strong> ${row.surveyName}</p>
    <p><strong>发布日期:</strong> ${row.publishDate}</p>
    <p><strong>截止日期:</strong> ${row.endDate}</p>
    <p><strong>状态:</strong> ${getStatusText(row.status)}</p>
  `, '问卷详情', {
    dangerouslyUseHTMLString: true,
    confirmButtonText: '确定',
  });
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchSurveyData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchSurveyData();
};

onMounted(() => {
  fetchSurveyData();
});
</script>

<style scoped>
.employee-survey-container {
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
