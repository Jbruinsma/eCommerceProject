<template>
  <div class="marketplace-container">
    <header class="page-header">
      <h1>Marketplace</h1>
      <div class="search-bar">
        <input v-model="searchQuery" type="text" placeholder="Search for items, brands, etc." />
        <button>Search</button>
      </div>
    </header>

    <div class="main-content">
      <aside class="filters-sidebar">
        <h2>Filters</h2>

        <div v-if="filterOptions.categories && filterOptions.categories.length" class="filter-group">
          <h3>Category</h3>
          <ul class="filter-options">
            <li v-for="category in filterOptions.categories" :key="category">
              <label> <input type="checkbox" :value="category" /> {{ category }} </label>
            </li>
          </ul>
        </div>

        <div v-if="filterOptions.brands && filterOptions.brands.length" class="filter-group">
          <h3>Brand</h3>
          <ul class="filter-options">
            <li v-for="brand in filterOptions.brands" :key="brand">
              <label> <input type="checkbox" :value="brand" /> {{ brand }} </label>
            </li>
          </ul>
        </div>

        <div class="filter-group">
          <h3>Price Range</h3>
          <div class="price-inputs">
            <input type="number" placeholder="Min" />
            <span>–</span>
            <input type="number" placeholder="Max" />
          </div>
        </div>

        <button class="apply-filters-btn">Apply Filters</button>
      </aside>

      <main class="results-container">
        <div class="results-header">
          <p>{{ searchResults.length }} Results</p>
          <select class="sort-dropdown">
            <option value="newest">Sort by: Newest</option>
            <option value="price-asc">Sort by: Price (Low to High)</option>
            <option value="price-desc">Sort by: Price (High to Low)</option>
          </select>
        </div>

        <div v-if="searchResults.length > 0" class="product-grid">
          <router-link
            v-for="product in searchResults"
            :key="product.productId"
            :to="{ name: 'ProductDetail', params: { id: product.productId } }"
            class="product-card"
          >
            <img :src="product.imageUrl" :alt="product.name" class="product-image" />
            <h3>{{ product.name }}</h3>
            <p class="product-brand">{{ product.brandName }}</p>
            <p class="product-price">${{ product.retailPrice }}</p>
          </router-link>
        </div>

        <div v-else class="no-results">
          <h2>No Results Found</h2>
          <p>Try adjusting your search or filters to find what you're looking for.</p>
        </div>

        <nav class="pagination" v-if="searchResults.length > 0">
          <a href="#" class="page-link prev">‹ Prev</a>
          <a href="#" class="page-link active">1</a>
          <a href="#" class="page-link">2</a>
          <a href="#" class="page-link">3</a>
          <a href="#" class="page-link next">Next ›</a>
        </nav>
      </main>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { fetchFromAPI } from '@/utils/index.js'

const searchQuery = ref('')
const searchResults = ref([])

const filterOptions = ref({})

const route = useRoute()

onMounted(async () => {
  const categoryQuery = route.query.category || ''
  const currentSearchQuery = route.query.q || ''
  await searchProducts(currentSearchQuery, categoryQuery)
})

watch(searchQuery, async (newQuery) => {
  if (route.query.category) {
    route.query.category = null
  }
  await searchProducts(newQuery)
})

async function searchProducts(searchQuery = null, category = null) {
  const params = new URLSearchParams()

  if (searchQuery) {
    params.append('q', searchQuery)
  }
  if (category) {
    params.append('category', category)
  }

  const queryString = params.toString()

  console.log('SEARCH QUERY: ', queryString)

  try {
    const endpoint = queryString ? `/search/?${queryString}` : '/search/'

    // Fetch the new data structure
    const response = await fetchFromAPI(endpoint)

    // Assign products and filters from the response object
    searchResults.value = response.products || []
    filterOptions.value = response.filters || {}

    // console.log('SEARCH RESULTS: ', searchResults.value)
    // console.log('FILTER OPTIONS: ', filterOptions.value)

  } catch (error) {
    console.error('Error fetching search results:', error)
    searchResults.value = []
    filterOptions.value = {}
  }
}
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
h1, h2, h3 { font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.8rem; margin-bottom: 2rem; text-align: center; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { font-size: 1.1rem; margin-bottom: 1rem; }
p { color: #cccccc; line-height: 1.6; }
ul { list-style: none; margin: 0; padding: 0; }
.apply-filters-btn { background-color: #ffffff; border: 1px solid #ffffff; border-radius: 6px; color: #121212; cursor: pointer; font-size: 1rem; font-weight: bold; padding: 0.75rem 1rem; text-align: center; transition: background-color 0.3s, color 0.3s; width: 100%; }
.apply-filters-btn:hover { background-color: transparent; color: #ffffff; }
.filter-group { margin-bottom: 2rem; }
.filter-options input[type='checkbox'] { accent-color: #ffffff; background-color: #333; border: 1px solid #555; border-radius: 3px; cursor: pointer; height: 16px; margin-right: 0.75rem; vertical-align: middle; width: 16px; }
.filter-options label { align-items: center; color: #cccccc; cursor: pointer; display: flex; margin-bottom: 0.75rem; }
.filter-options label:hover { color: #ffffff; }
.filters-sidebar { border-right: 1px solid #2a2a2a; flex: 0 0 260px; padding-right: 2rem; }
.main-content { display: flex; gap: 2rem; padding: 0 5%; }
.marketplace-container { color: #ffffff; padding: 4rem 0; }
.no-results { color: #888; padding: 4rem 2rem; text-align: center; }
.no-results h2 { border-bottom: none; font-size: 1.8rem; margin-bottom: 1rem; }
.no-results p { font-size: 1.1rem; margin: 0 auto; max-width: 400px; }
.page-header { margin: 0 auto; max-width: 1200px; padding: 0 5% 4rem; }
.page-link { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 4px; color: #ffffff; padding: 0.5rem 1rem; transition: background-color 0.3s, border-color 0.3s; }
.page-link-ellipsis { color: #888; padding: 0.5rem 0; }
.page-link.active, .page-link:hover { background-color: #ffffff; border-color: #ffffff; color: #121212; }
.pagination { align-items: center; display: flex; gap: 0.5rem; justify-content: center; margin-top: 3rem; }
.price-inputs { align-items: center; display: flex; gap: 0.5rem; }
.price-inputs input { background-color: #1a1a1a; border: 1px solid #555; border-radius: 4px; color: #ffffff; padding: 0.5rem; width: 100%; }
.price-inputs span { color: #888; }
.product-brand { color: #888; font-size: 0.9rem; margin: 0.25rem 0; }
.product-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; cursor: pointer; display: block; padding: 1.5rem; text-align: left; transition: box-shadow 0.3s ease, transform 0.3s ease; }
.product-card:hover { box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4); transform: translateY(-5px); }
.product-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, 250px); justify-content: start; }
.product-image { aspect-ratio: 1 / 1; margin-bottom: 1rem; object-fit: cover; width: 100%; }
.product-price { font-size: 1.2rem; font-weight: bold; margin-top: 0.5rem; }
.results-container { flex: 1; }
.results-header { align-items: center; display: flex; justify-content: space-between; margin-bottom: 2rem; }
.results-header p { color: #888; margin: 0; }
.search-bar { display: flex; margin: 0 auto; max-width: 700px; }
.search-bar button { background-color: #ffffff; border: 1px solid #ffffff; border-bottom-right-radius: 6px; border-top-right-radius: 6px; color: #121212; cursor: pointer; font-size: 1rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: background-color 0.3s, color 0.3s; }
.search-bar button:hover { background-color: #121212; color: #ffffff; }
.search-bar input { background-color: #1a1a1a; border: 1px solid #555; border-bottom-left-radius: 6px; border-right: none; border-top-left-radius: 6px; color: #ffffff; flex-grow: 1; font-size: 1rem; padding: 0.75rem 1rem; }
.sort-dropdown { background-color: #1a1a1a; border: 1px solid #555; border-radius: 4px; color: #ffffff; padding: 0.5rem; }
</style>
