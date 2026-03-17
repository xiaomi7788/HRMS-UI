<template>
  <div class="succession-planning-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>继任者计划与人才梯队管理</span>
          <el-button type="primary" @click="handleAdd">新增计划</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="岗位名称">
          <el-input v-model="searchForm.positionName" placeholder="请输入岗位名称"></el-input>
        </el-form-item>
        <el-form-item label="继任者姓名">
          <el-input v-model="searchForm.successorName" placeholder="请输入继任者姓名"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="进行中" value="进行中"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
            <el-option label="已取消" value="已取消"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="successionPlans" style="width: 100%" border>
        <el-table-column prop="positionName" label="岗位名称"></el-table-column>
        <el-table-column prop="currentHolder" label="现任者"></el-table-column>
        <el-table-column prop="successorName" label="继任者"></el-table-column>
        <el-table-column prop="readiness" label="继任准备度"></el-table-column>
        <el-table-column prop="planDate" label="计划日期"></el-table-column>
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

    <!-- 新增/编辑计划的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentPlan" label-width="120px">
        <el-form-item label="岗位名称">
          <el-input v-model="currentPlan.positionName"></el-input>
        </el-form-item>
        <el-form-item label="现任者">
          <el-input v-model="currentPlan.currentHolder"></el-input>
        </el-form-item>
        <el-form-item label="继任者">
          <el-input v-model="currentPlan.successorName"></el-input>
        </el-form-item>
        <el-form-item label="继任准备度">
          <el-select v-model="currentPlan.readiness" placeholder="请选择准备度" append-to-body>
            <el-option label="高" value="高"></el-option>
            <el-option label="中" value="中"></el-option>
            <el-option label="低" value="低"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="计划日期">
          <el-date-picker v-model="currentPlan.planDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentPlan.status" placeholder="请选择状态" append-to-body>
            <el-option label="进行中" value="进行中"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
            <el-option label="已取消" value="已取消"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input type="textarea" v-model="currentPlan.notes"></el-input>
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

interface SuccessionPlan {
  id: number;
  positionName: string;
  currentHolder: string;
  successorName: string;
  readiness: '高' | '中' | '低';
  planDate: string;
  status: '进行中' | '已完成' | '已取消';
  notes: string;
}

const allSuccessionPlans: SuccessionPlan[] = [
  { id: 1, positionName: '销售总监', currentHolder: '张伟', successorName: '李娜', readiness: '高', planDate: '2024-01-01', status: '进行中', notes: '李娜已完成高级销售培训' },
  { id: 2, positionName: '技术总监', currentHolder: '王强', successorName: '赵明', readiness: '中', planDate: '2024-03-01', status: '进行中', notes: '赵明需提升团队管理能力' },
  { id: 3, positionName: '市场经理', currentHolder: '刘芳', successorName: '孙悦', readiness: '高', planDate: '2023-11-01', status: '已完成', notes: '孙悦已成功接任市场经理职位' },
  { id: 4, positionName: '财务总监', currentHolder: '陈红', successorName: '周磊', readiness: '低', planDate: '2025-01-01', status: '进行中', notes: '周磊需进行CFO资质培训' },
  { id: 5, positionName: '人力资源总监', currentHolder: '杨丽', successorName: '吴迪', readiness: '中', planDate: '2024-06-01', status: '进行中', notes: '吴迪正在参与HRBP高级认证' },
];

const successionPlans = ref<SuccessionPlan[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentPlan = ref<SuccessionPlan>({
  id: 0,
  positionName: '',
  currentHolder: '',
  successorName: '',
  readiness: '中',
  planDate: '',
  status: '进行中',
  notes: '',
});

const searchForm = ref({
  positionName: '',
  successorName: '',
  status: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allSuccessionPlans;

  if (searchForm.value.positionName) {
    filteredRecords = filteredRecords.filter(plan =>
      plan.positionName.includes(searchForm.value.positionName)
    );
  }
  if (searchForm.value.successorName) {
    filteredRecords = filteredRecords.filter(plan =>
      plan.successorName.includes(searchForm.value.successorName)
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
  successionPlans.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '进行中':
      return '';
    case '已完成':
      return 'success';
    case '已取消':
      return 'info';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增继任者计划';
  currentPlan.value = {
    id: 0,
    positionName: '',
    currentHolder: '',
    successorName: '',
    readiness: '中',
    planDate: '',
    status: '进行中',
    notes: '',
  };
  dialogVisible.value = true;
};

const handleView = (row: SuccessionPlan) => {
  dialogTitle.value = '查看继任者计划';
  currentPlan.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleEdit = (row: SuccessionPlan) => {
  dialogTitle.value = '编辑继任者计划';
  currentPlan.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: SuccessionPlan) => {
  ElMessageBox.confirm(`确定删除岗位 ${row.positionName} 的继任者计划吗？`, '提示', {
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
    // 新增
    ElMessage.success('新增成功！');
  } else {
    // 编辑
    ElMessage.success('编辑成功！');
  }
  dialogVisible.value = false;
  fetchRecords(); // 重新加载数据
};

const handleCloseDialog = () => {
  dialogVisible.value = false;
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value.positionName = '';
  searchForm.value.successorName = '';
  searchForm.value.status = '';
  currentPage.value = 1;
  fetchRecords();
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
.succession-planning-container {
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
