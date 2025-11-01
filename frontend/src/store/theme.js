import { defineStore } from 'pinia'
import { ref, watch } from 'vue'

export const useThemeStore = defineStore('theme', () => {
    const isDark = ref(localStorage.getItem('theme') === 'dark')

    const toggleTheme = () => {
        isDark.value = !isDark.value
        updateTheme()
    }

    const updateTheme = () => {
        if (isDark.value) {
            document.documentElement.classList.add('dark')
            localStorage.setItem('theme', 'dark')
        } else {
            document.documentElement.classList.remove('dark')
            localStorage.setItem('theme', 'light')
        }
    }

    // Initialize theme on mount
    if (typeof window !== 'undefined') {
        updateTheme()
        watch(isDark, () => updateTheme())
    }

    return {
        isDark,
        toggleTheme
    }
})










