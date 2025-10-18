<template>
  <div class="profile-container">
    <nav class="navbar"></nav>

    <header class="page-header">
      <a href="/" class="logo">NAME</a>
    </header>

    <!-- API message area -->
    <div v-if="message" :class="['api-message', messageType]">{{ message }}</div>

    <main class="profile-content">
      <header class="profile-header">
        <div class="user-info">
          <h1>{{ greeting }}</h1>
          <p class="user-detail">Member since {{ formattedMemberSince }}</p>
          <p v-if="user.location" class="user-detail">{{ user.location }}</p>
        </div>
      </header>

      <section class="overview-section">
        <h2>Account Overview</h2>
        <div class="stats-grid">
          <div class="stat-card">
            <h3>{{ formatCurrency(user.portfolioValue) }}</h3>
            <p>Estimated Portfolio Value</p>
          </div>
          <div class="stat-card">
            <h3>{{ user.activeListings ?? 0 }}</h3>
            <p>Active Listings</p>
          </div>
          <div class="stat-card">
            <h3>{{ user.openOrders ?? 0 }}</h3>
            <p>Open Orders</p>
          </div>
        </div>
      </section>

      <section class="navigation-section">
        <h2>Manage Your Account</h2>
        <div class="nav-grid">
          <a href="#" class="nav-card">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M2.25 18 9 11.25l4.306 4.306a11.95 11.95 0 0 1 5.814-5.518l2.74-1.22m0 0-5.94-2.281m5.94 2.28-2.28 5.941"
              />
            </svg>
            <h3>Portfolio</h3>
            <p>View your collection's value.</p>
          </a>

          <a href="#" class="nav-card">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c.578 0 1.058-.42 1.135-.984l2.062-7.341a.375.375 0 0 0-.34-.48H4.625a.375.375 0 0 0-.34.48L6.44 11.25M12 21a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5Zm6 0a.75.75 0 1 1 0-1.5.75.75 0 0 1 0 1.5Z"
              />
            </svg>
            <h3>Orders</h3>
            <p>Track your purchases and sales.</p>
          </a>

          <a href="/transactions" class="nav-card">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M12 6v12m-3-2.818.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.826-1.106-2.279 0-3.105C10.42 7.219 11.22 7 12 7c.817 0 1.579.24 2.212.659"
              />
            </svg>
            <h3>Transactions</h3>
            <p>Review your payment history.</p>
          </a>

          <a href="#" class="nav-card">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25"
              />
            </svg>
            <h3>Listings</h3>
            <p>Manage your items for sale.</p>
          </a>

          <a href="/settings" class="nav-card">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z"
              />
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
              />
            </svg>
            <h3>Settings</h3>
            <p>Edit your profile and preferences.</p>
          </a>
        </div>
      </section>
    </main>

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { fetchFromAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'

const authStore = useAuthStore()

const user = ref({ firstName: '', memberSince: '', location: '', portfolioValue: 0, activeListings: 0, openOrders: 0 })

const greeting = ref('Welcome');

const message = ref('')
const messageType = ref('') // 'success' or 'error'
const loading = ref(false)

function formatCurrency(value) {
  const n = Number(value)
  if (Number.isFinite(n)) return `$${n.toLocaleString()}`
  return '$0'
}

function formatMemberSince(dateStr) {
  if (!dateStr) return ''
  // Try parsing ISO-like date strings; gracefully fallback to original string
  const d = new Date(dateStr)
  if (Number.isNaN(d.getTime())) return dateStr
  const monthName = d.toLocaleString(undefined, { month: 'long' })
  const year = d.getFullYear()
  return `${monthName} ${year}`
}

const formattedMemberSince = computed(() => formatMemberSince(user.value.memberSince))

onMounted(async() => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  loading.value = true
  try {
    const data = await fetchFromAPI(`/users/${authStore.uuid}`)
    // Expect the API to return the user object directly. Map to our local shape defensively.
    user.value = {
      firstName: data.firstName || '',
      memberSince: data.memberSince || '',
      location: data.location || '',
      portfolioValue: data.portfolioValue ?? 0,
      activeListings: data.activeListings ?? 0,
      openOrders: data.openOrders ?? 0,
    }

    greeting.value = user.value.firstName ? `Welcome, ${user.value.firstName}` : 'Welcome'
    // NOTE: per request, do not show a success message on every valid response.
  } catch (err) {
    // fetchFromAPI throws with .message and may include .data (api payload)
    let errMsg = (err && err.message) || 'Failed to load profile.'
    if (err && err.data && err.data.message) errMsg = err.data.message
    message.value = errMsg
    messageType.value = 'error'
    router.push('/login')
    return

  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
/* Inherit global styles from your main CSS file for fonts, colors, etc. */
h1,
h2,
h3 {
  font-family: Spectral, sans-serif;
  font-weight: 600;
}
h1 {
  font-size: 2.8rem;
  margin-bottom: 0.5rem;
}
h2 {
  border-bottom: 1px solid #333;
  font-size: 1.8rem;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  text-align: left;
}
h3 {
  color: #ffffff;
  font-size: 1.5rem;
  margin-bottom: 0.5rem;
}
p {
  color: #cccccc;
  line-height: 1.6;
}
a {
  color: #ffffff;
  text-decoration: none;
}
.logo {
  font-size: 1.5rem;
  font-weight: bold;
  letter-spacing: 2px;
}
.page-header {
  border-bottom: 1px solid #2a2a2a;
  padding: 1.5rem 5%;
}
.profile-container {
  color: #ffffff;
}
.profile-content {
  margin: 0 auto;
  max-width: 1200px;
  padding: 4rem 5%;
}
.profile-header {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  margin-bottom: 4rem;
  padding: 2rem;
}
.user-info .user-detail {
  color: #888;
  font-size: 1rem;
  margin: 0;
}
.overview-section,
.navigation-section {
  margin-bottom: 4rem;
}
.stats-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}
/* Updated nav-grid for 5 cards in one row or responsive wrapping */
.nav-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); /* Adjusted minmax for 5 cards */
}
@media (min-width: 1200px) {
  /* For larger screens, ensure 5 columns */
  .nav-grid {
    grid-template-columns: repeat(5, 1fr);
  }
}
/* End Updated nav-grid */
.stat-card {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
}
.stat-card h3 {
  color: #ffffff;
  font-size: 2.2rem;
  margin: 0 0 0.5rem 0;
}
.stat-card p {
  color: #888;
  font-size: 0.9rem;
  margin: 0;
}
.nav-card {
  align-items: center;
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  justify-content: center;
  padding: 2rem;
  text-align: center;
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;
}
.nav-card:hover {
  border-color: #444;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.5);
  transform: translateY(-5px);
}
.nav-card svg {
  height: 48px;
  margin-bottom: 1rem;
  stroke: #ffffff;
  width: 48px;
}
.nav-card h3 {
  font-size: 1.2rem;
  margin: 0;
}
.nav-card p {
  color: #888;
  font-size: 0.9rem;
  margin: 0;
}

/* API message styles */
.api-message {
  max-width: 1200px;
  margin: 1rem auto;
  padding: 0.75rem 1rem;
  border-radius: 6px;
  font-weight: 600;
  text-align: center;
}
.api-message.success {
  background: #0f5132;
  color: #d1e7dd;
  border: 1px solid #0b2f1f;
}
.api-message.error {
  background: #5a1414;
  color: #f8d7da;
  border: 1px solid #3e0b0b;
}
</style>
