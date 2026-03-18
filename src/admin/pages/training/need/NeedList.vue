<template>
  <div class="training-need-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>培训需求管理</span>
        </div>
      </template>

      <!-- 查询表单 -->
      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="年度">
          <el-date-picker
            v-model="queryParams.year"
            type="year"
            placeholder="请选择年度"
            value-format="YYYY"
            clearable
            @change="handleQuery"
          />
        </el-form-item>
        <el-form-item label="培训类别">
          <el-select
            v-model="queryParams.category"
            placeholder="请选择培训类别"
            clearable
            @change="handleQuery"
          >
            <el-option label="技能培训" value="技能培训" />
            <el-option label="管理培训" value="管理培训" />
            <el-option label="文化培训" value="文化培训" />
            <el-option label="合规培训" value="合规培训" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select
            v-model="queryParams.status"
            placeholder="请选择状态"
            clearable
            @change="handleQuery"
          >
            <el-option label="待审核" :value="0" />
            <el-option label="已纳入计划" :value="1" />
            <el-option label="已拒绝" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-bar">
        <el-button type="primary" @click="handleAdd">新增需求</el-button>
      </div>

      <!-- 需求列表 -->
      <el-table
        v-loading="loading"
        :data="needList"
        border
        stripe
        style="width: 100%; margin-top: 20px"
      >
        <el-table-column prop="year" label="年度" width="100" />
        <el-table-column prop="deptName" label="提报部门" width="120" />
        <el-table-column prop="employeeName" label="提报人" width="100" />
        <el-table-column prop="needTitle" label="需求标题" width="200" />
        <el-table-column prop="needDesc" label="需求描述" show-overflow-tooltip />
        <el-table-column prop="category" label="培训类别" width="100" />
        <el-table-column label="优先级" width="80">
          <template #default="{ row }">
            <el-tag :type="getPriorityType(row.priority)">
              {{ getPriorityText(row.priority) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="expectedTime" label="期望时间" width="120" />
        <el-table-column prop="participants" label="预计人数" width="80" />
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
              v-if="row.status === 0"
              link
              type="success"
              size="small"
              @click="handleAudit(row, 1)"
            >
              纳入计划
            </el-button>
            <el-button
              v-if="row.status === 0"
              link
              type="warning"
              size="small"
              @click="handleAudit(row, 2)"
            >
              拒绝
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
        <el-form-item label="年度" prop="year">
          <el-date-picker
            v-model="formData.year"
            type="year"
            placeholder="请选择年度"
            value-format="YYYY"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="提报部门" prop="deptId">
          <el-select v-model="formData.deptId" placeholder="请选择部门" style="width: 100%">
            <el-option
              v-for="dept in deptList"
              :key="dept.id"
              :label="dept.deptName"
              :value="dept.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="提报人" prop="employeeId">
          <el-select
            v-model="formData.employeeId"
            placeholder="请选择员工"
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
        <el-form-item label="需求标题" prop="needTitle">
          <el-input v-model="formData.needTitle" placeholder="请输入需求标题" />
        </el-form-item>
        <el-form-item label="需求描述" prop="needDesc">
          <el-input
            v-model="formData.needDesc"
            type="textarea"
            :rows="3"
            placeholder="请输入需求描述"
          />
        </el-form-item>
        <el-form-item label="培训类别" prop="category">
          <el-select v-model="formData.category" placeholder="请选择培训类别" style="width: 100%">
            <el-option label="技能培训" value="技能培训" />
            <el-option label="管理培训" value="管理培训" />
            <el-option label="文化培训" value="文化培训" />
            <el-option label="合规培训" value="合规培训" />
          </el-select>
        </el-form-item>
        <el-form-item label="优先级" prop="priority">
          <el-select v-model="formData.priority" placeholder="请选择优先级" style="width: 100%">
            <el-option label="低" :value="1" />
            <el-option label="中" :value="2" />
            <el-option label="高" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="期望培训时间" prop="expectedTime">
          <el-date-picker
            v-model="formData.expectedTime"
            type="date"
            placeholder="请选择期望培训时间"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="预计参与人数" prop="participants">
          <el-input-number
            v-model="formData.participants"
            :min="1"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="formData.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注"
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
  getNeedPage,
  createNeed,
  updateNeed,
  deleteNeed,
  auditNeed,
  type TrainingNeed,
  type NeedPageParams
} from '@/api/training'
import { getEmployeePage } from '@/api/employee'
import { getDeptPage } from '@/api/dept'

// 列表数据
const loading = ref(false)
const needList = ref<TrainingNeed[]>([])
const total = ref(0)
const queryParams = reactive<NeedPageParams>({
  pageNum: 1,
  pageSize: 10
})

// 员工和部门列表
const employeeList = ref<any[]>([])
const deptList = ref<any[]>([])

// 新增/编辑对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增培训需求')
const isEdit = ref(false)
const formRef = ref<FormInstance>()
const formData = reactive<Partial<TrainingNeed>>({})

const formRules: FormRules = {
  year: [{ required: true, message: '请选择年度', trigger: 'change' }],
  deptId: [{ required: true, message: '请选择提报部门', trigger: 'change' }],
  employeeId: [{ required: true, message: '请选择提报人', trigger: 'change' }],
  needTitle: [{ required: true, message: '请输入需求标题', trigger: 'blur' }],
  needDesc: [{ required: true, message: '请输入需求描述', trigger: 'blur' }],
  category: [{ required: true, message: '请选择培训类别', trigger: 'change' }],
  priority: [{ required: true, message: '请选择优先级', trigger: 'change' }],
  expectedTime: [{ required: true, message: '请选择期望培训时间', trigger: 'change' }],
  participants: [{ required: true, message: '请输入预计参与人数', trigger: 'blur' }]
}

// 查询列表
const handleQuery = async () => {
  loading.value = true
  try {
    const res = await getNeedPage(queryParams)
    needList.value = res.records
    total.value = Number(res.total)
  } catch (error) {
    ElMessage.error('获取需求列表失败')
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryParams.pageNum = 1
  queryParams.pageSize = 10
  queryParams.year = undefined
  queryParams.category = undefined
  queryParams.status = undefined
  handleQuery()
}

// 新增
const handleAdd = () => {
  dialogTitle.value = '新增培训需求'
  isEdit.value = false
  dialogVisible.value = true
}

// 编辑
const handleEdit = (row: TrainingNeed) => {
  dialogTitle.value = '编辑培训需求'
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

// 审核通过/拒绝
const handleAudit = async (row: TrainingNeed, status: number) => {
  try {
    await ElMessageBox.confirm(
      status === 1 ? '确认将该需求纳入培训计划吗？' : '确认拒绝该培训需求吗？',
      '提示',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    await auditNeed(row.id!, { status })
    ElMessage.success(status === 1 ? '已纳入计划' : '已拒绝')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('操作失败')
    }
  }
}

// 删除
const handleDelete = async (row: TrainingNeed) => {
  try {
    await ElMessageBox.confirm('确认要删除该培训需求吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteNeed(row.id!)
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
        await updateNeed(formData as TrainingNeed)
        ElMessage.success('更新成功')
      } else {
        const { id, createTime, updateTime, isDeleted, ...createData } = formData
        await createNeed(createData as TrainingNeed)
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
    delete formData[key as keyof TrainingNeed]
  })
  formRef.value?.resetFields()
}

// 获取状态文本
const getStatusText = (status: number) => {
  const map: Record<number, string> = {
    0: '待审核',
    1: '已纳入计划',
    2: '已拒绝'
  }
  return map[status] || '未知'
}

// 获取状态类型
const getStatusType = (status: number) => {
  const map: Record<number, string> = {
    0: 'info',
    1: 'success',
    2: 'warning'
  }
  return map[status] || 'info'
}

// 获取优先级文本
const getPriorityText = (priority: number) => {
  const map: Record<number, string> = {
    1: '低',
    2: '中',
    3: '高'
  }
  return map[priority] || '未知'
}

// 获取优先级类型
const getPriorityType = (priority: number) => {
  const map: Record<number, string> = {
    1: 'info',
    2: 'warning',
    3: 'danger'
  }
  return map[priority] || 'info'
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

// 加载部门列表
const loadDeptList = async () => {
  try {
    const res = await getDeptTree()
    // 扁平化部门树
    const flattenDepts = (depts: any[]): any[] => {
      const result: any[] = []
      depts.forEach(dept => {
        result.push(dept)
        if (dept.children && dept.children.length > 0) {
          result.push(...flattenDepts(dept.children))
        }
      })
      return result
    }
    deptList.value = flattenDepts(res)
  } catch (error) {
    console.error('加载部门列表失败', error)
  }
}

onMounted(() => {
  handleQuery()
  loadEmployeeList()
  loadDeptList()
})
</script>

<style scoped>
.training-need-container {
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
