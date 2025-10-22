<template>
  <div class="orders-container">
    <main class="orders-content">
      <h1 class="page-title">My Orders</h1>

      <div v-if="isLoading" class="loading-state">
        <p>Loading your orders...</p>
      </div>

      <div v-else-if="ordersList.length === 0" class="empty-state">
        <h2>No Orders Found</h2>
        <p>You haven't bought or sold any items yet.</p>
        <router-link :to="{ name: 'SearchResults' }" class="btn-shop">Start Shopping</router-link>
      </div>

      <div v-else class="orders-grid">
        <div v-for="order in ordersList" :key="order.order_id" class="order-card">
          <div class="order-card-image">
            <img
              :src="order.product_image_url"
              :alt="order.product_name"
              @error="(event) => (event.target.src = IMAGE_PLACEHOLDER)"
            />
          </div>
          <div class="order-card-details">
            <div class="order-card-header">
              <h3 class="product-name">{{ order.product_name }}</h3>
              <span class="role-badge" :class="`role-${order.user_role}`">
                {{ order.user_role }}
              </span>
            </div>
            <p class="product-brand">{{ order.brand_name }}</p>
            <p class="product-size">Size: {{ order.size_value }}</p>
            <div class="order-info">
              <p>
                <strong>{{ order.user_role === 'sell' ? 'Your Payout:' : 'Total Paid:' }}</strong>
                {{ formatCurrency(order.user_net_amount) }}
              </p>
              <p><strong>Order Date:</strong> {{ formatDate(order.created_at) }}</p>
            </div>
          </div>
          <div class="order-card-status">
            <span class="status-badge" :class="`status-${order.order_status}`">
              {{ formatStatus(order.order_status) }}
            </span>
          </div>
        </div>
      </div>
    </main>
    <footer class="site-footer"></footer>
  </div>
  <div
    aria-hidden="true"
    style="display: none"
    class="status-pending status-paid status-shipped status-completed status-cancelled status-refunded"
  ></div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useAuthStore } from '@/stores/authStore.js'
import { fetchFromAPI } from '@/utils/index.js'
import router from '@/router/index.js'

const authStore = useAuthStore()
const ordersList = ref([])
const isLoading = ref(true)

const IMAGE_PLACEHOLDER = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw=='

const normalizeOrders = (res) => {
  if (!res) return []
  if (Array.isArray(res)) return res

  if (res.orders) {
    if (Array.isArray(res.orders)) return res.orders
    if (typeof res.orders === 'object') return [res.orders]
  }

  if (res.data) {
    if (Array.isArray(res.data)) return res.data
    if (typeof res.data === 'object') return [res.data]
  }

  if (typeof res === 'object') return [res]
  return []
}

const formatStatus = (s) => {
  if (!s) return ''
  return String(s).replace(/(^|\s)\S/g, (c) => c.toUpperCase())
}

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  try {
    const response = await fetchFromAPI(`/orders/${authStore.uuid}`)
    ordersList.value = normalizeOrders(response)
  } catch (err) {
    console.error('Failed to load orders:', err)
    ordersList.value = []
  } finally {
    isLoading.value = false
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
.btn-shop { background-color: #6ef0a3; border-radius: 8px; color: #121212; display: inline-block; font-weight: bold; margin-top: 1.5rem; padding: 0.8rem 1.5rem; text-decoration: none; transition: background-color 0.3s; }
.btn-shop:hover { background-color: #8affbe; }
.empty-state { padding: 4rem 0; text-align: center; }
.empty-state h2 { font-size: 1.8rem; }
h1, h2, h3 { font-family: Spectral, sans-serif; font-weight: 600; }
.loading-state { padding: 4rem 0; text-align: center; }
.order-card { align-items: center; background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; display: grid; gap: 1.5rem; grid-template-columns: 100px 1fr auto; padding: 1.25rem; }
.order-card-details .order-info p { color: #aaa; font-size: 0.9rem; margin: 0.25rem 0; }
.order-card-details .order-info strong { color: #ccc; }
.order-card-details .product-brand { color: #888; font-size: 0.9rem; margin: 0.25rem 0 0.75rem; }
.order-card-details .product-name { font-size: 1.2rem; margin: 0; }
.order-card-details .product-size { color: #aaa; font-size: 0.9rem; margin: 0 0 1rem; }
.order-card-header { align-items: baseline; display: flex; gap: 0.75rem; }
.order-card-image img { border-radius: 8px; height: auto; max-width: 100%; }
.order-card-status { }
.orders-container { color: #ffffff; }
.orders-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.orders-grid { display: grid; gap: 1.5rem; }
.page-title { border-bottom: 1px solid #333; font-size: 2.2rem; margin-bottom: 3rem; padding-bottom: 1.5rem; text-align: left; }
p { color: #cccccc; }
.role-badge { border-radius: 12px; font-size: 0.7rem; font-weight: bold; padding: 0.25rem 0.6rem; text-transform: uppercase; }
.role-buy { background-color: #1a3e4a; color: #6ec2f0; }
.role-sell { background-color: #1a4a32; color: #6ef0a3; }
.status-badge { border-radius: 12px; font-size: 0.8rem; font-weight: bold; padding: 0.3rem 0.8rem; text-transform: capitalize; }
.status-cancelled { background-color: #4a1a1a; color: #f06e6e; }
.status-completed { background-color: #1a4a32; color: #6ef0a3; }
.status-paid { background-color: #1a3e4a; color: #6ec2f0; }
.status-pending { background-color: #4a411a; color: #f0d56e; }
.status-refunded { background-color: #2c2c2c; color: #aaaaaa; }
.status-shipped { background-color: #3e1a4a; color: #c26ef0; }

@media (max-width: 768px) {
  .order-card { grid-template-columns: 80px 1fr; }
  .order-card-status { grid-column: 2; justify-self: start; margin-top: 0.5rem; }
}
</style>
