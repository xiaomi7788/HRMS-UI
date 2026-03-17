<template>
  <div class="employee-lifecycle-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工入转调离管理</span>
          <el-button type="primary" @click="handleAdd">新增记录</el-button>
        </div>
      </template>
      <el-table :data="lifecycleRecords" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="type" label="异动类型">
          <template #default="{ row }">
            <el-tag :type="getTypeTag(row.type)">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="date" label="异动日期"></el-table-column>
        <el-table-column prop="description" label="描述"></el-table-column>
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

    <!-- 新增/编辑记录的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentRecord" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentRecord.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="异动类型">
          <el-select v-model="currentRecord.type" placeholder="请选择异动类型" popper-append-to-body>
            <el-option label="入职" value="入职"></el-option>
            <el-option label="转正" value="转正"></el-option>
            <el-option label="调动" value="调动"></el-option>
            <el-option label="离职" value="离职"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="异动日期">
          <el-date-picker v-model="currentRecord.date" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="描述">
          <el-input type="textarea" v-model="currentRecord.description"></el-input>
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

interface LifecycleRecord {
  id: number;
  employeeName: string;
  type: '入职' | '转正' | '调动' | '离职';
  date: string;
  description: string;
}

const lifecycleRecords = ref<LifecycleRecord[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentRecord = ref<LifecycleRecord>({
  id: 0,
  employeeName: '',
  type: '入职',
  date: '',
  description: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  // 模拟从后端获取数据
  const mockData: LifecycleRecord[] = [
    { id: 1, employeeName: '张三', type: '入职', date: '2023-01-01', description: '新员工入职' },
    { id: 2, employeeName: '李四', type: '转正', date: '2023-04-01', description: '试用期通过，正式转正' },
    { id: 3, employeeName: '王五', type: '调动', date: '2023-06-15', description: '从销售部调动至市场部' },
    { id: 4, employeeName: '赵六', type: '离职', date: '2023-09-30', description: '个人原因离职' },
    { id: 5, employeeName: '钱七', type: '入职', date: '2023-02-01', description: '新员工入职' },
    { id: 6, employeeName: '孙八', type: '转正', date: '2023-05-01', description: '试用期通过，正式转正' },
    { id: 7, employeeName: '周九', type: '调动', date: '2023-07-15', description: '从技术部调动至研发部' },
    { id: 8, employeeName: '吴十', type: '离职', date: '2023-10-30', description: '合同到期离职' },
    { id: 9, employeeName: '郑十一', type: '入职', date: '2023-03-01', description: '新员工入职' },
    { id: 10, employeeName: '冯十二', type: '转正', date: '2023-06-01', description: '试用期通过，正式转正' },
    { id: 11, employeeName: '陈十三', type: '调动', date: '2023-08-15', description: '从人事部调动至行政部' },
    { id: 12, employeeName: '褚十四', type: '离职', date: '2023-11-30', description: '身体原因离职' },
  ];
  totalRecords.value = mockData.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  lifecycleRecords.value = mockData.slice(start, end);
};

const getTypeTag = (type: string) => {
  switch (type) {
    case '入职':
      return 'success';
    case '转正':
      return ''; // 默认类型
    case '调动':
      return 'warning';
    case '离职':
      return 'danger';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增员工异动记录';
  currentRecord.value = {
    id: 0,
    employeeName: '',
    type: '入职',
    date: '',
    description: '',
  };
  dialogVisible.value = true;
};

const handleView = (row: LifecycleRecord) => {
  dialogTitle.value = '查看员工异动记录';
  currentRecord.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleEdit = (row: LifecycleRecord) => {
  dialogTitle.value = '编辑员工异动记录';
  currentRecord.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: LifecycleRecord) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} 的 ${row.type} 记录吗？`, '提示', {
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
  if (currentRecord.value.id === 0) {
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
.employee-lifecycle-management-container {
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
