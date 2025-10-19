<template>
  <div class="create-listing-container">
    <header class="page-header">
      <a href="/" class="logo">NAME</a>
    </header>

    <main class="create-content">
      <div class="wizard-card">
        <div class="progress-bar">
          <div class="progress" :style="{ width: `${(currentStep - 1) * 25}%` }"></div>
        </div>

        <div class="wizard-header">
          <h2>Create a Listing</h2>
          <p>Step {{ currentStep }} of 5: {{ stepTitle }}</p>
        </div>

        <div v-if="currentStep === 1" class="step-content">
          <div class="selection-grid">
            <button v-for="type in listingTypes" :key="type.value" class="selection-card" :class="{ selected: listingData.listing_type === type.value }" @click="selectListingType(type.value)">
              <span class="card-title">{{ type.label }}</span>
              <span class="card-desc">{{ type.description }}</span>
            </button>
          </div>
        </div>

        <div v-if="currentStep === 2" class="step-content">
          <input type="text" v-model="brandSearchQuery" placeholder="Search for brand..." class="search-input">
          <div class="selection-grid product-results">
            <button v-for="brand in filteredBrands" :key="brand.brand_id" class="selection-card" :class="{ selected: listingData.brand_id === brand.brand_id }" @click="selectBrand(brand.brand_id)">
              <img v-if="brand.brand_logo_url" :src="brand.brand_logo_url" :alt="`${brand.brand_name} Logo`" class="brand-logo">
              <span :class="['card-title', {'with-logo': !brand.brand_logo_url}]">{{ brand.brand_name }}</span>
            </button>
          </div>
        </div>

        <div v-if="currentStep === 3" class="step-content">
          <input type="text" v-model="productSearchQuery" placeholder="Search for product by name..." class="search-input">
          <div class="product-results">
            <div v-if="!listingData.brand_id" class="no-results">Please select a brand first.</div>
            <div v-else-if="filteredProducts.length === 0" class="no-results">No products found.</div>
            <div v-else v-for="product in filteredProducts" :key="product.product_id" class="product-item" :class="{ selected: listingData.product_id === product.product_id }" @click="selectProduct(product)">
              <img :src="product.image_url" :alt="product.name">
              <span>{{ product.name }}</span>
            </div>
          </div>
        </div>

        <div v-if="currentStep === 4" class="step-content">
          <div class="form-group">
            <label>1. Select Condition</label>
            <div class="radio-group">
              <button v-for="condition in conditions" :key="condition" class="radio-btn" :class="{ selected: listingData.item_condition === condition }" @click="listingData.item_condition = condition">{{ condition }}</button>
            </div>
          </div>
          <div class="form-group" v-if="listingData.item_condition">
            <label>2. Select Size</label>
            <div v-if="availableSizesForListing.length > 0" class="radio-group size-group">
              <button v-for="size in availableSizesForListing" :key="size.size_id" class="radio-btn" :class="{ selected: listingData.size_id === size.size_id }" @click="listingData.size_id = size.size_id">{{ size.size_value }}</button>
            </div>
            <div v-else class="no-results">
              <p>No sizes with active bids are available for this item in "{{listingData.item_condition}}" condition. Please go back and create an "Ask" to list this item.</p>
            </div>
          </div>
        </div>

        <div v-if="currentStep === 5" class="step-content review-step">
          <div v-if="listingData.listing_type === 'ask'" class="form-group">
            <label for="price">Your Asking Price</label>
            <input type="number" id="price" v-model.number="listingData.price" placeholder="$0.00" class="price-input">
            <p class="input-note">Minimum asking price is {{ formatCurrency(MINIMUM_PRICE) }}</p>
          </div>
          <div v-else class="form-group locked-price">
            <label>Sale Price (Locked to Highest Bid)</label>
            <div class="price-display">{{ formatCurrency(listingData.price) }}</div>
          </div>
          <div class="earnings-summary">
            <div class="summary-item"><span>Transaction Fee ({{ feePercentage }})</span> <span class="negative">-{{ formatCurrency(transactionFee) }}</span></div>
            <div class="summary-item total"><span>Your Payout</span> <span>{{ formatCurrency(sellerPayout) }}</span></div>
          </div>
          <div class="listing-review">
            <h4>Review Your Listing</h4>
            <p><strong>Item:</strong> {{ selectedProduct.name }}</p>
            <p><strong>Size:</strong> {{ selectedSizeValue }} | <strong>Condition:</strong> {{ listingData.item_condition }}</p>
            <p><strong>Listing Type:</strong> {{ listingData.listing_type }}</p>
            <div class="market-context">
              <p><strong>Retail Price:</strong> {{ formatCurrency(selectedProduct.retail_price) }}</p>
              <p><strong>Highest Bid:</strong> {{ formatCurrency(highestBid) }}</p>
            </div>
          </div>
        </div>

        <div class="wizard-footer">
          <button v-if="currentStep > 1" @click="prevStep" class="btn btn-secondary">Back</button>
          <button v-if="currentStep < 5" @click="nextStep" :disabled="!isStepValid" class="btn btn-primary">Next</button>
          <button v-if="currentStep === 5" @click="submitListing" :disabled="!isStepValid" class="btn btn-primary">Submit Listing</button>
        </div>
      </div>
    </main>
    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { fetchFromAPI } from '@/utils/index.js'

const currentStep = ref(1);
const MINIMUM_PRICE = 1.00;
const listingData = reactive({ listing_type: null, brand_id: null, product_id: null, size_id: null, item_condition: null, price: null });
const transactionFeeRate = ref(0.095);
const brands = ref([]);

onMounted(async () => {
  try {
    const brandsResponse = await fetchFromAPI('/product/brands')
    brands.value = brandsResponse || [];
  } catch (error) {
    console.error("Failed to fetch brands:", error);
  }
});

const listingTypes = [ { value: 'ask', label: 'Ask', description: 'Set a specific price for your item.' }, { value: 'sale', label: 'Sale', description: 'Sell immediately to the highest bidder.' } ];
const allProducts = ref([]);
const marketData = ref({ '3-1-new': { highest_bid: 295 }, '3-3-new': { highest_bid: 300 }, '3-3-used': { highest_bid: 250 } });
const conditions = ['new', 'used', 'worn'];
const productSearchQuery = ref('');
const productsResults = ref([]);
const brandSearchQuery = ref('');

const stepTitle = computed(() => { return ["Select Listing Type", "Select Brand", "Find Your Item", "Add Details", "Set Your Price"][currentStep.value - 1] || ''; });
const filteredBrands = computed(() => { if (!brandSearchQuery.value) return brands.value; return brands.value.filter(b => b.brand_name.toLowerCase().includes(brandSearchQuery.value.toLowerCase())); });
const filteredProducts = computed(() => {
  const query = (productSearchQuery.value || '').toLowerCase();
  const source = (productsResults.value && productsResults.value.length > 0) ? productsResults.value : allProducts.value;
  return source.filter(p => p.name.toLowerCase().includes(query));
});
const selectedProduct = computed(() => {
  const allAvailableProducts = [...allProducts.value, ...productsResults.value];
  return allAvailableProducts.find(p => p.product_id === listingData.product_id);
});
const selectedSizeValue = computed(() => selectedProduct.value?.sizes.find(s => s.size_id === listingData.size_id)?.size_value);
const feePercentage = computed(() => `${(transactionFeeRate.value * 100).toFixed(1)}%`);
const transactionFee = computed(() => (listingData.price || 0) * transactionFeeRate.value);
const sellerPayout = computed(() => (listingData.price || 0) - transactionFee.value);
const highestBid = computed(() => {
  if (!listingData.product_id || !listingData.size_id || !listingData.item_condition) return 0;
  const key = `${listingData.product_id}-${listingData.size_id}-${listingData.item_condition}`;
  return marketData.value[key]?.highest_bid || 0;
});

const availableSizesForListing = computed(() => {
  if (!selectedProduct.value) return [];
  if (listingData.listing_type === 'ask') {
    return selectedProduct.value.sizes;
  }
  if (listingData.listing_type === 'sale') {
    return selectedProduct.value.sizes.filter(size => {
      const key = `${listingData.product_id}-${size.size_id}-${listingData.item_condition}`;
      return marketData.value[key] && marketData.value[key].highest_bid > 0;
    });
  }
  // **THE FIX IS HERE**
  return []; // This guarantees the function always returns a valid array
});

const isStepValid = computed(() => {
  switch (currentStep.value) {
    case 1: return !!listingData.listing_type;
    case 2: return !!listingData.brand_id;
    case 3: return !!listingData.product_id;
    case 4: return !!listingData.size_id && !!listingData.item_condition && (listingData.listing_type === 'ask' || availableSizesForListing.value.length > 0);
    case 5: return listingData.listing_type === 'sale' || listingData.price >= MINIMUM_PRICE;
    default: return false;
  }
});

async function searchForProducts() {
  if (!listingData.brand_id) {
    productsResults.value = [];
    return;
  }
  const chosenBrandId = listingData.brand_id;
  const query = productSearchQuery.value || '';
  try {
    // Note: Updated the endpoint to /search as you mentioned
    const relevantProducts = await fetchFromAPI(`/product/search?brand_id=${chosenBrandId}&product_name=${query}`);
    productsResults.value = Array.isArray(relevantProducts) ? relevantProducts : (relevantProducts?.data || []);
  } catch (err) {
    console.error('Product search failed', err);
    productsResults.value = [];
  }
}

watch(() => listingData.item_condition, () => { listingData.size_id = null; });
watch(() => listingData.size_id, (newSizeId) => { if (listingData.listing_type === 'sale' && newSizeId) { listingData.price = highestBid.value; } });
watch(productSearchQuery, (newQuery) => {
  if (newQuery.length >= 2 || newQuery.length === 0) {
    searchForProducts();
  }
});
watch(() => listingData.brand_id, () => {
  productSearchQuery.value = '';
  listingData.product_id = null;
  productsResults.value = [];
  searchForProducts();
});

function selectListingType(type) { listingData.listing_type = type; listingData.price = null; }
function selectBrand(brandId) { listingData.brand_id = brandId; }
function selectProduct(product) { listingData.product_id = product.product_id; }
function nextStep() { if (isStepValid.value) currentStep.value++; }
function prevStep() { if (currentStep.value > 1) currentStep.value--; }
function submitListing() {
  if (!isStepValid.value) return;
  console.log('Submitting Listing:', JSON.parse(JSON.stringify(listingData)));
  alert('Listing submitted successfully! (Check console for data)');
}
const formatCurrency = (amount) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
</script>

<style scoped>
/* All styles remain unchanged */
.locked-price label { margin-bottom: 0.5rem; }
.price-display { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; font-size: 1.5rem; font-weight: bold; padding: 0.75rem; text-align: center; }
a { color: #ffffff; text-decoration: none; }
h2 { font-size: 1.8rem; margin-bottom: 0.5rem; text-align: left; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.create-listing-container { color: #ffffff; font-family: Spectral, sans-serif; }
.create-content { display: flex; justify-content: center; padding: 4rem 5%; }
.wizard-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; max-width: 800px; overflow: hidden; width: 100%; }
.progress-bar { background-color: #2c2c2c; height: 8px; width: 100%; }
.progress { background-color: #ffffff; height: 100%; transition: width 0.3s ease; }
.wizard-header { padding: 2rem 2rem 1rem; }
.wizard-header p { color: #888; margin: 0; }
.step-content { min-height: 300px; padding: 1rem 2rem; }
.selection-grid { display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
.selection-card { align-items: center; background-color: #2c2c2c; border: 2px solid #444; border-radius: 8px; color: #ffffff; cursor: pointer; display: flex; flex-direction: column; gap: 0.5rem; justify-content: center; padding: 1rem; text-align: center; transition: all 0.2s ease; }
.selection-card.selected { background-color: #383838; border-color: #ffffff; }
.selection-card .card-title { display: block; margin: 0; font-weight: 700; }
.selection-card .card-desc { color: #aaa; margin: 0; font-size: 0.95rem; }
.selection-card .card-title.with-logo { margin-top: 0; }
.brand-logo { height: 40px; margin-bottom: 0.5rem; max-width: 120px; object-fit: contain; }
.search-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; margin-bottom: 1.5rem; max-width: 500px; padding: 0.75rem; width: 100%; }
.product-results { max-height: 250px; overflow-y: auto; }
.no-results { color: #888; text-align: center; padding: 2rem; }
.product-item { align-items: center; border: 2px solid transparent; border-radius: 8px; cursor: pointer; display: flex; gap: 1rem; padding: 0.75rem; }
.product-item:hover { background-color: #2c2c2c; }
.product-item.selected { border-color: #ffffff; }
.product-item img { border-radius: 4px; height: 50px; width: 50px; }
.form-group { margin-bottom: 1.5rem; }
.form-group label { display: block; font-weight: bold; margin-bottom: 0.75rem; }
.radio-group { display: flex; flex-wrap: wrap; gap: 0.75rem; }
.radio-btn { background-color: #2c2c2c; border: 2px solid #444; border-radius: 20px; color: #ffffff; cursor: pointer; font-size: 0.9rem; padding: 0.5rem 1.25rem; text-transform: capitalize; transition: all 0.2s ease; }
.radio-btn.selected { background-color: #383838; border-color: #ffffff; }
.price-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1.5rem; font-weight: bold; padding: 0.75rem; width: 100%; }
.input-note { color: #888; font-size: 0.8rem; margin-top: 0.5rem; }
.earnings-summary { border-top: 1px solid #333; margin: 1.5rem 0; padding-top: 1.5rem; }
.summary-item { align-items: center; display: flex; justify-content: space-between; margin-bottom: 0.75rem; }
.summary-item.total { font-size: 1.2rem; font-weight: bold; }
.negative { color: #f06e6e; }
.listing-review { background-color: #121212; border-radius: 8px; margin-top: 1.5rem; padding: 1rem; }
.listing-review h4 { margin-top: 0; }
.market-context { border-top: 1px solid #333; margin-top: 1rem; padding-top: 1rem; }
.market-context p { margin: 0.5rem 0; }
.wizard-footer { align-items: center; background-color: #121212; border-top: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 2rem; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn:disabled { background-color: #333; border-color: #444; color: #888; cursor: not-allowed; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
</style>
