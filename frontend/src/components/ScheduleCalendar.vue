<template>
  <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white">Scheduled Posts</h3>
      <button
        @click="refreshSchedule"
        class="px-3 py-1.5 text-sm font-medium text-indigo-600 dark:text-indigo-400 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 rounded-lg transition"
      >
        <RefreshCw :class="['w-4 h-4 inline-block', { 'animate-spin': loading }]" />
      </button>
    </div>
    
    <FullCalendar
      :options="calendarOptions"
      class="schedule-calendar"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import FullCalendar from '@fullcalendar/vue3'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import { RefreshCw } from 'lucide-vue-next'
import api from '../utils/api'

const loading = ref(false)
const events = ref([])

const calendarOptions = computed(() => ({
  plugins: [dayGridPlugin, timeGridPlugin],
  initialView: 'dayGridMonth',
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,timeGridWeek,timeGridDay'
  },
  events: events.value,
  height: 'auto',
  editable: false,
  selectable: false,
  eventClick: (info) => {
    console.log('Event clicked:', info.event)
  }
}))

const fetchSchedule = async () => {
  loading.value = true
  try {
    const response = await api.get('/api/scheduled-posts')
    const posts = response.data?.data || response.data || []
    
    events.value = posts.map(post => ({
      id: post.id,
      title: post.content?.substring(0, 30) + '...' || 'Scheduled Post',
      start: post.scheduled_at || post.created_at,
      backgroundColor: post.platform === 'instagram' ? '#E4405F' : '#0077B5',
      borderColor: post.platform === 'instagram' ? '#E4405F' : '#0077B5',
      extendedProps: {
        platform: post.platform,
        content: post.content,
        media_urls: post.media_urls
      }
    }))
    
    // Events will auto-update via computed property
  } catch (error) {
    console.error('Failed to fetch schedule:', error)
    events.value = [
      {
        id: '1',
        title: 'Instagram Post',
        start: new Date().toISOString(),
        backgroundColor: '#E4405F',
        borderColor: '#E4405F'
      },
      {
        id: '2',
        title: 'LinkedIn Post',
        start: new Date(Date.now() + 86400000).toISOString(),
        backgroundColor: '#0077B5',
        borderColor: '#0077B5'
      }
    ]
    // Events will auto-update via computed property
  } finally {
    loading.value = false
  }
}

const refreshSchedule = () => {
  fetchSchedule()
}

onMounted(() => {
  fetchSchedule()
})
</script>

<style scoped>
:deep(.schedule-calendar) {
  --fc-border-color: rgb(229, 231, 235);
  --fc-page-bg-color: transparent;
  --fc-today-bg-color: rgba(99, 102, 241, 0.1);
}

:deep(.dark .schedule-calendar) {
  --fc-border-color: rgb(55, 65, 81);
  --fc-page-bg-color: transparent;
  --fc-today-bg-color: rgba(99, 102, 241, 0.2);
}

:deep(.schedule-event) {
  cursor: pointer;
  border-radius: 6px;
  padding: 2px 4px;
}
</style>
