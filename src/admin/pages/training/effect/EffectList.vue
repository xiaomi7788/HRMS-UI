<template>
  <div class="training-effect-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>效果评估报告</span>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="培训活动">
          <el-select
            v-model="queryParams.activityId"
            placeholder="请选择培训活动"
            clearable
            @change="handleQuery"
          >
            <el-option
              v-for="activity in activityList"
              :key="activity.id"
              :label="activity.title"
              :value="activity.id"
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
            <el-option label="已发布" :value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-bar">
        <el-button type="success" @click="handleGenerate">生成报告</el-button>
        <el-button type="primary" @click="handleAdd">新增报告</el-button>
      </div>

      <!-- 报告列表 -->
      <el-table
        v-loading="loading"
        :data="reportList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="reportTitle" label="报告标题" width="200" />
        <el-table-column prop="activityTitle" label="培训活动" width="200" />
        <el-table-column prop="totalEnrolled" label="总报名" width="80" />
        <el-table-column prop="totalCompleted" label="完成人数" width="80" />
        <el-table-column label="完成率" width="100">
          <template #default="{ row }">
            {{ (row.completionRate * 100).toFixed(2) }}%
          </template>
        </el-table-column>
        <el-table-column prop="avgExamScore" label="平均分" width="80" />
        <el-table-column label="通过率" width="100">
          <template #default="{ row }">
            {{ (row.passRate * 100).toFixed(2) }}%
          </template>
        </el-table-column>
        <el-table-column prop="avgSatisfaction" label="平均满意度" width="100" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '已发布' : '草稿' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button
              v-if="row.status === 0"
              link
              type="success"
              size="small"
              @click="handlePublish(row)"
            >
              发布
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
      width="800px"
      @close="resetForm"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="120px"
      >
        <el-form-item label="报告标题" prop="reportTitle">
          <el-input v-model="formData.reportTitle" placeholder="请输入报告标题" />
        </el-form-item>
        <el-form-item label="培训活动" prop="activityId">
          <el-select v-model="formData.activityId" placeholder="请选择培训活动" style="width: 100%">
            <el-option
              v-for="activity in activityList"
              :key="activity.id"
              :label="activity.title"
              :value="activity.id"
            />
          </el-select>
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="总报名人数" prop="totalEnrolled">
              <el-input-number v-model="formData.totalEnrolled" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="完成人数" prop="totalCompleted">
              <el-input-number v-model="formData.totalCompleted" :min="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="平均考核分" prop="avgExamScore">
              <el-input-number v-model="formData.avgExamScore" :min="0" :max="100" :precision="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="平均满意度" prop="avgSatisfaction">
              <el-input-number v-model="formData.avgSatisfaction" :min="1" :max="5" :precision="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="完成率(%)" prop="completionRate">
              <el-input-number v-model="formData.completionRate" :min="0" :max="1" :step="0.01" :precision="3" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="通过率(%)" prop="passRate">
              <el-input-number v-model="formData.passRate" :min="0" :max="1" :step="0.01" :precision="3" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="及格线" prop="passThreshold">
          <el-input-number v-model="formData.passThreshold" :min="0" :max="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="综合总结" prop="summary">
          <el-input
            v-model="formData.summary"
            type="textarea"
            :rows="4"
            placeholder="请输入综合总结"
          />
        </el-form-item>
        <el-form-item label="改进建议" prop="suggestions">
          <el-input
            v-model="formData.suggestions"
            type="textarea"
            :rows="4"
            placeholder="请输入改进建议"
          />
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
  getReportPage,
  createReport,
  updateReport,
  deleteReport,
  generateReport,
  publishReport,
  type TrainingEffectReport,
  type ReportPageParams
} from '@/api/training'

// 列表数据
const loading = ref(false)
const reportList = ref<TrainingEffectReport[]>([])
const activityList = ref<any[]>([])
const total = ref(0)
const queryParams = reactive<ReportPageParams>({
  pageNum: 1,
  pageSize: 10
})

// 新增/编辑对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增效果报告')
const isEdit = ref(false)
const formRef = ref<FormInstance>()
const formData = reactive<Partial<TrainingEffectReport>>({})

const formRules: FormRules = {
  reportTitle: [{ required: true, message: '请输入报告标题', trigger: 'blur' }],
  activityId: [{ required: true, message: '请选择培训活动', trigger: 'change' }]
}

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getReportPage(queryParams)
    reportList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取报告列表失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.activityId = undefined
  queryParams.status = undefined
  handleQuery()
}

// 生成报告
const handleGenerate = async () => {
  try {
    const { value } = await ElMessageBox.prompt('请选择培训活动生成报告', '生成效果报告', {
      confirmButtonText: '生成',
      cancelButtonText: '取消',
      inputType: 'select',
      inputOptions: activityList.value.map((a: any) => ({
        value: a.id,
        label: a.title
      }))
    })
    await generateReport({ activityId: Number(value) })
    ElMessage.success('报告生成成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('生成报告失败')
    }
  }
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增效果报告'
  isEdit.value = false
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: TrainingEffectReport) => {
  dialogTitle.value = '编辑效果报告'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 发布
const handlePublish = async (row: TrainingEffectReport) => {
  try {
    await ElMessageBox.confirm('确认要发布该报告吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await publishReport(row.id!)
    ElMessage.success('发布成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('发布失败')
    }
  }
}

// 删除
const handleDelete = async (row: TrainingEffectReport) => {
  try {
    await ElMessageBox.confirm('确认要删除该报告吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteReport(row.id!)
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
        await updateReport(formData as TrainingEffectReport)
        ElMessage.success('更新成功')
      } else {
        const { id, createTime, updateTime, isDeleted, ...createData } = formData
        await createReport(createData as TrainingEffectReport)
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
    delete formData[key as keyof TrainingEffectReport]
  })
  formRef.value?.resetFields()
}

// 加载活动列表
const loadActivityList = async () => {
  try {
    const { getActivityPage } = await import('@/api/training')
    const res = await getActivityPage({ pageNum: 1, pageSize: 1000 })
    activityList.value = res.records
  } catch (error) {
    console.error('加载活动列表失败', error)
  }
}

onMounted(() => {
  handleQuery()
  loadActivityList()
})
</script>

<style scoped>
.training-effect-container {
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
