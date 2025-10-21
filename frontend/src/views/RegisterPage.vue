<template>
  <div class="register-container">
    <div class="register-form-container">
      <h2>Create Your Account</h2>

      <!-- Success and error banners -->
      <div v-if="successMessage" class="message-banner success">{{ successMessage }}</div>
      <div v-if="errorMessage" class="message-banner error">{{ errorMessage }}</div>

      <form @submit.prevent="handleRegister">
        <div class="form-group">
          <label for="email">Email Address</label>
          <input
            id="email"
            type="email"
            class="form-input"
            v-model="email"
            placeholder="you@example.com"
            required
          />
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
          />
        </div>
        <div class="form-group">
          <label for="confirm-password">Confirm Password</label>
          <input
            id="confirm-password"
            type="password"
            class="form-input"
            v-model="confirmPassword"
            placeholder="••••••••"
            required
          />
        </div>
        <button :disabled="loading" type="submit" class="submit-button">
          {{ loading ? 'Creating...' : 'Create Account' }}
        </button>
      </form>
      <div class="extra-links">
        <a href="/login">Back to Login</a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { postToAPI } from '@/utils/index.js'
import router from '@/router/index.js'
import { authenticateUser } from '@/utils/authenticateUser.js'
import { useAuthStore } from '@/stores/authStore.js'

const email = ref('')
const password = ref('')
const confirmPassword = ref('')

const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const authStore = useAuthStore()

const clearMessages = (timeout = 5000) => {
  if (timeout <= 0) return
  setTimeout(() => {
    errorMessage.value = ''
    successMessage.value = ''
  }, timeout)
}

onMounted(async () => {
  if (authStore.isLoggedIn){
    authStore.logout()
  }
})

const handleRegister = async () => {
  errorMessage.value = ''
  successMessage.value = ''

  if (password.value !== confirmPassword.value) {
    errorMessage.value = 'Passwords do not match.'
    clearMessages()
    return
  }

  loading.value = true
  try {
    const registrationResponse = await postToAPI('/auth/register', {
      email: email.value,
      password: password.value,
      password_confirmation: confirmPassword.value,
    })

    successMessage.value =
      (registrationResponse && (registrationResponse.message || registrationResponse.detail)) ||
      'Registration successful.'
    email.value = ''
    password.value = ''
    confirmPassword.value = ''

    clearMessages()

    const userData = registrationResponse.extra

    try {
      await authenticateUser(userData.email, userData.uuid, userData.role)
    } catch (err) {
      console.error('Error authenticating user:', err)
      errorMessage.value = 'Failed to authenticate user.'
      clearMessages()
      return
    }
    await router.push('/')
  } catch (err) {
    errorMessage.value =
      (err && err.data && (err.data.message || err.data.detail)) ||
      err.message ||
      'An unexpected error occurred.'
    clearMessages()
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* Main container to center the form on the page */
.register-container {
  align-items: center;
  background-color: #121212;
  display: flex;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  justify-content: center;
  min-height: 100vh;
  padding: 2rem;
}

/* The form card itself, styled like your product cards */
.register-form-container {
  background-color: #1a1a1a;
  border: 1px solid #2a2a2a;
  border-radius: 8px;
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.4);
  max-width: 400px;
  padding: 2.5rem 2rem;
  width: 100%;
}

/* Header style consistent with the homepage */
h2 {
  color: #ffffff;
  font-size: 1.8rem;
  font-weight: 600;
  margin-bottom: 2rem;
  margin-top: 0;
  text-align: center;
}

/* Message banners */
.message-banner {
  text-align: center;
  border-radius: 6px;
  padding: 0.75rem 1rem;
  margin-bottom: 1rem;
  font-size: 0.95rem;
}
.message-banner.success {
  background-color: #113322;
  color: #b7f2c1;
  border: 1px solid #225533;
}
.message-banner.error {
  background-color: #3b1212;
  color: #ffd1d1;
  border: 1px solid #7a1b1b;
}

/* Styling for each label + input group */
.form-group {
  margin-bottom: 1.5rem;
}

label {
  color: #cccccc;
  display: block;
  font-size: 0.9rem;
  margin-bottom: 0.5rem;
}

/* Input fields styled to match the dark theme */
.form-input {
  background-color: #2c2c2c;
  border: 1px solid #444;
  border-radius: 4px;
  box-sizing: border-box;
  color: #ffffff;
  font-size: 1rem;
  padding: 0.8rem 1rem;
  transition:
    border-color 0.3s ease,
    box-shadow 0.3s ease;
  width: 100%;
}
.form-input::placeholder {
  color: #888;
}
.form-input:focus {
  border-color: #ffffff;
  box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
  outline: none;
}

/* Login button, styled like your "Shop Now" button */
.submit-button {
  background-color: #ffffff;
  border: none;
  border-radius: 4px;
  color: #121212;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
  margin-top: 1rem;
  padding: 1rem;
  transition: background-color 0.3s ease;
  width: 100%;
}
.submit-button:hover {
  background-color: #dddddd;
}
.submit-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Container for "Forgot Password" and "Create Account" links */
.extra-links {
  margin-top: 1.5rem;
  text-align: center;
}
.extra-links a {
  color: #bbbbbb;
  font-size: 0.9rem;
  text-decoration: none;
  transition: color 0.3s ease;
}
.extra-links a:hover {
  color: #ffffff;
  text-decoration: underline;
}
</style>
