<template>
  <div class="personnel-movement-statistics-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>人事异动查询与统计</span>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="异动类型">
          <el-select v-model="searchForm.type" placeholder="请选择异动类型">
            <el-option label="全部" value=""></el-option>
            <el-option label="入职" value="入职"></el-option>
            <el-option label="转正" value="转正"></el-option>
            <el-option label="调动" value="调动"></el-option>
            <el-option label="离职" value="离职"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="异动日期">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="movementRecords" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="type" label="异动类型">
          <template #default="{ row }">
            <el-tag :type="getTypeTag(row.type)">{{ row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="date" label="异动日期"></el-table-column>
        <el-table-column prop="description" label="描述"></el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看</el-button>
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

    <!-- 查看详情的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="异动记录详情"
      width="40%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentRecord" label-width="100px">
        <el-form-item label="员工姓名">{{ currentRecord.employeeName }}</el-form-item>
        <el-form-item label="异动类型">{{ currentRecord.type }}</el-form-item>
        <el-form-item label="异动日期">{{ currentRecord.date }}</el-form-item>
        <el-form-item label="描述">{{ currentRecord.description }}</el-form-item>
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

interface MovementRecord {
  id: number;
  employeeName: string;
  type: '入职' | '转正' | '调动' | '离职';
  date: string;
  description: string;
}

const allMovementRecords: MovementRecord[] = [
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

const movementRecords = ref<MovementRecord[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const currentRecord = ref<MovementRecord>({
  id: 0,
  employeeName: '',
  type: '入职',
  date: '',
  description: '',
});

const searchForm = ref({
  employeeName: '',
  type: '',
  dateRange: [],
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allMovementRecords;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(record =>
      record.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.type) {
    filteredRecords = filteredRecords.filter(record =>
      record.type === searchForm.value.type
    );
  }
  if (searchForm.value.dateRange && searchForm.value.dateRange.length === 2) {
    const [startDate, endDate] = searchForm.value.dateRange;
    filteredRecords = filteredRecords.filter(record => {
      const recordDate = new Date(record.date);
      return recordDate >= new Date(startDate) && recordDate <= new Date(endDate);
    });
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  movementRecords.value = filteredRecords.slice(start, end);
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

const handleSearch = () => {
  currentPage.value = 1;
  fetchRecords();
};

const handleReset = () => {
  searchForm.value = {
    employeeName: '',
    type: '',
    dateRange: [],
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: MovementRecord) => {
  currentRecord.value = { ...row };
  dialogVisible.value = true;
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
.personnel-movement-statistics-container {
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
