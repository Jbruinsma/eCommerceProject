<template>
  <footer class="site-footer">
    <div class="footer-container">
      <div class="footer-column">
        <h4>Shop</h4>
        <ul>
          <li><a href="/search?category=sneakers">Sneakers</a></li>
          <li><a href="/search?category=apparel">Apparel</a></li>
          <li><a href="/search?category=Accessory">Accessories</a></li>
        </ul>
      </div>

      <div class="footer-column">
        <h4>Codebase</h4>
        <ul>
          <li>
            <a href="https://github.com/Jbruinsma/eCommerceProject" target="_blank">GitHub</a>
          </li>
        </ul>
      </div>

      <div class="footer-column">
        <h4>Contributors</h4>
        <ul>
          <li><a href="https://github.com/Jbruinsma" target="_blank">Justin Bruinsma</a></li>
          <li><a href="https://github.com/fwmo" target="_blank">Mohammad Loum</a></li>
        </ul>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2025 The Vault. All Rights Reserved.</p>
    </div>
  </footer>
</template>

<script setup></script>

<style scoped>
.site-footer {
  background-color: #1a1a1a;
  border-top: 1px solid #333;
  color: #888;
  padding: 3rem 5%;
  font-family: 'Manrope', sans-serif;
}
.footer-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 4rem;
  max-width: 1200px;
  margin: 0 auto;
  padding-bottom: 2rem;
}
.footer-column {
  min-width: 150px;
}
.footer-column h4 {
  color: #ffffff;
  font-family: 'Bodoni Moda', serif;
  font-size: 1.2rem;
  font-weight: 600;
  margin-bottom: 1rem;
}
.footer-column ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.footer-column li {
  margin-bottom: 0.5rem;
}
.footer-column a {
  color: #cccccc;
  text-decoration: none;
  transition: color 0.3s ease;
}
.footer-column a:hover {
  color: #ffffff;
  text-decoration: underline;
}
.footer-bottom {
  border-top: 1px solid #333;
  padding-top: 2rem;
  text-align: center;
  color: #888;
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .footer-container {
    justify-content: flex-start;
    padding-left: 2rem;
    padding-right: 2rem;
    gap: 2.5rem;
  }
  .footer-column {
    min-width: 200px;
  }
}
</style>
