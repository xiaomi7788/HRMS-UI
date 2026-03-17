<template>
  <div class="performance-goal-setting-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>绩效目标制定与对齐</span>
          <el-button type="primary" @click="handleAdd">新增目标</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="目标周期">
          <el-select v-model="searchForm.period" placeholder="请选择目标周期">
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
            <el-option label="草稿" value="草稿"></el-option>
            <el-option label="待审批" value="待审批"></el-option>
            <el-option label="已批准" value="已批准"></el-option>
            <el-option label="进行中" value="进行中"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="goals" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="period" label="目标周期"></el-table-column>
        <el-table-column prop="goalDescription" label="目标描述"></el-table-column>
        <el-table-column prop="keyResults" label="关键结果"></el-table-column>
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

    <!-- 新增/编辑目标的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentGoal" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentGoal.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="目标周期">
          <el-select v-model="currentGoal.period" placeholder="请选择目标周期" :teleported="true">
            <el-option label="Q1 2024" value="Q1 2024"></el-option>
            <el-option label="Q2 2024" value="Q2 2024"></el-option>
            <el-option label="H1 2024" value="H1 2024"></el-option>
            <el-option label="2024年度" value="2024年度"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="目标描述">
          <el-input type="textarea" v-model="currentGoal.goalDescription" :rows="3"></el-input>
        </el-form-item>
        <el-form-item label="关键结果">
          <el-input type="textarea" v-model="currentGoal.keyResults" :rows="3"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentGoal.status" placeholder="请选择状态" :teleported="true">
            <el-option label="草稿" value="草稿"></el-option>
            <el-option label="待审批" value="待审批"></el-option>
            <el-option label="已批准" value="已批准"></el-option>
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

interface PerformanceGoal {
  id: number;
  employeeName: string;
  period: string;
  goalDescription: string;
  keyResults: string;
  status: '草稿' | '待审批' | '已批准' | '进行中' | '已完成';
}

const allGoals: PerformanceGoal[] = [
  { id: 1, employeeName: '张三', period: 'Q1 2024', goalDescription: '完成新产品A的UI设计', keyResults: '设计稿通过率90%，用户反馈满意度85%', status: '进行中' },
  { id: 2, employeeName: '李四', period: 'Q1 2024', goalDescription: '提升销售额15%', keyResults: '完成100万销售额，新增客户5家', status: '已批准' },
  { id: 3, employeeName: '王五', period: 'Q2 2024', goalDescription: '优化后端服务响应时间', keyResults: '核心接口响应时间缩短20%', status: '草稿' },
];

const goals = ref<PerformanceGoal[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentGoal = ref<PerformanceGoal>({
  id: 0,
  employeeName: '',
  period: '',
  goalDescription: '',
  keyResults: '',
  status: '草稿',
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
  let filteredRecords = allGoals;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(goal =>
      goal.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.period) {
    filteredRecords = filteredRecords.filter(goal =>
      goal.period === searchForm.value.period
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(goal =>
      goal.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  goals.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '草稿':
      return 'info';
    case '待审批':
      return 'warning';
    case '已批准':
      return 'success';
    case '进行中':
      return '';
    case '已完成':
      return 'success';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增绩效目标';
  currentGoal.value = {
    id: 0,
    employeeName: '',
    period: '',
    goalDescription: '',
    keyResults: '',
    status: '草稿',
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

const handleView = (row: PerformanceGoal) => {
  dialogTitle.value = '查看绩效目标';
  currentGoal.value = { ...row };
  dialogVisible.value = true;
};

const handleEdit = (row: PerformanceGoal) => {
  dialogTitle.value = '编辑绩效目标';
  currentGoal.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: PerformanceGoal) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} 的绩效目标吗？`, '提示', {
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
  if (currentGoal.value.id === 0) {
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
.performance-goal-setting-container {
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
