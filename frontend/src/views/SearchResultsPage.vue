<template>
  <div class="marketplace-container">
    <header class="page-header">
<!--      <h1>Search</h1>-->
      <div class="search-bar">
        <input v-model="searchQuery" type="text" placeholder="Search for items, brands, etc." />
        <button>Search</button>
      </div>
    </header>

    <div class="main-content">
      <aside class="filters-sidebar">
        <h2>Filters</h2>

        <div
            v-if="filterOptions.categories && filterOptions.categories.length"
            class="filter-group"
        >
          <h3>Category</h3>
          <ul class="filter-options">
            <li v-for="category in filterOptions.categories" :key="category">
              <label>
                <input
                    type="checkbox"
                    :value="category"
                    @change="applyFilter('category', category)"
                />
                {{ category }}
              </label>
            </li>
          </ul>
        </div>

        <div v-if="filterOptions.brands && filterOptions.brands.length" class="filter-group">
          <h3>Brand</h3>
          <ul class="filter-options">
            <li v-for="brand in filterOptions.brands" :key="brand">
              <label>
                <input type="checkbox" :value="brand" @change="applyFilter('brand', brand)" />
                {{ brand }}
              </label>
            </li>
          </ul>
        </div>

        <div class="filter-group">
          <h3>Price Range</h3>
          <div class="price-inputs">
            <input
                type="number"
                placeholder="Min"
                v-model="minPrice"
                @change="applyPriceFilter"
            />
            <span>–</span>
            <input
                type="number"
                placeholder="Max"
                v-model="maxPrice"
                @change="applyPriceFilter"
            />
          </div>
        </div>
      </aside>

      <main class="results-container">
        <div class="results-header">
          <p>{{ searchResults.length }} Results</p>
          <select v-model="sortOption" class="sort-dropdown">
            <option value="newest">Sort by: Newest</option>
            <option value="price-asc">Sort by: Price (Low to High)</option>
            <option value="price-desc">Sort by: Price (High to Low)</option>
          </select>
        </div>

        <div v-if="searchResults.length > 0" class="product-grid">
          <ProductCard
            v-for="product in searchResults"
            :key="product.productId"
            :productId="product.productId"
            :imageUrl="product.imageUrl"
            :name="product.name"
            :price="product.lowestAskingPrice"
            :brandName="product.brandName"
          />
        </div>

        <div v-else class="no-results">
          <h2>No Results Found</h2>
          <p>Try adjusting your search or filters to find what you're looking for.</p>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { fetchFromAPI } from '@/utils/index.js'
import ProductCard from '@/components/ProductCard.vue'

const searchQuery = ref('')
const searchResults = ref([])
const searchResultStorage = ref([])
const filterOptions = ref({})
const route = useRoute()

const minPrice = ref(null)
const maxPrice = ref(null)

const sortOption = ref('newest')

const activeFilters = ref({
  category: [],
  brand: [],
  price: {
    min: null,
    max: null,
  },
})

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

watch(activeFilters, () => {
  const categoryFilters = activeFilters.value.category;
  const brandFilters = activeFilters.value.brand;
  const minPrice = activeFilters.value.price.min;
  const maxPrice = activeFilters.value.price.max;

  let filteredResults = searchResultStorage.value;

  if (categoryFilters.length > 0) {
    filteredResults = filteredResults.filter(product =>
        categoryFilters.includes(product.productType)
    );
  }

  if (brandFilters.length > 0) {
    filteredResults = filteredResults.filter(product =>
        brandFilters.includes(product.brandName)
    );
  }

  if (minPrice !== null) {
    filteredResults = filteredResults.filter(product =>
        product.lowestAskingPrice !== null && product.lowestAskingPrice >= minPrice
    );
  }

  if (maxPrice !== null) {
    filteredResults = filteredResults.filter(product =>
        product.lowestAskingPrice !== null && product.lowestAskingPrice <= maxPrice
    );
  }

  searchResults.value = filteredResults
  sortResultsByPrice(sortOption.value)

}, { deep: true });

watch(sortOption, (newValue) => {
  if (['newest', 'price-asc', 'price-desc'].includes(newValue)) {
    sortResultsByPrice(newValue)
  } else {
    console.error('Invalid sort option:', newValue)
  }
})

function sortResultsByPrice(filterValue) {
  if (filterValue === 'newest') {
    sortResultsByNewest()
  } else if (filterValue === 'price-asc') {
    sortResultsLowToHigh()
  } else if (filterValue === 'price-desc') {
    sortResultsHighToLow()
  } else {
    console.error('Invalid sort option:', filterValue)
  }
}

function sortResultsByNewest() {
  searchResults.value.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
}

function sortResultsLowToHigh() {
  console.log("sorting low to high")
  searchResults.value.sort()
}

function sortResultsHighToLow() {
  console.log("sorting high to low")
}

function applyFilter(filterType, filterValue) {
  if (['category', 'brand'].includes(filterType)) {
    if (activeFilters.value[filterType].includes(filterValue)) {
      activeFilters.value[filterType] = activeFilters.value[filterType].filter(
          (v) => v !== filterValue,
      )
    } else {
      activeFilters.value[filterType].push(filterValue)
    }
  } else if (filterType === 'price') {
    activeFilters.value.price = {
      min: filterValue.min || null,
      max: filterValue.max || null,
    }
  }
}

function applyPriceFilter() {
  if (minPrice.value < 0) return
  if (maxPrice.value < 0) return
  if (maxPrice.value && minPrice.value && maxPrice.value < minPrice.value) return

  applyFilter('price', {
    min: minPrice.value,
    max: maxPrice.value,
  })
}

async function searchProducts(searchQuery = null, category = null) {
  const params = new URLSearchParams()

  if (searchQuery) {
    params.append('q', searchQuery)
  }
  if (category) {
    params.append('category', category)
  }

  const queryString = params.toString()

  try {
    const endpoint = queryString ? `/search/?${queryString}` : '/search/'
    const response = await fetchFromAPI(endpoint)

    searchResults.value = response.products || []
    searchResultStorage.value = response.products || []
    filterOptions.value = response.filters || {}

    route.query.q = queryString

  } catch (error) {
    console.error('Error fetching search results:', error)
    searchResults.value = []
    searchResultStorage.value = []
    filterOptions.value = {}
  }
}

</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Abel&family=Bodoni+Moda+SC:ital,opsz,wght@0,6..96,400..900;1,6..96,400..900&family=Inclusive+Sans&family=Inconsolata:wght@200;300;400;500;600&family=Manrope:wght@600;700;800&family=Mulish:ital,wght@0,300;0,400;0,700;1,200;1,400;1,600&family=Nanum+Myeongjo&family=Quicksand:wght@300..700&family=Scope+One&family=Sono:wght@200;300;400&family=Spectral:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;0,800;1,200;1,300;1,400;1,500;1,600;1,700;1,800&family=Zeyada&display=swap');

a { color: #ffffff; text-decoration: none; }
h1 { font-family: Bodoni Moda, BlinkMacSystemFont, serif; font-size: 2.8rem; font-weight: 600; margin-bottom: 2rem; text-align: center; }
h2 { border-bottom: 1px solid #333; font-family: Spectral, sans-serif; font-size: 1.8rem; font-weight: 600; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { font-family: Spectral, sans-serif; font-size: 1.1rem; font-weight: 600; margin-bottom: 1rem; }
p { color: #cccccc; line-height: 1.6; }
ul { list-style: none; margin: 0; padding: 0; }
.filter-group { margin-bottom: 2rem; }
.filter-options input[type='checkbox'] { -moz-appearance: none; -webkit-appearance: none; appearance: none; background-color: #1a1a1a; border: 1px solid #555; border-radius: 3px; cursor: pointer; height: 16px; margin-right: 0.75rem; position: relative; transition: background-color 0.2s, border-color 0.2s; vertical-align: middle; width: 16px; }
.filter-options input[type='checkbox']:checked { background-color: #ffffff; border-color: #ffffff; transition: background-color 0.2s, border-color 0.2s; }
.filter-options label { align-items: center; color: #cccccc; cursor: pointer; display: flex; margin-bottom: 0.75rem; }
.filter-options label:hover { color: #ffffff; }
.filters-sidebar { border-right: 1px solid #2a2a2a; flex: 0 0 260px; padding-right: 2rem; }
.main-content { display: flex; gap: 1rem; padding: 0 5%; }
.marketplace-container { color: #ffffff; padding: 4rem 0; }
.no-results { color: #888; padding: 4rem 2rem; text-align: center; }
.no-results h2 { border-bottom: none; font-size: 1.8rem; margin-bottom: 1rem; }
.no-results p { font-size: 1.1rem; margin: 0 auto; max-width: 400px; }
.page-header { margin: 0 auto; max-width: 1200px; padding: 0 5% 4rem; }
.price-inputs { align-items: center; display: flex; gap: 0.5rem; }
.price-inputs input { background-color: #1a1a1a; border: 1px solid #555; border-radius: 4px; color: #ffffff; padding: 0.5rem; width: 100%; }
.price-inputs input::placeholder { color: #777; opacity: 1; }
.price-inputs span { color: #888; }
.product-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, 250px); justify-content: start; }
.results-container { flex: 1; }
.results-header { align-items: center; display: flex; justify-content: space-between; margin-bottom: 2rem; }
.results-header p { color: #888; margin: 0; }
.search-bar { display: flex; margin: 0 auto; max-width: 700px; }
.search-bar button { background-color: #ffffff; border: 1px solid #ffffff; border-bottom-right-radius: 6px; border-top-right-radius: 6px; color: #121212; cursor: pointer; font-size: 1rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: background-color 0.3s, color 0.3s; }
.search-bar button:hover { background-color: #121212; color: #ffffff; }
.search-bar input { background-color: #1a1a1a; border: 1px solid #555; border-bottom-left-radius: 6px; border-right: none; border-top-left-radius: 6px; color: #ffffff; flex-grow: 1; font-size: 1rem; padding: 0.75rem 1rem; }
.sort-dropdown { background-color: #1a1a1a; border: 1px solid #555; border-radius: 4px; color: #ffffff; padding: 0.5rem; }
</style>
