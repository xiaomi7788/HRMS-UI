<template>
  <div class="welfare-management-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>福利管理</h2>
      <div class="header-actions">
        <el-button type="primary" @click="showItemDialog('add')">
          <el-icon><Plus /></el-icon> 新增福利项目
        </el-button>
        <el-button type="success" @click="showRecordDialog('add')">
          <el-icon><Plus /></el-icon> 新增发放记录
        </el-button>
      </div>
    </div>

    <!-- 标签页 -->
    <el-tabs v-model="activeTab" type="card" class="welfare-tabs">
      <!-- 福利项目管理 -->
      <el-tab-pane label="福利项目" name="items">
        <!-- 查询条件 -->
        <el-card class="query-card">
          <el-form :model="itemQueryParams" inline>
            <el-form-item label="关键字">
              <el-input
                v-model="itemQueryParams.keyword"
                placeholder="请输入福利项目名称/编码"
                clearable
                style="width: 200px"
              />
            </el-form-item>
            <el-form-item label="状态">
              <el-select
                v-model="itemQueryParams.status"
                placeholder="请选择状态"
                clearable
                style="width: 120px"
              >
                <el-option label="启用" :value="1" />
                <el-option label="停用" :value="0" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleItemQuery">
                <el-icon><Search /></el-icon> 查询
              </el-button>
              <el-button @click="resetItemQuery">
                <el-icon><Refresh /></el-icon> 重置
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 福利项目表格 -->
        <el-card class="table-card">
          <el-table
            :data="itemTableData"
            v-loading="itemLoading"
            border
            stripe
            style="width: 100%"
          >
            <el-table-column prop="itemCode" label="福利编码" width="120" />
            <el-table-column prop="name" label="福利名称" width="150" />
            <el-table-column prop="welfareType" label="福利类型" width="100">
              <template #default="{ row }">
                <el-tag :type="getWelfareTypeTag(row.welfareType)">
                  {{ getWelfareTypeLabel(row.welfareType) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="amount" label="金额" width="100">
              <template #default="{ row }">
                {{ formatCurrency(row.amount) }}
              </template>
            </el-table-column>
            <el-table-column prop="cycle" label="发放周期" width="100">
              <template #default="{ row }">
                {{ getCycleLabel(row.cycle) }}
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'info'">
                  {{ row.status === 1 ? '启用' : '停用' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
            <el-table-column prop="createTime" label="创建时间" width="160" />
            <el-table-column label="操作" width="180" fixed="right">
              <template #default="{ row }">
                <el-button
                  size="small"
                  type="primary"
                  @click="showItemDialog('edit', row)"
                >
                  编辑
                </el-button>
                <el-button
                  size="small"
                  type="danger"
                  @click="handleDeleteItem(row)"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <!-- 分页 -->
          <el-pagination
            v-model:current-page="itemQueryParams.pageNum"
            v-model:page-size="itemQueryParams.pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="itemTotal"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleItemSizeChange"
            @current-change="handleItemCurrentChange"
            style="margin-top: 20px"
          />
        </el-card>
      </el-tab-pane>

      <!-- 福利发放记录管理 -->
      <el-tab-pane label="发放记录" name="records">
        <!-- 查询条件 -->
        <el-card class="query-card">
          <el-form :model="recordQueryParams" inline>
            <el-form-item label="员工">
              <EmployeeSelect
                v-model="recordQueryParams.employeeId"
                placeholder="请选择员工"
                clearable
                style="width: 200px"
                @clear="handleRecordQuery"
              />
            </el-form-item>
            <el-form-item label="福利项目">
              <el-select
                v-model="recordQueryParams.itemId"
                placeholder="请选择福利项目"
                clearable
                filterable
                style="width: 200px"
              >
                <el-option
                  v-for="item in enabledItems"
                  :key="item.id"
                  :label="item.name"
                  :value="item.id"
                />
              </el-select>
            </el-form-item>
            <el-form-item label="发放月份">
              <el-date-picker
                v-model="recordQueryParams.grantMonth"
                type="month"
                placeholder="选择月份"
                value-format="YYYY-MM"
                clearable
                style="width: 150px"
              />
            </el-form-item>
            <el-form-item label="状态">
              <el-select
                v-model="recordQueryParams.status"
                placeholder="请选择状态"
                clearable
                style="width: 120px"
              >
                <el-option label="待发放" :value="0" />
                <el-option label="已发放" :value="1" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleRecordQuery">
                <el-icon><Search /></el-icon> 查询
              </el-button>
              <el-button @click="resetRecordQuery">
                <el-icon><Refresh /></el-icon> 重置
              </el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 发放记录表格 -->
        <el-card class="table-card">
          <el-table
            :data="recordTableData"
            v-loading="recordLoading"
            border
            stripe
            style="width: 100%"
          >
            <el-table-column prop="employeeName" label="员工" width="120" />
            <el-table-column prop="itemName" label="福利项目" width="150" />
            <el-table-column prop="grantMonth" label="发放月份" width="100" />
            <el-table-column prop="grantDate" label="发放日期" width="120" />
            <el-table-column prop="amount" label="金额" width="100">
              <template #default="{ row }">
                {{ formatCurrency(row.amount) }}
              </template>
            </el-table-column>
            <el-table-column prop="status" label="状态" width="80">
              <template #default="{ row }">
                <el-tag :type="row.status === 1 ? 'success' : 'warning'">
                  {{ row.status === 1 ? '已发放' : '待发放' }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
            <el-table-column prop="createTime" label="创建时间" width="160" />
            <el-table-column label="操作" width="200" fixed="right">
              <template #default="{ row }">
                <el-button
                  v-if="row.status === 0"
                  size="small"
                  type="success"
                  @click="handleMarkAsGranted(row)"
                >
                  标记已发放
                </el-button>
                <el-button
                  size="small"
                  type="primary"
                  @click="showRecordDialog('edit', row)"
                >
                  编辑
                </el-button>
                <el-button
                  size="small"
                  type="danger"
                  @click="handleDeleteRecord(row)"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <!-- 分页 -->
          <el-pagination
            v-model:current-page="recordQueryParams.pageNum"
            v-model:page-size="recordQueryParams.pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="recordTotal"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleRecordSizeChange"
            @current-change="handleRecordCurrentChange"
            style="margin-top: 20px"
          />
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <!-- 福利项目对话框 -->
    <el-dialog
      v-model="itemDialogVisible"
      :title="itemDialogTitle"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="itemFormRef"
        :model="itemFormData"
        :rules="itemFormRules"
        label-width="120px"
      >
        <el-form-item label="福利编码" prop="itemCode">
          <el-input
            v-model="itemFormData.itemCode"
            placeholder="请输入福利编码"
            maxlength="32"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="福利名称" prop="name">
          <el-input
            v-model="itemFormData.name"
            placeholder="请输入福利名称"
            maxlength="64"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="福利类型" prop="welfareType">
          <el-select
            v-model="itemFormData.welfareType"
            placeholder="请选择福利类型"
            style="width: 100%"
          >
            <el-option label="补贴" value="SUBSIDY" />
            <el-option label="实物" value="GOODS" />
            <el-option label="保险" value="INSURANCE" />
            <el-option label="其他" value="OTHER" />
          </el-select>
        </el-form-item>
        <el-form-item label="金额" prop="amount">
          <el-input-number
            v-model="itemFormData.amount"
            placeholder="请输入金额"
            :min="0"
            :precision="2"
            :step="100"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="发放周期" prop="cycle">
          <el-select
            v-model="itemFormData.cycle"
            placeholder="请选择发放周期"
            style="width: 100%"
          >
            <el-option label="每月" value="MONTHLY" />
            <el-option label="每季度" value="QUARTERLY" />
            <el-option label="每年" value="YEARLY" />
            <el-option label="不定期" value="IRREGULAR" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="itemFormData.status">
            <el-radio :label="1">启用</el-radio>
            <el-radio :label="0">停用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="itemFormData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入福利描述"
            maxlength="512"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="itemDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleItemSubmit">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 发放记录对话框 -->
    <el-dialog
      v-model="recordDialogVisible"
      :title="recordDialogTitle"
      width="700px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="recordFormRef"
        :model="recordFormData"
        :rules="recordFormRules"
        label-width="120px"
      >
        <el-form-item label="福利项目" prop="itemId">
          <el-select
            v-model="recordFormData.itemId"
            placeholder="请选择福利项目"
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="item in enabledItems"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="发放方式" prop="grantType">
          <el-radio-group v-model="recordFormData.grantType" @change="handleGrantTypeChange">
            <el-radio label="single">单个员工</el-radio>
            <el-radio label="batch">批量员工</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item v-if="recordFormData.grantType === 'single'" label="员工" prop="employeeId">
          <EmployeeSelect
            v-model="recordFormData.employeeId"
            placeholder="请选择员工"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item v-if="recordFormData.grantType === 'batch'" label="员工" prop="employeeIds">
          <EmployeeMultiSelect
            v-model="recordFormData.employeeIds"
            placeholder="请选择员工（可多选）"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="发放月份" prop="grantMonth">
          <el-date-picker
            v-model="recordFormData.grantMonth"
            type="month"
            placeholder="选择发放月份"
            value-format="YYYY-MM"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="发放日期" prop="grantDate">
          <el-date-picker
            v-model="recordFormData.grantDate"
            type="date"
            placeholder="选择发放日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="发放金额" prop="amount">
          <el-input-number
            v-model="recordFormData.amount"
            placeholder="请输入发放金额"
            :min="0"
            :precision="2"
            :step="100"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="状态" v-if="recordDialogType === 'edit'">
          <el-radio-group v-model="recordFormData.status">
            <el-radio :label="0">待发放</el-radio>
            <el-radio :label="1">已发放</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="recordFormData.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注"
            maxlength="512"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="recordDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleRecordSubmit">
            确定
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, defineAsyncComponent, nextTick } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Search, Refresh } from '@element-plus/icons-vue'
// @ts-ignore
import {
  getWelfareItemPage,
  getWelfareItemList,
  createWelfareItem,
  updateWelfareItem,
  deleteWelfareItem,
  getWelfareRecordPage,
  createWelfareRecord,
  updateWelfareRecord,
  deleteWelfareRecord
} from '@/api/welfare'
import type { 
  WelfareItem,
  WelfareRecord,
  WelfareItemPageQuery,
  WelfareRecordPageQuery 
} from '@/api/welfare'

// 使用异步导入解决组件导入问题
const EmployeeSelect = defineAsyncComponent(() => import('@/admin/pages/performance/components/EmployeeSelect.vue'))
const EmployeeMultiSelect = defineAsyncComponent(() => import('./components/EmployeeMultiSelect.vue'))

// 标签页
const activeTab = ref('items')

// 福利项目管理相关
const itemTableData = ref<WelfareItem[]>([])
const itemTotal = ref(0)
const itemLoading = ref(false)
const itemQueryParams = reactive<WelfareItemPageQuery>({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  status: undefined
})

// 福利发放记录管理相关
const recordTableData = ref<WelfareRecord[]>([])
const recordTotal = ref(0)
const recordLoading = ref(false)
const recordQueryParams = reactive<WelfareRecordPageQuery>({
  pageNum: 1,
  pageSize: 20,
  employeeId: undefined,
  itemId: undefined,
  grantMonth: '',
  status: undefined
})

// 启用的福利项目列表
const enabledItems = ref<WelfareItem[]>([])

// 对话框相关
const itemDialogVisible = ref(false)
const itemDialogType = ref<'add' | 'edit'>('add')
const itemDialogTitle = ref('')
const itemFormRef = ref<FormInstance>()
const itemFormData = reactive<WelfareItem>({
  itemCode: '',
  name: '',
  welfareType: 'SUBSIDY',
  amount: 0,
  cycle: 'MONTHLY',
  status: 1,
  description: ''
})

const recordDialogVisible = ref(false)
const recordDialogType = ref<'add' | 'edit'>('add')
const recordDialogTitle = ref('')
const recordFormRef = ref<FormInstance>()
const recordFormData = reactive<any>({
  itemId: undefined,
  grantType: 'single',
  employeeId: undefined,
  employeeIds: [],
  grantMonth: '',
  grantDate: '',
  amount: 0,
  status: 0,
  remark: ''
})

// 表单验证规则
const itemFormRules: FormRules = {
  itemCode: [
    { required: true, message: '请输入福利编码', trigger: 'blur' },
    { max: 32, message: '福利编码不能超过32个字符', trigger: 'blur' }
  ],
  name: [
    { required: true, message: '请输入福利名称', trigger: 'blur' },
    { max: 64, message: '福利名称不能超过64个字符', trigger: 'blur' }
  ],
  welfareType: [
    { required: true, message: '请选择福利类型', trigger: 'change' }
  ],
  amount: [
    { required: true, message: '请输入金额', trigger: 'blur' },
    { type: 'number', min: 0, message: '金额不能小于0', trigger: 'blur' }
  ],
  cycle: [
    { required: true, message: '请选择发放周期', trigger: 'change' }
  ]
}

const recordFormRules: FormRules = {
  itemId: [
    { required: true, message: '请选择福利项目', trigger: 'change' }
  ],
  employeeId: [
    { 
      required: true,
      validator: (rule, value, callback) => {
        if (recordFormData.grantType === 'single' && !value) {
          callback(new Error('请选择员工'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ],
  employeeIds: [
    { 
      required: true,
      validator: (rule, value, callback) => {
        if (recordFormData.grantType === 'batch' && (!value || value.length === 0)) {
          callback(new Error('请选择员工'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ],
  grantMonth: [
    { required: true, message: '请选择发放月份', trigger: 'change' }
  ],
  grantDate: [
    { required: true, message: '请选择发放日期', trigger: 'change' }
  ],
  amount: [
    { required: true, message: '请输入发放金额', trigger: 'blur' },
    { type: 'number', min: 0, message: '金额不能小于0', trigger: 'blur' }
  ]
}

// 初始化
onMounted(() => {
  loadItemList()
  loadRecordList()
  loadEnabledItems()
})

// 加载启用的福利项目
const loadEnabledItems = async () => {
  try {
    const res = await getWelfareItemList()
    enabledItems.value = res
  } catch (error) {
    console.error('加载启用的福利项目失败:', error)
  }
}

// 加载福利项目列表
const loadItemList = async () => {
  itemLoading.value = true
  try {
    const res = await getWelfareItemPage(itemQueryParams)
    itemTableData.value = res.records
    itemTotal.value = res.total
  } catch (error) {
    console.error('加载福利项目列表失败:', error)
  } finally {
    itemLoading.value = false
  }
}

// 加载发放记录列表
const loadRecordList = async () => {
  recordLoading.value = true
  console.log('11111');
  
  try {
    const res = await getWelfareRecordPage(recordQueryParams)
    recordTableData.value = res.records
    console.log('发放记录---->', res);
    console.log('222222');
    recordTotal.value = res.total
  } catch (error) {
    console.error('加载发放记录列表失败:', error)
  } finally {
    recordLoading.value = false
  }
}

// 福利项目查询
const handleItemQuery = () => {
  itemQueryParams.pageNum = 1
  loadItemList()
}

// 福利项目重置
const resetItemQuery = () => {
  itemQueryParams.keyword = ''
  itemQueryParams.status = undefined
  handleItemQuery()
}

// 发放记录查询
const handleRecordQuery = () => {
  recordQueryParams.pageNum = 1
  loadRecordList()
}

// 发放记录重置
const resetRecordQuery = () => {
  recordQueryParams.employeeId = undefined
  recordQueryParams.itemId = undefined
  recordQueryParams.grantMonth = ''
  recordQueryParams.status = undefined
  handleRecordQuery()
}

// 分页处理
const handleItemSizeChange = (size: number) => {
  itemQueryParams.pageSize = size
  itemQueryParams.pageNum = 1
  loadItemList()
}

const handleItemCurrentChange = (page: number) => {
  itemQueryParams.pageNum = page
  loadItemList()
}

const handleRecordSizeChange = (size: number) => {
  recordQueryParams.pageSize = size
  recordQueryParams.pageNum = 1
  loadRecordList()
}

const handleRecordCurrentChange = (page: number) => {
  recordQueryParams.pageNum = page
  loadRecordList()
}

// 显示福利项目对话框
const showItemDialog = (type: 'add' | 'edit', row?: WelfareItem) => {
  itemDialogType.value = type
  itemDialogTitle.value = type === 'add' ? '新增福利项目' : '编辑福利项目'
  
  if (type === 'edit' && row) {
    Object.assign(itemFormData, row)
  } else {
    resetItemForm()
  }
  
  itemDialogVisible.value = true
  
  // 清除表单验证
  nextTick(() => {
    itemFormRef.value?.clearValidate()
  })
}

// 显示发放记录对话框
const showRecordDialog = (type: 'add' | 'edit', row?: WelfareRecord) => {
  recordDialogType.value = type
  recordDialogTitle.value = type === 'add' ? '新增发放记录' : '编辑发放记录'
  
  if (type === 'edit' && row) {
    Object.assign(recordFormData, {
      ...row,
      grantType: 'single',
      employeeIds: []
    })
  } else {
    resetRecordForm()
  }
  
  recordDialogVisible.value = true
  
  // 清除表单验证
  nextTick(() => {
    recordFormRef.value?.clearValidate()
  })
}

// 重置福利项目表单
const resetItemForm = () => {
  Object.assign(itemFormData, {
    id: undefined,
    itemCode: '',
    name: '',
    welfareType: 'SUBSIDY',
    amount: 0,
    cycle: 'MONTHLY',
    status: 1,
    description: ''
  })
}

// 重置发放记录表单
const resetRecordForm = () => {
  Object.assign(recordFormData, {
    id: undefined,
    itemId: undefined,
    grantType: 'single',
    employeeId: undefined,
    employeeIds: [],
    grantMonth: '',
    grantDate: '',
    amount: 0,
    status: 0,
    remark: ''
  })
}

// 处理发放方式变化
const handleGrantTypeChange = () => {
  // 清除相关字段的验证
  if (recordFormRef.value) {
    recordFormRef.value.clearValidate(['employeeId', 'employeeIds'])
  }
}

// 提交福利项目
const handleItemSubmit = async () => {
  if (!itemFormRef.value) return
  
  try {
    await itemFormRef.value.validate()
    
    if (itemDialogType.value === 'add') {
      await createWelfareItem(itemFormData)
      ElMessage.success('新增成功')
    } else {
      await updateWelfareItem(itemFormData)
      ElMessage.success('更新成功')
    }
    
    itemDialogVisible.value = false
    loadItemList()
    loadEnabledItems() // 刷新启用的项目列表
  } catch (error) {
    console.error('保存福利项目失败:', error)
  }
}

// 提交发放记录
const handleRecordSubmit = async () => {
  if (!recordFormRef.value) return
  
  try {
    await recordFormRef.value.validate()
    
    // 准备提交数据
    const submitData: any = {
      id: recordFormData.id,
      itemId: recordFormData.itemId,
      grantMonth: recordFormData.grantMonth,
      grantDate: recordFormData.grantDate,
      amount: recordFormData.amount,
      status: recordFormData.status,
      remark: recordFormData.remark
    }
    
    // 根据发放方式设置员工ID
    if (recordFormData.grantType === 'single') {
      submitData.employeeId = recordFormData.employeeId
    } else {
      submitData.employeeIds = recordFormData.employeeIds
    }
    
    if (recordDialogType.value === 'add') {
      await createWelfareRecord(submitData)
      ElMessage.success('新增成功')
    } else {
      await updateWelfareRecord(submitData)
      ElMessage.success('更新成功')
    }
    
    recordDialogVisible.value = false
    loadRecordList()
  } catch (error) {
    console.error('保存发放记录失败:', error)
  }
}

// 删除福利项目
const handleDeleteItem = (row: WelfareItem) => {
  ElMessageBox.confirm(
    `确定要删除福利项目 "${row.name}" 吗？`,
    '删除确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await deleteWelfareItem(row.id!)
      ElMessage.success('删除成功')
      loadItemList()
      loadEnabledItems()
    } catch (error) {
      console.error('删除福利项目失败:', error)
    }
  }).catch(() => {})
}

// 删除发放记录
const handleDeleteRecord = (row: WelfareRecord) => {
  ElMessageBox.confirm(
    `确定要删除发放记录吗？`,
    '删除确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      await deleteWelfareRecord(row.id!)
      ElMessage.success('删除成功')
      loadRecordList()
    } catch (error) {
      console.error('删除发放记录失败:', error)
    }
  }).catch(() => {})
}

// 标记为已发放
const handleMarkAsGranted = (row: WelfareRecord) => {
  ElMessageBox.confirm(
    `确定要将该记录标记为已发放吗？`,
    '标记确认',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(async () => {
    try {
      const updateData = { ...row, status: 1 }
      await updateWelfareRecord(updateData)
      ElMessage.success('标记成功')
      loadRecordList()
    } catch (error) {
      console.error('标记发放记录失败:', error)
    }
  }).catch(() => {})
}

// 工具函数
const getWelfareTypeTag = (type?: string) => {
  switch (type) {
    case 'SUBSIDY': return 'success'
    case 'GOODS': return 'warning'
    case 'INSURANCE': return 'info'
    case 'OTHER': return ''
    default: return ''
  }
}

const getWelfareTypeLabel = (type?: string) => {
  switch (type) {
    case 'SUBSIDY': return '补贴'
    case 'GOODS': return '实物'
    case 'INSURANCE': return '保险'
    case 'OTHER': return '其他'
    default: return type || ''
  }
}

const getCycleLabel = (cycle?: string) => {
  switch (cycle) {
    case 'MONTHLY': return '每月'
    case 'QUARTERLY': return '每季度'
    case 'YEARLY': return '每年'
    case 'IRREGULAR': return '不定期'
    default: return cycle || ''
  }
}

const formatCurrency = (amount?: number) => {
  if (amount === undefined || amount === null) return '0.00'
  return amount.toLocaleString('zh-CN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}
</script>

<style scoped>
.welfare-management-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.welfare-tabs {
  margin-top: 10px;
}

.query-card {
  margin-bottom: 20px;
}

.table-card {
  margin-top: 20px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>