<template>
  <el-select
    v-model="selectedValue"
    v-bind="$attrs"
    :loading="loading"
    :remote="remote"
    :remote-method="remoteSearch"
    :filterable="true"
    clearable
    placeholder="请选择员工"
    @change="handleChange"
  >
    <el-option
      v-for="item in employeeList"
      :key="item.id"
      :label="item.empName"
      :value="item.id"
    >
      <span style="float: left">{{ item.empName }}</span>
      <span style="float: right; color: #8492a6; font-size: 12px">
        {{ item.empCode }} | {{ item.deptName || '无部门' }}
      </span>
    </el-option>
  </el-select>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { getEmployeePage, type Employee } from '@/api/employee'

const props = defineProps<{
  modelValue?: number
  remote?: boolean
  deptId?: number
}>()

const emit = defineEmits<{
  'update:modelValue': [value?: number]
  'change': [value?: number, employee?: Employee]
}>()

const selectedValue = ref<number>()
const employeeList = ref<Employee[]>([])
const loading = ref(false)

// 监听modelValue变化
watch(() => props.modelValue, (val) => {
  selectedValue.value = val
}, { immediate: true })

// 监听部门ID变化
watch(() => props.deptId, () => {
  if (!props.remote) {
    loadEmployees()
  }
}, { immediate: true })

// 远程搜索方法
const remoteSearch = async (query?: string) => {
  if (!query) {
    employeeList.value = []
    return
  }
  
  loading.value = true
  try {
    const res = await getEmployeePage({
      pageNum: 1,
      pageSize: 20,
      keyword: query,
      deptId: props.deptId
    })
    employeeList.value = res.records || []
  } catch (error) {
    console.error('搜索员工失败:', error)
  } finally {
    loading.value = false
  }
}

// 加载员工列表
const loadEmployees = async () => {
  loading.value = true
  try {
    const res = await getEmployeePage({
      pageNum: 1,
      pageSize: 100,
      deptId: props.deptId
    })
    employeeList.value = res.records || []
  } catch (error) {
    console.error('加载员工列表失败:', error)
  } finally {
    loading.value = false
  }
}

// 处理选择变化
const handleChange = (value?: number) => {
  emit('update:modelValue', value)
  if (value) {
    const selectedEmployee = employeeList.value.find(emp => emp.id === value)
    emit('change', value, selectedEmployee)
  } else {
    emit('change', undefined, undefined)
  }
}

// 初始化加载
onMounted(() => {
  if (!props.remote) {
    loadEmployees()
  }
})

// 显式默认导出（虽然<script setup>会自动导出，但有助于TypeScript识别）
defineExpose({})
</script>