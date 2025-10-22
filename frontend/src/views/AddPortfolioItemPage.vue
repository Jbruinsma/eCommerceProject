<template>
  <div class="add-item-container">
    <main class="add-item-content">
      <div class="wizard-card">
        <div v-if="isLoading" class="loading-overlay">
          <div class="spinner"></div>
          <p>Adding item to portfolio...</p>
        </div>
        <div v-else-if="submissionResult" class="submission-result-screen">
          <div v-if="submissionResult.success">
            <svg class="result-icon success" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" /></svg>
            <h2>Item Added!</h2>
            <p>Your item has been successfully added to your collection.</p>
            <div class="result-summary">
              <p><strong>Item:</strong> {{ selectedProduct.name }}</p>
              <p><strong>Size:</strong> {{ selectedSizeValue }}</p>
              <p><strong>Paid:</strong> {{ formatCurrency(submissionResult.data.acquisition_price) }}</p>
            </div>
            <button @click="router.push('/portfolio')" class="btn btn-primary">View Portfolio</button>
          </div>
          <div v-else>
            <svg class="result-icon error" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" /></svg>
            <h2>Something Went Wrong</h2>
            <p>{{ submissionResult.message || 'We couldn\'t add your item. Please try again.' }}</p>
            <button @click="submissionResult = null" class="btn btn-secondary">Try Again</button>
          </div>
        </div>

        <template v-else>
          <div class="progress-bar">
            <div class="progress" :style="{ width: `${(currentStep - 1) * 33.3}%` }"></div>
          </div>
          <div class="wizard-header">
            <h2>Add Item to Portfolio</h2>
            <p>Step {{ currentStep }} of 4: {{ stepTitle }}</p>
          </div>

          <div v-if="currentStep === 1" class="step-content">
            <input type="text" v-model="brandSearchQuery" placeholder="Search for brand..." class="search-input">
            <div class="selection-grid product-results">
              <button v-for="brand in filteredBrands" :key="brand.brand_id" class="selection-card" :class="{ selected: portfolioItemData.brand_id === brand.brand_id }" @click="selectBrand(brand.brand_id)">
                <img v-if="brand.brand_logo_url" :src="brand.brand_logo_url" :alt="`${brand.brand_name} Logo`" class="brand-logo">
                <span :class="['card-title', {'with-logo': !brand.brand_logo_url}]">{{ brand.brand_name }}</span>
              </button>
            </div>
          </div>

          <div v-if="currentStep === 2" class="step-content">
            <input type="text" v-model="productSearchQuery" placeholder="Search for product by name..." class="search-input">
            <div class="product-results">
              <div v-if="filteredProducts.length === 0" class="no-results">No products found.</div>
              <div v-else v-for="product in filteredProducts" :key="product.product_id" class="product-item" :class="{ selected: portfolioItemData.product_id === product.product_id }" @click="selectProduct(product)">
                <img :src="product.image_url" :alt="product.name">
                <span>{{ product.name }}</span>
              </div>
            </div>
          </div>

          <div v-if="currentStep === 3" class="step-content">
            <div class="form-grid">
              <div class="form-group span-2">
                <label>Size</label>
                <div class="radio-group size-group">
                  <button v-for="size in selectedProduct?.sizes" :key="size.size_id" class="radio-btn" :class="{ selected: portfolioItemData.size_id === size.size_id }" @click="portfolioItemData.size_id = size.size_id">{{ size.size_value }}</button>
                </div>
              </div>
              <div class="form-group span-2">
                <label>Condition</label>
                <div class="radio-group">
                  <button v-for="condition in conditions" :key="condition" class="radio-btn" :class="{ selected: portfolioItemData.item_condition === condition }" @click="portfolioItemData.item_condition = condition">{{ condition }}</button>
                </div>
              </div>
              <div class="form-group">
                <label for="acquisition_date">Acquisition Date (Optional)</label>
                <input type="date" id="acquisition_date" v-model="portfolioItemData.acquisition_date" class="text-input">
              </div>
              <div class="form-group">
                <label for="acquisition_price">Acquisition Price</label>
                <input type="number" id="acquisition_price" v-model.number="portfolioItemData.acquisition_price" placeholder="$0.00" class="text-input">
              </div>
            </div>
          </div>

          <div v-if="currentStep === 4" class="step-content review-step">
            <div class="listing-review">
              <h4>Review Your Item</h4>
              <p><strong>Item:</strong> {{ selectedProduct.name }}</p>
              <p><strong>Size:</strong> {{ selectedSizeValue }} | <strong>Condition:</strong> {{ portfolioItemData.item_condition }}</p>
              <p><strong>Acquired On:</strong> {{ formatDate(portfolioItemData.acquisition_date) }}</p>
              <p><strong>Price Paid:</strong> {{ formatCurrency(portfolioItemData.acquisition_price) }}</p>
            </div>
          </div>

          <div class="wizard-footer">
            <button v-if="currentStep > 1" @click="prevStep" class="btn btn-secondary">Back</button>
            <button v-if="currentStep < 4" @click="nextStep" :disabled="!isStepValid" class="btn btn-primary">Next</button>
            <button v-if="currentStep === 4" @click="submitPortfolioItem" :disabled="!isStepValid" class="btn btn-primary">Add to Portfolio</button>
          </div>
        </template>
      </div>
    </main>
    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue';
import { fetchFromAPI, postToAPI } from '@/utils/index.js';
import { useAuthStore } from '@/stores/authStore.js';
import router from '@/router/index.js';

const currentStep = ref(1);
const portfolioItemData = reactive({ brand_id: null, product_id: null, size_id: null, item_condition: null, acquisition_date: null, acquisition_price: null });
const brands = ref([]);
const authStore = useAuthStore();
const isLoading = ref(false);
const submissionResult = ref(null);

onMounted(async () => {
  if (!authStore.isLoggedIn) { await router.push('/login'); return; }
  try {
    const brandsResponse = await fetchFromAPI('/product/brands');
    brands.value = brandsResponse || [];
  } catch (error) { console.error("Failed to fetch brands:", error); }
});

const conditions = ['new', 'used', 'worn'];
const productSearchQuery = ref('');
const productsResults = ref([]);
const brandSearchQuery = ref('');

const stepTitle = computed(() => ["Select Brand", "Find Your Item", "Add Details", "Review Item"][currentStep.value - 1] || '');
const filteredBrands = computed(() => { if (!brandSearchQuery.value) return brands.value; return brands.value.filter(b => b.brand_name.toLowerCase().includes(brandSearchQuery.value.toLowerCase())); });
const filteredProducts = computed(() => productsResults.value.filter(p => p.name.toLowerCase().includes(productSearchQuery.value.toLowerCase())));
const selectedProduct = computed(() => productsResults.value.find(p => p.product_id === portfolioItemData.product_id));
const selectedSizeValue = computed(() => selectedProduct.value?.sizes.find(s => s.size_id === portfolioItemData.size_id)?.size_value);

const isStepValid = computed(() => {
  switch (currentStep.value) {
    case 1: return !!portfolioItemData.brand_id;
    case 2: return !!portfolioItemData.product_id;
    case 3: return !!portfolioItemData.size_id && !!portfolioItemData.item_condition && portfolioItemData.acquisition_price > 0;
    case 4: return true;
    default: return false;
  }
});

async function searchForProducts() {
  if (!portfolioItemData.brand_id) { productsResults.value = []; return; }
  try {
    const rawProducts = await fetchFromAPI(`/product/search?brand_id=${portfolioItemData.brand_id}&product_name=${productSearchQuery.value || ''}`);
    productsResults.value = (rawProducts || []).map(product => ({
      ...product,
      sizes: typeof product.sizes === 'string' ? JSON.parse(product.sizes) : []
    }));
  } catch (err) { console.error('Product search failed', err); productsResults.value = []; }
}

watch(() => portfolioItemData.brand_id, () => {
  productSearchQuery.value = '';
  portfolioItemData.product_id = null;
  productsResults.value = [];
  searchForProducts();
});
watch(productSearchQuery, (newQuery) => { if (newQuery.length >= 2 || newQuery.length === 0) searchForProducts(); });

function selectBrand(brandId) { portfolioItemData.brand_id = brandId; }
function selectProduct(product) { portfolioItemData.product_id = product.product_id; }
function nextStep() { if (isStepValid.value) currentStep.value++; }
function prevStep() { if (currentStep.value > 1) currentStep.value--; }

async function submitPortfolioItem() {
  if (!isStepValid.value) return;
  isLoading.value = true;
  submissionResult.value = null;

  try {
    const response = await postToAPI(`/portfolio/${authStore.uuid}`, portfolioItemData);
    if (response && response.portfolio_item_id) {
      submissionResult.value = { success: true, data: response };
    } else {
      throw new Error('Invalid response from server.');
    }
  } catch (error) {
    submissionResult.value = { success: false, message: error.message || 'An unknown error occurred.' };
  } finally {
    isLoading.value = false;
  }
}

const formatCurrency = (amount) => new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount || 0);
const formatDate = (dateString) => {
  if (!dateString) return 'N/A';
  const options = { year: 'numeric', month: 'long', day: 'numeric' };
  // Add a day to the date to correct for timezone issues with date inputs
  const date = new Date(dateString);
  date.setDate(date.getDate() + 1);
  return date.toLocaleDateString('en-US', options);
}
</script>

<style scoped>
.loading-overlay { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 400px; padding: 2rem; }
.spinner { animation: spin 1s linear infinite; border: 4px solid #333; border-radius: 50%; border-top: 4px solid #ffffff; height: 50px; width: 50px; }
.loading-overlay p { color: #888; font-weight: bold; margin-top: 1rem; }
@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
.submission-result-screen { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 400px; padding: 2rem; text-align: center; }
.result-icon { height: 80px; margin-bottom: 1rem; width: 80px; }
.result-icon.success { color: #6ef0a3; }
.result-icon.error { color: #f06e6e; }
.submission-result-screen h2 { border-bottom: none; font-size: 2rem; }
.submission-result-screen p { color: #aaa; max-width: 400px; }
.result-summary { background-color: #121212; border-radius: 8px; margin: 1.5rem 0; padding: 1rem; text-align: left; width: 100%; max-width: 350px; }
.result-summary p { margin: 0.5rem 0; }
a { color: #ffffff; text-decoration: none; }
h2 { font-size: 1.8rem; margin-bottom: 0.5rem; text-align: left; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.add-item-container { color: #ffffff; font-family: Spectral, sans-serif; }
.add-item-content { display: flex; justify-content: center; padding: 4rem 5%; }
.wizard-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; max-width: 800px; overflow: hidden; width: 100%; }
.progress-bar { background-color: #2c2c2c; height: 8px; width: 100%; }
.progress { background-color: #ffffff; height: 100%; transition: width 0.3s ease; }
.wizard-header { padding: 2rem 2rem 1rem; }
.wizard-header p { color: #888; margin: 0; }
.step-content { min-height: 300px; padding: 1rem 2rem; }
.selection-grid { display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); }
.selection-card { align-items: center; background-color: #2c2c2c; border: 2px solid #444; border-radius: 8px; color: #ffffff; cursor: pointer; display: flex; flex-direction: column; gap: 0.5rem; justify-content: center; padding: 1rem; text-align: center; transition: all 0.2s ease; }
.selection-card.selected { background-color: #383838; border-color: #ffffff; }
.selection-card .card-title { display: block; font-weight: 700; margin: 0; }
.brand-logo { height: 40px; margin-bottom: 0.5rem; max-width: 120px; object-fit: contain; }
.search-input, .text-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem; width: 100%; }
.search-input { margin-bottom: 1.5rem; max-width: 500px; }
.product-results { max-height: 250px; overflow-y: auto; }
.no-results { color: #888; padding: 2rem; text-align: center; }
.product-item { align-items: center; border: 2px solid transparent; border-radius: 8px; cursor: pointer; display: flex; gap: 1rem; padding: 0.75rem; }
.product-item:hover { background-color: #2c2c2c; }
.product-item.selected { border-color: #ffffff; }
.product-item img { border-radius: 4px; height: 50px; width: 50px; }
.form-grid { display: grid; gap: 2rem; grid-template-columns: repeat(2, 1fr); }
.form-group { margin-bottom: 0; }
.form-group.span-2 { grid-column: span 2; }
.form-group label { display: block; font-weight: bold; margin-bottom: 0.75rem; }
.radio-group { display: flex; flex-wrap: wrap; gap: 0.75rem; }
.radio-btn { background-color: #2c2c2c; border: 2px solid #444; border-radius: 20px; color: #ffffff; cursor: pointer; font-size: 0.9rem; padding: 0.5rem 1.25rem; text-transform: capitalize; transition: all 0.2s ease; }
.radio-btn.selected { background-color: #383838; border-color: #ffffff; }
.listing-review { background-color: #121212; border-radius: 8px; margin-top: 1.5rem; padding: 1.5rem; }
.listing-review h4 { margin-top: 0; }
.listing-review p { margin: 0.75rem 0; }
.wizard-footer { align-items: center; background-color: #121212; border-top: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 2rem; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn:disabled { background-color: #333; border-color: #444; color: #888; cursor: not-allowed; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
</style>
