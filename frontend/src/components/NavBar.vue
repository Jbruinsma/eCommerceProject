<template>
  <nav class="navbar">
    <a class="logo" href="/">NAME</a>
    <ul class="nav-links">
      <li class="nav-customization"><a href="/search?category=sneakers">Sneakers</a></li>
      <li class="nav-customization"><a href="/search?category=apparel">Apparel</a></li>
      <li class="nav-customization"><a href="/search?category=collectibles">Collectibles</a></li>
    </ul>

    <div class="nav-icons">
      <div v-if="!isSearchPage" class="header-search-bar">
        <svg
          @click="handleSearch"
          class="search-icon"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="currentColor"
        >
          <path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
        </svg>
        <input
          type="text"
          class="search-input"
          placeholder="Search for items..."
          v-model="searchQuery"
          @keyup.enter="handleSearch"
        />
      </div>

      <svg
        @click="redirectToProfile"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="account-icon"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
        />
      </svg>

      <svg
        @click="redirectToOrders"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="cart-icon"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"
        />
      </svg>

      <svg
        @click="redirectToAdminDashboard"
        v-if="authStore.role === 'admin'"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        class="bars-icon"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z"
        />
      </svg>


    </div>
  </nav>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'

const searchQuery = ref('')
const authStore = useAuthStore()
const route = useRoute()

// If route name is 'search-results' or path starts with '/search', treat it as the search page.
const isSearchPage = computed(() => {
  const name = route.name ? String(route.name) : ''
  const path = route.path ? String(route.path) : ''
  const lname = name.toLowerCase()
  return lname.includes('search') || path.startsWith('/search')
})

function handleSearch() {
  const q = (searchQuery.value || '').toString().trim()
  try {
    if (q) {
      router.push({ name: 'SearchResults', query: { q } })
    } else {
      if (router && router.resolve) {
        router.push({ name: 'SearchResults' }).catch(() => router.push('/search'))
      } else {
        router.push('/search')
      }
    }
  } catch (err) {
    // defensive fallback
    console.error('Error handling search:', err)
    router.push(q ? `/search?q=${encodeURIComponent(q)}` : '/search')
  }
  searchQuery.value = ''
}

function redirectToProfile() {
  if (authStore.isLoggedIn) router.push('/profile')
  else router.push('/login')
}

function redirectToOrders() {
  if (authStore.isLoggedIn) router.push('/orders')
  else router.push('/login')
}

function redirectToAdminDashboard() {
  if (authStore.isLoggedIn && authStore.role === 'admin') {
    router.push('/admin')
  } else {
    router.push('/login')
  }
}

</script>

<style scoped>
h1, h2, h3 { font-weight: 600; }
h1 { font-size: 3rem; margin-bottom: 1rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; text-align: center; }
h3 { font-size: 1.1rem; margin-top: 1rem; }
p { color: #cccccc; line-height: 1.6; }
a { color: #ffffff; text-decoration: none; }
.navbar { align-items: center; background-color: #1a1a1a; display: flex; justify-content: space-between; padding: 1rem 5%; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.nav-links { align-items: center; display: flex; gap: 2rem; list-style: none; }
.nav-links a { transition: color 0.3s ease; }
.nav-links a:hover { color: #bbbbbb; }
.nav-customization { font-size: 20px; font-weight: 500; display: inline-flex; }
.nav-icons { align-items: center; display: flex; gap: 1.5rem; }
.account-icon, .cart-icon { cursor: pointer; height: 28px; width: 28px; color: #ffffff; stroke: #ffffff; }
.header-search-bar { align-items: center; background-color: #2c2c2c; border-radius: 12px; display: flex; padding: 0.3rem 0.8rem; }
.search-icon { fill: #888; height: 30px; margin-right: 0.5rem; width: 15px; cursor: pointer; }
.search-input { background-color: transparent; border: none; color: #ffffff; font-size: 0.9rem; outline: none; width: 200px; }
.search-input::placeholder { color: #888; }

.bars-icon { cursor: pointer; height: 28px; width: 28px; color: #ffffff; stroke: #ffffff; }
</style>
