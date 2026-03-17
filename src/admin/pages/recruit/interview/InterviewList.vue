<template>
  <div class="interview-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">安排面试</span>
          <el-button type="primary" @click="handleAddCandidate">录入简历</el-button>
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
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="handleArrangeInterview(row)">安排面试</el-button>
            <el-button link type="warning" size="small" @click="handleUpdateStage(row)">更新阶段</el-button>
            <el-button link type="info" size="small" @click="handleViewDetail(row)">查看详情</el-button>
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

    <!-- 录入简历对话框 -->
    <el-dialog
      v-model="candidateDialogVisible"
      title="录入简历"
      width="700px"
      @close="handleCandidateDialogClose"
    >
      <el-form ref="candidateFormRef" :model="candidateForm" :rules="candidateFormRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="candidateForm.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-radio-group v-model="candidateForm.gender">
                <el-radio :value="1">男</el-radio>
                <el-radio :value="0">女</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="candidateForm.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="candidateForm.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="应聘职位" prop="jobId">
              <el-select v-model="candidateForm.jobId" placeholder="请选择职位" style="width: 100%">
                <el-option
                  v-for="job in jobList"
                  :key="job.id"
                  :label="job.jobName"
                  :value="job.id"
                />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="来源" prop="source">
              <el-select v-model="candidateForm.source" placeholder="请选择来源" style="width: 100%">
                <el-option label="自荐" value="自荐" />
                <el-option label="招聘网站" value="招聘网站" />
                <el-option label="内部推荐" value="内部推荐" />
                <el-option label="猎头" value="猎头" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="学历" prop="education">
              <el-input v-model="candidateForm.education" placeholder="如：本科" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="毕业年份" prop="graduationYear">
              <el-input-number v-model="candidateForm.graduationYear" :min="1990" :max="2030" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="毕业院校" prop="school">
          <el-input v-model="candidateForm.school" placeholder="请输入毕业院校" />
        </el-form-item>
        <el-form-item label="专业" prop="major">
          <el-input v-model="candidateForm.major" placeholder="请输入专业" />
        </el-form-item>
        <el-form-item label="工作年限" prop="workYears">
          <el-input-number v-model="candidateForm.workYears" :min="0" :max="50" style="width: 200px" />
        </el-form-item>
        <el-form-item label="当前单位" prop="currentCompany">
          <el-input v-model="candidateForm.currentCompany" placeholder="请输入当前单位" />
        </el-form-item>
        <el-form-item label="当前职位" prop="currentPosition">
          <el-input v-model="candidateForm.currentPosition" placeholder="请输入当前职位" />
        </el-form-item>
        <el-form-item label="期望薪资" prop="expectedSalary">
          <el-input v-model="candidateForm.expectedSalary" placeholder="如：10-15k" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="candidateForm.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="candidateDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveCandidate">确定</el-button>
      </template>
    </el-dialog>

    <!-- 安排面试对话框 -->
    <el-dialog
      v-model="interviewDialogVisible"
      title="安排面试"
      width="600px"
      @close="handleInterviewDialogClose"
    >
      <el-form ref="interviewFormRef" :model="interviewForm" :rules="interviewFormRules" label-width="100px">
        <el-form-item label="候选人">
          <el-input :value="currentCandidate?.name" disabled />
        </el-form-item>
        <el-form-item label="应聘职位">
          <el-input :value="currentCandidate?.jobName" disabled />
        </el-form-item>
        <el-form-item label="面试轮次" prop="round">
          <el-radio-group v-model="interviewForm.round">
            <el-radio :value="1">初试</el-radio>
            <el-radio :value="2">复试</el-radio>
            <el-radio :value="3">终试</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="面试官" prop="interviewerId">
          <el-select v-model="interviewForm.interviewerId" placeholder="请选择面试官" style="width: 100%">
            <el-option
              v-for="emp in employeeList"
              :key="emp.id"
              :label="emp.empName"
              :value="emp.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="面试时间" prop="interviewTime">
          <el-date-picker
            v-model="interviewForm.interviewTime"
            type="datetime"
            placeholder="请选择面试时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="面试方式" prop="type">
          <el-radio-group v-model="interviewForm.type">
            <el-radio :value="0">现场</el-radio>
            <el-radio :value="1">视频</el-radio>
            <el-radio :value="2">电话</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="interviewDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveInterview">确定</el-button>
      </template>
    </el-dialog>

    <!-- 更新阶段对话框 -->
    <el-dialog
      v-model="stageDialogVisible"
      title="更新面试阶段"
      width="400px"
      @close="handleStageDialogClose"
    >
      <el-form label-width="100px">
        <el-form-item label="候选人">
          <el-input :value="currentCandidate?.name" disabled />
        </el-form-item>
        <el-form-item label="当前阶段">
          <el-input :value="getStageText(currentCandidate?.stage || 0)" disabled />
        </el-form-item>
        <el-form-item label="新阶段">
          <el-radio-group v-model="newStage">
            <el-radio :value="0">简历筛选</el-radio>
            <el-radio :value="1">初试</el-radio>
            <el-radio :value="2">复试</el-radio>
            <el-radio :value="3">终试</el-radio>
            <el-radio :value="4">Offer</el-radio>
            <el-radio :value="5">已录用</el-radio>
            <el-radio :value="6">淘汰</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="stageDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveStage">确定</el-button>
      </template>
    </el-dialog>

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
      </el-table>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { getCandidatePage, type RecruitCandidate, type CandidatePageParams } from '@/api/candidate'
import { getJobList, type RecruitJob } from '@/api/job'
import {
  addInterview,
  listInterviews,
  updateStage,
  updateCandidate,
  createCandidate,
  type RecruitInterview
} from '@/api/interview'
import { getEmployeePage } from '@/api/employee'

const loading = ref(false)
const tableData = ref<RecruitCandidate[]>([])
const total = ref(0)
const jobList = ref<RecruitJob[]>([])
const employeeList = ref<any[]>([])
const interviewList = ref<RecruitInterview[]>([])

const candidateDialogVisible = ref(false)
const interviewDialogVisible = ref(false)
const stageDialogVisible = ref(false)
const detailDialogVisible = ref(false)

const candidateFormRef = ref<FormInstance>()
const interviewFormRef = ref<FormInstance>()

const currentCandidate = ref<RecruitCandidate | null>(null)
const newStage = ref<number>(0)

const queryParams = reactive<CandidatePageParams>({
  pageNum: 1,
  pageSize: 20,
  jobId: undefined,
  stage: undefined,
  keyword: ''
})

const candidateForm = reactive<Partial<RecruitCandidate>>({
  name: '',
  gender: 1,
  phone: '',
  email: '',
  jobId: undefined,
  source: '',
  education: '',
  graduationYear: new Date().getFullYear(),
  school: '',
  major: '',
  workYears: 0,
  currentCompany: '',
  currentPosition: '',
  expectedSalary: '',
  remark: ''
})

const candidateFormRules: FormRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [{ required: true, message: '请输入手机号', trigger: 'blur' }],
  email: [{ required: true, message: '请输入邮箱', trigger: 'blur' }],
  jobId: [{ required: true, message: '请选择应聘职位', trigger: 'change' }]
}

const interviewForm = reactive<Partial<RecruitInterview>>({
  round: 1,
  interviewerId: undefined,
  interviewTime: '',
  type: 0
})

const interviewFormRules: FormRules = {
  round: [{ required: true, message: '请选择面试轮次', trigger: 'change' }],
  interviewerId: [{ required: true, message: '请选择面试官', trigger: 'change' }],
  interviewTime: [{ required: true, message: '请选择面试时间', trigger: 'change' }],
  type: [{ required: true, message: '请选择面试方式', trigger: 'change' }]
}

const loadJobList = async () => {
  try {
    const data = await getJobList()
    jobList.value = data
  } catch (error) {
    console.error('加载职位列表失败:', error)
  }
}

const loadEmployeeList = async () => {
  try {
    const data = await getEmployeePage({ pageNum: 1, pageSize: 1000 })
    employeeList.value = data.records
  } catch (error) {
    console.error('加载员工列表失败:', error)
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

const handleAddCandidate = () => {
  candidateDialogVisible.value = true
}

const handleArrangeInterview = (row: RecruitCandidate) => {
  currentCandidate.value = row
  interviewDialogVisible.value = true
}

const handleUpdateStage = (row: RecruitCandidate) => {
  currentCandidate.value = row
  newStage.value = row.stage || 0
  stageDialogVisible.value = true
}

const handleViewDetail = async (row: RecruitCandidate) => {
  currentCandidate.value = row
  try {
    const data = await listInterviews(row.id!)
    interviewList.value = data
  } catch (error) {
    console.error('加载面试记录失败:', error)
  }
  detailDialogVisible.value = true
}

const handleSaveCandidate = async () => {
  if (!candidateFormRef.value) return
  await candidateFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await createCandidate(candidateForm)
        ElMessage.success('录入成功')
        candidateDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('录入简历失败:', error)
      }
    }
  })
}

const handleSaveInterview = async () => {
  if (!interviewFormRef.value || !currentCandidate.value) return
  await interviewFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await addInterview(currentCandidate.value.id!, interviewForm)
        ElMessage.success('安排成功')
        interviewDialogVisible.value = false
        loadData()
      } catch (error) {
        console.error('安排面试失败:', error)
      }
    }
  })
}

const handleSaveStage = async () => {
  if (!currentCandidate.value) return
  try {
    await updateStage(currentCandidate.value.id!, newStage.value)
    ElMessage.success('更新成功')
    stageDialogVisible.value = false
    loadData()
  } catch (error) {
    console.error('更新阶段失败:', error)
  }
}

const handleCandidateDialogClose = () => {
  candidateFormRef.value?.resetFields()
}

const handleInterviewDialogClose = () => {
  interviewFormRef.value?.resetFields()
}

const handleStageDialogClose = () => {
  newStage.value = 0
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
  loadEmployeeList()
  loadData()
})
</script>

<style scoped>
.interview-container {
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
