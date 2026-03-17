<template>
  <div class="attendance-rule-config-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>考勤规则配置</span>
        </div>
      </template>

      <el-form :model="ruleForm" :rules="rules" ref="ruleFormRef" label-width="120px">
        <el-form-item label="规则名称" prop="name">
          <el-input v-model="ruleForm.name" placeholder="请输入考勤规则名称" />
        </el-form-item>
        <el-form-item label="工作日" prop="workDays">
          <el-checkbox-group v-model="ruleForm.workDays">
            <el-checkbox label="周一" />
            <el-checkbox label="周二" />
            <el-checkbox label="周三" />
            <el-checkbox label="周四" />
            <el-checkbox label="周五" />
            <el-checkbox label="周六" />
            <el-checkbox label="周日" />
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="上班时间" prop="checkInTime">
          <el-time-picker v-model="ruleForm.checkInTime" placeholder="选择上班时间" format="HH:mm" value-format="HH:mm" />
        </el-form-item>
        <el-form-item label="下班时间" prop="checkOutTime">
          <el-time-picker v-model="ruleForm.checkOutTime" placeholder="选择下班时间" format="HH:mm" value-format="HH:mm" />
        </el-form-item>
        <el-form-item label="迟到容忍时间" prop="lateTolerance">
          <el-input-number v-model="ruleForm.lateTolerance" :min="0" :max="60" />
          <span style="margin-left: 10px;">分钟</span>
        </el-form-item>
        <el-form-item label="早退容忍时间" prop="earlyLeaveTolerance">
          <el-input-number v-model="ruleForm.earlyLeaveTolerance" :min="0" :max="60" />
          <span style="margin-left: 10px;">分钟</span>
        </el-form-item>
        <el-form-item label="是否启用" prop="enabled">
          <el-switch v-model="ruleForm.enabled" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm">保存规则</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, type FormInstance, type FormRules } from 'element-plus';

interface AttendanceRule {
  name: string;
  workDays: string[];
  checkInTime: string;
  checkOutTime: string;
  lateTolerance: number;
  earlyLeaveTolerance: number;
  enabled: boolean;
}

const ruleFormRef = ref<FormInstance>();
const ruleForm = reactive<AttendanceRule>({
  name: '默认考勤规则',
  workDays: ['周一', '周二', '周三', '周四', '周五'],
  checkInTime: '09:00',
  checkOutTime: '18:00',
  lateTolerance: 10,
  earlyLeaveTolerance: 10,
  enabled: true,
});

const rules = reactive<FormRules<AttendanceRule>>({
  name: [{ required: true, message: '请输入考勤规则名称', trigger: 'blur' }],
  workDays: [{ type: 'array', required: true, message: '请选择工作日', trigger: 'change' }],
  checkInTime: [{ required: true, message: '请选择上班时间', trigger: 'change' }],
  checkOutTime: [{ required: true, message: '请选择下班时间', trigger: 'change' }],
  lateTolerance: [{ required: true, message: '请输入迟到容忍时间', trigger: 'blur' }],
  earlyLeaveTolerance: [{ required: true, message: '请输入早退容忍时间', trigger: 'blur' }],
});

const submitForm = async () => {
  const formEl = ruleFormRef.value;
  if (!formEl) return;
  await formEl.validate((valid, fields) => {
    if (valid) {
      ElMessage.success('考勤规则保存成功！');
      console.log('提交的考勤规则:', ruleForm);
    } else {
      ElMessage.error('请检查表单填写！');
      console.log('表单验证失败:', fields);
    }
  });
};

const resetForm = () => {
  const formEl = ruleFormRef.value;
  if (!formEl) return;
  formEl.resetFields();
};
</script>

<style scoped>
.attendance-rule-config-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
