<template>
  <div class="login-container">
    <div class="login-form-container">
      <h2>Login to Your Account</h2>
      <form @submit.prevent="handleLogin">
        <div class="form-group">
          <label for="email">Email Address</label>
          <input
            id="email"
            type="email"
            class="form-input"
            v-model="email"
            placeholder="you@example.com"
            required
          >
        </div>
        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            type="password"
            class="form-input"
            v-model="password"
            placeholder="••••••••"
            required
          >
        </div>
        <button type="submit" class="submit-button">Login</button>
      </form>
      <div class="extra-links">
        <a href="/account-recovery">Forgot Password?</a>
        <a href="/register">Create Account</a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
// If you're using a router, you might import it here
// import { useRouter } from 'vue-router';

// const router = useRouter();

const email = ref('');
const password = ref('');

const handleLogin = () => {
  // 1. --- FORM VALIDATION ---
  // You can add more complex validation logic here if needed.
  // For example, checking if the password meets certain criteria.
  if (!email.value || !password.value) {
    console.error('Email and password are required.');
    // You could also set an error message in a ref to display in the template
    return;
  }

  // 2. --- API CALL ---
  // This is where you would make a call to your backend authentication endpoint.
  console.log('Submitting login request for:', email.value);

};
</script>

<style scoped>
/* Main container to center the form on the page */
.login-container { align-items: center; background-color: #121212; display: flex; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; justify-content: center; min-height: 100vh; padding: 2rem; }

/* The form card itself, styled like your product cards */
.login-form-container { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 8px; box-shadow: 0 10px 20px rgba(0,0,0,0.4); max-width: 400px; padding: 2.5rem 2rem; width: 100%; }

/* Header style consistent with the homepage */
h2 { color: #ffffff; font-size: 1.8rem; font-weight: 600; margin-bottom: 2rem; margin-top: 0; text-align: center; }

/* Styling for each label + input group */
.form-group { margin-bottom: 1.5rem; }

label { color: #cccccc; display: block; font-size: 0.9rem; margin-bottom: 0.5rem; }

/* Input fields styled to match the dark theme */
.form-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 4px; box-sizing: border-box; color: #ffffff; font-size: 1rem; padding: 0.8rem 1rem; transition: border-color 0.3s ease, box-shadow 0.3s ease; width: 100%; }
.form-input::placeholder { color: #888; }
.form-input:focus { border-color: #ffffff; box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1); outline: none; }

/* Login button, styled like your "Shop Now" button */
.submit-button { background-color: #ffffff; border: none; border-radius: 4px; color: #121212; cursor: pointer; font-size: 1rem; font-weight: bold; margin-top: 1rem; padding: 1rem; transition: background-color 0.3s ease; width: 100%; }
.submit-button:hover { background-color: #dddddd; }

/* Container for "Forgot Password" and "Create Account" links */
.extra-links { display: flex; justify-content: space-between; margin-top: 1.5rem; }
.extra-links a { color: #bbbbbb; font-size: 0.9rem; text-decoration: none; transition: color 0.3s ease; }
.extra-links a:hover { color: #ffffff; text-decoration: underline; }
</style>
