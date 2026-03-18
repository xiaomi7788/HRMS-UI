<template>
  <div class="training-learning-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>在线学习管理</span>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="课程">
          <el-select
            v-model="queryParams.courseId"
            placeholder="请选择课程"
            clearable
            @change="handleQuery"
          >
            <el-option
              v-for="course in courseList"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 学习进度列表 -->
      <el-table
        v-loading="loading"
        :data="learnList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="employeeNo" label="员工编号" width="120" />
        <el-table-column prop="employeeName" label="员工姓名" width="120" />
        <el-table-column prop="courseName" label="课程名称" width="200" />
        <el-table-column prop="chapterIndex" label="当前章节" width="100" />
        <el-table-column label="学习进度" width="150">
          <template #default="{ row }">
            <el-progress :percentage="row.progressPct ?? 0" />
          </template>
        </el-table-column>
        <el-table-column label="学习时长(分钟)" width="120" align="right">
          <template #default="{ row }">
            {{ row.studyMinutes }}
          </template>
        </el-table-column>
        <el-table-column label="完成状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.isCompleted === 1 ? 'success' : 'info'">
              {{ row.isCompleted === 1 ? '已完成' : '进行中' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="completeTime" label="完成时间" width="180" />
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
        @change="handleQuery"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getLearnPage,
  type LearnPageParams,
  type TrainingLearnProgress
} from '@/api/training'

// 列表数据
const loading = ref(false)
const learnList = ref<TrainingLearnProgress[]>([])
const courseList = ref<any[]>([])
const total = ref(0)
const queryParams = reactive<LearnPageParams>({
  pageNum: 1,
  pageSize: 10
})

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getLearnPage(queryParams)
    learnList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取学习进度失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.courseId = undefined
  queryParams.employeeId = undefined
  handleQuery()
}

// 加载课程列表
const loadCourseList = async () => {
  try {
    const { getCoursePage } = await import('@/api/training')
    const res = await getCoursePage({ pageNum: 1, pageSize: 1000 })
    courseList.value = res.records
  } catch (error) {
    console.error('加载课程列表失败', error)
  }
}

onMounted(() => {
  handleQuery()
  loadCourseList()
})
</script>

<style scoped>
.training-learning-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
</style>
