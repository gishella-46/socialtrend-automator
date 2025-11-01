<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900">
    
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <motion
        :initial="{ opacity: 0, y: 20 }"
        :animate="{ opacity: 1, y: 0 }"
        :transition="{ duration: 0.5 }"
      >
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Upload Content</h1>
          <p class="text-gray-600 dark:text-gray-400">Share your content to social media platforms</p>
        </div>

        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
          <form @submit.prevent="handleUpload" class="space-y-6">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Platform
              </label>
              <select
                v-model="formData.platform"
                required
                class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
              >
                <option value="">Select platform</option>
                <option value="instagram">Instagram</option>
                <option value="linkedin">LinkedIn</option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Content
              </label>
              <textarea
                v-model="formData.content"
                required
                rows="6"
                class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition resize-none"
                placeholder="Write your post content here..."
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Media URLs (optional)
              </label>
              <input
                v-model="mediaUrl"
                type="url"
                @keyup.enter="addMediaUrl"
                class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition mb-2"
                placeholder="https://example.com/image.jpg"
              />
              <div v-if="formData.media_urls.length > 0" class="flex flex-wrap gap-2 mt-2">
                <span
                  v-for="(url, index) in formData.media_urls"
                  :key="index"
                  class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-indigo-100 dark:bg-indigo-900/30 text-indigo-800 dark:text-indigo-300"
                >
                  {{ url }}
                  <button
                    type="button"
                    @click="removeMediaUrl(index)"
                    class="ml-2 text-indigo-600 dark:text-indigo-400 hover:text-indigo-800 dark:hover:text-indigo-200"
                  >
                    ×
                  </button>
                </span>
              </div>
            </div>

            <div>
              <label class="flex items-center space-x-2">
                <input
                  v-model="formData.schedule"
                  type="checkbox"
                  class="w-4 h-4 text-indigo-600 rounded focus:ring-indigo-500"
                />
                <span class="text-sm text-gray-700 dark:text-gray-300">Schedule this post</span>
              </label>
              <input
                v-if="formData.schedule"
                v-model="formData.scheduled_at"
                type="datetime-local"
                class="mt-2 w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
              />
            </div>

            <button
              type="submit"
              :disabled="loading"
              class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ loading ? 'Uploading...' : 'Upload Content' }}
            </button>

            <div v-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3 text-red-700 dark:text-red-400 text-sm">
              {{ error }}
            </div>

            <div v-if="success" class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-3 text-green-700 dark:text-green-400 text-sm">
              Content uploaded successfully!
            </div>
          </form>
        </div>
      </motion>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Motion } from '@motionone/vue'
import api from '../utils/api'

const formData = ref({
  platform: '',
  content: '',
  media_urls: [],
  schedule: false,
  scheduled_at: ''
})

const mediaUrl = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

const addMediaUrl = () => {
  if (mediaUrl.value && !formData.value.media_urls.includes(mediaUrl.value)) {
    formData.value.media_urls.push(mediaUrl.value)
    mediaUrl.value = ''
  }
}

const removeMediaUrl = (index) => {
  formData.value.media_urls.splice(index, 1)
}

const handleUpload = async () => {
  loading.value = true
  error.value = ''
  success.value = false

  try {
    const payload = {
      platform: formData.value.platform,
      content: formData.value.content,
      media_urls: formData.value.media_urls
    }

    if (formData.value.schedule && formData.value.scheduled_at) {
      payload.scheduled_at = formData.value.scheduled_at
    }

    await api.post('/api/upload', payload)
    success.value = true
    
    // Reset form
    formData.value = {
      platform: '',
      content: '',
      media_urls: [],
      schedule: false,
      scheduled_at: ''
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Upload failed'
  } finally {
    loading.value = false
  }
}
</script>

