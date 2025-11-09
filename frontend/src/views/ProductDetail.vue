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
              <label>Condition</label>
              <div class="condition-selector">
                <button
                  v-for="condition in availableConditions"
                  :key="condition"
                  @click="selectedCondition = condition"
                  :class="['btn-condition', { active: selectedCondition === condition }]"
                >
                  {{ condition.charAt(0).toUpperCase() + condition.slice(1) }}
                </button>
              </div>
            </div>

            <div class="form-group">
              <label for="size-select">Size</label>
              <div class="size-selector-wrapper">
                <select id="size-select" v-model="selectedSize">
                  <option v-for="size in availableSizes" :key="size" :value="size">
                    {{ size }}
                  </option>
                </select>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                  class="size-arrow-icon"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="m19.5 8.25-7.5 7.5-7.5-7.5"
                  />
                </svg>
              </div>
            </div>
            <div class="action-buttons">
              <button
                v-if="currentMarketData.lowestAsk && currentMarketData.lowestAsk.price"
                @click="
                  redirectToBuyPage(
                    currentMarketData.lowestAsk.listingId,
                    selectedSize,
                    selectedCondition,
                  )
                "
                class="btn btn-buy"
              >
                Buy Now
                <span class="btn-price">{{
                    formatCurrency(currentMarketData.lowestAsk.price)
                  }}</span>
              </button>

              <button v-else class="btn btn-buy" disabled>
                Buy Now
                <span class="btn-price">{{ formatCurrency(null) }}</span>
              </button>

              <button
                @click="redirectToBidPage(product.productId, selectedSize, selectedCondition)"
                class="btn btn-bid"
              >
                Place Bid
                <span class="btn-price">{{
                    formatCurrency(
                      currentMarketData.highestBid ? currentMarketData.highestBid.amount : null,
                    )
                  }}</span>
              </button>
            </div>
          </div>

          <div class="product-details">
            <h3>Product Details</h3>
            <ul>
              <li>
                <strong>Retail Price</strong
                ><span>{{ formatCurrency(product.retailPrice) }}</span>
              </li>
              <li>
                <strong>Release Date</strong
                ><span>{{ formatDate(product.releaseDate) }}</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </main>

    <section class="chart-container">
      <h3>
        Sales History
        <span v-if="selectedSize">
          ({{ selectedCondition.charAt(0).toUpperCase() + selectedCondition.slice(1) }} - Size
          {{ selectedSize }})
        </span>
      </h3>
      <div class="chart-wrapper">
        <canvas ref="salesChartCanvas"></canvas>
      </div>
    </section>

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { fetchFromAPI } from '@/utils/index.js'
import { Chart, registerables } from 'chart.js'
import { redirectToBuyPage, redirectToBidPage } from '@/utils/routing.js'

Chart.register(...registerables)

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

const availableConditions = ref(['new', 'used', 'worn'])
const selectedCondition = ref('new')

const marketData = ref({})
const salesHistory = ref({})

const salesChartCanvas = ref(null)
let salesChartInstance = null

const currentMarketData = computed(() => {
  if (!selectedSize.value || !selectedCondition.value) {
    return { lowestAsk: null, highestBid: null }
  }
  const sizeData = marketData.value[selectedSize.value]
  if (!sizeData) {
    return { lowestAsk: null, highestBid: null }
  }
  return sizeData[selectedCondition.value] || { lowestAsk: null, highestBid: null }
})

const currentSalesHistory = computed(() => {
  if (!selectedSize.value || !selectedCondition.value || !salesHistory.value) {
    return []
  }
  const historyEntryKey = Object.keys(salesHistory.value).find(
    (key) => salesHistory.value[key].sizeValue === selectedSize.value,
  )
  if (!historyEntryKey) {
    return []
  }
  const salesList = salesHistory.value[historyEntryKey][selectedCondition.value]
  if (!salesList || salesList.length === 0) {
    return []
  }
  return salesList.slice().sort((a, b) => new Date(a.order_date) - new Date(b.order_date))
})

const formatCurrency = (amount) => {
  if (amount === null || typeof amount !== 'number') return '—'
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const options = { year: 'numeric', month: 'long', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('en-US', options)
}

const renderChart = () => {
  if (!salesChartCanvas.value) return
  const salesData = currentSalesHistory.value
  const labels = salesData.map((sale) => formatDate(sale.order_date))
  const data = salesData.map((sale) => sale.sale_price)
  const chartConfig = {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Sale Price',
          data: data,
          borderColor: 'rgba(255, 255, 255, 0.8)',
          backgroundColor: 'rgba(255, 255, 255, 0.1)',
          tension: 0.1,
          fill: true,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false,
        },
        tooltip: {
          backgroundColor: '#111',
          titleFont: { weight: 'bold' },
          callbacks: {
            label: function (context) {
              return `Price: ${formatCurrency(context.parsed.y)}`
            },
          },
        },
      },
      scales: {
        x: {
          ticks: { color: '#aaa' },
          grid: { color: 'rgba(255, 255, 255, 0.1)' },
        },
        y: {
          ticks: {
            color: '#aaa',
            callback: function (value) {
              return formatCurrency(value)
            },
          },
          grid: { color: 'rgba(255, 255, 255, 0.1)' },
        },
      },
    },
  }
  if (salesChartInstance) {
    salesChartInstance.data.labels = labels
    salesChartInstance.data.datasets[0].data = data
    salesChartInstance.update()
  } else {
    salesChartInstance = new Chart(salesChartCanvas.value, chartConfig)
  }
}

onMounted(async () => {
  try {
    const [response, salesHistoryResponse] = await Promise.all([
      fetchFromAPI(`/search/${productId}`),
      fetchFromAPI(`/product/history/${productId}`),
    ])

    product.value = { ...response, productId: productId }
    if (response.sizes && response.sizes.length > 0) {
      const processedMarketData = {}
      const uniqueSizes = new Set()
      response.sizes.forEach((item) => {
        uniqueSizes.add(item.size)
        if (!processedMarketData[item.size]) {
          processedMarketData[item.size] = {}
        }
        availableConditions.value.forEach((condition) => {
          processedMarketData[item.size][condition] = {
            highestBid: item.highestBid[condition],
            lowestAsk: item.lowestAskingPrice[condition],
          }
        })
      })
      marketData.value = processedMarketData
      const sortedSizes = Array.from(uniqueSizes).sort((a, b) => {
        const numA = parseFloat(a)
        const numB = parseFloat(b)
        if (!isNaN(numA) && !isNaN(numB)) {
          return numA - numB
        }
        return a.localeCompare(b)
      })
      availableSizes.value = sortedSizes
      if (sortedSizes.includes('10')) {
        selectedSize.value = '10'
      } else if (sortedSizes.includes('M')) {
        selectedSize.value = 'M'
      } else if (sortedSizes.length > 0) {
        selectedSize.value = sortedSizes[0]
      }
    }
    salesHistory.value = salesHistoryResponse
    renderChart()
  } catch (error) {
    console.error('Error fetching product details:', error)
    product.value.name = 'Product Not Found'
  }
})

watch(currentSalesHistory, () => {
  renderChart()
})

onUnmounted(() => {
  if (salesChartInstance) {
    salesChartInstance.destroy()
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
.btn-bid { background-color: #2c2c2c; color: #ffffff; }
.btn-bid:hover { background-color: #383838; }
.btn-buy { background-color: #1a4a32; border-color: #6ef0a3; color: #ffffff; }
.btn-buy:disabled { cursor: not-allowed; opacity: 0.5; }
.btn-buy:hover:not(:disabled) { background-color: #256b48; }
.btn-condition { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; cursor: pointer; flex-grow: 1; font-weight: 600; padding: 0.75rem; transition: background-color 0.2s ease, border-color 0.2s ease; }
.btn-condition.active { background-color: #4a4a4a; border-color: #888; }
.btn-condition:hover { background-color: #383838; }
.btn-price { color: #ccc; font-size: 0.8rem; margin-top: 0.25rem; }
.condition-selector { display: flex; gap: 0.5rem; }
.form-group { margin-bottom: 1rem; }
.product-details li { align-items: center; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.product-details span { color: #aaa; }
.size-arrow-icon { color: #aaa; height: 1.25rem; pointer-events: none; position: absolute; right: 0.75rem; top: 50%; transform: translateY(-50%); width: 1.25rem; }
.size-selector-wrapper { position: relative; }
.size-selector-wrapper select:hover { cursor: pointer; }
select { appearance: none; background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem 2.5rem 0.75rem 1rem; width: 100%; }
.chart-container { margin: 0 auto; max-width: 1200px; padding: 1rem 5% 4rem; }
.chart-container h3 { font-size: 1.5rem; }
.chart-container h3 span { color: #aaa; font-size: 1.1rem; font-weight: 400; }
.chart-wrapper { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; height: 400px; padding: 1.5rem; position: relative; }
@media (max-width: 900px) {
  .action-buttons { grid-template-columns: 1fr; }
  .chart-container { padding: 1rem 5% 3rem; }
  .chart-wrapper { height: 350px; }
  .product-content { padding: 2rem 5%; }
  .product-grid { gap: 2rem; grid-template-columns: 1fr; }
  h1.product-name { font-size: 1.8rem; }
  h2.brand-name { font-size: 1.2rem; }
}
@media (max-width: 480px) {
  .chart-container { padding: 1rem 3% 2rem; }
  .product-content { padding: 2rem 3%; }
}
</style>
