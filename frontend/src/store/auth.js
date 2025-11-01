import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '../utils/api'

export const useAuthStore = defineStore('auth', () => {
    const user = ref(null)
    const token = ref(localStorage.getItem('token') || null)

    const isAuthenticated = computed(() => !!token.value)

    const login = async (credentials) => {
        try {
            const response = await api.post('/auth/login', credentials)
            token.value = response.data.token
            user.value = response.data.user
            localStorage.setItem('token', token.value)
            return { success: true }
        } catch (error) {
            return {
                success: false,
                error: error.response?.data?.message || 'Login failed'
            }
        }
    }

    const register = async (userData) => {
        try {
            const response = await api.post('/auth/register', userData)
            token.value = response.data.token
            user.value = response.data.user
            localStorage.setItem('token', token.value)
            return { success: true }
        } catch (error) {
            return {
                success: false,
                error: error.response?.data?.message || 'Registration failed'
            }
        }
    }

    const logout = () => {
        token.value = null
        user.value = null
        localStorage.removeItem('token')
    }

    return {
        user,
        token,
        isAuthenticated,
        login,
        register,
        logout
    }
})










