import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '@/views/HomePage.vue'
import LoginPage from '@/views/LoginPage.vue'
import RegisterPage from '@/views/RegisterPage.vue'
import ForgotPassword from '@/views/ForgotPassword.vue'
import ProfilePage from '@/views/ProfilePage.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { name: 'Home', path: '/', component: HomePage },
    { name: 'Login', path: '/login', component: LoginPage },
    { name: 'Register', path: '/register', component: RegisterPage },
    { name: 'ForgotPassword', path: '/account-recovery', component: ForgotPassword },
    { name: 'Profile', path: '/profile', component: ProfilePage }
  ],
})

export default router
