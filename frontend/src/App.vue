<template>
  <div id="app">
    <Navbar v-if="showNavbar" />
    <router-view />
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useThemeStore } from './store/theme'
import Navbar from './components/Navbar.vue'

const route = useRoute()
const themeStore = useThemeStore()

const showNavbar = computed(() => {
  return route.path !== '/login' && route.path !== '/register'
})

onMounted(() => {
  // Initialize theme
  themeStore.updateTheme()
})
</script>
