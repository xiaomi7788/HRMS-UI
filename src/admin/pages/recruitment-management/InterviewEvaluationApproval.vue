<template>
  <div class="interview-evaluation-approval-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>面试评价与录用审批</span>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="候选人姓名">
          <el-input v-model="searchForm.candidateName" placeholder="请输入候选人姓名"></el-input>
        </el-form-item>
        <el-form-item label="应聘职位">
          <el-input v-model="searchForm.position" placeholder="请输入应聘职位"></el-input>
        </el-form-item>
        <el-form-item label="审批状态">
          <el-select v-model="searchForm.approvalStatus" placeholder="请选择审批状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待审批" value="待审批"></el-option>
            <el-option label="已通过" value="已通过"></el-option>
            <el-option label="已拒绝" value="已拒绝"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="evaluations" style="width: 100%" border>
        <el-table-column prop="candidateName" label="候选人姓名"></el-table-column>
        <el-table-column prop="position" label="应聘职位"></el-table-column>
        <el-table-column prop="interviewer" label="面试官"></el-table-column>
        <el-table-column prop="interviewDate" label="面试日期"></el-table-column>
        <el-table-column prop="evaluationScore" label="评价得分"></el-table-column>
        <el-table-column prop="approvalStatus" label="审批状态">
          <template #default="{ row }">
            <el-tag :type="getApprovalStatusTag(row.approvalStatus)">{{ row.approvalStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <div style="display: flex; gap: 5px;">
              <el-button size="small" @click="handleView(scope.row)">查看评价</el-button>
              <el-button
                v-if="scope.row.approvalStatus === '待审批'"
                size="small"
                type="success"
                @click="handleApprove(scope.row)"
              >通过</el-button>
              <el-button
                v-if="scope.row.approvalStatus === '待审批'"
                size="small"
                type="danger"
                @click="handleReject(scope.row)"
              >拒绝</el-button>
            </div>
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

    <!-- 查看评价详情的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="面试评价详情"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEvaluation" label-width="100px">
        <el-form-item label="候选人姓名">{{ currentEvaluation.candidateName }}</el-form-item>
        <el-form-item label="应聘职位">{{ currentEvaluation.position }}</el-form-item>
        <el-form-item label="面试官">{{ currentEvaluation.interviewer }}</el-form-item>
        <el-form-item label="面试日期">{{ currentEvaluation.interviewDate }}</el-form-item>
        <el-form-item label="评价得分">{{ currentEvaluation.evaluationScore }}</el-form-item>
        <el-form-item label="评价意见">{{ currentEvaluation.evaluationComments }}</el-form-item>
        <el-form-item label="审批状态">
          <el-tag :type="getApprovalStatusTag(currentEvaluation.approvalStatus)">
            {{ currentEvaluation.approvalStatus }}
          </el-tag>
        </el-form-item>
        <el-form-item v-if="currentEvaluation.approvalComments" label="审批意见">
          {{ currentEvaluation.approvalComments }}
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

interface InterviewEvaluation {
  id: number;
  candidateName: string;
  position: string;
  interviewer: string;
  interviewDate: string;
  evaluationScore: number;
  evaluationComments: string;
  approvalStatus: '待审批' | '已通过' | '已拒绝';
  approvalComments?: string;
}

const allEvaluations: InterviewEvaluation[] = [
  { id: 1, candidateName: '张小明', position: '高级前端工程师', interviewer: '李工程师', interviewDate: '2024-03-20', evaluationScore: 90, evaluationComments: '技术扎实，沟通良好', approvalStatus: '待审批' },
  { id: 2, candidateName: '李丽', position: '市场营销专员', interviewer: '王HR', interviewDate: '2024-03-22', evaluationScore: 85, evaluationComments: '有创意，积极主动', approvalStatus: '已通过', approvalComments: '同意录用' },
  { id: 3, candidateName: '王大锤', position: '销售经理', interviewer: '陈总', interviewDate: '2024-03-18', evaluationScore: 95, evaluationComments: '经验丰富，领导力强', approvalStatus: '已通过', approvalComments: '立即办理入职' },
  { id: 4, candidateName: '赵敏', position: '人力资源专员', interviewer: '孙经理', interviewDate: '2024-03-21', evaluationScore: 60, evaluationComments: '经验不足，与岗位要求不符', approvalStatus: '已拒绝', approvalComments: '不予录用' },
];

const evaluations = ref<InterviewEvaluation[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const currentEvaluation = ref<InterviewEvaluation>({
  id: 0,
  candidateName: '',
  position: '',
  interviewer: '',
  interviewDate: '',
  evaluationScore: 0,
  evaluationComments: '',
  approvalStatus: '待审批',
});

const searchForm = ref({
  candidateName: '',
  position: '',
  approvalStatus: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allEvaluations;

  if (searchForm.value.candidateName) {
    filteredRecords = filteredRecords.filter(evaluation =>
      evaluation.candidateName.includes(searchForm.value.candidateName)
    );
  }
  if (searchForm.value.position) {
    filteredRecords = filteredRecords.filter(evaluation =>
      evaluation.position.includes(searchForm.value.position)
    );
  }
  if (searchForm.value.approvalStatus) {
    filteredRecords = filteredRecords.filter(evaluation =>
      evaluation.approvalStatus === searchForm.value.approvalStatus
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  evaluations.value = filteredRecords.slice(start, end);
};

const getApprovalStatusTag = (status: string) => {
  switch (status) {
    case '待审批':
      return 'warning';
    case '已通过':
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
    candidateName: '',
    position: '',
    approvalStatus: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: InterviewEvaluation) => {
  currentEvaluation.value = { ...row };
  dialogVisible.value = true;
};

const handleApprove = (row: InterviewEvaluation) => {
  ElMessageBox.prompt('请输入审批意见', '通过审批', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      // 模拟审批通过操作
      row.approvalStatus = '已通过';
      row.approvalComments = value;
      ElMessage.success('审批已通过！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消审批');
    });
};

const handleReject = (row: InterviewEvaluation) => {
  ElMessageBox.prompt('请输入拒绝理由', '拒绝审批', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      // 模拟审批拒绝操作
      row.approvalStatus = '已拒绝';
      row.approvalComments = value;
      ElMessage.success('审批已拒绝！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消审批');
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
.interview-evaluation-approval-container {
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
