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
import OrdersPage from '@/views/OrdersPage.vue'
import AdminDashboard from '@/views/AdminDashboard.vue'
import ManageFunds from '@/views/ManageFunds.vue'
import BidsPage from '@/views/BidsPage.vue'
import OrderDetailPage from '@/views/OrderDetailPage.vue'
import ManageUsers from "@/views/ManageUsers.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { name: 'Home', path: '/', component: HomePage },
    { name: 'AdminDashboard', path: '/admin', component: AdminDashboard },
    { name: 'ManageFunds', path: '/admin/funds', component: ManageFunds },
    { name: 'ManageUsers', path: '/admin/users', component: ManageUsers },
    { name: 'Login', path: '/login', component: LoginPage },
    { name: 'Register', path: '/register', component: RegisterPage },
    { name: 'ForgotPassword', path: '/account-recovery', component: ForgotPassword },
    { name: 'SearchResults', path: '/search', component: SearchResultsPage },
    { name: 'Profile', path: '/profile', component: ProfilePage },
    { name: 'Transactions', path: '/transactions', component: TransactionsPage },
    { name: 'Settings', path: '/settings', component: SettingsPage },
    { name: 'Bids', path: '/bids', component: BidsPage },
    { name: 'Orders', path: '/orders', component: OrdersPage },
    { name: 'OrderDetails', path: '/orders/:orderId', component: OrderDetailPage },
    { name: 'ProductDetail', path: '/product/:id', component: ProductDetail, props: true },
    { name: 'PlaceOrder', path: '/place-order/:listingId', component: PlaceOrder },
    { name: 'PlaceBid', path: '/place-bid/:listingId', component: PlaceBid },
    { name: 'MyListings', path: '/my-listings', component: MyListingsPage },
    { name: 'CreateListing', path: '/create-listing', component: CreateListingPage },
    { name: 'Listing', path: '/listing/:listingId', component: ListingDetailPage },
    { name: 'Portfolio', path: '/portfolio', component: PortfolioPage },
    { name: 'AddPortfolioItem', path: '/portfolio/add', component: AddPortfolioItemPage },
  ],
})

export default router
