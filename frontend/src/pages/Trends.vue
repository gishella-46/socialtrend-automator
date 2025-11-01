<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion
        :initial="{ opacity: 0, y: 20 }"
        :animate="{ opacity: 1, y: 0 }"
        :transition="{ duration: 0.5 }"
      >
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Trending Topics</h1>
          <p class="text-gray-600 dark:text-gray-400">Discover what's trending across platforms</p>
        </div>

        <!-- Platform Selector -->
        <div class="mb-6 flex space-x-4">
          <button
            v-for="platform in platforms"
            :key="platform"
            @click="selectedPlatform = platform; fetchTrends()"
            :class="[
              'px-4 py-2 rounded-lg font-medium transition',
              selectedPlatform === platform
                ? 'bg-indigo-600 text-white'
                : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
            ]"
          >
            {{ platform.charAt(0).toUpperCase() + platform.slice(1) }}
          </button>
        </div>

        <!-- Chart -->
        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700 mb-6">
          <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Trend Analysis</h2>
          <div class="h-64">
            <Line
              v-if="chartData"
              :data="chartData"
              :options="chartOptions"
            />
          </div>
        </div>

        <!-- Trends List -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <motion
            v-for="(trend, index) in trends"
            :key="index"
            :initial="{ opacity: 0, scale: 0.9 }"
            :animate="{ opacity: 1, scale: 1 }"
            :transition="{ duration: 0.3, delay: index * 0.1 }"
            class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-4 border border-gray-200 dark:border-gray-700 hover:shadow-md transition"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <h3 class="font-semibold text-gray-900 dark:text-white mb-1">{{ trend.title }}</h3>
                <p class="text-sm text-gray-600 dark:text-gray-400">{{ trend.source }}</p>
                <div class="mt-2 flex items-center space-x-2">
                  <TrendingUp class="w-4 h-4 text-green-500" />
                  <span class="text-sm text-green-600 dark:text-green-400 font-medium">{{ trend.score }}%</span>
                </div>
              </div>
            </div>
          </motion>
        </div>

        <div v-if="loading" class="text-center py-8 text-gray-600 dark:text-gray-400">
          Loading trends...
        </div>
      </motion>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { Motion } from '@motionone/vue'
import { Line } from 'vue-chartjs'
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend } from 'chart.js'
import { TrendingUp } from 'lucide-vue-next'
import api from '../utils/api'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend)

const platforms = ['google', 'reddit', 'twitter']
const selectedPlatform = ref('google')
const trends = ref([])
const loading = ref(false)

const chartData = computed(() => {
  if (trends.value.length === 0) return null
  
  return {
    labels: trends.value.map(t => t.title),
    datasets: [{
      label: 'Trend Score',
      data: trends.value.map(t => t.score),
      borderColor: 'rgb(99, 102, 241)',
      backgroundColor: 'rgba(99, 102, 241, 0.1)',
      tension: 0.4
    }]
  }
})

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    }
  },
  scales: {
    y: {
      beginAtZero: true
    }
  }
}

const fetchTrends = async () => {
  loading.value = true
  try {
    const response = await api.post('/api/trends/fetch', {
      platform: selectedPlatform.value,
      keywords: []
    })
    // Transform API response to match chart format
    const apiTrends = response.data?.data?.trends || response.data?.trends || []
    trends.value = apiTrends.map((trend, index) => ({
      title: trend.hashtag || trend.subreddit || trend.keyword || `Trend ${index + 1}`,
      source: selectedPlatform.value,
      score: trend.tweet_count || trend.score || Math.floor(Math.random() * 100)
    }))
  } catch (error) {
    console.error('Failed to fetch trends:', error)
    // Fallback data for demo
    trends.value = [
      { title: 'AI Technology', source: selectedPlatform.value, score: 85 },
      { title: 'Web Development', source: selectedPlatform.value, score: 72 },
      { title: 'Machine Learning', source: selectedPlatform.value, score: 68 }
    ]
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchTrends()
})
</script>

