<template>
  <div class="training-center-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>培训中心</span>
        </div>
      </template>
      <el-tabs v-model="activeTab" class="training-tabs">
        <el-tab-pane label="培训计划" name="plans">
          <el-table :data="trainingPlans" style="width: 100%" border>
            <el-table-column prop="name" label="计划名称"></el-table-column>
            <el-table-column prop="startDate" label="开始日期" width="120"></el-table-column>
            <el-table-column prop="endDate" label="结束日期" width="120"></el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getPlanStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewPlanDetail(row)">查看详情</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="课程列表" name="courses">
          <el-table :data="courseList" style="width: 100%" border>
            <el-table-column prop="name" label="课程名称"></el-table-column>
            <el-table-column prop="instructor" label="讲师" width="120"></el-table-column>
            <el-table-column prop="duration" label="时长" width="100"></el-table-column>
            <el-table-column prop="status" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getCourseStatusType(row.status)">{{ row.status }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="120">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="enrollCourse(row)" :disabled="row.status !== '未开始'">报名</el-button>
                <el-button link type="primary" size="small" @click="viewCourseDetail(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="我的培训记录" name="records">
          <el-table :data="trainingRecords" style="width: 100%" border>
            <el-table-column prop="courseName" label="课程名称"></el-table-column>
            <el-table-column prop="date" label="培训日期" width="120"></el-table-column>
            <el-table-column prop="score" label="成绩" width="80"></el-table-column>
            <el-table-column prop="result" label="结果" width="100">
              <template #default="{ row }">
                <el-tag :type="getTrainingResultType(row.result)">{{ row.result }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewRecordDetail(row)">查看证书</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { ElMessage } from 'element-plus';

const activeTab = ref('plans');

// 培训计划
const trainingPlans = ref([
  { id: 1, name: '新员工入职培训计划', startDate: '2023-11-01', endDate: '2023-11-05', status: '进行中' },
  { id: 2, name: '前端技术进阶培训', startDate: '2023-12-01', endDate: '2023-12-15', status: '未开始' },
  { id: 3, name: '管理层领导力提升', startDate: '2023-09-01', endDate: '2023-09-30', status: '已结束' },
]);

const getPlanStatusType = (status: string) => {
  switch (status) {
    case '进行中': return 'primary';
    case '未开始': return 'info';
    case '已结束': return 'success';
    default: return '';
  }
};

const viewPlanDetail = (row: any) => {
  ElMessage.info(`查看培训计划详情: ${row.name}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

// 课程列表
const courseList = ref([
  { id: 101, name: 'Vue 3 核心技术', instructor: '张老师', duration: '16小时', status: '进行中' },
  { id: 102, name: 'Element Plus 组件实战', instructor: '李老师', duration: '8小时', status: '未开始' },
  { id: 103, name: 'TypeScript 高级应用', instructor: '王老师', duration: '12小时', status: '已结束' },
]);

const getCourseStatusType = (status: string) => {
  switch (status) {
    case '进行中': return 'primary';
    case '未开始': return 'info';
    case '已结束': return 'success';
    default: return '';
  }
};

const enrollCourse = (row: any) => {
  ElMessage.success(`成功报名课程: ${row.name}`);
  row.status = '进行中'; // 模拟状态更新
  // 实际应用中会调用API报名课程
};

const viewCourseDetail = (row: any) => {
  ElMessage.info(`查看课程详情: ${row.name}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

// 我的培训记录
const trainingRecords = ref([
  { id: 201, courseName: 'Vue 2 到 Vue 3 迁移', date: '2023-08-10', score: 95, result: '通过' },
  { id: 202, courseName: 'Git 版本控制精讲', date: '2023-07-20', score: 80, result: '通过' },
  { id: 203, courseName: '项目管理基础', date: '2023-06-01', score: 60, result: '未通过' },
]);

const getTrainingResultType = (result: string) => {
  switch (result) {
    case '通过': return 'success';
    case '未通过': return 'danger';
    default: return '';
  }
};

const viewRecordDetail = (row: any) => {
  ElMessage.info(`查看培训记录详情: ${row.courseName}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

onMounted(() => {
  // 模拟数据加载
});
</script>

<style scoped>
.training-center-container {
  padding: 20px;
}

.box-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
  font-weight: bold;
}

.training-tabs {
  margin-top: 20px;
}
</style>
