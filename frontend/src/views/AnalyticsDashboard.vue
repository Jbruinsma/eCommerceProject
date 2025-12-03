<template>
  <div class="dashboard-container">
    <div v-if="isLoading" class="loading-state">
      <div class="spinner"></div>
      <p class="loading-text">Loading Dashboard...</p>
    </div>

    <main v-else class="dashboard-content">
      <header class="page-header">
        <h1>Analytics</h1>
      </header>

      <section class="kpi-grid">
        <div class="card kpi-card">
          <label>Monthly Revenue ({{ monthlyRevenue.revenue_month }})</label>
          <span class="value">{{ formatCurrency(monthlyRevenue.total_revenue) }}</span>
        </div>
        <div class="card kpi-card">
          <label>All-Time Revenue</label>
          <span class="value">{{ formatCurrency(allTimeRevenue) }}</span>
        </div>
        <div class="card kpi-card">
          <label>Average Order Value</label>
          <span class="value">{{ formatCurrency(averageCompletedOrderValue) }}</span>
        </div>
        <div class="card kpi-card">
          <label>Total Orders</label>
          <span class="value">{{ totalOrders.toLocaleString('en-US') }}</span>
        </div>
      </section>

      <section class="card chart-card">
        <h2>Revenue Over Time</h2>
        <p class="chart-subtitle">Total fees generated per month.</p>
        <div class="chart-container">
          <canvas id="revenueChart" ref="chartCanvas"></canvas>
        </div>
      </section>

      <section class="insights-grid">
        <div class="card chart-card">
          <h2>Customer Breakdown</h2>
          <p class="chart-subtitle">New vs. returning customers (all-time).</p>
          <div class="chart-container" style="height: 250px">
            <canvas id="customerChart" ref="customerChartCanvas"></canvas>
          </div>
        </div>

        <div class="card">
          <h2>Sales by Category</h2>
          <div class="category-grid">
            <div
              v-for="category in salesByCategory"
              :key="category.product_type"
              class="category-card"
            >
              <span class="category-count">{{ category.total_orders.toLocaleString() }}</span>
              <span class="category-name">{{ category.product_type }}</span>
            </div>
          </div>
        </div>
      </section>

      <section class="products-section">
        <div class="section-header">
          <h2>All-Time Top Selling Products</h2>
        </div>

        <div class="product-grid">
          <div
            v-for="product in topSellingProducts"
            :key="`${product.name}-${product.size_value}`"
            class="product-card-item"
          >
            <div class="image-wrapper">
              <img
                :src="formatValidatedImageUrl(product.image_url)"
                :alt="product.name"
                class="product-img"
              />
            </div>
            <div class="product-info">
              <h3 class="product-name">{{ product.name }}</h3>
              <p class="product-meta">
                Size: {{ product.size_value }} | {{ product.product_condition }}
              </p>
              <div class="sales-badge">{{ product.total_sales }} Sales</div>
            </div>
          </div>
        </div>
      </section>

      <section class="products-section">
        <div class="section-header">
          <h2>Top Product of the Month</h2>
        </div>

        <div class="product-grid">
          <div
            v-for="product in monthlyTopProducts"
            :key="`${product.sales_month}-${product.product_name}`"
            class="product-card-item"
          >
            <div class="image-wrapper">
              <img
                :src="formatValidatedImageUrl(product.image_url)"
                :alt="product.product_name"
                class="product-img"
              />
            </div>
            <div class="product-info">
              <h3 class="product-name">{{ product.product_name }}</h3>
              <p class="product-meta">{{ product.sales_month }} | Size: {{ product.size_value }}</p>
              <div class="sales-badge">{{ product.total_sales }} Sales</div>
            </div>
          </div>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue'
import { fetchFromAPI } from '@/utils/index.js'
import { Chart, registerables } from 'chart.js'
import { formatCurrency, formatValidatedImageUrl } from '@/utils/formatting.js'

Chart.register(...registerables)

const isLoading = ref(true)

const topSellingProducts = ref([])
const monthlyTopProducts = ref([])
const monthlyRevenue = ref({
  revenue_month: 'N/A',
  total_revenue: 0,
})
const allTimeRevenue = ref(0)
const revenueOverTime = ref([])
const chartInstance = ref(null)
const chartCanvas = ref(null)

const averageCompletedOrderValue = ref(0)
const totalOrders = ref(0)
const customerBreakdown = ref([])
const salesByCategory = ref([])

const customerChartInstance = ref(null)
const customerChartCanvas = ref(null)

function renderRevenueChart(data) {
  const ctx = chartCanvas.value
  if (!ctx) return

  const labels = data.map((d) => d.month || d.revenue_month)
  const chartData = data.map((d) => d.revenue || d.total_revenue)

  if (chartInstance.value) {
    chartInstance.value.destroy()
  }

  chartInstance.value = new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Monthly Revenue',
          data: chartData,
          borderColor: 'rgba(255, 255, 255, 0.8)',
          backgroundColor: 'rgba(255, 255, 255, 0.1)',
          fill: true,
          tension: 0.1,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          ticks: { color: '#aaa' },
          grid: { color: 'rgba(255, 255, 255, 0.1)' },
        },
        x: {
          ticks: { color: '#aaa' },
          grid: { display: false },
        },
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: '#111',
          titleColor: '#fff',
          bodyColor: '#fff',
        },
      },
    },
  })
}

function renderCustomerChart(data) {
  const ctx = customerChartCanvas.value
  if (!ctx) return

  const labels = data.map((d) => d.buyer_type.replace('_', ' '))
  const chartData = data.map((d) => d.total_orders)

  if (customerChartInstance.value) {
    customerChartInstance.value.destroy()
  }

  customerChartInstance.value = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Orders',
          data: chartData,
          backgroundColor: ['rgba(255, 255, 255, 0.7)', 'rgba(255, 255, 255, 0.2)'],
          borderColor: '#1a1a1a',
          borderWidth: 4,
        },
      ],
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
          labels: {
            color: '#aaa',
            padding: 15,
          },
        },
        tooltip: {
          backgroundColor: '#111',
          titleColor: '#fff',
          bodyColor: '#fff',
        },
      },
    },
  })
}

async function fetchDashboardData() {
  isLoading.value = true
  try {
    const analyticsData = await fetchFromAPI('/admin/analytics')

    console.log(analyticsData)

    if (analyticsData) {
      if (analyticsData.revenue && Array.isArray(analyticsData.revenue)) {
        revenueOverTime.value = analyticsData.revenue
        if (analyticsData.revenue.length > 0) {
          monthlyRevenue.value = analyticsData.revenue[analyticsData.revenue.length - 1]
        }
        allTimeRevenue.value = analyticsData.revenue.reduce((sum, month) => {
          return sum + (Number(month.total_revenue) || 0)
        }, 0)
      }

      if (analyticsData.topSellingProducts) {
        topSellingProducts.value = analyticsData.topSellingProducts
      }

      if (analyticsData.monthlyTopSellingProducts) {
        monthlyTopProducts.value = analyticsData.monthlyTopSellingProducts
      }

      if (analyticsData.averageCompletedOrderValue) {
        averageCompletedOrderValue.value = analyticsData.averageCompletedOrderValue
      }

      if (analyticsData.totalOrders) {
        totalOrders.value = analyticsData.totalOrders
      }

      if (analyticsData.salesByCategory) {
        salesByCategory.value = analyticsData.salesByCategory
      }

      if (analyticsData.customerBreakdown) {
        customerBreakdown.value = analyticsData.customerBreakdown
      }

      // Allow override if API provides specific all-time total
      if (analyticsData.allTimeRevenue) {
        allTimeRevenue.value = analyticsData.allTimeRevenue
      }
    }
  } catch (err) {
    console.error('Failed to fetch dashboard data:', err)
  } finally {
    isLoading.value = false

    // Wait for DOM update after loading finishes to render charts
    await nextTick(() => {
      if (revenueOverTime.value.length > 0) renderRevenueChart(revenueOverTime.value)
      if (customerBreakdown.value.length > 0) renderCustomerChart(customerBreakdown.value)
    })
  }
}

watch(revenueOverTime, (newData) => {
  if (!isLoading.value && newData && newData.length > 0) {
    renderRevenueChart(newData)
  }
})

watch(customerBreakdown, (newData) => {
  if (!isLoading.value && newData && newData.length > 0) {
    renderCustomerChart(newData)
  }
})

onMounted(() => {
  fetchDashboardData()
})
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
h1 {
  color: #ffffff;
  font-family: Spectral, sans-serif;
  font-size: 2.2rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}
h2 {
  border-bottom: 1px solid #333;
  color: #ffffff;
  font-family: Spectral, sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
}
label {
  color: #aaa;
  display: block;
  font-size: 0.9rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  text-transform: capitalize;
}
p {
  color: #cccccc;
  line-height: 1.6;
  margin: 0.25rem 0;
}
.card {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 12px;
  margin-bottom: 2rem;
  padding: 2rem;
}
.category-card {
  align-items: center;
  background-color: #2a2a2a;
  border: 1px solid #333;
  border-radius: 8px;
  cursor: default;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  justify-content: center;
  padding: 1.5rem;
  text-align: center;
  transition:
    transform 0.2s ease,
    box-shadow 0.2s ease;
}
.category-card:hover {
  border-color: #555;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
  transform: translateY(-3px);
}
.category-count {
  color: #fff;
  font-size: 1.5rem;
  font-weight: 700;
}
.category-grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
  max-height: 500px;
  overflow-y: auto;
  padding-right: 0.5rem;
}
.category-name {
  color: #aaa;
  font-family: 'Spectral', sans-serif;
  font-size: 0.9rem;
  text-transform: capitalize;
}
.chart-card {
  min-height: 400px;
}
.chart-container {
  height: 300px;
  position: relative;
}
.chart-subtitle {
  color: #888;
  margin-bottom: 2rem;
  margin-top: -1.25rem;
}
.dashboard-container {
  color: #ffffff;
  min-height: 80vh;
  position: relative;
}
.dashboard-content {
  margin: 0 auto;
  max-width: 1200px;
  padding: 4rem 5%;
}
.image-wrapper {
  aspect-ratio: 4 / 3;
  background-color: #fff;
  border-bottom: 1px solid #333;
  overflow: hidden;
  width: 100%;
}
.insights-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: 1fr 1fr;
  margin-bottom: 2rem;
}
.kpi-card {
  margin-bottom: 0;
  padding: 1.5rem 2rem;
}
.kpi-card .value {
  color: #ffffff;
  display: block;
  font-size: 2.2rem;
  font-weight: 600;
}
.kpi-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: repeat(4, 1fr);
  margin-bottom: 2rem;
}
.loading-state {
  align-items: center;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  height: 50vh;
  justify-content: center;
  width: 100%;
}
.loading-text {
  color: #888;
  font-family: 'Spectral', sans-serif;
  font-size: 1.1rem;
}
.page-header {
  margin-bottom: 3rem;
  text-align: left;
}
.product-card-item {
  background-color: #2a2a2a;
  border: 1px solid #333;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition:
    transform 0.2s,
    box-shadow 0.2s;
}
.product-card-item:hover {
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.5);
  transform: translateY(-5px);
}
.product-grid {
  display: grid;
  gap: 1.5rem;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
}
.product-img {
  height: 100%;
  object-fit: contain;
  width: 100%;
}
.product-info {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  gap: 0.5rem;
  padding: 1rem;
  text-align: center;
}
.product-meta {
  color: #888;
  font-family: 'Spectral', sans-serif;
  font-size: 0.85rem;
  text-transform: capitalize;
}
.product-name {
  color: #fff;
  font-family: 'Bodoni Moda', serif;
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.products-section {
  margin-bottom: 3rem;
}
.sales-badge {
  background-color: #333;
  border-radius: 4px;
  color: #fff;
  display: inline-block;
  font-size: 0.9rem;
  font-weight: bold;
  margin-top: auto;
  padding: 0.25rem 0.75rem;
}
.spinner {
  animation: spin 1s linear infinite;
  border: 3px solid rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  border-top: 3px solid #fff;
  height: 40px;
  width: 40px;
}
@media (max-width: 1024px) {
  .insights-grid {
    grid-template-columns: 1fr;
  }
  .kpi-grid {
    grid-template-columns: 1fr 1fr;
  }
}
@media (max-width: 768px) {
  .kpi-grid {
    grid-template-columns: 1fr;
  }
}
</style>
