<template>
  <div class="home-container">
    <header class="hero-section">
      <div class="hero-content">
        <h1>Latest Drop: "Future Sneaker"</h1>
        <!-- <img class ="featured-product-img" src="/images/MaisonMargielaFutureBlack.png"></img> -->
        <p class = hero-info>Experience the future of footwear. Reintroducing the Future Sneaker, originally launched in the SS11 collection, the Future Sneaker is making its way back onto the shelves this season.</p>
        <p class = hero-info>Featured Collection by Maison Margiela</p>
        <a href="/search?category=sneakers"> <button class="cta-button">Shop Now</button></a>
      </div>
    </header>

    <main class="featured-products">
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

    <footer class="site-footer">
      <p>&copy; 2025 NAME Marketplace. All Rights Reserved.</p>
    </footer>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const featuredProducts = ref([
 {
   id: 1,
   name: 'MF Doom Dunk High Pro SB',
   price: '2,204',
   imageUrl: '/images/MFDoomNike.png',
 },
 {
   id: 2,
   name: "Humidity x Nike Dunk High SB 'Trumpet'",
   price: 750,
   imageUrl: '/images/NikeSBMetallicGold.png',
 },
 {
   id: 3,
   name: 'Maison Margiela Future High Top Black',
   price: '1,190',
   imageUrl: '/images/MaisonMargielaFutureBlack.png',
 },
 {
   id: 4,
   name: 'Balenciaga Men\'s Furry Slides',
   price: 135,
   imageUrl: '/images/BalenciagaMenSlides.webp' ,
 },
])
</script>


<style>
/*Fonts */
@import url('https://fonts.googleapis.com/css2?family=Abel&family=Bodoni+Moda+SC:ital,opsz,wght@0,6..96,400..900;1,6..96,400..900&family=Inclusive+Sans&family=Inconsolata:wght@200;300;400;500;600&family=Manrope:wght@600;700;800&family=Mulish:ital,wght@0,300;0,400;0,700;1,200;1,400;1,600&family=Nanum+Myeongjo&family=Quicksand:wght@300..700&family=Scope+One&family=Sono:wght@200;300;400&family=Spectral:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;0,800;1,200;1,300;1,400;1,500;1,600;1,700;1,800&family=Zeyada&display=swap');
</style>


<style>
/* Global styles for body and html to ensure full dark background */
body,
html {
 /* Default color - #1a1a1a */
 background-color: #1a1a1a;
 margin: 0;
 padding: 0;
 width: 100%;
}
</style>


<style scoped>
.home-container { color: #ffffff; font-family: Bodoni Moda, BlinkMacSystemFont,serif; min-height: 100vh; width: 100%; }
h1, h2, h3 { font-weight: 600; }
h1 { font-size: 3rem; margin-bottom: 1rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 2rem; padding-bottom: 1rem; text-align: center; }
h3 { font-size: 1.1rem; margin-top: 1rem; }
p { color: #cccccc; line-height: 1.6; }
a { color: #ffffff; text-decoration: none; }
.nav-links a { transition: color 0.3s ease; }
.nav-links a:hover { color: #bbbbbb; }
.hero-section { background: linear-gradient(rgba(0, 0, 0, 0.7), rgba(0, 0, 0, 0.2)), url('/images/MaisonMargielaBanner.png') no-repeat center center/cover; min-height: 60vh; padding: 5rem 5%; text-align: center; }
.hero-content { margin: 0 auto; max-width: 800px; text-shadow: 2px 2px 2px black;}
.hero-info { font-size: 1.2rem; margin-bottom: 1rem; color: white; text-shadow: 1px 1px 1px black;}
.cta-button { background-color:#ffffff;  border:1px solid #000000; border-radius: 10px; color:#121212; cursor:pointer; font-size:1rem; font-weight:bold; margin-top:2rem; padding:1rem 2rem; transition:background-color 0.7s ease,color 0.7s ease,border-color 0.7s ease; }
.cta-button:hover { background-color:#000000; color:#ffffff; border-color:#ffffff; }
.featured-products { padding: 4rem 5%; text-shadow: 1px 1px 1px gray;}
.product-grid { display: grid; gap: 2rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.product-card { background-color: #ffffff; border: px solid #7e7e7e; cursor: pointer; padding: 2rem; text-align: center; transition: transform 0.3s ease, box-shadow 0.3s ease; color: black; }
.product-card:hover { box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4); transform: translateY(-5px); }
.product-image { aspect-ratio: 4 / 3; object-fit: cover; width: 100%; }
.product-price { color: #3c862a; font-size: 1.2rem; margin-top: 0.5rem; }
.site-footer { background-color: #1a1a1a; border-top: 1px solid #333; color: #888; padding: 2rem 5%; text-align: center; }
</style>
