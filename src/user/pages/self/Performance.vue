<template>
  <div class="self-performance">
    <el-card class="performance-card">
      <template #header>
        <span>我的绩效</span>
      </template>

      <!-- 表格 -->
      <el-table :data="resultList" v-loading="loading" stripe>
        <el-table-column prop="planId" label="方案ID" width="100" />
        <el-table-column prop="kpiScore" label="KPI得分" width="100" align="center" />
        <el-table-column prop="behaviorScore" label="行为评分" width="100" align="center" />
        <el-table-column prop="evaluationScore" label="360评分" width="100" align="center" />
        <el-table-column prop="totalScore" label="综合得分" width="120" align="center">
          <template #default="{ row }">
            <span :class="getScoreClass(row.totalScore)">
              {{ row.totalScore }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="grade" label="等级" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="getGradeTagType(row.grade)">
              {{ row.grade }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="rating" label="评级" width="100">
          <template #default="{ row }">
            {{ getRatingName(row.rating) }}
          </template>
        </el-table-column>
        <el-table-column prop="evaluatorName" label="评估人" width="100" />
        <el-table-column prop="evaluateTime" label="评估时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.evaluateTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusName(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">
              查看详情
            </el-button>
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

    <!-- 详情对话框 -->
    <el-dialog v-model="detailDialog" title="绩效详情" width="600px">
      <el-descriptions v-if="currentResult" :column="1" border>
        <el-descriptions-item label="方案ID">{{ currentResult.planId }}</el-descriptions-item>
        <el-descriptions-item label="KPI得分">
          <span :class="getScoreClass(currentResult.kpiScore)">
            {{ currentResult.kpiScore }}
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="行为评分">
          <span :class="getScoreClass(currentResult.behaviorScore)">
            {{ currentResult.behaviorScore }}
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="360评分">
          <span :class="getScoreClass(currentResult.evaluationScore)">
            {{ currentResult.evaluationScore }}
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="综合得分">
          <span :class="getScoreClass(currentResult.totalScore)" style="font-weight: bold; font-size: 18px;">
            {{ currentResult.totalScore }}
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="绩效等级">
          <el-tag :type="getGradeTagType(currentResult.grade)">
            {{ currentResult.grade }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="评级">{{ getRatingName(currentResult.rating) }}</el-descriptions-item>
        <el-descriptions-item label="评估人">{{ currentResult.evaluatorName }}</el-descriptions-item>
        <el-descriptions-item label="评估时间">{{ formatDateTime(currentResult.evaluateTime) }}</el-descriptions-item>
        <el-descriptions-item label="评估意见">{{ currentResult.comment }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getPerformanceResults,
  type PerformanceResult
} from '@/api/self'

const loading = ref(false)
const resultList = ref<PerformanceResult[]>([])
const total = ref(0)
const detailDialog = ref(false)
const currentResult = ref<PerformanceResult | null>(null)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10
})

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function getScoreClass(score: string) {
  const num = parseFloat(score || '0')
  if (num >= 90) return 'score-high'
  if (num >= 70) return 'score-medium'
  return 'score-low'
}

function getGradeTagType(grade: string) {
  const map: Record<string, string> = {
    'A': 'success',
    'B': 'primary',
    'C': 'warning',
    'D': 'danger'
  }
  return map[grade] || ''
}

function getStatusName(status: number) {
  const map: Record<number, string> = {
    0: '待评估',
    1: '已评估',
    2: '已校准',
    3: '已确认'
  }
  return map[status] || '未知'
}

function getStatusTagType(status: number) {
  const map: Record<number, string> = {
    0: 'warning',
    1: 'info',
    2: 'primary',
    3: 'success'
  }
  return map[status] || ''
}

function getRatingName(rating: string) {
  const map: Record<string, string> = {
    'EXCELLENT': '优秀',
    'GOOD': '良好',
    'NEEDS_IMPROVEMENT': '需改进',
    'UNSATISFACTORY': '不满意'
  }
  return map[rating] || rating || '-'
}

function handleView(row: PerformanceResult) {
  currentResult.value = row
  detailDialog.value = true
}

async function handleQuery() {
  loading.value = true
  try {
    const result = await getPerformanceResults(queryParams)
    resultList.value = result.records || []
    total.value = Number(result.total || 0)
  } catch (error) {
    ElMessage.error('获取绩效结果失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.self-performance {
  padding: 20px;
}

.performance-card {
  max-width: 1400px;
  margin: 0 auto;
}

.score-high {
  color: #67c23a;
  font-weight: bold;
}

.score-medium {
  color: #409eff;
  font-weight: bold;
}

.score-low {
  color: #f56c6c;
  font-weight: bold;
}
</style>
