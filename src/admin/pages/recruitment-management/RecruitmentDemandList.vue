<template>
  <div class="recruitment-demand-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>招聘需求管理</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索职位名称或部门"
          clearable
          style="width: 250px; margin-right: 10px;"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        />
        <el-select
          v-model="filterStatus"
          placeholder="筛选状态"
          style="width: 120px; margin-right: 10px;"
          @change="handleFilter"
        >
          <el-option label="所有" value="所有" />
          <el-option label="招聘中" value="招聘中" />
          <el-option label="已完成" value="已完成" />
          <el-option label="已暂停" value="已暂停" />
        </el-select>
        <el-button type="primary" @click="handleSearch">查询</el-button>
        <el-button type="success" @click="addRecruitmentDemand">新增需求</el-button>
      </div>

      <el-table :data="paginatedDemands" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" />
        <el-table-column prop="position" label="职位名称" />
        <el-table-column prop="department" label="需求部门" />
        <el-table-column prop="count" label="需求人数" />
        <el-table-column prop="status" label="状态">
          <template #default="scope">
            <el-tag :type="getStatusTagType(scope.row.status)">
              {{ scope.row.status }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="publishDate" label="发布日期" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="editRecruitmentDemand(scope.row.id)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteRecruitmentDemand(scope.row.id)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :small="false"
        :disabled="false"
        :background="true"
        layout="total, sizes, prev, pager, next, jumper"
        :total="totalDemands"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';

interface RecruitmentDemand {
  id: number;
  position: string;
  department: string;
  count: number;
  status: '招聘中' | '已完成' | '已暂停';
  publishDate: string;
}

const recruitmentDemands = ref<RecruitmentDemand[]>([
  { id: 1, position: '前端开发工程师', department: '技术部', count: 2, status: '招聘中', publishDate: '2023-01-01' },
  { id: 2, position: '后端开发工程师', department: '技术部', count: 3, status: '招聘中', publishDate: '2023-01-05' },
  { id: 3, position: 'HRBP', department: '人力资源部', count: 1, status: '已完成', publishDate: '2023-01-10' },
  { id: 4, position: '市场专员', department: '市场部', count: 1, status: '招聘中', publishDate: '2023-01-15' },
  { id: 5, position: '销售经理', department: '销售部', count: 2, status: '已暂停', publishDate: '2023-01-20' },
]);

const searchQuery = ref('');
const filterStatus = ref('所有');
const currentPage = ref(1);
const pageSize = ref(10);

const filteredDemands = computed(() => {
  let result = recruitmentDemands.value;
  if (filterStatus.value !== '所有') {
    result = result.filter(demand => demand.status === filterStatus.value);
  }
  if (searchQuery.value) {
    result = result.filter(demand =>
      demand.position.includes(searchQuery.value) ||
      demand.department.includes(searchQuery.value)
    );
  }
  return result;
});

const totalDemands = computed(() => filteredDemands.value.length);

const paginatedDemands = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredDemands.value.slice(start, end);
});

const getStatusTagType = (status: RecruitmentDemand['status']) => {
  switch (status) {
    case '招聘中':
      return 'success';
    case '已完成':
      return 'info';
    case '已暂停':
      return 'warning';
    default:
      return '';
  }
};

const handleSearch = () => {
  currentPage.value = 1; // 搜索时重置到第一页
};

const handleFilter = () => {
  currentPage.value = 1; // 筛选时重置到第一页
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  currentPage.value = 1; // 改变每页大小时重置到第一页
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
};

const addRecruitmentDemand = () => {
  ElMessage.info('新增招聘需求功能待实现');
};

const editRecruitmentDemand = (demandId: number) => {
  ElMessage.info(`编辑招聘需求 ${demandId} 功能待实现`);
};

const deleteRecruitmentDemand = (demandId: number) => {
  ElMessageBox.confirm('此操作将永久删除该招聘需求, 是否继续?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      const index = recruitmentDemands.value.findIndex(d => d.id === demandId);
      if (index !== -1) {
        recruitmentDemands.value.splice(index, 1);
        ElMessage.success('删除成功!');
      }
    })
    .catch(() => {
      ElMessage.info('已取消删除');
    });
};
</script>

<style scoped>
.recruitment-demand-list-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-filter-section {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}
</style>
