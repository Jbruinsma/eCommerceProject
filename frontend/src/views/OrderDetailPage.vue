<template>
  <div class="order-detail-container">
    <main class="order-content">
      <div class="order-header">
        <div class="header-info">
          <h1>Order #{{ order.order_id }}</h1>
          <p>Placed on {{ formatDate(order.created_at) }}</p>
        </div>
        <div class="header-status">
          <span class="status-badge" :class="`status-${order.order_status}`">{{ order.order_status }}</span>
        </div>
      </div>

      <div class="order-grid">
        <div class="product-summary">
          <div class="product-image">
            <img :src="order.product.image_url" :alt="order.product.name">
          </div>
          <div class="product-details">
            <h3>{{ order.product.brand.brand_name }} {{ order.product.name }}</h3>
            <p><span>Size:</span> {{ order.size.size_value }}</p>
            <p><span>Condition:</span> New</p>
            <p v-if="order.tracking_number"><span>Tracking:</span> <a href="#">{{ order.tracking_number }}</a></p>
          </div>
        </div>

        <div class="order-sidebar">
          <div class="info-section">
            <h3>Pricing Summary</h3>
            <ul>
              <li><span>Sale Price</span><span>{{ formatCurrency(order.sale_price) }}</span></li>
              <li><span>Transaction Fee</span><span>{{ formatCurrency(order.transaction_fee) }}</span></li>
              <li class="total"><span>Total Price</span><span>{{ formatCurrency(order.total_price) }}</span></li>
            </ul>
          </div>

          <div class="info-section">
            <h3>Shipping Address</h3>
            <address>
              {{ order.shipping_address.name }}<br>
              {{ order.shipping_address.address_line_1 }}<br>
              <template v-if="order.shipping_address.address_line_2">
                {{ order.shipping_address.address_line_2 }}<br>
              </template>
              {{ order.shipping_address.city }}, {{ order.shipping_address.state }} {{ order.shipping_address.zip_code }}<br>
              {{ order.shipping_address.country }}
            </address>
          </div>

          <div class="info-section">
            <h3>Payment Information</h3>
            <p><strong>Method:</strong> {{ order.payment_info.method }}</p>
            <p><strong>Transaction ID:</strong> #{{ order.payment_info.transaction_id }}</p>
          </div>
        </div>
      </div>
    </main>

    <footer class="site-footer">
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue';

// Mock data simulating a detailed query for a single order
const order = ref({
  order_id: 721,
  sale_price: '310.00',
  transaction_fee: '15.50',
  total_price: '325.50',
  order_status: 'shipped',
  created_at: '2025-10-15T10:30:00Z',
  tracking_number: '1Z999AA10123456784',
  product: {
    name: 'Retro Dunk "Obsidian"',
    image_url: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+3',
    brand: { brand_name: 'Athletic Co.' }
  },
  size: { size_value: '10.5' },
  shipping_address: {
    name: 'Alex Miller',
    address_line_1: '123 Market St',
    address_line_2: 'Apt 4B',
    city: 'Brooklyn',
    state: 'NY',
    zip_code: '11201',
    country: 'United States'
  },
  payment_info: {
    method: 'Visa ending in 4242',
    transaction_id: 1054
  }
});

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
};

const formatDate = (dateString) => {
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  return new Date(dateString).toLocaleDateString('en-US', options);
};
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
a:hover { text-decoration: underline; }
h1 { font-size: 2.2rem; margin: 0; }
h3 { border-bottom: 1px solid #333; font-size: 1.2rem; margin-bottom: 1rem; padding-bottom: 1rem; }
ul { list-style: none; padding: 0; }
address { font-style: normal; line-height: 1.6; }
.order-detail-container { color: #ffffff; font-family: Spectral, sans-serif; }
.order-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.order-header { align-items: flex-start; border-bottom: 1px solid #333; display: flex; justify-content: space-between; margin-bottom: 2.5rem; padding-bottom: 1.5rem; }
.order-header p { color: #888; margin: 0.25rem 0 0; }
.order-grid { display: grid; gap: 3rem; grid-template-columns: 2fr 1fr; }
.product-summary { align-items: center; background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; display: flex; gap: 1.5rem; padding: 1.5rem; }
.product-image { flex-shrink: 0; height: 120px; width: 120px; }
.product-image img { border-radius: 8px; height: 100%; object-fit: cover; width: 100%; }
.product-details h3 { border: none; font-size: 1.4rem; padding: 0; }
.product-details p { color: #ccc; margin: 0.5rem 0; }
.product-details p span { color: #888; font-weight: bold; }
.order-sidebar { display: flex; flex-direction: column; gap: 2rem; }
.info-section { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 1.5rem; }
.info-section li, .info-section p { align-items: center; color: #ccc; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.info-section li.total { font-size: 1.1rem; font-weight: bold; margin-top: 1rem; }
.info-section li.total span { color: #ffffff; }
/* Status Badge Styles */
.status-badge { border-radius: 12px; font-size: 0.9rem; font-weight: bold; padding: 0.4rem 1rem; text-transform: capitalize; }
.status-shipped { background-color: #1a414a; color: #6ee3f0; }
.status-completed { background-color: #1a4a32; color: #6ef0a3; }
.status-pending { background-color: #4a411a; color: #f0d56e; }
.status-cancelled { background-color: #4a1a1a; color: #f06e6e; }
</style>
