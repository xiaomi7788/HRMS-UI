<template>
  <div class="performance-plan-design-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>绩效方案设计</span>
        </div>
      </template>

      <el-form :model="planForm" :rules="rules" ref="planFormRef" label-width="120px">
        <el-form-item label="方案名称" prop="name">
          <el-input v-model="planForm.name" placeholder="请输入绩效方案名称" />
        </el-form-item>
        <el-form-item label="适用部门" prop="departments">
          <el-select v-model="planForm.departments" multiple placeholder="请选择适用部门" style="width: 100%;">
            <el-option label="技术部" value="技术部" />
            <el-option label="人力资源部" value="人力资源部" />
            <el-option label="市场部" value="市场部" />
            <el-option label="销售部" value="销售部" />
          </el-select>
        </el-form-item>
        <el-form-item label="评估周期" prop="cycle">
          <el-select v-model="planForm.cycle" placeholder="请选择评估周期" style="width: 100%;">
            <el-option label="季度" value="季度" />
            <el-option label="半年度" value="半年度" />
            <el-option label="年度" value="年度" />
          </el-select>
        </el-form-item>
        <el-form-item label="评估指标">
          <el-table :data="planForm.indicators" style="width: 100%; margin-bottom: 10px;" border>
            <el-table-column prop="name" label="指标名称" />
            <el-table-column prop="weight" label="权重 (%)" width="100" />
            <el-table-column prop="description" label="描述" />
            <el-table-column label="操作" width="100">
              <template #default="scope">
                <el-button size="small" type="danger" @click="removeIndicator(scope.$index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-button type="primary" @click="addIndicator">添加指标</el-button>
        </el-form-item>
        <el-form-item label="是否启用" prop="enabled">
          <el-switch v-model="planForm.enabled" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm">保存方案</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus';

interface Indicator {
  name: string;
  weight: number;
  description: string;
}

interface PerformancePlan {
  name: string;
  departments: string[];
  cycle: string;
  indicators: Indicator[];
  enabled: boolean;
}

const planFormRef = ref<FormInstance>();
const planForm = reactive<PerformancePlan>({
  name: '季度绩效评估方案',
  departments: ['技术部', '人力资源部'],
  cycle: '季度',
  indicators: [
    { name: '工作效率', weight: 30, description: '按时完成任务的效率' },
    { name: '工作质量', weight: 40, description: '工作成果的准确性和完整性' },
    { name: '团队协作', weight: 30, description: '与团队成员的合作情况' },
  ],
  enabled: true,
});

const rules = reactive<FormRules<PerformancePlan>>({
  name: [{ required: true, message: '请输入方案名称', trigger: 'blur' }],
  departments: [{ type: 'array', required: true, message: '请选择适用部门', trigger: 'change' }],
  cycle: [{ required: true, message: '请选择评估周期', trigger: 'change' }],
});

const addIndicator = () => {
  ElMessageBox.prompt('请输入指标名称、权重和描述 (例如: 效率,30,按时完成任务)', '添加评估指标', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /^(.+),(\d+),(.+)$/,
    inputErrorMessage: '请输入“名称,权重,描述”格式，例如“效率,30,按时完成任务”',
  })
    .then(({ value }) => {
      const [name, weightStr, description] = value.split(',');
      planForm.indicators.push({ name, weight: parseInt(weightStr), description });
      ElMessage.success('指标添加成功！');
    })
    .catch(() => {
      ElMessage.info('已取消添加指标');
    });
};

const removeIndicator = (index: number) => {
  planForm.indicators.splice(index, 1);
  ElMessage.success('指标删除成功！');
};

const submitForm = async () => {
  if (!planFormRef.value) return;
  await planFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('绩效方案保存成功！');
      console.log('提交的绩效方案:', planForm);
    } else {
      ElMessage.error('请检查表单填写！');
    }
  });
};

const resetForm = () => {
  if (!planFormRef.value) return;
  planFormRef.value.resetFields();
  planForm.indicators = [];
};
</script>

<style scoped>
.performance-plan-design-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
