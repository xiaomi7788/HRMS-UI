<template>
  <div class="interview-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>面试流程安排与面试官管理</span>
          <el-button type="primary" @click="handleAdd">安排新面试</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="候选人姓名">
          <el-input v-model="searchForm.candidateName" placeholder="请输入候选人姓名"></el-input>
        </el-form-item>
        <el-form-item label="面试官">
          <el-input v-model="searchForm.interviewer" placeholder="请输入面试官姓名"></el-input>
        </el-form-item>
        <el-form-item label="面试状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待安排" value="待安排"></el-option>
            <el-option label="已安排" value="已安排"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
            <el-option label="已取消" value="已取消"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="interviews" style="width: 100%" border>
        <el-table-column prop="candidateName" label="候选人姓名"></el-table-column>
        <el-table-column prop="position" label="应聘职位"></el-table-column>
        <el-table-column prop="interviewType" label="面试类型"></el-table-column>
        <el-table-column prop="interviewer" label="面试官"></el-table-column>
        <el-table-column prop="interviewDate" label="面试日期"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
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

    <!-- 新增/编辑面试的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentInterview" label-width="100px">
        <el-form-item label="候选人姓名">
          <el-input v-model="currentInterview.candidateName"></el-input>
        </el-form-item>
        <el-form-item label="应聘职位">
          <el-input v-model="currentInterview.position"></el-input>
        </el-form-item>
        <el-form-item label="面试类型">
          <el-select v-model="currentInterview.interviewType" placeholder="请选择面试类型" popper-append-to-body>
            <el-option label="初试" value="初试"></el-option>
            <el-option label="复试" value="复试"></el-option>
            <el-option label="终面" value="终面"></el-option>
            <el-option label="HR面" value="HR面"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="面试官">
          <el-input v-model="currentInterview.interviewer"></el-input>
        </el-form-item>
        <el-form-item label="面试日期">
          <el-date-picker v-model="currentInterview.interviewDate" type="date" placeholder="选择日期"></el-date-picker>
        </el-form-item>
        <el-form-item label="面试时间">
          <el-time-picker v-model="currentInterview.interviewTime" placeholder="选择时间"></el-time-picker>
        </el-form-item>
        <el-form-item label="面试地点/链接">
          <el-input v-model="currentInterview.location"></el-input>
        </el-form-item>
        <el-form-item label="面试状态">
          <el-select v-model="currentInterview.status" placeholder="请选择状态">
            <el-option label="待安排" value="待安排"></el-option>
            <el-option label="已安排" value="已安排"></el-option>
            <el-option label="已完成" value="已完成"></el-option>
            <el-option label="已取消" value="已取消"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input type="textarea" v-model="currentInterview.notes"></el-input>
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

interface Interview {
  id: number;
  candidateName: string;
  position: string;
  interviewType: string;
  interviewer: string;
  interviewDate: string;
  interviewTime: string;
  location: string;
  status: '待安排' | '已安排' | '已完成' | '已取消';
  notes: string;
}

const allInterviews: Interview[] = [
  { id: 1, candidateName: '张小明', position: '高级前端工程师', interviewType: '初试', interviewer: '李工程师', interviewDate: '2024-03-20', interviewTime: '10:00', location: '线上会议', status: '已安排', notes: '' },
  { id: 2, candidateName: '李丽', position: '市场营销专员', interviewType: 'HR面', interviewer: '王HR', interviewDate: '2024-03-22', interviewTime: '14:00', location: '公司会议室', status: '待安排', notes: '' },
  { id: 3, candidateName: '王大锤', position: '销售经理', interviewType: '终面', interviewer: '陈总', interviewDate: '2024-03-18', interviewTime: '11:00', location: '公司会议室', status: '已完成', notes: '表现优秀，建议录用' },
  { id: 4, candidateName: '钱多多', position: '后端开发工程师', interviewType: '复试', interviewer: '赵经理', interviewDate: '2024-03-25', interviewTime: '09:30', location: '线上会议', status: '已安排', notes: '' },
];

const interviews = ref<Interview[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentInterview = ref<Interview>({
  id: 0,
  candidateName: '',
  position: '',
  interviewType: '',
  interviewer: '',
  interviewDate: '',
  interviewTime: '',
  location: '',
  status: '待安排',
  notes: '',
});

const searchForm = ref({
  candidateName: '',
  interviewer: '',
  status: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allInterviews;

  if (searchForm.value.candidateName) {
    filteredRecords = filteredRecords.filter(interview =>
      interview.candidateName.includes(searchForm.value.candidateName)
    );
  }
  if (searchForm.value.interviewer) {
    filteredRecords = filteredRecords.filter(interview =>
      interview.interviewer.includes(searchForm.value.interviewer)
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(interview =>
      interview.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  interviews.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '待安排':
      return 'info';
    case '已安排':
      return '';
    case '已完成':
      return 'success';
    case '已取消':
      return 'danger';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '安排新面试';
  currentInterview.value = {
    id: 0,
    candidateName: '',
    position: '',
    interviewType: '',
    interviewer: '',
    interviewDate: '',
    interviewTime: '',
    location: '',
    status: '待安排',
    notes: '',
  };
  dialogVisible.value = true;
};

const handleView = (row: Interview) => {
  dialogTitle.value = '查看面试详情';
  currentInterview.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleEdit = (row: Interview) => {
  dialogTitle.value = '编辑面试信息';
  currentInterview.value = { ...row };
  dialogVisible.value = true;
};

const handleDelete = (row: Interview) => {
  ElMessageBox.confirm(`确定删除候选人 ${row.candidateName} 的面试安排吗？`, '提示', {
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
  if (currentInterview.value.id === 0) {
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
  searchForm.value.interviewer = '';
  searchForm.value.status = '';
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
.interview-management-container {
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
