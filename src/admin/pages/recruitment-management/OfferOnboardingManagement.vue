<template>
  <div class="offer-onboarding-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>Offer发放与入职预约管理</span>
          <el-button type="primary" @click="handleAdd">发放Offer</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="候选人姓名">
          <el-input v-model="searchForm.candidateName" placeholder="请输入候选人姓名"></el-input>
        </el-form-item>
        <el-form-item label="职位">
          <el-input v-model="searchForm.position" placeholder="请输入职位"></el-input>
        </el-form-item>
        <el-form-item label="Offer状态">
          <el-select v-model="searchForm.offerStatus" placeholder="请选择Offer状态" append-to-body>
            <el-option label="待发放" value="待发放"></el-option>
            <el-option label="已发放" value="已发放"></el-option>
            <el-option label="已接受" value="已接受"></el-option>
            <el-option label="已拒绝" value="已拒绝"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="入职状态">
          <el-select v-model="searchForm.onboardingStatus" placeholder="请选择入职状态" popper-append-to-body>
            <el-option label="全部" value=""></el-option>
            <el-option label="待入职" value="待入职"></el-option>
            <el-option label="已入职" value="已入职"></el-option>
            <el-option label="已取消" value="已取消"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="offers" style="width: 100%" border>
        <el-table-column prop="candidateName" label="候选人姓名"></el-table-column>
        <el-table-column prop="position" label="职位"></el-table-column>
        <el-table-column prop="offerIssueDate" label="Offer发放日期"></el-table-column>
        <el-table-column prop="offerStatus" label="Offer状态">
          <template #default="{ row }">
            <el-tag :type="getOfferStatusTag(row.offerStatus)">{{ row.offerStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="onboardingDate" label="预计入职日期"></el-table-column>
        <el-table-column prop="onboardingStatus" label="入职状态">
          <template #default="{ row }">
            <el-tag :type="getOnboardingStatusTag(row.onboardingStatus)">{{ row.onboardingStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
            <el-button
              v-if="scope.row.offerStatus === '待发放'"
              size="small"
              type="success"
              @click="handleIssueOffer(scope.row)"
            >发放Offer</el-button>
            <el-button
              v-if="scope.row.offerStatus === '已接受' && scope.row.onboardingStatus === '待入职'"
              size="small"
              type="primary"
              @click="handleConfirmOnboarding(scope.row)"
            >确认入职</el-button>
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

    <!-- 新增/编辑Offer的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentOffer" label-width="120px">
        <el-form-item label="候选人姓名">
          <el-input v-model="currentOffer.candidateName"></el-input>
        </el-form-item>
        <el-form-item label="职位">
          <el-input v-model="currentOffer.position"></el-input>
        </el-form-item>
        <el-form-item label="薪资待遇">
          <el-input v-model="currentOffer.salary"></el-input>
        </el-form-item>
        <el-form-item label="Offer发放日期">
          <el-date-picker v-model="currentOffer.offerIssueDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="Offer截止日期">
          <el-date-picker v-model="currentOffer.offerAcceptanceDeadline" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="Offer状态">
          <el-select v-model="currentOffer.offerStatus" placeholder="请选择Offer状态">
            <el-option label="待发放" value="待发放"></el-option>
            <el-option label="已发放" value="已发放"></el-option>
            <el-option label="已接受" value="已接受"></el-option>
            <el-option label="已拒绝" value="已拒绝"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="预计入职日期">
          <el-date-picker v-model="currentOffer.onboardingDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="入职状态">
          <el-select v-model="currentOffer.onboardingStatus" placeholder="请选择入职状态">
            <el-option label="待入职" value="待入职"></el-option>
            <el-option label="已入职" value="已入职"></el-option>
            <el-option label="已取消" value="已取消"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input type="textarea" v-model="currentOffer.notes"></el-input>
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

interface OfferOnboarding {
  id: number;
  candidateName: string;
  position: string;
  salary: string;
  offerIssueDate: string;
  offerAcceptanceDeadline: string;
  offerStatus: '待发放' | '已发放' | '已接受' | '已拒绝';
  onboardingDate: string;
  onboardingStatus: '待入职' | '已入职' | '已取消';
  notes: string;
}

const allOffers: OfferOnboarding[] = [
  { id: 1, candidateName: '张小明', position: '高级前端工程师', salary: '20K-30K', offerIssueDate: '2024-03-25', offerAcceptanceDeadline: '2024-03-30', offerStatus: '已发放', onboardingDate: '2024-04-08', onboardingStatus: '待入职', notes: '' },
  { id: 2, candidateName: '李丽', position: '市场营销专员', salary: '10K-15K', offerIssueDate: '', offerAcceptanceDeadline: '', offerStatus: '待发放', onboardingDate: '', onboardingStatus: '待入职', notes: '' },
  { id: 3, candidateName: '王大锤', position: '销售经理', salary: '15K-25K', offerIssueDate: '2024-03-19', offerAcceptanceDeadline: '2024-03-22', offerStatus: '已接受', onboardingDate: '2024-04-01', onboardingStatus: '已入职', notes: '已完成入职手续' },
  { id: 4, candidateName: '钱多多', position: '后端开发工程师', salary: '18K-28K', offerIssueDate: '2024-03-26', offerAcceptanceDeadline: '2024-03-31', offerStatus: '已发放', onboardingDate: '2024-04-10', onboardingStatus: '待入职', notes: '' },
];

const offers = ref<OfferOnboarding[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentOffer = ref<OfferOnboarding>({
  id: 0,
  candidateName: '',
  position: '',
  salary: '',
  offerIssueDate: '',
  offerAcceptanceDeadline: '',
  offerStatus: '待发放',
  onboardingDate: '',
  onboardingStatus: '待入职',
  notes: '',
});

const searchForm = ref({
  candidateName: '',
  position: '',
  offerStatus: '',
  onboardingStatus: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allOffers;

  if (searchForm.value.candidateName) {
    filteredRecords = filteredRecords.filter(offer =>
      offer.candidateName.includes(searchForm.value.candidateName)
    );
  }
  if (searchForm.value.position) {
    filteredRecords = filteredRecords.filter(offer =>
      offer.position.includes(searchForm.value.position)
    );
  }
  if (searchForm.value.offerStatus) {
    filteredRecords = filteredRecords.filter(offer =>
      offer.offerStatus === searchForm.value.offerStatus
    );
  }
  if (searchForm.value.onboardingStatus) {
    filteredRecords = filteredRecords.filter(offer =>
      offer.onboardingStatus === searchForm.value.onboardingStatus
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  offers.value = filteredRecords.slice(start, end);
};

const getOfferStatusTag = (status: string) => {
  switch (status) {
    case '待发放':
      return 'info';
    case '已发放':
      return '';
    case '已接受':
      return 'success';
    case '已拒绝':
      return 'danger';
    default:
      return '';
  }
};

const getOnboardingStatusTag = (status: string) => {
  switch (status) {
    case '待入职':
      return 'warning';
    case '已入职':
      return 'success';
    case '已取消':
      return 'info';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '发放新Offer';
  currentOffer.value = {
    id: 0,
    candidateName: '',
    position: '',
    salary: '',
    offerIssueDate: '',
    offerAcceptanceDeadline: '',
    offerStatus: '待发放',
    onboardingDate: '',
    onboardingStatus: '待入职',
    notes: '',
  };
  dialogVisible.value = true;
};

const handleView = (row: OfferOnboarding) => {
  dialogTitle.value = '查看Offer与入职详情';
  currentOffer.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleIssueOffer = (row: OfferOnboarding) => {
  ElMessageBox.confirm(`确定向候选人 ${row.candidateName} 发放Offer吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟发放Offer操作
      row.offerStatus = '已发放';
      row.offerIssueDate = new Date().toISOString().slice(0, 10);
      ElMessage.success('Offer发放成功！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消操作');
    });
};

const handleConfirmOnboarding = (row: OfferOnboarding) => {
  ElMessageBox.confirm(`确定确认候选人 ${row.candidateName} 已入职吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟确认入职操作
      row.onboardingStatus = '已入职';
      ElMessage.success('已确认入职！');
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消操作');
    });
};

const handleDelete = (row: OfferOnboarding) => {
  ElMessageBox.confirm(`确定删除候选人 ${row.candidateName} 的Offer记录吗？`, '提示', {
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
  if (currentOffer.value.id === 0) {
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
  searchForm.value.candidateName = '';
  searchForm.value.position = '';
  searchForm.value.offerStatus = '';
  searchForm.value.onboardingStatus = '';
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
.offer-onboarding-management-container {
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
