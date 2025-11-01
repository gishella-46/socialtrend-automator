<template>
  <nav class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <div class="flex">
          <router-link to="/dashboard" class="flex items-center space-x-2">
            <span class="text-2xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
              SocialTrend
            </span>
          </router-link>
          
          <div class="hidden md:flex md:space-x-8 md:ml-10">
            <router-link
              v-for="item in navItems"
              :key="item.path"
              :to="item.path"
              class="inline-flex items-center px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-indigo-600 dark:hover:text-indigo-400 transition"
              active-class="text-indigo-600 dark:text-indigo-400 border-b-2 border-indigo-600"
            >
              <component :is="item.icon" class="w-5 h-5 mr-2" />
              {{ item.name }}
            </router-link>
          </div>
        </div>

        <div class="flex items-center space-x-4">
          <button
            @click="themeStore.toggleTheme"
            class="p-2 rounded-lg text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition"
          >
            <Sun v-if="themeStore.isDark" class="w-5 h-5" />
            <Moon v-else class="w-5 h-5" />
          </button>

          <button
            @click="handleLogout"
            class="px-4 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-red-600 dark:hover:text-red-400 transition"
          >
            <LogOut class="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../store/auth'
import { useThemeStore } from '../store/theme'
import { Home, Upload, TrendingUp, Sparkles, Sun, Moon, LogOut } from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()
const themeStore = useThemeStore()

const navItems = [
  { path: '/dashboard', name: 'Dashboard', icon: Home },
  { path: '/upload', name: 'Upload', icon: Upload },
  { path: '/trends', name: 'Trends', icon: TrendingUp },
  { path: '/ai', name: 'AI Generator', icon: Sparkles }
]

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>










