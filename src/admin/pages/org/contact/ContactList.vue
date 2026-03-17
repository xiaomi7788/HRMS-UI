<template>
  <div class="contact-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">通讯录</span>
        </div>
      </template>

      <el-form :inline="true" :model="queryParams" class="search-form">
        <el-form-item label="部门">
          <el-select v-model="queryParams.deptId" placeholder="选择部门" clearable style="width: 200px">
            <el-option
              v-for="dept in deptList"
              :key="dept.id"
              :label="dept.deptName"
              :value="dept.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="关键字">
          <el-input
            v-model="queryParams.keyword"
            placeholder="姓名/工号/手机号"
            clearable
            style="width: 200px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>

      <el-table :data="tableData" stripe v-loading="loading">
        <el-table-column prop="empCode" label="工号" width="120" />
        <el-table-column prop="empName" label="姓名" width="100" />
        <el-table-column label="性别" width="80">
          <template #default="{ row }">
            {{ row.gender === 1 ? '男' : row.gender === 2 ? '女' : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="deptName" label="部门" width="150" />
        <el-table-column prop="positionName" label="岗位" width="150" />
        <el-table-column prop="phone" label="手机号" width="130" />
        <el-table-column prop="email" label="邮箱" min-width="180" show-overflow-tooltip />
        <el-table-column prop="entryDate" label="入职日期" width="120" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.workStatus === 2 ? 'success' : 'info'">
              {{ row.workStatus === 2 ? '在职' : '离职' }}
            </el-tag>
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
import { getDirectory, type EmployeeVO, type DirectoryParams } from '@/api/contact'
import { getDeptTree, type Department } from '@/api/dept'

const loading = ref(false)
const tableData = ref<EmployeeVO[]>([])
const total = ref(0)
const deptList = ref<Department[]>([])

const queryParams = reactive<DirectoryParams>({
  pageNum: 1,
  pageSize: 20,
  deptId: undefined,
  keyword: ''
})

const loadDeptList = async () => {
  try {
    const data = await getDeptTree()
    deptList.value = flattenDeptTree(data)
  } catch (error) {
    console.error('加载部门列表失败:', error)
  }
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

const loadData = async () => {
  loading.value = true
  try {
    const data = await getDirectory(queryParams)
    tableData.value = data.records
    total.value = Number(data.total)
  } catch (error) {
    console.error('加载通讯录失败:', error)
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
  queryParams.keyword = ''
  queryParams.pageNum = 1
  loadData()
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
.contact-container {
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
