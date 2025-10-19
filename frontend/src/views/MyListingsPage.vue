<template>
  <div class="listings-container">
    <main class="listings-content">
      <div class="listings-header">
        <h2>My Listings</h2>
        <button
          type="button"
          @click="redirectToCreateListing"
          class="btn btn-primary create-btn"
          aria-label="Create Listing"
        >
          Create Listing
        </button>
      </div>
      <div v-if="listings.length === 0" class="no-listings">
        <p>You have no active listings. Sell an item to get started!</p>
      </div>
      <div v-else class="listings-grid">
        <router-link
          v-for="listing in listings"
          :key="listing.listing_id"
          :to="{ name: 'listing', params: { listingId: listing.listing_id } }"
          class="listing-card"
        >
          <div class="card-image-container">
            <img :src="listing.product.image_url" :alt="listing.product.name" />
          </div>
          <div class="card-details">
            <div class="card-header">
              <span class="status-badge" :class="`status-${listing.status}`">{{
                  listing.status
                }}</span>
              <p class="listing-date">Listed on {{ formatDate(listing.created_at) }}</p>
            </div>
            <h3 class="product-name">{{ listing.product.name }}</h3>
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

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import { fetchFromAPI } from '@/utils/index.js'

const listings = ref([])
const authStore = useAuthStore()

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  try {
    const apiResponse = await fetchFromAPI(`/listings/${authStore.uuid}`)
    const formattedListings = (apiResponse || []).map(item => {
      return {
        listing_id: item.listing_id,
        price: item.price,
        item_condition: item.item_condition,
        status: item.status,
        created_at: item.created_at,
        product: {
          name: item.product_name,
          image_url: item.product_image_url
        },
        size: {
          size_value: item.size_value
        }
      };
    });
    listings.value = formattedListings;
  } catch (error) {
    console.error('Error fetching listings:', error)
  }
})

const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
}

const formatDate = (dateString) => {
  const options = { year: 'numeric', month: 'short', day: 'numeric' }
  return new Date(dateString).toLocaleDateString('en-US', options)
}

function redirectToCreateListing() {
  router.push('/create-listing')
}
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
h2 { font-size: 1.8rem; margin: 0; text-align: left; }
h3 { font-size: 1.2rem; margin: 0.5rem 0; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.listings-container { color: #ffffff; font-family: Spectral, sans-serif; }
.listings-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.listings-header { align-items: center; border-bottom: 1px solid #333; display: flex; justify-content: space-between; margin-bottom: 2rem; padding-bottom: 1rem; }
.btn-primary { background-color: #ffffff; border-color: transparent; color: #121212; }
.btn-primary:hover { background-color: #cccccc; color: #121212; }
.create-btn { margin-left: 1rem; }
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
.status-badge { border-radius: 12px; font-size: 0.8rem; font-weight: bold; padding: 0.3rem 0.8rem; text-transform: capitalize; }
.status-active { background-color: #1a4a32; color: #6ef0a3; }
.status-sold { background-color: #2c2c2c; color: #aaaaaa; }
.status-canceled { background-color: #4a1a1a; color: #f06e6e; }

@media (max-width: 640px) {
  .listings-header { align-items: flex-start; flex-direction: column; gap: 0.75rem; }
  .create-btn { display: inline-flex; justify-content: center; width: 100%; }
}
</style>
