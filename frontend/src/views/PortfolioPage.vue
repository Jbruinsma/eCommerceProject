<template>
  <div class="portfolio-container">
    <main class="portfolio-content">
      <section class="overview-section">
        <h2>Portfolio Overview</h2>
        <div class="stats-grid">
          <div class="stat-card">
            <h3>{{ formatCurrency(totalPortfolioValue) }}</h3>
            <p>Total Portfolio Value</p>
          </div>
          <div class="stat-card">
            <h3 :class="totalGainLoss >= 0 ? 'gain' : 'loss'">
              {{ formatCurrency(totalGainLoss) }}
            </h3>
            <p>Total Gain / Loss</p>
          </div>
          <div class="stat-card">
            <h3>{{ portfolioItems.length }}</h3>
            <p>Items in Portfolio</p>
          </div>
        </div>
      </section>

      <section class="items-section">
        <div class="items-header">
          <h2>My Collection</h2>
          <button @click="redirectToAddItem" class="btn btn-primary">Add Item</button>
        </div>
        <div class="table-wrapper">
          <table class="portfolio-table">
            <thead>
              <tr>
                <th>Item</th>
                <th>Size</th>
                <th>Acquired</th>
                <th>Paid</th>
                <th>Market Value</th>
                <th>Gain / Loss</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="portfolioItems.length === 0">
                <td colspan="7">Your portfolio is empty.</td>
              </tr>
              <tr v-for="item in portfolioItems" :key="item.portfolioItemId">
                <td>
                  <div class="product-cell">
                    <img
                      :src="item.product.image_url"
                      :alt="item.product.name"
                      class="product-image"
                    />
                    <span>{{ item.product.name }}</span>
                  </div>
                </td>
                <td>{{ item.size.sizeValue }}</td>
                <td>{{ formatDate(item.acquisitionDate) }}</td>
                <td>{{ formatCurrency(item.acquisitionPrice) }}</td>
                <td>{{ formatCurrency(item.marketValue) }}</td>
                <td>
                  <span :class="item.gainLoss >= 0 ? 'gain' : 'loss'">
                    {{ formatCurrency(item.gainLoss) }}
                  </span>
                </td>
                <td>
                  <button class="btn btn-primary">Sell Item</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </main>

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'
import { fetchFromAPI } from '@/utils/index.js'
import { formatCurrency, formatDate } from '@/utils/formatting.js'

const authStore = useAuthStore()
const portfolioItems = ref([])

const totalPortfolioValue = ref(0)
const totalGainLoss = ref(0)

onMounted(async () => {
  totalPortfolioValue.value = 0
  totalGainLoss.value = 0

  try {
    const portfolioItemsResponse = await fetchFromAPI(`/portfolio/${authStore.uuid}`)

    for (const item of portfolioItemsResponse) {
      const itemMarketValue = item.marketValue
      const itemGainLoss = item.gainLoss

      if (itemMarketValue != null) totalPortfolioValue.value += itemMarketValue
      if (itemGainLoss != null) totalGainLoss.value += itemGainLoss
    }

    portfolioItems.value = portfolioItemsResponse
  } catch (err) {
    console.error(err)
  }
})

// Navigation handlers
function redirectToAddItem() {
  router.push('/portfolio/add')
}
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; text-align: left; }
.portfolio-container { color: #ffffff; font-family: Spectral, sans-serif; }
.portfolio-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.overview-section { margin-bottom: 4rem; }
.stats-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.stat-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 8px; padding: 2rem; text-align: center; }
.stat-card h3 { color: #ffffff; font-size: 2.2rem; margin: 0 0 0.5rem 0; }
.stat-card p { color: #888; font-size: 0.9rem; margin: 0; }
.items-header { align-items: center; display: flex; justify-content: space-between; }
.items-header h2 { border-bottom: none; margin-bottom: 1rem; }
.table-wrapper { overflow-x: auto; }
.portfolio-table { border-collapse: collapse; width: 100%; }
thead th { background-color: #1a1a1a; border-bottom: 2px solid #333; color: #ffffff; font-weight: 600; padding: 1rem; text-align: left; }
tbody td { border-bottom: 1px solid #2a2a2a; padding: 1rem; vertical-align: middle; }
tbody tr:hover { background-color: #1f1f1f; }
.product-cell { align-items: center; display: flex; gap: 1rem; }
.product-image { border-radius: 4px; height: 50px; object-fit: cover; width: 50px; }
.gain { color: #6ef0a3; }
.loss { color: #f06e6e; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.6rem 1.2rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-primary:hover { background-color: #cccccc; }
.site-footer { background-color: #1a1a1a; border-top: 1px solid #333; color: #888; padding: 2rem 5%; text-align: center; }

@media (max-width: 768px) {
  .portfolio-content { padding: 2rem 5%; }
  .stats-grid { grid-template-columns: 1fr; }
  .stat-card { padding: 1.5rem; }
  .stat-card h3 { font-size: 1.8rem; }
  .items-header { align-items: flex-start; flex-direction: column; gap: 1rem; }
  .items-header h2 { margin-bottom: 0; }
  .btn { width: 100%; }
  thead th, tbody td { font-size: 0.9rem; padding: 0.75rem; white-space: nowrap; }
  .product-cell span { white-space: normal; }
}

@media (max-width: 480px) {
  .portfolio-content { padding: 2rem 3%; }
}
</style>
