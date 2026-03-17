<template>
  <div class="human-resource-structure-analysis-container">
    <el-card class="box-card">
      <template #header>
        <div class="card-header">
          <span>人力结构分析</span>
        </div>
      </template>

      <el-row :gutter="20" style="margin-bottom: 20px;">
        <el-col :span="12">
          <el-card shadow="hover">
            <div id="gender-distribution-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
        <el-col :span="12">
          <el-card shadow="hover">
            <div id="age-distribution-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="24">
          <el-card shadow="hover">
            <div id="education-distribution-chart" style="height: 300px;"></div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import * as echarts from 'echarts';

onMounted(() => {
  initGenderDistributionChart();
  initAgeDistributionChart();
  initEducationDistributionChart();
});

const initGenderDistributionChart = () => {
  const chartDom = document.getElementById('gender-distribution-chart');
  if (chartDom) {
    const myChart = echarts.init(chartDom);
    const option = {
      title: {
        text: '性别分布',
        left: 'center'
      },
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left'
      },
      series: [
        {
          name: '性别分布',
          type: 'pie',
          radius: '50%',
          data: [
            { value: 1048, name: '男' },
            { value: 735, name: '女' }
          ],
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    };
    myChart.setOption(option);
  }
};

const initAgeDistributionChart = () => {
  const chartDom = document.getElementById('age-distribution-chart');
  if (chartDom) {
    const myChart = echarts.init(chartDom);
    const option = {
      title: {
        text: '年龄分布',
        left: 'center'
      },
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow'
        }
      },
      xAxis: {
        type: 'category',
        data: ['20-25', '26-30', '31-35', '36-40', '41-45', '45+']
      },
      yAxis: {
        type: 'value'
      },
      series: [
        {
          name: '人数',
          type: 'bar',
          data: [120, 200, 150, 80, 70, 110],
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)'
            }
          }
        }
      ]
    };
    myChart.setOption(option);
  }
};

const initEducationDistributionChart = () => {
  const chartDom = document.getElementById('education-distribution-chart');
  if (chartDom) {
    const myChart = echarts.init(chartDom);
    const option = {
      title: {
        text: '学历分布',
        left: 'center'
      },
      tooltip: {
        trigger: 'item'
      },
      legend: {
        orient: 'vertical',
        left: 'left'
      },
      series: [
        {
          name: '学历分布',
          type: 'pie',
          radius: ['40%', '70%'],
          avoidLabelOverlap: false,
          itemStyle: {
            borderRadius: 10,
            borderColor: '#fff',
            borderWidth: 2
          },
          label: {
            show: false,
            position: 'center'
          },
          emphasis: {
            label: {
              show: true,
              fontSize: 20,
              fontWeight: 'bold'
            }
          },
          labelLine: {
            show: false
          },
          data: [
            { value: 335, name: '大专' },
            { value: 310, name: '本科' },
            { value: 234, name: '硕士' },
            { value: 135, name: '博士' },
            { value: 1548, name: '其他' }
          ]
        }
      ]
    };
    myChart.setOption(option);
  }
};
</script>

<style scoped>
.human-resource-structure-analysis-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
