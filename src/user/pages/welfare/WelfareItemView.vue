<template>
  <div class="welfare-item-view-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>福利项目查看</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="项目名称">
          <el-input v-model="queryForm.itemName" placeholder="请输入项目名称"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryForm.status" placeholder="选择状态" popper-append-to-body>
            <el-option label="全部" value=""></el-option>
            <el-option label="已发放" value="issued"></el-option>
            <el-option label="待发放" value="pending"></el-option>
            <el-option label="已登记" value="registered"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchWelfareData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="welfareData" style="width: 100%" border v-loading="loading">
        <el-table-column prop="itemName" label="项目名称"></el-table-column>
        <el-table-column prop="description" label="描述"></el-table-column>
        <el-table-column prop="issueDate" label="发放日期"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleRegister(row)" v-if="row.status === 'pending'">登记</el-button>
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
  itemName: '',
  status: '',
});

const welfareData = ref([
  { id: 1, itemName: '节日礼品', description: '春节福利礼包', issueDate: '2023-01-15', status: 'issued' },
  { id: 2, itemName: '商业保险', description: '补充医疗保险', issueDate: '2023-03-01', status: 'registered' },
  { id: 3, itemName: '生日福利', description: '生日蛋糕券', issueDate: '2023-04-20', status: 'pending' },
  { id: 4, itemName: '年度体检', description: '员工年度健康体检', issueDate: '2023-05-10', status: 'issued' },
  { id: 5, itemName: '高温补贴', description: '夏季高温津贴', issueDate: '2023-07-01', status: 'pending' },
]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(welfareData.value.length);

const getStatusText = (status: string) => {
  switch (status) {
    case 'issued':
      return '已发放';
    case 'pending':
      return '待发放';
    case 'registered':
      return '已登记';
    default:
      return '未知';
  }
};

const getStatusType = (status: string) => {
  switch (status) {
    case 'issued':
      return 'success';
    case 'pending':
      return 'warning';
    case 'registered':
      return 'info';
    default:
      return 'default';
  }
};

const fetchWelfareData = () => {
  loading.value = true;
  // 模拟 API 请求
  setTimeout(() => {
    ElMessage.success('查询福利项目数据成功！');
    // 根据查询条件过滤数据，这里只是模拟
    total.value = welfareData.value.length;
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.itemName = '';
  queryForm.status = '';
  fetchWelfareData();
};

const handleRegister = (row: any) => {
  ElMessageBox.confirm(`确定要登记福利项目 “${row.itemName}” 吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟登记操作
      row.status = 'registered';
      ElMessage.success(`${row.itemName} 登记成功！`);
    })
    .catch(() => {
      ElMessage.info('已取消登记');
    });
};

const handleViewDetails = (row: any) => {
  ElMessageBox.alert(`
    <p><strong>项目名称:</strong> ${row.itemName}</p>
    <p><strong>描述:</strong> ${row.description}</p>
    <p><strong>发放日期:</strong> ${row.issueDate}</p>
    <p><strong>状态:</strong> ${getStatusText(row.status)}</p>
  `, '福利项目详情', {
    dangerouslyUseHTMLString: true,
    confirmButtonText: '确定',
  });
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchWelfareData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchWelfareData();
};

onMounted(() => {
  fetchWelfareData();
});
</script>

<style scoped>
.welfare-item-view-container {
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
