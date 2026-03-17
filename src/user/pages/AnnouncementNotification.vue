<template>
  <div class="announcement-notification-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>公告通知中心</span>
        </div>
      </template>
      <el-tabs v-model="activeTab" class="notification-tabs">
        <el-tab-pane label="公司公告" name="announcements">
          <el-table :data="announcements" style="width: 100%" border>
            <el-table-column prop="title" label="标题"></el-table-column>
            <el-table-column prop="publishDate" label="发布日期" width="120"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewAnnouncement(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="announcementCurrentPage"
            v-model:page-size="announcementPageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="totalAnnouncements"
            @size-change="handleAnnouncementSizeChange"
            @current-change="handleAnnouncementCurrentChange"
            background
            class="pagination-container"
          />
        </el-tab-pane>
        <el-tab-pane label="系统通知" name="systemNotifications">
          <el-table :data="systemNotifications" style="width: 100%" border>
            <el-table-column prop="content" label="内容"></el-table-column>
            <el-table-column prop="receiveDate" label="接收日期" width="120"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewSystemNotification(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-pagination
            v-model:current-page="systemNotificationCurrentPage"
            v-model:page-size="systemNotificationPageSize"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            :total="totalSystemNotifications"
            @size-change="handleSystemNotificationSizeChange"
            @current-change="handleSystemNotificationCurrentChange"
            background
            class="pagination-container"
          />
        </el-tab-pane>
        <el-tab-pane label="审批提醒" name="approvalReminders">
          <el-table :data="approvalReminders" style="width: 100%" border>
            <el-table-column prop="type" label="类型" width="100"></el-table-column>
            <el-table-column prop="content" label="内容"></el-table-column>
            <el-table-column prop="date" label="日期" width="120"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="handleApprovalReminder(row)">处理</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="培训通知" name="trainingNotifications">
          <el-table :data="trainingNotifications" style="width: 100%" border>
            <el-table-column prop="courseName" label="课程名称"></el-table-column>
            <el-table-column prop="date" label="日期" width="120"></el-table-column>
            <el-table-column prop="location" label="地点"></el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="viewTrainingNotification(row)">查看</el-button>
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

const activeTab = ref('announcements');

// 公司公告
const announcements = ref([
  { id: 1, title: '关于公司年会安排的通知', publishDate: '2023-11-01', content: '详细内容...' },
  { id: 2, title: '公司组织架构调整公告', publishDate: '2023-10-25', content: '详细内容...' },
  { id: 3, title: '关于加强信息安全的通知', publishDate: '2023-10-20', content: '详细内容...' },
]);
const announcementCurrentPage = ref(1);
const announcementPageSize = ref(10);
const totalAnnouncements = ref(announcements.value.length);

const viewAnnouncement = (row: any) => {
  ElMessage.info(`查看公告: ${row.title}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const handleAnnouncementSizeChange = (val: number) => {
  announcementPageSize.value = val;
  // 重新获取数据
};

const handleAnnouncementCurrentChange = (val: number) => {
  announcementCurrentPage.value = val;
  // 重新获取数据
};

// 系统通知
const systemNotifications = ref([
  { id: 1, content: '您的密码已过期，请及时修改。', receiveDate: '2023-11-02' },
  { id: 2, content: '系统将于今晚23:00-24:00进行维护。', receiveDate: '2023-11-01' },
]);
const systemNotificationCurrentPage = ref(1);
const systemNotificationPageSize = ref(10);
const totalSystemNotifications = ref(systemNotifications.value.length);

const viewSystemNotification = (row: any) => {
  ElMessage.info(`查看系统通知: ${row.content}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const handleSystemNotificationSizeChange = (val: number) => {
  systemNotificationPageSize.value = val;
  // 重新获取数据
};

const handleSystemNotificationCurrentChange = (val: number) => {
  systemNotificationCurrentPage.value = val;
  // 重新获取数据
};

// 审批提醒
const approvalReminders = ref([
  { id: 1, type: '请假', content: '您的请假申请（年假）已通过。', date: '2023-11-01' },
  { id: 2, type: '加班', content: '您的加班申请（项目紧急）已被驳回。', date: '2023-10-30' },
]);

const handleApprovalReminder = (row: any) => {
  ElMessage.info(`处理审批提醒: ${row.content}`);
  // 实际应用中会跳转到相关审批页面
};

// 培训通知
const trainingNotifications = ref([
  { id: 1, courseName: 'Vue 3 核心技术', date: '2023-11-15', location: '线上会议室' },
  { id: 2, courseName: 'Element Plus 组件实战', date: '2023-12-01', location: '公司培训室' },
]);

const viewTrainingNotification = (row: any) => {
  ElMessage.info(`查看培训通知: ${row.courseName}`);
  // 实际应用中会跳转到培训详情页
};

onMounted(() => {
  // 模拟数据加载
});
</script>

<style scoped>
.announcement-notification-container {
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

.notification-tabs {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  justify-content: flex-end;
  display: flex;
}
</style>
