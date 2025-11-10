<template>
  <div class="create-listing-container">
    <main class="create-content">
      <WizardLayout
        :is-loading="isLoading"
        loading-text="Submitting your listing..."
        :submission-result="submissionResult"
        title="Create a Listing"
        :current-step="currentStep"
        :total-steps="5"
        :step-titles="['Select Listing Type', 'Select Brand', 'Find Your Item', 'Add Details', 'Set Your Price']"
        :is-step-valid="isStepValid"
        submit-button-text="Submit Listing"
        @prev="prevStep"
        @next="nextStep"
        @submit="submitListing"
      >
        <template #result>
          <div v-if="submissionResult.success">
            <svg class="result-icon success" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/>
            </svg>
            <h2 class="listing-created-header">
              {{ submissionResult.type === 'sale' ? 'Item Sold!' : 'Listing Created!' }}
            </h2>
            <p class="listing-created-p">
              {{
                submissionResult.type === 'sale'
                  ? 'You have successfully sold your item to the highest bidder.'
                  : 'Your item is now live on the marketplace.'
              }}
            </p>
            <div class="result-summary">
              <p><strong>Item:</strong> {{ selectedProductInfo.name }}</p>
              <p><strong>Size:</strong> {{ selectedSizeValue }}</p>
              <p v-if="submissionResult.type === 'ask'">
                <strong>Asking Price:</strong> {{ formatCurrency(submissionResult.data.price) }}
              </p>
              <p v-if="submissionResult.type === 'sale'">
                <strong>Sale Price:</strong> {{ formatCurrency(submissionResult.data.sale_price) }}
              </p>
              <p v-if="submissionResult.type === 'sale'">
                <strong>Your Payout:</strong>
                {{ formatCurrency(submissionResult.data.seller_final_payout) }}
              </p>
            </div>
            <button @click="navigateToNext" class="btn btn-primary">
              {{
                submissionResult.type === 'sale' ? 'View My Sales' : 'View My Listings'
              }}
            </button>
          </div>
          <div v-else>
            <svg class="result-icon error" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z"/>
            </svg>
            <h2>Something Went Wrong</h2>
            <p>
              {{
                submissionResult.message || 'We couldn\'t process your request. Please try again.'
              }}
            </p>
            <button @click="submissionResult = null" class="btn btn-secondary">Try Again</button>
          </div>
        </template>

        <div v-if="currentStep === 1" class="step-content">
          <div class="selection-grid">
            <button
              v-for="type in listingTypes"
              :key="type.value"
              class="selection-card"
              :class="{ selected: listingData.listing_type === type.value }"
              @click="selectListingType(type.value)"
            >
              <span class="card-title">{{ type.label }}</span>
              <span class="card-desc">{{ type.description }}</span>
            </button>
          </div>
        </div>
        <div v-if="currentStep === 2" class="step-content">
          <input
            type="text"
            v-model="brandSearchQuery"
            placeholder="Search for brand..."
            class="search-input"
          />
          <div class="selection-grid product-results">
            <button
              v-for="brand in filteredBrands"
              :key="brand.brand_id"
              class="selection-card"
              :class="{ selected: listingData.brand_id === brand.brand_id }"
              @click="selectBrand(brand.brand_id)"
            >
              <img
                v-if="brand.brand_logo_url"
                :src="brand.brand_logo_url"
                :alt="`${brand.brand_name} Logo`"
                class="brand-logo"
              />
              <span :class="['card-title', { 'with-logo': !brand.brand_logo_url }]">{{
                  brand.brand_name
                }}</span>
            </button>
          </div>
        </div>
        <div v-if="currentStep === 3" class="step-content">
          <input
            type="text"
            v-model="productSearchQuery"
            placeholder="Search for product by name..."
            class="search-input"
          />
          <div class="product-results">
            <div v-if="!listingData.brand_id" class="no-results">
              Please select a brand first.
            </div>
            <div v-else-if="filteredProducts.length === 0" class="no-results">
              No products found.
            </div>
            <div
              v-else
              v-for="product in filteredProducts"
              :key="product.productId"
              class="product-item"
              :class="{ selected: listingData.product_id === product.productId }"
              @click="selectProduct(product)"
            >
              <img :src="product.imageUrl" :alt="product.name" />
              <span>{{ product.name }}</span>
            </div>
          </div>
        </div>

        <div v-if="currentStep === 4" class="step-content">
          <div class="form-group">
            <label>1. Select Condition</label>
            <div class="radio-group">
              <button
                v-for="condition in conditions"
                :key="condition"
                class="radio-btn"
                :class="{ selected: listingData.item_condition === condition }"
                @click="listingData.item_condition = condition"
              >
                {{ condition }}
              </button>
            </div>
          </div>
          <div class="form-group" v-if="listingData.item_condition">
            <label>2. Select Size</label>
            <div v-if="availableSizesForListing.length > 0" class="radio-group size-group">
              <button
                v-for="size in availableSizesForListing"
                :key="size.sizeId"
                class="radio-btn"
                :class="{ selected: listingData.size_id === size.sizeId }"
                @click="listingData.size_id = size.sizeId"
              >
                <span class="size-value">{{ size.size }}</span>
              </button>
            </div>
            <div v-else-if="listingData.listing_type === 'sale'" class="no-results">
              <p>
                No sizes with active bids are available for this item in "{{
                  listingData.item_condition
                }}" condition. Please go back and create an "Ask" to list this item.
              </p>
            </div>

            <div
              v-if="listingData.size_id && detailedProductData"
              class="market-data-panel"
            >
              <h4>Market for Size {{ selectedSizeValue }} ({{listingData.item_condition}})</h4>
              <div class="market-data-content">
                <div class="data-point">
                  <span class="data-label">Highest Bid</span>
                  <span class="data-value bid">{{ formatCurrency(highestBid) }}</span>
                </div>
                <div v-if="listingData.listing_type === 'ask'" class="data-point">
                  <span class="data-label">Lowest Ask</span>
                  <span class="data-value ask">{{ formatCurrency(lowestAsk) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="currentStep === 5" class="step-content review-step">
          <div v-if="listingData.listing_type === 'ask'" class="form-group">
            <label for="price">Your Asking Price</label>
            <input
              type="text"
              id="price"
              :value="priceInput"
              @input="filterAskInput"
              placeholder="$0.00"
              class="price-input"
            />
            <p class="input-note">
              Minimum asking price is {{ formatCurrency(minimumAskPrice) }}
            </p>
          </div>
          <div v-else class="form-group locked-price">
            <label>Sale Price (Locked to Highest Bid)</label>
            <div class="price-display">{{ formatCurrency(listingData.price) }}</div>
          </div>
          <div class="earnings-summary">
            <div class="summary-item">
              <span>Transaction Fee ({{ feePercentage }}):</span>
              <span class="negative"> -{{ formatCurrency(transactionFee) }}</span>
            </div>
            <div class="summary-item total">
              <span>Your Payout:</span> <span>{{ formatCurrency(sellerPayout) }}</span>
            </div>
          </div>
          <div class="listing-review" v-if="selectedProductInfo">
            <h4>Review Your Listing</h4>
            <p><strong>Item:</strong> {{ selectedProductInfo.name }}</p>
            <p>
              <strong>Size:</strong> {{ selectedSizeValue }} | <strong>Condition:</strong>
              {{ listingData.item_condition }}
            </p>
            <p><strong>Listing Type:</strong> {{ listingData.listing_type }}</p>
            <div class="market-context">
              <p>
                <strong>Retail Price:</strong> {{ formatCurrency(selectedProductInfo.retailPrice) }}
              </p>
              <p><strong>Highest Bid:</strong> {{ formatCurrency(highestBid) }}</p>
            </div>
          </div>
        </div>
      </WizardLayout>
    </main>
    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'
import { getSellerFee } from '@/utils/fees.js'
import WizardLayout from '@/components/WizardLayout.vue'
import { formatCurrency } from '@/utils/formatting.js'

const currentStep = ref(1)
const MINIMUM_PRICE = 1.0
const MAX_PRICE = 99999999.99 // NEW
const listingData = reactive({
  listing_type: null,
  brand_id: null,
  product_id: null,
  size_id: null,
  item_condition: null,
  price: null,
})
const transactionFeeRate = ref(0.095)
const feeId = ref(null)
const brands = ref([])
const authStore = useAuthStore()
const isLoading = ref(false)
const submissionResult = ref(null)

const productSearchQuery = ref('')
const brandSearchQuery = ref('')
const productsResults = ref([])
const detailedProductData = ref(null)
const priceInput = ref('') // NEW: For string value of price

const listingTypes = [
  { value: 'ask', label: 'Ask', description: 'Set a specific price for your item.' },
  { value: 'sale', label: 'Sale', description: 'Sell immediately to the highest bidder.' },
]
const conditions = ['new', 'used', 'worn']

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }
  try {
    const sellerFeeInfo = await getSellerFee()
    if (sellerFeeInfo && sellerFeeInfo.id) {
      transactionFeeRate.value = sellerFeeInfo.seller_fee_percentage
      feeId.value = sellerFeeInfo.id
    }
    const brandsResponse = await fetchFromAPI('/product/brands')
    brands.value = brandsResponse || []
  } catch (error) {
    console.error('Failed during component setup:', error)
  }
})

// NEW: Input validation function
function filterAskInput(event) {
  const previous = priceInput.value
  let value = event.target.value
  const validFormat = /^\d*(?:\.\d{0,2})?$/.test(value)

  if (!validFormat) {
    event.target.value = previous
    priceInput.value = previous
    return
  }

  if (value === '') {
    priceInput.value = ''
    listingData.price = null
    return
  }

  const parsed = Number(value)
  if (isNaN(parsed) || parsed > MAX_PRICE) {
    event.target.value = previous
    priceInput.value = previous
    return
  }

  priceInput.value = value
  listingData.price = parsed
}

const filteredBrands = computed(() => {
  if (!brandSearchQuery.value) return brands.value
  return brands.value.filter((b) =>
    b.brand_name.toLowerCase().includes(brandSearchQuery.value.toLowerCase()),
  )
})

const filteredProducts = computed(() =>
  productsResults.value.filter((p) =>
    p.name.toLowerCase().includes(productSearchQuery.value.toLowerCase()),
  ),
)

const selectedProductInfo = computed(() => {
  return detailedProductData.value || productsResults.value.find(p => p.productId === listingData.product_id)
});

const selectedSizeValue = computed(() => {
  if (!detailedProductData.value) return ''
  const sizeInfo = detailedProductData.value.sizes.find(s => s.sizeId === listingData.size_id)
  return sizeInfo ? sizeInfo.size : ''
})

const feePercentage = computed(() => `${(transactionFeeRate.value * 100).toFixed(1)}%`)
const transactionFee = computed(() => (listingData.price || 0) * transactionFeeRate.value)
const sellerPayout = computed(() => (listingData.price || 0) - transactionFee.value)

const highestBid = computed(() => {
  if (!detailedProductData.value || !listingData.size_id || !listingData.item_condition) return null
  const sizeInfo = detailedProductData.value.sizes.find(s => s.sizeId === listingData.size_id)
  return sizeInfo?.highestBid[listingData.item_condition]?.amount
})

const lowestAsk = computed(() => {
  if (!detailedProductData.value || !listingData.size_id || !listingData.item_condition) return null
  const sizeInfo = detailedProductData.value.sizes.find(s => s.sizeId === listingData.size_id)
  return sizeInfo?.lowestAskingPrice[listingData.item_condition]?.price
})

const minimumAskPrice = computed(() => {
  if (listingData.listing_type === 'ask' && highestBid.value > 0) {
    return highestBid.value + 1.00;
  }
  return MINIMUM_PRICE;
});

const availableSizesForListing = computed(() => {
  if (!detailedProductData.value || !Array.isArray(detailedProductData.value.sizes)) return []
  if (listingData.listing_type === 'ask') {
    return detailedProductData.value.sizes
  }
  if (listingData.listing_type === 'sale') {
    return detailedProductData.value.sizes.filter(size => {
      const bidInfo = size.highestBid[listingData.item_condition]
      return bidInfo && bidInfo.amount > 0
    })
  }
  return []
})

const isStepValid = computed(() => {
  switch (currentStep.value) {
    case 1:
      return !!listingData.listing_type
    case 2:
      return !!listingData.brand_id
    case 3:
      return !!listingData.product_id
    case 4:
      return !!listingData.size_id && !!listingData.item_condition
    case 5:
      return listingData.listing_type === 'sale' || (listingData.price && listingData.price >= minimumAskPrice.value)
    default:
      return false
  }
})

async function searchForProducts() {
  if (!listingData.brand_id) {
    productsResults.value = []
    return
  }
  try {
    const response = await fetchFromAPI(`/search/?brand_id=${listingData.brand_id}`)
    productsResults.value = response.products || []
  } catch (err) {
    console.error('Product search failed:', err)
    productsResults.value = []
  }
}

// UPDATED: This watch now syncs the numeric price to the string input
watch(() => listingData.price, (newPrice) => {
  if (newPrice === null) {
    priceInput.value = ''
  } else if (Number(priceInput.value) !== newPrice) {
    priceInput.value = String(newPrice)
  }
});

watch(
  () => listingData.brand_id,
  (newBrandId) => {
    productSearchQuery.value = ''
    listingData.product_id = null
    listingData.size_id = null
    productsResults.value = []
    detailedProductData.value = null
    if (newBrandId) {
      searchForProducts()
    }
  },
)

watch(
  () => listingData.item_condition,
  () => {
    listingData.size_id = null
  },
)

watch(
  () => listingData.size_id,
  (newSizeId) => {
    if (listingData.listing_type === 'sale' && newSizeId) {
      listingData.price = highestBid.value
    } else if (listingData.listing_type === 'ask') {
      // Clear price when size changes in 'ask' mode
      listingData.price = null
      priceInput.value = ''
    }
  },
)

function selectListingType(type) {
  listingData.listing_type = type
  listingData.price = null
}

function selectBrand(brandId) {
  listingData.brand_id = brandId
}

async function selectProduct(product) {
  listingData.product_id = product.productId
  detailedProductData.value = null

  try {
    const response = await fetchFromAPI(`/search/${product.productId}`)
    detailedProductData.value = response
  } catch (error) {
    console.error(`Failed to fetch detailed data for product ${product.productId}:`, error)
    detailedProductData.value = null
  }
}

function nextStep() {
  if (isStepValid.value) currentStep.value++
}

function prevStep() {
  if (currentStep.value > 1) currentStep.value--
}

async function submitListing() {
  if (!isStepValid.value) return
  isLoading.value = true
  submissionResult.value = null

  try {
    const payload = {
      ...listingData,
      fee_id: feeId.value,
    }

    const listingType = listingData.listing_type
    let response

    if (listingType === 'ask') {
      response = await postToAPI(`/listings/${authStore.uuid}/create`, payload)
    } else if (listingType === 'sale') {
      const selectedSize = detailedProductData.value?.sizes.find(s => s.sizeId === listingData.size_id)
      const bidInfo = selectedSize?.highestBid[listingData.item_condition]

      if (bidInfo && bidInfo.bidId) {
        payload.target_bid_id = bidInfo.bidId
      } else {
        throw new Error('Could not find the corresponding bid to sell to.')
      }

      // console.log('Payload for sale:', payload)

      response = await postToAPI(`/listings/${authStore.uuid}/fulfill`, payload)
    }

    if ((listingType === 'ask' && response?.listing_id) || (listingType === 'sale' && response?.order_id)) {
      submissionResult.value = { success: true, data: response, type: listingType }
    } else {
      throw new Error('Invalid response from server.')
    }
  } catch (error) {
    console.error('Listing submission failed:', error)
    submissionResult.value = {
      success: false,
      message: error.data?.message || error.message || 'An unknown error occurred.',
    }
  } finally {
    isLoading.value = false
  }
}

function navigateToNext() {
  const route = submissionResult.value?.type === 'sale' ? '/my-sales' : '/my-listings';
  router.push(route);
}

</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
.brand-logo { height: 40px; margin-bottom: 0.5rem; max-width: 120px; object-fit: contain; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.create-content { display: flex; justify-content: center; padding: 4rem 5%; }
.create-listing-container { color: #ffffff; font-family: Spectral, sans-serif; }
.data-label { color: #888; display: block; font-size: 0.8rem; margin-bottom: 0.25rem; }
.data-point { text-align: center; }
.data-value { font-size: 1.2rem; font-weight: bold; }
.data-value.ask { color: #f06e6e; }
.data-value.bid { color: #6ef0a3; }
.earnings-summary { border-top: 1px solid #333; margin: 1.5rem 0; padding-top: 1.5rem; }
.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; font-weight: bold; margin-bottom: 0.75rem; }
.input-note { color: #888; font-size: 0.8rem; margin-top: 0.5rem; }
.listing-created-header, .listing-created-p { text-align: center; }
.listing-review { background-color: #121212; border-radius: 8px; margin-top: 1.5rem; padding: 1rem; }
.listing-review h4 { margin-top: 0; }
.locked-price label { margin-bottom: 0.5rem; }
.market-context { border-top: 1px solid #333; margin-top: 1rem; padding-top: 1rem; }
.market-context p { margin: 0.5rem 0; }
.market-data-content { display: flex; gap: 1rem; justify-content: space-around; }
.market-data-panel { animation: fadeIn 0.3s ease; background-color: #121212; border: 1px solid #2a2a2a; border-radius: 8px; margin-top: 1.5rem; padding: 1rem; text-transform: capitalize; }
.market-data-panel h4 { color: #aaa; font-size: 1rem; font-weight: normal; margin-bottom: 1rem; margin-top: 0; text-align: center; }
.negative { color: #f06e6e; }
.no-results { color: #888; padding: 2rem; text-align: center; }
.price-display { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; font-size: 1.5rem; font-weight: bold; padding: 0.75rem; text-align: center; }
.price-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1.5rem; font-weight: bold; padding: 0.75rem; width: 100%; }
.product-item { align-items: center; border: 2px solid transparent; border-radius: 8px; cursor: pointer; display: flex; gap: 1rem; padding: 0.75rem; }
.product-item img { border-radius: 4px; height: 50px; width: 50px; }
.product-item.selected { border-color: #ffffff; }
.product-item:hover { background-color: #2c2c2c; }
.product-results { max-height: 250px; overflow-y: auto; }
.radio-btn { background-color: #2c2c2c; border: 2px solid #444; border-radius: 20px; color: #ffffff; cursor: pointer; font-size: 0.9rem; padding: 0.5rem 1.25rem; text-transform: capitalize; transition: all 0.2s ease; }
.radio-btn.selected { background-color: #383838; border-color: #ffffff; }
.radio-group { display: flex; flex-wrap: wrap; gap: 0.75rem; }
.result-icon { height: 80px; margin-bottom: 1rem; width: 80px; }
.result-icon.error { color: #f06e6e; }
.result-icon.success { color: #6ef0a3; }
.result-summary { background-color: #121212; border-radius: 8px; margin: 1.5rem 0; max-width: 350px; padding: 1rem; text-align: left; width: 100%; }
.result-summary p { margin: 0.5rem 0; }
.search-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; margin-bottom: 1.5rem; margin-top: 1rem; max-width: 500px; padding: 0.75rem; width: 100%; }
.selection-card { align-items: center; background-color: #2c2c2c; border: 2px solid #444; border-radius: 8px; color: #ffffff; cursor: pointer; display: flex; flex-direction: column; gap: 0.5rem; justify-content: center; padding: 1rem; text-align: center; transition: all 0.2s ease; }
.selection-card .card-desc { color: #aaa; font-size: 0.95rem; margin: 0; }
.selection-card .card-title { display: block; font-weight: 700; margin: 0; }
.selection-card .card-title.with-logo { margin-top: 0; }
.selection-card.selected { background-color: #383838; border-color: #ffffff; }
.selection-grid { display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
.size-value { font-weight: 600; }
.step-content { min-height: 300px; padding: 1rem 2rem; }
@keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
@media (max-width: 768px) {
  .create-content { padding: 2rem 3%; }
  .market-data-content { flex-direction: column; }
  .price-input { font-size: 1.2rem; }
  .selection-grid { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
  .step-content { padding: 1rem 1.5rem; }
}
@media (max-width: 480px) {
  .create-content { padding: 1rem 3%; }
  .selection-grid { grid-template-columns: 1fr; }
  .step-content { padding: 1rem; }
}
</style>
