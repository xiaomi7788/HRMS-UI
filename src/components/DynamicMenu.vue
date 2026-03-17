<template>
  <template v-for="menu in menus" :key="menu.id">
    <!-- 有子菜单的 -->
    <el-sub-menu v-if="menu.children && menu.children.length > 0" :index="String(menu.id)">
      <template #title>
        <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
        <span>{{ menu.title }}</span>
      </template>
      <!-- 递归渲染子菜单 -->
      <DynamicMenu :menus="menu.children" />
    </el-sub-menu>
    <!-- 没有子菜单的 -->
    <el-menu-item v-else :index="menu.path">
      <el-icon><component :is="getIcon(menu.icon)" /></el-icon>
      <span>{{ menu.title }}</span>
    </el-menu-item>
  </template>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

interface MenuItem {
  id: number
  parentId: number | null
  title: string
  path: string
  icon?: string
  children?: MenuItem[]
}

defineProps<{
  menus: MenuItem[]
}>()

// 获取图标组件
function getIcon(iconName?: string) {
  if (!iconName) return 'Folder'
  // 如果图标名称存在，尝试返回对应的图标组件
  const iconMap: Record<string, any> = {
    'House': ref(ElementPlusIconsVue.House).value,
    'User': ref(ElementPlusIconsVue.User).value,
    'Setting': ref(ElementPlusIconsVue.Setting).value,
    'Document': ref(ElementPlusIconsVue.Document).value,
    'Folder': ref(ElementPlusIconsVue.Folder).value,
    'FolderOpened': ref(ElementPlusIconsVue.FolderOpened).value,
    'Files': ref(ElementPlusIconsVue.Files).value,
    'List': ref(ElementPlusIconsVue.List).value,
    'Grid': ref(ElementPlusIconsVue.Grid).value,
    'Menu': ref(ElementPlusIconsVue.Menu).value,
    'Search': ref(ElementPlusIconsVue.Search).value,
    'Bell': ref(ElementPlusIconsVue.Bell).value,
    'Message': ref(ElementPlusIconsVue.Message).value,
    'Star': ref(ElementPlusIconsVue.Star).value,
    'StarFilled': ref(ElementPlusIconsVue.StarFilled).value,
    'Clock': ref(ElementPlusIconsVue.Clock).value,
    'Calendar': ref(ElementPlusIconsVue.Calendar).value,
    'Money': ref(ElementPlusIconsVue.Money).value,
    'Wallet': ref(ElementPlusIconsVue.Wallet).value,
    'TrendCharts': ref(ElementPlusIconsVue.TrendCharts).value,
    'DataLine': ref(ElementPlusIconsVue.DataLine).value,
    'PieChart': ref(ElementPlusIconsVue.PieChart).value,
    'Histogram': ref(ElementPlusIconsVue.Histogram).value,
    'Management': ref(ElementPlusIconsVue.Management).value,
    'Tools': ref(ElementPlusIconsVue.Tools).value,
    'Brush': ref(ElementPlusIconsVue.Brush).value,
    'Lock': ref(ElementPlusIconsVue.Lock).value,
    'Key': ref(ElementPlusIconsVue.Key).value,
    'Medal': ref(ElementPlusIconsVue.Medal).value,
    'Trophy': ref(ElementPlusIconsVue.Trophy).value,
    'Briefcase': ref(ElementPlusIconsVue.Briefcase).value,
    'School': ref(ElementPlusIconsVue.School).value,
    'Reading': ref(ElementPlusIconsVue.Reading).value,
    'Film': ref(ElementPlusIconsVue.Film).value,
    'Camera': ref(ElementPlusIconsVue.Camera).value,
    'Picture': ref(ElementPlusIconsVue.Picture).value,
    'Upload': ref(ElementPlusIconsVue.Upload).value,
    'Download': ref(ElementPlusIconsVue.Download).value,
    'Link': ref(ElementPlusIconsVue.Link).value,
    'Phone': ref(ElementPlusIconsVue.Phone).value,
    'MessageBox': ref(ElementPlusIconsVue.MessageBox).value,
    'Postcard': ref(ElementPlusIconsVue.Postcard).value,
    'OfficeBuilding': ref(ElementPlusIconsVue.OfficeBuilding).value,
    'HomeFilled': ref(ElementPlusIconsVue.HomeFilled).value,
    'UserFilled': ref(ElementPlusIconsVue.UserFilled).value,
    'MoreFilled': ref(ElementPlusIconsVue.MoreFilled).value,
    'Cherry': ref(ElementPlusIconsVue.Cherry).value,
    'Food': ref(ElementPlusIconsVue.Food).value,
    'Present': ref(ElementPlusIconsVue.Present).value,
    'Sunrise': ref(ElementPlusIconsVue.Sunrise).value,
    'Sunset': ref(ElementPlusIconsVue.Sunset).value,
    'Cloudy': ref(ElementPlusIconsVue.Cloudy).value,
    'Sunny': ref(ElementPlusIconsVue.Sunny).value,
    'Moon': ref(ElementPlusIconsVue.Moon).value,
    'Ticket': ref(ElementPlusIconsVue.Ticket).value,
    'Flag': ref(ElementPlusIconsVue.Flag).value,
    'Location': ref(ElementPlusIconsVue.Location).value,
    'Aim': ref(ElementPlusIconsVue.Aim).value,
    'Promotion': ref(ElementPlusIconsVue.Promotion).value,
    'Pointer': ref(ElementPlusIconsVue.Pointer).value,
    'MagicStick': ref(ElementPlusIconsVue.MagicStick).value,
    'Headset': ref(ElementPlusIconsVue.Headset).value,
    'Microphone': ref(ElementPlusIconsVue.Microphone).value,
    'Coffee': ref(ElementPlusIconsVue.Coffee).value,
    'GobletFull': ref(ElementPlusIconsVue.GobletFull).value,
    'Watermelon': ref(ElementPlusIconsVue.Watermelon).value,
    'Grape': ref(ElementPlusIconsVue.Grape).value,
    'Apple': ref(ElementPlusIconsVue.Apple).value,
    'Orange': ref(ElementPlusIconsVue.Orange).value,
  }
  return iconMap[iconName] || ref(ElementPlusIconsVue.Folder).value
}
</script>
