<template>
  <div class="contract-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>劳动合同管理</span>
          <el-button type="primary" @click="handleAdd">新增合同</el-button>
        </div>
      </template>
      <el-table :data="contractRecords" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="contractNumber" label="合同编号"></el-table-column>
        <el-table-column prop="contractType" label="合同类型"></el-table-column>
        <el-table-column prop="startDate" label="开始日期"></el-table-column>
        <el-table-column prop="endDate" label="结束日期"></el-table-column>
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

    <!-- 新增/编辑合同的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentContract" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentContract.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="合同编号">
          <el-input v-model="currentContract.contractNumber"></el-input>
        </el-form-item>
        <el-form-item label="合同类型">
          <el-select v-model="currentContract.contractType" placeholder="请选择合同类型" append-to-body>
            <el-option label="固定期限劳动合同" value="固定期限劳动合同"></el-option>
            <el-option label="无固定期限劳动合同" value="无固定期限劳动合同"></el-option>
            <el-option label="劳务派遣合同" value="劳务派遣合同"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期">
          <el-date-picker v-model="currentContract.startDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="结束日期">
          <el-date-picker v-model="currentContract.endDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentContract.status" placeholder="请选择合同状态" append-to-body>
            <el-option label="生效中" value="生效中"></el-option>
            <el-option label="已到期" value="已到期"></el-option>
            <el-option label="已终止" value="已终止"></el-option>
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

interface ContractRecord {
  id: number;
  employeeName: string;
  contractNumber: string;
  contractType: string;
  startDate: string;
  endDate: string;
  status: '生效中' | '已到期' | '已终止';
}

const contractRecords = ref<ContractRecord[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentContract = ref<ContractRecord>({
  id: 0,
  employeeName: '',
  contractNumber: '',
  contractType: '固定期限劳动合同',
  startDate: '',
  endDate: '',
  status: '生效中',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  // 模拟从后端获取数据
  const mockData: ContractRecord[] = [
    { id: 1, employeeName: '张三', contractNumber: 'HT2023001', contractType: '固定期限劳动合同', startDate: '2023-01-01', endDate: '2025-12-31', status: '生效中' },
    { id: 2, employeeName: '李四', contractNumber: 'HT2022002', contractType: '无固定期限劳动合同', startDate: '2022-03-01', endDate: '', status: '生效中' },
    { id: 3, employeeName: '王五', contractNumber: 'HT2021003', contractType: '固定期限劳动合同', startDate: '2021-06-01', endDate: '2024-05-31', status: '生效中' },
    { id: 4, employeeName: '赵六', contractNumber: 'HT2020004', contractType: '劳务派遣合同', startDate: '2020-09-01', endDate: '2023-08-31', status: '已到期' },
    { id: 5, employeeName: '钱七', contractNumber: 'HT2023005', contractType: '固定期限劳动合同', startDate: '2023-02-01', endDate: '2026-01-31', status: '生效中' },
    { id: 6, employeeName: '孙八', contractNumber: 'HT2022006', contractType: '无固定期限劳动合同', startDate: '2022-05-01', endDate: '', status: '生效中' },
    { id: 7, employeeName: '周九', contractNumber: 'HT2021007', contractType: '固定期限劳动合同', startDate: '2021-07-01', endDate: '2024-06-30', status: '生效中' },
    { id: 8, employeeName: '吴十', contractNumber: 'HT2020008', contractType: '劳务派遣合同', startDate: '2020-10-01', endDate: '2023-09-30', status: '已终止' },
    { id: 9, employeeName: '郑十一', contractNumber: 'HT2023009', contractType: '固定期限劳动合同', startDate: '2023-03-01', endDate: '2026-02-28', status: '生效中' },
    { id: 10, employeeName: '冯十二', contractNumber: 'HT2022010', contractType: '无固定期限劳动合同', startDate: '2022-06-01', endDate: '', status: '生效中' },
  ];
  totalRecords.value = mockData.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  contractRecords.value = mockData.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '生效中':
      return 'success';
    case '已到期':
      return 'warning';
    case '已终止':
      return 'danger';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增劳动合同';
  currentContract.value = {
    id: 0,
    employeeName: '',
    contractNumber: '',
    contractType: '固定期限劳动合同',
    startDate: '',
    endDate: '',
    status: '生效中',
  };
  dialogVisible.value = true;
};

const handleView = (row: ContractRecord) => {
  dialogTitle.value = '查看劳动合同';
  currentContract.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleEdit = (row: ContractRecord) => {
  dialogTitle.value = '编辑劳动合同';
  currentContract.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: ContractRecord) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} 的合同编号 ${row.contractNumber} 吗？`, '提示', {
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
  if (currentContract.value.id === 0) {
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
.contract-management-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
