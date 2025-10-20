<template>
  <div class="product-container">
    <main class="product-content">
      <div class="product-grid">
        <div class="product-image-container">
          <img :src="product.image_url" :alt="product.name" class="product-image" />
        </div>

        <div class="product-info-container">
          <h2 class="brand-name">{{ product.brand_name }}</h2>
          <h1 class="product-name">{{ product.name }}</h1>

          <div class="action-box">
            <div class="form-group">
              <label>Condition</label>
              <div class="condition-selector">
                <button
                  v-for="condition in availableConditions"
                  :key="condition"
                  :class="{ active: selectedCondition === condition }"
                  @click="selectedCondition = condition"
                >
                  {{ condition }}
                </button>
              </div>
            </div>
            <div class="form-group">
              <label for="size-select">Size</label>
              <select id="size-select" v-model="selectedSize">
                <option v-for="size in availableSizes" :key="size" :value="size">
                  {{ size }}
                </option>
              </select>
            </div>

            <div class="action-buttons">
              <button class="btn btn-buy">
                Buy Now
                <span class="btn-price">{{ formatCurrency(currentMarketData.lowest_ask) }}</span>
              </button>

              <router-link
                :to="{
                  name: 'place-bid',
                  params: { listingId: product.product_id },
                  query: { size: selectedSize, condition: selectedCondition },
                }"
                class="btn btn-bid"
              >
                Place Bid
                <span class="btn-price">{{ formatCurrency(currentMarketData.highest_bid) }}</span>
              </router-link>
            </div>
            <a href="#" class="market-link">View Market Data</a>
          </div>

          <div class="product-details">
            <h3>Product Details</h3>
            <ul>
              <li>
                <strong>SKU</strong><span>{{ product.sku }}</span>
              </li>
              <li>
                <strong>Colorway</strong><span>{{ product.colorway }}</span>
              </li>
              <li>
                <strong>Retail Price</strong><span>{{ formatCurrency(product.retail_price) }}</span>
              </li>
              <li>
                <strong>Release Date</strong><span>{{ formatDate(product.release_date) }}</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </main>

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { fetchFromAPI } from '@/utils/index.js'

const route = useRoute()
const product_id = route.params.id

const product = ref({
  product_id: product_id,
  brand_name: '',
  name: 'Loading...',
  sku: '',
  colorway: '',
  retail_price: 0,
  release_date: '',
  image_url: 'https://placehold.co/800x600/1a1a1a/ffffff?text=Loading',
})

const availableConditions = ref(['New', 'Used', 'Worn'])
const selectedCondition = ref('New')

// Initialize with empty array; will be populated by API
const availableSizes = ref([])
const selectedSize = ref(null)

// Initialize with empty object; will be populated by API
const marketData = ref({})

// This computed property finds data based on both size AND condition.
const currentMarketData = computed(() => {
  const sizeData = marketData.value[selectedSize.value]
  if (sizeData) {
    // Return market data for the selected condition, or a default object if not found
    return sizeData[selectedCondition.value] || { lowest_ask: null, highest_bid: null }
  }
  // Return a default object if the size itself is not found
  return { lowest_ask: null, highest_bid: null }
})

// Updated to handle null values from the API
const formatCurrency = (amount) => {
  if (amount === null || typeof amount !== 'number') return '—' // Display '—' for null or invalid values
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('en-US', options)
}

onMounted(async () => {
  try {
    const response = await fetchFromAPI(`/product/${product_id}`)

    // Deconstruct the response for easier access
    const { productInfo, sizes, marketData: apiMarketData } = response

    // 1. Populate product info
    if (productInfo) {
      product.value = { ...productInfo, product_id: product_id }
    }

    // 2. Populate and sort available sizes
    if (sizes && sizes.length > 0) {
      const sortedSizes = sizes
        .map((s) => s.size_value)
        .sort((a, b) => parseFloat(a) - parseFloat(b)) // Sort sizes numerically
      availableSizes.value = sortedSizes
      selectedSize.value = sortedSizes[0] // Set default selected size to the first available size
    }

    // 3. Populate market data
    if (apiMarketData) {
      marketData.value = apiMarketData
    }

  } catch (error) {
    console.error('Error fetching product details:', error)
    product.value.name = 'Product Not Found'
  }
})
</script>

<style scoped>
h1, h2, h3 { font-family: Spectral, sans-serif; font-weight: 600; }
h1.product-name { font-size: 2.5rem; margin: 0.25rem 0; }
h2.brand-name { color: #ccc; font-size: 1.5rem; margin-bottom: 0; }
h3 { border-bottom: 1px solid #333; font-size: 1.2rem; margin-bottom: 1rem; padding-bottom: 1rem; }
label { display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.5rem; }
ul { list-style: none; padding: 0; }
.product-container { color: #ffffff; }
.product-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.product-grid { display: grid; gap: 4rem; grid-template-columns: 1fr 1fr; }
.product-image-container { align-items: center; display: flex; justify-content: center; }
.product-image { border-radius: 12px; max-width: 100%; }
.action-box { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin-bottom: 2.5rem; margin-top: 2rem; padding: 1.5rem; }
.action-buttons { display: grid; gap: 1rem; grid-template-columns: 1fr 1fr; margin-top: 1rem; }
.btn { align-items: center; border: 1px solid #444; border-radius: 8px; cursor: pointer; display: flex; flex-direction: column; font-size: 1rem; font-weight: bold; padding: 0.75rem; transition: all 0.3s ease; }
.btn-buy { background-color: #1a4a32; border-color: #6ef0a3; color: #ffffff; }
.btn-buy:hover { background-color: #256b48; }
.btn-bid { background-color: #2c2c2c; color: #ffffff; text-decoration: none; }
.btn-bid:hover { background-color: #383838; }
.btn-price { color: #ccc; font-size: 0.8rem; margin-top: 0.25rem; }
.condition-selector { display: flex; gap: 0.5rem; }
.condition-selector button { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ccc; cursor: pointer; flex-grow: 1; font-size: 1rem; padding: 0.75rem; transition: all 0.3s ease; }
.condition-selector button.active { background-color: #ffffff; border-color: #ffffff; color: #121212; }
.condition-selector button:hover:not(.active) { background-color: #383838; }
.form-group { margin-bottom: 1rem; }
select { appearance: none; background-color: #2c2c2c; background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e"); background-position: right 0.5rem center; background-repeat: no-repeat; background-size: 1.5em 1.5em; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem 2.5rem 0.75rem 1rem; width: 100%; }
.market-link { color: #ccc; display: block; font-size: 0.9rem; margin-top: 1.5rem; text-align: center; text-decoration: underline; }
.product-details li { align-items: center; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.product-details span { color: #aaa; }
@media (max-width: 900px) { .product-grid { grid-template-columns: 1fr; } }
</style>
