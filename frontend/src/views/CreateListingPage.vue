<template>
  <div class="create-listing-container">
    <main class="create-content">
      <div class="wizard-card">
        <div v-if="isLoading" class="loading-overlay">
          <div class="spinner"></div>
          <p>Submitting your listing...</p>
        </div>

        <div v-else-if="submissionResult" class="submission-result-screen">
          <div v-if="submissionResult.success">
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
              <p><strong>Item:</strong> {{ selectedProduct.name }}</p>
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
            <p>
              {{
                submissionResult.message || 'We couldn\'t process your request. Please try again.'
              }}
            </p>
            <button @click="submissionResult = null" class="btn btn-secondary">Try Again</button>
          </div>
        </div>

        <template v-else>
          <div class="progress-bar">
            <div class="progress" :style="{ width: `${(currentStep - 1) * 25}%` }"></div>
          </div>
          <div class="wizard-header">
            <h2>Create a Listing</h2>
            <p>Step {{ currentStep }} of 5: {{ stepTitle }}</p>
          </div>

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
                :key="product.product_id"
                class="product-item"
                :class="{ selected: listingData.product_id === product.product_id }"
                @click="selectProduct(product)"
              >
                <img :src="product.image_url" :alt="product.name" />
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
                  :key="size.size_id"
                  class="radio-btn"
                  :class="{
                    selected: listingData.size_id === size.size_id,
                    'size-bid-btn': listingData.listing_type === 'sale',
                  }"
                  @click="listingData.size_id = size.size_id"
                >
                  <span class="size-value">{{ size.size_value }}</span>
                  <span
                    v-if="listingData.listing_type === 'sale'"
                    class="highest-bid-value"
                  >
                    {{
                      formatCurrency(
                        activeBidsData[
                          `${listingData.product_id}-${size.size_id}-${listingData.item_condition}`
                          ]?.highest_bid,
                      )
                    }}
                  </span>
                </button>
              </div>
              <div v-else-if="listingData.listing_type === 'sale'" class="no-results">
                <p>
                  No sizes with active bids are available for this item in "{{
                    listingData.item_condition
                  }}" condition. Please go back and create an "Ask" to list this item.
                </p>
              </div>
            </div>
          </div>

          <div v-if="currentStep === 5" class="step-content review-step">
            <div v-if="listingData.listing_type === 'ask'" class="form-group">
              <label for="price">Your Asking Price</label>
              <input
                type="number"
                id="price"
                v-model.number="listingData.price"
                placeholder="$0.00"
                class="price-input"
              />
              <p class="input-note">Minimum asking price is {{ formatCurrency(MINIMUM_PRICE) }}</p>
            </div>
            <div v-else class="form-group locked-price">
              <label>Sale Price (Locked to Highest Bid)</label>
              <div class="price-display">{{ formatCurrency(listingData.price) }}</div>
            </div>
            <div class="earnings-summary">
              <div class="summary-item">
                <span>Transaction Fee ({{ feePercentage }})</span>
                <span class="negative">-{{ formatCurrency(transactionFee) }}</span>
              </div>
              <div class="summary-item total">
                <span>Your Payout</span> <span>{{ formatCurrency(sellerPayout) }}</span>
              </div>
            </div>
            <div class="listing-review">
              <h4>Review Your Listing</h4>
              <p><strong>Item:</strong> {{ selectedProduct.name }}</p>
              <p>
                <strong>Size:</strong> {{ selectedSizeValue }} | <strong>Condition:</strong>
                {{ listingData.item_condition }}
              </p>
              <p><strong>Listing Type:</strong> {{ listingData.listing_type }}</p>
              <div class="market-context">
                <p>
                  <strong>Retail Price:</strong> {{ formatCurrency(selectedProduct.retail_price) }}
                </p>
                <p><strong>Highest Bid:</strong> {{ formatCurrency(highestBid) }}</p>
              </div>
            </div>
          </div>

          <div class="wizard-footer">
            <button v-if="currentStep > 1" @click="prevStep" class="btn btn-secondary">Back</button>
            <button
              v-if="currentStep < 5"
              @click="nextStep"
              :disabled="!isStepValid"
              class="btn btn-primary"
            >
              Next
            </button>
            <button
              v-if="currentStep === 5"
              @click="submitListing"
              :disabled="!isStepValid"
              class="btn btn-primary"
            >
              Submit Listing
            </button>
          </div>
        </template>
      </div>
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

const currentStep = ref(1)
const MINIMUM_PRICE = 1.0
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
const activeBidsData = ref({})

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }
  try {

    console.log("Brand Products: ", await fetchFromAPI('/search/?brand_id=1'))

    console.log("Product: ", await fetchFromAPI('/search/?product_id=1'))

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

const listingTypes = [
  { value: 'ask', label: 'Ask', description: 'Set a specific price for your item.' },
  { value: 'sale', label: 'Sale', description: 'Sell immediately to the highest bidder.' },
]
const conditions = ['new', 'used', 'worn']
const productSearchQuery = ref('')
const productsResults = ref([])
const brandSearchQuery = ref('')

const stepTitle = computed(() => {
  return (
    ['Select Listing Type', 'Select Brand', 'Find Your Item', 'Add Details', 'Set Your Price'][
    currentStep.value - 1
      ] || ''
  )
})
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
const selectedProduct = computed(() =>
  productsResults.value.find((p) => p.product_id === listingData.product_id),
)
const selectedSizeValue = computed(
  () => selectedProduct.value?.sizes.find((s) => s.size_id === listingData.size_id)?.size_value,
)
const feePercentage = computed(() => `${(transactionFeeRate.value * 100).toFixed(1)}%`)
const transactionFee = computed(() => (listingData.price || 0) * transactionFeeRate.value)
const sellerPayout = computed(() => (listingData.price || 0) - transactionFee.value)
const highestBid = computed(() => {
  if (!listingData.product_id || !listingData.size_id || !listingData.item_condition) return 0
  const key = `${listingData.product_id}-${listingData.size_id}-${listingData.item_condition}`
  return activeBidsData.value[key]?.highest_bid || 0
})
const availableSizesForListing = computed(() => {
  if (!selectedProduct.value || !Array.isArray(selectedProduct.value.sizes)) return []
  if (listingData.listing_type === 'ask') return selectedProduct.value.sizes
  if (listingData.listing_type === 'sale') {
    return selectedProduct.value.sizes.filter((size) => {
      const key = `${listingData.product_id}-${size.size_id}-${listingData.item_condition}`
      return activeBidsData.value[key] && activeBidsData.value[key].highest_bid > 0
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
      return (
        !!listingData.size_id &&
        !!listingData.item_condition &&
        (listingData.listing_type === 'ask' || availableSizesForListing.value.length > 0)
      )
    case 5:
      return listingData.listing_type === 'sale' || listingData.price >= MINIMUM_PRICE
    default:
      return false
  }
})

async function searchForBrandProducts(brandId) {
  if (!brandId) {
    productsResults.value = []
    return
  }
  try {
    const rawProducts = await fetchFromAPI(`/search/?brand_id=${brandId}`)

    console.log(rawProducts)

  } catch (err) {
    console.error('Product search failed', err)
    productsResults.value = []
  }
}

async function retrieveProductData(product) {
  const response = await fetchFromAPI(`/search/?product_id=${product.product_id}`)
}

async function searchForProducts() {
  if (!listingData.brand_id) {
    productsResults.value = []
    return
  }
  const chosenBrandId = listingData.brand_id
  const query = productSearchQuery.value || ''
  try {
    const rawProducts = await fetchFromAPI(`/search/?brand_id=${chosenBrandId}`)

    console.log(rawProducts)



    productsResults.value = (rawProducts || []).map((product) => {
      let sizesArray = []
      if (typeof product.sizes === 'string') {
        try {
          sizesArray = JSON.parse(product.sizes)
        } catch (e) {
          console.error(`Failed to parse sizes for product ${product.product_id}:`, e)
          sizesArray = []
        }
      }
      return { ...product, sizes: sizesArray }
    })
  } catch (err) {
    console.error('Product search failed', err)
    productsResults.value = []
  }
}

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
    }
  },
)
watch(productSearchQuery, (newQuery) => {
  if (newQuery.length >= 2 || newQuery.length === 0) {
    searchForProducts()
  }
})
watch(
  () => listingData.brand_id,
  () => {
    productSearchQuery.value = ''
    listingData.product_id = null
    productsResults.value = []
    activeBidsData.value = {}
    searchForProducts()
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
  activeBidsData.value = {}

  if (listingData.listing_type === 'sale') {
    try {
      const activeBidsResponse = await fetchFromAPI(`/bids/${product.product_id}/all`)
      const formattedBids = {}

      for (const sizeValue in activeBidsResponse) {
        const sizeData = activeBidsResponse[sizeValue]
        const sizeId = sizeData.sizeId

        for (const condition in sizeData.bids) {
          const bidInfo = sizeData.bids[condition]
          if (bidInfo && bidInfo.bidAmount > 0) {
            const componentCondition = condition.toLowerCase()
            const key = `${product.product_id}-${sizeId}-${componentCondition}`
            formattedBids[key] = {
              highest_bid: bidInfo.bidAmount,
              bid_id: bidInfo.bidId,
            }
          }
        }
      }
      activeBidsData.value = formattedBids
    } catch (error) {
      console.error('Failed to fetch active bids:', error)
      activeBidsData.value = {}
    }
  }
  listingData.product_id = product.product_id
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
      const bidKey = `${listingData.product_id}-${listingData.size_id}-${listingData.item_condition}`
      const bidData = activeBidsData.value[bidKey]

      if (bidData && bidData.bid_id) {
        payload.target_bid_id = bidData.bid_id
      } else {
        throw new Error('Could not find the corresponding bid to sell to.')
      }

      response = await postToAPI(`/listings/${authStore.uuid}/fulfill`, payload)
    }

    const isAskSuccess = listingType === 'ask' && response && response.listing_id
    const isSaleSuccess = listingType === 'sale' && response && response.order_id

    if (isAskSuccess || isSaleSuccess) {
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
  if (submissionResult.value?.type === 'sale') {
    router.push('/my-sales')
  } else {
    router.push('/my-listings')
  }
}

const formatCurrency = (amount) => {
  if (typeof amount !== 'number') return '$--.--'
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
.brand-logo { height: 40px; margin-bottom: 0.5rem; max-width: 120px; object-fit: contain; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.btn:disabled { background-color: #333; border-color: #444; color: #888; cursor: not-allowed; }
.create-content { display: flex; justify-content: center; padding: 4rem 5%; }
.create-listing-container { color: #ffffff; font-family: Spectral, sans-serif; }
.earnings-summary { border-top: 1px solid #333; margin: 1.5rem 0; padding-top: 1.5rem; }
.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; font-weight: bold; margin-bottom: 0.75rem; }
h2 { font-size: 1.8rem; margin-bottom: 0.5rem; text-align: left; }
.highest-bid-value { color: #6ef0a3; font-size: 0.8rem; font-weight: bold; }
.input-note { color: #888; font-size: 0.8rem; margin-top: 0.5rem; }
.listing-created-header, .listing-created-p { text-align: center; }
.listing-review { background-color: #121212; border-radius: 8px; margin-top: 1.5rem; padding: 1rem; }
.listing-review h4 { margin-top: 0; }
.loading-overlay { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 400px; padding: 2rem; }
.loading-overlay p { color: #888; font-weight: bold; margin-top: 1rem; }
.locked-price label { margin-bottom: 0.5rem; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.market-context { border-top: 1px solid #333; margin-top: 1rem; padding-top: 1rem; }
.market-context p { margin: 0.5rem 0; }
.negative { color: #f06e6e; }
.no-results { color: #888; padding: 2rem; text-align: center; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.price-display { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; font-size: 1.5rem; font-weight: bold; padding: 0.75rem; text-align: center; }
.price-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1.5rem; font-weight: bold; padding: 0.75rem; width: 100%; }
.product-item { align-items: center; border: 2px solid transparent; border-radius: 8px; cursor: pointer; display: flex; gap: 1rem; padding: 0.75rem; }
.product-item:hover { background-color: #2c2c2c; }
.product-item img { border-radius: 4px; height: 50px; width: 50px; }
.product-item.selected { border-color: #ffffff; }
.product-results { max-height: 250px; overflow-y: auto; }
.progress { background-color: #ffffff; height: 100%; transition: width 0.3s ease; }
.progress-bar { background-color: #2c2c2c; height: 8px; width: 100%; }
.radio-btn { background-color: #2c2c2c; border: 2px solid #444; border-radius: 20px; color: #ffffff; cursor: pointer; font-size: 0.9rem; padding: 0.5rem 1.25rem; text-transform: capitalize; transition: all 0.2s ease; }
.radio-btn.selected { background-color: #383838; border-color: #ffffff; }
.radio-group { display: flex; flex-wrap: wrap; gap: 0.75rem; }
.result-icon { height: 80px; margin-bottom: 1rem; width: 80px; }
.result-icon.error { color: #f06e6e; }
.result-icon.success { color: #6ef0a3; }
.result-summary { background-color: #121212; border-radius: 8px; margin: 1.5rem 0; max-width: 350px; padding: 1rem; text-align: left; width: 100%; }
.result-summary p { margin: 0.5rem 0; }
.search-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; margin-bottom: 1.5rem; max-width: 500px; padding: 0.75rem; width: 100%; }
.selection-card { align-items: center; background-color: #2c2c2c; border: 2px solid #444; border-radius: 8px; color: #ffffff; cursor: pointer; display: flex; flex-direction: column; gap: 0.5rem; justify-content: center; padding: 1rem; text-align: center; transition: all 0.2s ease; }
.selection-card .card-desc { color: #aaa; font-size: 0.95rem; margin: 0; }
.selection-card .card-title { display: block; font-weight: 700; margin: 0; }
.selection-card .card-title.with-logo { margin-top: 0; }
.selection-card.selected { background-color: #383838; border-color: #ffffff; }
.selection-grid { display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
.size-bid-btn { align-items: center; display: flex; flex-direction: column; gap: 4px; height: auto; line-height: 1.2; padding: 0.75rem 1.25rem; }
.size-value { font-weight: 600; }
.spinner { animation: spin 1s linear infinite; border: 4px solid #333; border-radius: 50%; border-top: 4px solid #ffffff; height: 50px; width: 50px; }
.step-content { min-height: 300px; padding: 1rem 2rem; }
.submission-result-screen { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 400px; padding: 2rem; text-align: center; }
.submission-result-screen h2 { border-bottom: none; font-size: 2rem; }
.submission-result-screen p { color: #aaa; max-width: 400px; }
.summary-item { align-items: center; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.summary-item.total { font-size: 1.2rem; font-weight: bold; }
.wizard-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; max-width: 800px; overflow: hidden; width: 100%; }
.wizard-footer { align-items: center; background-color: #121212; border-top: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 2rem; }
.wizard-header { padding: 2rem 2rem 1rem; }
.wizard-header p { color: #888; margin: 0; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
</style>

