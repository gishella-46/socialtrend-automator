<template>
  <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
    <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Upload Content</h3>
    
    <form @submit.prevent="handleUpload" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Platform
        </label>
        <select
          v-model="formData.platform"
          required
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
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
          rows="4"
          @input="updatePreview"
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition resize-none"
          placeholder="Write your content here..."
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Media URL (optional)
        </label>
        <input
          v-model="formData.media_url"
          type="url"
          @input="updatePreview"
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
          placeholder="https://example.com/image.jpg"
        />
      </div>

      <div class="flex items-center space-x-2">
        <button
          type="button"
          @click="showPreviewModal = true"
          class="flex-1 px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 rounded-lg transition"
        >
          Preview
        </button>
        <button
          type="submit"
          :disabled="loading || !formData.platform || !formData.content"
          class="flex-1 px-4 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ loading ? 'Uploading...' : 'Upload' }}
        </button>
      </div>
    </form>

    <!-- Preview Modal -->
    <div
      v-if="showPreviewModal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 dark:bg-opacity-70"
      @click="showPreviewModal = false"
    >
      <div
        class="bg-white dark:bg-gray-800 rounded-xl shadow-xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto"
        @click.stop
      >
        <div class="p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-xl font-semibold text-gray-900 dark:text-white">Content Preview</h3>
            <button
              @click="showPreviewModal = false"
              class="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200"
            >
              <X class="w-6 h-6" />
            </button>
          </div>
          
          <div class="space-y-4">
            <div>
              <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Platform:</span>
              <span class="ml-2 px-2 py-1 text-sm rounded bg-indigo-100 dark:bg-indigo-900/30 text-indigo-800 dark:text-indigo-300 capitalize">
                {{ formData.platform }}
              </span>
            </div>
            
            <div v-if="formData.media_url" class="rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700">
              <img
                :src="formData.media_url"
                :alt="formData.content"
                class="w-full h-64 object-cover"
                @error="imageError = true"
              />
              <div v-if="imageError" class="flex items-center justify-center h-64 bg-gray-100 dark:bg-gray-700">
                <ImageOff class="w-12 h-12 text-gray-400" />
              </div>
            </div>
            
            <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
              <p class="text-gray-900 dark:text-white whitespace-pre-wrap">{{ formData.content }}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { X, ImageOff } from 'lucide-vue-next'
import api from '../utils/api'
import { useToast } from 'vue-toastification'

const toast = useToast()

const formData = ref({
  platform: '',
  content: '',
  media_url: ''
})

const loading = ref(false)
const showPreviewModal = ref(false)
const imageError = ref(false)

const emit = defineEmits(['uploaded'])

const updatePreview = () => {
  imageError.value = false
}

watch(() => formData.value.media_url, () => {
  imageError.value = false
})

const handleUpload = async () => {
  loading.value = true
  
  try {
    const payload = {
      platform: formData.value.platform,
      content: formData.value.content,
      media_urls: formData.value.media_url ? [formData.value.media_url] : []
    }

    await api.post('/api/upload', payload)
    
    toast.success('Content uploaded successfully!', {
      timeout: 3000
    })
    
    emit('uploaded')
    
    // Reset form
    formData.value = {
      platform: '',
      content: '',
      media_url: ''
    }
  } catch (error) {
    toast.error(error.response?.data?.detail || 'Failed to upload content', {
      timeout: 3000
    })
  } finally {
    loading.value = false
  }
}
</script>








