<template>
  <div class="dashboard-container">
    <main class="dashboard-content">
      <header class="page-header">
        <h1>Analytics</h1>
      </header>

      <section class="kpi-grid">
        <div class="card kpi-card">
          <label>Latest Monthly Revenue ({{ monthlyRevenue.revenue_month }})</label>
          <span class="value">{{ formatCurrency(monthlyRevenue.total_revenue) }}</span>
        </div>
        <div class="card kpi-card">
          <label>All-Time Revenue</label>
          <span class="value">{{ formatCurrency(allTimeRevenue) }}</span>
        </div>
      </section>

      <section class="card chart-card">
        <h2>Revenue Over Time</h2>
        <p class="chart-subtitle">Total fees generated per month.</p>
        <div class="chart-container">
          <canvas id="revenueChart" ref="chartCanvas"></canvas>
        </div>
      </section>

      <div class="activity-grid">
        <div class="card">
          <h2>All-Time Top Selling Products</h2>
          <ul class="product-list">
            <li v-for="product in topSellingProducts" :key="`${product.name}-${product.size_value}`">
              <img :src="resolveImageUrl(product.image_url)" :alt="product.name" class="list-img" />
              <div class="list-details">
                <span class="list-main">{{ product.name }}</span>
                <span class="list-sub">
                  Size: {{ product.size_value }} ({{ product.product_condition }})
                </span>
              </div>
              <span class="list-count">{{ product.total_sales }} sales</span>
            </li>
          </ul>
        </div>

        <div class="card">
          <h2>Top Product of the Month</h2>
          <ul class="product-list">
            <li v-for="product in monthlyTopProducts" :key="`${product.sales_month}-${product.product_name}`">
              <img :src="resolveImageUrl(product.image_url)" :alt="product.product_name" class="list-img" />
              <div class="list-details">
                <span class="list-main">{{ product.sales_month }} - {{ product.product_name }}</span>
                <span class="list-sub">
                  Size: {{ product.size_value }} ({{ product.product_condition }})
                </span>
              </div>
              <span class="list-count">{{ product.total_sales }} sales</span>
            </li>
          </ul>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { fetchFromAPI } from '@/utils/index.js'
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

const topSellingProducts = ref([]);
const monthlyTopProducts = ref([]);
const monthlyRevenue = ref({
  revenue_month: 'N/A',
  total_revenue: 0
});
const allTimeRevenue = ref(0);
const revenueOverTime = ref([]);
const chartInstance = ref(null);
const chartCanvas = ref(null);

function formatCurrency(value) {
  const n = Number(value)
  if (!Number.isFinite(n)) return '$0.00'
  return n.toLocaleString('en-US', { style: 'currency', currency: 'USD' })
}

function resolveImageUrl(url) {
  if (!url) {
    return 'https://placehold.co/100x100/333/fff?text=N/A'
  }
  if (url.startsWith('/')) {
    return url;
  }
  return '/' + url;
}

function renderRevenueChart(data) {
  const ctx = chartCanvas.value;
  if (!ctx) return;

  const labels = data.map(d => d.month || d.revenue_month);
  const chartData = data.map(d => d.revenue || d.total_revenue);

  if (chartInstance.value) {
    chartInstance.value.destroy();
  }

  chartInstance.value = new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [{
        label: 'Monthly Revenue',
        data: chartData,
        borderColor: 'rgba(255, 255, 255, 0.8)',
        backgroundColor: 'rgba(255, 255, 255, 0.1)',
        fill: true,
        tension: 0.1
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          beginAtZero: true,
          ticks: { color: '#aaa' },
          grid: { color: 'rgba(255, 255, 255, 0.1)' }
        },
        x: {
          ticks: { color: '#aaa' },
          grid: { display: false }
        }
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: '#111',
          titleColor: '#fff',
          bodyColor: '#fff',
        }
      }
    }
  });
}

async function fetchDashboardData() {
  try {
    const analyticsData = await fetchFromAPI('/admin/analytics')
    console.log("Analytics Data:", analyticsData)

    if (analyticsData) {
      if (analyticsData.revenue && Array.isArray(analyticsData.revenue) && analyticsData.revenue.length > 0) {
        revenueOverTime.value = analyticsData.revenue;
        monthlyRevenue.value = analyticsData.revenue[analyticsData.revenue.length - 1];
        allTimeRevenue.value = analyticsData.revenue.reduce((sum, month) => {
          const revenue = Number(month.total_revenue) || 0;
          return sum + revenue;
        }, 0);

      }

      if (analyticsData.topSellingProducts) {
        topSellingProducts.value = analyticsData.topSellingProducts;
      }
      if (analyticsData.monthlyTopSellingProducts) {
        monthlyTopProducts.value = analyticsData.monthlyTopSellingProducts;
      }

      if (analyticsData.allTimeRevenue) {
        allTimeRevenue.value = analyticsData.allTimeRevenue;
      }

    }
  } catch (err) {
    console.error("Failed to fetch dashboard data:", err)
  }
}

watch(revenueOverTime, (newData) => {
  if (newData && newData.length > 0) {
    renderRevenueChart(newData);
  }
});

onMounted(() => {
  fetchDashboardData()
});
</script>

<style scoped>
h1, h2 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.2rem; margin-bottom: 0.5rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.5rem; margin-bottom: 1.5rem; padding-bottom: 1rem; }
p { color: #cccccc; line-height: 1.6; margin: 0.25rem 0; }
label { display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.5rem; }

.dashboard-container { color: #ffffff; }
.dashboard-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.page-header { margin-bottom: 3rem; text-align: left; }

.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin-bottom: 2rem; padding: 2rem; }

/* KPI Grid Styles */
.kpi-grid { display: grid; gap: 2rem; grid-template-columns: 1fr 1fr; margin-bottom: 2rem; }
.kpi-card { margin-bottom: 0; padding: 1.5rem 2rem; }
.kpi-card label { color: #aaa; font-size: 1rem; margin-bottom: 0.5rem; text-transform: capitalize; }
.kpi-card .value { color: #ffffff; display: block; font-size: 2.2rem; font-weight: 600; }

/* Chart Styles */
.chart-card { min-height: 400px; }
.chart-subtitle { color: #888; margin-bottom: 2rem; margin-top: -1.25rem; }
.chart-container { height: 300px; position: relative; }

/* Grid layout for lists */
.activity-grid { display: grid; gap: 2rem; grid-template-columns: 1fr 1fr; }

/* Product List Styles */
.product-list { display: flex; flex-direction: column; gap: 1.5rem; list-style: none; margin: 0; max-height: 500px; overflow-y: auto; padding: 0; }
.product-list li { align-items: center; display: flex; gap: 1rem; }
.list-img { background-color: #333; border: 1px solid #444; border-radius: 8px; flex-shrink: 0; height: 50px; object-fit: cover; width: 50px; }
.list-details { flex-grow: 1; min-width: 0; }
.list-main { color: #f0f0f0; display: block; font-size: 1rem; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.list-sub { color: #888; font-size: 0.85rem; text-transform: capitalize; }
.list-count { color: #f0f0f0; font-size: 1rem; font-weight: 600; padding-left: 1rem; text-align: right; white-space: nowrap; }

@media (max-width: 900px) {
  .activity-grid { grid-template-columns: 1fr; }
}
@media (max-width: 768px) {
  .kpi-grid { grid-template-columns: 1fr; }
}
</style>
