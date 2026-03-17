<template>
  <div class="benefit-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>福利项目发放与登记</span>
          <el-button type="primary" @click="handleAdd">新增福利项目</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="福利名称">
          <el-input v-model="searchForm.benefitName" placeholder="请输入福利名称"></el-input>
        </el-form-item>
        <el-form-item label="发放日期">
          <el-date-picker
            v-model="searchForm.issueDateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
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

      <el-table :data="benefits" style="width: 100%" border>
        <el-table-column prop="benefitName" label="福利名称"></el-table-column>
        <el-table-column prop="targetEmployees" label="发放对象"></el-table-column>
        <el-table-column prop="issueDate" label="发放日期"></el-table-column>
        <el-table-column prop="value" label="价值/金额"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.status === '待发放'"
              size="small"
              type="success"
              @click="handleIssue(scope.row)"
            >发放</el-button>
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

    <!-- 新增/编辑福利项目的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentBenefit" label-width="100px">
        <el-form-item label="福利名称">
          <el-input v-model="currentBenefit.benefitName"></el-input>
        </el-form-item>
        <el-form-item label="发放对象">
          <el-input v-model="currentBenefit.targetEmployees"></el-input>
        </el-form-item>
        <el-form-item label="发放日期">
          <el-date-picker v-model="currentBenefit.issueDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="价值/金额">
          <el-input-number v-model="currentBenefit.value" :min="0"></el-input-number>
        </el-form-item>
        <el-form-item label="备注">
          <el-input type="textarea" v-model="currentBenefit.notes"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentBenefit.status" placeholder="请选择状态" popper-append-to-body>
            <el-option label="待发放" value="待发放"></el-option>
            <el-option label="已发放" value="已发放"></el-option>
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

interface Benefit {
  id: number;
  benefitName: string;
  targetEmployees: string;
  issueDate: string;
  value: number;
  notes: string;
  status: '待发放' | '已发放';
}

const allBenefits: Benefit[] = [
  { id: 1, benefitName: '节日礼品', targetEmployees: '全体员工', issueDate: '2024-02-01', value: 200, notes: '春节福利', status: '已发放' },
  { id: 2, benefitName: '商业保险', targetEmployees: '正式员工', issueDate: '2024-01-01', value: 500, notes: '年度商业医疗保险', status: '已发放' },
  { id: 3, benefitName: '生日福利', targetEmployees: '当月生日员工', issueDate: '2024-03-01', value: 100, notes: '生日蛋糕券', status: '待发放' },
];

const benefits = ref<Benefit[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentBenefit = ref<Benefit>({
  id: 0,
  benefitName: '',
  targetEmployees: '',
  issueDate: '',
  value: 0,
  notes: '',
  status: '待发放',
});

const searchForm = ref({
  benefitName: '',
  issueDateRange: [],
  status: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allBenefits;

  if (searchForm.value.benefitName) {
    filteredRecords = filteredRecords.filter(benefit =>
      benefit.benefitName.includes(searchForm.value.benefitName)
    );
  }
  if (searchForm.value.issueDateRange && searchForm.value.issueDateRange.length === 2) {
    const [startDate, endDate] = searchForm.value.issueDateRange;
    filteredRecords = filteredRecords.filter(benefit => {
      const benefitDate = new Date(benefit.issueDate);
      return benefitDate >= new Date(startDate) && benefitDate <= new Date(endDate);
    });
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(benefit =>
      benefit.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  benefits.value = filteredRecords.slice(start, end);
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

const handleAdd = () => {
  dialogTitle.value = '新增福利项目';
  currentBenefit.value = {
    id: 0,
    benefitName: '',
    targetEmployees: '',
    issueDate: '',
    value: 0,
    notes: '',
    status: '待发放',
  };
  dialogVisible.value = true;
};

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    benefitName: '',
    issueDateRange: [],
    status: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: Benefit) => {
  dialogTitle.value = '查看福利项目详情';
  currentBenefit.value = { ...row };
  dialogVisible.value = true;
};

const handleIssue = (row: Benefit) => {
  ElMessageBox.confirm(`确定发放福利项目《${row.benefitName}》吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟发放操作
      row.status = '已发放';
      ElMessage.success('福利发放成功！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消发放');
    });
};

const handleDelete = (row: Benefit) => {
  ElMessageBox.confirm(`确定删除福利项目《${row.benefitName}》吗？`, '提示', {
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
  if (currentBenefit.value.id === 0) {
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
.benefit-management-container {
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
