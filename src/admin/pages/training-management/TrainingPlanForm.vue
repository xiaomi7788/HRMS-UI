<template>
  <div class="training-plan-form-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>培训计划制定</span>
        </div>
      </template>

      <el-form :model="planForm" :rules="rules" ref="planFormRef" label-width="120px">
        <el-form-item label="计划名称" prop="name">
          <el-input v-model="planForm.name" placeholder="请输入培训计划名称" />
        </el-form-item>
        <el-form-item label="培训类型" prop="type">
          <el-select v-model="planForm.type" placeholder="请选择培训类型" style="width: 100%;">
            <el-option label="岗前培训" value="岗前培训" />
            <el-option label="技能提升" value="技能提升" />
            <el-option label="管理能力" value="管理能力" />
          </el-select>
        </el-form-item>
        <el-form-item label="培训讲师" prop="trainer">
          <el-input v-model="planForm.trainer" placeholder="请输入培训讲师" />
        </el-form-item>
        <el-form-item label="培训时间" prop="dateRange">
          <el-date-picker
            v-model="planForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="培训地点" prop="location">
          <el-input v-model="planForm.location" placeholder="请输入培训地点" />
        </el-form-item>
        <el-form-item label="参与人员" prop="participants">
          <el-select v-model="planForm.participants" multiple placeholder="请选择参与人员" style="width: 100%;">
            <el-option label="全体员工" value="全体员工" />
            <el-option label="技术部员工" value="技术部员工" />
            <el-option label="HR部员工" value="HR部员工" />
          </el-select>
        </el-form-item>
        <el-form-item label="计划描述" prop="description">
          <el-input type="textarea" v-model="planForm.description" placeholder="请输入计划描述" :rows="4" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm">保存计划</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, type FormInstance, type FormRules } from 'element-plus';

interface TrainingPlan {
  name: string;
  type: string;
  trainer: string;
  dateRange: [Date, Date] | null;
  location: string;
  participants: string[];
  description: string;
}

const planFormRef = ref<FormInstance>();
const planForm = reactive<TrainingPlan>({
  name: '新员工岗前培训',
  type: '岗前培训',
  trainer: '张老师',
  dateRange: [new Date('2023-03-01'), new Date('2023-03-05')],
  location: '公司大会议室',
  participants: ['全体员工'],
  description: '为新入职员工提供全面的岗前培训，帮助其快速融入公司。',
});

const rules = reactive<FormRules<TrainingPlan>>({
  name: [{ required: true, message: '请输入计划名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择培训类型', trigger: 'change' }],
  trainer: [{ required: true, message: '请输入培训讲师', trigger: 'blur' }],
  dateRange: [{ type: 'array', required: true, message: '请选择培训时间', trigger: 'change' }],
  location: [{ required: true, message: '请输入培训地点', trigger: 'blur' }],
  participants: [{ type: 'array', required: true, message: '请选择参与人员', trigger: 'change' }],
});

const submitForm = async () => {
  if (!planFormRef.value) return;
  await planFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('培训计划保存成功！');
      console.log('提交的培训计划:', planForm);
    } else {
      ElMessage.error('请检查表单填写！');
    }
  });
};

const resetForm = () => {
  if (!planFormRef.value) return;
  planFormRef.value.resetFields();
};
</script>

<style scoped>
.training-plan-form-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
