<template>
  <div class="self-attendance">
    <el-card class="attendance-card">
      <template #header>
        <span>我的考勤</span>
      </template>

      <!-- 表格 -->
      <el-table :data="recordList" v-loading="loading" stripe>
        <el-table-column prop="attendanceDate" label="日期" width="120">
          <template #default="{ row }">
            {{ formatDate(row.attendanceDate) }}
          </template>
        </el-table-column>
        <el-table-column prop="employeeName" label="姓名" width="100">
          <template #default="{ row }">
            {{ row.employeeName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="deptName" label="部门" width="120">
          <template #default="{ row }">
            {{ row.deptName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="checkInTime" label="签到时间" width="180">
          <template #default="{ row }">
            {{ formatTime(row.checkInTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="checkOutTime" label="签退时间" width="180">
          <template #default="{ row }">
            {{ formatTime(row.checkOutTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="workHours" label="工作时长" width="100">
          <template #default="{ row }">
            {{ row.workHours ? row.workHours + '小时' : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusName(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.remark || '-' }}
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        @change="handleQuery"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getAttendanceRecords,
  type AttendanceRecord
} from '@/api/self'

const loading = ref(false)
const recordList = ref<AttendanceRecord[]>([])
const total = ref(0)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20
})

function formatDate(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN')
}

function formatTime(time: string) {
  if (!time) return '-'
  const date = new Date(time)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

function getStatusName(status: number) {
  const map: Record<number, string> = {
    0: '正常',
    1: '迟到',
    2: '早退',
    3: '缺勤',
    4: '请假',
    5: '加班'
  }
  return map[status] || '未知'
}

function getStatusTagType(status: number) {
  const map: Record<number, string> = {
    0: 'success',
    1: 'warning',
    2: 'warning',
    3: 'danger',
    4: 'info',
    5: 'primary'
  }
  return map[status] || ''
}

async function handleQuery() {
  loading.value = true
  try {
    const result = await getAttendanceRecords(queryParams)
    recordList.value = result.records || []
    total.value = Number(result.total || 0)
  } catch (error) {
    ElMessage.error('获取考勤记录失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.self-attendance {
  padding: 20px;
}

.attendance-card {
  max-width: 1400px;
  margin: 0 auto;
}
</style>
