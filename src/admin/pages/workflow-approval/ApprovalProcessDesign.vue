<template>
  <div class="approval-process-design-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>审批流程设计</span>
        </div>
      </template>

      <el-form :model="processForm" :rules="rules" ref="processFormRef" label-width="120px">
        <el-form-item label="流程名称" prop="name">
          <el-input v-model="processForm.name" placeholder="请输入审批流程名称" />
        </el-form-item>
        <el-form-item label="适用类型" prop="type">
          <el-select v-model="processForm.type" placeholder="请选择适用类型" style="width: 100%;">
            <el-option label="请假审批" value="请假审批" />
            <el-option label="报销审批" value="报销审批" />
            <el-option label="加班审批" value="加班审批" />
          </el-select>
        </el-form-item>
        <el-form-item label="流程节点">
          <el-timeline style="max-width: 600px">
            <el-timeline-item
              v-for="(node, index) in processForm.nodes"
              :key="index"
              :timestamp="`节点 ${index + 1}`"
              placement="top"
            >
              <el-card>
                <h4>{{ node.name }}</h4>
                <p>审批人: {{ node.approver }}</p>
                <el-button type="danger" size="small" @click="removeNode(index)">删除节点</el-button>
              </el-card>
            </el-timeline-item>
          </el-timeline>
          <el-button type="primary" @click="addNode">添加节点</el-button>
        </el-form-item>
        <el-form-item label="是否启用" prop="enabled">
          <el-switch v-model="processForm.enabled" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="submitForm">保存流程</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus';

interface ApprovalNode {
  name: string;
  approver: string;
}

interface ApprovalProcess {
  name: string;
  type: string;
  nodes: ApprovalNode[];
  enabled: boolean;
}

const processFormRef = ref<FormInstance>();
const processForm = reactive<ApprovalProcess>({
  name: '请假审批流程',
  type: '请假审批',
  nodes: [
    { name: '直接上级审批', approver: '部门负责人' },
    { name: 'HR审批', approver: 'HR专员' },
    { name: '总经理审批', approver: '总经理' },
  ],
  enabled: true,
});

const rules = reactive<FormRules<ApprovalProcess>>({
  name: [{ required: true, message: '请输入流程名称', trigger: 'blur' }],
  type: [{ required: true, message: '请选择适用类型', trigger: 'change' }],
  nodes: [{ type: 'array', required: true, message: '请至少添加一个流程节点', trigger: 'change' }],
});

const addNode = () => {
  ElMessageBox.prompt('请输入节点名称和审批人 (例如: 上级审批,部门负责人)', '添加流程节点', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPattern: /^(.+),(.+)$/,
    inputErrorMessage: '请输入“节点名称,审批人”格式，例如“上级审批,部门负责人”',
  })
    .then(({ value }) => {
      const [name, approver] = value.split(',');
      processForm.nodes.push({ name, approver });
      ElMessage.success('节点添加成功！');
    })
    .catch(() => {
      ElMessage.info('已取消添加节点');
    });
};

const removeNode = (index: number) => {
  processForm.nodes.splice(index, 1);
  ElMessage.success('节点删除成功！');
};

const submitForm = async () => {
  if (!processFormRef.value) return;
  await processFormRef.value.validate((valid) => {
    if (valid) {
      ElMessage.success('审批流程保存成功！');
      console.log('提交的审批流程:', processForm);
    } else {
      ElMessage.error('请检查表单填写！');
    }
  });
};

const resetForm = () => {
  if (!processFormRef.value) return;
  processFormRef.value.resetFields();
  processForm.nodes = [];
};
</script>

<style scoped>
.approval-process-design-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
