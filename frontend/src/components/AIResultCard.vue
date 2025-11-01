<template>
  <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm p-6 border border-gray-200 dark:border-gray-700">
    <div class="flex items-center justify-between mb-4">
      <h3 class="text-lg font-semibold text-gray-900 dark:text-white">AI Generated Caption</h3>
      <Sparkles class="w-5 h-5 text-purple-600 dark:text-purple-400" />
    </div>

    <div v-if="result" class="space-y-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Caption
        </label>
        <div class="p-4 bg-gray-50 dark:bg-gray-700/50 rounded-lg">
          <p class="text-gray-900 dark:text-white whitespace-pre-wrap">{{ result.caption }}</p>
        </div>
        <button
          @click="copyText(result.caption)"
          class="mt-2 text-sm text-indigo-600 dark:text-indigo-400 hover:underline"
        >
          Copy Caption
        </button>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Hashtags
        </label>
        <div class="flex flex-wrap gap-2">
          <span
            v-for="(hashtag, index) in result.hashtags"
            :key="index"
            class="px-3 py-1 rounded-full text-sm bg-purple-100 dark:bg-purple-900/30 text-purple-800 dark:text-purple-300 cursor-pointer hover:bg-purple-200 dark:hover:bg-purple-900/50 transition"
            @click="copyText(hashtag)"
          >
            {{ hashtag }}
          </span>
        </div>
        <button
          @click="copyText(result.hashtags.join(' '))"
          class="mt-2 text-sm text-indigo-600 dark:text-indigo-400 hover:underline"
        >
          Copy All Hashtags
        </button>
      </div>

      <div class="flex items-center justify-between p-3 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg">
        <div>
          <p class="text-sm text-gray-600 dark:text-gray-400">Recommended Post Time</p>
          <p class="text-lg font-semibold text-indigo-700 dark:text-indigo-300">
            {{ result.recommended_time }}
          </p>
        </div>
        <Clock class="w-8 h-8 text-indigo-600 dark:text-indigo-400" />
      </div>
    </div>

    <div v-else class="text-center py-8 text-gray-500 dark:text-gray-400">
      <Sparkles class="w-16 h-16 mx-auto mb-4 opacity-50" />
      <p>Generate caption using AI Generator to see results here</p>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Sparkles, Clock } from 'lucide-vue-next'
import { useToast } from 'vue-toastification'

const props = defineProps({
  result: {
    type: Object,
    default: null
  }
})

const toast = useToast()

const copyText = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    toast.success('Copied to clipboard!', {
      timeout: 2000
    })
  } catch (error) {
    toast.error('Failed to copy', {
      timeout: 2000
    })
  }
}

watch(() => props.result, (newResult) => {
  if (newResult) {
    // Auto-scroll to top when new result arrives
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}, { deep: true })
</script>








