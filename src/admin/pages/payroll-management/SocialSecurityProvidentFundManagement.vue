<template>
  <div class="social-security-provident-fund-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>社保、公积金账户管理与缴纳</span>
          <el-button type="primary" @click="handleAdd">新增账户</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="缴纳月份">
          <el-date-picker
            v-model="searchForm.paymentMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="缴纳状态">
          <el-select v-model="searchForm.paymentStatus" placeholder="请选择缴纳状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待缴纳" value="待缴纳"></el-option>
            <el-option label="已缴纳" value="已缴纳"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="accounts" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="socialSecurityAccount" label="社保账号"></el-table-column>
        <el-table-column prop="providentFundAccount" label="公积金账号"></el-table-column>
        <el-table-column prop="paymentMonth" label="缴纳月份"></el-table-column>
        <el-table-column prop="companySocialSecurity" label="公司社保"></el-table-column>
        <el-table-column prop="personalSocialSecurity" label="个人社保"></el-table-column>
        <el-table-column prop="companyProvidentFund" label="公司公积金"></el-table-column>
        <el-table-column prop="personalProvidentFund" label="个人公积金"></el-table-column>
        <el-table-column prop="paymentStatus" label="缴纳状态">
          <template #default="{ row }">
            <el-tag :type="getPaymentStatusTag(row.paymentStatus)">{{ row.paymentStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.paymentStatus === '待缴纳'"
              size="small"
              type="success"
              @click="handlePay(scope.row)"
            >缴纳</el-button>
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

    <!-- 新增/编辑账户的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentAccount" label-width="120px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentAccount.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="社保账号">
          <el-input v-model="currentAccount.socialSecurityAccount"></el-input>
        </el-form-item>
        <el-form-item label="公积金账号">
          <el-input v-model="currentAccount.providentFundAccount"></el-input>
        </el-form-item>
        <el-form-item label="缴纳月份">
          <el-date-picker
            v-model="currentAccount.paymentMonth"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="公司社保缴纳">
          <el-input-number v-model="currentAccount.companySocialSecurity" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="个人社保缴纳">
          <el-input-number v-model="currentAccount.personalSocialSecurity" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="公司公积金缴纳">
          <el-input-number v-model="currentAccount.companyProvidentFund" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="个人公积金缴纳">
          <el-input-number v-model="currentAccount.personalProvidentFund" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="缴纳状态">
          <el-select v-model="currentAccount.paymentStatus" placeholder="请选择缴纳状态" popper-append-to-body>
            <el-option label="待缴纳" value="待缴纳"></el-option>
            <el-option label="已缴纳" value="已缴纳"></el-option>
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

interface SocialSecurityProvidentFundAccount {
  id: number;
  employeeName: string;
  socialSecurityAccount: string;
  providentFundAccount: string;
  paymentMonth: string;
  companySocialSecurity: number;
  personalSocialSecurity: number;
  companyProvidentFund: number;
  personalProvidentFund: number;
  paymentStatus: '待缴纳' | '已缴纳';
}

const allAccounts: SocialSecurityProvidentFundAccount[] = [
  { id: 1, employeeName: '张三', socialSecurityAccount: 'SHB123456', providentFundAccount: 'GJJ789012', paymentMonth: '2024-03', companySocialSecurity: 1000, personalSocialSecurity: 500, companyProvidentFund: 800, personalProvidentFund: 400, paymentStatus: '待缴纳' },
  { id: 2, employeeName: '李四', socialSecurityAccount: 'SHB234567', providentFundAccount: 'GJJ890123', paymentMonth: '2024-03', companySocialSecurity: 1200, personalSocialSecurity: 600, companyProvidentFund: 900, personalProvidentFund: 450, paymentStatus: '已缴纳' },
  { id: 3, employeeName: '王五', socialSecurityAccount: 'SHB345678', providentFundAccount: 'GJJ901234', paymentMonth: '2024-03', companySocialSecurity: 900, personalSocialSecurity: 450, companyProvidentFund: 700, personalProvidentFund: 350, paymentStatus: '待缴纳' },
];

const accounts = ref<SocialSecurityProvidentFundAccount[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentAccount = ref<SocialSecurityProvidentFundAccount>({
  id: 0,
  employeeName: '',
  socialSecurityAccount: '',
  providentFundAccount: '',
  paymentMonth: '',
  companySocialSecurity: 0,
  personalSocialSecurity: 0,
  companyProvidentFund: 0,
  personalProvidentFund: 0,
  paymentStatus: '待缴纳',
});

const searchForm = ref({
  employeeName: '',
  paymentMonth: '',
  paymentStatus: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allAccounts;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(account =>
      account.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.paymentMonth) {
    filteredRecords = filteredRecords.filter(account =>
      account.paymentMonth === searchForm.value.paymentMonth
    );
  }
  if (searchForm.value.paymentStatus) {
    filteredRecords = filteredRecords.filter(account =>
      account.paymentStatus === searchForm.value.paymentStatus
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  accounts.value = filteredRecords.slice(start, end);
};

const getPaymentStatusTag = (status: string) => {
  switch (status) {
    case '待缴纳':
      return 'warning';
    case '已缴纳':
      return 'success';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增社保公积金账户';
  currentAccount.value = {
    id: 0,
    employeeName: '',
    socialSecurityAccount: '',
    providentFundAccount: '',
    paymentMonth: '',
    companySocialSecurity: 0,
    personalSocialSecurity: 0,
    companyProvidentFund: 0,
    personalProvidentFund: 0,
    paymentStatus: '待缴纳',
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
    paymentMonth: '',
    paymentStatus: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: SocialSecurityProvidentFundAccount) => {
  dialogTitle.value = '查看账户详情';
  currentAccount.value = { ...row };
  dialogVisible.value = true;
};

const handlePay = (row: SocialSecurityProvidentFundAccount) => {
  ElMessageBox.confirm(`确定缴纳员工 ${row.employeeName} ${row.paymentMonth} 月的社保公积金吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟缴纳操作
      row.paymentStatus = '已缴纳';
      ElMessage.success('缴纳成功！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消缴纳');
    });
};

const handleSubmit = () => {
  // 模拟保存操作
  if (currentAccount.value.id === 0) {
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
.social-security-provident-fund-management-container {
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
