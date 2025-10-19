<template>
  <div class="product-container">
    <main class="product-content">
      <div class="product-grid">
        <div class="product-image-container">
          <img :src="product.image_url" :alt="product.name" class="product-image" />
        </div>

        <div class="product-info-container">
          <h2 class="brand-name">{{ product.brand.brand_name }}</h2>
          <h1 class="product-name">{{ product.name }}</h1>
          <p class="last-sale">Last Sale: {{ formatCurrency(currentMarketData.last_sale) }}</p>

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
              <button class="btn btn-buy">
                Buy Now
                <span class="btn-price">{{ formatCurrency(currentMarketData.lowest_ask) }}</span>
              </button>
              <button class="btn btn-bid">
                Place Bid
                <span class="btn-price">{{ formatCurrency(currentMarketData.highest_bid) }}</span>
              </button>
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
import router from '@/router/index.js'
import { fetchFromAPI } from '@/utils/index.js'

const product_id = router.currentRoute.value.params.id

// Mock data based on your SQL schema for a single product.
// This simulates fetching a product and its related brand, sizes, and active listings.
const product = ref({
  product_id: 1,
  brand: { brand_name: 'Maison Margiela' },
  name: 'Future Sneaker "Black"',
  sku: 'S57WS0283P2703',
  colorway: 'Black/White',
  retail_price: '990.00',
  release_date: '2025-08-15',
  image_url: 'https://placehold.co/800x600/1a1a1a/ffffff?text=Sneaker',
})

const availableSizes = ref(['9', '9.5', '10', '10.5', '11', '12'])
const selectedSize = ref(availableSizes.value[2]) // Default to size 10

// This simulates querying your `listings` table for the lowest asks and highest bids per size.
const marketData = ref({
  9: { lowest_ask: 1150, highest_bid: 980, last_sale: 1100 },
  9.5: { lowest_ask: 1180, highest_bid: 1000, last_sale: 1120 },
  10: { lowest_ask: 1200, highest_bid: 1050, last_sale: 1150 },
  10.5: { lowest_ask: 1250, highest_bid: 1080, last_sale: 1190 },
  11: { lowest_ask: 1300, highest_bid: 1100, last_sale: 1250 },
  12: { lowest_ask: 1450, highest_bid: 1200, last_sale: 1400 },
})

// Computed property to get the market data for the currently selected size.
const currentMarketData = computed(() => {
  return marketData.value[selectedSize.value] || { lowest_ask: 0, highest_bid: 0, last_sale: 0 }
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDate = (dateString) => {
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('en-US', options)
}

onMounted(async () => {
  console.log('Product ID:', product_id)

  try {
    const response = await fetchFromAPI(`/product/${product_id}`)
  } catch (error) {
    console.error('Error fetching product:', error)
  }

})

// Nav handled by NavBar component globally (header handlers removed)
</script>

<style scoped>
h1,
h2,
h3 {
  font-family: Spectral, sans-serif;
  font-weight: 600;
}
h1.product-name {
  font-size: 2.5rem;
  margin: 0.25rem 0;
}
h2.brand-name {
  color: #ccc;
  font-size: 1.5rem;
  margin-bottom: 0;
}
h3 {
  border-bottom: 1px solid #333;
  font-size: 1.2rem;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
}
label {
  display: block;
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}
ul {
  list-style: none;
  padding: 0;
}
.product-container {
  color: #ffffff;
}
.product-content {
  margin: 0 auto;
  max-width: 1200px;
  padding: 4rem 5%;
}
.product-grid {
  display: grid;
  gap: 4rem;
  grid-template-columns: 1fr 1fr;
}
.product-image-container {
  align-items: center;
  display: flex;
  justify-content: center;
}
.product-image {
  border-radius: 12px;
  max-width: 100%;
}
.last-sale {
  color: #aaa;
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 2rem;
}
.action-box {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  margin-bottom: 2.5rem;
  padding: 1.5rem;
}
.action-buttons {
  display: grid;
  gap: 1rem;
  grid-template-columns: 1fr 1fr;
  margin-top: 1rem;
}
.btn {
  align-items: center;
  border: 1px solid #444;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  font-size: 1rem;
  font-weight: bold;
  padding: 0.75rem;
  transition: all 0.3s ease;
}
.btn-buy {
  background-color: #1a4a32;
  border-color: #6ef0a3;
  color: #ffffff;
}
.btn-buy:hover {
  background-color: #256b48;
}
.btn-bid {
  background-color: #2c2c2c;
  color: #ffffff;
}
.btn-bid:hover {
  background-color: #383838;
}
.btn-price {
  color: #ccc;
  font-size: 0.8rem;
  margin-top: 0.25rem;
}
select {
  appearance: none;
  background-color: #2c2c2c;
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e");
  background-position: right 0.5rem center;
  background-repeat: no-repeat;
  background-size: 1.5em 1.5em;
  border: 1px solid #444;
  border-radius: 8px;
  color: #ffffff;
  font-size: 1rem;
  padding: 0.75rem 2.5rem 0.75rem 1rem;
  width: 100%;
}
.market-link {
  color: #ccc;
  display: block;
  font-size: 0.9rem;
  margin-top: 1.5rem;
  text-align: center;
  text-decoration: underline;
}
.product-details li {
  align-items: center;
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.75rem;
}
.product-details span {
  color: #aaa;
}
@media (max-width: 900px) {
  .product-grid {
    grid-template-columns: 1fr;
  }
}
</style>
