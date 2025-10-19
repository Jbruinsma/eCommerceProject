<template>
  <div class="transactions-container">
    <nav class="navbar"></nav>

    <header class="page-header">
      <a href="/" class="logo">NAME</a>
      <div class="nav-icons">
        <svg
          @click="onProfileClick"
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
          @click="onCartClick"
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
      </div>
    </header>

    <main class="transactions-content">
      <section class="overview-section">
        <div class="stats-grid">
          <div class="stat-card">
            <h3>{{ formatCurrency(currentBalance) }}</h3>
            <p>Current Balance</p>
          </div>
          <div class="stat-card">
            <h3>{{ formatCurrency(lifetimeEarnings) }}</h3>
            <p>Lifetime Earnings</p>
          </div>
        </div>
      </section>

      <h2>Transaction History</h2>
      <div class="table-wrapper">
        <table class="transactions-table">
          <thead>
          <tr>
            <th>Transaction ID</th>
            <th>Order ID</th>
            <th>Date</th>
            <th>Amount</th>
            <th>Status</th>
          </tr>
          </thead>
          <tbody>
          <tr v-if="transactionsList.length === 0">
            <td colspan="5">You have no transactions yet.</td>
          </tr>
          <tr v-for="tx in transactionsList" :key="tx.transaction_id">
            <td>#{{ tx.transaction_id }}</td>
            <td><a href="#">{{ tx.order_id }}</a></td>
            <td>{{ formatDate(tx.created_at) }}</td>
            <td>{{ formatCurrency(tx.amount) }}</td>
            <td>
                <span class="status-badge" :class="`status-${tx.transaction_status}`">
                  {{ tx.transaction_status }}
                </span>
            </td>
          </tr>
          </tbody>
        </table>
      </div>
    </main>

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'
import { fetchFromAPI } from '@/utils/index.js'

const authStore = useAuthStore()
const transactionsList = ref([])

const currentBalance = ref('DNE')
const lifetimeEarnings = ref('DNE')

function onProfileClick() {
  if (authStore.isLoggedIn) router.push('/profile')
  else router.push('/login')
}
function onCartClick() {
  router.push('/cart')
}

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  try {
    const response = await fetchFromAPI(`/users/${authStore.uuid}/transactions`)

    const { transactions, currentBalance, lifetimeEarnings } = response

    transactionsList.value = transactions.map((tx) => ({
      transaction_id: tx.transaction_id ?? tx.id ?? tx.tx_id ?? '',
      order_id: tx.order_id ?? tx.orderId ?? (tx.order && (tx.order.id ?? tx.order_id)) ?? '',
      created_at: tx.created_at ?? tx.createdAt ?? tx.date ?? '',
      amount: tx.amount ?? tx.total ?? 0,
      transaction_status: (tx.transaction_status ?? tx.transactionStatus ?? tx.status ?? 'pending').toString(),
    }))

    currentBalance.value = currentBalance ?? 0
    lifetimeEarnings.value = lifetimeEarnings ?? 0

  } catch (err) {
    console.error('Failed to load transactions:', err)
    transactionsList.value = []
  }
})

const formatCurrency = (amount) => {
  const n = Number(amount)
  if (!Number.isFinite(n)) return '$0.00'
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(n)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const d = new Date(dateString)
  if (Number.isNaN(d.getTime())) return dateString
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return d.toLocaleDateString('en-US', options)
}
</script>

<style scoped>
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; text-align: left; }
a { color: #ffffff; text-decoration: none; }
a:hover { text-decoration: underline; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; gap: 1rem; justify-content: space-between; padding: 1.5rem 5%; }
.transactions-container { color: #ffffff; font-family: Spectral, sans-serif; }
.transactions-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.table-wrapper { overflow-x: auto; }
.transactions-table { border-collapse: collapse; margin-top: 1rem; min-width: 800px; width: 100%; }
thead th { background-color: #1a1a1a; border-bottom: 2px solid #333; color: #ffffff; font-weight: 600; padding: 1rem; text-align: left; }
tbody td { border-bottom: 1px solid #2a2a2a; padding: 1rem; vertical-align: middle; }
tbody tr:hover { background-color: #1f1f1f; }
tbody td a { font-weight: bold; }
/* Status Badge Styles */
.status-badge { border-radius: 12px; font-size: 0.8rem; font-weight: bold; padding: 0.3rem 0.8rem; text-transform: capitalize; }
.status-completed { background-color: #1a4a32; color: #6ef0a3; }
.status-pending { background-color: #4a411a; color: #f0d56e; }
.status-failed { background-color: #4a1a1a; color: #f06e6e; }
.status-refunded { background-color: #2c2c2c; color: #aaaaaa; }
.nav-icons { align-items: center; display: flex; gap: 1rem; }
.account-icon, .cart-icon { color: inherit; cursor: pointer; height: 28px; opacity: 0.95; transition: transform 0.12s ease, opacity 0.12s ease; width: 28px; }
.account-icon:hover, .cart-icon:hover { opacity: 1; transform: translateY(-2px); }
.account-icon:focus, .cart-icon:focus { outline: none; }
.account-icon:focus-visible, .cart-icon:focus-visible { border-radius: 4px; box-shadow: 0 0 0 3px rgba(255,255,255,0.06); }
/* New Styles for Overview Section */
.overview-section { margin-bottom: 4rem; }
.stats-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.stat-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 8px; padding: 2rem; text-align: center; }
.stat-card h3 { color: #ffffff; font-size: 2.2rem; margin: 0 0 0.5rem 0; }
.stat-card p { color: #888; font-size: 0.9rem; margin: 0; }

@media (max-width: 640px) {
  .page-header { padding: 1rem 3%; }
  .account-icon, .cart-icon { height: 24px; width: 24px; }
}
</style>
