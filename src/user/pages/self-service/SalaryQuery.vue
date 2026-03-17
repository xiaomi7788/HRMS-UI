<template>
  <div class="salary-query-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>薪资查询</span>
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
        <el-form-item label="月份">
          <el-select v-model="queryForm.month" placeholder="选择月份" popper-append-to-body>
            <el-option v-for="i in 12" :key="i" :label="i + '月'" :value="i"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchSalaryData">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="salaryData" style="width: 100%" border v-loading="loading">
        <el-table-column prop="month" label="月份" width="100"></el-table-column>
        <el-table-column prop="baseSalary" label="基本工资"></el-table-column>
        <el-table-column prop="bonus" label="奖金"></el-table-column>
        <el-table-column prop="allowance" label="津贴"></el-table-column>
        <el-table-column prop="deduction" label="扣款"></el-table-column>
        <el-table-column prop="tax" label="个税"></el-table-column>
        <el-table-column prop="netSalary" label="实发工资"></el-table-column>
        <el-table-column label="操作" width="100">
          <template #default>
            <el-button link type="primary" size="small">查看详情</el-button>
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
import { ElMessage } from 'element-plus';

const loading = ref(false);
const queryForm = reactive({
  year: new Date().getFullYear().toString(),
  month: new Date().getMonth() + 1,
});

const salaryData = ref([
  // 模拟数据
  { month: '2023-01', baseSalary: 8000, bonus: 1000, allowance: 500, deduction: 200, tax: 300, netSalary: 9000 },
  { month: '2023-02', baseSalary: 8000, bonus: 1200, allowance: 500, deduction: 200, tax: 350, netSalary: 9150 },
  { month: '2023-03', baseSalary: 8000, bonus: 1000, allowance: 500, deduction: 200, tax: 300, netSalary: 9000 },
  { month: '2023-04', baseSalary: 8000, bonus: 1100, allowance: 500, deduction: 200, tax: 320, netSalary: 9080 },
  { month: '2023-05', baseSalary: 8000, bonus: 1000, allowance: 500, deduction: 200, tax: 300, netSalary: 9000 },
  { month: '2023-06', baseSalary: 8000, bonus: 1300, allowance: 500, deduction: 200, tax: 380, netSalary: 9220 },
]);

const currentPage = ref(1);
const pageSize = ref(10);
const total = ref(salaryData.value.length);

const fetchSalaryData = () => {
  loading.value = true;
  // 模拟 API 请求
  setTimeout(() => {
    ElMessage.success(`查询 ${queryForm.year} 年 ${queryForm.month} 月薪资数据成功！`);
    // 根据查询条件过滤数据，这里只是模拟
    total.value = salaryData.value.length;
    loading.value = false;
  }, 500);
};

const resetQuery = () => {
  queryForm.year = new Date().getFullYear().toString();
  queryForm.month = new Date().getMonth() + 1;
  fetchSalaryData();
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  fetchSalaryData();
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
  fetchSalaryData();
};

onMounted(() => {
  fetchSalaryData();
});
</script>

<style scoped>
.salary-query-container {
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
