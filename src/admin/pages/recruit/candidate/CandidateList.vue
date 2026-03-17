<template>
  <div class="candidate-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">候选人库</span>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="职位">
          <el-select v-model="queryParams.jobId" placeholder="全部职位" clearable style="width: 200px">
            <el-option
              v-for="job in jobList"
              :key="job.id"
              :label="job.jobName"
              :value="job.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="面试阶段">
          <el-select v-model="queryParams.stage" placeholder="全部阶段" clearable style="width: 150px">
            <el-option label="简历筛选" :value="0" />
            <el-option label="初试" :value="1" />
            <el-option label="复试" :value="2" />
            <el-option label="终试" :value="3" />
            <el-option label="Offer" :value="4" />
            <el-option label="已录用" :value="5" />
            <el-option label="淘汰" :value="6" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input v-model="queryParams.keyword" placeholder="姓名/手机号" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column label="性别" width="80">
          <template #default="{ row }">
            {{ row.gender === 1 ? '男' : row.gender === 0 ? '女' : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="email" label="邮箱" min-width="160" show-overflow-tooltip />
        <el-table-column prop="jobName" label="应聘职位" width="150" />
        <el-table-column prop="education" label="学历" width="100" />
        <el-table-column prop="school" label="毕业院校" width="150" show-overflow-tooltip />
        <el-table-column prop="major" label="专业" width="120" show-overflow-tooltip />
        <el-table-column prop="workYears" label="工作年限" width="100" align="center" />
        <el-table-column prop="currentCompany" label="当前单位" width="150" show-overflow-tooltip />
        <el-table-column prop="currentPosition" label="当前职位" width="150" show-overflow-tooltip />
        <el-table-column prop="source" label="来源" width="100" />
        <el-table-column prop="expectedSalary" label="期望薪资" width="120" />
        <el-table-column label="面试阶段" width="100">
          <template #default="{ row }">
            <el-tag :type="getStageType(row.stage)">
              {{ getStageText(row.stage) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="interviewTimes" label="面试次数" width="100" align="center" />
        <el-table-column prop="createTime" label="创建时间" width="160" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCandidatePage, deleteCandidate, type RecruitCandidate, type CandidatePageParams } from '@/api/candidate'
import { getJobList, type RecruitJob } from '@/api/job'

const loading = ref(false)
const tableData = ref<RecruitCandidate[]>([])
const total = ref(0)
const jobList = ref<RecruitJob[]>([])

const queryParams = reactive<CandidatePageParams>({
  pageNum: 1,
  pageSize: 20,
  jobId: undefined,
  stage: undefined,
  keyword: ''
})

const loadJobList = async () => {
  try {
    const data = await getJobList()
    jobList.value = data
  } catch (error) {
    console.error('加载职位列表失败:', error)
  }
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getCandidatePage(queryParams)
    tableData.value = data.records.map(candidate => ({
      ...candidate,
      jobName: jobList.value.find(job => job.id === candidate.jobId)?.jobName || '-'
    }))
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载候选人列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleQuery = () => {
  queryParams.pageNum = 1
  loadData()
}

const handleReset = () => {
  queryParams.jobId = undefined
  queryParams.stage = undefined
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadData()
}

const handleDelete = (row: RecruitCandidate) => {
  ElMessageBox.confirm('确认删除该候选人吗？', '提示', {
    type: 'warning'
  }).then(async () => {
    try {
      await deleteCandidate(row.id!)
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      console.error('删除候选人失败:', error)
    }
  })
}

const getStageText = (stage: number) => {
  const stageMap: Record<number, string> = {
    0: '简历筛选',
    1: '初试',
    2: '复试',
    3: '终试',
    4: 'Offer',
    5: '已录用',
    6: '淘汰'
  }
  return stageMap[stage] || '-'
}

const getStageType = (stage: number) => {
  const typeMap: Record<number, string> = {
    0: 'info',
    1: 'warning',
    2: 'warning',
    3: 'warning',
    4: 'primary',
    5: 'success',
    6: 'danger'
  }
  return typeMap[stage] || ''
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

onMounted(() => {
  loadJobList()
  loadData()
})
</script>

<style scoped>
.candidate-container {
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
