<template>
  <div class="forgot-password-container">
    <div class="form-container">
      <h2>Reset Your Password</h2>
      <p class="instructions">Enter your email address below, and we'll send you a link to get back into your account.</p>
      <form @submit.prevent="handleForgotPassword">
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
        <button type="submit" class="submit-button">Send Reset Link</button>
      </form>
      <div class="extra-links">
        <a href="/login">Back to Login</a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const email = ref('');

const handleForgotPassword = () => {
  // 1. --- API CALL ---
  // You would make an API call here to your backend password reset endpoint.
  // The backend should handle checking for the email and sending the reset link.
  // For security, the backend should always return a successful response, even if the
  // email doesn't exist, to prevent attackers from discovering registered emails.
  console.log(`Password reset requested for: ${email.value}`);

  alert("If that email is associated with an account, you will receive an email with steps to reset the password to your account.");
};
</script>

<style scoped>
/* Main container to center the form on the page */
.forgot-password-container { align-items: center; background-color: #121212; display: flex; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; justify-content: center; min-height: 100vh; padding: 2rem; }

/* The form card itself */
.form-container { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 8px; box-shadow: 0 10px 20px rgba(0,0,0,0.4); max-width: 400px; padding: 2.5rem 2rem; width: 100%; }

/* Header style */
h2 { color: #ffffff; font-size: 1.8rem; font-weight: 600; margin-bottom: 1rem; margin-top: 0; text-align: center; }

/* Instruction text below header */
.instructions { color: #cccccc; line-height: 1.6; margin-bottom: 2rem; text-align: center; }

/* Styling for each label + input group */
.form-group { margin-bottom: 1.5rem; }

label { color: #cccccc; display: block; font-size: 0.9rem; margin-bottom: 0.5rem; }

/* Input fields */
.form-input { background-color: #2c2c2c; border: 1px solid #444; border-radius: 4px; box-sizing: border-box; color: #ffffff; font-size: 1rem; padding: 0.8rem 1rem; transition: border-color 0.3s ease, box-shadow 0.3s ease; width: 100%; }
.form-input::placeholder { color: #888; }
.form-input:focus { border-color: #ffffff; box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1); outline: none; }

/* Submit button */
.submit-button { background-color: #ffffff; border: none; border-radius: 4px; color: #121212; cursor: pointer; font-size: 1rem; font-weight: bold; margin-top: 1rem; padding: 1rem; transition: background-color 0.3s ease; width: 100%; }
.submit-button:hover { background-color: #dddddd; }

/* Link to go back to login */
.extra-links { margin-top: 1.5rem; text-align: center; }
.extra-links a { color: #bbbbbb; font-size: 0.9rem; text-decoration: none; transition: color 0.3s ease; }
.extra-links a:hover { color: #ffffff; text-decoration: underline; }
</style>
