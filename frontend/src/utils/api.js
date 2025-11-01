import axios from 'axios'

// Determine API base URL based on endpoint
const getBaseURL = (url) => {
    // Laravel API endpoints
    if (url && (url.includes('/api/auth') || url.includes('/api/scheduled-posts') || url.includes('/api/dashboard'))) {
        return import.meta.env.VITE_LARAVEL_API_URL || 'http://localhost:8000'
    }
    // FastAPI endpoints (default)
    return import.meta.env.VITE_API_URL || 'http://localhost:5000'
}

const api = axios.create({
    baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5000',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
})

// Request interceptor
api.interceptors.request.use(
    (config) => {
        // Determine correct base URL based on endpoint
        const baseURL = getBaseURL(config.url)
        config.baseURL = baseURL

        const token = localStorage.getItem('token')
        if (token) {
            config.headers.Authorization = `Bearer ${token}`
        }
        return config
    },
    (error) => {
        return Promise.reject(error)
    }
)

// Response interceptor
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem('token')
            window.location.href = '/login'
        }
        return Promise.reject(error)
    }
)

export default api
