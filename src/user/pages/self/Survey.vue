<template>
  <div class="self-survey">
    <el-card class="survey-card">
      <template #header>
        <span>员工问卷</span>
      </template>

      <el-empty v-if="surveyList.length === 0" description="暂无问卷调查" />

      <div v-else class="survey-list">
        <el-card v-for="survey in surveyList" :key="survey.id" class="survey-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <span class="title">{{ survey.title }}</span>
              <el-tag :type="survey.status === 0 ? 'success' : 'danger'">
                {{ survey.status === 0 ? '进行中' : '已结束' }}
              </el-tag>
            </div>
          </template>

          <div class="survey-content">
            <div class="info-row">
              <el-icon><Calendar /></el-icon>
              <span>开始时间：{{ formatDateTime(survey.startTime) }}</span>
            </div>
            <div class="info-row">
              <el-icon><Clock /></el-icon>
              <span>结束时间：{{ formatDateTime(survey.endTime) }}</span>
            </div>
            <div class="info-row" v-if="survey.description">
              <el-icon><Document /></el-icon>
              <span class="description">{{ survey.description }}</span>
            </div>
          </div>

          <div class="card-footer">
            <el-tag v-if="survey.answered" type="success">已填写</el-tag>
            <el-button
              v-else-if="survey.status === 0"
              type="primary"
              @click="handleFill(survey)"
            >
              填写问卷
            </el-button>
            <el-button v-else disabled>
              问卷已结束
            </el-button>
          </div>
        </el-card>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Calendar, Clock, Document } from '@element-plus/icons-vue'

// 问卷数据接口
interface Survey {
  id: number
  title: string
  description?: string
  startTime: string
  endTime: string
  status: number // 0进行中 1已结束
  answered?: boolean
}

const surveyList = ref<Survey[]>([])

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function handleFill(survey: Survey) {
  ElMessage.info('问卷填写功能开发中...')
  // TODO: 跳转到问卷填写页面
}

async function loadSurveys() {
  try {
    // TODO: 调用问卷列表接口
    ElMessage.info('暂无可用的问卷调查')
  } catch (error) {
    ElMessage.error('获取问卷列表失败')
  }
}

onMounted(() => {
  loadSurveys()
})
</script>

<style scoped>
.self-survey {
  padding: 20px;
}

.survey-card {
  max-width: 1400px;
  margin: 0 auto;
}

.survey-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.survey-card {
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

.survey-content {
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  align-items: center;
  margin-bottom: 12px;
  color: #606266;
}

.info-row .el-icon {
  margin-right: 8px;
  color: #909399;
}

.description {
  line-height: 1.6;
  color: #606266;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid #ebeef5;
  padding-top: 15px;
  margin-top: 15px;
}
</style>
