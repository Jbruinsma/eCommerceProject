<template>
  <div class="order-detail-container">
    <div v-if="loading" class="loading-state">
      <p>Loading Order Details...</p>
    </div>
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
    </div>
    <main v-else-if="order" class="order-content">
      <div class="order-header">
        <div class="header-info">
          <h1>Order #{{ order.orderId }}</h1>
          <p>Placed on {{ formatDate(order.createdAt) }}</p>
        </div>
        <div class="role-banner">
          <strong>{{ order.role }}</strong>
        </div>
      </div>

      <div class="card timeline-section">
        <h2>Order Timeline</h2>
        <div class="timeline">
          <div class="timeline-item complete">
            <div class="timeline-dot"></div>
            <div class="timeline-info">
              <p class="timeline-title">Order Placed</p>
              <p class="timeline-date">{{ formatDate(order.createdAt) }}</p>
            </div>
          </div>
          <div class="timeline-connector"></div>
          <div class="timeline-item" :class="{ complete: order.orderStatus !== 'pending' }">
            <div class="timeline-dot"></div>
            <div class="timeline-info">
              <p class="timeline-title">Last Updated</p>
              <p class="timeline-date">{{ formatDate(order.lastUpdatedAt) }}</p>
            </div>
          </div>
          <div class="timeline-connector"></div>
          <div class="timeline-item" :class="{ complete: order.orderStatus === 'completed' }">
            <div class="timeline-dot"></div>
            <div class="timeline-info">
              <p class="timeline-title">Completed</p>
              <p v-if="order.orderStatus === 'completed'" class="timeline-date">
                {{ formatDate(order.lastUpdatedAt) }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <div class="card product-status-card">
        <div class="product-grid">
          <div class="product-image">
            <img
              :src="order.productDetails.productImageUrl"
              :alt="order.productDetails.productName"
            />
          </div>
          <div class="product-details">
            <h3>{{ order.productDetails.productName }}</h3>
            <p class="brand">{{ order.productDetails.brandName }}</p>
            <p><span>Size:</span> {{ order.productDetails.sizeValue }}</p>
            <p><span>SKU:</span> {{ order.productDetails.productSku }}</p>
            <p><span>Condition:</span> {{ order.productDetails.productCondition || 'New' }}</p>
          </div>
        </div>
        <div class="status-section">
          <h2>Order Status</h2>
          <div class="status-display">
            <span class="status-badge" :class="`status-${order.orderStatus}`">{{
                order.orderStatus
              }}</span>
            <p>Your order is currently {{ order.orderStatus }}.</p>
          </div>
          <ul class="timeline-simple">
            <li>
              <span>Order Placed</span>
              <span>{{ formatDate(order.createdAt) }}</span>
            </li>
            <li>
              <span>Last Update</span>
              <span>{{ formatDate(order.lastUpdatedAt) }}</span>
            </li>
          </ul>
        </div>
      </div>

      <div class="details-grid">
        <template v-if="order.role === 'buyer'">
          <div class="card pricing-summary">
            <h2>Pricing Summary</h2>
            <ul>
              <li>
                <span>Sale Price</span>
                <span>{{
                    formatCurrency(order.buyerDetails.finalPrice - order.buyerDetails.transactionFee)
                  }}</span>
              </li>
              <li>
                <span>Transaction Fee</span>
                <span>{{ formatCurrency(order.buyerDetails.transactionFee) }}</span>
              </li>
              <li class="total">
                <span>Total Price</span>
                <span>{{ formatCurrency(order.buyerDetails.finalPrice) }}</span>
              </li>
            </ul>
          </div>
          <div class="card address-summary">
            <h2>Shipping Address</h2>
            <address>
              {{ order.buyerDetails.address.nameOnAddress }}<br />
              {{ order.buyerDetails.address.addressLine1 }}<br />
              <template v-if="order.buyerDetails.address.addressLine2">
                {{ order.buyerDetails.address.addressLine2 }}<br />
              </template>
              {{ order.buyerDetails.address.city }}, {{ order.buyerDetails.address.state }}
              {{ order.buyerDetails.address.zipCode }}<br />
              {{ order.buyerDetails.address.country }}
            </address>
          </div>
        </template>

        <template v-if="order.role === 'seller'">
          <div class="card pricing-summary">
            <h2>Payout Summary</h2>
            <ul>
              <li>
                <span>Sale Price</span>
                <span>{{
                    formatCurrency(order.sellerDetails.finalPayout + order.sellerDetails.transactionFee)
                  }}</span>
              </li>
              <li>
                <span>Transaction Fee</span>
                <span>- {{ formatCurrency(order.sellerDetails.transactionFee) }}</span>
              </li>
              <li class="total">
                <span>Total Payout</span>
                <span>{{ formatCurrency(order.sellerDetails.finalPayout) }}</span>
              </li>
            </ul>
          </div>
          <div class="card next-steps-summary">
            <h2>Next Steps</h2>
            <p>
              Please prepare the item for shipment. You will be notified when it is time to print
              the shipping label.
            </p>
          </div>
        </template>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'
import { fetchFromAPI } from '@/utils/index.js'

const route = useRoute()
const authStore = useAuthStore()

const orderId = route.params.orderId
const order = ref(null)
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  try {
    const orderResponse = await fetchFromAPI(`/orders/${authStore.uuid}/${orderId}`)
    order.value = orderResponse
  } catch (err) {
    error.value = 'Failed to load order details. Please try again later.'
    console.error(err)
  } finally {
    loading.value = false
  }
})

const formatCurrency = (amount) => {
  if (typeof amount !== 'number') return '$0.00'
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDate = (dateString) => {
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('en-US', options)
}
</script>

<style scoped>
address { font-style: normal; line-height: 1.6; }
.brand { color: #888; font-size: 1rem; margin: 0 0 0.5rem; }
.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.details-grid { display: grid; gap: 2rem; grid-template-columns: 1fr 1fr; margin-top: 2rem; }
.error-state, .loading-state { align-items: center; display: flex; height: 50vh; justify-content: center; }
h1 { font-family: Spectral, sans-serif; font-size: 2.2rem; font-weight: 600; margin: 0; }
h2 { border-bottom: 1px solid #333; font-family: Spectral, sans-serif; font-size: 1.5rem; font-weight: 600; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { color: #ffffff; font-family: Spectral, sans-serif; font-size: 1.4rem; font-weight: 600; margin: 0; }
.header-info { flex-grow: 1; }
.order-content { margin: 0 auto; max-width: 1000px; padding: 4rem 5%; }
.order-detail-container { color: #ffffff; font-family: Spectral, sans-serif; }
.order-header { align-items: flex-start; border-bottom: 1px solid #333; display: flex; justify-content: space-between; padding-bottom: 1.5rem; position: relative; }
.order-header p { color: #888; margin: 0.25rem 0 0; }
p { color: #ccc; line-height: 1.6; }
.pricing-summary li { align-items: center; color: #ccc; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.pricing-summary li.total { border-top: 1px solid #333; color: #ffffff; font-size: 1.1rem; font-weight: bold; margin-top: 1rem; padding-top: 1rem; }
.pricing-summary ul { list-style: none; padding: 0; }
.product-details p { color: #ccc; margin: 0.25rem 0; }
.product-details p span { color: #888; font-weight: 600; }
.product-grid { align-items: center; display: grid; gap: 2rem; grid-template-columns: 150px 1fr; }
.product-image { background-color: #ffffff; border-radius: 8px; flex-shrink: 0; height: 150px; width: 150px; }
.product-image img { border-radius: 8px; height: 100%; object-fit: contain; width: 100%; }
.product-status-card { display: grid; gap: 2rem; grid-template-columns: 1fr; margin-top: 2rem; }
.role-banner { background-color: #f0d56e; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; color: #1a1a1a; font-size: 0.8rem; font-weight: bold; padding: 0.3rem 0.8rem; position: absolute; right: 0; text-transform: uppercase; top: 0; }
.status-badge { border-radius: 12px; font-size: 0.9rem; font-weight: bold; padding: 0.4rem 1rem; text-transform: capitalize; }
.status-cancelled { background-color: #4a1a1a; color: #f06e6e; }
.status-completed { background-color: #6ef0a3; color: #1a4a32; }
.status-display { align-items: center; display: flex; gap: 1rem; }
.status-display p { color: #ffffff; font-size: 1.1rem; font-weight: 600; margin: 0; }
.status-paid { background-color: #1a4a32; color: #6ef0a3; }
.status-pending { background-color: #4a411a; color: #f0d56e; }
.status-refunded { background-color: #2c2c2c; color: #aaaaaa; }
.status-section { border-top: 1px solid #333; margin-top: 2rem; padding-top: 2rem; }
.status-shipped { background-color: #1a4a32; color: #6ef0a3; }
.timeline { align-items: flex-start; display: flex; justify-content: space-between; }
.timeline-connector { background-color: #333; flex-grow: 1; height: 2px; margin: 0 1rem; position: relative; top: 8px; }
.timeline-date { color: #888; font-size: 0.85rem; margin-top: 0.25rem; }
.timeline-dot { background-color: #444; border: 2px solid #666; border-radius: 50%; height: 12px; margin: 0 auto; transition: all 0.3s ease; width: 12px; }
.timeline-info { text-align: center; }
.timeline-item { position: relative; width: 100px; }
.timeline-item.complete .timeline-connector { background-color: #6ef0a3; }
.timeline-item.complete .timeline-dot { background-color: #6ef0a3; border-color: #6ef0a3; }
.timeline-item.complete .timeline-title { color: #ffffff; }
.timeline-section { margin-bottom: 0; margin-top: 2rem; }
.timeline-section h2 { margin-bottom: 2.5rem; }
.timeline-simple { list-style: none; margin-top: 1.5rem; padding: 0; }
.timeline-simple li { align-items: center; color: #888; display: flex; justify-content: space-between; }
.timeline-simple li span:first-child { font-weight: 600; }
.timeline-title { font-weight: bold; margin: 0.75rem 0 0; transition: color 0.3s ease; }
ul { list-style: none; padding: 0; }
@media (min-width: 769px) {
  .product-status-card { grid-template-columns: 1fr 1fr; }
  .status-section { border-left: 1px solid #333; border-top: none; margin-top: 0; padding-left: 2rem; padding-top: 0; }
}
@media (max-width: 768px) {
  .details-grid { grid-template-columns: 1fr; }
  .order-content { padding: 2rem 5%; }
  .product-grid { grid-template-columns: 1fr; text-align: center; }
  .product-image { margin: 0 auto; }
  .timeline { flex-direction: column; }
  .timeline-connector { display: none; }
  .timeline-item { align-items: center; display: flex; gap: 1rem; margin-bottom: 1rem; width: 100%; }
  .timeline-info { text-align: left; }
  .timeline-dot { margin: 0; }
  .timeline-title { margin-top: 0; }
}
@media (max-width: 480px) {
  h1 { font-size: 1.8rem; }
  .order-content { padding: 2rem 3%; }
  .card { padding: 1.5rem; }
  .role-banner { font-size: 0.7rem; padding: 0.2rem 0.6rem; }
}
</style>
