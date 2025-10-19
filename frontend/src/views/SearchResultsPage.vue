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

        <div class="filter-group">
          <h3>Category</h3>
          <ul class="filter-options">
            <li v-for="category in filterOptions.categories" :key="category">
              <label>
                <input type="checkbox" :value="category" />
                {{ category }}
              </label>
            </li>
          </ul>
        </div>

        <div class="filter-group">
          <h3>Brand</h3>
          <ul class="filter-options">
            <li v-for="brand in filterOptions.brands" :key="brand">
              <label>
                <input type="checkbox" :value="brand" />
                {{ brand }}
              </label>
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

        <div class="product-grid">
          <a v-for="product in searchResults" :key="product.id" href="#" class="product-card">
            <img :src="product.imageUrl" :alt="product.name" class="product-image" />
            <h3>{{ product.name }}</h3>
            <p class="product-brand">{{ product.brand }}</p>
            <p class="product-price">${{ product.price }}</p>
          </a>
        </div>

        <nav class="pagination">
          <a href="#" class="page-link prev">‹ Prev</a>
          <a href="#" class="page-link active">1</a>
          <a href="#" class="page-link">2</a>
          <a href="#" class="page-link">3</a>
          <span class="page-link-ellipsis">...</span>
          <a href="#" class="page-link">10</a>
          <a href="#" class="page-link next">Next ›</a>
        </nav>
      </main>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'

const searchQuery = ref('')

const searchResults = ref([
  {
    id: 1,
    name: 'Air Runner "Graphite"',
    brand: 'Brand A',
    price: 250,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+1',
  },
  {
    id: 2,
    name: 'Streetwise Hoodie "Carbon"',
    brand: 'Brand B',
    price: 120,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+2',
  },
  {
    id: 3,
    name: 'Retro Dunk "Obsidian"',
    brand: 'Brand A',
    price: 310,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+3',
  },
  {
    id: 4,
    name: 'Vapor Max "Midnight"',
    brand: 'Brand C',
    price: 190,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+4',
  },
  {
    id: 5,
    name: 'Tech Fleece Jogger',
    brand: 'Brand B',
    price: 95,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+5',
  },
  {
    id: 6,
    name: 'Classic Leather "Chalk"',
    brand: 'Brand D',
    price: 150,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+6',
  },
  {
    id: 7,
    name: 'Utility Cargo Pant',
    brand: 'Brand C',
    price: 130,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+7',
  },
  {
    id: 8,
    name: 'Heritage Beanie "Grey"',
    brand: 'Brand A',
    price: 45,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Item+8',
  },
])

const filterOptions = ref({
  categories: ['Sneakers', 'Apparel', 'Accessories', 'Collectibles'],
  brands: ['Brand A', 'Brand B', 'Brand C', 'Brand D'],
})

const route = useRoute()
const query = route.query

console.log('Query:', query)

onMounted( async () => {
  if (query.q) {
    searchQuery.value = query.q
  }

  

})

// Logic for search, filtering, sorting, and pagination will go here.
</script>

<style scoped>
a {
  color: #ffffff;
  text-decoration: none;
}
h1,
h2,
h3 {
  font-family: Spectral, sans-serif;
  font-weight: 600;
}
h1 {
  font-size: 2.8rem;
  margin-bottom: 2rem;
  text-align: center;
}
h2 {
  border-bottom: 1px solid #333;
  font-size: 1.8rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
}
h3 {
  font-size: 1.1rem;
  margin-bottom: 1rem;
}
p {
  color: #cccccc;
  line-height: 1.6;
}
ul {
  list-style: none;
  margin: 0;
  padding: 0;
}
.apply-filters-btn {
  background-color: #ffffff;
  border: 1px solid #ffffff;
  border-radius: 6px;
  color: #121212;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
  padding: 0.75rem 1rem;
  text-align: center;
  transition:
    background-color 0.3s,
    color 0.3s;
  width: 100%;
}
.apply-filters-btn:hover {
  background-color: transparent;
  color: #ffffff;
}
.filter-group {
  margin-bottom: 2rem;
}
.filter-options input[type='checkbox'] {
  accent-color: #ffffff;
  background-color: #333;
  border: 1px solid #555;
  border-radius: 3px;
  cursor: pointer;
  height: 16px;
  margin-right: 0.75rem;
  vertical-align: middle;
  width: 16px;
}
.filter-options label {
  align-items: center;
  color: #cccccc;
  cursor: pointer;
  display: flex;
  margin-bottom: 0.75rem;
}
.filter-options label:hover {
  color: #ffffff;
}
.filters-sidebar {
  border-right: 1px solid #2a2a2a;
  flex: 0 0 260px;
  padding-right: 2rem;
}
.main-content {
  display: flex;
  gap: 2rem;
  padding: 0 5%;
}
.marketplace-container {
  color: #ffffff;
  padding: 4rem 0;
}
.page-header {
  margin: 0 auto;
  max-width: 1200px;
  padding: 0 5% 4rem;
}
.page-link {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 4px;
  color: #ffffff;
  padding: 0.5rem 1rem;
  transition:
    background-color 0.3s,
    border-color 0.3s;
}
.page-link-ellipsis {
  color: #888;
  padding: 0.5rem 0;
}
.page-link.active,
.page-link:hover {
  background-color: #ffffff;
  border-color: #ffffff;
  color: #121212;
}
.pagination {
  align-items: center;
  display: flex;
  gap: 0.5rem;
  justify-content: center;
  margin-top: 3rem;
}
.price-inputs {
  align-items: center;
  display: flex;
  gap: 0.5rem;
}
.price-inputs input {
  background-color: #1a1a1a;
  border: 1px solid #555;
  border-radius: 4px;
  color: #ffffff;
  padding: 0.5rem;
  width: 100%;
}
.price-inputs span {
  color: #888;
}
.product-brand {
  color: #888;
  font-size: 0.9rem;
  margin: 0.25rem 0;
}
.product-card {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  cursor: pointer;
  display: block;
  padding: 1.5rem;
  text-align: left;
  transition:
    transform 0.3s ease,
    box-shadow 0.3s ease;
}
.product-card:hover {
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4);
  transform: translateY(-5px);
}
.product-grid {
  display: grid;
  gap: 2rem;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
}
.product-image {
  aspect-ratio: 1 / 1;
  margin-bottom: 1rem;
  object-fit: cover;
  width: 100%;
}
.product-price {
  font-size: 1.2rem;
  font-weight: bold;
  margin-top: 0.5rem;
}
.results-container {
  flex: 1;
}
.results-header {
  align-items: center;
  display: flex;
  justify-content: space-between;
  margin-bottom: 2rem;
}
.results-header p {
  color: #888;
  margin: 0;
}
.search-bar {
  display: flex;
  margin: 0 auto;
  max-width: 700px;
}
.search-bar button {
  background-color: #ffffff;
  border: 1px solid #ffffff;
  border-bottom-right-radius: 6px;
  border-top-right-radius: 6px;
  color: #121212;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
  padding: 0.75rem 1.5rem;
  transition:
    background-color 0.3s,
    color 0.3s;
}
.search-bar button:hover {
  background-color: #121212;
  color: #ffffff;
}
.search-bar input {
  background-color: #1a1a1a;
  border: 1px solid #555;
  border-bottom-left-radius: 6px;
  border-right: none;
  border-top-left-radius: 6px;
  color: #ffffff;
  flex-grow: 1;
  font-size: 1rem;
  padding: 0.75rem 1rem;
}
.sort-dropdown {
  background-color: #1a1a1a;
  border: 1px solid #555;
  border-radius: 4px;
  color: #ffffff;
  padding: 0.5rem;
}
</style>
