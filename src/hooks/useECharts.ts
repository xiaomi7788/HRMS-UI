import { ref, onMounted, onUnmounted, type Ref } from 'vue'
import * as echarts from 'echarts/core'
import {
  BarChart,
  LineChart,
  PieChart,
  RadarChart,
} from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  DataZoomComponent,
  ToolboxComponent,
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import type { ECharts, EChartsCoreOption } from 'echarts/core'

// 按需注册 ECharts 模块（减少打包体积）
echarts.use([
  BarChart,
  LineChart,
  PieChart,
  RadarChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  DataZoomComponent,
  ToolboxComponent,
  CanvasRenderer,
])

/**
 * ECharts Hook - 自动处理初始化、resize 和销毁
 * @param domRef 图表容器的 DOM ref
 * @param theme 主题（可选，默认 'light'）
 */
export function useECharts(domRef: Ref<HTMLElement | null>, theme?: string | object) {
  const chartInstance = ref<ECharts | null>(null)
  let resizeObserver: ResizeObserver | null = null

  // 初始化图表
  function initChart() {
    if (!domRef.value) return
    chartInstance.value = echarts.init(domRef.value, theme || null)
    // 监听容器尺寸变化自动 resize
    resizeObserver = new ResizeObserver(() => {
      chartInstance.value?.resize()
    })
    resizeObserver.observe(domRef.value)
  }

  // 设置图表配置
  function setOption(option: EChartsCoreOption, notMerge = false) {
    if (!chartInstance.value) {
      initChart()
    }
    chartInstance.value?.setOption(option, notMerge)
  }

  // 显示加载动画
  function showLoading() {
    chartInstance.value?.showLoading()
  }

  // 隐藏加载动画
  function hideLoading() {
    chartInstance.value?.hideLoading()
  }

  // 手动触发 resize
  function resize() {
    chartInstance.value?.resize()
  }

  onMounted(() => {
    initChart()
  })

  onUnmounted(() => {
    resizeObserver?.disconnect()
    chartInstance.value?.dispose()
    chartInstance.value = null
  })

  return {
    chartInstance,
    setOption,
    showLoading,
    hideLoading,
    resize,
  }
}

// 导出 echarts 实例，供外部直接使用
export { echarts }
