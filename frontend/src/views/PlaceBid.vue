<template>
  <div class="bid-container">
    <main class="bid-content">
      <!-- Loading Overlay -->
      <div v-if="isLoading" class="loading-overlay">
        <div class="spinner"></div>
        <p>Submitting your bid...</p>
      </div>

      <div v-else-if="submissionResult" class="submission-result-screen">
        <div v-if="submissionResult.success" class="result-card">
          <svg class="result-icon success" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
          </svg>
          <h2>Bid Placed!</h2>
          <p>Your bid has been successfully submitted.</p>
          <p>You will be notified if it is accepted.</p>
          <div class="result-summary">
            <p><strong>Item:</strong> {{ product.name }}</p>
            <p><strong>Size:</strong> {{ selectedSize }}</p>
            <p><strong>Your Bid:</strong> {{ formatCurrency(submissionResult.data.bid_amount) }}</p>
            <p><strong>Total:</strong> {{ formatCurrency(submissionResult.data.total_bid_amount) }}</p>
          </div>
          <button @click="router.back()" class="btn btn-primary">Continue Shopping</button>
        </div>
        <div v-else class="result-card">
          <svg class="result-icon error" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
          </svg>
          <h2>Something Went Wrong</h2>
          <p>{{ submissionResult.message || 'We couldn\'t process your bid. Please try again.' }}</p>
          <button @click="submissionResult = null" class="btn btn-secondary">Try Again</button>
        </div>
      </div>

      <template v-else>
        <h1 class="page-title">Place Your Bid</h1>
        <div class="bid-grid">
          <div class="product-summary">
            <img :src="product.image_url" :alt="product.name" class="product-image" />
            <div class="product-info">
              <h2 class="brand-name">{{ product.brand_name }}</h2>
              <h3 class="product-name">{{ product.name }}</h3>
              <p class="product-size">Size: {{ selectedSize }}</p>
              <p class="product-size">Condition: {{ selectedCondition }}</p>
            </div>
          </div>

          <div class="bid-form">
            <div class="market-context">
              <div class="market-item">
                <span>Highest Bid</span>
                <p>{{ formatCurrency(marketInfo.highest_bid) }}</p>
              </div>
              <div class="market-item">
                <span>Lowest Ask</span>
                <p>{{ formatCurrency(marketInfo.lowest_ask) }}</p>
              </div>
            </div>

            <div class="bid-input-group">
              <span class="currency-symbol">$</span>
              <input :value="bidInput" @input="filterBidInput" type="text" class="bid-input" placeholder="0.00" />
            </div>

            <ul class="fee-breakdown">
              <li>
                <span>Your Bid</span>
                <span>{{ formatCurrency(bidAmount) }}</span>
              </li>
              <li>
                <span>Transaction Fee ({{ transactionFeeRate * 100 }}%)</span>
                <span>+ {{ formatCurrency(transactionFee) }}</span>
              </li>
              <li class="total-cost">
                <span>Total</span>
                <span>{{ formatCurrency(totalCost) }}</span>
              </li>
            </ul>

            <button @click="submitBid" :disabled="!isBidValid" class="btn-submit-bid">Confirm Bid</button>
            <p class="disclaimer">
              By placing a bid, you are committing to buy this item if your bid is accepted.
            </p>
          </div>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const product_id = route.params.listingId
const selectedSize = ref(route.query.size || 'N/A')
const selectedCondition = ref(route.query.condition || 'N/A')

const product = ref({
  brand_name: 'Loading...',
  name: '...',
  image_url: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item',
})

const marketInfo = ref({ highest_bid: 0, lowest_ask: 0, })
const bidAmount = ref(null)
const bidInput = ref('')

const isLoading = ref(false);
const submissionResult = ref(null);

const MIN_BID = 0.01
const MAX_BID = 99999999.99
const transactionFeeRate = 0.05 // 5%

const transactionFee = computed(() => (bidAmount.value || 0) * transactionFeeRate)
const totalCost = computed(() => (bidAmount.value || 0) + transactionFee.value)
const isBidValid = computed(() => typeof bidAmount.value === 'number' && !isNaN(bidAmount.value) && bidAmount.value >= MIN_BID && bidAmount.value <= MAX_BID)

const formatCurrency = (amount) => {
  if (typeof amount !== 'number' || isNaN(amount)) return '$0.00'
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const filterBidInput = (event) => {
  const previous = bidInput.value
  let value = event.target.value
  const validFormat = /^\d*(?:\.\d{0,2})?$/.test(value)
  if (!validFormat) {
    event.target.value = previous
    bidInput.value = previous
    return
  }
  if (value === '') {
    bidInput.value = ''
    bidAmount.value = null
    return
  }
  const parsed = Number(value)
  if (isNaN(parsed) || parsed > MAX_BID) {
    event.target.value = previous
    bidInput.value = previous
    return
  }
  bidInput.value = value
  bidAmount.value = parsed
}

onMounted(async () => {
  try {
    const productResponse = await fetchFromAPI(`/product/${product_id}`)
    const productData = productResponse.productInfo

    if (productData) product.value = productData
  } catch (error) {
    console.error('Error fetching page data:', error)
  }
})

async function submitBid() {
  if (!isBidValid.value) return;

  isLoading.value = true;
  submissionResult.value = null;

  try {
    const bidToSubmit = Math.round(bidAmount.value * 100) / 100
    const totalAmount = bidToSubmit + transactionFee.value

    const bidResponse = await postToAPI(`/bids/${authStore.uuid}`, {
      user_id: authStore.uuid,
      product_id: product_id,
      size: selectedSize.value,
      product_condition: selectedCondition.value,
      bid_amount: bidToSubmit,
      transaction_fee: transactionFee.value,
      total_amount: totalAmount,
      bid_status: "pending"
    });

    if (bidResponse && bidResponse.bid_id) {
      submissionResult.value = { success: true, data: bidResponse };
    } else {
      throw new Error('Invalid response from server.');
    }

  } catch (error) {
    submissionResult.value = { success: false, message: error.message || 'An unknown error occurred.' };
    console.error('Error submitting bid:', error);
  } finally {
    isLoading.value = false;
  }
}
</script>

<style scoped>
/* General Styles */
h1, h2, h3 { font-family: Spectral, sans-serif; font-weight: 600; }
h1.page-title { border-bottom: 1px solid #333; font-size: 2.2rem; margin-bottom: 3rem; padding-bottom: 1.5rem; text-align: center; }
h2 { font-size: 1.8rem; margin-bottom: 0.5rem; }
p { color: #cccccc; line-height: 1.6; }
.bid-container { color: #ffffff; padding: 4rem 5%; }
.bid-content { margin: 0 auto; max-width: 900px; }

/* Loading and Submission Result Styles */
.loading-overlay, .submission-result-screen { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 500px; padding: 2rem; }
.spinner { animation: spin 1s linear infinite; border: 4px solid #333; border-radius: 50%; border-top: 4px solid #ffffff; height: 50px; width: 50px; }
.loading-overlay p { color: #888; font-weight: bold; margin-top: 1rem; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
.result-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; text-align: center; max-width: 450px; width: 100%; }
.result-icon { height: 80px; margin-bottom: 1rem; width: 80px; }
.result-icon.success { color: #6ef0a3; }
.result-icon.error { color: #f06e6e; }
.result-summary { background-color: #121212; border-radius: 8px; margin: 1.5rem 0; padding: 1rem; text-align: left; }
.result-summary p { margin: 0.5rem 0; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }

/* Bid Form Styles */
.bid-grid { display: grid; gap: 3rem; grid-template-columns: 1fr 1.25fr; }
.product-summary { align-items: center; display: flex; flex-direction: column; justify-content: center; }
.product-image { border-radius: 8px; margin-bottom: 1.5rem; max-width: 100%; }
.product-info { text-align: center; }
h2.brand-name { color: #ccc; font-size: 1.2rem; margin: 0; }
h3.product-name { font-size: 1.5rem; margin: 0.25rem 0 0; }
.product-size { color: #aaa; font-size: 1.1rem; margin-top: 0.5rem; }
.bid-form { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.market-context { border-bottom: 1px solid #333; display: grid; grid-template-columns: 1fr 1fr; padding-bottom: 1rem; text-align: center; }
.market-item span { color: #888; display: block; font-size: 0.9rem; }
.market-item p { font-size: 1.5rem; font-weight: bold; margin: 0.25rem 0 0; }
.bid-input-group { align-items: baseline; border-bottom: 2px solid #555; display: flex; margin: 2rem 0; padding-bottom: 0.5rem; transition: border-color 0.3s; }
.bid-input-group:focus-within { border-color: #ffffff; }
.currency-symbol { color: #888; font-size: 2rem; font-weight: bold; }
.bid-input { background-color: transparent; border: none; color: #ffffff; font-size: 2rem; font-weight: bold; outline: none; text-align: left; width: 100%; }
.fee-breakdown { list-style: none; margin: 0 0 2rem; padding: 0; }
.fee-breakdown li { align-items: center; display: flex; justify-content: space-between; font-size: 1rem; margin-bottom: 0.75rem; }
.fee-breakdown span:first-child { color: #aaa; }
.total-cost { border-top: 1px solid #333; font-size: 1.2rem !important; font-weight: bold; margin-top: 1rem; padding-top: 1rem; }
.btn-submit-bid { background-color: #ffffff; border: 1px solid #ffffff; border-radius: 8px; color: #121212; cursor: pointer; font-size: 1.1rem; font-weight: bold; padding: 1rem; transition: background-color 0.3s, color 0.3s; width: 100%; }
.btn-submit-bid:hover { background-color: transparent; color: #ffffff; }
.btn-submit-bid:disabled { cursor: not-allowed; opacity: 0.6; }
.disclaimer { color: #888; font-size: 0.8rem; margin-top: 1rem; text-align: center; }

@media (max-width: 768px) {
  .bid-grid { grid-template-columns: 1fr; }
  .product-summary { margin-bottom: 2rem; }
}
</style>
