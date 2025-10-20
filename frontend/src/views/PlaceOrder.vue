<template>
  <div class="order-container">
    <main class="order-content">
      <div v-if="isLoading" class="loading-overlay">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>

      <div v-else-if="submissionResult" class="submission-result-screen">
        <div class="success-icon">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
          </svg>
        </div>
        <h2 class="result-title">Purchase Confirmed!</h2>
        <p class="result-subtitle">Your order has been placed successfully.</p>

        <div class="result-summary">
          <ul>
            <li><span>Order ID</span><span>{{ submissionResult.order_id }}</span></li>
            <li><span>Date</span><span>{{ formatOrderDate(submissionResult.created_at) }}</span></li>
            <li class="total"><span>Total Amount</span><span>{{ formatCurrency(submissionResult.total_price) }}</span></li>
          </ul>
        </div>

        <div class="result-actions">
          <router-link to="/" class="btn btn-secondary">Continue Shopping</router-link>
          <router-link to="/profile/orders" class="btn btn-primary">View My Orders</router-link>
        </div>
      </div>

      <template v-else-if="listing">
        <h1 class="page-title">Confirm Your Purchase</h1>
        <div class="order-grid">
          <div class="product-summary-col">
            <div class="product-summary">
              <img :src="listing.product_image_url" :alt="listing.product_name" class="product-image" />
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
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3" />
                  </svg>
                </button>
              </div>
              <div class="form-grid">
                <div class="form-group full-width"><label for="name">Full Name</label><input type="text" id="name" v-model="shippingInfo.name" /></div>
                <div class="form-group full-width"><label for="address_line_1">Address Line 1</label><input type="text" id="address_line_1" v-model="shippingInfo.address_line_1" /></div>
                <div class="form-group full-width"><label for="address_line_2">Address Line 2 (Optional)</label><input type="text" id="address_line_2" v-model="shippingInfo.address_line_2" /></div>
                <div class="form-group"><label for="city">City</label><input type="text" id="city" v-model="shippingInfo.city" /></div>
                <div class="form-group"><label for="state">State</label><input type="text" id="state" v-model="shippingInfo.state" /></div>
                <div class="form-group"><label for="zip_code">Zip Code</label><input type="text" id="zip_code" v-model="shippingInfo.zip_code" /></div>
                <div class="form-group"><label for="country">Country</label><input type="text" id="country" v-model="shippingInfo.country" /></div>
              </div>
            </div>

            <div v-if="currentStep === 2" class="info-section payment-section">
              <div class="section-header">
                <button @click="prevStep" class="btn-nav">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 15.75 3 12m0 0 3.75-3.75M3 12h18" />
                  </svg>
                </button>
                <h2>Payment Method</h2>
                <button @click="nextStep" :disabled="!isStepReady" class="btn-nav">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3" />
                  </svg>
                </button>
              </div>
              <div class="payment-options">
                <div class="payment-option" :class="{ selected: paymentMethod === 'account_balance', disabled: !canUseBalance }" @click="selectPaymentMethod('account_balance')">
                  <span class="option-name">Account Balance</span>
                  <span class="option-detail">{{ formatCurrency(userBalance) }}</span>
                </div>
                <div class="payment-option" :class="{ selected: paymentMethod === 'credit_card' }" @click="selectPaymentMethod('credit_card')">
                  <span class="option-name">Credit Card</span>
                  <span class="option-detail">**** 1234</span>
                </div>
              </div>
              <p v-if="!canUseBalance" class="balance-insufficient">Insufficient balance for this purchase.</p>
            </div>

            <div v-if="currentStep === 3" class="info-section order-details">
              <div class="section-header">
                <button @click="prevStep" class="btn-nav">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 15.75 3 12m0 0 3.75-3.75M3 12h18" />
                  </svg>
                </button>
                <h2>Order Summary</h2>
                <div class="nav-placeholder"></div>
              </div>
              <div class="shipping-preview">
                <h4>Shipping To</h4>
                <p class="address-line">{{ shippingInfo.name }}</p>
                <p class="address-line">{{ shippingInfo.address_line_1 }}</p>
                <p v-if="shippingInfo.address_line_2" class="address-line">{{ shippingInfo.address_line_2 }}</p>
                <p class="address-line">{{ shippingInfo.city }}, {{ shippingInfo.state }} {{ shippingInfo.zip_code }}</p>
                <p class="address-line">{{ shippingInfo.country }}</p>
              </div>
              <ul class="order-summary-list">
                <li class="payment-method-summary">
                  <span>Payment Method</span>
                  <span>{{ paymentMethod === 'account_balance' ? 'Account Balance' : 'Credit Card' }}</span>
                </li>
                <li><span>Item Price</span><span>{{ formatCurrency(purchasePrice) }}</span></li>
                <li><span>Transaction Fee ({{ (transactionFeeRate * 100).toFixed(1) }}%)</span><span>+ {{ formatCurrency(transactionFee) }}</span></li>
                <li class="total-cost"><span>Total</span><span>{{ formatCurrency(totalCost) }}</span></li>
              </ul>
              <button @click="submitOrder" :disabled="!isReadyToSubmit" class="btn-confirm-purchase">
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
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { fetchFromAPI, postToAPI } from '@/utils/index.js';
import { useAuthStore } from '@/stores/authStore.js';

const route = useRoute();
const router = useRouter();
const authStore = useAuthStore();
const listingId = route.params.listingId;

const currentStep = ref(1);
const totalSteps = 3;

const listing = ref(null);
const isLoading = ref(true);
const loadingMessage = ref('Loading order details...');
const submissionResult = ref(null);

const shippingInfo = ref({
  name: '',
  address_line_1: '',
  address_line_2: '',
  city: '',
  state: '',
  zip_code: '',
  country: 'United States',
});

const userBalance = ref(0);
const paymentMethod = ref('credit_card');

const transactionFeeRate = 0.05;

const purchasePrice = computed(() => listing.value?.price || null);
const transactionFee = computed(() => (purchasePrice.value || 0) * transactionFeeRate);
const totalCost = computed(() => (purchasePrice.value || 0) + transactionFee.value);
const canUseBalance = computed(() => userBalance.value >= totalCost.value);

const isOrderValid = computed(() => listing.value && typeof listing.value.price === 'number' && listing.value.price > 0);
const isFormComplete = computed(() => {
  const { name, address_line_1, city, state, zip_code, country } = shippingInfo.value;
  const requiredFields = [name, address_line_1, city, state, zip_code, country];
  return requiredFields.every(field => field && field.trim() !== '');
});
const isReadyToSubmit = computed(() => isOrderValid.value && isFormComplete.value);

const isStepReady = computed(() => {
  if (currentStep.value === 1) return isFormComplete.value;
  if (currentStep.value === 2) return !!paymentMethod.value;
  return isReadyToSubmit.value;
});

const formatCurrency = (amount) => {
  if (typeof amount !== 'number' || isNaN(amount)) return '—';
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
};

// NEW: Helper function to format the order date
const formatOrderDate = (dateString) => {
  if (!dateString) return 'N/A';
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  return new Date(dateString).toLocaleDateString('en-US', options);
};

onMounted(async () => {
  try {
    const [listingData, balanceData] = await Promise.all([
      fetchFromAPI(`/listings/active/id/${listingId}`),
      fetchFromAPI(`/users/${authStore.uuid}/balance`)
    ]);

    if (listingData && listingData.listing_id) {
      listing.value = listingData;
    } else {
      throw new Error('This listing is no longer available.');
    }

    if (balanceData && typeof balanceData.balance === 'number') {
      userBalance.value = balanceData.balance;
    }
  } catch (error) {
    console.error('Error fetching initial data:', error);
    router.back();
  } finally {
    isLoading.value = false;
  }
});

function selectPaymentMethod(method) {
  if (method === 'account_balance' && !canUseBalance.value) return;
  paymentMethod.value = method;
}

function nextStep() {
  if (currentStep.value < totalSteps) currentStep.value++;
}

function prevStep() {
  if (currentStep.value > 1) currentStep.value--;
}

// MODIFIED: submitOrder now handles loading state and sets the result
async function submitOrder() {
  const orderData = {
    buyer_id: authStore.uuid,
    shipping_info: shippingInfo.value,
    listing_id: parseInt(listingId, 10),
    transaction_fee: transactionFee.value,
    payment_method: paymentMethod.value,
  };

  console.log('Submitting order:', orderData);

  isLoading.value = true;
  loadingMessage.value = 'Processing your order...';

  try {
    const response = await postToAPI(`/orders/${listingId}`, orderData);
    submissionResult.value = response; // Set the response to show the confirmation screen
  } catch (error) {
    console.error('Failed to submit order:', error);
    // You could add an error message to the UI here
    alert('There was an error submitting your order. Please try again.');
  } finally {
    isLoading.value = false;
  }
}
</script>

<style scoped>
/* --- Styles --- */
h1, h2, h3, h4 { font-family: Spectral, sans-serif; font-weight: 600; }
h1.page-title { border-bottom: 1px solid #333; font-size: 2.2rem; margin-bottom: 3rem; padding-bottom: 1.5rem; text-align: center; }
h2 { font-size: 1.8rem; margin: 0; text-align: center; flex-grow: 1; }
h3.product-name { font-size: 1.5rem; margin: 0.25rem 0 0; }
p { color: #cccccc; line-height: 1.6; }
.order-container { color: #ffffff; padding: 4rem 5%; }
.order-content { margin: 0 auto; max-width: 1100px; }
.order-grid { align-items: flex-start; display: grid; gap: 3rem; grid-template-columns: 1fr 1.25fr; }
.product-summary-col { position: sticky; top: 2rem; }
.product-summary { align-items: center; display: flex; flex-direction: column; }
.product-image { max-width: 100%; }
.product-info { text-align: center; }
.product-details { color: #aaa; font-size: 1.1rem; margin-top: 0.5rem; text-transform: capitalize; }
.checkout-details-col { display: flex; flex-direction: column; gap: 2rem; }
.info-section { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.section-header { align-items: center; display: flex; justify-content: space-between; margin-bottom: 2rem; }
.btn-nav { align-items: center; background: transparent; border: 1px solid #444; border-radius: 50%; color: #ccc; cursor: pointer; display: flex; height: 44px; justify-content: center; padding: 0; transition: all 0.2s ease; width: 44px; }
.btn-nav:hover:not(:disabled) { background-color: #2a2a2a; border-color: #666; color: #fff; }
.btn-nav:disabled { cursor: not-allowed; opacity: 0.4; }
.btn-nav svg { height: 24px; width: 24px; }
.nav-placeholder { width: 44px; height: 44px; }
.form-grid { display: grid; gap: 1rem; grid-template-columns: 1fr 1fr; }
.form-group { display: flex; flex-direction: column; }
.form-group.full-width { grid-column: 1 / -1; }
.form-group label { color: #aaa; font-size: 0.9rem; margin-bottom: 0.5rem; }
.form-group input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 6px; color: #ffffff; font-size: 1rem; padding: 0.75rem; }
.form-group input:focus { border-color: #ffffff; outline: none; }
.order-summary-list { list-style: none; margin: 0 0 2rem; padding: 0; }
.order-summary-list li { align-items: center; display: flex; font-size: 1rem; justify-content: space-between; margin-bottom: 0.75rem; }
.order-summary-list span:first-child { color: #aaa; }
.total-cost { border-top: 1px solid #333; font-size: 1.2rem !important; font-weight: bold; margin-top: 1rem; padding-top: 1rem; }
.btn-confirm-purchase { background-color: #6ef0a3; border: 1px solid #6ef0a3; border-radius: 8px; color: #121212; cursor: pointer; font-size: 1.1rem; font-weight: bold; padding: 1rem; transition: background-color 0.3s, color 0.3s; width: 100%; }
.btn-confirm-purchase:hover:not(:disabled) { background-color: transparent; color: #6ef0a3; }
.btn-confirm-purchase:disabled { cursor: not-allowed; opacity: 0.6; }
.disclaimer { color: #888; font-size: 0.8rem; margin-top: 1rem; text-align: center; }
.shipping-preview { border-bottom: 1px solid #333; margin-bottom: 2rem; padding-bottom: 1.5rem; }
.shipping-preview h4 { color: #aaa; font-size: 1.1rem; font-weight: 600; margin-bottom: 1rem; }
.shipping-preview .address-line { color: #ffffff; font-size: 1rem; line-height: 1.5; margin: 0.25rem 0; }
.payment-options { display: flex; flex-direction: column; gap: 1rem; }
.payment-option { align-items: center; background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; cursor: pointer; display: flex; justify-content: space-between; padding: 1.25rem; transition: border-color 0.2s ease, background-color 0.2s ease; }
.payment-option:hover { background-color: #333; }
.payment-option.selected { border-color: #6ef0a3; }
.payment-option.disabled { cursor: not-allowed; opacity: 0.5; }
.payment-option.disabled:hover { background-color: #2c2c2c; }
.option-name { font-weight: 600; }
.option-detail { color: #aaa; }
.balance-insufficient { color: #ff6b6b; font-size: 0.9rem; margin-top: 1rem; text-align: center; }
.payment-method-summary { border-top: 1px solid #333; padding-top: 1rem; margin-top: 1rem;}

/* --- NEW: Submission Result Screen Styles --- */
.submission-result-screen { text-align: center; padding: 4rem 2rem; background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; max-width: 600px; margin: 4rem auto 0; }
.success-icon { color: #6ef0a3; margin-bottom: 1.5rem; }
.success-icon svg { width: 80px; height: 80px; }
.result-title { font-size: 2.5rem; margin-bottom: 0.5rem; }
.result-subtitle { color: #aaa; font-size: 1.1rem; margin-bottom: 2.5rem; }
.result-summary { text-align: left; border-top: 1px solid #333; border-bottom: 1px solid #333; margin-bottom: 2.5rem; padding: 1.5rem 0; }
.result-summary ul { list-style: none; padding: 0; }
.result-summary li { display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.result-summary span:first-child { color: #aaa; }
.result-summary li.total { font-size: 1.1rem; font-weight: bold; margin-top: 1rem; }
.result-actions { display: flex; gap: 1rem; justify-content: center; }
.btn { padding: 0.8rem 1.5rem; text-decoration: none; border-radius: 8px; font-weight: 600; transition: all 0.2s ease; }
.btn-primary { background-color: #6ef0a3; color: #121212; }
.btn-primary:hover { background-color: #8affbe; }
.btn-secondary { background-color: #2c2c2c; border: 1px solid #444; color: #fff; }
.btn-secondary:hover { background-color: #383838; }

@media (max-width: 900px) {
  .order-grid { grid-template-columns: 1fr; }
  .product-summary-col { position: static; }
}
</style>
