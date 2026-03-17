<template>
  <div class="performance-result-improvement-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>绩效结果应用与改进计划</span>
          <el-button type="primary" @click="handleAdd">新增改进计划</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="评估周期">
          <el-select v-model="searchForm.period" placeholder="请选择评估周期" popper-append-to-body>
            <el-option label="全部" value=""></el-option>
            <el-option label="Q1 2024" value="Q1 2024"></el-option>
            <el-option label="Q2 2024" value="Q2 2024"></el-option>
            <el-option label="H1 2024" value="H1 2024"></el-option>
            <el-option label="2024年度" value="2024年度"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待制定" value="待制定"></el-option>
            <el-option label="进行中" value="进行中"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="improvementPlans" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="period" label="评估周期"></el-table-column>
        <el-table-column prop="performanceResult" label="绩效结果"></el-table-column>
        <el-table-column prop="improvementPlan" label="改进计划"></el-table-column>
        <el-table-column prop="startDate" label="开始日期"></el-table-column>
        <el-table-column prop="endDate" label="结束日期"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
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

    <!-- 新增/编辑改进计划的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentPlan" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentPlan.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="评估周期">
          <el-select v-model="currentPlan.period" placeholder="请选择评估周期" append-to-body>
            <el-option label="Q1 2024" value="Q1 2024"></el-option>
            <el-option label="Q2 2024" value="Q2 2024"></el-option>
            <el-option label="H1 2024" value="H1 2024"></el-option>
            <el-option label="2024年度" value="2024年度"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="绩效结果">
          <el-input v-model="currentPlan.performanceResult"></el-input>
        </el-form-item>
        <el-form-item label="改进计划">
          <el-input type="textarea" v-model="currentPlan.improvementPlan" :rows="5"></el-input>
        </el-form-item>
        <el-form-item label="开始日期">
          <el-date-picker v-model="currentPlan.startDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker v-model="currentPlan.endDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentPlan.status" placeholder="请选择状态" popper-append-to-body>
            <el-option label="待制定" value="待制定"></el-option>
            <el-option label="进行中" value="进行中"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
          </el-select>
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

interface ImprovementPlan {
  id: number;
  employeeName: string;
  period: string;
  performanceResult: string;
  improvementPlan: string;
  startDate: string;
  endDate: string;
  status: '待制定' | '进行中' | '已完成';
}

const allImprovementPlans: ImprovementPlan[] = [
  { id: 1, employeeName: '张三', period: 'Q1 2024', performanceResult: '良好', improvementPlan: '提升团队协作能力，参与相关培训。', startDate: '2024-04-01', endDate: '2024-06-30', status: '进行中' },
  { id: 2, employeeName: '李四', period: 'Q1 2024', performanceResult: '优秀', improvementPlan: '分享销售经验，带领新员工成长。', startDate: '2024-04-01', endDate: '2024-06-30', status: '已完成' },
  { id: 3, employeeName: '王五', period: 'Q2 2024', performanceResult: '待改进', improvementPlan: '深入学习新技术，完成技术分享。', startDate: '2024-07-01', endDate: '2024-09-30', status: '待制定' },
];

const improvementPlans = ref<ImprovementPlan[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentPlan = ref<ImprovementPlan>({
  id: 0,
  employeeName: '',
  period: '',
  performanceResult: '',
  improvementPlan: '',
  startDate: '',
  endDate: '',
  status: '待制定',
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
  let filteredRecords = allImprovementPlans;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(plan =>
      plan.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.period) {
    filteredRecords = filteredRecords.filter(plan =>
      plan.period === searchForm.value.period
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(plan =>
      plan.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  improvementPlans.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '待制定':
      return 'info';
    case '进行中':
      return '';
    case '已完成':
      return 'success';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增改进计划';
  currentPlan.value = {
    id: 0,
    employeeName: '',
    period: '',
    performanceResult: '',
    improvementPlan: '',
    startDate: '',
    endDate: '',
    status: '待制定',
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

const handleView = (row: ImprovementPlan) => {
  dialogTitle.value = '查看改进计划';
  currentPlan.value = { ...row };
  dialogVisible.value = true;
};

const handleEdit = (row: ImprovementPlan) => {
  dialogTitle.value = '编辑改进计划';
  currentPlan.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: ImprovementPlan) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} 的改进计划吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟删除操作
      ElMessage.success('删除成功！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};

const handleSubmit = () => {
  // 模拟保存操作
  if (currentPlan.value.id === 0) {
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
.performance-result-improvement-container {
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
