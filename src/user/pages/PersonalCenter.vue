<template>
  <div class="personal-center-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>个人信息</span>
        </div>
      </template>
      <el-row :gutter="20">
        <el-col :span="6" class="avatar-upload-section">
          <el-avatar :size="100" :src="userStore.userInfo?.avatar || 'https://cube.elemecdn.com/3/7c/3ed6826170ee4e3fdeb8e64338717jpeg.jpeg'"></el-avatar>
          <el-button type="primary" link>上传头像</el-button>
        </el-col>
        <el-col :span="18">
          <el-form :model="userInfoForm" label-width="100px" label-position="left">
            <el-form-item label="用户名">
              <el-input v-model="userInfoForm.username" disabled></el-input>
            </el-form-item>
            <el-form-item label="昵称">
              <el-input v-model="userInfoForm.nickname"></el-input>
            </el-form-item>
            <el-form-item label="联系方式">
              <el-input v-model="userInfoForm.contact"></el-input>
            </el-form-item>
            <el-form-item label="岗位">
              <el-input v-model="userInfoForm.position" disabled></el-input>
            </el-form-item>
            <el-form-item label="部门">
              <el-input v-model="userInfoForm.department" disabled></el-input>
            </el-form-item>
            <el-form-item label="入职时间">
              <el-input v-model="userInfoForm.hireDate" disabled></el-input>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveUserInfo">保存</el-button>
              <el-button @click="resetUserInfo">重置</el-button>
              <el-button type="warning" @click="showPasswordDialog = true">修改密码</el-button>
            </el-form-item>
          </el-form>
        </el-col>
      </el-row>
    </el-card>

    <!-- 修改密码对话框 -->
    <el-dialog
      v-model="showPasswordDialog"
      title="修改登录密码"
      width="30%"
      :before-close="handleClosePasswordDialog"
    >
      <el-form :model="passwordForm" label-width="100px" label-position="left" ref="passwordFormRef" :rules="passwordRules">
        <el-form-item label="旧密码" prop="oldPassword">
          <el-input type="password" v-model="passwordForm.oldPassword" show-password></el-input>
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input type="password" v-model="passwordForm.newPassword" show-password></el-input>
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPassword">
          <el-input type="password" v-model="passwordForm.confirmPassword" show-password></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleClosePasswordDialog">取消</el-button>
          <el-button type="primary" @click="changePassword">确认修改</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue';
import { useUserStore } from '@/stores/user';
import { ElMessage, ElMessageBox } from 'element-plus';
import type { FormInstance } from 'element-plus';

const userStore = useUserStore();

// 控制修改密码对话框的显示
const showPasswordDialog = ref(false);

// 个人信息表单
const userInfoForm = reactive({
  username: userStore.userInfo?.username || '',
  nickname: userStore.userInfo?.nickname || '',
  contact: '', // 假设联系方式需要编辑
  position: '前端开发工程师', // 模拟数据
  department: '技术部', // 模拟数据
  hireDate: '2022-01-01', // 模拟数据
});

const saveUserInfo = () => {
  // 模拟保存个人信息
  ElMessage.success('个人信息保存成功！');
  // 实际应用中会调用API更新用户信息
};

const resetUserInfo = () => {
  // 模拟重置个人信息
  userInfoForm.nickname = userStore.userInfo?.nickname || '';
  userInfoForm.contact = '';
  ElMessage.info('个人信息已重置。');
};

// 修改密码表单
const passwordFormRef = ref<FormInstance>();
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: '',
});

// 密码验证规则
const passwordRules = reactive({
  oldPassword: [
    { required: true, message: '请输入旧密码', trigger: 'blur' },
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '新密码长度不能少于6位', trigger: 'blur' },
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (rule: any, value: string, callback: any) => {
        void rule;
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的新密码不一致!'));
        } else {
          callback();
        }
      },
      trigger: 'blur',
    },
  ],
});

const handleClosePasswordDialog = () => {
  ElMessageBox.confirm('确定取消修改密码吗？未保存的更改将丢失。')
    .then(() => {
      showPasswordDialog.value = false;
      passwordFormRef.value?.resetFields(); // 关闭时重置表单
    })
    .catch(() => {
      // catch error
    });
};

const changePassword = () => {
  const formRef = passwordFormRef.value;
  if (!formRef) return;
  formRef.validate((valid) => {
    if (valid) {
      if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        ElMessage.error('两次输入的新密码不一致！');
        return;
      }
      // 模拟修改密码
      ElMessage.success('密码修改成功！');
      // 实际应用中会调用API修改密码
      showPasswordDialog.value = false; // 关闭对话框
      formRef.resetFields();
    } else {
      ElMessage.error('请填写完整并正确的信息！');
    }
  });
};

</script>

<style scoped>
.personal-center-container {
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

.avatar-upload-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  border-right: 1px solid #ebeef5;
}

.el-avatar {
  margin-bottom: 10px;
}

.password-card {
  max-width: 600px;
}
</style>
