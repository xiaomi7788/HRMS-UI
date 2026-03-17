<template>
  <div class="offer-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">Offer管理</span>
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
        <el-table-column prop="workYears" label="工作年限" width="100" align="center" />
        <el-table-column prop="currentCompany" label="当前单位" width="150" show-overflow-tooltip />
        <el-table-column prop="currentPosition" label="当前职位" width="150" show-overflow-tooltip />
        <el-table-column prop="expectedSalary" label="期望薪资" width="120" />
        <el-table-column label="面试阶段" width="100">
          <template #default="{ row }">
            <el-tag :type="getStageType(row.stage)">
              {{ getStageText(row.stage) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="interviewTimes" label="面试次数" width="100" align="center" />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              link
              type="primary"
              size="small"
              @click="handleViewDetail(row)"
              :disabled="row.stage !== 3"
            >
              录入结果
            </el-button>
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

    <!-- 查看详情对话框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="候选人详情"
      width="900px"
    >
      <el-descriptions :column="2" border>
        <el-descriptions-item label="姓名">{{ currentCandidate?.name }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ currentCandidate?.gender === 1 ? '男' : '女' }}</el-descriptions-item>
        <el-descriptions-item label="手机号">{{ currentCandidate?.phone }}</el-descriptions-item>
        <el-descriptions-item label="邮箱">{{ currentCandidate?.email }}</el-descriptions-item>
        <el-descriptions-item label="应聘职位">{{ currentCandidate?.jobName }}</el-descriptions-item>
        <el-descriptions-item label="面试阶段">
          <el-tag :type="getStageType(currentCandidate?.stage || 0)">
            {{ getStageText(currentCandidate?.stage || 0) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="学历">{{ currentCandidate?.education }}</el-descriptions-item>
        <el-descriptions-item label="毕业年份">{{ currentCandidate?.graduationYear }}</el-descriptions-item>
        <el-descriptions-item label="毕业院校">{{ currentCandidate?.school }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ currentCandidate?.major }}</el-descriptions-item>
        <el-descriptions-item label="工作年限">{{ currentCandidate?.workYears }}年</el-descriptions-item>
        <el-descriptions-item label="当前单位">{{ currentCandidate?.currentCompany }}</el-descriptions-item>
        <el-descriptions-item label="当前职位">{{ currentCandidate?.currentPosition }}</el-descriptions-item>
        <el-descriptions-item label="期望薪资">{{ currentCandidate?.expectedSalary }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ currentCandidate?.source }}</el-descriptions-item>
        <el-descriptions-item label="面试次数">{{ currentCandidate?.interviewTimes }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ currentCandidate?.remark }}</el-descriptions-item>
      </el-descriptions>

      <el-divider>面试记录</el-divider>
      <el-table :data="interviewList" stripe>
        <el-table-column prop="round" label="轮次" width="80">
          <template #default="{ row }">
            {{ row.round === 1 ? '初试' : row.round === 2 ? '复试' : '终试' }}
          </template>
        </el-table-column>
        <el-table-column prop="interviewerName" label="面试官" width="120" />
        <el-table-column prop="interviewTime" label="面试时间" width="180" />
        <el-table-column label="面试方式" width="100">
          <template #default="{ row }">
            {{ row.type === 0 ? '现场' : row.type === 1 ? '视频' : '电话' }}
          </template>
        </el-table-column>
        <el-table-column label="结果" width="100">
          <template #default="{ row }">
            <el-tag :type="getResultType(row.result)">
              {{ getResultText(row.result) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="score" label="评分" width="100" align="center" />
        <el-table-column prop="comment" label="评价" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              link
              type="primary"
              size="small"
              @click="handleUpdateResult(row)"
              :disabled="row.result !== 0"
            >
              录入结果
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 录入面试结果对话框 -->
    <el-dialog
      v-model="resultDialogVisible"
      title="录入面试结果"
      width="500px"
      @close="handleResultDialogClose"
    >
      <el-form ref="resultFormRef" :model="resultForm" :rules="resultFormRules" label-width="100px">
        <el-form-item label="面试轮次">
          <el-input :value="currentInterview?.round === 1 ? '初试' : currentInterview?.round === 2 ? '复试' : '终试'" disabled />
        </el-form-item>
        <el-form-item label="面试官">
          <el-input :value="currentInterview?.interviewerName" disabled />
        </el-form-item>
        <el-form-item label="面试时间">
          <el-input :value="currentInterview?.interviewTime" disabled />
        </el-form-item>
        <el-form-item label="面试结果" prop="result">
          <el-radio-group v-model="resultForm.result">
            <el-radio :value="1">通过</el-radio>
            <el-radio :value="2">不通过</el-radio>
            <el-radio :value="3">爽约</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="面试评分">
          <el-input-number v-model="resultForm.score" :min="0" :max="100" style="width: 200px" />
        </el-form-item>
        <el-form-item label="面试评价" prop="comment">
          <el-input
            v-model="resultForm.comment"
            type="textarea"
            :rows="4"
            placeholder="请输入面试评价"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resultDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveResult">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import {
  getCandidatePage,
  listInterviews,
  updateInterviewResult,
  type UpdateInterviewResult
} from '@/api/offer'
import type { RecruitInterview } from '@/api/interview'
import { getJobList, type RecruitJob } from '@/api/job'

const loading = ref(false)
const tableData = ref<any[]>([])
const total = ref(0)
const jobList = ref<RecruitJob[]>([])
const interviewList = ref<RecruitInterview[]>([])

const detailDialogVisible = ref(false)
const resultDialogVisible = ref(false)

const resultFormRef = ref<FormInstance>()

const currentCandidate = ref<any>(null)
const currentInterview = ref<RecruitInterview | null>(null)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  jobId: undefined,
  stage: undefined,
  keyword: ''
})

const resultForm = reactive<UpdateInterviewResult>({
  result: 1,
  comment: '',
  score: 0
})

const resultFormRules: FormRules = {
  result: [{ required: true, message: '请选择面试结果', trigger: 'change' }],
  comment: [{ required: true, message: '请输入面试评价', trigger: 'blur' }]
}

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
    tableData.value = data.records.map((candidate: any) => ({
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

const handleViewDetail = async (row: any) => {
  currentCandidate.value = row
  try {
    const data = await listInterviews(row.id)
    interviewList.value = data
  } catch (error) {
    console.error('加载面试记录失败:', error)
  }
  detailDialogVisible.value = true
}

const handleUpdateResult = (row: RecruitInterview) => {
  currentInterview.value = row
  resultDialogVisible.value = true
}

const handleSaveResult = async () => {
  if (!resultFormRef.value || !currentInterview.value) return
  await resultFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await updateInterviewResult(currentInterview.value.id!, resultForm)
        ElMessage.success('录入成功')
        resultDialogVisible.value = false
        detailDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('录入面试结果失败:', error)
      }
    }
  })
}

const handleResultDialogClose = () => {
  resultFormRef.value?.resetFields()
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

const getResultText = (result: number) => {
  const resultMap: Record<number, string> = {
    0: '待面试',
    1: '通过',
    2: '不通过',
    3: '爽约'
  }
  return resultMap[result] || '-'
}

const getResultType = (result: number) => {
  const typeMap: Record<number, string> = {
    0: 'info',
    1: 'success',
    2: 'danger',
    3: 'warning'
  }
  return typeMap[result] || ''
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
.offer-container {
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
