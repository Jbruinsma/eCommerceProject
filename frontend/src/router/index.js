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
import PortfolioPage from '@/views/PortfolioPage.vue'
import AddPortfolioItemPage from '@/views/AddPortfolioItemPage.vue'
import SearchResultsPage from '@/views/SearchResultsPage.vue'
import PlaceBid from '@/views/PlaceBid.vue'
import PlaceOrder from '@/views/PlaceOrder.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { name: 'Home', path: '/', component: HomePage },
    { name: 'Login', path: '/login', component: LoginPage },
    { name: 'Register', path: '/register', component: RegisterPage },
    { name: 'ForgotPassword', path: '/account-recovery', component: ForgotPassword },
    { name: 'SearchResults', path: '/search', component: SearchResultsPage },
    { name: 'Profile', path: '/profile', component: ProfilePage },
    { name: 'Transactions', path: '/transactions', component: TransactionsPage },
    { name: 'Settings', path: '/settings', component: SettingsPage },
    { name: 'product-detail', path: '/product/:id', component: ProductDetail, props: true },
    { name: 'place-order', path: '/place-order/:listingId', component: PlaceOrder },
    { name: 'place-bid', path: '/place-bid/:listingId', component: PlaceBid },
    { name: 'my-listings', path: '/my-listings', component: MyListingsPage },
    { name: 'create-listing', path: '/create-listing', component: CreateListingPage },
    { name: 'listing', path: '/listing/:listingId', component: ListingDetailPage },
    { name: 'Portfolio', path: '/portfolio', component: PortfolioPage },
    { name: 'add-portfolio-item', path: '/portfolio/add', component: AddPortfolioItemPage },
  ],
})

export default router
