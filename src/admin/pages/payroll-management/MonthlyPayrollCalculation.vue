<template>
  <div class="monthly-payroll-calculation-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>月度薪酬核算与个税计算</span>
          <el-button type="primary" @click="handleCalculate">核算薪酬</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="月份">
          <el-date-picker
            v-model="searchForm.month"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待发放" value="待发放"></el-option>
            <el-option label="已发放" value="已发放"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="payrollRecords" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="month" label="月份"></el-table-column>
        <el-table-column prop="baseSalary" label="基本工资"></el-table-column>
        <el-table-column prop="bonus" label="奖金"></el-table-column>
        <el-table-column prop="allowance" label="津贴"></el-table-column>
        <el-table-column prop="socialSecurity" label="社保扣除"></el-table-column>
        <el-table-column prop="housingFund" label="公积金扣除"></el-table-column>
        <el-table-column prop="tax" label="个税"></el-table-column>
        <el-table-column prop="netSalary" label="实发工资"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.status === '待发放'"
              size="small"
              type="success"
              @click="handleIssue(scope.row)"
            >发放</el-button>
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

    <!-- 薪酬详情对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="薪酬详情"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentPayroll" label-width="120px">
        <el-form-item label="员工姓名">{{ currentPayroll.employeeName }}</el-form-item>
        <el-form-item label="月份">{{ currentPayroll.month }}</el-form-item>
        <el-form-item label="基本工资">{{ currentPayroll.baseSalary }}</el-form-item>
        <el-form-item label="奖金">{{ currentPayroll.bonus }}</el-form-item>
        <el-form-item label="津贴">{{ currentPayroll.allowance }}</el-form-item>
        <el-form-item label="社保扣除">{{ currentPayroll.socialSecurity }}</el-form-item>
        <el-form-item label="公积金扣除">{{ currentPayroll.housingFund }}</el-form-item>
        <el-form-item label="个税">{{ currentPayroll.tax }}</el-form-item>
        <el-form-item label="实发工资">{{ currentPayroll.netSalary }}</el-form-item>
        <el-form-item label="状态">
          <el-tag :type="getStatusTag(currentPayroll.status)">{{ currentPayroll.status }}</el-tag>
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

interface PayrollRecord {
  id: number;
  employeeName: string;
  month: string;
  baseSalary: number;
  bonus: number;
  allowance: number;
  socialSecurity: number;
  housingFund: number;
  tax: number;
  netSalary: number;
  status: '待发放' | '已发放';
}

const allPayrollRecords: PayrollRecord[] = [
  { id: 1, employeeName: '张三', month: '2024-03', baseSalary: 8000, bonus: 1000, allowance: 500, socialSecurity: 800, housingFund: 400, tax: 200, netSalary: 8100, status: '待发放' },
  { id: 2, employeeName: '李四', month: '2024-03', baseSalary: 12000, bonus: 2000, allowance: 800, socialSecurity: 1200, housingFund: 600, tax: 500, netSalary: 12500, status: '已发放' },
  { id: 3, employeeName: '王五', month: '2024-03', baseSalary: 6000, bonus: 500, allowance: 300, socialSecurity: 600, housingFund: 300, tax: 50, netSalary: 5850, status: '待发放' },
];

const payrollRecords = ref<PayrollRecord[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const currentPayroll = ref<PayrollRecord>({
  id: 0,
  employeeName: '',
  month: '',
  baseSalary: 0,
  bonus: 0,
  allowance: 0,
  socialSecurity: 0,
  housingFund: 0,
  tax: 0,
  netSalary: 0,
  status: '待发放',
});

const searchForm = ref({
  employeeName: '',
  month: '',
  status: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allPayrollRecords;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(record =>
      record.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.month) {
    filteredRecords = filteredRecords.filter(record =>
      record.month === searchForm.value.month
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(record =>
      record.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  payrollRecords.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '待发放':
      return 'warning';
    case '已发放':
      return 'success';
    default:
      return '';
  }
};

const handleCalculate = () => {
  ElMessage.success('模拟薪酬核算成功！');
  fetchRecords(); // 重新加载数据
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    employeeName: '',
    month: '',
    status: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: PayrollRecord) => {
  currentPayroll.value = { ...row };
  dialogVisible.value = true;
};

const handleIssue = (row: PayrollRecord) => {
  ElMessageBox.confirm(`确定向员工 ${row.employeeName} 发放 ${row.month} 月薪酬吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟发放操作
      row.status = '已发放';
      ElMessage.success('薪酬发放成功！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消发放');
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
.monthly-payroll-calculation-container {
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
