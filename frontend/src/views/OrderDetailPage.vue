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
        <div class="header-status">
          <span class="status-badge" :class="`status-${order.orderStatus}`">{{
              order.orderStatus
            }}</span>
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

      <div class="order-grid">
        <div class="card product-summary">
          <div class="product-image">
            <img
              :src="order.productDetails.productImageUrl"
              :alt="order.productDetails.productName"
            />
          </div>
          <div class="product-details">
            <h3>{{ order.productDetails.brandName }} {{ order.productDetails.productName }}</h3>
            <p><span>Size:</span> {{ order.productDetails.sizeValue }}</p>
            <p><span>SKU:</span> {{ order.productDetails.productSku }}</p>
            <p><span>Condition:</span> New</p>
          </div>
        </div>

        <div class="order-sidebar">
          <div class="card role-indicator">
            <p>You are the <strong>{{ order.role }}</strong></p>
          </div>

          <template v-if="order.role === 'buyer'">
            <div class="card">
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
            <div class="card">
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
            <div class="card">
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
            <div class="card">
              <h2>Next Steps</h2>
              <p>
                Please prepare the item for shipment. You will be notified when it is time to print
                the shipping label.
              </p>
            </div>
          </template>

          <div class="card">
            <h2>Manage Order</h2>
            <div class="button-group">
              <button @click="showHelpModal" class="btn btn-secondary">Need Help?</button>
              <button v-if="isCancellable" @click="showCancelModal" class="btn btn-danger">
                Cancel Order
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div v-if="isModalVisible" class="modal-overlay" @click.self="handleModalClose">
      <div class="modal-content">
        <h4>{{ modalTitle }}</h4>
        <p>{{ modalMessage }}</p>
        <div class="modal-actions">
          <button @click="handleModalClose" class="btn btn-secondary">Close</button>
          <button v-if="pendingAction === 'cancel'" @click="handleModalConfirm" class="btn btn-danger">
            Confirm Cancellation
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
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

// Modal State
const isModalVisible = ref(false)
const modalTitle = ref('')
const modalMessage = ref('')
const pendingAction = ref(null)

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  try {
    const orderResponse = await mockFetchOrder(orderId)
    order.value = orderResponse
  } catch (err) {
    error.value = 'Failed to load order details. Please try again later.'
    console.error(err)
  } finally {
    loading.value = false
  }
})

// --- MOCK API FUNCTION - REMOVE FOR PRODUCTION ---
const mockFetchOrder = (id) => {
  console.log(`Fetching mock data for order ID: ${id}`)
  // const sellerResponse = {
  //   role: 'seller',
  //   orderId: '3a400dad-af76-11f0-9011-96302f5b3d1f',
  //   orderStatus: 'pending',
  //   createdAt: '2025-10-22T14:37:56',
  //   lastUpdatedAt: '2025-10-22T14:37:56',
  //   productDetails: {
  //     productId: 1,
  //     sizeId: 13,
  //     sizeValue: '10',
  //     brandId: 12,
  //     brandName: 'Nike',
  //     productName: 'Dunk Low "Panda"',
  //     productSku: 'DD1391-100',
  //     productColorway: 'White/Black-White',
  //     productImageUrl: 'https://images.stockx.com/images/Nike-Dunk-Low-Retro-White-Black-2021-Product.jpg',
  //     productRetailPrice: 110
  //   },
  //   sellerDetails: {
  //     transactionFee: 18,
  //     finalPayout: 282
  //   }
  // }

  const buyerResponse = {
    role: 'buyer',
    orderId: '3a400dad-af76-11f0-9011-96302f5b3d1f',
    orderStatus: 'pending',
    createdAt: '2025-10-22T14:37:56',
    lastUpdatedAt: '2025-10-22T14:37:56',
    productDetails: {
      productId: 1,
      sizeId: 13,
      sizeValue: '10',
      brandId: 12,
      brandName: 'Nike',
      productName: 'Dunk Low "Panda"',
      productSku: 'DD1391-100',
      productColorway: 'White/Black-White',
      productImageUrl: 'https://images.stockx.com/images/Nike-Dunk-Low-Retro-White-Black-2021-Product.jpg',
      productRetailPrice: 110
    },
    buyerDetails: {
      address: {
        nameOnAddress: 'Alex Miller',
        addressLine1: '123 Market St',
        addressLine2: 'Apt 4B',
        city: 'Brooklyn',
        state: 'NY',
        zipCode: '11201',
        country: 'United States'
      },
      transactionFee: 4.5,
      finalPrice: 304.5
    }
  }


  return new Promise((resolve) => {
    setTimeout(() => {
      // To test the buyer view, return buyerResponse instead of sellerResponse
      resolve(buyerResponse)
    }, 500)
  })
}

const isCancellable = computed(() => {
  if (!order.value) return false
  const nonCancellableStatus = ['completed', 'shipped']
  return !nonCancellableStatus.includes(order.value.orderStatus)
})

const showCancelModal = () => {
  pendingAction.value = 'cancel'
  modalTitle.value = 'Confirm Order Cancellation'
  modalMessage.value = 'Are you sure you want to cancel this order? This action cannot be undone.'
  isModalVisible.value = true
}

const showHelpModal = () => {
  pendingAction.value = 'help'
  modalTitle.value = 'Contact Support'
  modalMessage.value =
    'For any questions or issues with your order, please contact our support team at support@example.com.'
  isModalVisible.value = true
}

const handleModalClose = () => {
  isModalVisible.value = false
  pendingAction.value = null
}

const handleModalConfirm = async () => {
  if (pendingAction.value === 'cancel') {
    console.log('--- Initiating Cancel Order API call ---')
    alert('Order cancellation request has been submitted.')
  }
  handleModalClose()
}

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
h1 { font-size: 2.2rem; margin: 0; }
<<<<<<< HEAD
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; }
h3 { font-size: 1.4rem; margin: 0; }
=======
h2 { font-family: Bodoni Moda, BlinkMacSystemFont; border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; }
h3 { font-family: Bodoni Moda, BlinkMacSystemFont; text-shadow: 1px 1px 1px rgba(0, 0, 0, 0.3); font-size: 1.4rem; margin: 0; color: black }
>>>>>>> b586519 (Recovery: Saving all current work)
h4 { font-size: 1.4rem; margin: 0 0 0.5rem; }
p { color: #ccc; line-height: 1.6; }
ul { list-style: none; padding: 0; }
.btn { border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.6rem 1.2rem; transition: background-color 0.2s; }
.btn-danger { background-color: #4a1a1a; border: 1px solid #f06e6e; color: #f06e6e; }
.btn-danger:hover { background-color: #5d2020; }
.btn-secondary { background-color: #2f2f2f; border: 1px solid #555; color: #e0e0e0; }
.btn-secondary:hover { background-color: #3f3f3f; }
.button-group { display: flex; flex-direction: column; gap: 1rem; }
.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.card li { align-items: center; color: #ccc; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.card li.total { font-size: 1.1rem; font-weight: bold; margin-top: 1rem; }
.card li.total span { color: #ffffff; }
.error-state, .loading-state { align-items: center; display: flex; height: 50vh; justify-content: center; }
.header-info { flex-grow: 1; }
.header-status { flex-shrink: 0; }
.modal-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; }
.modal-content { background-color: #1e1e1e; border: 1px solid #333; border-radius: 12px; max-width: 500px; padding: 2rem; width: 90%; }
.modal-content p { color: #ccc; line-height: 1.6; margin-bottom: 0; }
.modal-overlay { align-items: center; background-color: rgba(0, 0, 0, 0.7); display: flex; height: 100%; justify-content: center; left: 0; position: fixed; top: 0; width: 100%; z-index: 1000; }
.order-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.order-detail-container { color: #ffffff; font-family: Spectral, sans-serif; }
.order-grid { align-items: start; display: grid; gap: 3rem; grid-template-columns: 2fr 1fr; margin-top: 3rem; }
.order-header { align-items: flex-start; border-bottom: 1px solid #333; display: flex; justify-content: space-between; padding-bottom: 1.5rem; }
.order-header p { color: #888; margin: 0.25rem 0 0; }
.order-sidebar { display: flex; flex-direction: column; gap: 2rem; }
<<<<<<< HEAD
.product-details p { color: #ccc; margin: 0.5rem 0; }
.product-details p span { color: #888; font-weight: bold; }
.product-image { background-color: #111; border-radius: 8px; flex-shrink: 0; height: 150px; width: 150px; }
.product-image img { border-radius: 8px; height: 100%; object-fit: contain; width: 100%; }
.product-summary { align-items: center; display: flex; gap: 2rem; }
=======
.product-details p { font-family: Bodoni Moda, BlinkMacSystemFont; font-weight: bold; color: black; margin: 0.5rem 0; }
.product-details p span { color: rgba(0, 0, 0, 0.5); font-weight: bold; }
.product-image { background-color: white; border-radius: 8px; flex-shrink: 0; height: 150px; width: 150px; }
.product-image img { border-radius: 8px; height: 100%; object-fit: contain; width: 100%; }
.product-summary { align-items: center; display: flex; gap: 2rem; background-color: white; }
>>>>>>> b586519 (Recovery: Saving all current work)
.role-indicator { padding: 1rem 2rem; text-align: center; }
.role-indicator p { font-size: 1.1rem; margin: 0; text-transform: capitalize; }
.role-indicator strong { color: #6ef0a3; }
.status-badge { border-radius: 12px; font-size: 0.9rem; font-weight: bold; padding: 0.4rem 1rem; text-transform: capitalize; }
.status-cancelled { background-color: #4a1a1a; color: #f06e6e; }
.status-completed { background-color: #1a4a32; color: #6ef0a3; }
.status-pending { background-color: #4a411a; color: #f0d56e; }
.status-shipped { background-color: #1a414a; color: #6ee3f0; }
.timeline { align-items: flex-start; display: flex; justify-content: space-between; }
.timeline-connector { background-color: #333; flex-grow: 1; height: 2px; margin: 0 1rem; position: relative; top: 8px; }
.timeline-date { color: #888; font-size: 0.85rem; margin-top: 0.25rem; }
.timeline-dot { background-color: #444; border: 2px solid #666; border-radius: 50%; height: 12px; margin: 0 auto; transition: all 0.3s ease; width: 12px; }
.timeline-info { text-align: center; }
.timeline-item { position: relative; width: 100px; }
.timeline-item.complete .timeline-connector { background-color: #6ef0a3; }
.timeline-item.complete .timeline-dot { background-color: #6ef0a3; border-color: #6ef0a3; }
.timeline-item.complete .timeline-title { color: #ffffff; }
.timeline-section { margin-bottom: 0; }
.timeline-section h2 { margin-bottom: 2.5rem; }
.timeline-title { font-weight: bold; margin: 0.75rem 0 0; transition: color 0.3s ease; }
</style>
