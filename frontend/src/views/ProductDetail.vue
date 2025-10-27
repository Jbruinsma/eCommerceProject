<template>
  <div class="product-container">
    <main class="product-content">
      <div class="product-grid">
        <div class="product-image-container">
          <img :src="product.imageUrl" :alt="product.name" class="product-image" />
        </div>

        <div class="product-info-container">
          <h2 class="brand-name">{{ product.brandName }}</h2>
          <h1 class="product-name">{{ product.name }}</h1>

          <div class="action-box">
            <div class="form-group">
              <label for="size-select">Size</label>
              <select id="size-select" v-model="selectedSize">
                <option v-for="size in availableSizes" :key="size" :value="size">
                  {{ size }}
                </option>
              </select>
            </div>

            <div class="action-buttons">
              <router-link
                v-if="currentMarketData.lowestAsk"
                :to="{
                  name: 'PlaceOrder',
                  // Ensure listingId from lowestAsk is passed correctly
                  params: { listingId: currentMarketData.lowestAsk.listingId },
                  query: { size: selectedSize },
                }"
                class="btn btn-buy"
              >
                Buy Now
                <span class="btn-price">{{ formatCurrency(currentMarketData.lowestAsk.price) }}</span>
              </router-link>

              <button v-else class="btn btn-buy" disabled>
                Buy Now
                <span class="btn-price">{{ formatCurrency(null) }}</span>
              </button>

              <router-link
                :to="{
                  name: 'PlaceBid',
                  // The parameter should likely be the product ID, not a listing ID
                  params: { listingId: product.productId },
                  query: { size: selectedSize },
                }"
                class="btn btn-bid"
              >
                Place Bid
                <span class="btn-price">{{ formatCurrency(currentMarketData.highestBid ? currentMarketData.highestBid.amount : null) }}</span>
              </router-link>
            </div>
            <a href="#" class="market-link">View Market Data</a>
          </div>

          <div class="product-details">
            <h3>Product Details</h3>
            <ul>
              <li>
                <strong>Retail Price</strong><span>{{ formatCurrency(product.retailPrice) }}</span>
              </li>
              <li>
                <strong>Release Date</strong><span>{{ formatDate(product.releaseDate) }}</span>
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
const productId = route.params.id

const product = ref({
  productId: productId,
  brandName: '',
  name: 'Loading...',
  retailPrice: 0,
  releaseDate: '',
  imageUrl: 'https://placehold.co/800x600/1a1a1a/ffffff?text=Loading',
})

const availableSizes = ref([])
const selectedSize = ref(null)

const marketData = ref({})

const currentMarketData = computed(() => {
  return marketData.value[selectedSize.value] || { lowestAsk: null, highestBid: null }
})

const formatCurrency = (amount) => {
  if (amount === null || typeof amount !== 'number') return '—'
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  // Corrected the function call here
  return new Date(dateString).toLocaleDateString('en-US', options)
}

onMounted(async () => {
  try {
    const response = await fetchFromAPI(`/search/${productId}`)

    product.value = { ...response, productId: productId }

    if (response.sizes && response.sizes.length > 0) {
      const processedMarketData = {}
      const uniqueSizes = new Set()

      response.sizes.forEach(item => {
        uniqueSizes.add(item.size)
        if (!processedMarketData[item.size]) {
          processedMarketData[item.size] = {
            highestBid: null,
            lowestAsk: null,
          }
        }

        if (item.highestBid.amount && (!processedMarketData[item.size].highestBid || item.highestBid.amount > processedMarketData[item.size].highestBid.amount)) {
          processedMarketData[item.size].highestBid = item.highestBid
        }

        if (item.lowestAskingPrice.price && (!processedMarketData[item.size].lowestAsk || item.lowestAskingPrice.price < processedMarketData[item.size].lowestAsk.price)) {
          processedMarketData[item.size].lowestAsk = item.lowestAskingPrice
        }
      });

      marketData.value = processedMarketData;

      const sortedSizes = Array.from(uniqueSizes).sort((a, b) => {
        const numA = parseFloat(a)
        const numB = parseFloat(b)
        if (!isNaN(numA) && !isNaN(numB)) {
          return numA - numB
        }
        return a.localeCompare(b)
      })

      availableSizes.value = sortedSizes

      // Set a default selected size
      if (sortedSizes.includes('10')) {
        selectedSize.value = '10'
      } else if (sortedSizes.includes('M')) {
        selectedSize.value = 'M'
      } else {
        selectedSize.value = sortedSizes[0]
      }
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
.btn { align-items: center; border: 1px solid #444; border-radius: 8px; cursor: pointer; display: flex; flex-direction: column; font-size: 1rem; font-weight: bold; padding: 0.75rem; text-decoration: none; transition: all 0.3s ease; }
.btn-buy { background-color: #1a4a32; border-color: #6ef0a3; color: #ffffff; }
.btn-buy:hover:not(:disabled) { background-color: #256b48; }
.btn-buy:disabled { cursor: not-allowed; opacity: 0.5; }
.btn-bid { background-color: #2c2c2c; color: #ffffff; }
.btn-bid:hover { background-color: #383838; }
.btn-price { color: #ccc; font-size: 0.8rem; margin-top: 0.25rem; }
.form-group { margin-bottom: 1rem; }
select { appearance: none; background-color: #2c2c2c; background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e"); background-position: right 0.5rem center; background-repeat: no-repeat; background-size: 1.5em 1.5em; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem 2.5rem 0.75rem 1rem; width: 100%; }
.market-link { color: #ccc; display: block; font-size: 0.9rem; margin-top: 1.5rem; text-align: center; text-decoration: underline; }
.product-details li { align-items: center; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.product-details span { color: #aaa; }
@media (max-width: 900px) { .product-grid { grid-template-columns: 1fr; } }
</style>
