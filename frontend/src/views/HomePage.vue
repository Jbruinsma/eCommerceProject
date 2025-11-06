<template>
  <div class="home-container">
    <section v-if="loading" class="collage-hero-loading">
      <h1>Loading...</h1>
    </section>

    <section v-else-if="apiError" class="hero-fallback">
      <h1>Welcome to The Vault</h1>
      <p class="hero-info">Start browsing our collection.</p>
      <a @click="router.push({ name: 'SearchResults' })" class="shop-now-link">
        <span>Shop Now</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="arrow-icon"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3"
          />
        </svg>
      </a>
    </section>

    <section v-else-if="bannerProduct" class="collage-hero">
      <div class="collage-left">
        <h1>{{ bannerProduct.text.header }}</h1>
        <p class="hero-info">{{ bannerProduct.text.subtext }}</p>
        <img
          :src="bannerProduct.text.image"
          alt="Banner inspiration"
          class="collage-image-1"
        />
      </div>

      <div class="collage-right-stack">
        <div class="card-overlap-container">
          <router-link
            :to="{ name: 'ProductDetail', params: { id: bannerProduct.productInfo[0].product_id } }"
            class="collage-product-card hero-card-1"
          >
            <img
              :src="bannerProduct.productInfo[0].image_url"
              :alt="bannerProduct.productInfo[0].name"
              class="collage-product-image"
            />
            <h3 class="collage-product-name">{{ bannerProduct.productInfo[0].name }}</h3>
            <p
              v-if="bannerProduct.productInfo[0].lowest_asking_price"
              class="collage-product-price"
            >
              ${{ bannerProduct.productInfo[0].lowest_asking_price }}
            </p>
          </router-link>

          <router-link
            v-if="bannerProduct.productInfo[1]"
            :to="{ name: 'ProductDetail', params: { id: bannerProduct.productInfo[1].product_id } }"
            class="collage-product-card hero-card-2"
          >
            <img
              :src="bannerProduct.productInfo[1].image_url"
              :alt="bannerProduct.productInfo[1].name"
              class="collage-product-image"
            />
            <h3 class="collage-product-name">{{ bannerProduct.productInfo[1].name }}</h3>
            <p
              v-if="bannerProduct.productInfo[1].lowest_asking_price"
              class="collage-product-price"
            >
              ${{ bannerProduct.productInfo[1].lowest_asking_price }}
            </p>
          </router-link>
        </div>

        <a
          @click="router.push({ name: 'SearchResults', query: { q: 'Maison Margiela' } })"
          class="shop-now-link"
        >
          <span>Shop Now</span>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="arrow-icon"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3"
            />
          </svg>
        </a>
      </div>
    </section>

    <main class="featured-products" v-if="featuredProducts.length > 0">
      <h2>Featured Items</h2>
      <div class="product-grid">
        <router-link
          v-for="product in featuredProducts"
          :key="product.id"
          :to="{ name: 'ProductDetail', params: { id: product.id } }"
          class="product-card"
        >
          <img :src="product.imageUrl" :alt="product.name" class="product-image" />
          <h3>{{ product.name }}</h3>
          <p class="product-price">${{ product.price }}</p>
        </router-link>
      </div>
    </main>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { fetchFromAPI } from '@/utils/index.js'
import router from '@/router/index.js'


const featuredProducts = ref([])
const bannerProduct = ref(null)
const loading = ref(true)
const apiError = ref(null)

onMounted(async () => {
  try {
    const response = await fetchFromAPI('/product/featured')

    featuredProducts.value = response.homepageProducts.map((product) => ({
      id: product.product_id,
      name: product.name,
      price: product.lowest_asking_price,
      imageUrl: product.image_url
    }))

    bannerProduct.value = response.bannerProduct
  } catch (error) {
    console.error('Error fetching featured products:', error)
    apiError.value = error
  } finally {
    loading.value = false
  }
})
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Abel&family=Bodoni+Moda+SC:ital,opsz,wght@0,6..96,400..900;1,6..96,400..900&family=Inclusive+Sans&family=Inconsolata:wght@200;300;400;500;600&family=Manrope:wght@600;700;8E&family=Mulish:ital,wght@0,300;0,400;0,700;1,200;1,400;1,600&family=Nanum+Myeongjo&family=Quicksand:wght@300..700&family=Scope+One&family=Sono:wght@200;300;400&family=Spectral:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;0,800;1,200;1,300;1,400;1,500;1,600;1,700;1,800&family=Zeyada&display=swap');
</style>

<style>
body, html { background-color: #1a1a1a; margin: 0; padding: 0; width: 100%; }
</style>

<style scoped>
.home-container { color: #ffffff; font-family: Bodoni Moda, BlinkMacSystemFont, serif; margin: 0 auto; max-width: 1400px; min-height: 100vh; width: 100%; }
h1, h2, h3 { font-weight: 600; }
h1 { font-size: 3rem; margin-bottom: 1rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; text-align: center; }
h3 { font-size: 1.1rem; margin-top: 1rem; }
p { color: #cccccc; line-height: 1.6; }
a { color: #ffffff; text-decoration: none; }
.nav-links a { transition: color 0.3s ease; }
.nav-links a:hover { color: #bbbbbb; }

.collage-hero { align-items: center; display: grid; gap: 2rem; grid-template-columns: 1fr 1fr; padding: 4rem 5%; }
.collage-hero-loading { align-items: center; display: flex; justify-content: center; min-height: 60vh; }
.hero-fallback { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 50vh; padding: 4rem 5%; text-align: center; }
.hero-fallback .hero-info { margin-bottom: 2.5rem; } /* Add space above button */

.collage-left { display: flex; flex-direction: column; justify-content: center; text-shadow: 1px 1px 2px #000; }
.hero-info { color: white; font-size: 1.2rem; margin-bottom: 1rem; }
.collage-image-1 { border-radius: 10px; margin-top: 1rem; object-fit: cover; width: 100%; }
.collage-right-stack { align-items: center; display: flex; flex-direction: column; gap: 2.5rem; justify-content: center; }
.card-overlap-container { align-items: center; display: flex; justify-content: center; position: relative; }

.collage-product-card { background-color: #ffffff; border: 1px solid #7e7e7e; border-radius: 10px; color: black; cursor: pointer; max-width: 360px; padding: 2rem; text-align: center; text-decoration: none; transition: transform 0.3s ease, box-shadow 0.3s ease; width: 100%; }
.collage-product-card:hover { box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4); transform: translateY(-5px) rotate(var(--hover-rotate, 0)); }
.collage-product-name { font-size: 1.2rem; margin-top: 1rem; }
.collage-product-image { aspect-ratio: 4 / 3; border-radius: 5px; object-fit: cover; width: 100%; }
.collage-product-price { color: #3c862a; font-size: 1.2rem; margin-top: 0.5rem; }

.hero-card-1 { transform: rotate(5deg); z-index: 1; --hover-rotate: 5deg; }
.hero-card-2 { box-shadow: 0 15px 30px rgba(0, 0, 0, 0.5); margin-left: -120px; transform: rotate(-3deg); z-index: 2; --hover-rotate: -3deg; }
.hero-card-2:hover { box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6); }

.shop-now-link { align-items: center; color: #ffffff; display: flex; font-size: 1.1rem; font-weight: bold; gap: 0.5rem; text-decoration: none; transition: gap 0.3s ease; }
.shop-now-link:hover { gap: 0.8rem; cursor: pointer; }
.arrow-icon { height: 1.5rem; transition: transform 0.3s ease; width: 1.5rem; }
.shop-now-link:hover .arrow-icon { transform: translateX(4px); }

.featured-products { padding: 4rem 5%; text-shadow: 1px 1px 1px gray; }
.product-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.product-card { background-color: #ffffff; border: 1px solid #7e7e7a; border-radius: 10px; color: black; cursor: pointer; padding: 2rem; text-align: center; transition: transform 0.3s ease, box-shadow 0.3s ease; }
.product-card:hover { box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4); transform: translateY(-5px); }
.product-image { aspect-ratio: 4 / 3; border-radius: 5px; object-fit: cover; width: 100%; }
.product-price { color: #3c862a; font-size: 1.2rem; margin-top: 0.5rem; }

@media (max-width: 768px) {
  .collage-hero { grid-template-columns: 1fr; }
  .collage-right-stack { flex-direction: column; gap: 2rem; margin-top: 2rem; }
  .card-overlap-container { flex-direction: column; } /* Stack cards on mobile */
  .hero-card-1, .hero-card-2 { margin-left: 0; transform: none; }
}
</style>
