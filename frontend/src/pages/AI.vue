<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion
        :initial="{ opacity: 0, y: 20 }"
        :animate="{ opacity: 1, y: 0 }"
        :transition="{ duration: 0.5 }"
      >
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">AI Caption Generator</h1>
          <p class="text-gray-600 dark:text-gray-400">Generate engaging captions and hashtags with AI</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Input Form -->
          <motion
            :initial="{ opacity: 0, x: -20 }"
            :animate="{ opacity: 1, x: 0 }"
            :transition="{ duration: 0.5 }"
            class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700"
          >
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Generate Caption</h2>
            
            <form @submit.prevent="generateCaption" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Topic
                </label>
                <input
                  v-model="formData.topic"
                  type="text"
                  required
                  class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                  placeholder="e.g., Technology trends"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Style
                </label>
                <select
                  v-model="formData.style"
                  class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                >
                  <option value="professional">Professional</option>
                  <option value="casual">Casual</option>
                  <option value="creative">Creative</option>
                </select>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Trending Keywords (optional)
                </label>
                <input
                  v-model="trendInput"
                  type="text"
                  @keyup.enter="addTrend"
                  class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-purple-500 focus:border-transparent transition mb-2"
                  placeholder="Press Enter to add keyword"
                />
                <div v-if="formData.trend.length > 0" class="flex flex-wrap gap-2">
                  <span
                    v-for="(trend, index) in formData.trend"
                    :key="index"
                    class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300"
                  >
                    {{ trend }}
                    <button
                      type="button"
                      @click="removeTrend(index)"
                      class="ml-2 text-purple-600 dark:text-purple-400 hover:text-purple-800 dark:hover:text-purple-200"
                    >
                      ×
                    </button>
                  </span>
                </div>
              </div>

              <button
                type="submit"
                :disabled="loading"
                class="w-full bg-purple-600 hover:bg-purple-700 text-white font-semibold py-3 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {{ loading ? 'Generating...' : 'Generate Caption' }}
              </button>

              <div v-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3 text-red-700 dark:text-red-400 text-sm">
                {{ error }}
              </div>
            </form>
          </motion>

          <!-- Output -->
          <motion
            :initial="{ opacity: 0, x: 20 }"
            :animate="{ opacity: 1, x: 0 }"
            :transition="{ duration: 0.5 }"
            class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700"
          >
            <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Generated Content</h2>
            
            <div v-if="result" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Caption
                </label>
                <textarea
                  :value="result.caption"
                  readonly
                  rows="6"
                  class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-gray-50 dark:bg-gray-700/50 text-gray-900 dark:text-white resize-none"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Hashtags
                </label>
                <div class="flex flex-wrap gap-2">
                  <span
                    v-for="(hashtag, index) in result.hashtags"
                    :key="index"
                    class="px-3 py-1 rounded-full text-sm bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300"
                  >
                    {{ hashtag }}
                  </span>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                  Recommended Post Time
                </label>
                <div class="px-4 py-3 rounded-lg bg-indigo-50 dark:bg-indigo-900/20 border border-indigo-200 dark:border-indigo-800">
                  <span class="text-indigo-700 dark:text-indigo-400 font-semibold">{{ result.recommended_time }}</span>
                </div>
              </div>

              <button
                @click="copyToClipboard"
                class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 rounded-lg transition"
              >
                Copy to Clipboard
              </button>
            </div>

            <div v-else class="text-center py-12 text-gray-500 dark:text-gray-400">
              <Sparkles class="w-16 h-16 mx-auto mb-4 opacity-50" />
              <p>Generated content will appear here</p>
            </div>
          </motion>
        </div>
      </motion>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Motion } from '@motionone/vue'
import { Sparkles } from 'lucide-vue-next'
import api from '../utils/api'

const formData = ref({
  topic: '',
  style: 'professional',
  trend: []
})

const trendInput = ref('')
const loading = ref(false)
const error = ref('')
const result = ref(null)

const addTrend = () => {
  if (trendInput.value && !formData.value.trend.includes(trendInput.value)) {
    formData.value.trend.push(trendInput.value)
    trendInput.value = ''
  }
}

const removeTrend = (index) => {
  formData.value.trend.splice(index, 1)
}

const generateCaption = async () => {
  loading.value = true
  error.value = ''
  result.value = null

  try {
    const response = await api.post('/api/ai/caption', {
      topic: formData.value.topic,
      style: formData.value.style,
      trend: formData.value.trend
    })
    result.value = response.data
    // Store in localStorage for Dashboard
    localStorage.setItem('aiResult', JSON.stringify(response.data))
  } catch (err) {
    error.value = err.response?.data?.detail || 'Failed to generate caption'
  } finally {
    loading.value = false
  }
}

const copyToClipboard = async () => {
  if (result.value) {
    const text = `${result.value.caption}\n\n${result.value.hashtags.join(' ')}`
    await navigator.clipboard.writeText(text)
    alert('Copied to clipboard!')
  }
}
</script>

