<template>
  <footer class="site-footer">
    <div class="footer-container">
      <div class="footer-column">
        <h4>Shop</h4>
        <ul>
          <li><a href="/search?category=sneakers">Sneakers</a></li>
          <li><a href="/search?category=apparel">Apparel</a></li>
          <li><a href="/search?category=new">New Arrivals</a></li>
        </ul>
      </div>

      <div class="footer-column">
        <h4>Support</h4>
        <ul>
          <li><a href="/contact">Contact Us</a></li>
          <li><a href="/faq">FAQ</a></li>
          <li><a href="/shipping">Shipping & Returns</a></li>
        </ul>
      </div>

      <div class="footer-column">
        <h4>Company</h4>
        <ul>
          <li><a href="/about">About Us</a></li>
          <li><a href="/careers">Careers</a></li>
          <li><a href="/tos">Terms of Service</a></li>
        </ul>
      </div>

      <div class="footer-column">
        <h4>Follow Us</h4>
        <ul>
          <li><a href="#" target="_blank">Instagram</a></li>
          <li><a href="#" target="_blank">X (Twitter)</a></li>
          <li><a href="#" target="_blank">Facebook</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2025 The Vault Marketplace. All Rights Reserved.</p>
    </div>
  </footer>
</template>

<script setup>
</script>

<style scoped>
.site-footer { background-color: #1a1a1a; border-top: 1px solid #333; color: #888; padding: 3rem 5%; font-family: 'Manrope', sans-serif; }
.footer-container { display: flex; flex-wrap: wrap; justify-content: space-between;gap: 2rem; max-width: 1200px; margin: 0 auto; padding-bottom: 2rem; }
.footer-column { flex: 1; min-width: 150px; }
.footer-column h4 { color: #ffffff; font-family: 'Bodoni Moda', serif; font-size: 1.2rem; font-weight: 600; margin-bottom: 1rem; }
.footer-column ul { list-style: none; padding: 0; margin: 0; }
.footer-column li { margin-bottom: 0.5rem; }
.footer-column a { color: #cccccc; text-decoration: none; transition: color 0.3s ease; }
.footer-column a:hover { color: #ffffff; text-decoration: underline; }
.footer-bottom { border-top: 1px solid #333; padding-top: 2rem; text-align: center; color: #888; font-size: 0.9rem; }
</style>
