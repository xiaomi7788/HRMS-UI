<template>
  <div class="admin-dashboard">
    <!-- 核心指标卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6" v-loading="summaryLoading">
        <div class="stat-card primary">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon :size="28"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ summary.onJobCount }}</div>
              <div class="stat-label">在职员工</div>
              <div class="stat-desc">Total Employees</div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" v-loading="summaryLoading">
        <div class="stat-card success">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon :size="28"><OfficeBuilding /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ summary.deptCount }}</div>
              <div class="stat-label">部门数量</div>
              <div class="stat-desc">Departments</div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" v-loading="summaryLoading">
        <div class="stat-card warning">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon :size="28"><Document /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ summary.pendingApproval }}</div>
              <div class="stat-label">待审批</div>
              <div class="stat-desc">Pending Approval</div>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6" v-loading="summaryLoading">
        <div class="stat-card info">
          <div class="stat-content">
            <div class="stat-icon">
              <el-icon :size="28"><Money /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ summary.salaryCalculatedThisMonth }}</div>
              <div class="stat-label">本月薪酬</div>
              <div class="stat-desc">Salary Calculated</div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 第一行：人员概览 + 薪酬趋势 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="12">
        <el-card shadow="hover" v-loading="employeeOverviewLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">
                <el-icon><User /></el-icon>
                人员概览
              </span>
              <el-button link @click="loadEmployeeOverview">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          <div class="employee-overview">
            <div class="overview-grid">
              <div class="overview-item">
                <div class="overview-icon total">
                  <el-icon :size="24"><User /></el-icon>
                </div>
                <div class="overview-content">
                  <div class="overview-value">{{ employeeOverview.total }}</div>
                  <div class="overview-label">总人数</div>
                </div>
              </div>
              <div class="overview-item">
                <div class="overview-icon on-job">
                  <el-icon :size="24"><Briefcase /></el-icon>
                </div>
                <div class="overview-content">
                  <div class="overview-value">{{ employeeOverview.onJob }}</div>
                  <div class="overview-label">在职</div>
                </div>
              </div>
              <div class="overview-item">
                <div class="overview-icon probation">
                  <el-icon :size="24"><Clock /></el-icon>
                </div>
                <div class="overview-content">
                  <div class="overview-value">{{ employeeOverview.probation }}</div>
                  <div class="overview-label">试用期</div>
                </div>
              </div>
              <div class="overview-item">
                <div class="overview-icon leave">
                  <el-icon :size="24"><UserFilled /></el-icon>
                </div>
                <div class="overview-content">
                  <div class="overview-value">{{ employeeOverview.leaved }}</div>
                  <div class="overview-label">离职</div>
                </div>
              </div>
            </div>
            <el-divider />
            <div class="monthly-stats">
              <div class="monthly-item">
                <div class="monthly-label">本月入职</div>
                <div class="monthly-value up">
                  <el-icon><Top /></el-icon>
                  {{ employeeOverview.newHiresThisMonth }}
                </div>
              </div>
              <div class="monthly-item">
                <div class="monthly-label">本月离职</div>
                <div class="monthly-value down">
                  <el-icon><Bottom /></el-icon>
                  {{ employeeOverview.leavedThisMonth }}
                </div>
              </div>
              <div class="monthly-item">
                <div class="monthly-label">离职率</div>
                <div class="monthly-value rate">
                  {{ employeeOverview.leaveRateThisMonth }}%
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="hover" v-loading="salaryTrendLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">
                <el-icon><TrendCharts /></el-icon>
                近6个月薪酬成本趋势
              </span>
              <el-button link @click="loadSalaryTrend">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          <div id="salaryTrendChart" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第二行：部门分布 + 绩效分布 + 招聘漏斗 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="8">
        <el-card shadow="hover" v-loading="deptDistributionLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">
                <el-icon><PieChart /></el-icon>
                部门人员分布
              </span>
              <el-button link @click="loadDeptDistribution">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          <div id="deptDistributionChart" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="hover" v-loading="perfDistributionLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">
                <el-icon><DataAnalysis /></el-icon>
                绩效等级分布
              </span>
              <el-button link @click="loadPerfDistribution">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          <div id="perfDistributionChart" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card shadow="hover" v-loading="recruitFunnelLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">
                <el-icon><Histogram /></el-icon>
                招聘漏斗
              </span>
              <el-button link @click="loadRecruitFunnel">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          <div id="recruitFunnelChart" class="chart-container"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 第三行：考勤统计 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24">
        <el-card shadow="hover" v-loading="attendanceStatsLoading">
          <template #header>
            <div class="card-header">
              <span class="card-title">
                <el-icon><Calendar /></el-icon>
                本月考勤统计
              </span>
              <el-button link @click="loadAttendanceStats">
                <el-icon><Refresh /></el-icon>
              </el-button>
            </div>
          </template>
          <div class="attendance-stats">
            <div class="attendance-item">
              <div class="attendance-box">
                <div class="attendance-icon-box leave">
                  <el-icon :size="36"><Calendar /></el-icon>
                </div>
                <div class="attendance-text">
                  <div class="attendance-number">{{ attendanceStats.totalLeave }}</div>
                  <div class="attendance-label">请假申请</div>
                </div>
              </div>
            </div>
            <div class="attendance-item">
              <div class="attendance-box">
                <div class="attendance-icon-box overtime">
                  <el-icon :size="36"><Clock /></el-icon>
                </div>
                <div class="attendance-text">
                  <div class="attendance-number">{{ attendanceStats.totalOvertime }}</div>
                  <div class="attendance-label">加班申请</div>
                </div>
              </div>
            </div>
            <div class="attendance-item">
              <div class="attendance-box">
                <div class="attendance-icon-box pending">
                  <el-icon :size="36"><DocumentChecked /></el-icon>
                </div>
                <div class="attendance-text">
                  <div class="attendance-number">{{ attendanceStats.pendingApproval }}</div>
                  <div class="attendance-label">待审批</div>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import {
  getDashboardSummary,
  getEmployeeOverview,
  getDeptDistribution,
  getSalaryTrend,
  getPerfDistribution,
  getRecruitFunnel,
  getAttendanceStats,
  type DashboardSummary,
  type EmployeeOverview,
  type DeptDistribution,
  type SalaryTrend,
  type PerfDistribution,
  type RecruitFunnel,
  type AttendanceStats
} from '@/api/dashboard'
import { getDeptTree } from '@/api/dept'
import * as echarts from 'echarts'
import {
  User,
  OfficeBuilding,
  Document,
  Money,
  Refresh,
  Calendar,
  Clock,
  DocumentChecked,
  Briefcase,
  UserFilled,
  Top,
  Bottom,
  TrendCharts,
  PieChart,
  DataAnalysis,
  Histogram
} from '@element-plus/icons-vue'

// 加载状态
const summaryLoading = ref(false)
const employeeOverviewLoading = ref(false)
const deptDistributionLoading = ref(false)
const salaryTrendLoading = ref(false)
const perfDistributionLoading = ref(false)
const recruitFunnelLoading = ref(false)
const attendanceStatsLoading = ref(false)

// 数据
const summary = ref<DashboardSummary>({
  onJobCount: 0,
  deptCount: 0,
  pendingApproval: 0,
  salaryCalculatedThisMonth: 0
})
const employeeOverview = ref<EmployeeOverview>({
  total: 0,
  onJob: 0,
  leaved: 0,
  probation: 0,
  newHiresThisMonth: 0,
  leavedThisMonth: 0,
  leaveRateThisMonth: 0
})
const salaryTrend = ref<SalaryTrend>({
  months: [],
  totalPay: []
})
const perfDistribution = ref<PerfDistribution>({
  A: 0,
  B: 0,
  C: 0,
  D: 0
})
const recruitFunnel = ref<RecruitFunnel>({
  total: 0,
  stageDistribution: {}
})
const attendanceStats = ref<AttendanceStats>({
  totalLeave: 0,
  totalOvertime: 0,
  pendingApproval: 0
})

// ECharts实例
let salaryTrendChart: echarts.ECharts | null = null
let deptDistributionChart: echarts.ECharts | null = null
let perfDistributionChart: echarts.ECharts | null = null
let recruitFunnelChart: echarts.ECharts | null = null

// 获取综合仪表盘摘要
async function loadDashboardSummary() {
  summaryLoading.value = true
  try {
    summary.value = await getDashboardSummary()
  } catch (error) {
    console.error('获取综合仪表盘摘要失败:', error)
  } finally {
    summaryLoading.value = false
  }
}

// 获取人员概览
async function loadEmployeeOverview() {
  employeeOverviewLoading.value = true
  try {
    employeeOverview.value = await getEmployeeOverview()
  } catch (error) {
    console.error('获取人员概览失败:', error)
  } finally {
    employeeOverviewLoading.value = false
  }
}

// 获取薪酬趋势
async function loadSalaryTrend() {
  salaryTrendLoading.value = true
  try {
    salaryTrend.value = await getSalaryTrend()
    await nextTick()
    renderSalaryTrendChart()
  } catch (error) {
    console.error('获取薪酬趋势失败:', error)
  } finally {
    salaryTrendLoading.value = false
  }
}

// 渲染薪酬趋势图
function renderSalaryTrendChart() {
  const chartDom = document.getElementById('salaryTrendChart')
  if (!chartDom) return

  if (!salaryTrendChart) {
    salaryTrendChart = echarts.init(chartDom)
  }

  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#eee',
      borderWidth: 1,
      textStyle: { color: '#333' },
      formatter: (params: any) => {
        return `${params[0].name}<br/>薪酬总额: <span style="color: #667eea; font-weight: bold;">¥${params[0].value}</span>`
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '15%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: salaryTrend.value.months,
      boundaryGap: false,
      axisLine: { lineStyle: { color: '#ddd' } },
      axisLabel: { color: '#666' }
    },
    yAxis: {
      type: 'value',
      name: '金额(元)',
      nameTextStyle: { color: '#999' },
      axisLine: { lineStyle: { color: '#ddd' } },
      axisLabel: { color: '#666' },
      splitLine: { lineStyle: { color: '#f0f0f0', type: 'dashed' } }
    },
    series: [
      {
        name: '薪酬总额',
        type: 'line',
        data: salaryTrend.value.totalPay,
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(102, 126, 234, 0.4)' },
            { offset: 1, color: 'rgba(102, 126, 234, 0.05)' }
          ])
        },
        lineStyle: {
          color: '#667eea',
          width: 3
        },
        itemStyle: {
          color: '#667eea',
          borderWidth: 2,
          borderColor: '#fff'
        }
      }
    ]
  }

  salaryTrendChart.setOption(option)
}

// 获取部门人员分布
async function loadDeptDistribution() {
  deptDistributionLoading.value = true
  try {
    const distributions = await getDeptDistribution()
    const depts = await getDeptTree()
    
    // 展开树形结构为扁平数组
    const flattenDepts: any[] = []
    function flatten(deptTree: any[]) {
      deptTree.forEach(dept => {
        flattenDepts.push(dept)
        if (dept.children && dept.children.length > 0) {
          flatten(dept.children)
        }
      })
    }
    flatten(depts)
    
    // 组合数据
    const data = distributions.map(d => {
      const dept = flattenDepts.find((item: any) => item.id === d.deptId)
      return {
        name: dept?.deptName || `部门${d.deptId}`,
        value: d.count
      }
    })
    
    await nextTick()
    renderDeptDistributionChart(data)
  } catch (error) {
    console.error('获取部门人员分布失败:', error)
  } finally {
    deptDistributionLoading.value = false
  }
}

// 渲染部门人员分布图
function renderDeptDistributionChart(data: any[]) {
  const chartDom = document.getElementById('deptDistributionChart')
  if (!chartDom) return

  if (!deptDistributionChart) {
    deptDistributionChart = echarts.init(chartDom)
  }

  // 按人数降序排序
  const sortedData = [...data].sort((a, b) => b.value - a.value)

  const colors = ['#667eea', '#764ba2', '#f093fb', '#f5576c', '#4facfe', '#00f2fe', '#43e97b', '#38f9d7']

  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: (params: any) => {
        return `${params[0].name}<br/>人数: <span style="color: #667eea; font-weight: bold;">${params[0].value}人</span>`
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '5%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      name: '人数',
      nameTextStyle: { color: '#999' },
      axisLine: { lineStyle: { color: '#ddd' } },
      axisLabel: { color: '#666' },
      splitLine: { lineStyle: { color: '#f0f0f0', type: 'dashed' } }
    },
    yAxis: {
      type: 'category',
      data: sortedData.map(item => item.name),
      axisLine: { lineStyle: { color: '#ddd' } },
      axisLabel: { color: '#666' }
    },
    series: [
      {
        name: '部门人员',
        type: 'bar',
        data: sortedData.map((item, index) => ({
          value: item.value,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: colors[index % colors.length] },
              { offset: 1, color: colors[(index + 1) % colors.length] }
            ]),
            borderRadius: [0, 8, 8, 0]
          }
        })),
        barWidth: '60%',
        label: {
          show: true,
          position: 'right',
          formatter: '{c}人',
          color: '#666'
        },
        animationDelay: (idx: number) => idx * 50
      }
    ]
  }

  deptDistributionChart.setOption(option)
}

// 获取绩效等级分布
async function loadPerfDistribution() {
  perfDistributionLoading.value = true
  try {
    perfDistribution.value = await getPerfDistribution()
    await nextTick()
    renderPerfDistributionChart()
  } catch (error) {
    console.error('获取绩效等级分布失败:', error)
  } finally {
    perfDistributionLoading.value = false
  }
}

// 渲染绩效等级分布图
function renderPerfDistributionChart() {
  const chartDom = document.getElementById('perfDistributionChart')
  if (!chartDom) return

  if (!perfDistributionChart) {
    perfDistributionChart = echarts.init(chartDom)
  }

  const data = [
    { value: perfDistribution.value.A, name: 'A级', itemStyle: { color: '#67c23a' } },
    { value: perfDistribution.value.B, name: 'B级', itemStyle: { color: '#409eff' } },
    { value: perfDistribution.value.C, name: 'C级', itemStyle: { color: '#e6a23c' } },
    { value: perfDistribution.value.D, name: 'D级', itemStyle: { color: '#f56c6c' } }
  ]

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c}人 ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 10,
      top: 'center',
      textStyle: { color: '#666' }
    },
    series: [
      {
        name: '绩效等级',
        type: 'pie',
        radius: '65%',
        center: ['38%', '50%'],
        itemStyle: {
          borderRadius: 8,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}: {c}人'
        },
        data: data
      }
    ]
  }

  perfDistributionChart.setOption(option)
}

// 获取招聘漏斗
async function loadRecruitFunnel() {
  recruitFunnelLoading.value = true
  try {
    recruitFunnel.value = await getRecruitFunnel()
    await nextTick()
    renderRecruitFunnelChart()
  } catch (error) {
    console.error('获取招聘漏斗失败:', error)
  } finally {
    recruitFunnelLoading.value = false
  }
}

// 渲染招聘漏斗图
function renderRecruitFunnelChart() {
  const chartDom = document.getElementById('recruitFunnelChart')
  if (!chartDom) return

  if (!recruitFunnelChart) {
    recruitFunnelChart = echarts.init(chartDom)
  }

  const stageNames = ['简历筛选', '初试', '复试', 'Offer', '入职']
  const colors = ['#667eea', '#764ba2', '#f093fb', '#f5576c', '#4facfe']
  const data = stageNames.map((name, index) => ({
    name,
    value: recruitFunnel.value.stageDistribution[index] || 0,
    itemStyle: { color: colors[index] }
  }))

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c}人'
    },
    series: [
      {
        name: '招聘漏斗',
        type: 'funnel',
        left: '10%',
        top: 60,
        bottom: 60,
        width: '80%',
        min: 0,
        max: Math.max(...data.map((d: any) => d.value), 1),
        minSize: '0%',
        maxSize: '100%',
        sort: 'descending',
        gap: 2,
        label: {
          show: true,
          position: 'inside',
          formatter: '{b}: {c}',
          color: '#fff',
          fontSize: 14
        },
        labelLine: {
          show: false
        },
        itemStyle: {
          borderColor: '#fff',
          borderWidth: 2,
          borderRadius: 8
        },
        emphasis: {
          label: {
            fontSize: 16,
            fontWeight: 'bold'
          }
        },
        data: data
      }
    ]
  }

  recruitFunnelChart.setOption(option)
}

// 获取考勤统计
async function loadAttendanceStats() {
  attendanceStatsLoading.value = true
  try {
    attendanceStats.value = await getAttendanceStats()
  } catch (error) {
    console.error('获取考勤统计失败:', error)
  } finally {
    attendanceStatsLoading.value = false
  }
}

// 窗口大小改变时重绘图表
function handleResize() {
  salaryTrendChart?.resize()
  deptDistributionChart?.resize()
  perfDistributionChart?.resize()
  recruitFunnelChart?.resize()
}

onMounted(async () => {
  await loadDashboardSummary()
  await loadEmployeeOverview()
  await loadSalaryTrend()
  await loadDeptDistribution()
  await loadPerfDistribution()
  await loadRecruitFunnel()
  await loadAttendanceStats()

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  salaryTrendChart?.dispose()
  deptDistributionChart?.dispose()
  perfDistributionChart?.dispose()
  recruitFunnelChart?.dispose()
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
.admin-dashboard {
  padding: 24px;
  background: #f5f7fa;
  min-height: 100vh;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: transform 0.3s, box-shadow 0.3s;
  cursor: pointer;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-card.primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card.success {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-card.warning {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-card.info {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 64px;
  height: 64px;
  background: rgba(255, 255, 255, 0.25);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  backdrop-filter: blur(10px);
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 36px;
  font-weight: bold;
  color: white;
  line-height: 1;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.95);
  font-weight: 500;
  margin-bottom: 4px;
}

.stat-desc {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.75);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.chart-row {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.employee-overview {
  padding: 10px 0;
}

.overview-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.overview-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  border-radius: 12px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  transition: transform 0.3s;
}

.overview-item:hover {
  transform: scale(1.02);
}

.overview-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.overview-icon.total {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.overview-icon.on-job {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.overview-icon.probation {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.overview-icon.leave {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.overview-content {
  flex: 1;
}

.overview-value {
  font-size: 24px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
  margin-bottom: 4px;
}

.overview-label {
  font-size: 13px;
  color: #909399;
}

.monthly-stats {
  display: flex;
  justify-content: space-around;
  padding: 10px 0;
}

.monthly-item {
  text-align: center;
}

.monthly-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.monthly-value {
  font-size: 20px;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.monthly-value.up {
  color: #67c23a;
}

.monthly-value.down {
  color: #f56c6c;
}

.monthly-value.rate {
  color: #409eff;
  justify-content: center;
}

.chart-container {
  height: 320px;
  width: 100%;
}

.attendance-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  padding: 20px 0;
}

.attendance-box {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 32px;
  border-radius: 16px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  transition: transform 0.3s;
}

.attendance-box:hover {
  transform: translateY(-4px);
}

.attendance-icon-box {
  width: 80px;
  height: 80px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.attendance-icon-box.leave {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.attendance-icon-box.overtime {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.attendance-icon-box.pending {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.attendance-text {
  flex: 1;
}

.attendance-number {
  font-size: 40px;
  font-weight: bold;
  color: #303133;
  line-height: 1;
  margin-bottom: 8px;
}

.attendance-label {
  font-size: 16px;
  color: #909399;
  font-weight: 500;
}

@media (max-width: 1200px) {
  .overview-grid {
    grid-template-columns: 1fr;
  }
  
  .attendance-stats {
    grid-template-columns: 1fr;
  }
}
</style>
