<template>
  <div class="grade-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">薪资等级管理</span>
          <el-button type="primary" @click="handleAdd">新建等级</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="职级序列">
          <el-select v-model="queryParams.series" placeholder="选择序列" clearable style="width: 150px">
            <el-option label="技术" value="技术" />
            <el-option label="管理" value="管理" />
            <el-option label="销售" value="销售" />
            <el-option label="职能" value="职能" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="选择状态" clearable style="width: 120px">
            <el-option label="启用" :value="1" />
            <el-option label="停用" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="queryParams.keyword" placeholder="等级编码/名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="gradeCode" label="等级编码" width="120" />
        <el-table-column prop="gradeName" label="等级名称" width="150" />
        <el-table-column prop="series" label="职级序列" width="100" />
        <el-table-column prop="minSalary" label="薪资下限" width="120">
          <template #default="{ row }">
            {{ row.minSalary ? `¥${row.minSalary}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="maxSalary" label="薪资上限" width="120">
          <template #default="{ row }">
            {{ row.maxSalary ? `¥${row.maxSalary}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="midSalary" label="参考中位值" width="120">
          <template #default="{ row }">
            {{ row.midSalary ? `¥${row.midSalary}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="positionAllowance" label="岗位津贴" width="120">
          <template #default="{ row }">
            {{ row.positionAllowance ? `¥${row.positionAllowance}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'">
              {{ row.status === 1 ? '启用' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
      />
    </el-card>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑薪资等级' : '新建薪资等级'"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="120px">
        <el-form-item label="职级序列" prop="series">
          <el-select v-model="formData.series" placeholder="选择职级序列" style="width: 100%">
            <el-option label="技术" value="技术" />
            <el-option label="管理" value="管理" />
            <el-option label="销售" value="销售" />
            <el-option label="职能" value="职能" />
          </el-select>
        </el-form-item>
        <el-form-item label="等级编码" prop="gradeCode">
          <el-input v-model="formData.gradeCode" placeholder="如 P1/P2/M1/M2" />
        </el-form-item>
        <el-form-item label="等级名称" prop="gradeName">
          <el-input v-model="formData.gradeName" placeholder="如 初级工程师" />
        </el-form-item>
        <el-form-item label="薪资下限" prop="minSalary">
          <el-input-number v-model="formData.minSalary" :min="0" :precision="2" :step="1000" style="width: 100%" />
        </el-form-item>
        <el-form-item label="薪资上限" prop="maxSalary">
          <el-input-number v-model="formData.maxSalary" :min="0" :precision="2" :step="1000" style="width: 100%" />
        </el-form-item>
        <el-form-item label="参考中位值" prop="midSalary">
          <el-input-number v-model="formData.midSalary" :min="0" :precision="2" :step="1000" style="width: 100%" />
        </el-form-item>
        <el-form-item label="岗位津贴" prop="positionAllowance">
          <el-input-number v-model="formData.positionAllowance" :min="0" :precision="2" :step="500" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="formData.remark" type="textarea" :rows="3" placeholder="请输入备注说明" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">启用</el-radio>
            <el-radio :value="0">停用</el-radio>
          </el-radio-group>
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
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getGradePage,
  createGrade,
  updateGrade,
  deleteGrade,
  type SalaryGrade,
  type GradePageParams
} from '@/api/grade'

const loading = ref(false)
const tableData = ref<SalaryGrade[]>([])
const total = ref(0)
const dialogVisible = ref(false)
const formRef = ref<FormInstance>()
const isEdit = ref(false)

const queryParams = reactive<GradePageParams>({
  pageNum: 1,
  pageSize: 20,
  series: undefined,
  status: undefined,
  keyword: undefined
})

const formData = reactive<SalaryGrade>({
  gradeCode: '',
  gradeName: '',
  series: '',
  minSalary: undefined,
  maxSalary: undefined,
  midSalary: undefined,
  positionAllowance: undefined,
  remark: '',
  status: 1
})

const formRules: FormRules = {
  gradeCode: [{ required: true, message: '请输入等级编码', trigger: 'blur' }],
  gradeName: [{ required: true, message: '请输入等级名称', trigger: 'blur' }],
  series: [{ required: true, message: '请选择职级序列', trigger: 'change' }],
  minSalary: [{ required: true, message: '请输入薪资下限', trigger: 'blur' }],
  maxSalary: [{ required: true, message: '请输入薪资上限', trigger: 'blur' }],
  midSalary: [{ required: true, message: '请输入参考中位值', trigger: 'blur' }],
  positionAllowance: [{ required: true, message: '请输入岗位津贴', trigger: 'blur' }]
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getGradePage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载薪资等级列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.series = undefined
  queryParams.status = undefined
  queryParams.keyword = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(formData, {
    gradeCode: '',
    gradeName: '',
    series: '',
    minSalary: undefined,
    maxSalary: undefined,
    midSalary: undefined,
    positionAllowance: undefined,
    remark: '',
    status: 1
  })
  dialogVisible.value = true
}

const handleEdit = (row: SalaryGrade) => {
  isEdit.value = true
  Object.assign(formData, row)
  dialogVisible.value = true
}

const handleDelete = (row: SalaryGrade) => {
  ElMessageBox.confirm(`确认删除等级"${row.gradeName}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteGrade(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除失败:', error)
    }
  })
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (isEdit.value) {
          await updateGrade(formData)
          ElMessage.success('更新成功')
        } else {
          // 新建时排除id字段
          const { id, createTime, updateTime, deleted, ...createData } = formData
          await createGrade(createData)
          ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error: any) {
        console.error('保存失败:', error)
        if (error?.message?.includes('Duplicate entry') && error?.message?.includes('uk_grade_code')) {
          ElMessage.error('等级编码已存在，请使用其他编码')
        } else {
          ElMessage.error('保存失败，请稍后重试')
        }
      }
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

const handleCurrentChange = () => {
  loadData()
}

const handleSizeChange = () => {
  queryParams.pageNum = 1
  loadData()
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.grade-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
}

.search-form {
  margin-bottom: 20px;
}

.el-pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
