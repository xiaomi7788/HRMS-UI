<template>
  <div class="schedule-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">排班管理</span>
          <el-button type="primary" @click="handleGenerate">智能排班</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="部门">
          <el-select v-model="queryParams.deptId" placeholder="全部部门" clearable style="width: 200px">
            <el-option
              v-for="dept in deptList"
              :key="dept.id"
              :label="dept.deptName"
              :value="dept.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="月份">
          <el-date-picker
            v-model="queryParams.month"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 160px"
          />
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="queryParams.keyword" placeholder="工号/姓名" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="employeeNo" label="工号" width="120" />
        <el-table-column prop="employeeName" label="姓名" width="100" />
        <el-table-column prop="deptName" label="部门" width="150" />
        <el-table-column prop="shiftDate" label="排班日期" width="120" />
        <el-table-column label="班次类型" width="100">
          <template #default="{ row }">
            {{ getShiftTypeText(row.shiftType) }}
          </template>
        </el-table-column>
        <el-table-column prop="ruleName" label="考勤规则" width="150" />
        <el-table-column prop="workStart" label="上班时间" width="120" />
        <el-table-column prop="workEnd" label="下班时间" width="120" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 编辑排班对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑排班"
      width="500px"
      @close="handleEditDialogClose"
    >
      <el-form ref="editFormRef" :model="editForm" :rules="editFormRules" label-width="100px">
        <el-form-item label="员工">
          <el-input :value="currentShift?.employeeName" disabled />
        </el-form-item>
        <el-form-item label="排班日期" prop="shiftDate">
          <el-date-picker
            v-model="editForm.shiftDate"
            type="date"
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="班次类型" prop="shiftType">
          <el-select v-model="editForm.shiftType" placeholder="选择班次类型" style="width: 100%">
            <el-option label="正常班" :value="0" />
            <el-option label="早班" :value="1" />
            <el-option label="中班" :value="2" />
            <el-option label="晚班" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="考勤规则" prop="ruleId">
          <el-select v-model="editForm.ruleId" placeholder="选择考勤规则" style="width: 100%">
            <el-option
              v-for="rule in ruleList"
              :key="rule.id"
              :label="rule.ruleName"
              :value="rule.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveEdit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 智能排班对话框 -->
    <el-dialog
      v-model="generateDialogVisible"
      title="智能排班"
      width="500px"
      @close="handleGenerateDialogClose"
    >
      <el-form ref="generateFormRef" :model="generateForm" :rules="generateFormRules" label-width="120px">
        <el-form-item label="排班月份" prop="month">
          <el-date-picker
            v-model="generateForm.month"
            type="month"
            placeholder="选择月份"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="部门" prop="deptId">
          <el-select v-model="generateForm.deptId" placeholder="选择部门" clearable style="width: 100%">
            <el-option
              v-for="dept in deptList"
              :key="dept.id"
              :label="dept.deptName"
              :value="dept.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="班次类型" prop="shiftType">
          <el-select v-model="generateForm.shiftType" placeholder="选择班次类型" style="width: 100%">
            <el-option label="正常班" :value="0" />
            <el-option label="早班" :value="1" />
            <el-option label="中班" :value="2" />
            <el-option label="晚班" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="考勤规则" prop="ruleId">
          <el-select v-model="generateForm.ruleId" placeholder="选择考勤规则" style="width: 100%">
            <el-option
              v-for="rule in ruleList"
              :key="rule.id"
              :label="rule.ruleName"
              :value="rule.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="生成数量">
          <el-input-number v-model="generateForm.count" :min="1" :max="1000" style="width: 100%" />
        </el-form-item>
        <el-form-item label="排除周末">
          <el-switch v-model="generateForm.excludeWeekend" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="generateDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveGenerate">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getShiftPage,
  updateShift,
  deleteShift,
  generateShift,
  type ShiftVO,
  type ShiftPageParams,
  type GenerateParams,
  type AttendanceShift
} from '@/api/shift'
import { getDeptTree, type Department } from '@/api/dept'
import { getRuleList } from '@/api/attendance'

const loading = ref(false)
const tableData = ref<ShiftVO[]>([])
const total = ref(0)
const deptList = ref<Department[]>([])
const ruleList = ref<any[]>([])
const editDialogVisible = ref(false)
const generateDialogVisible = ref(false)
const editFormRef = ref<FormInstance>()
const generateFormRef = ref<FormInstance>()

const currentShift = ref<ShiftVO | null>(null)

const queryParams = reactive<ShiftPageParams>({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  deptId: undefined,
  month: undefined
})

const generateForm = reactive<GenerateParams & { count: number }>({
  month: '',
  deptId: undefined,
  shiftType: 0,
  ruleId: undefined as any,
  excludeWeekend: true,
  count: 10
})

const editForm = reactive<Partial<AttendanceShift>>({
  shiftDate: '',
  shiftType: 0,
  ruleId: undefined
})

const generateFormRules: FormRules = {
  month: [{ required: true, message: '请选择排班月份', trigger: 'change' }],
  ruleId: [{ required: true, message: '请选择考勤规则', trigger: 'change' }]
}

const editFormRules: FormRules = {
  shiftDate: [{ required: true, message: '请选择排班日期', trigger: 'change' }],
  shiftType: [{ required: true, message: '请选择班次类型', trigger: 'change' }],
  ruleId: [{ required: true, message: '请选择考勤规则', trigger: 'change' }]
}

const flattenDeptTree = (tree: Department[]): Department[] => {
  const result: Department[] = []
  const traverse = (items: Department[]) => {
    items.forEach(item => {
      result.push(item)
      if (item.children && item.children.length > 0) {
        traverse(item.children)
      }
    })
  }
  traverse(tree)
  return result
}

const loadDeptList = async () => {
  try {
    const data = await getDeptTree()
    deptList.value = flattenDeptTree(data)
  } catch (error) {
    console.error('加载部门列表失败:', error)
  }
}

const loadRuleList = async () => {
  try {
    const data = await getRuleList()
    ruleList.value = data
  } catch (error) {
    console.error('加载考勤规则列表失败:', error)
  }
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getShiftPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载排班列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.deptId = undefined
  queryParams.month = undefined
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadData()
}

const handleGenerate = () => {
  generateDialogVisible.value = true
}

const handleSaveGenerate = async () => {
  if (!generateFormRef.value) return
  await generateFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const result = await generateShift(generateForm)
        ElMessage.success(result || '智能排班成功')
        generateDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('智能排班失败:', error)
      }
    }
  })
}

const handleEdit = (row: ShiftVO) => {
  currentShift.value = row
  editForm.id = row.id
  editForm.employeeId = row.employeeId
  editForm.shiftDate = row.shiftDate
  editForm.shiftType = row.shiftType
  editForm.ruleId = row.ruleId
  editDialogVisible.value = true
}

const handleSaveEdit = async () => {
  if (!editFormRef.value) return
  await editFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await updateShift(editForm)
        ElMessage.success('更新成功')
        editDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('更新排班失败:', error)
      }
    }
  })
}

const handleDelete = (row: ShiftVO) => {
  ElMessageBox.confirm('确认删除该排班记录吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteShift(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除排班失败:', error)
    }
  })
}

const handleGenerateDialogClose = () => {
  generateFormRef.value?.resetFields()
}

const handleEditDialogClose = () => {
  editFormRef.value?.resetFields()
  currentShift.value = null
}

const getShiftTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    0: '正常班',
    1: '早班',
    2: '中班',
    3: '晚班'
  }
  return typeMap[type] || '-'
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadDeptList()
  loadRuleList()
  loadData()
})
</script>

<style scoped>
.schedule-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header .title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.search-form {
  margin-bottom: 20px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
