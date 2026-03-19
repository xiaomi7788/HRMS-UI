<template>
  <div class="welfare-management">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>福利管理</span>
        </div>
      </template>

      <el-tabs v-model="activeTab" type="border-card">
        <!-- 福利项目标签页 -->
        <el-tab-pane label="福利项目" name="items">
          <div class="tab-content">
            <div class="toolbar">
              <el-button type="primary" @click="handleAddItem">
                <el-icon><Plus /></el-icon>
                新增福利项目
              </el-button>
              <div class="search-form">
                <el-input
                  v-model="itemQuery.keyword"
                  placeholder="搜索福利名称"
                  clearable
                  style="width: 200px"
                  @keyup.enter="loadItems"
                />
                <el-select
                  v-model="itemQuery.status"
                  placeholder="状态"
                  clearable
                  style="width: 120px"
                >
                  <el-option
                    v-for="opt in WELFARE_STATUS_OPTIONS"
                    :key="opt.value"
                    :label="opt.label"
                    :value="opt.value"
                  />
                </el-select>
                <el-button type="primary" @click="loadItems">查询</el-button>
                <el-button @click="resetItemQuery">重置</el-button>
              </div>
            </div>

            <el-table :data="itemList" v-loading="itemLoading" stripe>
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="itemCode" label="福利编码" width="150" />
              <el-table-column prop="name" label="福利名称" min-width="150" />
              <el-table-column prop="welfareType" label="福利类型" width="120">
                <template #default="{ row }">
                  {{ getWelfareTypeName(row.welfareType) }}
                </template>
              </el-table-column>
              <el-table-column prop="amount" label="金额" width="120">
                <template #default="{ row }">
                  {{ row.amount ? `¥${row.amount}` : '-' }}
                </template>
              </el-table-column>
              <el-table-column prop="cycle" label="发放周期" width="120">
                <template #default="{ row }">
                  {{ row.cycle ? getCycleTypeName(row.cycle) : '-' }}
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 1 ? 'success' : 'info'">
                    {{ row.status === 1 ? '启用' : '停用' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="description" label="描述" min-width="150" show-overflow-tooltip />
              <el-table-column prop="createTime" label="创建时间" width="180">
                <template #default="{ row }">
                  {{ formatDateTime(row.createTime) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="180" fixed="right">
                <template #default="{ row }">
                  <el-button type="primary" link @click="handleEditItem(row)">编辑</el-button>
                  <el-button type="danger" link @click="handleDeleteItem(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>

            <el-pagination
              v-model:current-page="itemQuery.pageNum"
              v-model:page-size="itemQuery.pageSize"
              :total="itemTotal"
              :page-sizes="[10, 20, 50, 100]"
              @change="loadItems"
              layout="total, sizes, prev, pager, next, jumper"
              style="margin-top: 20px; justify-content: flex-end"
            />
          </div>
        </el-tab-pane>

        <!-- 发放记录标签页 -->
        <el-tab-pane label="发放记录" name="records">
          <div class="tab-content">
            <div class="toolbar">
              <el-button type="primary" @click="handleAddRecord">
                <el-icon><Plus /></el-icon>
                新增发放记录
              </el-button>
              <div class="search-form">
                <el-select
                  v-model="recordQuery.employeeId"
                  placeholder="员工姓名"
                  clearable
                  filterable
                  style="width: 150px"
                >
                  <el-option
                    v-for="emp in employeeOptions"
                    :key="emp.id"
                    :label="emp.empName"
                    :value="emp.id"
                  />
                </el-select>
                <el-select
                  v-model="recordQuery.itemId"
                  placeholder="福利项目"
                  clearable
                  style="width: 180px"
                >
                  <el-option
                    v-for="item in welfareItems"
                    :key="item.id"
                    :label="item.name"
                    :value="item.id"
                  />
                </el-select>
                <el-date-picker
                  v-model="recordQuery.grantMonth"
                  type="month"
                  placeholder="发放月份"
                  format="YYYY-MM"
                  value-format="YYYY-MM"
                  style="width: 160px"
                />
                <el-select
                  v-model="recordQuery.status"
                  placeholder="状态"
                  clearable
                  style="width: 120px"
                >
                  <el-option
                    v-for="opt in RECORD_STATUS_OPTIONS"
                    :key="opt.value"
                    :label="opt.label"
                    :value="opt.value"
                  />
                </el-select>
                <el-button type="primary" @click="loadRecords">查询</el-button>
                <el-button @click="resetRecordQuery">重置</el-button>
              </div>
            </div>

            <el-table :data="recordList" v-loading="recordLoading" stripe>
              <el-table-column prop="id" label="ID" width="80" />
              <el-table-column prop="itemName" label="福利项目" min-width="150" />
              <el-table-column prop="employeeName" label="员工姓名" width="120" />
              <el-table-column prop="grantMonth" label="发放月份" width="120" />
              <el-table-column prop="amount" label="金额" width="120">
                <template #default="{ row }">
                  ¥{{ row.amount }}
                </template>
              </el-table-column>
              <el-table-column prop="grantDate" label="发放日期" width="120">
                <template #default="{ row }">
                  {{ formatDate(row.grantDate) }}
                </template>
              </el-table-column>
              <el-table-column prop="status" label="状态" width="100">
                <template #default="{ row }">
                  <el-tag :type="row.status === 1 ? 'success' : 'warning'">
                    {{ row.status === 1 ? '已发放' : '待发放' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
              <el-table-column prop="createTime" label="创建时间" width="180">
                <template #default="{ row }">
                  {{ formatDateTime(row.createTime) }}
                </template>
              </el-table-column>
              <el-table-column label="操作" width="180" fixed="right">
                <template #default="{ row }">
                  <el-button type="primary" link @click="handleEditRecord(row)">编辑</el-button>
                  <el-button type="danger" link @click="handleDeleteRecord(row)">删除</el-button>
                </template>
              </el-table-column>
            </el-table>

            <el-pagination
              v-model:current-page="recordQuery.pageNum"
              v-model:page-size="recordQuery.pageSize"
              :total="recordTotal"
              :page-sizes="[10, 20, 50, 100]"
              @change="loadRecords"
              layout="total, sizes, prev, pager, next, jumper"
              style="margin-top: 20px; justify-content: flex-end"
            />
          </div>
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 福利项目对话框 -->
    <el-dialog
      v-model="itemDialogVisible"
      :title="itemDialogTitle"
      width="600px"
      @close="handleItemDialogClose"
    >
      <el-form :model="itemForm" :rules="itemFormRules" ref="itemFormRef" label-width="120px">
        <el-form-item label="福利编码" prop="itemCode">
          <el-input v-model="itemForm.itemCode" placeholder="请输入福利编码" />
        </el-form-item>
        <el-form-item label="福利名称" prop="name">
          <el-input v-model="itemForm.name" placeholder="请输入福利名称" />
        </el-form-item>
        <el-form-item label="福利类型" prop="welfareType">
          <el-select v-model="itemForm.welfareType" placeholder="请选择福利类型" style="width: 100%">
            <el-option
              v-for="opt in WELFARE_TYPE_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number v-model="itemForm.amount" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="发放周期" prop="cycle">
          <el-select v-model="itemForm.cycle" placeholder="请选择发放周期" style="width: 100%">
            <el-option
              v-for="opt in CYCLE_TYPE_OPTIONS"
              :key="opt.value"
              :label="opt.label"
              :value="opt.value"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-switch
            v-model="itemForm.status"
            :active-value="1"
            :inactive-value="0"
            active-text="启用"
            inactive-text="停用"
          />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="itemForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleItemSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 发放记录对话框 -->
    <el-dialog
      v-model="recordDialogVisible"
      :title="recordDialogTitle"
      width="700px"
      @close="handleRecordDialogClose"
    >
      <el-form :model="recordForm" :rules="recordFormRules" ref="recordFormRef" label-width="120px">
        <el-form-item label="福利项目" prop="itemId">
          <el-select v-model="recordForm.itemId" placeholder="请选择福利项目" style="width: 100%">
            <el-option
              v-for="item in welfareItems"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="发放月份" prop="grantMonth">
          <el-date-picker
            v-model="recordForm.grantMonth"
            type="month"
            placeholder="请选择发放月份"
            format="YYYY-MM"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="发放日期" prop="grantDate">
          <el-date-picker
            v-model="recordForm.grantDate"
            type="date"
            placeholder="请选择发放日期"
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="发放金额" prop="amount">
          <el-input-number v-model="recordForm.amount" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="选择员工" prop="selectedEmployees">
          <el-select
            v-model="recordForm.selectedEmployees"
            placeholder="请选择员工（可多选）"
            multiple
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="emp in employeeOptions"
              :key="emp.id"
              :label="emp.empName"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-switch
            v-model="recordForm.status"
            :active-value="1"
            :inactive-value="0"
            active-text="已发放"
            inactive-text="待发放"
          />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="recordForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="recordDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleRecordSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import {
  getWelfareItemPage,
  getWelfareItemList,
  createWelfareItem,
  updateWelfareItem,
  deleteWelfareItem,
  getWelfareRecordPage,
  createWelfareRecord,
  updateWelfareRecord,
  deleteWelfareRecord,
  type WelfareItem,
  type WelfareItemPageQuery,
  type WelfareRecord,
  type WelfareRecordPageQuery,
  WelfareType,
  CycleType,
  WelfareStatus,
  RecordStatus,
  WELFARE_TYPE_OPTIONS,
  CYCLE_TYPE_OPTIONS,
  WELFARE_STATUS_OPTIONS,
  RECORD_STATUS_OPTIONS
} from '@/api/welfare'
import { getEmployeePage } from '@/api/employee'
import type { Employee } from '@/api/employee'

const activeTab = ref('items')

// 福利项目相关
const itemLoading = ref(false)
const itemList = ref<WelfareItem[]>([])
const itemTotal = ref(0)
const itemDialogVisible = ref(false)
const itemDialogTitle = ref('新增福利项目')
const itemFormRef = ref<FormInstance>()
const itemQuery = reactive<WelfareItemPageQuery>({
  pageNum: 1,
  pageSize: 10
})

const itemForm = reactive<WelfareItem>({
  itemCode: '',
  name: '',
  welfareType: WelfareType.SUBSIDY,
  amount: 0,
  cycle: CycleType.IRREGULAR,
  status: 1,
  description: ''
})

const itemFormRules = {
  itemCode: [{ required: true, message: '请输入福利编码', trigger: 'blur' }],
  name: [{ required: true, message: '请输入福利名称', trigger: 'blur' }],
  welfareType: [{ required: true, message: '请选择福利类型', trigger: 'change' }],
  amount: [{ required: true, message: '请输入金额', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

// 发放记录相关
const recordLoading = ref(false)
const recordList = ref<WelfareRecord[]>([])
const recordTotal = ref(0)
const recordDialogVisible = ref(false)
const recordDialogTitle = ref('新增发放记录')
const recordFormRef = ref<FormInstance>()
const welfareItems = ref<WelfareItem[]>([])
const employeeOptions = ref<Employee[]>([])
const employeeCache = ref<Map<number, Employee>>(new Map())
const itemCache = ref<Map<number, WelfareItem>>(new Map())
const recordQuery = reactive<WelfareRecordPageQuery & { employeeId?: number }>({
  pageNum: 1,
  pageSize: 10
})

const recordForm = reactive<WelfareRecord & { selectedEmployees?: number[] }>({
  itemId: 0,
  employeeId: 0,
  grantMonth: '',
  amount: 0,
  grantDate: '',
  status: 1,
  remark: '',
  selectedEmployees: []
})

const recordFormRules = {
  itemId: [{ required: true, message: '请选择福利项目', trigger: 'change' }],
  grantMonth: [{ required: true, message: '请选择发放月份', trigger: 'change' }],
  grantDate: [{ required: true, message: '请选择发放日期', trigger: 'change' }],
  amount: [{ required: true, message: '请输入发放金额', trigger: 'blur' }],
  selectedEmployees: [{ required: true, message: '请选择员工', trigger: 'change' }]
}

async function loadItems() {
  itemLoading.value = true
  try {
    const result = await getWelfareItemPage(itemQuery)
    itemList.value = result.records || []
    itemTotal.value = Number(result.total || 0)
  } catch (error) {
    ElMessage.error('获取福利项目列表失败')
  } finally {
    itemLoading.value = false
  }
}

function resetItemQuery() {
  itemQuery.pageNum = 1
  itemQuery.keyword = undefined
  itemQuery.status = undefined
  loadItems()
}

function handleAddItem() {
  itemDialogTitle.value = '新增福利项目'
  Object.assign(itemForm, {
    itemCode: '',
    name: '',
    welfareType: WelfareType.SUBSIDY,
    amount: 0,
    cycle: CycleType.IRREGULAR,
    status: 1,
    description: ''
  })
  itemDialogVisible.value = true
}

function handleEditItem(row: WelfareItem) {
  itemDialogTitle.value = '编辑福利项目'
  Object.assign(itemForm, row)
  itemDialogVisible.value = true
}

function handleItemDialogClose() {
  itemFormRef.value?.resetFields()
}

async function handleItemSubmit() {
  if (!itemFormRef.value) return
  await itemFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (itemForm.id) {
          await updateWelfareItem(itemForm)
          ElMessage.success('更新成功')
        } else {
          await createWelfareItem(itemForm)
          ElMessage.success('新增成功')
        }
        itemDialogVisible.value = false
        loadItems()
      } catch (error) {
        ElMessage.error(itemForm.id ? '更新失败' : '新增失败')
      }
    }
  })
}

async function handleDeleteItem(row: WelfareItem) {
  try {
    await ElMessageBox.confirm('确认删除此福利项目吗?', '提示', {
      type: 'warning'
    })
    await deleteWelfareItem(row.id!)
    ElMessage.success('删除成功')
    loadItems()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

async function loadRecords() {
  recordLoading.value = true
  try {
    const params: any = {
      pageNum: recordQuery.pageNum,
      pageSize: recordQuery.pageSize
    }
    if (recordQuery.employeeId) {
      params.employeeId = Number(recordQuery.employeeId)
    }
    if (recordQuery.itemId) {
      params.itemId = recordQuery.itemId
    }
    if (recordQuery.grantMonth) {
      params.grantMonth = recordQuery.grantMonth
    }
    if (recordQuery.status !== undefined) {
      params.status = recordQuery.status
    }
    const result = await getWelfareRecordPage(params)
    recordList.value = result.records || []
    recordTotal.value = Number(result.total || 0)
  } catch (error) {
    ElMessage.error('获取发放记录列表失败')
  } finally {
    recordLoading.value = false
  }
}

function resetRecordQuery() {
  recordQuery.pageNum = 1
  recordQuery.employeeId = undefined
  recordQuery.itemId = undefined
  recordQuery.grantMonth = undefined
  recordQuery.status = undefined
  loadRecords()
}

async function handleAddRecord() {
  recordDialogTitle.value = '新增发放记录'
  await loadWelfareItems()
  await loadEmployeeOptions()
  const now = new Date()
  Object.assign(recordForm, {
    itemId: 0,
    employeeId: 0,
    grantMonth: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`,
    amount: 0,
    grantDate: '',
    status: 1,
    remark: '',
    selectedEmployees: []
  })
  recordDialogVisible.value = true
}

async function handleEditRecord(row: WelfareRecord) {
  recordDialogTitle.value = '编辑发放记录'
  await loadWelfareItems()
  await loadEmployeeOptions()
  Object.assign(recordForm, row)
  recordForm.selectedEmployees = [row.employeeId]
  recordDialogVisible.value = true
}

function handleRecordDialogClose() {
  recordFormRef.value?.resetFields()
}

async function handleRecordSubmit() {
  if (!recordFormRef.value) return
  await recordFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (recordForm.id) {
          const submitData = { ...recordForm }
          await updateWelfareRecord(submitData as WelfareRecord)
          ElMessage.success('更新成功')
        } else {
          if (recordForm.selectedEmployees && recordForm.selectedEmployees.length > 0) {
            await createWelfareRecord({
              itemId: recordForm.itemId,
              employeeIds: recordForm.selectedEmployees,
              amount: recordForm.amount,
              grantDate: recordForm.grantDate,
              grantMonth: recordForm.grantMonth,
              remark: recordForm.remark
            })
            ElMessage.success('新增成功')
          } else {
            ElMessage.error('请选择员工')
            return
          }
        }
        recordDialogVisible.value = false
        loadRecords()
      } catch (error) {
        ElMessage.error(recordForm.id ? '更新失败' : '新增失败')
      }
    }
  })
}

async function handleDeleteRecord(row: WelfareRecord) {
  try {
    await ElMessageBox.confirm('确认删除此发放记录吗?', '提示', {
      type: 'warning'
    })
    await deleteWelfareRecord(row.id!)
    ElMessage.success('删除成功')
    loadRecords()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

async function loadWelfareItems() {
  try {
    welfareItems.value = await getWelfareItemList()
  } catch (error) {
    ElMessage.error('加载福利项目失败')
  }
}

async function loadEmployeeOptions() {
  try {
    const result = await getEmployeePage({
      pageNum: 1,
      pageSize: 1000
    })
    employeeOptions.value = result.records || []
    // 更新员工缓存
    employeeCache.value.clear()
    employeeOptions.value.forEach(emp => {
      if (emp.id) {
        employeeCache.value.set(emp.id, emp)
      }
    })
  } catch (error) {
    ElMessage.error('加载员工列表失败')
  }
}

function formatDateTime(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

function formatDate(date: string) {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN')
}

function getWelfareTypeName(type: string) {
  const option = WELFARE_TYPE_OPTIONS.find(item => item.value === type)
  return option?.label || type
}

function getCycleTypeName(cycle: string) {
  const option = CYCLE_TYPE_OPTIONS.find(item => item.value === cycle)
  return option?.label || cycle
}

onMounted(async () => {
  await loadWelfareItems()
  await loadEmployeeOptions()
  loadItems()
  loadRecords()
})
</script>

<style scoped>
.welfare-management {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tab-content {
  padding: 10px 0;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.search-form {
  display: flex;
  gap: 10px;
}
</style>
