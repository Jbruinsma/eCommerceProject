<template>
  <div class="transactions-container">
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

/* New Styles for Overview Section */
.overview-section { margin-bottom: 4rem; }
.stats-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.stat-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 8px; padding: 2rem; text-align: center; }
.stat-card h3 { color: #ffffff; font-size: 2.2rem; margin: 0 0 0.5rem 0; }
.stat-card p { color: #888; font-size: 0.9rem; margin: 0; }

@media (max-width: 640px) {
  .page-header { padding: 1rem 3%; }
}
</style>
