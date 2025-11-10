<template>
  <div class="order-container">
    <main class="order-content">
      <div v-if="isLoading" class="loading-overlay">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>

      <div v-else-if="submissionResult" class="submission-result-screen">
        <div class="success-icon">
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
              d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
        </div>
        <h2 class="result-title">Purchase Confirmed!</h2>
        <p class="result-subtitle">Your order has been placed successfully.</p>

        <div class="result-summary">
          <ul>
            <li>
              <span>Order ID</span><span>{{ submissionResult.order_id }}</span>
            </li>
            <li>
              <span>Date</span><span>{{ formatOrderDate(submissionResult.created_at) }}</span>
            </li>
            <li class="total">
              <span>Total Amount</span
              ><span>{{ formatCurrency(submissionResult.buyer_final_price) }}</span>
            </li>
          </ul>
        </div>

        <div class="result-actions">
          <router-link to="/" class="btn btn-secondary">Continue Shopping</router-link>
          <router-link to="/orders" class="btn btn-primary">View My Orders</router-link>
        </div>
      </div>

      <div v-else-if="submissionError" class="submission-result-screen error-screen">
        <div class="error-icon">
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
              d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
            />
          </svg>
        </div>
        <h2 class="result-title">Purchase Failed</h2>
        <p class="result-subtitle">
          {{ submissionError.message || 'An unexpected error occurred.' }}
        </p>

        <div class="result-actions">
          <router-link to="/" class="btn btn-secondary">Go to Homepage</router-link>
          <button @click="retryOrder" class="btn btn-primary">Try Again</button>
        </div>
      </div>

      <template v-else-if="listing">
        <h1 class="page-title">Confirm Your Purchase</h1>
        <div class="order-grid">
          <div class="product-summary-col">
            <div class="product-summary">
              <img
                :src="listing.product_image_url"
                :alt="listing.product_name"
                class="product-image"
              />
              <div class="product-info">
                <h3 class="product-name">{{ listing.product_name }}</h3>
                <p class="product-details">Size: {{ listing.size_value }}</p>
                <p class="product-details">Condition: {{ listing.item_condition }}</p>
              </div>
            </div>
          </div>

          <div class="checkout-details-col">
            <div v-if="currentStep === 1" class="info-section shipping-form">
              <div class="section-header">
                <h2>Shipping Address</h2>
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
              <ShippingForm v-model="shippingInfo" />
            </div>

            <div v-if="currentStep === 2" class="info-section payment-section">
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
                <h2>Payment Method</h2>
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
              <div class="payment-options">
                <div
                  class="payment-option"
                  :class="{
                    selected: paymentMethod === 'account_balance',
                    disabled: !canUseBalance,
                  }"
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
              <p v-if="!canUseBalance" class="balance-insufficient">
                Insufficient balance for this purchase.
              </p>
            </div>

            <div v-if="currentStep === 3" class="info-section order-details">
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
                <h2>Order Summary</h2>
                <div class="nav-placeholder"></div>
              </div>
              <div class="shipping-preview">
                <h4>Shipping To</h4>
                <p class="address-line">{{ shippingInfo.name }}</p>
                <p class="address-line">{{ shippingInfo.address_line_1 }}</p>
                <p v-if="shippingInfo.address_line_2" class="address-line">
                  {{ shippingInfo.address_line_2 }}
                </p>
                <p class="address-line">
                  {{ shippingInfo.city }}, {{ shippingInfo.state }} {{ shippingInfo.zip_code }}
                </p>
                <p class="address-line">{{ shippingInfo.country }}</p>
              </div>
              <ul class="order-summary-list">
                <li class="payment-method-summary">
                  <span>Payment Method</span>
                  <span>{{
                      paymentMethod === 'account_balance' ? 'Account Balance' : 'Credit Card'
                    }}</span>
                </li>
                <li>
                  <span>Item Price</span><span>{{ formatCurrency(purchasePrice) }}</span>
                </li>
                <li>
                  <span>Transaction Fee ({{ (transactionFeeRate * 100).toFixed(1) }}%)</span
                  ><span>+ {{ formatCurrency(transactionFee) }}</span>
                </li>
                <li class="total-cost">
                  <span>Total</span><span>{{ formatCurrency(totalCost) }}</span>
                </li>
              </ul>
              <button
                @click="submitOrder"
                :disabled="!isReadyToSubmit"
                class="btn-confirm-purchase"
              >
                Confirm Purchase
              </button>
              <p class="disclaimer">By confirming, you agree to purchase this item.</p>
            </div>
          </div>
        </div>
      </template>
    </main>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import ShippingForm from '@/components/ShippingForm.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const listingId = route.params.listingId

const currentStep = ref(1)
const totalSteps = 3

const listing = ref(null)
const isLoading = ref(true)
const loadingMessage = ref('Loading order details...')
const submissionResult = ref(null)
const submissionError = ref(null)

const shippingInfo = ref({
  name: '',
  address_line_1: '',
  address_line_2: '',
  city: '',
  state: null,
  zip_code: '',
  country: 'United States',
})

const userBalance = ref(0)
const paymentMethod = ref('credit_card')

const transactionFeeRate = ref(0.01)
const transactionFeeStructureId = ref(1)

const purchasePrice = computed(() => listing.value?.price || null)
const transactionFee = computed(() => (purchasePrice.value || 0) * transactionFeeRate.value)
const totalCost = computed(() => (purchasePrice.value || 0) + transactionFee.value)
const canUseBalance = computed(() => userBalance.value >= totalCost.value)

const isOrderValid = computed(
  () => listing.value && typeof listing.value.price === 'number' && listing.value.price > 0,
)
const isFormComplete = computed(() => {
  const { name, address_line_1, city, state, zip_code, country } = shippingInfo.value
  const requiredFields = [name, address_line_1, city, state, zip_code, country]
  return requiredFields.every((field) => field && field.trim() !== '')
})
const isReadyToSubmit = computed(() => isOrderValid.value && isFormComplete.value)

const isStepReady = computed(() => {
  if (currentStep.value === 1) return isFormComplete.value
  if (currentStep.value === 2) return !!paymentMethod.value
  return isReadyToSubmit.value
})

const formatCurrency = (amount) => {
  if (typeof amount !== 'number' || isNaN(amount)) return '—'
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatOrderDate = (dateString) => {
  if (!dateString) return 'N/A'
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('en-US', options)
}

onMounted(async () => {
  try {
    const [listingData, balanceData, feeData] = await Promise.all([
      fetchFromAPI(`/listings/active/id/${listingId}`),
      fetchFromAPI(`/users/${authStore.uuid}/balance`),
      fetchFromAPI('/fees/buyer_fee_percentage'),
    ])

    transactionFeeRate.value = feeData.buyer_fee_percentage
    transactionFeeStructureId.value = feeData.id

    if (listingData && listingData.listing_id) {
      listing.value = listingData
    } else {
      throw new Error('This listing is no longer available.')
    }

    if (balanceData && typeof balanceData.balance === 'number') {
      userBalance.value = balanceData.balance
    }
  } catch (error) {
    console.error('Error fetching initial data:', error)
    router.back()
  } finally {
    isLoading.value = false
  }
})

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

async function submitOrder() {
  submissionError.value = null

  const orderData = {
    buyer_id: authStore.uuid,
    shipping_info: shippingInfo.value,
    listing_id: parseInt(listingId, 10),
    purchase_price: purchasePrice.value,
    transaction_structure_fee_id: transactionFeeStructureId.value,
    payment_method: paymentMethod.value,
  }

  isLoading.value = true
  loadingMessage.value = 'Processing your order...'

  try {
    submissionResult.value = await postToAPI(`/orders/${listingId}`, orderData)
  } catch (error) {
    console.error('Failed to submit order:', error)
    submissionError.value = {
      message:
        error.response?.data?.detail ||
        'There was a problem connecting to the server. Please try again.',
    }
  } finally {
    isLoading.value = false
  }
}

function retryOrder() {
  submissionError.value = null
}
</script>

<style scoped>
h1, h2, h3, h4 { font-family: Spectral, sans-serif; font-weight: 600; }
h1.page-title { border-bottom: 1px solid #333; font-size: 2.2rem; margin-bottom: 3rem; padding-bottom: 1.5rem; text-align: center; }
h2 { flex-grow: 1; font-size: 1.8rem; margin: 0; text-align: center; }
h3.product-name { font-size: 1.5rem; margin: 0.25rem 0 0; }
p { color: #cccccc; line-height: 1.6; }
.balance-insufficient { color: #ff6b6b; font-size: 0.9rem; margin-top: 1rem; text-align: center; }
.btn { border-radius: 8px; cursor: pointer; font-weight: 600; padding: 0.8rem 1.5rem; text-decoration: none; transition: all 0.2s ease; }
.btn-confirm-purchase { background-color: #6ef0a3; border: 1px solid #6ef0a3; border-radius: 8px; color: #121212; cursor: pointer; font-size: 1.1rem; font-weight: bold; padding: 1rem; transition: background-color 0.3s, color 0.3s; width: 100%; }
.btn-confirm-purchase:disabled { cursor: not-allowed; opacity: 0.6; }
.btn-confirm-purchase:hover:not(:disabled) { background-color: transparent; color: #6ef0a3; }
.btn-nav { align-items: center; background: transparent; border: 1px solid #444; border-radius: 50%; color: #ccc; cursor: pointer; display: flex; height: 44px; justify-content: center; padding: 0; transition: all 0.2s ease; width: 44px; }
.btn-nav svg { height: 24px; width: 24px; }
.btn-nav:disabled { cursor: not-allowed; opacity: 0.4; }
.btn-nav:hover:not(:disabled) { background-color: #2a2a2a; border-color: #666; color: #fff; }
.btn-primary { background-color: #6ef0a3; border: none; color: #121212; }
.btn-primary:hover { background-color: #8affbe; }
.btn-secondary { background-color: #2c2c2c; border: 1px solid #444; color: #fff; }
.btn-secondary:hover { background-color: #383838; }
.checkout-details-col { display: flex; flex-direction: column; gap: 2rem; }
.disclaimer { color: #888; font-size: 0.8rem; margin-top: 1rem; text-align: center; }
.error-icon { color: #ff6b6b; margin-bottom: 1.5rem; }
.error-icon svg { height: 80px; width: 80px; }
.error-screen .btn-primary { background-color: #ff6b6b; }
.error-screen .btn-primary:hover { background-color: #ff8a8a; }
.error-screen .result-title { color: #ff8a8a; }
.info-section { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.nav-placeholder { height: 44px; width: 44px; }
.option-detail { color: #aaa; }
.option-name { font-weight: 600; }
.order-container { color: #ffffff; padding: 4rem 5%; }
.order-content { margin: 0 auto; max-width: 1100px; }
.order-grid { align-items: flex-start; display: grid; gap: 3rem; grid-template-columns: 1fr 1.25fr; }
.order-summary-list { list-style: none; margin: 0 0 2rem; padding: 0; }
.order-summary-list li { align-items: center; display: flex; font-size: 1rem; justify-content: space-between; margin-bottom: 0.75rem; }
.order-summary-list span:first-child { color: #aaa; }
.payment-method-summary { border-top: 1px solid #333; margin-top: 1rem; padding-top: 1rem; }
.payment-option { align-items: center; background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; cursor: pointer; display: flex; justify-content: space-between; padding: 1.25rem; transition: border-color 0.2s ease, background-color 0.2s ease; }
.payment-option.disabled { cursor: not-allowed; opacity: 0.5; }
.payment-option.disabled:hover { background-color: #2c2c2c; }
.payment-option.selected { border-color: #6ef0a3; }
.payment-option:hover { background-color: #333; }
.payment-options { display: flex; flex-direction: column; gap: 1rem; }
.product-details { color: #aaa; font-size: 1.1rem; margin-top: 0.5rem; text-transform: capitalize; }
.product-image { max-width: 100%; }
.product-info { text-align: center; }
.product-summary { align-items: center; display: flex; flex-direction: column; }
.product-summary-col { position: sticky; top: 2rem; }
.result-actions { display: flex; gap: 1rem; justify-content: center; }
.result-subtitle { color: #aaa; font-size: 1.1rem; margin-bottom: 2.5rem; }
.result-summary { border-bottom: 1px solid #333; border-top: 1px solid #333; margin-bottom: 2.5rem; padding: 1.5rem 0; text-align: left; }
.result-summary li { display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.result-summary li.total { font-size: 1.1rem; font-weight: bold; margin-top: 1rem; }
.result-summary span:first-child { color: #aaa; }
.result-summary ul { list-style: none; padding: 0; }
.result-title { font-size: 2.5rem; margin-bottom: 0.5rem; }
.section-header { align-items: center; display: flex; justify-content: space-between; margin-bottom: 2rem; }
.shipping-preview { border-bottom: 1px solid #333; margin-bottom: 2rem; padding-bottom: 1.5rem; }
.shipping-preview .address-line { color: #ffffff; font-size: 1rem; line-height: 1.5; margin: 0.25rem 0; }
.shipping-preview h4 { color: #aaa; font-size: 1.1rem; font-weight: 600; margin-bottom: 1rem; }
.submission-result-screen { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin: 4rem auto 0; max-width: 600px; padding: 4rem 2rem; text-align: center; }
.success-icon { color: #6ef0a3; margin-bottom: 1.5rem; }
.success-icon svg { height: 80px; width: 80px; }
.total-cost { border-top: 1px solid #333; font-size: 1.2rem !important; font-weight: bold; margin-top: 1rem; padding-top: 1rem; }
@media (max-width: 900px) {
  .btn { width: 100%; }
  h1.page-title { font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; }
  .order-container { padding: 2rem 5%; }
  .order-grid { grid-template-columns: 1fr; }
  .product-summary { margin: 0 auto 2rem auto; max-width: 300px; }
  .product-summary-col { position: static; }
  .result-actions { flex-direction: column; gap: 0.75rem; }
  .result-title { font-size: 1.8rem; }
  .submission-result-screen { margin-top: 1rem; padding: 2.5rem 1.5rem; }
  .success-icon svg, .error-icon svg { height: 60px; width: 60px; }
}
@media (max-width: 480px) {
  .info-section { padding: 1.5rem; }
  .order-container { padding: 2rem 3%; }
  .submission-result-screen { padding: 2rem 1rem; }
}
</style>
