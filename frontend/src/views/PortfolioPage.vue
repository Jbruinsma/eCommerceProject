<template>
  <div class="portfolio-container">
    <main class="portfolio-content">
      <div v-if="isLoading" class="loading-container">
        <div class="spinner"></div>
        <p>Loading your portfolio...</p>
      </div>

      <div v-else>
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
                  <td class="item-cell">
                    <div class="product-cell">
                      <img
                        :src="item.product.image_url"
                        :alt="item.product.name"
                        class="product-image"
                      />
                      <span class="product-name">{{ item.product.name }}</span>
                    </div>
                  </td>
                  <td data-label="Size">{{ item.size.sizeValue }}</td>
                  <td data-label="Acquired">{{ formatDate(item.acquisitionDate) }}</td>
                  <td data-label="Paid">{{ formatCurrency(item.acquisitionPrice) }}</td>
                  <td data-label="Market Value">{{ formatCurrency(item.marketValue) }}</td>
                  <td data-label="Gain / Loss">
                    <span :class="item.gainLoss >= 0 ? 'gain' : 'loss'">
                      {{ formatCurrency(item.gainLoss) }}
                    </span>
                  </td>
                  <td data-label="Actions" class="actions-cell">
                    <button class="btn btn-primary btn-sm">Sell Item</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
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
const isLoading = ref(true)

const totalPortfolioValue = ref(0)
const totalGainLoss = ref(0)

onMounted(async () => {
  isLoading.value = true
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
  } finally {
    isLoading.value = false
  }
})

function redirectToAddItem() {
  router.push('/portfolio/add')
}
</script>

<style scoped>
@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

a {
  color: #ffffff;
  text-decoration: none;
}
h2 {
  border-bottom: 1px solid #333;
  font-size: 1.8rem;
  margin-bottom: 2rem;
  padding-bottom: 1rem;
  text-align: left;
}
.btn {
  border: 1px solid transparent;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: bold;
  padding: 0.6rem 1.2rem;
  transition: all 0.3s ease;
}
.btn-primary {
  background-color: #ffffff;
  color: #121212;
}
.btn-primary:hover {
  background-color: #cccccc;
}
.btn-sm {
  font-size: 0.8rem;
  padding: 0.4rem 0.8rem;
}
.gain {
  color: #6ef0a3;
}
.items-header {
  align-items: center;
  display: flex;
  justify-content: space-between;
}
.items-header h2 {
  border-bottom: none;
  margin-bottom: 1rem;
}
.loading-container {
  align-items: center;
  display: flex;
  flex-direction: column;
  justify-content: center;
  min-height: 50vh;
  text-align: center;
}
.loss {
  color: #f06e6e;
}
.overview-section {
  margin-bottom: 4rem;
}
.portfolio-container {
  color: #ffffff;
  font-family: Spectral, sans-serif;
}
.portfolio-content {
  margin: 0 auto;
  max-width: 1200px;
  padding: 4rem 5%;
}
.portfolio-table {
  border-collapse: collapse;
  width: 100%;
}
.product-cell {
  align-items: center;
  display: flex;
  gap: 1rem;
}
.product-image {
  border-radius: 4px;
  height: 50px;
  object-fit: cover;
  width: 50px;
}
.site-footer {
  background-color: #1a1a1a;
  border-top: 1px solid #333;
  color: #888;
  padding: 2rem 5%;
  text-align: center;
}
.spinner {
  animation: spin 1s linear infinite;
  border: 4px solid #333;
  border-top: 4px solid #ffffff;
  border-radius: 50%;
  height: 50px;
  margin-bottom: 1rem;
  width: 50px;
}
.stat-card {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
}
.stat-card h3 {
  color: #ffffff;
  font-size: 2.2rem;
  margin: 0 0 0.5rem 0;
}
.stat-card p {
  color: #888;
  font-size: 0.9rem;
  margin: 0;
}
.stats-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}
.table-wrapper {
  overflow-x: auto;
}
tbody td {
  border-bottom: 1px solid #2a2a2a;
  padding: 1rem;
  vertical-align: middle;
}
tbody tr:hover {
  background-color: #1f1f1f;
}
thead th {
  background-color: #1a1a1a;
  border-bottom: 2px solid #333;
  color: #ffffff;
  font-weight: 600;
  padding: 1rem;
  text-align: left;
}

@media (max-width: 768px) {
  .items-header {
    align-items: stretch;
    flex-direction: column;
    gap: 1rem;
  }
  .items-header h2 {
    margin-bottom: 0.5rem;
  }
  .portfolio-content {
    padding: 2rem 5%;
  }
  .stat-card {
    padding: 1.5rem;
  }
  .stat-card h3 {
    font-size: 1.8rem;
  }
  .stats-grid {
    grid-template-columns: 1fr;
  }

  .portfolio-table,
  tbody,
  td,
  th,
  thead,
  tr {
    display: block;
  }
  thead {
    position: absolute;
    top: -9999px;
    left: -9999px;
  }
  tbody tr {
    background-color: #1a1a1a;
    border: 1px solid #2a2a2a;
    border-radius: 8px;
    margin-bottom: 1.5rem;
    overflow: hidden;
  }

  tbody td {
    align-items: center;
    border: none;
    border-bottom: 1px solid #2a2a2a;
    display: flex;
    justify-content: space-between;
    padding: 0.8rem 1rem;
    text-align: right;
  }
  tbody td::before {
    color: #888;
    content: attr(data-label);
    float: left;
    font-size: 0.85rem;
    font-weight: bold;
    text-transform: uppercase;
  }

  .item-cell {
    background-color: #222;
    border-bottom: 1px solid #333;
    flex-direction: row;
    justify-content: flex-start;
    padding: 1rem;
    text-align: left;
  }

  .item-cell::before {
    display: none;
  }

  .product-cell {
    width: 100%;
    flex-direction: row;
    justify-content: flex-start;
    gap: 1rem;
  }
  .product-image {
    height: 60px;
    width: 60px;
    margin-right: 0.5rem;
  }
  .product-name {
    font-size: 1.1rem;
    font-weight: 600;
    color: #fff;
    line-height: 1.3;
  }

  /* Last Child (Actions) */
  tbody td:last-child {
    border-bottom: none;
    padding-top: 1rem;
    padding-bottom: 1rem;
  }
}

@media (max-width: 480px) {
  .portfolio-content {
    padding: 2rem 3%;
  }
  tbody td {
    font-size: 0.9rem;
  }
}
</style>
