<template>
  <div class="performance-tracking-feedback-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>绩效过程跟踪与反馈记录</span>
          <el-button type="primary" @click="handleAdd">新增反馈</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="员工姓名">
          <el-input v-model="searchForm.employeeName" placeholder="请输入员工姓名"></el-input>
        </el-form-item>
        <el-form-item label="反馈日期">
          <el-date-picker
            v-model="searchForm.feedbackDateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          ></el-date-picker>
        </el-form-item>
        <el-form-item label="反馈类型">
          <el-select v-model="searchForm.feedbackType" placeholder="请选择反馈类型">
            <el-option label="全部" value=""></el-option>
            <el-option label="阶段性反馈" value="阶段性反馈"></el-option>
            <el-option label="即时反馈" value="即时反馈"></el-option>
            <el-option label="辅导记录" value="辅导记录"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="feedbackRecords" style="width: 100%" border>
        <el-table-column prop="employeeName" label="员工姓名"></el-table-column>
        <el-table-column prop="feedbackDate" label="反馈日期"></el-table-column>
        <el-table-column prop="feedbackType" label="反馈类型"></el-table-column>
        <el-table-column prop="feedbackProvider" label="反馈人"></el-table-column>
        <el-table-column prop="content" label="反馈内容"></el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
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

    <!-- 新增/编辑反馈的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentRecord" label-width="100px">
        <el-form-item label="员工姓名">
          <el-input v-model="currentRecord.employeeName"></el-input>
        </el-form-item>
        <el-form-item label="反馈日期">
          <el-date-picker v-model="currentRecord.feedbackDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="反馈类型">
          <el-select v-model="currentRecord.feedbackType" placeholder="请选择反馈类型" :teleported="true">
            <el-option label="阶段性反馈" value="阶段性反馈"></el-option>
            <el-option label="即时反馈" value="即时反馈"></el-option>
            <el-option label="辅导记录" value="辅导记录"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="反馈人">
          <el-input v-model="currentRecord.feedbackProvider"></el-input>
        </el-form-item>
        <el-form-item label="反馈内容">
          <el-input type="textarea" v-model="currentRecord.content" :rows="5"></el-input>
        </el-form-item>
        <el-form-item label="改进计划">
          <el-input type="textarea" v-model="currentRecord.improvementPlan" :rows="3"></el-input>
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

interface FeedbackRecord {
  id: number;
  employeeName: string;
  feedbackDate: string;
  feedbackType: '阶段性反馈' | '即时反馈' | '辅导记录';
  feedbackProvider: string;
  content: string;
  improvementPlan: string;
}

const allFeedbackRecords: FeedbackRecord[] = [
  { id: 1, employeeName: '张三', feedbackDate: '2024-03-15', feedbackType: '阶段性反馈', feedbackProvider: '李经理', content: '本季度目标完成度良好，但在团队协作方面有提升空间。', improvementPlan: '参与团队协作培训，多与同事沟通。' },
  { id: 2, employeeName: '李四', feedbackDate: '2024-03-10', feedbackType: '即时反馈', feedbackProvider: '王总监', content: '在项目演示中表现出色，逻辑清晰，表达流畅。', improvementPlan: '' },
  { id: 3, employeeName: '王五', feedbackDate: '2024-03-01', feedbackType: '辅导记录', feedbackProvider: '赵导师', content: '针对新技术的学习进行了辅导，王五已掌握基本概念。', improvementPlan: '继续深入学习，实践项目。' },
];

const feedbackRecords = ref<FeedbackRecord[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentRecord = ref<FeedbackRecord>({
  id: 0,
  employeeName: '',
  feedbackDate: '',
  feedbackType: '阶段性反馈',
  feedbackProvider: '',
  content: '',
  improvementPlan: '',
});

const searchForm = ref({
  employeeName: '',
  feedbackDateRange: [],
  feedbackType: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allFeedbackRecords;

  if (searchForm.value.employeeName) {
    filteredRecords = filteredRecords.filter(record =>
      record.employeeName.includes(searchForm.value.employeeName)
    );
  }
  if (searchForm.value.feedbackDateRange && searchForm.value.feedbackDateRange.length === 2) {
    const [startDate, endDate] = searchForm.value.feedbackDateRange;
    filteredRecords = filteredRecords.filter(record => {
      const recordDate = new Date(record.feedbackDate);
      return recordDate >= new Date(startDate) && recordDate <= new Date(endDate);
    });
  }
  if (searchForm.value.feedbackType) {
    filteredRecords = filteredRecords.filter(record =>
      record.feedbackType === searchForm.value.feedbackType
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  feedbackRecords.value = filteredRecords.slice(start, end);
};

const handleAdd = () => {
  dialogTitle.value = '新增反馈记录';
  currentRecord.value = {
    id: 0,
    employeeName: '',
    feedbackDate: '',
    feedbackType: '阶段性反馈',
    feedbackProvider: '',
    content: '',
    improvementPlan: '',
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
    feedbackDateRange: [],
    feedbackType: '',
  };
  currentPage.value = 1;
  fetchRecords();
};

const handleView = (row: FeedbackRecord) => {
  dialogTitle.value = '查看反馈详情';
  currentRecord.value = { ...row };
  dialogVisible.value = true;
};

const handleEdit = (row: FeedbackRecord) => {
  dialogTitle.value = '编辑反馈记录';
  currentRecord.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: FeedbackRecord) => {
  ElMessageBox.confirm(`确定删除员工 ${row.employeeName} 的反馈记录吗？`, '提示', {
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
.performance-tracking-feedback-container {
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
