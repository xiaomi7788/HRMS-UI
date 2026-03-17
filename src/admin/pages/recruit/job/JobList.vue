<template>
  <div class="job-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">招聘职位管理</span>
          <el-button type="primary" @click="handleAdd">发布职位</el-button>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="关键字">
          <el-input v-model="queryParams.keyword" placeholder="职位名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="queryParams.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="招募中" :value="1" />
            <el-option label="暂停" :value="2" />
            <el-option label="关闭" :value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="jobName" label="职位名称" width="150" />
        <el-table-column prop="deptName" label="所属部门" width="120" />
        <el-table-column prop="headcount" label="招聘人数" width="100" align="center" />
        <el-table-column prop="hiredCount" label="已录用" width="100" align="center" />
        <el-table-column label="薪资范围" width="150">
          <template #default="{ row }">
            {{ row.salaryMin && row.salaryMax ? `${row.salaryMin} - ${row.salaryMax}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="education" label="学历要求" width="100" />
        <el-table-column prop="experience" label="工作经验" width="120" />
        <el-table-column prop="deadline" label="截止日期" width="120" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : row.status === 2 ? 'warning' : 'info'">
              {{ row.status === 1 ? '招募中' : row.status === 2 ? '暂停' : '关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="发布时间" width="160" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button link type="warning" size="small" @click="handleClose(row)" v-if="row.status === 1">关闭</el-button>
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

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="700px"
      @close="handleDialogClose"
    >
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="职位名称" prop="jobName">
              <el-input v-model="formData.jobName" placeholder="请输入职位名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所属部门" prop="deptId">
              <el-select v-model="formData.deptId" placeholder="请选择部门" style="width: 100%">
                <el-option
                  v-for="dept in deptList"
                  :key="dept.id"
                  :label="dept.deptName"
                  :value="dept.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="招聘人数" prop="headcount">
              <el-input-number v-model="formData.headcount" :min="1" :max="100" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="截止日期" prop="deadline">
              <el-date-picker
                v-model="formData.deadline"
                type="date"
                placeholder="请选择截止日期"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="学历要求" prop="education">
              <el-input v-model="formData.education" placeholder="如：本科及以上" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="工作经验" prop="experience">
              <el-input v-model="formData.experience" placeholder="如：3年以上" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="最低薪资" prop="salaryMin">
              <el-input-number v-model="formData.salaryMin" :min="0" :precision="0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="最高薪资" prop="salaryMax">
              <el-input-number v-model="formData.salaryMax" :min="0" :precision="0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="职位描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="4"
            placeholder="请输入职位描述"
          />
        </el-form-item>
        <el-form-item label="任职要求" prop="requirement">
          <el-input
            v-model="formData.requirement"
            type="textarea"
            :rows="4"
            placeholder="请输入任职要求"
          />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio :value="1">招募中</el-radio>
            <el-radio :value="2">暂停</el-radio>
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
import { getJobPage, createJob, updateJob, deleteJob, closeJob, type RecruitJob, type JobPageParams } from '@/api/job'
import { getDeptTree, type Department } from '@/api/dept'

const loading = ref(false)
const tableData = ref<RecruitJob[]>([])
const total = ref(0)
const deptList = ref<Department[]>([])
const dialogVisible = ref(false)
const dialogTitle = ref('')
const formRef = ref<FormInstance>()

const queryParams = reactive<JobPageParams>({
  pageNum: 1,
  pageSize: 20,
  keyword: '',
  status: undefined
})

const formData = reactive<Partial<RecruitJob>>({
  jobName: '',
  deptId: undefined,
  headcount: 1,
  education: '',
  experience: '',
  salaryMin: undefined,
  salaryMax: undefined,
  description: '',
  requirement: '',
  deadline: '',
  status: 1
})

const formRules: FormRules = {
  jobName: [{ required: true, message: '请输入职位名称', trigger: 'blur' }],
  deptId: [{ required: true, message: '请选择所属部门', trigger: 'change' }],
  headcount: [{ required: true, message: '请输入招聘人数', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
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

const loadData = async () => {
  loading.value = true
  try {
    const data = await getJobPage(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载职位列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.keyword = ''
  queryParams.status = undefined
  queryParams.pageNum = 1
  loadData()
}

const handleAdd = () => {
  dialogTitle.value = '发布职位'
  dialogVisible.value = true
  Object.assign(formData, {
    jobName: '',
    deptId: undefined,
    headcount: 1,
    education: '',
    experience: '',
    salaryMin: undefined,
    salaryMax: undefined,
    description: '',
    requirement: '',
    deadline: '',
    status: 1
  })
}

const handleEdit = (row: RecruitJob) => {
  dialogTitle.value = '编辑职位'
  dialogVisible.value = true
  Object.assign(formData, row)
}

const handleClose = (row: RecruitJob) => {
  ElMessageBox.confirm('确认关闭该职位吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await closeJob(row.id!)
      ElMessage.success('操作成功')
      loadData()
    } catch (error) {
      console.error('关闭职位失败:', error)
    }
  })
}

const handleDelete = (row: RecruitJob) => {
  ElMessageBox.confirm('确认删除该职位吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteJob(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除职位失败:', error)
    }
  })
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      try {
        if (formData.id) {
          await updateJob(formData)
          ElMessage.success('更新成功')
        } else {
          await createJob(formData)
          ElMessage.success('发布成功')
        }
        dialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('提交失败:', error)
      }
    }
  })
}

const handleDialogClose = () => {
  formRef.value?.resetFields()
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadDeptList()
  loadData()
})
</script>

<style scoped>
.job-container {
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
