<template>
  <div class="manage-orders-container">
    <main class="manage-orders-content">
      <header class="page-header">
        <h1>Manage User Orders</h1>
        <p>Search for a user by their email or ID to manage all associated orders.</p>
      </header>

      <section class="card search-card">
        <h2>Find User's Orders</h2>
        <form @submit.prevent="searchOrders" class="search-form">
          <label for="search-query">User Email or UUID</label>
          <input
            type="text"
            id="search-query"
            v-model="searchQuery"
            placeholder="e.g., user@example.com or a UUID"
          />
          <button type="submit" class="btn btn-primary" :disabled="loading">
            {{ loading ? '...' : 'Search' }}
          </button>
        </form>
      </section>

      <div v-if="message" :class="['api-message', messageType]">{{ message }}</div>

      <section v-if="orders.length > 0" class="results-section">
        <h2 class="results-header">Found {{ orders.length }} Order(s)</h2>
        <form
          v-for="order in orders"
          :key="order.order_id"
          class="card order-details-card"
          @submit.prevent="saveOrder(order)"
        >
          <div class="order-grid">
            <div class="product-info">
              <img :src="order.product_image_url" :alt="order.product_name" class="product-img" />
              <div class="product-details">
                <h3>{{ order.product_name }}</h3>
                <p>{{ order.brand_name }}</p>
                <p>Size: {{ order.size_value }}</p>
                <p>Condition: <span class="condition-value">{{ order.product_condition }}</span></p>
              </div>
            </div>

            <div class="order-info">
              <div class="info-item">
                <label>Order ID</label>
                <span>{{ order.order_id }}</span>
              </div>
              <div class="info-item">
                <label>Date Created</label>
                <span>{{ formatTimestamp(order.created_at) }}</span>
              </div>
              <div class="info-item">
                <label>Sale Price</label>
                <span>{{ formatCurrency(order.sale_price) }}</span>
              </div>
              <div class="info-item">
                <label>Net Amount ({{ order.user_role }})</label>
                <span>{{ formatCurrency(order.user_net_amount) }}</span>
              </div>
            </div>

            <div class="order-management">
              <h3>Manage Status</h3>
              <div class="form-group">
                <label for="order_status">Order Status</label>
                <select id="order_status" v-model="order.order_status">
                  <option value="pending">Pending</option>
                  <option value="paid">Paid</option>
                  <option value="shipped">Shipped</option>
                  <option value="completed">Completed</option>
                  <option value="cancelled">Cancelled</option>
                  <option value="refunded">Refunded</option>
                </select>
              </div>
              <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
          </div>
        </form>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'

const searchQuery = ref('')
const loading = ref(false)
const message = ref('')
const messageType = ref('')
const orders = ref([])

function formatTimestamp(dateStr) {
  if (!dateStr) return 'N/A'
  const d = new Date(dateStr)
  if (Number.isNaN(d.getTime())) return dateStr
  return d.toLocaleString()
}

function formatCurrency(value) {
  const n = Number(value)
  if (!Number.isFinite(n)) return '$0.00'
  return n.toLocaleString('en-US', { style: 'currency', currency: 'USD' })
}

async function searchOrders() {
  if (!searchQuery.value) {
    message.value = 'Please enter a User Email or UUID.'
    messageType.value = 'error'
    return
  }
  loading.value = true
  orders.value = []
  message.value = ''
  messageType.value = ''
  try {
    const response = await fetchFromAPI(`/admin/orders/${searchQuery.value}`)

    if (response && response.length > 0) {
      orders.value = response
      message.value = ''
      messageType.value = 'success'
    } else {
      message.value = 'No orders found for that user.'
      messageType.value = 'error'
    }
  } catch (err) {
    console.error('Error searching for orders:', err)
    message.value = err?.data?.message || 'An error occurred while searching.'
    messageType.value = 'error'
  } finally {
    loading.value = false
    setTimeout(() => {
      message.value = ''
    }, 3000)
  }
}

async function saveOrder(order) {
  const payload = {
    user_identifier: searchQuery.value,
    status: order.order_status,
  };

  console.log(`Saving order ${order.order_id} for user ${searchQuery.value} with payload:`, payload);

  // try {
  //   // UPDATED: The API endpoint now includes the user identifier from the search query
  //   await postToAPI(`/admin/orders/${searchQuery.value}/${order.order_id}`, payload)
  //
  //   message.value = `Order ${order.order_id} status updated successfully!`
  //   messageType.value = 'success'
  // } catch (err) {
  //   console.error('Error updating order status:', err)
  //   message.value = 'Failed to update order status.'
  //   messageType.value = 'error'
  // } finally {
  //   setTimeout(() => {
  //     message.value = ''
  //   }, 3000)
  // }
}
</script>

<style scoped>
h1, h2, h3 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.8rem; margin-bottom: 0.5rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.5rem; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { font-size: 1.2rem; margin-bottom: 0.5rem; }
p { color: #cccccc; line-height: 1.6; margin: 0.25rem 0; }
label { display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.5rem; }
select { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-family: inherit; font-size: 1rem; padding: 0.75rem; width: 100%; }

.manage-orders-container { color: #ffffff; }
.manage-orders-content { margin: 0 auto; max-width: 900px; padding: 4rem 5%; }
.page-header { margin-bottom: 3rem; text-align: center; }
.page-header p { color: #888; font-size: 1.1rem; }

.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin-bottom: 2rem; padding: 2rem; }
.search-form { display: flex; flex-direction: column; }

.search-card {
  max-width: 550px;
  margin-left: auto;
  margin-right: auto;
}

#search-query {
  background-color: #2c2c2c;
  border: 1px solid #444;
  border-radius: 8px;
  box-sizing: border-box;
  color: #ffffff;
  font-size: 1rem;
  margin-bottom: 1rem;
  outline: none;
  padding: 0.85rem 1rem;
  transition: border-color 0.2s ease;
  width: 100%;
}
#search-query:focus {
  border-color: #ffffff;
}

.results-section .results-header {
  border-bottom: none;
  color: #ccc;
  font-size: 1.3rem;
  margin-bottom: 1.5rem;
}

.order-details-card { padding: 1.5rem; }
.order-grid { align-items: flex-start; display: grid; gap: 2rem; grid-template-columns: 1.5fr 1.5fr 1fr; }
.product-info { align-items: center; display: flex; gap: 1rem; }
.product-img { border-radius: 8px; height: 100px; object-fit: cover; width: 100px; }
.product-details h3 { margin-bottom: 0.5rem; }
.condition-value {
  text-transform: capitalize;
}
.order-info { display: flex; flex-direction: column; gap: 1rem; }
.info-item label { color: #888; font-size: 0.8rem; margin-bottom: 0; }
.info-item span { font-family: monospace; font-size: 0.9rem; }
.order-management { border-left: 1px solid #333; padding-left: 2rem; }
.order-management .form-group { margin-bottom: 1rem; }

.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 1rem; font-weight: bold; padding: 0.75rem 1.5rem; text-align: center; transition: all 0.3s ease; width: 100%; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-primary:hover:not(:disabled) { background-color: #cccccc; }
.btn:disabled { background-color: #555; color: #999; cursor: not-allowed; }

.api-message { border-radius: 8px; font-weight: 600; margin: 0 auto 2rem auto; max-width: 900px; padding: 1rem 1.5rem; text-align: center; }
.api-message.success { background: #0f5132; border: 1px solid #0b2f1f; color: #d1e7dd; }
.api-message.error { background: #5a1414; border: 1px solid #3e0b0b; color: #f8d7da; }

@media (max-width: 768px) {
  .order-grid { grid-template-columns: 1fr; }
  .order-management { border-left: none; border-top: 1px solid #333; margin-top: 1.5rem; padding-left: 0; padding-top: 1.5rem; }
}
</style>
