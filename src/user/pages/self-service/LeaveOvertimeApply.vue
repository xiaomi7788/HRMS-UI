<template>
  <div class="leave-overtime-apply-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>请假 / 加班 / 调休申请</span>
        </div>
      </template>
      <el-tabs v-model="activeTab" class="apply-tabs">
        <el-tab-pane label="请假申请" name="leave">
          <el-form :model="leaveForm" :rules="leaveRules" ref="leaveFormRef" label-width="100px" class="apply-form">
            <el-form-item label="申请类型" prop="type">
              <el-select v-model="leaveForm.type" placeholder="请选择请假类型" popper-append-to-body>
                <el-option label="事假" value="personal"></el-option>
                <el-option label="病假" value="sick"></el-option>
                <el-option label="年假" value="annual"></el-option>
                <el-option label="婚假" value="marriage"></el-option>
                <el-option label="产假" value="maternity"></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="开始时间" prop="startDate">
              <el-date-picker v-model="leaveForm.startDate" type="datetime" placeholder="选择开始时间"></el-date-picker>
            </el-form-item>
            <el-form-item label="结束时间" prop="endDate">
              <el-date-picker v-model="leaveForm.endDate" type="datetime" placeholder="选择结束时间"></el-date-picker>
            </el-form-item>
            <el-form-item label="请假事由" prop="reason">
              <el-input type="textarea" v-model="leaveForm.reason" :rows="3"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitLeaveApply">提交申请</el-button>
              <el-button @click="resetLeaveForm">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="加班申请" name="overtime">
          <el-form :model="overtimeForm" :rules="overtimeRules" ref="overtimeFormRef" label-width="100px" class="apply-form">
            <el-form-item label="开始时间" prop="startDate">
              <el-date-picker v-model="overtimeForm.startDate" type="datetime" placeholder="选择开始时间"></el-date-picker>
            </el-form-item>
            <el-form-item label="结束时间" prop="endDate">
              <el-date-picker v-model="overtimeForm.endDate" type="datetime" placeholder="选择结束时间"></el-date-picker>
            </el-form-item>
            <el-form-item label="加班事由" prop="reason">
              <el-input type="textarea" v-model="overtimeForm.reason" :rows="3"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitOvertimeApply">提交申请</el-button>
              <el-button @click="resetOvertimeForm">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
        <el-tab-pane label="调休申请" name="compensatory">
          <el-form :model="compensatoryForm" :rules="compensatoryRules" ref="compensatoryFormRef" label-width="100px" class="apply-form">
            <el-form-item label="调休时长" prop="duration">
              <el-input-number v-model="compensatoryForm.duration" :min="0.5" :step="0.5"></el-input-number> 小时
            </el-form-item>
            <el-form-item label="调休事由" prop="reason">
              <el-input type="textarea" v-model="compensatoryForm.reason" :rows="3"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="submitCompensatoryApply">提交申请</el-button>
              <el-button @click="resetCompensatoryForm">重置</el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>我的申请记录</span>
        </div>
      </template>
      <el-table :data="myApplications" style="width: 100%" border>
        <el-table-column prop="type" label="类型" width="100"></el-table-column>
        <el-table-column prop="reason" label="事由"></el-table-column>
        <el-table-column prop="applyDate" label="申请日期" width="120"></el-table-column>
        <el-table-column prop="status" label="审批状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getApprovalStatusType(row.status)">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="viewApplicationDetail(row)">查看</el-button>
            <el-button link type="danger" size="small" @click="withdrawApplication(row)" :disabled="row.status !== '待审批'">撤回</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { ElMessage } from 'element-plus';
import type { FormInstance, FormRules } from 'element-plus';

const activeTab = ref('leave');

// 请假申请表单
const leaveFormRef = ref<FormInstance>();
const leaveForm = reactive({
  type: '',
  startDate: '',
  endDate: '',
  reason: '',
});
const leaveRules = reactive<FormRules>({
  type: [{ required: true, message: '请选择请假类型', trigger: 'change' }],
  startDate: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  reason: [{ required: true, message: '请输入请假事由', trigger: 'blur' }],
});

const submitLeaveApply = () => {
  if (!leaveFormRef.value) return;
  leaveFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('请假申请已提交！');
      // 实际应用中会调用API提交申请
      resetLeaveForm();
    } else {
      ElMessage.error('请填写完整并正确的信息！');
    }
  });
};
const resetLeaveForm = () => {
  if (leaveFormRef.value) {
    leaveFormRef.value.resetFields();
  }
};

// 加班申请表单
const overtimeFormRef = ref<FormInstance>();
const overtimeForm = reactive({
  startDate: '',
  endDate: '',
  reason: '',
});
const overtimeRules = reactive<FormRules>({
  startDate: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择结束时间', trigger: 'change' }],
  reason: [{ required: true, message: '请输入加班事由', trigger: 'blur' }],
});

const submitOvertimeApply = () => {
  if (!overtimeFormRef.value) return;
  overtimeFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('加班申请已提交！');
      // 实际应用中会调用API提交申请
      resetOvertimeForm();
    } else {
      ElMessage.error('请填写完整并正确的信息！');
    }
  });
};
const resetOvertimeForm = () => {
  if (overtimeFormRef.value) {
    overtimeFormRef.value.resetFields();
  }
};

// 调休申请表单
const compensatoryFormRef = ref<FormInstance>();
const compensatoryForm = reactive({
  duration: 0.5,
  reason: '',
});
const compensatoryRules = reactive<FormRules>({
  duration: [{ required: true, message: '请输入调休时长', trigger: 'blur' }],
  reason: [{ required: true, message: '请输入调休事由', trigger: 'blur' }],
});

const submitCompensatoryApply = () => {
  if (!compensatoryFormRef.value) return;
  compensatoryFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('调休申请已提交！');
      // 实际应用中会调用API提交申请
      resetCompensatoryForm();
    } else {
      ElMessage.error('请填写完整并正确的信息！');
    }
  });
};
const resetCompensatoryForm = () => {
  if (compensatoryFormRef.value) {
    compensatoryFormRef.value.resetFields();
  }
};

// 我的申请记录
const myApplications = ref([
  { id: 1, type: '请假', reason: '个人事务', applyDate: '2023-10-26', status: '待审批' },
  { id: 2, type: '加班', reason: '项目紧急', applyDate: '2023-10-25', status: '已通过' },
  { id: 3, type: '调休', reason: '加班调休', applyDate: '2023-10-24', status: '已拒绝' },
]);

const getApprovalStatusType = (status: string) => {
  switch (status) {
    case '待审批': return 'warning';
    case '已通过': return 'success';
    case '已拒绝': return 'danger';
    default: return '';
  }
};

const viewApplicationDetail = (row: any) => {
  ElMessage.info(`查看申请详情: ${row.reason}`);
  // 实际应用中会跳转到详情页或弹窗显示详情
};

const withdrawApplication = (row: any) => {
  ElMessage.warning(`撤回申请: ${row.reason}`);
  // 实际应用中会调用API撤回申请
  row.status = '已撤回'; // 模拟状态更新
};
</script>

<style scoped>
.leave-overtime-apply-container {
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

.apply-tabs {
  margin-top: 20px;
}

.apply-form {
  max-width: 600px;
  padding: 20px;
}
</style>
