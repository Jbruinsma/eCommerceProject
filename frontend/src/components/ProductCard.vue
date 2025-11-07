<template>
  <router-link
    :to="{ name: 'ProductDetail', params: { id: productId } }"
    class="product-card"
  >
    <img :src="imageUrl" :alt="name" class="product-image" />

    <div class="product-details">
      <h3 class="product-name">{{ name }}</h3>

      <p v-if="brandName" class="product-brand">{{ brandName }}</p>
    </div>

    <p class="product-price">
      {{ formatProductCardPrice(price) }}
    </p>
  </router-link>
</template>

<script setup>
import { defineProps } from 'vue'
import { formatProductCardPrice } from '@/utils/formatting.js'

defineProps({
  productId: {
    type: [String, Number],
    required: true
  },
  name: {
    type: String,
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    default: null
  },
  brandName: {
    type: String,
    default: null
  }
})
</script>

<style scoped>
a { color: black; text-decoration: none; }
h3 { font-family: 'Bodoni Moda', BlinkMacSystemFont, serif; font-size: 1.1rem; font-weight: 600; margin-bottom: 0; margin-top: 1rem; }
.product-card { background-color: #ffffff; border: 1px solid #7e7e7e; color: black; cursor: pointer; display: flex; flex-direction: column; padding: 2rem; text-align: center; transition: box-shadow 0.3s ease, transform 0.3s ease; }
.product-card:hover { box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4); transform: translateY(-5px); }
.product-image { aspect-ratio: 4 / 3; border-radius: 5px; object-fit: cover; width: 100%; }
.product-details { align-items: center; display: flex; flex-direction: column; flex-grow: 1; justify-content: center; }.product-name { font-family: 'Bodoni Moda', BlinkMacSystemFont, serif; font-size: 1.1rem; font-weight: 600; margin: 0; padding: 0.5rem 0; }
.product-brand { color: #555; font-family: 'Spectral', sans-serif; font-size: 0.9rem; font-weight: 600; margin-bottom: 0; margin-top: 1rem; text-transform: uppercase; }
.product-price { color: #3c862a; font-family: Bodoni Moda, BlinkMacSystemFont, serif; font-size: 1.2rem; margin-top: 0.5rem; }
</style>
