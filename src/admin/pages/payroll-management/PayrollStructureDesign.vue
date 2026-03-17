<template>
  <div class="payroll-structure-design-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>薪酬结构设计</span>
        </div>
      </template>

      <el-form :model="payrollStructureForm" :rules="rules" ref="payrollStructureFormRef" label-width="150px">
        <el-form-item label="结构名称" prop="name">
          <el-input v-model="payrollStructureForm.name" placeholder="请输入薪酬结构名称" />
        </el-form-item>
        <el-form-item label="基础工资" prop="baseSalary">
          <el-input-number v-model="payrollStructureForm.baseSalary" :min="0" />
          <span style="margin-left: 10px;">元</span>
        </el-form-item>
        <el-form-item label="绩效工资比例" prop="performanceBonusRatio">
          <el-input-number v-model="payrollStructureForm.performanceBonusRatio" :min="0" :max="100" />
          <span style="margin-left: 10px;">%</span>
        </el-form-item>
        <el-form-item label="津贴项">
          <el-table :data="payrollStructureForm.allowances" style="width: 100%; margin-bottom: 10px;" border>
            <el-table-column prop="name" label="津贴名称" />
            <el-table-column prop="amount" label="金额" />
            <el-table-column label="操作" width="100">
              <template #default="scope">
                <el-button size="small" type="danger" @click="removeAllowance(scope.$index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-button type="primary" @click="addAllowance">添加津贴项</el-button>
        </el-form-item>
        <el-form-item label="扣除项">
          <el-table :data="payrollStructureForm.deductions" style="width: 100%; margin-bottom: 10px;" border>
            <el-table-column prop="name" label="扣除项名称" />
            <el-table-column prop="amount" label="金额" />
            <el-table-column label="操作" width="100">
              <template #default="scope">
                <el-button size="small" type="danger" @click="removeDeduction(scope.$index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-button type="primary" @click="addDeduction">添加扣除项</el-button>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm">保存薪酬结构</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus';

interface Allowance {
  name: string;
  amount: number;
}

interface Deduction {
  name: string;
  amount: number;
}

interface PayrollStructure {
  name: string;
  baseSalary: number;
  performanceBonusRatio: number;
  allowances: Allowance[];
  deductions: Deduction[];
}

const payrollStructureFormRef = ref<FormInstance>();
const payrollStructureForm = reactive<PayrollStructure>({
  name: '默认薪酬结构',
  baseSalary: 5000,
  performanceBonusRatio: 20,
  allowances: [
    { name: '交通补贴', amount: 200 },
    { name: '餐补', amount: 300 },
  ],
  deductions: [
    { name: '社保', amount: 500 },
    { name: '公积金', amount: 300 },
  ],
});

const rules = reactive<FormRules<PayrollStructure>>({
  name: [{ required: true, message: '请输入薪酬结构名称', trigger: 'blur' }],
  baseSalary: [{ required: true, message: '请输入基础工资', trigger: 'blur' }],
  performanceBonusRatio: [{ required: true, message: '请输入绩效工资比例', trigger: 'blur' }],
});

const addAllowance = () => {
  ElMessageBox.prompt('请输入津贴名称和金额', '添加津贴', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /^(.+),(\d+(\.\d+)?)$/,
    inputErrorMessage: '请输入“名称,金额”格式，例如“交通补贴,200”',
  })
    .then(({ value }) => {
      const [name, amountStr] = value.split(',');
      payrollStructureForm.allowances.push({ name, amount: parseFloat(amountStr) });
      ElMessage.success('津贴添加成功！');
    })
    .catch(() => {
      ElMessage.info('已取消添加津贴');
    });
};

const removeAllowance = (index: number) => {
  payrollStructureForm.allowances.splice(index, 1);
  ElMessage.success('津贴删除成功！');
};

const addDeduction = () => {
  ElMessageBox.prompt('请输入扣除项名称和金额', '添加扣除项', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /^(.+),(\d+(\.\d+)?)$/,
    inputErrorMessage: '请输入“名称,金额”格式，例如“社保,500”',
  })
    .then(({ value }) => {
      const [name, amountStr] = value.split(',');
      payrollStructureForm.deductions.push({ name, amount: parseFloat(amountStr) });
      ElMessage.success('扣除项添加成功！');
    })
    .catch(() => {
      ElMessage.info('已取消添加扣除项');
    });
};

const removeDeduction = (index: number) => {
  payrollStructureForm.deductions.splice(index, 1);
  ElMessage.success('扣除项删除成功！');
};

const submitForm = async () => {
  if (!payrollStructureFormRef.value) return;
  await payrollStructureFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('薪酬结构保存成功！');
      console.log('提交的薪酬结构:', payrollStructureForm);
    } else {
      ElMessage.error('请检查表单填写！');
    }
  });
};

const resetForm = () => {
  if (!payrollStructureFormRef.value) return;
  payrollStructureFormRef.value.resetFields();
  payrollStructureForm.allowances = [];
  payrollStructureForm.deductions = [];
};
</script>

<style scoped>
.payroll-structure-design-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
