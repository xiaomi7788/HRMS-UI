<template>
  <div class="performance-evaluation-calibration-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>绩效评估与校准会议</span>
          <el-button type="primary" @click="handleAdd">新增评估</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="评估周期">
          <el-select v-model="currentEvaluation.period" placeholder="请选择评估周期" append-to-body>
            <el-option label="Q1 2024" value="Q1 2024"></el-option>
            <el-option label="Q2 2024" value="Q2 2024"></el-option>
            <el-option label="H1 2024" value="H1 2024"></el-option>
            <el-option label="2024年度" value="2024年度"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentEvaluation.status" placeholder="请选择状态" popper-append-to-body>
            <el-option label="全部" value=""></el-option>
            <el-option label="待评估" value="待评估"></el-option>
            <el-option label="已评估" value="已评估"></el-option>
            <el-option label="已校准" value="已校准"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="evaluations" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="period" label="评估周期"></el-table-column>
        <el-table-column prop="evaluator" label="评估人"></el-table-column>
        <el-table-column prop="evaluationDate" label="评估日期"></el-table-column>
        <el-table-column prop="score" label="得分"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button
              v-if="scope.row.status === '已评估'"
              size="small"
              type="primary"
              @click="handleCalibrate(scope.row)"
            >校准</el-button>
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

    <!-- 新增/编辑评估的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEvaluation" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentEvaluation.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="评估周期">
          <el-select v-model="currentEvaluation.period" placeholder="请选择评估周期">
            <el-option label="Q1 2024" value="Q1 2024"></el-option>
            <el-option label="Q2 2024" value="Q2 2024"></el-option>
            <el-option label="H1 2024" value="H1 2024"></el-option>
            <el-option label="2024年度" value="2024年度"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="评估人">
          <el-input v-model="currentEvaluation.evaluator"></el-input>
        </el-form-item>
        <el-form-item label="评估日期">
          <el-date-picker v-model="currentEvaluation.evaluationDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="得分">
          <el-input-number v-model="currentEvaluation.score" :min="0" :max="100"></el-input-number>
        </el-form-item>
        <el-form-item label="评估意见">
          <el-input type="textarea" v-model="currentEvaluation.comments" :rows="5"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentEvaluation.status" placeholder="请选择状态" popper-append-to-body>
            <el-option label="待评估" value="待评估"></el-option>
            <el-option label="已评估" value="已评估"></el-option>
            <el-option label="已校准" value="已校准"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item v-if="currentEvaluation.calibrationNotes" label="校准意见">
          <el-input type="textarea" v-model="currentEvaluation.calibrationNotes" :disabled="true"></el-input>
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

interface PerformanceEvaluation {
  id: number;
  employeeName: string;
  period: string;
  evaluator: string;
  evaluationDate: string;
  score: number;
  comments: string;
  status: '待评估' | '已评估' | '已校准';
  calibrationNotes?: string;
}

const allEvaluations: PerformanceEvaluation[] = [
  { id: 1, employeeName: '张三', period: 'Q1 2024', evaluator: '李经理', evaluationDate: '2024-03-20', score: 85, comments: '目标达成度良好，团队协作能力有待提升。', status: '已评估' },
  { id: 2, employeeName: '李四', period: 'Q1 2024', evaluator: '王总监', evaluationDate: '2024-03-22', score: 92, comments: '超额完成销售目标，表现突出。', status: '已校准', calibrationNotes: '调整为优秀等级' },
  { id: 3, employeeName: '王五', period: 'Q2 2024', evaluator: '赵导师', evaluationDate: '', score: 0, comments: '', status: '待评估' },
];

const evaluations = ref<PerformanceEvaluation[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentEvaluation = ref<PerformanceEvaluation>({
  id: 0,
  employeeName: '',
  period: '',
  evaluator: '',
  evaluationDate: '',
  score: 0,
  comments: '',
  status: '待评估',
});

const searchForm = ref({
  employeeName: '',
  period: '',
  status: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allEvaluations;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(evaluation =>
      evaluation.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.period) {
    filteredRecords = filteredRecords.filter(evaluation =>
      evaluation.period === searchForm.value.period
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(evaluation =>
      evaluation.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  evaluations.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '待评估':
      return 'info';
    case '已评估':
      return '';
    case '已校准':
      return 'success';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增绩效评估';
  currentEvaluation.value = {
    id: 0,
    employeeName: '',
    period: '',
    evaluator: '',
    evaluationDate: '',
    score: 0,
    comments: '',
    status: '待评估',
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
    period: '',
    status: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: PerformanceEvaluation) => {
  dialogTitle.value = '查看绩效评估详情';
  currentEvaluation.value = { ...row };
  dialogVisible.value = true;
};

const handleEdit = (row: PerformanceEvaluation) => {
  dialogTitle.value = '编辑绩效评估';
  currentEvaluation.value = { ...row };
  dialogVisible.value = true;
};

const handleCalibrate = (row: PerformanceEvaluation) => {
  ElMessageBox.prompt('请输入校准意见', '绩效校准', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputType: 'textarea',
  })
    .then(({ value }) => {
      row.status = '已校准';
      row.calibrationNotes = value;
      ElMessage.success('绩效已校准！');
      fetchRecords();
    })
    .catch(() => {
      ElMessage.info('已取消校准');
    });
};

const handleSubmit = () => {
  // 模拟保存操作
  if (currentEvaluation.value.id === 0) {
    ElMessage.success('新增成功！');
  } else {
    ElMessage.success('编辑成功！');
  }
  dialogVisible.value = false;
  fetchRecords(); // 重新加载数据
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
.performance-evaluation-calibration-container {
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
