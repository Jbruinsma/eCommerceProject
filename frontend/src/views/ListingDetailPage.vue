<template>
  <div class="listing-detail-container">
    <nav class="page-header">
      <a href="/" class="logo">NAME</a>
      <div class="nav-icons">
        <svg
          @click="redirectToProfile"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="account-icon"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
          />
        </svg>

        <svg
          @click="redirectToCart"
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="cart-icon"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z"
          />
        </svg>
      </div>
    </nav>

    <main v-if="listing" class="listing-content">
      <div class="listing-grid">
        <div class="product-summary">
          <div class="product-image">
            <img :src="listing.product.image_url" :alt="listing.product.name" />
          </div>
          <div class="product-details">
            <h1>{{ listing.product.name }}</h1>
            <div class="product-info-tags">
              <span>Size: {{ listing.size.size_value }}</span>
              <span>Condition: {{ listing.item_condition }}</span>
            </div>
          </div>
        </div>

        <div class="listing-sidebar">
          <div class="info-section status-card">
            <div class="status-header">
              <span class="status-badge" :class="`status-${listing.status}`">{{
                  listing.status
                }}</span>
            </div>
            <div class="price-info">
              <p>Asking Price</p>
              <h2>{{ formatCurrency(listing.price) }}</h2>
            </div>
            <div v-if="listing.status === 'active'" class="card-actions">
              <button class="btn btn-secondary">Edit Price</button>
              <button class="btn btn-danger">Cancel Listing</button>
            </div>
          </div>

          <div class="info-section">
            <h3 v-if="listing.status === 'active' || listing.status === 'pending'">Potential Earnings Breakdown</h3>
            <h3 v-else >Earnings Breakdown</h3>
            <ul>
              <li>
                <span>Asking Price</span><span>{{ formatCurrency(listing.price) }}</span>
              </li>
              <li>
                <span>Transaction Fee ({{ formattedTransactionFeeRate }}%)</span
                ><span class="negative">-{{ formatCurrency(transactionFee) }}</span>
              </li>
              <li class="total">
                <span>Seller Payout</span><span>{{ formatCurrency(sellerPayout) }}</span>
              </li>
            </ul>
          </div>

          <div class="info-section">
            <h3>Listing History</h3>
            <ul>
              <li>
                <span>Listed On</span><span>{{ formatDate(listing.created_at) }}</span>
              </li>
              <li v-if="listing.status === 'sold'">
                <span>Sold On</span><span>{{ formatDate(listing.sold_at) }}</span>
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
import router from '@/router/index.js'
import { fetchFromAPI } from '@/utils/index.js'
import { useAuthStore } from '@/stores/authStore.js'

const listing = ref(null);
const authStore = useAuthStore();
const route = useRoute();
const listingId = route.params.listingId;

onMounted(async () => {
  if (!listingId) {
    await router.push('/listings');
    return;
  }
  if (!authStore.isLoggedIn){
    await router.push('/login');
    return;
  }

  try {
    const response = await fetchFromAPI(`/listings/${authStore.uuid}/${listingId}`);

    if (response) {
      listing.value = {
        listing_id: response.listing_id,
        price: response.price,
        item_condition: response.item_condition,
        status: response.status,
        created_at: response.created_at,
        sold_at: response.sold_at,
        product: {
          name: response.product_name,
          image_url: response.product_image_url,
        },
        size: {
          size_value: response.size_value,
        },
      };
    } else {
      await router.push('/listings');
    }
  } catch (error) {
    console.error("Failed to fetch listing details:", error);
    await router.push('/listings');
  }
});

const transactionFeeRate = 0.065;

const formattedTransactionFeeRate = computed(() => {
  return (transactionFeeRate * 100).toFixed(1);
});

const transactionFee = computed(() => {
  return listing.value ? parseFloat(listing.value.price) * transactionFeeRate : 0;
});

const sellerPayout = computed(() => {
  return listing.value ? parseFloat(listing.value.price) - transactionFee.value : 0;
});

const formatCurrency = (amount) => {
  if (amount == null) return '';
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  return new Date(dateString).toLocaleDateString('en-US', options);
};

// Add redirect functions for the nav icons
function redirectToProfile() {
  if (authStore.isLoggedIn) { router.push('/profile') }
  else { router.push('/login') }
}

function redirectToCart() {
  router.push('/cart')
}
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
h1 { font-size: 2.2rem; margin: 0.25rem 0 1rem 0; }
h3 { font-size: 1.2rem; }
ul { list-style: none; padding: 0; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.nav-icons { align-items: center; display: flex; gap: 1.5rem; }
.account-icon, .cart-icon { cursor: pointer; height: 28px; width: 28px; }
.listing-detail-container { color: #ffffff; font-family: Spectral, sans-serif; }
.listing-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.listing-grid { display: grid; gap: 3rem; grid-template-columns: 2fr 1fr; }
.product-summary .product-image { background-color: #1a1a1a; border-radius: 12px; margin-bottom: 2rem; padding: 2rem; }
.product-summary .product-image img { max-width: 100%; }
.product-details h3 { color: #aaa; margin: 0; }
.product-info-tags { display: flex; gap: 1rem; margin-top: 1.5rem; }
.product-info-tags span { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 6px; padding: 0.4rem 0.8rem; }
.listing-sidebar { display: flex; flex-direction: column; gap: 2rem; }
.info-section { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 1.5rem; }
.info-section h3 { border-bottom: 1px solid #333; margin-bottom: 1rem; padding-bottom: 1rem; }
.info-section li { align-items: center; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.info-section li span:first-child { color: #aaa; }
.info-section li span.negative { color: #f06e6e; }
.info-section li.total { font-size: 1.1rem; font-weight: bold; margin-top: 1rem; }
.info-section li.total span { color: #ffffff; }
.status-card { text-align: center; }
.status-card .price-info p { color: #aaa; margin: 1rem 0 0.5rem; }
.status-card .price-info h2 { font-size: 2.5rem; margin: 0; }
.card-actions { display: grid; gap: 1rem; grid-template-columns: 1fr 1fr; margin-top: 1.5rem; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem; transition: all 0.3s ease; width: 100%; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.btn-secondary:hover { background-color: #383838; border-color: #666; }
.btn-danger { background-color: transparent; border-color: #f06e6e; color: #f06e6e; }
.btn-danger:hover { background-color: #4a1a1a; color: #ffffff; }
.status-badge { border-radius: 12px; display: inline-block; font-size: 0.9rem; font-weight: bold; padding: 0.4rem 1rem; text-transform: capitalize; }
.status-active { background-color: #1a4a32; color: #6ef0a3; }
.status-sold { background-color: #2c2c2c; color: #aaaaaa; }
.status-canceled { background-color: #4a1a1a; color: #f06e6e; }
@media (max-width: 900px) {
  .listing-grid { grid-template-columns: 1fr; }
}
</style>
