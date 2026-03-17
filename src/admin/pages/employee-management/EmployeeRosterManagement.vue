<template>
  <div class="employee-roster-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工花名册管理</span>
          <el-button type="primary" @click="handleAdd">新增员工</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
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
        <el-form-item label="岗位">
          <el-input v-model="searchForm.position" placeholder="请输入岗位"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="employeeRoster" style="width: 100%" border>
        <el-table-column prop="employeeId" label="员工编号"></el-table-column>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="gender" label="性别"></el-table-column>
        <el-table-column prop="department" label="部门"></el-table-column>
        <el-table-column prop="position" label="岗位"></el-table-column>
        <el-table-column prop="entryDate" label="入职日期"></el-table-column>
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

    <!-- 新增/编辑员工的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="50%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentEmployee" label-width="100px">
        <el-form-item label="员工编号">
          <el-input v-model="currentEmployee.employeeId"></el-input>
        </el-form-item>
        <el-form-item label="员工姓名">
          <el-input v-model="currentEmployee.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="currentEmployee.gender">
            <el-radio label="男">男</el-radio>
            <el-radio label="女">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="部门">
          <el-select v-model="currentEmployee.department" placeholder="请选择部门">
            <el-option label="销售部" value="销售部"></el-option>
            <el-option label="市场部" value="市场部"></el-option>
            <el-option label="技术部" value="技术部"></el-option>
            <el-option label="人事部" value="人事部"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="岗位">
          <el-input v-model="currentEmployee.position"></el-input>
        </el-form-item>
        <el-form-item label="入职日期">
          <el-date-picker v-model="currentEmployee.entryDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentEmployee.status" placeholder="请选择员工状态">
            <el-option label="在职" value="在职"></el-option>
            <el-option label="离职" value="离职"></el-option>
            <el-option label="休假" value="休假"></el-option>
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

interface Employee {
  id: number;
  employeeId: string;
  employeeName: string;
  gender: '男' | '女';
  department: string;
  position: string;
  entryDate: string;
  status: '在职' | '离职' | '休假';
}

const allEmployees: Employee[] = [
  { id: 1, employeeId: 'EMP001', employeeName: '张三', gender: '男', department: '销售部', position: '销售经理', entryDate: '2020-01-01', status: '在职' },
  { id: 2, employeeId: 'EMP002', employeeName: '李四', gender: '女', department: '市场部', position: '市场专员', entryDate: '2021-03-15', status: '在职' },
  { id: 3, employeeId: 'EMP003', employeeName: '王五', gender: '男', department: '技术部', position: '前端工程师', entryDate: '2022-07-01', status: '在职' },
  { id: 4, employeeId: 'EMP004', employeeName: '赵六', gender: '女', department: '人事部', position: 'HRBP', entryDate: '2019-11-01', status: '离职' },
  { id: 5, employeeId: 'EMP005', employeeName: '钱七', gender: '男', department: '销售部', position: '销售代表', entryDate: '2023-02-01', status: '在职' },
  { id: 6, employeeId: 'EMP006', employeeName: '孙八', gender: '女', department: '市场部', position: '市场经理', entryDate: '2020-05-01', status: '在职' },
  { id: 7, employeeId: 'EMP007', employeeName: '周九', gender: '男', department: '技术部', position: '后端工程师', entryDate: '2021-08-01', status: '在职' },
  { id: 8, employeeId: 'EMP008', employeeName: '吴十', gender: '女', department: '人事部', position: '招聘专员', entryDate: '2022-01-01', status: '在职' },
  { id: 9, employeeId: 'EMP009', employeeName: '郑十一', gender: '男', department: '销售部', position: '销售代表', entryDate: '2023-04-01', status: '在职' },
  { id: 10, employeeId: 'EMP010', employeeName: '冯十二', gender: '女', department: '市场部', position: '品牌经理', entryDate: '2020-09-01', status: '休假' },
];

const employeeRoster = ref<Employee[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentEmployee = ref<Employee>({
  id: 0,
  employeeId: '',
  employeeName: '',
  gender: '男',
  department: '',
  position: '',
  entryDate: '',
  status: '在职',
});

const searchForm = ref({
  employeeName: '',
  department: '',
  position: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allEmployees;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(employee =>
      employee.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.department) {
    filteredRecords = filteredRecords.filter(employee =>
      employee.department === searchForm.value.department
    );
  }
  if (searchForm.value.position) {
    filteredRecords = filteredRecords.filter(employee =>
      employee.position.includes(searchForm.value.position)
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  employeeRoster.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '在职':
      return 'success';
    case '离职':
      return 'danger';
    case '休假':
      return 'info';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增员工';
  currentEmployee.value = {
    id: 0,
    employeeId: '',
    employeeName: '',
    gender: '男',
    department: '',
    position: '',
    entryDate: '',
    status: '在职',
  };
  dialogVisible.value = true;
};

const handleView = (row: Employee) => {
  dialogTitle.value = '查看员工信息';
  currentEmployee.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleEdit = (row: Employee) => {
  dialogTitle.value = '编辑员工信息';
  currentEmployee.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: Employee) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} (编号: ${row.employeeId}) 吗？`, '提示', {
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
  if (currentEmployee.value.id === 0) {
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
  searchForm.value.employeeName = '';
  searchForm.value.department = '';
  searchForm.value.position = '';
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
.employee-roster-management-container {
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
