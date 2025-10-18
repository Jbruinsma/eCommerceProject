<template>
  <div class="home-container">
    <nav class="navbar">
      <div class="logo">NAME</div>
      <ul class="nav-links">
        <li class ="nav-customization"><a href="#">Sneakers</a></li>
        <li class ="nav-customization"><a href="#">Apparel</a></li>
        <li class ="nav-customization"><a href="#">Collectibles</a></li>
      </ul>
      <div class="nav-icons">
        <div class="search-bar">
          <svg
            class="search-icon"
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <path
              d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"
            />
          </svg>
          <input
            type="text"
            class="search-input"
            placeholder="Search for items..."
            v-model="searchQuery"
            @keyup.enter="handleSearch"
          />
        </div>
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

    <header class="hero-section">
      <div class="hero-content">
        <h1>Latest Drop: "Future Sneaker"</h1>
        <!-- <img class ="featured-product-img" src="/images/MaisonMargielaFutureBlack.png"></img> -->
        <p class = hero-info>Experience the future of footwear. Reintroducing the Future Sneaker, originally launched in the SS11 collection, the Future Sneaker is making its way back onto the shelves this season.</p>
        <p class = hero-info>Featured Collection by Maison Margiela</p>
        <button class="cta-button">Shop Now</button>
      </div>
    </header>

    <main class="featured-products">
      <h2>Featured Items</h2>
      <div class="product-grid">
        <div v-for="product in featuredProducts" :key="product.id" class="product-card">
          <img :src="product.imageUrl" :alt="product.name" class="product-image" />
          <h3>{{ product.name }}</h3>
          <p class="product-price">${{ product.price }}</p>
        </div>
      </div>
    </main>

    <footer class="site-footer">
      <p>&copy; 2025 NAME Marketplace. All Rights Reserved.</p>
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'

const searchQuery = ref('')

const authStore = useAuthStore();

const handleSearch = () => {
  console.log(`Searching for: ${searchQuery.value}`)
}

const featuredProducts = ref([
  {
    id: 1,
    name: 'Air Runner "Graphite"',
    price: 250,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+1',
  },
  {
    id: 2,
    name: 'Streetwise Hoodie "Carbon"',
    price: 120,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+2',
  },
  {
    id: 3,
    name: 'Retro Dunk "Obsidian"',
    price: 310,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+3',
  },
  {
    id: 4,
    name: 'Vapor Max "Midnight"',
    price: 190,
    imageUrl: 'https://placehold.co/400x300/1a1a1a/ffffff?text=Sneaker+4',
  },
])

function redirectToProfile() {
  if (authStore.isLoggedIn) { router.push('/profile') }
  else { router.push('/login') }
}

</script>

<style>
/*Fonts */
@import url('https://fonts.googleapis.com/css2?family=Abel&family=Bodoni+Moda+SC:ital,opsz,wght@0,6..96,400..900;1,6..96,400..900&family=Inclusive+Sans&family=Inconsolata:wght@200;300;400;500;600&family=Manrope:wght@600;700;800&family=Mulish:ital,wght@0,300;0,400;0,700;1,200;1,400;1,600&family=Nanum+Myeongjo&family=Quicksand:wght@300..700&family=Scope+One&family=Sono:wght@200;300;400&family=Spectral:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;0,800;1,200;1,300;1,400;1,500;1,600;1,700;1,800&family=Zeyada&display=swap');
</style>

<style>
/* Global styles for body and html to ensure full dark background */
body,
html {
  background-color: #121212;
  margin: 0;
  padding: 0;
  width: 100%;
}
</style>

<style scoped>
.home-container { color: #ffffff; font-family: Spectral, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; min-height: 100vh; width: 100%; }
h1, h2, h3 { font-weight: 600; }
h1 { font-size: 3rem; margin-bottom: 1rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; text-align: center; }
h3 { font-size: 1.1rem; margin-top: 1rem; }
p { color: #cccccc; line-height: 1.6; }
a { color: #ffffff; text-decoration: none; }
.navbar { align-items: center; background-color: #1a1a1a; display: flex; justify-content: space-between; padding: 1rem 5%; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.nav-links { align-items: center; display: flex; gap: 2rem; list-style: none; }
.nav-links a { transition: color 0.3s ease; }
.nav-links a:hover { color: #bbbbbb; }
.nav-customization { font-size: 20px; font-weight: 500; display: inline-flex; }
.nav-icons { align-items: center; display: flex; gap: 1.5rem; }
.account-icon { cursor: pointer; height: 28px; width: 28px; }
.cart-icon { cursor: pointer; height: 28px; width: 28px; }
.search-bar { align-items: center; background-color: #2c2c2c; border-radius: 12px; display: flex; padding: 0.3rem 0.8rem; }
.search-icon { fill: #888; height: 30px; margin-right: 0.5rem; width: 15px; }
.search-input { background-color: transparent; border: none; color: #ffffff; font-size: 0.9rem; outline: none; width: 200px; }
.search-input::placeholder { color: #888; }
.hero-section { background: linear-gradient(rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.2)), url('/images/MaisonMargielaBanner.png') no-repeat center center/cover; min-height: 60vh; padding: 5rem 5%; text-align: center; }
.hero-content { margin: 0 auto; max-width: 800px; text-shadow: 2px 2px 2px black;}
.hero-info { font-size: 1.2rem; margin-bottom: 1rem; color: white; text-shadow: 1px 1px 1px black;}
.cta-button { background-color:#ffffff;  border:1px solid #000000; border-radius: 10px; color:#121212; cursor:pointer; font-size:1rem; font-weight:bold; margin-top:2rem; padding:1rem 2rem; transition:background-color 0.7s ease,color 0.7s ease,border-color 0.7s ease; }
.cta-button:hover { background-color:#000000; color:#ffffff; border-color:#ffffff; }
.featured-products { padding: 4rem 5%; }
.product-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.product-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; cursor: pointer; padding: 1.5rem; text-align: center; transition: transform 0.3s ease, box-shadow 0.3s ease; }
.product-card:hover { box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4); transform: translateY(-5px); }
.product-image { aspect-ratio: 4 / 3; object-fit: cover; width: 100%; }
.product-price { color: #ffffff; font-size: 1.2rem; font-weight: bold; margin-top: 0.5rem; }
.site-footer { background-color: #1a1a1a; border-top: 1px solid #333; color: #888; padding: 2rem 5%; text-align: center; }
</style>
