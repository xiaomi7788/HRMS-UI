<template>
  <div class="operation-log-list-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>操作日志记录</span>
        </div>
      </template>

      <div class="search-filter-section">
        <el-input
          v-model="searchQuery"
          placeholder="搜索操作用户或内容"
          clearable
          style="width: 250px; margin-right: 10px;"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        />
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 280px; margin-right: 10px;"
          @change="handleSearch"
        />
        <el-button type="primary" @click="handleSearch">查询</el-button>
      </div>

      <el-table :data="paginatedLogs" style="width: 100%; margin-top: 20px;" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="操作用户" width="120" />
        <el-table-column prop="operation" label="操作内容" />
        <el-table-column prop="ipAddress" label="IP地址" width="150" />
        <el-table-column prop="timestamp" label="操作时间" width="180" />
      </el-table>

      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :small="false"
        :disabled="false"
        :background="true"
        layout="total, sizes, prev, pager, next, jumper"
        :total="totalLogs"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
        style="margin-top: 20px; justify-content: flex-end;"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

interface OperationLog {
  id: number;
  username: string;
  operation: string;
  ipAddress: string;
  timestamp: string;
}

const operationLogs = ref<OperationLog[]>([
  { id: 1, username: 'admin', operation: '登录系统', ipAddress: '192.168.1.1', timestamp: '2023-03-14 10:00:00' },
  { id: 2, username: 'admin', operation: '修改用户张三密码', ipAddress: '192.168.1.1', timestamp: '2023-03-14 10:05:30' },
  { id: 3, username: 'lisi', operation: '查看员工档案', ipAddress: '192.168.1.2', timestamp: '2023-03-14 10:10:15' },
  { id: 4, username: 'admin', operation: '新增部门技术部', ipAddress: '192.168.1.1', timestamp: '2023-03-14 10:15:00' },
  { id: 5, username: 'wangwu', operation: '提交请假申请', ipAddress: '192.168.1.3', timestamp: '2023-03-14 10:20:45' },
]);

const searchQuery = ref('');
const dateRange = ref<[Date, Date] | null>(null);
const currentPage = ref(1);
const pageSize = ref(10);

const filteredLogs = computed(() => {
  let result = operationLogs.value;
  if (searchQuery.value) {
    result = result.filter(log =>
      log.username.includes(searchQuery.value) ||
      log.operation.includes(searchQuery.value)
    );
  }
  if (dateRange.value && dateRange.value.length === 2) {
    const [startDate, endDate] = dateRange.value;
    result = result.filter(log => {
      const logDate = new Date(log.timestamp.split(' ')[0]);
      return logDate >= startDate && logDate <= endDate;
    });
  }
  return result;
});

const totalLogs = computed(() => filteredLogs.value.length);

const paginatedLogs = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return filteredLogs.value.slice(start, end);
});

const handleSearch = () => {
  currentPage.value = 1; // 搜索时重置到第一页
};

const handleSizeChange = (val: number) => {
  pageSize.value = val;
  currentPage.value = 1; // 改变每页大小时重置到第一页
};

const handleCurrentChange = (val: number) => {
  currentPage.value = val;
};
</script>

<style scoped>
.operation-log-list-container {
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
