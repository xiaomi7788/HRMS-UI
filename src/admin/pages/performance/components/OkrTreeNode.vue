<template>
  <div class="okr-tree-node" :class="{ 'has-children': node.children && node.children.length > 0 }">
    <!-- 节点连接线 -->
    <div class="node-connector" v-if="level > 0">
      <div class="vertical-line"></div>
      <div class="horizontal-line" :class="{ 'last-child': isLast }"></div>
    </div>
    
    <!-- 节点内容 -->
    <div class="node-content">
      <!-- 节点头部 -->
      <div class="node-header">
        <div class="node-title-section">
          <div class="node-title">{{ node.title }}</div>
          <div class="node-subtitle">
            <span class="node-employee">{{ node.employeeName || '-' }}</span>
            <span class="node-period">• {{ node.period || '-' }}</span>
          </div>
        </div>
        
        <div class="node-badges">
          <el-tag 
            :type="getTypeTagType(node.objectiveType)" 
            size="small"
            class="type-badge"
          >
            {{ node.objectiveType }}
          </el-tag>
          <el-tag 
            :type="getPriorityTagType(node.priority)" 
            size="small"
            class="priority-badge"
          >
            {{ node.priority || '默认' }}
          </el-tag>
        </div>
      </div>
      
      <!-- 节点进度信息 -->
      <div class="node-progress-section">
        <div class="progress-info">
          <div class="progress-row">
            <span class="progress-label">进度</span>
            <div class="progress-bar-container">
              <el-progress
                :percentage="node.progressPercent || 0"
                :status="getProgressStatus(node.progressPercent)"
                :stroke-width="8"
                :show-text="false"
                class="progress-bar"
              />
              <span class="progress-text">{{ node.progressPercent || 0 }}%</span>
            </div>
          </div>
          
          <div class="progress-row">
            <span class="progress-label">权重</span>
            <span class="weight-text">{{ node.weight || 0 }}%</span>
          </div>
          
          <div v-if="node.targetValue" class="progress-row">
            <span class="progress-label">目标</span>
            <span class="target-text">{{ node.targetValue }}</span>
          </div>
        </div>
      </div>
      
      <!-- 节点操作 -->
      <div class="node-actions">
        <el-button link type="primary" size="small" @click.stop="$emit('edit', node)">
          编辑
        </el-button>
        <el-button link type="primary" size="small" @click.stop="$emit('update-progress', node)">
          更新进度
        </el-button>
        <el-button link type="primary" size="small" @click.stop="$emit('align', node)">
          对齐
        </el-button>
      </div>
    </div>
    
    <!-- 子节点 -->
    <div v-if="node.children && node.children.length > 0" class="node-children">
      <div 
        v-for="(child, childIndex) in node.children" 
        :key="child.id" 
        class="child-wrapper"
      >
        <OkrTreeNode 
          :node="child" 
          :level="level + 1"
          :is-last="childIndex === node.children.length - 1"
          @edit="$emit('edit', $event)"
          @update-progress="$emit('update-progress', $event)"
          @align="$emit('align', $event)"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { defineProps, defineEmits } from 'vue'
import type { PerfObjective } from '@/api/objective'

const props = defineProps<{
  node: PerfObjective
  level: number
  isLast: boolean
}>()

const emit = defineEmits<{
  edit: [node: PerfObjective]
  updateProgress: [node: PerfObjective]
  align: [node: PerfObjective]
}>()

// 目标类型标签颜色
const getTypeTagType = (type: string) => {
  const typeMap: Record<string, string> = {
    '公司级': 'danger',
    '部门级': 'warning',
    '个人级': 'success'
  }
  return typeMap[type] || ''
}

// 优先级标签颜色
const getPriorityTagType = (priority: string) => {
  const typeMap: Record<string, string> = {
    '高': 'danger',
    '中': 'warning',
    '低': 'success'
  }
  return typeMap[priority] || ''
}

// 进度状态
const getProgressStatus = (progress: number) => {
  if (progress >= 100) return 'success'
  if (progress >= 80) return 'warning'
  return 'exception'
}
</script>

<style scoped>
.okr-tree-node {
  position: relative;
  margin-bottom: 16px;
}

.node-connector {
  position: absolute;
  left: -16px;
  top: 0;
  width: 16px;
  height: 100%;
  z-index: 1;
}

.vertical-line {
  position: absolute;
  left: 50%;
  top: 0;
  width: 2px;
  height: 100%;
  background-color: #dcdfe6;
  transform: translateX(-50%);
}

.horizontal-line {
  position: absolute;
  left: 50%;
  top: 50%;
  width: 16px;
  height: 2px;
  background-color: #dcdfe6;
  transform: translateY(-50%);
}

.horizontal-line.last-child {
  height: 50%;
  top: 0;
  transform: none;
}

.node-content {
  position: relative;
  padding: 16px;
  background-color: white;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  z-index: 2;
}

.node-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.node-title-section {
  flex: 1;
  min-width: 0;
}

.node-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  line-height: 1.4;
  margin-bottom: 4px;
  word-break: break-word;
}

.node-subtitle {
  font-size: 13px;
  color: #909399;
  display: flex;
  align-items: center;
  gap: 8px;
}

.node-employee {
  color: #409eff;
  font-weight: 500;
}

.node-period {
  color: #909399;
}

.node-badges {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.type-badge,
.priority-badge {
  font-size: 12px;
}

.node-progress-section {
  margin-bottom: 12px;
}

.progress-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  padding: 12px;
  background-color: #f5f7fa;
  border-radius: 6px;
}

.progress-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-label {
  min-width: 40px;
  font-size: 13px;
  color: #606266;
  font-weight: 500;
}

.progress-bar-container {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
}

.progress-bar {
  flex: 1;
  min-width: 0;
}

.progress-text {
  min-width: 40px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  text-align: right;
}

.weight-text,
.target-text {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.node-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  padding-top: 12px;
  border-top: 1px solid #f0f0f0;
}

.node-children {
  position: relative;
  margin-left: 32px;
  margin-top: 16px;
}

.child-wrapper {
  position: relative;
}

.has-children .node-content {
  margin-bottom: 16px;
}

/* 层级样式 */
.okr-tree-node[level="0"] .node-content {
  background-color: #f0f9ff;
  border-color: #c6e2ff;
}

.okr-tree-node[level="1"] .node-content {
  background-color: #f0f9ff;
  border-color: #b3d8ff;
}

.okr-tree-node[level="2"] .node-content {
  background-color: #f0f9ff;
  border-color: #a0d0ff;
}

.okr-tree-node[level="3"] .node-content {
  background-color: #ecf5ff;
  border-color: #8dc9ff;
}

/* 悬停效果 */
.node-content:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px 0 rgba(0, 0, 0, 0.12);
  transition: all 0.3s ease;
}
</style>