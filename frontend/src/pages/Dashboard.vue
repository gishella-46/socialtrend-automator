<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion
        :initial="{ opacity: 0, y: 20 }"
        :animate="{ opacity: 1, y: 0 }"
        :transition="{ duration: 0.5 }"
      >
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Dashboard</h1>
          <p class="text-gray-600 dark:text-gray-400">Overview of your social media activities</p>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <motion
            v-for="(stat, index) in stats"
            :key="index"
            :initial="{ opacity: 0, y: 20 }"
            :animate="{ opacity: 1, y: 0 }"
            :transition="{ duration: 0.5, delay: index * 0.1 }"
            class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700"
          >
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-600 dark:text-gray-400">{{ stat.label }}</p>
                <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1">{{ stat.value }}</p>
                <p class="text-xs text-green-600 dark:text-green-400 mt-1">{{ stat.change }}</p>
              </div>
              <component :is="stat.icon" :class="['w-8 h-8', stat.color]" />
            </div>
          </motion>
        </div>

        <!-- Main Content Grid -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <!-- Upload Card -->
          <motion
            :initial="{ opacity: 0, x: -20 }"
            :animate="{ opacity: 1, x: 0 }"
            :transition="{ duration: 0.5 }"
          >
            <UploadCard @uploaded="handleUploadSuccess" />
          </motion>

          <!-- AI Result Card -->
          <motion
            :initial="{ opacity: 0, x: 20 }"
            :animate="{ opacity: 1, x: 0 }"
            :transition="{ duration: 0.5 }"
          >
            <AIResultCard :result="aiResult" />
          </motion>
        </div>

        <!-- Trend Chart -->
        <motion
          :initial="{ opacity: 0, y: 20 }"
          :animate="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, delay: 0.2 }"
          class="mb-6"
        >
          <TrendChart />
        </motion>

        <!-- Schedule Calendar -->
        <motion
          :initial="{ opacity: 0, y: 20 }"
          :animate="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, delay: 0.3 }"
        >
          <ScheduleCalendar />
        </motion>

        <!-- Quick Actions -->
        <motion
          :initial="{ opacity: 0, y: 20 }"
          :animate="{ opacity: 1, y: 0 }"
          :transition="{ duration: 0.5, delay: 0.4 }"
          class="mt-6 bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700"
        >
          <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Quick Actions</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <router-link
              to="/upload"
              class="flex items-center justify-between p-4 rounded-lg bg-indigo-50 dark:bg-indigo-900/20 hover:bg-indigo-100 dark:hover:bg-indigo-900/30 transition"
            >
              <span class="text-indigo-700 dark:text-indigo-400 font-medium">Upload Content</span>
              <Upload class="w-5 h-5 text-indigo-600 dark:text-indigo-400" />
            </router-link>
            <router-link
              to="/ai"
              class="flex items-center justify-between p-4 rounded-lg bg-purple-50 dark:bg-purple-900/20 hover:bg-purple-100 dark:hover:bg-purple-900/30 transition"
            >
              <span class="text-purple-700 dark:text-purple-400 font-medium">Generate AI Caption</span>
              <Sparkles class="w-5 h-5 text-purple-600 dark:text-purple-400" />
            </router-link>
            <router-link
              to="/trends"
              class="flex items-center justify-between p-4 rounded-lg bg-green-50 dark:bg-green-900/20 hover:bg-green-100 dark:hover:bg-green-900/30 transition"
            >
              <span class="text-green-700 dark:text-green-400 font-medium">View Trends</span>
              <TrendingUp class="w-5 h-5 text-green-600 dark:text-green-400" />
            </router-link>
          </div>
        </motion>
      </motion>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Motion } from '@motionone/vue'
import { Upload, Sparkles, TrendingUp, BarChart3, Calendar, Users, Eye } from 'lucide-vue-next'
import UploadCard from '../components/UploadCard.vue'
import AIResultCard from '../components/AIResultCard.vue'
import TrendChart from '../components/TrendChart.vue'
import ScheduleCalendar from '../components/ScheduleCalendar.vue'
import { useToast } from 'vue-toastification'
import api from '../utils/api'

const toast = useToast()

const stats = ref([
  { label: 'Total Posts', value: '24', change: '+12%', icon: BarChart3, color: 'text-blue-600 dark:text-blue-400' },
  { label: 'Scheduled', value: '8', change: '+3', icon: Calendar, color: 'text-purple-600 dark:text-purple-400' },
  { label: 'Followers', value: '1.2K', change: '+8%', icon: Users, color: 'text-green-600 dark:text-green-400' },
  { label: 'Views', value: '5.4K', change: '+15%', icon: Eye, color: 'text-orange-600 dark:text-orange-400' }
])

const aiResult = ref(null)

const fetchStats = async () => {
  try {
    // Fetch from Laravel API
    const response = await api.get('/api/dashboard/stats')
    if (response.data?.data) {
      const data = response.data.data
      stats.value = [
        { label: 'Total Posts', value: data.total_posts || '24', change: '+12%', icon: BarChart3, color: 'text-blue-600 dark:text-blue-400' },
        { label: 'Scheduled', value: data.scheduled || '8', change: '+3', icon: Calendar, color: 'text-purple-600 dark:text-purple-400' },
        { label: 'Followers', value: data.followers || '1.2K', change: '+8%', icon: Users, color: 'text-green-600 dark:text-green-400' },
        { label: 'Views', value: data.views || '5.4K', change: '+15%', icon: Eye, color: 'text-orange-600 dark:text-orange-400' }
      ]
    }
  } catch (error) {
    console.error('Failed to fetch stats:', error)
    // Use default stats
  }
}

const handleUploadSuccess = () => {
  fetchStats()
  toast.success('Content uploaded successfully!', {
    timeout: 3000
  })
}

// Load AI result from localStorage if available
const loadAIResult = () => {
  const stored = localStorage.getItem('aiResult')
  if (stored) {
    try {
      aiResult.value = JSON.parse(stored)
    } catch (e) {
      console.error('Failed to parse AI result:', e)
    }
  }
}

// Listen for AI result updates from AI page
window.addEventListener('storage', (e) => {
  if (e.key === 'aiResult') {
    loadAIResult()
  }
})

onMounted(() => {
  fetchStats()
  loadAIResult()
})
</script>
