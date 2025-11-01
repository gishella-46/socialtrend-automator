import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../store/auth'

const routes = [
    {
        path: '/login',
        name: 'Login',
        component: () => import('../pages/Login.vue'),
        meta: { requiresAuth: false }
    },
    {
        path: '/register',
        name: 'Register',
        component: () => import('../pages/Register.vue'),
        meta: { requiresAuth: false }
    },
    {
        path: '/dashboard',
        name: 'Dashboard',
        component: () => import('../pages/Dashboard.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/upload',
        name: 'Upload',
        component: () => import('../pages/Upload.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/trends',
        name: 'Trends',
        component: () => import('../pages/Trends.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/ai',
        name: 'AI',
        component: () => import('../pages/AI.vue'),
        meta: { requiresAuth: true }
    },
    {
        path: '/',
        redirect: '/dashboard'
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const authStore = useAuthStore()

    if (to.meta.requiresAuth && !authStore.isAuthenticated) {
        next('/login')
    } else if ((to.path === '/login' || to.path === '/register') && authStore.isAuthenticated) {
        next('/dashboard')
    } else {
        next()
    }
})

export default router










