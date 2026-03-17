<template>
  <div class="candidate-management-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>候选人简历库与人才池管理</span>
          <el-button type="primary" @click="handleAdd">新增候选人</el-button>
        </div>
      </template>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="姓名">
          <el-input v-model="searchForm.name" placeholder="请输入姓名"></el-input>
        </el-form-item>
        <el-form-item label="职位">
          <el-input v-model="searchForm.position" placeholder="请输入应聘职位"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态">
            <el-option label="全部" value=""></el-option>
            <el-option label="待处理" value="待处理"></el-option>
            <el-option label="面试中" value="面试中"></el-option>
            <el-option label="已录用" value="已录用"></el-option>
            <el-option label="已淘汰" value="已淘汰"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="candidates" style="width: 100%" border>
        <el-table-column prop="name" label="姓名"></el-table-column>
        <el-table-column prop="gender" label="性别"></el-table-column>
        <el-table-column prop="age" label="年龄"></el-table-column>
        <el-table-column prop="position" label="应聘职位"></el-table-column>
        <el-table-column prop="contact" label="联系方式"></el-table-column>
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusTag(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看简历</el-button>
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

    <!-- 新增/编辑候选人的对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="60%"
      :before-close="handleCloseDialog"
    >
      <el-form :model="currentCandidate" label-width="100px">
        <el-form-item label="姓名">
          <el-input v-model="currentCandidate.name"></el-input>
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="currentCandidate.gender">
            <el-radio label="男">男</el-radio>
            <el-radio label="女">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="年龄">
          <el-input-number v-model="currentCandidate.age" :min="18" :max="60"></el-input-number>
        </el-form-item>
        <el-form-item label="应聘职位">
          <el-input v-model="currentCandidate.position"></el-input>
        </el-form-item>
        <el-form-item label="联系方式">
          <el-input v-model="currentCandidate.contact"></el-input>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="currentCandidate.email"></el-input>
        </el-form-item>
        <el-form-item label="简历">
          <el-upload
            class="upload-demo"
            action="https://jsonplaceholder.typicode.com/posts/"
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :file-list="fileList"
            list-type="text"
          >
            <el-button type="primary">点击上传</el-button>
            <template #tip>
              <div class="el-upload__tip">
                支持PDF、DOC、DOCX等格式，大小不超过5MB
              </div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="currentCandidate.status" placeholder="请选择状态">
            <el-option label="待处理" value="待处理"></el-option>
            <el-option label="面试中" value="面试中"></el-option>
            <el-option label="已录用" value="已录用"></el-option>
            <el-option label="已淘汰" value="已淘汰"></el-option>
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
import { ElMessage, ElMessageBox, type UploadUserFile } from 'element-plus';

interface Candidate {
  id: number;
  name: string;
  gender: '男' | '女';
  age: number;
  position: string;
  contact: string;
  email: string;
  resumeUrl: string;
  status: '待处理' | '面试中' | '已录用' | '已淘汰';
}

const allCandidates: Candidate[] = [
  { id: 1, name: '张小明', gender: '男', age: 28, position: '高级前端工程师', contact: '13800001111', email: 'zhangxm@example.com', resumeUrl: 'resume_zhangxm.pdf', status: '面试中' },
  { id: 2, name: '李丽', gender: '女', age: 25, position: '市场营销专员', contact: '13900002222', email: 'lili@example.com', resumeUrl: 'resume_lili.docx', status: '待处理' },
  { id: 3, name: '王大锤', gender: '男', age: 30, position: '销售经理', contact: '13700003333', email: 'wangdc@example.com', resumeUrl: 'resume_wangdc.pdf', status: '已录用' },
  { id: 4, name: '赵敏', gender: '女', age: 26, position: '人力资源专员', contact: '13600004444', email: 'zhaom@example.com', resumeUrl: 'resume_zhaom.pdf', status: '已淘汰' },
  { id: 5, name: '钱多多', gender: '男', age: 29, position: '后端开发工程师', contact: '13500005555', email: 'qiandd@example.com', resumeUrl: 'resume_qiandd.pdf', status: '面试中' },
];

const candidates = ref<Candidate[]>([]);
const currentPage = ref(1);
const pageSize = ref(10);
const totalRecords = ref(0);
const dialogVisible = ref(false);
const dialogTitle = ref('');
const currentCandidate = ref<Candidate>({
  id: 0,
  name: '',
  gender: '男',
  age: 0,
  position: '',
  contact: '',
  email: '',
  resumeUrl: '',
  status: '待处理',
});

const searchForm = ref({
  name: '',
  position: '',
  status: '',
});

const fileList = ref<UploadUserFile[]>([]);

onMounted(() => {
  fetchRecords();
});

const fetchRecords = () => {
  let filteredRecords = allCandidates;

  if (searchForm.value.name) {
    filteredRecords = filteredRecords.filter(candidate =>
      candidate.name.includes(searchForm.value.name)
    );
  }
  if (searchForm.value.position) {
    filteredRecords = filteredRecords.filter(candidate =>
      candidate.position.includes(searchForm.value.position)
    );
  }
  if (searchForm.value.status) {
    filteredRecords = filteredRecords.filter(candidate =>
      candidate.status === searchForm.value.status
    );
  }

  totalRecords.value = filteredRecords.length;
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  candidates.value = filteredRecords.slice(start, end);
};

const getStatusTag = (status: string) => {
  switch (status) {
    case '待处理':
      return 'info';
    case '面试中':
      return '';
    case '已录用':
      return 'success';
    case '已淘汰':
      return 'danger';
    default:
      return '';
  }
};

const handleAdd = () => {
  dialogTitle.value = '新增候选人';
  currentCandidate.value = {
    id: 0,
    name: '',
    gender: '男',
    age: 0,
    position: '',
    contact: '',
    email: '',
    resumeUrl: '',
    status: '待处理',
  };
  fileList.value = [];
  dialogVisible.value = true;
};

const handleView = (row: Candidate) => {
  dialogTitle.value = '查看候选人简历';
  currentCandidate.value = { ...row };
  // 模拟简历文件列表
  fileList.value = row.resumeUrl ? [{ name: row.resumeUrl, url: '#' }] : [];
  dialogVisible.value = true;
  // 实际项目中，这里可能需要禁用表单编辑，并提供简历下载链接
};

const handleEdit = (row: Candidate) => {
  dialogTitle.value = '编辑候选人信息';
  currentCandidate.value = { ...row };
  fileList.value = row.resumeUrl ? [{ name: row.resumeUrl, url: '#' }] : [];
  dialogVisible.value = true;
};

const handleDelete = (row: Candidate) => {
  ElMessageBox.confirm(`确定删除候选人 ${row.name} 吗？`, '提示', {
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
  if (currentCandidate.value.id === 0) {
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
  searchForm.value.name = '';
  searchForm.value.position = '';
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

const handleRemove = (file: any, fileList: any) => {
  console.log(file, fileList);
  ElMessage.info(`文件 ${file.name} 已移除`);
};

const handlePreview = (file: any) => {
  console.log(file);
  ElMessage.info(`预览文件 ${file.name}`);
  // 实际项目中，这里会打开文件预览或下载
};
</script>

<style scoped>
.candidate-management-container {
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
