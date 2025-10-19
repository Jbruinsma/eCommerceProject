<template>
  <div class="listings-container">
    <nav class="navbar">
    </nav>

    <header class="page-header">
      <a href="/" class="logo">NAME</a>
      <div class="nav-icons">
        <svg @click="redirectToProfile" @keydown.enter.prevent="redirectToProfile" @keydown.space.prevent="redirectToProfile" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="account-icon" role="button" tabindex="0" aria-label="Account"> <path stroke-linecap="round" stroke-linejoin="round" d="M17.982 18.725A7.488 7.488 0 0 0 12 15.75a7.488 7.488 0 0 0-5.982 2.975m11.963 0a9 9 0 1 0-11.963 0m11.963 0A8.966 8.966 0 0 1 12 21a8.966 8.966 0 0 1-5.982-2.275M15 9.75a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" /> </svg>
        <svg @click="redirectToCart" @keydown.enter.prevent="redirectToCart" @keydown.space.prevent="redirectToCart" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="cart-icon" role="button" tabindex="0" aria-label="Cart"> <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 3h1.386c.51 0 .955.343 1.087.835l.383 1.437M7.5 14.25a3 3 0 0 0-3 3h15.75m-12.75-3h11.218c1.121-2.3 2.1-4.684 2.924-7.138a60.114 60.114 0 0 0-16.536-1.84M7.5 14.25 5.106 5.272M6 20.25a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Zm12.75 0a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" /> </svg>
      </div>
    </header>

    <main class="listings-content">
      <div class="listings-header">
        <h2>My Listings</h2>
        <button type="button" @click="redirectToCreateListing" class="btn btn-primary create-btn" aria-label="Create Listing">Create Listing</button>
      </div>
      <div v-if="listings.length === 0" class="no-listings">
        <p>You have no active listings. Sell an item to get started!</p>
      </div>
      <div v-else class="listings-grid">
        <router-link
          v-for="listing in listings"
          :key="listing.listing_id"
          :to="{ name: 'listing', params: { id: listing.listing_id } }"
          class="listing-card"
        >
          <div class="card-image-container">
            <img :src="listing.product.image_url" :alt="listing.product.name">
          </div>
          <div class="card-details">
            <div class="card-header">
              <span class="status-badge" :class="`status-${listing.status}`">{{ listing.status }}</span>
              <p class="listing-date">Listed on {{ formatDate(listing.created_at) }}</p>
            </div>
            <h3 class="product-name">{{ listing.product.brand.brand_name }} {{ listing.product.name }}</h3>
            <div class="product-info">
              <span>Size: {{ listing.size.size_value }}</span>
              <span>Condition: {{ listing.item_condition }}</span>
            </div>
            <p class="listing-price">Asking Price: {{ formatCurrency(listing.price) }}</p>
            <div v-if="listing.status === 'active'" class="card-actions">
              <button @click.prevent class="btn btn-secondary">Edit Price</button>
              <button @click.prevent class="btn btn-danger">Cancel Listing</button>
            </div>
          </div>
        </router-link>
      </div>
    </main>

    <footer class="site-footer">
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'

const listings = ref([
  {
    listing_id: 501,
    price: '310.00',
    item_condition: 'new',
    status: 'active',
    created_at: '2025-10-15T11:30:00Z',
    product: {
      name: 'Retro Dunk "Obsidian"',
      image_url: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+3',
      brand: { brand_name: 'Athletic Co.' }
    },
    size: { size_value: '10.5' }
  },
  {
    listing_id: 502,
    price: '250.00',
    item_condition: 'new',
    status: 'active',
    created_at: '2025-10-12T09:00:00Z',
    product: {
      name: 'Air Runner "Graphite"',
      image_url: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+1',
      brand: { brand_name: 'Athletic Co.' }
    },
    size: { size_value: '11' }
  },
  {
    listing_id: 503,
    price: '120.00',
    item_condition: 'used',
    status: 'sold',
    created_at: '2025-09-28T18:20:00Z',
    product: {
      name: 'Streetwise Hoodie "Carbon"',
      image_url: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Hoodie',
      brand: { brand_name: 'Streetwear Co.' }
    },
    size: { size_value: 'Large' }
  },
  {
    listing_id: 504,
    price: '190.00',
    item_condition: 'new',
    status: 'canceled',
    created_at: '2025-09-15T14:45:00Z',
    product: {
      name: 'Vapor Max "Midnight"',
      image_url: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+4',
      brand: { brand_name: 'Athletic Co.' }
    },
    size: { size_value: '9.5' }
  },
]);

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
};

const formatDate = (dateString) => {
  const options = { year: 'numeric', month: 'short', day: 'numeric' };
  return new Date(dateString).toLocaleDateString('en-US', options);
};

// Header icon handlers
const authStore = useAuthStore()
function redirectToProfile() { if (authStore.isLoggedIn) { router.push('/profile') } else { router.push('/login') } }
function redirectToCart() { router.push('/cart') }
// Navigate to the create listing page. Assumption: route path is '/create-listing'.
function redirectToCreateListing() { router.push('/create-listing') }
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
h2 { font-size: 1.8rem; margin: 0; text-align: left; }
h3 { font-size: 1.2rem; margin: 0.5rem 0; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.nav-icons { align-items: center; display: flex; gap: 1.5rem; }
.account-icon, .cart-icon { cursor: pointer; height: 28px; width: 28px; }
.listings-container { color: #ffffff; font-family: Spectral, sans-serif; }
.listings-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.listings-header { align-items: center; display: flex; justify-content: space-between; margin-bottom: 2rem; border-bottom: 1px solid #333; padding-bottom: 1rem; }
.btn-primary { background-color: #ffffff; color: #121212; border-color: transparent; }
.btn-primary:hover { background-color: #cccccc; color: #121212; }
.create-btn { /* keep a compact visual gap on desktop */ margin-left: 1rem; }
.listings-grid { display: grid; gap: 2rem; grid-template-columns: 1fr; }
.listing-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; color: #ffffff; display: flex; gap: 1.5rem; overflow: hidden; padding: 1.5rem; transition: border-color 0.3s ease; }
.listing-card:hover { border-color: #444; }
.card-image-container { align-items: center; background-color: #121212; border-radius: 8px; display: flex; flex-shrink: 0; height: 160px; justify-content: center; overflow: hidden; width: 160px; }
.card-image-container img { height: 100%; object-fit: cover; width: 100%; }
.card-details { display: flex; flex-direction: column; width: 100%; }
.card-header { align-items: center; display: flex; justify-content: space-between; }
.listing-date { color: #888; font-size: 0.8rem; margin: 0; }
.product-info { align-items: center; color: #ccc; display: flex; font-size: 0.9rem; gap: 1.5rem; margin-bottom: 1rem; }
.product-info span { background-color: #2c2c2c; border-radius: 6px; padding: 0.25rem 0.6rem; }
.listing-price { font-size: 1.4rem; font-weight: bold; margin-top: auto; }
.card-actions { align-self: flex-end; display: flex; gap: 1rem; margin-top: auto; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.btn-secondary:hover { background-color: #383838; border-color: #666; }
.btn-danger { background-color: transparent; border-color: #f06e6e; color: #f06e6e; }
.btn-danger:hover { background-color: #4a1a1a; color: #ffffff; }
.no-listings { background-color: #1a1a1a; border: 1px dashed #333; border-radius: 12px; color: #888; padding: 3rem; text-align: center; }
/* Status Badge Styles */
.status-badge { border-radius: 12px; font-size: 0.8rem; font-weight: bold; padding: 0.3rem 0.8rem; text-transform: capitalize; }
.status-active { background-color: #1a4a32; color: #6ef0a3; }
.status-sold { background-color: #2c2c2c; color: #aaaaaa; }
.status-canceled { background-color: #4a1a1a; color: #f06e6e; }

@media (max-width: 640px) {
  .listings-header { flex-direction: column; align-items: flex-start; gap: 0.75rem; }
  .create-btn { width: 100%; display: inline-flex; justify-content: center; }
}
</style>
