<template>
  <div class="bid-container">
    <main class="bid-content">
      <div v-if="isLoading" class="loading-overlay">
        <div class="spinner"></div>
        <p>Submitting your bid...</p>
      </div>

      <div v-else-if="submissionResult" class="submission-result-screen">
        <div v-if="submissionResult.success" class="result-card">
          <svg
            class="result-icon success"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
          <h2>Bid Placed!</h2>
          <p>Your bid has been successfully submitted.</p>
          <p>You will be notified if it is accepted.</p>
          <div class="result-summary">
            <p><strong>Item:</strong> {{ product.name }}</p>
            <p><strong>Size:</strong> {{ selectedSize }}</p>
            <p>
              <strong>Your Bid:</strong> {{ formatCurrency(submissionResult.data.bid_amount) }}
            </p>
            <p>
              <strong>Total:</strong>
              {{ formatCurrency(submissionResult.data.total_bid_amount) }}
            </p>
          </div>
          <button @click="router.back()" class="btn btn-primary">Continue Shopping</button>
        </div>
        <div v-else class="result-card">
          <svg
            class="result-icon error"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z"
            />
          </svg>
          <h2>Something Went Wrong</h2>
          <p>{{ submissionResult.message || "We couldn't process your bid. Please try again." }}</p>
          <button @click="submissionResult = null" class="btn btn-secondary">Try Again</button>
        </div>
      </div>

      <template v-else>
        <h1 class="page-title">Place Your Bid</h1>
        <div class="bid-grid">
          <div class="product-summary">
            <img :src="product.imageUrl" :alt="product.name" class="product-image" />
            <div class="product-info">
              <h2 class="brand-name">{{ product.brandName }}</h2>
              <h3 class="product-name">{{ product.name }}</h3>
              <p class="product-size">Size: {{ selectedSize }}</p>
            </div>
          </div>

          <div class="bid-steps-col">
            <div v-if="currentStep === 1" class="bid-form">
              <div class="section-header">
                <h2>Enter Your Bid</h2>
                <button @click="nextStep" :disabled="!isStepReady" class="btn-nav">
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
                      d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3"
                    />
                  </svg>
                </button>
              </div>
              <div class="market-context">
                <div class="market-item">
                  <span>Highest Bid</span>
                  <p>{{ formatCurrency(marketInfo.highestBid) }}</p>
                </div>
                <div class="market-item">
                  <span>Lowest Ask</span>
                  <p>{{ formatCurrency(marketInfo.lowestAsk) }}</p>
                </div>
              </div>
              <div class="bid-input-group">
                <span class="currency-symbol">$</span>
                <input
                  :value="bidInput"
                  @input="filterBidInput"
                  type="text"
                  class="bid-input"
                  placeholder="0.00"
                />
              </div>
              <p v-if="bidMatchesHighestError" class="error-message">
                Your bid cannot be the same as the current highest bid.
              </p>
              <ul class="fee-breakdown">
                <li>
                  <span>Your Bid</span>
                  <span>{{ formatCurrency(bidAmount) }}</span>
                </li>
                <li>
                  <span>Transaction Fee ({{ (transactionFeeRate.rate * 100).toFixed(2) }}%)</span>
                  <span>+ {{ formatCurrency(transactionFee) }}</span>
                </li>
                <li class="total-cost">
                  <span>Total</span>
                  <span>{{ formatCurrency(totalCost) }}</span>
                </li>
              </ul>
            </div>

            <div v-if="currentStep === 2" class="bid-form">
              <div class="section-header">
                <button @click="prevStep" class="btn-nav">
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
                      d="M6.75 15.75 3 12m0 0 3.75-3.75M3 12h18"
                    />
                  </svg>
                </button>
                <h2>Confirm Bid</h2>
                <div class="nav-placeholder"></div>
              </div>

              <ul class="fee-breakdown">
                <li>
                  <span>Your Bid</span>
                  <span>{{ formatCurrency(bidAmount) }}</span>
                </li>
                <li>
                  <span>Transaction Fee ({{ (transactionFeeRate.rate * 100).toFixed(2) }}%)</span>
                  <span>+ {{ formatCurrency(transactionFee) }}</span>
                </li>
                <li class="total-cost">
                  <span>Total</span>
                  <span>{{ formatCurrency(totalCost) }}</span>
                </li>
              </ul>

              <div class="payment-section">
                <h4 class="payment-title">Payment Method</h4>
                <div class="payment-options">
                  <div
                    class="payment-option"
                    :class="{ selected: paymentMethod === 'account_balance', disabled: !canUseBalance }"
                    @click="selectPaymentMethod('account_balance')"
                  >
                    <span class="option-name">Account Balance</span>
                    <span class="option-detail">{{ formatCurrency(userBalance) }}</span>
                  </div>
                  <div
                    class="payment-option"
                    :class="{ selected: paymentMethod === 'credit_card' }"
                    @click="selectPaymentMethod('credit_card')"
                  >
                    <span class="option-name">Credit Card</span>
                    <span class="option-detail">**** 1234</span>
                  </div>
                </div>
                <p v-if="!canUseBalance && bidAmount > 0" class="balance-insufficient">
                  Insufficient balance for this bid.
                </p>
              </div>

              <p v-if="bidMatch" class="bid-match-message">
                Your bid matches the current lowest ask. Placing this bid will result in an
                immediate purchase.
              </p>

              <button @click="submitBid" :disabled="!isBidValid" class="btn-submit-bid">
                {{ submitButtonText }}
              </button>
              <p v-if="!bidMatch" class="disclaimer">
                By placing a bid, you are committing to buy this item if your bid is accepted.
              </p>
            </div>
          </div>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import { getBuyerFee } from '@/utils/fees.js'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const currentStep = ref(1)
const totalSteps = 2

const productId = route.params.listingId
const selectedSize = ref(route.query.size || null)
const selectedCondition = ref(route.query.condition || null)

const product = ref({
  brandName: 'Loading...',
  name: '...',
  imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item',
})

const marketInfo = ref({ highestBid: null, lowestAsk: null })
const bidAmount = ref(null)
const bidInput = ref('')
const userBalance = ref(0)
const paymentMethod = ref(null)

const bidMatch = ref(false)
const submitButtonText = ref('Confirm Bid')

const isLoading = ref(false)
const submissionResult = ref(null)

const MIN_BID = 0.01
const MAX_BID = 99999999.99
let transactionFeeRate = ref({
  rateId: null,
  rate: 0.01,
})

const transactionFee = computed(() => (bidAmount.value || 0) * transactionFeeRate.value.rate)
const totalCost = computed(() => (bidAmount.value || 0) + transactionFee.value)
const canUseBalance = computed(() => userBalance.value >= totalCost.value)

const isBidAmountValid = computed(() => {
  return (
    typeof bidAmount.value === 'number' &&
    !isNaN(bidAmount.value) &&
    bidAmount.value >= MIN_BID &&
    bidAmount.value <= MAX_BID
  )
})

const bidMatchesHighestError = computed(() => {
  return (
    bidAmount.value !== null && bidAmount.value > 0 && bidAmount.value === marketInfo.value.highestBid
  )
})

const isStepReady = computed(() => {
  if (currentStep.value === 1) {
    return isBidAmountValid.value && !bidMatchesHighestError.value
  }
  if (currentStep.value === 2) return !!paymentMethod.value
  return false
})

const isBidValid = computed(
  () =>
    isBidAmountValid.value &&
    !bidMatchesHighestError.value &&
    !!paymentMethod.value &&
    selectedSize.value &&
    selectedCondition.value
)

const formatCurrency = (amount) => {
  if (typeof amount !== 'number' || isNaN(amount)) return '---'
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

function selectPaymentMethod(method) {
  if (method === 'account_balance' && !canUseBalance.value) return
  paymentMethod.value = method
}

function nextStep() {
  if (currentStep.value < totalSteps) currentStep.value++
}

function prevStep() {
  if (currentStep.value > 1) currentStep.value--
}

onMounted(async () => {
  try {
    const [feeData, productResponse, balanceData] = await Promise.all([
      getBuyerFee(),
      fetchFromAPI(`/search/${productId}`),
      fetchFromAPI(`/users/${authStore.uuid}/balance`),
    ])

    transactionFeeRate.value.rateId = feeData.id
    transactionFeeRate.value.rate = feeData.buyer_fee_percentage

    if (productResponse) {
      product.value = productResponse
    }

    if (productResponse.sizes && selectedSize.value && selectedCondition.value) {
      const sizeData = productResponse.sizes.find((s) => s.size === selectedSize.value)

      if (sizeData) {
        const bidData = sizeData.highestBid[selectedCondition.value]
        const askData = sizeData.lowestAskingPrice[selectedCondition.value]

        marketInfo.value = {
          highestBid: bidData ? bidData.amount : null,
          lowestAsk: askData ? askData.price : null,
        }
      }
    }

    if (balanceData && typeof balanceData.balance === 'number') {
      userBalance.value = balanceData.balance
    }
  } catch (error) {
    console.error('Error fetching page data:', error)
  }
})

watch(bidAmount, (newValue) => {
  if (marketInfo.value.lowestAsk > 0 && newValue === marketInfo.value.lowestAsk) {
    bidMatch.value = true
    submitButtonText.value = 'Buy Now'
  } else {
    bidMatch.value = false
    submitButtonText.value = 'Confirm Bid'
  }
})

async function submitBid() {
  if (!isBidValid.value) return

  isLoading.value = true
  submissionResult.value = null

  try {
    const bidResponse = await postToAPI(`/bids/${authStore.uuid}`, {
      user_id: authStore.uuid,
      product_id: productId,
      size: selectedSize.value,
      product_condition: selectedCondition.value,
      bid_amount: bidAmount.value,
      fee_structure_id: transactionFeeRate.value.rateId,
      payment_origin: paymentMethod.value,
    })

    if (bidResponse && bidResponse.bid_id) {
      submissionResult.value = { success: true, data: bidResponse }
    } else {
      throw new Error('Invalid response from server.')
    }
  } catch (error) {
    submissionResult.value = {
      success: false,
      message: error.data?.message || error.message || 'An unknown error occurred.',
    }
    console.error('Error submitting bid:', error)
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
@media (max-width: 768px) { .bid-grid { grid-template-columns: 1fr; } .product-summary { margin-bottom: 2rem; } }
h1, h2, h3, h4 { font-family: Spectral, sans-serif; font-weight: 600; }
h1.page-title { border-bottom: 1px solid #333; font-size: 2.2rem; margin-bottom: 3rem; padding-bottom: 1.5rem; text-align: center; }
h2 { flex-grow: 1; font-size: 1.8rem; margin: 0; text-align: center; }
h2.brand-name { color: #ccc; font-size: 1.2rem; margin: 0; }
h3.product-name { font-size: 1.5rem; margin: 0.25rem 0 0; }
p { color: #cccccc; line-height: 1.6; }
.balance-insufficient { color: #ff6b6b; font-size: 0.9rem; margin-top: 1rem; text-align: center; }
.bid-container { color: #ffffff; padding: 4rem 5%; }
.bid-content { margin: 0 auto; max-width: 900px; }
.bid-form { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.bid-grid { display: grid; gap: 3rem; grid-template-columns: 1fr 1.25fr; }
.bid-input { background-color: transparent; border: none; color: #ffffff; font-size: 2rem; font-weight: bold; outline: none; text-align: left; width: 100%; }
.bid-input-group { align-items: baseline; border-bottom: 2px solid #555; display: flex; margin: 2rem 0; padding-bottom: 0.5rem; transition: border-color 0.3s; }
.bid-input-group:focus-within { border-color: #ffffff; }
.bid-match-message { color: #6ef0a3; font-size: 0.9rem; margin-top: 1rem; text-align: center; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-nav { align-items: center; background: transparent; border: 1px solid #444; border-radius: 50%; color: #ccc; cursor: pointer; display: flex; height: 44px; justify-content: center; padding: 0; transition: all 0.2s ease; width: 44px; }
.btn-nav svg { height: 24px; width: 24px; }
.btn-nav:disabled { cursor: not-allowed; opacity: 0.4; }
.btn-nav:hover:not(:disabled) { background-color: #2a2a2a; border-color: #666; color: #fff; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.btn-submit-bid { background-color: #ffffff; border: 1px solid #ffffff; border-radius: 8px; color: #121212; cursor: pointer; font-size: 1.1rem; font-weight: bold; margin-top: 2rem; padding: 1rem; transition: background-color 0.3s, color 0.3s; width: 100%; }
.btn-submit-bid:disabled { cursor: not-allowed; opacity: 0.6; }
.btn-submit-bid:hover:not(:disabled) { background-color: transparent; color: #ffffff; }
.currency-symbol { color: #888; font-size: 2rem; font-weight: bold; }
.disclaimer { color: #888; font-size: 0.8rem; margin-top: 1rem; text-align: center; }
.error-message { color: #f06e6e; font-size: 0.9rem; margin-bottom: 1.5rem; margin-top: -1rem; text-align: center; }
.fee-breakdown { list-style: none; margin: 0 0 2rem; padding: 0; }
.fee-breakdown li { align-items: center; display: flex; font-size: 1rem; justify-content: space-between; margin-bottom: 0.75rem; }
.fee-breakdown span:first-child { color: #aaa; }
.loading-overlay { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 500px; padding: 2rem; }
.loading-overlay p { color: #888; font-weight: bold; margin-top: 1rem; }
.market-context { border-bottom: 1px solid #333; display: grid; grid-template-columns: 1fr 1fr; padding-bottom: 1rem; text-align: center; }
.market-item p { font-size: 1.5rem; font-weight: bold; margin: 0.25rem 0 0; }
.market-item span { color: #888; display: block; font-size: 0.9rem; }
.nav-placeholder { height: 44px; width: 44px; }
.option-detail { color: #aaa; }
.option-name { font-weight: 600; }
.payment-option { align-items: center; background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; cursor: pointer; display: flex; justify-content: space-between; padding: 1rem; transition: border-color 0.2s ease, background-color 0.2s ease; }
.payment-option.disabled { cursor: not-allowed; opacity: 0.5; }
.payment-option.disabled:hover { background-color: #2c2c2c; border-color: #444; }
.payment-option.selected { border-color: #6ef0a3; }
.payment-option:hover { background-color: #333; }
.payment-options { display: flex; flex-direction: column; gap: 1rem; }
.payment-section { border-top: 1px solid #333; margin-top: 2rem; padding-top: 2rem; }
.payment-title { color: #e0e0e0; font-size: 1.1rem; margin-bottom: 1.5rem; text-align: left; }
.product-image { border-radius: 8px; margin-bottom: 1.5rem; max-width: 100%; }
.product-info { text-align: center; }
.product-size { color: #aaa; font-size: 1.1rem; margin-top: 0.5rem; }
.product-summary { align-items: center; display: flex; flex-direction: column; justify-content: center; }
.result-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; max-width: 450px; padding: 2rem; text-align: center; width: 100%; }
.result-icon { height: 80px; margin-bottom: 1rem; width: 80px; }
.result-icon.error { color: #f06e6e; }
.result-icon.success { color: #6ef0a3; }
.result-summary { background-color: #121212; border-radius: 8px; margin: 1.5rem 0; padding: 1rem; text-align: left; }
.result-summary p { margin: 0.5rem 0; }
.section-header { align-items: center; display: flex; justify-content: space-between; margin-bottom: 2rem; }
.spinner { animation: spin 1s linear infinite; border: 4px solid #333; border-radius: 50%; border-top: 4px solid #ffffff; height: 50px; width: 50px; }
.submission-result-screen { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 500px; padding: 2rem; }
.total-cost { border-top: 1px solid #333; font-size: 1.2rem !important; font-weight: bold; margin-top: 1rem; padding-top: 1rem; }
</style>
