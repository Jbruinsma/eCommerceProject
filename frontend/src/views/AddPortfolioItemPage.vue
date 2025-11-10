<template>
  <div class="add-item-container">
    <main class="add-item-content">
      <WizardLayout
        :is-loading="isLoading"
        loading-text="Adding item to portfolio..."
        :submission-result="submissionResult"
        title="Add Item to Portfolio"
        :current-step="currentStep"
        :total-steps="4"
        :step-titles="['Select Brand', 'Find Your Item', 'Add Details', 'Review Item']"
        :is-step-valid="isStepValid"
        submit-button-text="Add to Portfolio"
        @prev="prevStep"
        @next="nextStep"
        @submit="submitPortfolioItem"
      >
        <template #result>
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
            <h2>Item Added!</h2>
            <p>Your item has been successfully added to your collection.</p>
            <div class="result-summary">
              <p><strong>Item:</strong> {{ selectedProductInfo.name }}</p>
              <p><strong>Size:</strong> {{ selectedSizeValue }}</p>
              <p>
                <strong>Paid:</strong> {{ formatCurrency(submissionResult.data.acquisition_price) }}
              </p>
            </div>
            <button @click="router.push('/portfolio')" class="btn btn-primary">
              View Portfolio
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
            <p>{{ submissionResult.message || "We couldn't add your item. Please try again." }}</p>
            <button @click="submissionResult = null" class="btn btn-secondary">Try Again</button>
          </div>
        </template>

        <div v-if="currentStep === 1" class="step-content">
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
              :class="{ selected: portfolioItemData.brand_id === brand.brand_id }"
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

        <div v-if="currentStep === 2" class="step-content">
          <input
            type="text"
            v-model="productSearchQuery"
            placeholder="Search for product by name..."
            class="search-input"
          />
          <div class="product-results">
            <div v-if="filteredProducts.length === 0" class="no-results">No products found.</div>
            <div
              v-else
              v-for="product in filteredProducts"
              :key="product.productId"
              class="product-item"
              :class="{ selected: portfolioItemData.product_id === product.productId }"
              @click="selectProduct(product)"
            >
              <img :src="product.imageUrl" :alt="product.name" />
              <span>{{ product.name }}</span>
            </div>
          </div>
        </div>

        <div v-if="currentStep === 3" class="step-content">
          <div class="form-grid">
            <div class="form-group span-2">
              <label>Size</label>
              <div class="radio-group size-group">
                <button
                  v-for="size in detailedProductData?.sizes"
                  :key="size.sizeId"
                  class="radio-btn"
                  :class="{ selected: portfolioItemData.size_id === size.sizeId }"
                  @click="portfolioItemData.size_id = size.sizeId"
                >
                  {{ size.size }}
                </button>
              </div>
            </div>
            <div class="form-group span-2">
              <label>Condition</label>
              <div class="radio-group">
                <button
                  v-for="condition in conditions"
                  :key="condition"
                  class="radio-btn"
                  :class="{ selected: portfolioItemData.item_condition === condition }"
                  @click="portfolioItemData.item_condition = condition"
                >
                  {{ condition }}
                </button>
              </div>
            </div>
            <div class="form-group">
              <label for="acquisition_date">Acquisition Date (Optional)</label>
              <input
                type="date"
                id="acquisition_date"
                v-model="portfolioItemData.acquisition_date"
                class="text-input"
              />
            </div>
            <div class="form-group">
              <label for="acquisition_price">Acquisition Price</label>
              <input
                type="number"
                id="acquisition_price"
                v-model.number="portfolioItemData.acquisition_price"
                placeholder="$0.00"
                class="text-input"
              />
            </div>
          </div>
        </div>

        <div v-if="currentStep === 4" class="step-content review-step">
          <div class="listing-review">
            <h4>Review Your Item</h4>
            <p><strong>Item:</strong> {{ selectedProductInfo.name }}</p>
            <p>
              <strong>Size:</strong> {{ selectedSizeValue }} | <strong>Condition:</strong>
              {{ portfolioItemData.item_condition }}
            </p>
            <p>
              <strong>Acquired On:</strong> {{ formatDate(portfolioItemData.acquisition_date) }}
            </p>
            <p>
              <strong>Price Paid:</strong> {{ formatCurrency(portfolioItemData.acquisition_price) }}
            </p>
          </div>
        </div>
      </WizardLayout>
    </main>
    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'
import WizardLayout from '@/components/WizardLayout.vue'
import { formatCurrency, formatDate } from '@/utils/formatting.js'

const currentStep = ref(1)
const portfolioItemData = reactive({
  brand_id: null,
  product_id: null,
  size_id: null,
  item_condition: null,
  acquisition_date: null,
  acquisition_price: null,
})
const brands = ref([])
const authStore = useAuthStore()
const isLoading = ref(false)
const submissionResult = ref(null)

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }
  try {
    const brandsResponse = await fetchFromAPI('/product/brands')
    brands.value = brandsResponse || []
  } catch (error) {
    console.error('Failed to fetch brands:', error)
  }
})

const conditions = ['new', 'used', 'worn']
const productSearchQuery = ref('')
const productsResults = ref([])
const brandSearchQuery = ref('')
const detailedProductData = ref(null)

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
  return (
    detailedProductData.value ||
    productsResults.value.find((p) => p.productId === portfolioItemData.product_id)
  )
})
const selectedSizeValue = computed(() => {
  if (!detailedProductData.value) return ''
  const sizeInfo = detailedProductData.value.sizes.find(
    (s) => s.sizeId === portfolioItemData.size_id,
  )
  return sizeInfo ? sizeInfo.size : ''
})

const isStepValid = computed(() => {
  switch (currentStep.value) {
    case 1:
      return !!portfolioItemData.brand_id
    case 2:
      return !!portfolioItemData.product_id
    case 3:
      return (
        !!portfolioItemData.size_id &&
        !!portfolioItemData.item_condition &&
        portfolioItemData.acquisition_price > 0
      )
    case 4:
      return true
    default:
      return false
  }
})

async function searchForProducts() {
  if (!portfolioItemData.brand_id) {
    productsResults.value = []
    return
  }
  try {
    const response = await fetchFromAPI(`/search/?brand_id=${portfolioItemData.brand_id}`)
    productsResults.value = response.products || []
  } catch (err) {
    console.error('Product search failed', err)
    productsResults.value = []
  }
}

watch(
  () => portfolioItemData.brand_id,
  (newBrandId) => {
    productSearchQuery.value = ''
    portfolioItemData.product_id = null
    portfolioItemData.size_id = null
    productsResults.value = []
    detailedProductData.value = null
    if (newBrandId) {
      searchForProducts()
    }
  },
)

function selectBrand(brandId) {
  portfolioItemData.brand_id = brandId
}
async function selectProduct(product) {
  portfolioItemData.product_id = product.productId
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

async function submitPortfolioItem() {
  if (!isStepValid.value) return
  isLoading.value = true
  submissionResult.value = null

  try {
    const response = await postToAPI(`/portfolio/${authStore.uuid}`, portfolioItemData)
    if (response && response.portfolio_item_id) {
      submissionResult.value = { success: true, data: response }
    } else {
      throw new Error('Invalid response from server.')
    }
  } catch (error) {
    submissionResult.value = {
      success: false,
      message: error.data?.message || error.message || 'An unknown error occurred.',
    }
  } finally {
    isLoading.value = false
  }
}
</script>

<style scoped>
.add-item-container { color: #ffffff; font-family: Spectral, sans-serif; }
.add-item-content { display: flex; justify-content: center; padding: 4rem 5%; }
.brand-logo { height: 40px; margin-bottom: 0.5rem; max-width: 150px; object-fit: contain; width: 100%; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.form-grid { display: grid; gap: 2rem; grid-template-columns: repeat(2, 1fr); }
.form-group { margin-bottom: 0; }
.form-group label { display: block; font-weight: bold; margin-bottom: 0.75rem; }
.form-group.span-2 { grid-column: span 2; }
.listing-review { background-color: #121212; border-radius: 8px; margin-top: 1.5rem; padding: 1.5rem; }
.listing-review h4 { margin-top: 0; }
.listing-review p { margin: 0.75rem 0; }
.no-results { color: #888; padding: 2rem; text-align: center; }
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
.text-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem; width: 100%; }
.selection-card { align-items: center; background-color: #2c2c2c; border: 2px solid #444; border-radius: 8px; color: #ffffff; cursor: pointer; display: flex; flex-direction: column; gap: 0.5rem; justify-content: center; padding: 1rem; text-align: center; transition: all 0.2s ease; }
.selection-card .card-title { display: block; font-weight: 700; margin: 0; }
.selection-card.selected { background-color: #383838; border-color: #ffffff; }
.selection-grid { display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
.step-content { min-height: 300px; padding: 1rem 2rem; }

@media (max-width: 768px) {
  .add-item-content { padding: 2rem 3%; }
  .form-grid { grid-template-columns: 1fr; }
  .selection-grid { grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
  .step-content { padding: 1rem 1.5rem; }
}

@media (max-width: 480px) {
  .add-item-content { padding: 1rem 3%; }
  .selection-grid { grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); }
  .step-content { padding: 1rem; }
}
</style>
