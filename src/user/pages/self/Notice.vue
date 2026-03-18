<template>
  <div class="self-notice">
    <el-card class="notice-card">
      <template #header>
        <div class="card-header">
          <span>系统公告</span>
          <el-select v-model="noticeType" placeholder="公告类型" clearable style="width: 150px" @change="handleQuery">
            <el-option label="全部" value="" />
            <el-option label="系统通知" value="system" />
            <el-option label="公告通知" value="notice" />
            <el-option label="活动通知" value="activity" />
          </el-select>
        </div>
      </template>

      <el-empty v-if="noticeList.length === 0" description="暂无公告" />

      <div v-else class="notice-list">
        <el-card v-for="notice in noticeList" :key="notice.id" class="notice-card" shadow="hover">
          <div class="notice-header">
            <el-tag :type="getTypeTagType(notice.type)" size="small">
              {{ getTypeName(notice.type) }}
            </el-tag>
            <span class="time">{{ formatDateTime(notice.createTime) }}</span>
          </div>

          <div class="notice-title">{{ notice.title }}</div>
          <div class="notice-content" v-if="showContent === notice.id">
            <div v-html="notice.content"></div>
          </div>
          <div class="notice-content" v-else>
            <div class="preview">{{ notice.content }}</div>
          </div>

          <div class="notice-footer">
            <el-button
              v-if="showContent !== notice.id"
              type="primary"
              link
              @click="showContent = notice.id"
            >
              查看详情
            </el-button>
            <el-button
              v-else
              link
              @click="showContent = undefined"
            >
              收起
            </el-button>
          </div>
        </el-card>
      </div>

      <!-- 分页 -->
      <el-pagination
        v-if="noticeList.length > 0"
        v-model:current-page="queryParams.current"
        v-model:page-size="queryParams.size"
        :total="total"
        :page-sizes="[10, 20, 50]"
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

// 公告数据接口
interface Notice {
  id: number
  title: string
  content: string
  type: string // system/notice/activity
  createTime: string
}

const noticeList = ref<Notice[]>([])
const total = ref(0)
const noticeType = ref('')
const showContent = ref<number>()

const queryParams = reactive({
  current: 1,
  size: 10
})

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function getTypeName(type: string) {
  const map: Record<string, string> = {
    'system': '系统通知',
    'notice': '公告通知',
    'activity': '活动通知'
  }
  return map[type] || type
}

function getTypeTagType(type: string) {
  const map: Record<string, string> = {
    'system': 'danger',
    'notice': 'primary',
    'activity': 'success'
  }
  return map[type] || ''
}

async function handleQuery() {
  try {
    // TODO: 调用公告列表接口
    ElMessage.info('暂无公告')
  } catch (error) {
    ElMessage.error('获取公告列表失败')
  }
}

async function loadNotices() {
  await handleQuery()
}

onMounted(() => {
  loadNotices()
})
</script>

<style scoped>
.self-notice {
  padding: 20px;
}

.notice-card {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.notice-list {
  display: grid;
  grid-template-columns: 1fr;
  gap: 20px;
  margin-top: 20px;
}

.notice-card {
  margin-bottom: 0;
}

.notice-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.time {
  color: #909399;
  font-size: 14px;
}

.notice-title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 15px;
  color: #303133;
}

.notice-content {
  color: #606266;
  line-height: 1.8;
  margin-bottom: 15px;
}

.preview {
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  max-height: 60px;
}

.notice-footer {
  text-align: right;
}
</style>
