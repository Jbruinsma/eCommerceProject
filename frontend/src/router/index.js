import { createRouter, createWebHistory } from 'vue-router'
import HomePage from '@/views/HomePage.vue'
import LoginPage from '@/views/LoginPage.vue'
import RegisterPage from '@/views/RegisterPage.vue'
import ForgotPassword from '@/views/ForgotPassword.vue'
import ProfilePage from '@/views/ProfilePage.vue'
import TransactionsPage from '@/views/TransactionsPage.vue'
import SettingsPage from '@/views/SettingsPage.vue'
import ProductDetail from '@/views/ProductDetail.vue'
import MyListingsPage from '@/views/MyListingsPage.vue'
import ListingDetailPage from '@/views/ListingDetailPage.vue'
import CreateListingPage from '@/views/CreateListingPage.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { name: 'Home', path: '/', component: HomePage },
    { name: 'Login', path: '/login', component: LoginPage },
    { name: 'Register', path: '/register', component: RegisterPage },
    { name: 'ForgotPassword', path: '/account-recovery', component: ForgotPassword },
    { name: 'Profile', path: '/profile', component: ProfilePage },
    { name: 'Transactions', path: '/transactions', component: TransactionsPage },
    { name: 'Settings', path: '/settings', component: SettingsPage },
    { name: 'product-detail', path: '/product/:id', component: ProductDetail, props: true },
    { name: 'my-listings', path: '/my-listings', component: MyListingsPage },
    { name: 'create-listing', path: '/create-listing', component: CreateListingPage },
    { name: 'listing', path: '/listing/:listingId', component: ListingDetailPage }
  ],
})

export default router
