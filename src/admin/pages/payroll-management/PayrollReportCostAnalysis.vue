<template>
  <div class="payroll-report-cost-analysis-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>薪酬报表与成本分析</span>
          <el-button type="primary" @click="handleExport">导出报表</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="年份">
          <el-date-picker
            v-model="searchForm.year"
            type="year"
            placeholder="选择年份"
            value-format="YYYY"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="部门">
          <el-select v-model="searchForm.department" placeholder="请选择部门">
            <el-option label="全部" value=""></el-option>
            <el-option label="销售部" value="销售部"></el-option>
            <el-option label="市场部" value="市场部"></el-option>
            <el-option label="技术部" value="技术部"></el-option>
            <el-option label="人事部" value="人事部"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-tabs v-model="activeTab" type="border-card">
        <el-tab-pane label="薪酬总览" name="overview">
          <el-table :data="payrollOverview" style="width: 100%" border>
            <el-table-column prop="department" label="部门"></el-table-column>
            <el-table-column prop="totalSalary" label="总薪酬"></el-table-column>
            <el-table-column prop="totalBonus" label="总奖金"></el-table-column>
            <el-table-column prop="totalAllowance" label="总津贴"></el-table-column>
            <el-table-column prop="totalSocialSecurity" label="总社保"></el-table-column>
            <el-table-column prop="totalHousingFund" label="总公积金"></el-table-column>
            <el-table-column prop="totalTax" label="总个税"></el-table-column>
            <el-table-column prop="totalCost" label="总成本"></el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="薪酬明细" name="details">
          <el-table :data="payrollDetails" style="width: 100%" border>
            <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
            <el-table-column prop="month" label="月份"></el-table-column>
            <el-table-column prop="baseSalary" label="基本工资"></el-table-column>
            <el-table-column prop="bonus" label="奖金"></el-table-column>
            <el-table-column prop="allowance" label="津贴"></el-table-column>
            <el-table-column prop="socialSecurity" label="社保扣除"></el-table-column>
            <el-table-column prop="housingFund" label="公积金扣除"></el-table-column>
            <el-table-column prop="tax" label="个税"></el-table-column>
            <el-table-column prop="netSalary" label="实发工资"></el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="成本趋势分析" name="trend">
          <div ref="chartContainer" style="width: 100%; height: 400px;"></div>
        </el-tab-pane>
      </el-tabs>

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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { ElMessage } from 'element-plus';
import * as echarts from 'echarts';

interface PayrollOverview {
  department: string;
  totalSalary: number;
  totalBonus: number;
  totalAllowance: number;
  totalSocialSecurity: number;
  totalHousingFund: number;
  totalTax: number;
  totalCost: number;
}

interface PayrollDetail {
  employeeName: string;
  month: string;
  baseSalary: number;
  bonus: number;
  allowance: number;
  socialSecurity: number;
  housingFund: number;
  tax: number;
  netSalary: number;
}

const payrollOverview = ref<PayrollOverview[]>([]);
const payrollDetails = ref<PayrollDetail[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const activeTab = ref('overview'); // 默认显示薪酬总览

const searchForm = ref({
  year: new Date().getFullYear().toString(),
  department: '',
});

const chartContainer = ref<HTMLElement | null>(null);
let chartInstance: echarts.ECharts | null = null;

onMounted(() => {
  fetchRecords();
  initChart();
});

watch(activeTab, (newTab) => {
  if (newTab === 'trend') {
    // 确保DOM元素已渲染
    setTimeout(() => {
      if (chartInstance) {
        chartInstance.resize();
      } else {
        initChart();
      }
    }, 0);
  }
});

const fetchRecords = () => {
  // 模拟薪酬总览数据
  payrollOverview.value = [
    { department: '销售部', totalSalary: 100000, totalBonus: 20000, totalAllowance: 5000, totalSocialSecurity: 10000, totalHousingFund: 5000, totalTax: 3000, totalCost: 143000 },
    { department: '市场部', totalSalary: 80000, totalBonus: 15000, totalAllowance: 4000, totalSocialSecurity: 8000, totalHousingFund: 4000, totalTax: 2000, totalCost: 113000 },
    { department: '技术部', totalSalary: 150000, totalBonus: 30000, totalAllowance: 8000, totalSocialSecurity: 15000, totalHousingFund: 7500, totalTax: 5000, totalCost: 215500 },
    { department: '人事部', totalSalary: 60000, totalBonus: 10000, totalAllowance: 3000, totalSocialSecurity: 6000, totalHousingFund: 3000, totalTax: 1000, totalCost: 83000 },
  ].filter(item => {
    return (!searchForm.value.department || item.department === searchForm.value.department);
  });

  // 模拟薪酬明细数据
  payrollDetails.value = [
    { employeeName: '张三', month: '2024-03', baseSalary: 8000, bonus: 1000, allowance: 500, socialSecurity: 800, housingFund: 400, tax: 200, netSalary: 8100 },
    { employeeName: '李四', month: '2024-03', baseSalary: 12000, bonus: 2000, allowance: 800, socialSecurity: 1200, housingFund: 600, tax: 500, netSalary: 12500 },
    { employeeName: '王五', month: '2024-03', baseSalary: 6000, bonus: 500, allowance: 300, socialSecurity: 600, housingFund: 300, tax: 50, netSalary: 5850 },
    { employeeName: '张三', month: '2024-02', baseSalary: 8000, bonus: 800, allowance: 500, socialSecurity: 800, housingFund: 400, tax: 180, netSalary: 7920 },
    { employeeName: '李四', month: '2024-02', baseSalary: 12000, bonus: 1800, allowance: 800, socialSecurity: 1200, housingFund: 600, tax: 450, netSalary: 12350 },
  ].filter(item => {
    return (!searchForm.value.department || getDepartmentByEmployee(item.employeeName) === searchForm.value.department);
  });

  totalRecords.value = activeTab.value === 'overview' ? payrollOverview.value.length : payrollDetails.value.length;
};

const getDepartmentByEmployee = (employeeName: string) => {
  // 模拟根据员工姓名获取部门
  const employeeMap: { [key: string]: string } = {
    '张三': '销售部',
    '李四': '市场部',
    '王五': '技术部',
  };
  return employeeMap[employeeName] || '';
};

const initChart = () => {
  if (chartContainer.value) {
    chartInstance = echarts.init(chartContainer.value);
    const option = {
      title: {
        text: '薪酬成本趋势',
        left: 'center'
      },
      tooltip: {
        trigger: 'axis'
      },
      legend: {
        data: ['总薪酬成本'],
        top: 'bottom'
      },
      xAxis: {
        type: 'category',
        data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月']
      },
      yAxis: {
        type: 'value',
        name: '金额 (元)'
      },
      series: [
        {
          name: '总薪酬成本',
          type: 'line',
          data: [120000, 130000, 140000, 135000, 145000, 150000, 148000, 155000, 160000, 158000, 165000, 170000]
        }
      ]
    };
    chartInstance.setOption(option);
  }
};

const handleExport = () => {
  ElMessage.success('模拟导出报表成功！');
  // 实际项目中会触发文件下载
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    year: new Date().getFullYear().toString(),
    department: '',
  };
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
.payroll-report-cost-analysis-container {
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
