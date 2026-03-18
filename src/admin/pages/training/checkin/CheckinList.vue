<template>
  <div class="training-checkin-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>培训签到管理</span>
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
        <el-form-item label="签到日期">
          <el-date-picker
            v-model="queryParams.checkinDate"
            type="date"
            placeholder="请选择签到日期"
            value-format="YYYY-MM-DD"
            clearable
            @change="handleQuery"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-bar">
        <el-button type="primary" @click="handleBatchCheckin">批量签到</el-button>
      </div>

      <!-- 签到记录列表 -->
      <el-table
        v-loading="loading"
        :data="checkinList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="employeeNo" label="员工编号" width="120" />
        <el-table-column prop="employeeName" label="员工姓名" width="120" />
        <el-table-column prop="deptName" label="部门" width="150" />
        <el-table-column prop="activityTitle" label="培训活动" width="200" />
        <el-table-column prop="checkinDate" label="签到日期" width="120" />
        <el-table-column prop="checkinTime" label="签到时间" width="180" />
        <el-table-column prop="checkoutTime" label="签退时间" width="180" />
        <el-table-column label="签到方式" width="100">
          <template #default="{ row }">
            <el-tag :type="getCheckinTypeType(row.checkinType)">
              {{ getCheckinTypeText(row.checkinType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template #default="{ row }">
            <el-tag v-if="row.isLate" type="warning" size="small">迟到</el-tag>
            <el-tag v-if="row.leaveEarly" type="danger" size="small">早退</el-tag>
            <el-tag v-if="!row.isLate && !row.leaveEarly" type="success" size="small">正常</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="参与时长(分钟)" width="120" align="right">
          <template #default="{ row }">
            {{ row.durationMinutes }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
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

    <!-- 批量签到对话框 -->
    <el-dialog
      v-model="batchDialogVisible"
      title="批量签到"
      width="600px"
    >
      <el-form
        ref="batchFormRef"
        :model="batchFormData"
        :rules="batchFormRules"
        label-width="120px"
      >
        <el-form-item label="培训活动" prop="activityId">
          <el-select v-model="batchFormData.activityId" placeholder="请选择培训活动" style="width: 100%">
            <el-option
              v-for="activity in activityList"
              :key="activity.id"
              :label="activity.title"
              :value="activity.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="选择员工" prop="employeeIds">
          <el-select
            v-model="batchFormData.employeeIds"
            placeholder="请选择员工"
            multiple
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="`${emp.empCode} - ${emp.empName}`"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="batchDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitBatch">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getCheckinPage,
  batchCheckin,
  deleteCheckin,
  type CheckinPageParams,
  type TrainingCheckin,
  type BatchCheckinParams
} from '@/api/training'
import { getEmployeePage } from '@/api/employee'

// 列表数据
const loading = ref(false)
const checkinList = ref<TrainingCheckin[]>([])
const activityList = ref<any[]>([])
const employeeList = ref<any[]>([])
const total = ref(0)
const queryParams = reactive<CheckinPageParams>({
  pageNum: 1,
  pageSize: 10
})

// 批量签到对话框
const batchDialogVisible = ref(false)
const batchFormRef = ref<FormInstance>()
const batchFormData = reactive<BatchCheckinParams>({
  activityId: undefined as any,
  employeeIds: []
})

const batchFormRules: FormRules = {
  activityId: [{ required: true, message: '请选择培训活动', trigger: 'change' }],
  employeeIds: [{ required: true, message: '请选择员工', trigger: 'change' }]
}

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getCheckinPage(queryParams)
    checkinList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取签到记录失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.activityId = undefined
  queryParams.checkinDate = undefined
  handleQuery()
}

// 批量签到
const handleBatchCheckin = () => {
  batchDialogVisible.value = true
}

// 提交批量签到
const handleSubmitBatch = async () => {
  if (!batchFormRef.value) return
  await batchFormRef.value.validate(async (valid) => {
    if (!valid) return

    try {
      await batchCheckin(batchFormData)
      ElMessage.success('批量签到成功')
      batchDialogVisible.value = false
      handleQuery()
    } catch (error) {
      ElMessage.error('批量签到失败')
    }
  })
}

// 删除
const handleDelete = async (row: TrainingCheckin) => {
  try {
    await ElMessageBox.confirm('确认要删除该签到记录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteCheckin(row.id!)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 获取签到方式文本
const getCheckinTypeText = (type: number) => {
  const map: Record<number, string> = {
    0: '手动',
    1: '扫码',
    2: '人脸'
  }
  return map[type] || '未知'
}

// 获取签到方式类型
const getCheckinTypeType = (type: number) => {
  const map: Record<number, string> = {
    0: 'info',
    1: 'success',
    2: 'primary'
  }
  return map[type] || 'info'
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

// 加载员工列表
const loadEmployeeList = async () => {
  try {
    const res = await getEmployeePage({ pageNum: 1, pageSize: 1000 })
    employeeList.value = res.records
  } catch (error) {
    console.error('加载员工列表失败', error)
  }
}

onMounted(() => {
  handleQuery()
  loadActivityList()
  loadEmployeeList()
})
</script>

<style scoped>
.training-checkin-container {
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
