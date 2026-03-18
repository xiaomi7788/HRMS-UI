<template>
  <div class="self-training">
    <el-card class="training-card">
      <template #header>
        <span>我的培训</span>
      </template>

      <el-empty v-if="activityList.length === 0" description="暂无培训活动" />

      <div v-else class="activity-list">
        <el-card v-for="activity in activityList" :key="activity.id" class="activity-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="title">{{ activity.title }}</span>
              <el-tag :type="getStatusTagType(activity.status)">
                {{ getStatusName(activity.status) }}
              </el-tag>
            </div>
          </template>

          <div class="activity-content">
            <div class="info-row">
              <el-icon><Calendar /></el-icon>
              <span>培训时间：{{ formatDate(activity.startDate) }} - {{ formatDate(activity.endDate) }}</span>
            </div>
            <div class="info-row" v-if="activity.location">
              <el-icon><Location /></el-icon>
              <span>培训地点：{{ activity.location }}</span>
            </div>
            <div class="info-row" v-if="activity.registrationDeadline">
              <el-icon><Clock /></el-icon>
              <span>报名截止：{{ formatDate(activity.registrationDeadline) }}</span>
            </div>
            <div class="info-row">
              <el-icon><User /></el-icon>
              <span>参与人数：{{ activity.currentParticipants || 0 }} / {{ activity.maxParticipants || '不限' }}</span>
            </div>
          </div>
        </el-card>
      </div>

      <!-- 分页 -->
      <el-pagination
        v-if="total > 0"
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
import { Calendar, Location, User, Clock } from '@element-plus/icons-vue'
import {
  getTrainingActivities,
  type TrainingActivity
} from '@/api/self'

const loading = ref(false)
const activityList = ref<TrainingActivity[]>([])
const total = ref(0)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10
})

function formatDate(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN')
}

function getStatusName(status: number) {
  const map: Record<number, string> = {
    0: '草稿',
    1: '报名中',
    2: '进行中',
    3: '已完成',
    4: '已取消'
  }
  return map[status] || '未知'
}

function getStatusTagType(status: number) {
  const map: Record<number, string> = {
    0: 'info',
    1: 'primary',
    2: 'warning',
    3: 'success',
    4: 'danger'
  }
  return map[status] || ''
}

async function handleQuery() {
  loading.value = true
  try {
    const result = await getTrainingActivities(queryParams)
    activityList.value = result.records || []
    total.value = result.total || 0
  } catch (error) {
    ElMessage.error('获取培训活动失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.self-training {
  padding: 20px;
}

.training-card {
  max-width: 1200px;
  margin: 0 auto;
}

.activity-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.activity-card {
  margin-bottom: 0;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header .title {
  font-size: 16px;
  font-weight: bold;
}

.activity-content {
  padding: 10px 0;
}

.info-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 10px;
  color: #606266;
  font-size: 14px;
}

.info-row .el-icon {
  color: #909399;
}
</style>
