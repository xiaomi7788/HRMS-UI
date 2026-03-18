<template>
  <div class="training-activity-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>培训活动管理</span>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="课程">
          <el-select
            v-model="queryParams.courseId"
            placeholder="请选择课程"
            clearable
            @change="handleQuery"
          >
            <el-option
              v-for="course in courseList"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="queryParams.status"
            placeholder="请选择状态"
            clearable
            @change="handleQuery"
          >
            <el-option label="草稿" :value="0" />
            <el-option label="报名中" :value="1" />
            <el-option label="进行中" :value="2" />
            <el-option label="已完成" :value="3" />
            <el-option label="已取消" :value="4" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-bar">
        <el-button type="primary" @click="handleAdd">新增活动</el-button>
        <el-button type="success" @click="showRecordDialog">学习记录</el-button>
      </div>

      <!-- 活动列表 -->
      <el-table
        v-loading="loading"
        :data="activityList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="title" label="活动标题" width="200" />
        <el-table-column prop="courseName" label="关联课程" width="150" />
        <el-table-column prop="startDate" label="开始日期" width="120" />
        <el-table-column prop="endDate" label="结束日期" width="120" />
        <el-table-column prop="location" label="培训地点" width="150" />
        <el-table-column prop="registrationDeadline" label="报名截止" width="120" />
        <el-table-column label="报名人数" width="100">
          <template #default="{ row }">
            {{ row.currentParticipants }} / {{ row.maxParticipants }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button
              v-if="row.status === 1"
              link
              type="success"
              size="small"
              @click="handleEnroll(row)"
            >
              报名
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
        <el-form-item label="活动标题" prop="title">
          <el-input v-model="formData.title" placeholder="请输入活动标题" />
        </el-form-item>
        <el-form-item label="关联课程" prop="courseId">
          <el-select v-model="formData.courseId" placeholder="请选择课程" style="width: 100%">
            <el-option
              v-for="course in courseList"
              :key="course.id"
              :label="course.courseName"
              :value="course.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="开始日期" prop="startDate">
          <el-date-picker
            v-model="formData.startDate"
            type="date"
            placeholder="请选择开始日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="结束日期" prop="endDate">
          <el-date-picker
            v-model="formData.endDate"
            type="date"
            placeholder="请选择结束日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="培训地点" prop="location">
          <el-input v-model="formData.location" placeholder="请输入培训地点" />
        </el-form-item>
        <el-form-item label="报名截止日期" prop="registrationDeadline">
          <el-date-picker
            v-model="formData.registrationDeadline"
            type="date"
            placeholder="请选择报名截止日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="最大人数" prop="maxParticipants">
          <el-input-number
            v-model="formData.maxParticipants"
            :min="1"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="草稿" :value="0" />
            <el-option label="报名中" :value="1" />
            <el-option label="进行中" :value="2" />
            <el-option label="已完成" :value="3" />
            <el-option label="已取消" :value="4" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 学习记录对话框 -->
    <el-dialog
      v-model="recordDialogVisible"
      title="培训学习记录"
      width="90%"
      top="5vh"
    >
      <el-form :inline="true" :model="recordQueryParams" class="search-form">
        <el-form-item label="培训活动">
          <el-select
            v-model="recordQueryParams.activityId"
            placeholder="请选择培训活动"
            clearable
            @change="handleRecordQuery"
          >
            <el-option
              v-for="activity in activityList"
              :key="activity.id"
              :label="activity.title"
              :value="activity.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="报名状态">
          <el-select
            v-model="recordQueryParams.enrollStatus"
            placeholder="请选择报名状态"
            clearable
            @change="handleRecordQuery"
          >
            <el-option label="待审核" :value="0" />
            <el-option label="已通过" :value="1" />
            <el-option label="已拒绝" :value="2" />
            <el-option label="已取消" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleRecordQuery">查询</el-button>
        </el-form-item>
      </el-form>

      <el-table
        v-loading="recordLoading"
        :data="recordList"
        border
        stripe
        style="width: 100%; margin-top: 10px"
      >
        <el-table-column prop="employeeNo" label="员工编号" width="120" />
        <el-table-column prop="employeeName" label="员工姓名" width="120" />
        <el-table-column prop="activityTitle" label="培训活动" width="200" />
        <el-table-column label="报名状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getEnrollStatusType(row.enrollStatus)">
              {{ getEnrollStatusText(row.enrollStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="完成状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.completionStatus === 1 ? 'success' : 'info'">
              {{ row.completionStatus === 1 ? '已完成' : '未完成' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="examScore" label="考试得分" width="100" />
        <el-table-column prop="satisfactionScore" label="满意度" width="80" />
        <el-table-column prop="feedback" label="学习反馈" show-overflow-tooltip />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.enrollStatus === 0"
              link
              type="success"
              size="small"
              @click="handleAuditRecord(row, 1)"
            >
              通过
            </el-button>
            <el-button
              v-if="row.enrollStatus === 0"
              link
              type="warning"
              size="small"
              @click="handleAuditRecord(row, 2)"
            >
              拒绝
            </el-button>
            <el-button
              v-if="row.enrollStatus === 1 && row.completionStatus === 0"
              link
              type="primary"
              size="small"
              @click="handleComplete(row)"
            >
              完成情况
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="recordQueryParams.pageNum"
        v-model:page-size="recordQueryParams.pageSize"
        :total="recordTotal"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
        @change="handleRecordQuery"
      />
    </el-dialog>

    <!-- 完成情况对话框 -->
    <el-dialog
      v-model="completeDialogVisible"
      title="录入培训完成情况"
      width="500px"
    >
      <el-form
        ref="completeFormRef"
        :model="completeFormData"
        :rules="completeFormRules"
        label-width="100px"
      >
        <el-form-item label="完成状态" prop="completionStatus">
          <el-select v-model="completeFormData.completionStatus" placeholder="请选择完成状态">
            <el-option label="未完成" :value="0" />
            <el-option label="已完成" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="考试得分" prop="examScore">
          <el-input-number
            v-model="completeFormData.examScore"
            :min="0"
            :max="100"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="满意度评分" prop="satisfactionScore">
          <el-rate v-model="completeFormData.satisfactionScore" :max="5" />
        </el-form-item>
        <el-form-item label="学习反馈" prop="feedback">
          <el-input
            v-model="completeFormData.feedback"
            type="textarea"
            :rows="3"
            placeholder="请输入学习反馈"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="completeDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitComplete">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getActivityPage,
  createActivity,
  updateActivity,
  deleteActivity,
  enrollActivity,
  getRecordPage,
  auditRecord,
  completeRecord,
  type TrainingActivity,
  type ActivityPageParams,
  type TrainingRecord
} from '@/api/training'

// 活动列表
const loading = ref(false)
const activityList = ref<TrainingActivity[]>([])
const courseList = ref<any[]>([])
const total = ref(0)
const queryParams = reactive<ActivityPageParams>({
  pageNum: 1,
  pageSize: 10
})

// 新增/编辑对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增培训活动')
const isEdit = ref(false)
const formRef = ref<FormInstance>()
const formData = reactive<Partial<TrainingActivity>>({})

const formRules: FormRules = {
  title: [{ required: true, message: '请输入活动标题', trigger: 'blur' }],
  courseId: [{ required: true, message: '请选择课程', trigger: 'change' }],
  startDate: [{ required: true, message: '请选择开始日期', trigger: 'change' }],
  endDate: [{ required: true, message: '请选择结束日期', trigger: 'change' }],
  location: [{ required: true, message: '请输入培训地点', trigger: 'blur' }],
  registrationDeadline: [{ required: true, message: '请选择报名截止日期', trigger: 'change' }],
  maxParticipants: [{ required: true, message: '请输入最大人数', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

// 学习记录
const recordDialogVisible = ref(false)
const recordLoading = ref(false)
const recordList = ref<TrainingRecord[]>([])
const recordTotal = ref(0)
const recordQueryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  activityId: undefined as number | undefined,
  enrollStatus: undefined as number | undefined
})

// 完成情况
const completeDialogVisible = ref(false)
const completeFormRef = ref<FormInstance>()
const currentRecord = ref<TrainingRecord | null>(null)
const completeFormData = reactive({
  completionStatus: 1,
  examScore: 0,
  satisfactionScore: 5,
  feedback: ''
})

const completeFormRules: FormRules = {
  completionStatus: [{ required: true, message: '请选择完成状态', trigger: 'change' }]
}

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getActivityPage(queryParams)
    activityList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取活动列表失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.courseId = undefined
  queryParams.status = undefined
  handleQuery()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增培训活动'
  isEdit.value = false
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: TrainingActivity) => {
  dialogTitle.value = '编辑培训活动'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 报名
const handleEnroll = async (row: TrainingActivity) => {
  try {
    await ElMessageBox.confirm('确认要报名该培训活动吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await enrollActivity(row.id!)
    ElMessage.success('报名成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('报名失败')
    }
  }
}

// 删除
const handleDelete = async (row: TrainingActivity) => {
  try {
    await ElMessageBox.confirm('确认要删除该培训活动吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteActivity(row.id!)
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
        await updateActivity(formData as TrainingActivity)
        ElMessage.success('更新成功')
      } else {
        const { id, createTime, updateTime, isDeleted, ...createData } = formData
        await createActivity(createData as TrainingActivity)
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
    delete formData[key as keyof TrainingActivity]
  })
  formRef.value?.resetFields()
}

// 显示学习记录
const showRecordDialog = () => {
  recordDialogVisible.value = true
  handleRecordQuery()
}

// 查询学习记录
const handleRecordQuery = async () => {
  recordLoading.value = true
  try {
    const res = await getRecordPage(recordQueryParams)
    recordList.value = res.records
    recordTotal.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取学习记录失败')
  } finally {
    recordLoading.value = false
  }
}

// 审核报名
const handleAuditRecord = async (row: TrainingRecord, status: number) => {
  try {
    await auditRecord(row.id!, { status })
    ElMessage.success(status === 1 ? '已通过' : '已拒绝')
    handleRecordQuery()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

// 完成情况
const handleComplete = (row: TrainingRecord) => {
  currentRecord.value = row
  completeFormData.completionStatus = row.completionStatus ?? 0
  completeFormData.examScore = row.examScore ?? 0
  completeFormData.satisfactionScore = row.satisfactionScore ?? 5
  completeFormData.feedback = row.feedback ?? ''
  completeDialogVisible.value = true
}

// 提交完成情况
const handleSubmitComplete = async () => {
  if (!completeFormRef.value || !currentRecord.value) return
  await completeFormRef.value.validate(async (valid) => {
    if (!valid) return

    try {
      await completeRecord(currentRecord.value.id!, completeFormData)
      ElMessage.success('录入成功')
      completeDialogVisible.value = false
      handleRecordQuery()
    } catch (error) {
      ElMessage.error('操作失败')
    }
  })
}

// 获取状态文本
const getStatusText = (status: number) => {
  const map: Record<number, string> = {
    0: '草稿',
    1: '报名中',
    2: '进行中',
    3: '已完成',
    4: '已取消'
  }
  return map[status] || '未知'
}

// 获取状态类型
const getStatusType = (status: number) => {
  const map: Record<number, string> = {
    0: 'info',
    1: 'primary',
    2: 'warning',
    3: 'success',
    4: 'danger'
  }
  return map[status] || 'info'
}

// 获取报名状态文本
const getEnrollStatusText = (status: number) => {
  const map: Record<number, string> = {
    0: '待审核',
    1: '已通过',
    2: '已拒绝',
    3: '已取消'
  }
  return map[status] || '未知'
}

// 获取报名状态类型
const getEnrollStatusType = (status: number) => {
  const map: Record<number, string> = {
    0: 'info',
    1: 'success',
    2: 'danger',
    3: 'warning'
  }
  return map[status] || 'info'
}

// 加载课程列表
const loadCourseList = async () => {
  try {
    const { getCoursePage } = await import('@/api/training')
    const res = await getCoursePage({ pageNum: 1, pageSize: 1000 })
    courseList.value = res.records
  } catch (error) {
    console.error('加载课程列表失败', error)
  }
}

onMounted(() => {
  handleQuery()
  loadCourseList()
})
</script>

<style scoped>
.training-activity-container {
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
