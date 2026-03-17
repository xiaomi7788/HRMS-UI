<template>
  <div class="job-posting-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>职位发布管理</span>
          <el-button type="primary" @click="handleAdd">发布新职位</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="职位名称">
          <el-input v-model="searchForm.jobTitle" placeholder="请输入职位名称"></el-input>
        </el-form-item>
        <el-form-item label="发布状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="已发布" value="已发布"></el-option>
            <el-option label="草稿" value="草稿"></el-option>
            <el-option label="已下线" value="已下线"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="jobPostings" style="width: 100%" border>
        <el-table-column prop="jobTitle" label="职位名称"></el-table-column>
        <el-table-column prop="department" label="所属部门"></el-table-column>
        <el-table-column prop="location" label="工作地点"></el-table-column>
        <el-table-column prop="publishDate" label="发布日期"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="scope">
            <div style="display: flex; gap: 5px;">
              <el-button size="small" @click="handleView(scope.row)">查看</el-button>
              <el-button size="small" @click="handleEdit(scope.row)">编辑</el-button>
              <el-button size="small" type="warning" @click="handleToggleStatus(scope.row)">
                {{ scope.row.status === '已发布' ? '下线' : '发布' }}
              </el-button>
              <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
            </div>
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

    <!-- 新增/编辑职位的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentJob" label-width="100px">
        <el-form-item label="职位名称">
          <el-input v-model="currentJob.jobTitle"></el-input>
        </el-form-item>
        <el-form-item label="所属部门">
          <el-select v-model="currentJob.department" placeholder="请选择部门" popper-append-to-body>
            <el-option label="销售部" value="销售部"></el-option>
            <el-option label="市场部" value="市场部"></el-option>
            <el-option label="技术部" value="技术部"></el-option>
            <el-option label="人事部" value="人事部"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="工作地点">
          <el-input v-model="currentJob.location"></el-input>
        </el-form-item>
        <el-form-item label="职位描述">
          <el-input type="textarea" v-model="currentJob.description" :rows="5"></el-input>
        </el-form-item>
        <el-form-item label="发布状态">
          <el-radio-group v-model="currentJob.status">
            <el-radio label="草稿">草稿</el-radio>
            <el-radio label="已发布">已发布</el-radio>
            <el-radio label="已下线">已下线</el-radio>
          </el-radio-group>
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

interface JobPosting {
  id: number;
  jobTitle: string;
  department: string;
  location: string;
  description: string;
  publishDate: string;
  status: '草稿' | '已发布' | '已下线';
}

const allJobPostings: JobPosting[] = [
  { id: 1, jobTitle: '高级前端工程师', department: '技术部', location: '上海', description: '负责前端架构设计与开发', publishDate: '2023-01-01', status: '已发布' },
  { id: 2, jobTitle: '市场营销专员', department: '市场部', location: '北京', description: '负责市场活动策划与执行', publishDate: '2023-02-15', status: '已发布' },
  { id: 3, jobTitle: '销售经理', department: '销售部', location: '深圳', description: '负责区域销售团队管理', publishDate: '2023-03-01', status: '已发布' },
  { id: 4, jobTitle: '人力资源专员', department: '人事部', location: '广州', description: '负责招聘与员工关系维护', publishDate: '2023-04-10', status: '草稿' },
  { id: 5, jobTitle: '后端开发工程师', department: '技术部', location: '上海', description: '负责后端服务开发与维护', publishDate: '2023-05-01', status: '已发布' },
  { id: 6, jobTitle: '品牌策划', department: '市场部', location: '北京', description: '负责品牌策略制定与推广', publishDate: '2023-06-01', status: '已下线' },
];

const jobPostings = ref<JobPosting[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentJob = ref<JobPosting>({
  id: 0,
  jobTitle: '',
  department: '',
  location: '',
  description: '',
  publishDate: '',
  status: '草稿',
});

const searchForm = ref({
  jobTitle: '',
  status: '',
});

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allJobPostings;

  if (searchForm.value.jobTitle) {
    filteredRecords = filteredRecords.filter(job =>
      job.jobTitle.includes(searchForm.value.jobTitle)
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(job =>
      job.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  jobPostings.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '已发布':
      return 'success';
    case '草稿':
      return 'info';
    case '已下线':
      return 'danger';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '发布新职位';
  currentJob.value = {
    id: 0,
    jobTitle: '',
    department: '',
    location: '',
    description: '',
    publishDate: '',
    status: '草稿',
  };
  dialogVisible.value = true;
};

const handleView = (row: JobPosting) => {
  dialogTitle.value = '查看职位详情';
  currentJob.value = { ...row };
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑
};

const handleEdit = (row: JobPosting) => {
  dialogTitle.value = '编辑职位';
  currentJob.value = { ...row };
  dialogVisible.value = true;
};

const handleToggleStatus = (row: JobPosting) => {
  const newStatus = row.status === '已发布' ? '已下线' : '已发布';
  ElMessageBox.confirm(`确定将职位《${row.jobTitle}》${newStatus === '已发布' ? '发布' : '下线'}吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      // 模拟更新状态
      row.status = newStatus;
      ElMessage.success(`${newStatus === '已发布' ? '发布' : '下线'}成功！`);
      fetchRecords(); // 重新加载数据
    })
    .catch(() => {
      ElMessage.info('已取消操作');
    });
};

const handleDelete = (row: JobPosting) => {
  ElMessageBox.confirm(`确定删除职位《${row.jobTitle}》吗？`, '提示', {
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
  if (currentJob.value.id === 0) {
    // 新增
    currentJob.value.publishDate = new Date().toISOString().slice(0, 10); // 模拟设置发布日期
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
  searchForm.value.jobTitle = '';
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
.job-posting-management-container {
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
