<template>
  <div class="self-salary">
    <el-card class="salary-card">
      <template #header>
        <span>我的薪酬</span>
      </template>

      <!-- 表格 -->
      <el-table :data="recordList" v-loading="loading" stripe>
        <el-table-column prop="payMonth" label="薪酬月份" width="120" fixed="left" />
        <el-table-column prop="baseSalary" label="基本工资" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.baseSalary) }}
          </template>
        </el-table-column>
        <el-table-column prop="allowance" label="津贴" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.allowance) }}
          </template>
        </el-table-column>
        <el-table-column prop="bonus" label="奖金" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.bonus) }}
          </template>
        </el-table-column>
        <el-table-column prop="overtimePay" label="加班工资" width="120" align="right">
          <template #default="{ row }">
            ¥{{ formatMoney(row.overtimePay) }}
          </template>
        </el-table-column>
        <el-table-column prop="socialInsurance" label="社保" width="120" align="right">
          <template #default="{ row }">
            -¥{{ formatMoney(row.socialInsurance) }}
          </template>
        </el-table-column>
        <el-table-column prop="housingFund" label="公积金" width="120" align="right">
          <template #default="{ row }">
            -¥{{ formatMoney(row.housingFund) }}
          </template>
        </el-table-column>
        <el-table-column prop="deduction" label="其他扣款" width="120" align="right">
          <template #default="{ row }">
            -¥{{ formatMoney(row.deduction) }}
          </template>
        </el-table-column>
        <el-table-column prop="personalTax" label="个税" width="120" align="right">
          <template #default="{ row }">
            -¥{{ formatMoney(row.personalTax) }}
          </template>
        </el-table-column>
        <el-table-column prop="actualPay" label="实发工资" width="140" align="right" fixed="right">
          <template #default="{ row }">
            <span class="actual-salary">¥{{ formatMoney(row.actualPay) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)">
              {{ getStatusName(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :total="total"
        :page-sizes="[10, 20, 50, 100]"
        @change="handleQuery"
        layout="total, sizes, prev, pager, next, jumper"
        style="margin-top: 20px; justify-content: flex-end"
      />
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getSalaryRecords,
  type SalaryRecord
} from '@/api/self'

const loading = ref(false)
const recordList = ref<SalaryRecord[]>([])
const total = ref(0)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 12
})

function formatMoney(value: any) {
  if (!value && value !== 0) return '0.00'
  return Number(value).toFixed(2)
}

function getStatusName(status: number) {
  const map: Record<number, string> = {
    0: '草稿',
    1: '已确认',
    2: '已发放'
  }
  return map[status] || '未知'
}

function getStatusTagType(status: number) {
  const map: Record<number, string> = {
    0: 'info',
    1: 'warning',
    2: 'success'
  }
  return map[status] || ''
}

async function handleQuery() {
  loading.value = true
  try {
    const result = await getSalaryRecords(queryParams)
    recordList.value = result.records || []
    total.value = result.total || 0
  } catch (error) {
    ElMessage.error('获取薪酬记录失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  handleQuery()
})
</script>

<style scoped>
.self-salary {
  padding: 20px;
}

.salary-card {
  max-width: 1400px;
  margin: 0 auto;
}

.actual-salary {
  color: #67c23a;
  font-weight: bold;
  font-size: 16px;
}
</style>
