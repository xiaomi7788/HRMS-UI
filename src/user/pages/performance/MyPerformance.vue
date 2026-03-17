<template>
  <div class="my-performance-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>我的绩效</span>
        </div>
      </template>
      <el-form :inline="true" :model="queryForm" class="query-form">
        <el-form-item label="年份">
          <el-date-picker
            v-model="queryForm.year"
            type="year"
            placeholder="选择年份"
            value-format="YYYY"
          />
        </el-form-item>
        <el-form-item label="绩效周期">
          <el-select v-model="queryForm.cycle" placeholder="选择绩效周期" popper-append-to-body>
            <el-option label="全年" value="full_year"></el-option>
            <el-option label="上半年" value="first_half"></el-option>
            <el-option label="下半年" value="second_half"></el-option>
            <el-option label="Q1" value="q1"></el-option>
            <el-option label="Q2" value="q2"></el-option>
            <el-option label="Q3" value="q3"></el-option>
            <el-option label="Q4" value="q4"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchPerformanceData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="performanceData" style="width: 100%" border v-loading="loading">
        <el-table-column prop="year" label="年份"></el-table-column>
        <el-table-column prop="cycle" label="绩效周期"></el-table-column>
        <el-table-column prop="goal" label="绩效目标"></el-table-column>
        <el-table-column prop="selfRating" label="自评"></el-table-column>
        <el-table-column prop="managerRating" label="主管评价"></el-table-column>
        <el-table-column prop="finalRating" label="最终评级">
          <template #default="{ row }">
            <el-tag :type="getRatingType(row.finalRating)">{{ row.finalRating }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleViewDetails(row)">查看详情</el-button>
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
  year: new Date().getFullYear().toString(),
  cycle: '',
});

const performanceData = ref([
  { id: 1, year: '2023', cycle: '全年', goal: '完成年度销售目标1000万', selfRating: 'A', managerRating: 'A', finalRating: 'A' },
  { id: 2, year: '2023', cycle: '上半年', goal: '完成新产品上线并达到市场占有率5%', selfRating: 'B', managerRating: 'B+', finalRating: 'B+' },
  { id: 3, year: '2022', cycle: '全年', goal: '优化客户服务流程，提升客户满意度10%', selfRating: 'B+', managerRating: 'A-', finalRating: 'A-' },
  { id: 4, year: '2024', cycle: 'Q1', goal: '完成团队建设活动，提升团队凝聚力', selfRating: 'A', managerRating: 'A', finalRating: 'A' },
]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(performanceData.value.length);

const getRatingType = (rating: string) => {
  if (rating.startsWith('A')) return 'success';
  if (rating.startsWith('B')) return 'warning';
  if (rating.startsWith('C')) return 'danger';
  return 'info';
};

const fetchPerformanceData = () => {
  loading.value = true;
  // 模拟 API 请求
  setTimeout(() => {
    ElMessage.success(`查询 ${queryForm.year} 年 ${queryForm.cycle || '所有周期'} 绩效数据成功！`);
    // 根据查询条件过滤数据，这里只是模拟
    total.value = performanceData.value.length;
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.year = new Date().getFullYear().toString();
  queryForm.cycle = '';
  fetchPerformanceData();
};

const handleViewDetails = (row: any) => {
  ElMessageBox.alert(`
    <p><strong>年份:</strong> ${row.year}</p>
    <p><strong>绩效周期:</strong> ${row.cycle}</p>
    <p><strong>绩效目标:</strong> ${row.goal}</p>
    <p><strong>自评:</strong> ${row.selfRating}</p>
    <p><strong>主管评价:</strong> ${row.managerRating}</p>
    <p><strong>最终评级:</strong> ${row.finalRating}</p>
  `, '绩效详情', {
    dangerouslyUseHTMLString: true,
    confirmButtonText: '确定',
  });
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchPerformanceData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchPerformanceData();
};

onMounted(() => {
  fetchPerformanceData();
});
</script>

<style scoped>
.my-performance-container {
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
