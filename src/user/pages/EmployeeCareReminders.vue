<template>
  <div class="employee-care-reminders-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>员工关怀提醒</span>
        </div>
      </template>
      <el-tabs v-model="activeTab" class="reminders-tabs">
        <el-tab-pane label="生日提醒" name="birthday">
          <el-table :data="birthdayReminders" style="width: 100%" border>
            <el-table-column prop="name" label="姓名" width="120"></el-table-column>
            <el-table-column prop="date" label="生日日期" width="120"></el-table-column>
            <el-table-column prop="message" label="祝福语"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="sendBlessing(row)">送祝福</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="入职周年提醒" name="anniversary">
          <el-table :data="anniversaryReminders" style="width: 100%" border>
            <el-table-column prop="name" label="姓名" width="120"></el-table-column>
            <el-table-column prop="date" label="入职日期" width="120"></el-table-column>
            <el-table-column prop="years" label="周年数" width="100"></el-table-column>
            <el-table-column prop="message" label="寄语"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="sendGreeting(row)">送祝福</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="公司活动提醒" name="activities">
          <el-table :data="activityReminders" style="width: 100%" border>
            <el-table-column prop="title" label="活动名称"></el-table-column>
            <el-table-column prop="date" label="活动日期" width="120"></el-table-column>
            <el-table-column prop="location" label="地点"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewActivityDetail(row)">查看详情</el-button>
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

const activeTab = ref('birthday');

// 生日提醒
const birthdayReminders = ref([
  { id: 1, name: '张三', date: '11月15日', message: '祝张三生日快乐！' },
  { id: 2, name: '李四', date: '12月01日', message: '祝李四生日快乐！' },
]);

const sendBlessing = (row: any) => {
  ElMessage.success(`已向 ${row.name} 发送生日祝福！`);
  // 实际应用中会调用API发送祝福
};

// 入职周年提醒
const anniversaryReminders = ref([
  { id: 1, name: '王五', date: '2020-11-01', years: 3, message: '感谢王五与公司携手三年！' },
  { id: 2, name: '赵六', date: '2022-05-20', years: 1, message: '祝赵六入职一周年快乐！' },
]);

const sendGreeting = (row: any) => {
  ElMessage.success(`已向 ${row.name} 发送周年祝福！`);
  // 实际应用中会调用API发送祝福
};

// 公司活动提醒
const activityReminders = ref([
  { id: 1, title: '公司团建活动', date: '2023-11-20', location: 'XX度假村' },
  { id: 2, title: '年度健康体检', date: '2023-12-10', location: 'XX体检中心' },
]);

const viewActivityDetail = (row: any) => {
  ElMessage.info(`查看活动详情: ${row.title}`);
  // 实际应用中会跳转到活动详情页
};

onMounted(() => {
  // 模拟数据加载
});
</script>

<style scoped>
.employee-care-reminders-container {
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

.reminders-tabs {
  margin-top: 20px;
}
</style>
