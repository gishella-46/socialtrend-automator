<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800 p-4">
    <motion
      :initial="{ opacity: 0, y: 20 }"
      :animate="{ opacity: 1, y: 0 }"
      :transition="{ duration: 0.5 }"
      class="w-full max-w-md"
    >
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8 space-y-6">
        <div class="text-center">
          <h1 class="text-3xl font-bold text-gray-900 dark:text-white mb-2">Welcome Back</h1>
          <p class="text-gray-600 dark:text-gray-400">Sign in to your account</p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Email
            </label>
            <input
              v-model="email"
              type="email"
              required
              class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
              placeholder="your@email.com"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Password
            </label>
            <input
              v-model="password"
              type="password"
              required
              class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition"
              placeholder="••••••••"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-3 rounded-lg transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ loading ? 'Signing in...' : 'Sign In' }}
          </button>
        </form>

        <p class="text-center text-sm text-gray-600 dark:text-gray-400">
          Don't have an account?
          <a
            href="/register"
            @click.prevent="goToRegister"
            class="text-indigo-600 dark:text-indigo-400 hover:underline font-semibold cursor-pointer transition-colors"
          >
            Sign up
          </a>
        </p>

        <div v-if="error" class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3 text-red-700 dark:text-red-400 text-sm">
          {{ error }}
        </div>
      </div>
    </motion>
  </div>
</template>

<script setup>
import { Motion } from '@motionone/vue'
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../store/auth'

const router = useRouter()
const authStore = useAuthStore()

// Navigate to register page
const goToRegister = () => {
  router.push('/register')
}

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''

  const result = await authStore.login({
    email: email.value,
    password: password.value
  })

  if (result.success) {
    router.push('/dashboard')
  } else {
    error.value = result.error
  }

  loading.value = false
}
</script>
