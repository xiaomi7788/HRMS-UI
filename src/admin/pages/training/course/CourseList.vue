<template>
  <div class="training-course-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>课程管理</span>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="课程分类">
          <el-select
            v-model="queryParams.category"
            placeholder="请选择课程分类"
            clearable
            @change="handleQuery"
          >
            <el-option label="技能培训" value="技能培训" />
            <el-option label="管理培训" value="管理培训" />
            <el-option label="文化培训" value="文化培训" />
            <el-option label="合规培训" value="合规培训" />
          </el-select>
        </el-form-item>
        <el-form-item label="课程类型">
          <el-select
            v-model="queryParams.courseType"
            placeholder="请选择课程类型"
            clearable
            @change="handleQuery"
          >
            <el-option label="内部课程" :value="0" />
            <el-option label="外部课程" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="queryParams.status"
            placeholder="请选择状态"
            clearable
            @change="handleQuery"
          >
            <el-option label="下架" :value="0" />
            <el-option label="上架" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-bar">
        <el-button type="primary" @click="handleAdd">新增课程</el-button>
      </div>

      <!-- 课程列表 -->
      <el-table
        v-loading="loading"
        :data="courseList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="courseName" label="课程名称" width="200" />
        <el-table-column prop="category" label="课程分类" width="120" />
        <el-table-column label="课程类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.courseType === 0 ? 'primary' : 'success'">
              {{ row.courseType === 0 ? '内部' : '外部' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="instructor" label="讲师" width="120" />
        <el-table-column label="课程时长(小时)" width="120" align="right">
          <template #default="{ row }">
            {{ row.duration }}
          </template>
        </el-table-column>
        <el-table-column prop="description" label="课程描述" show-overflow-tooltip />
        <el-table-column label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '上架' : '下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
        @change="handleQuery"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="resetForm"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
      >
        <el-form-item label="课程名称" prop="courseName">
          <el-input v-model="formData.courseName" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程分类" prop="category">
          <el-select v-model="formData.category" placeholder="请选择课程分类" style="width: 100%">
            <el-option label="技能培训" value="技能培训" />
            <el-option label="管理培训" value="管理培训" />
            <el-option label="文化培训" value="文化培训" />
            <el-option label="合规培训" value="合规培训" />
          </el-select>
        </el-form-item>
        <el-form-item label="课程类型" prop="courseType">
          <el-select v-model="formData.courseType" placeholder="请选择课程类型" style="width: 100%">
            <el-option label="内部课程" :value="0" />
            <el-option label="外部课程" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="讲师姓名" prop="instructor">
          <el-input v-model="formData.instructor" placeholder="请输入讲师姓名" />
        </el-form-item>
        <el-form-item label="课程时长(小时)" prop="duration">
          <el-input-number
            v-model="formData.duration"
            :min="1"
            :precision="1"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="课程描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="4"
            placeholder="请输入课程描述"
          />
        </el-form-item>
        <el-form-item label="课程附件URL" prop="attachmentUrl">
          <el-input v-model="formData.attachmentUrl" placeholder="请输入课程附件URL" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="下架" :value="0" />
            <el-option label="上架" :value="1" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getCoursePage,
  createCourse,
  updateCourse,
  deleteCourse,
  type TrainingCourse,
  type CoursePageParams
} from '@/api/training'

// 列表数据
const loading = ref(false)
const courseList = ref<TrainingCourse[]>([])
const total = ref(0)
const queryParams = reactive<CoursePageParams>({
  pageNum: 1,
  pageSize: 10
})

// 新增/编辑对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增课程')
const isEdit = ref(false)
const formRef = ref<FormInstance>()
const formData = reactive<Partial<TrainingCourse>>({})

const formRules: FormRules = {
  courseName: [{ required: true, message: '请输入课程名称', trigger: 'blur' }],
  category: [{ required: true, message: '请选择课程分类', trigger: 'change' }],
  courseType: [{ required: true, message: '请选择课程类型', trigger: 'change' }],
  instructor: [{ required: true, message: '请输入讲师姓名', trigger: 'blur' }],
  duration: [{ required: true, message: '请输入课程时长', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getCoursePage(queryParams)
    courseList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取课程列表失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.category = undefined
  queryParams.courseType = undefined
  queryParams.status = undefined
  handleQuery()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增课程'
  isEdit.value = false
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: TrainingCourse) => {
  dialogTitle.value = '编辑课程'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 删除
const handleDelete = async (row: TrainingCourse) => {
  try {
    await ElMessageBox.confirm('确认要删除该课程吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteCourse(row.id!)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return

    try {
      if (isEdit.value) {
        await updateCourse(formData as TrainingCourse)
        ElMessage.success('更新成功')
      } else {
        const { id, createTime, updateTime, isDeleted, ...createData } = formData
        await createCourse(createData as TrainingCourse)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      handleQuery()
    } catch (error: any) {
      ElMessage.error(error.message || '操作失败')
    }
  })
}

// 重置表单
const resetForm = () => {
  Object.keys(formData).forEach((key) => {
    delete formData[key as keyof TrainingCourse]
  })
  formRef.value?.resetFields()
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.training-course-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.operation-bar {
  margin: 20px 0;
  display: flex;
  gap: 10px;
}
</style>
