import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'

export async function navigateWithAuth(targetRoute, authCheck = null) {
  const authStore = useAuthStore()

  const isAuthorized = authCheck
    ? authCheck(authStore)
    : authStore.isLoggedIn

  if (isAuthorized) {
    await router.push(targetRoute)
  } else {
    const redirectPath = router.resolve(targetRoute).href
    await router.push({ name: 'Login', query: { redirect: redirectPath } })
  }
}

export function redirectToProfile() {
  return navigateWithAuth('/profile')
}

export function redirectToOrders() {
  return navigateWithAuth('/orders')
}

export function redirectToBuyPage(listingId, size, condition) {
  const targetRoute = {
    name: 'PlaceOrder',
    params: { listingId: listingId },
    query: { size: size, condition: condition },
  }
  return navigateWithAuth(targetRoute)
}

export function redirectToBidPage(listingId, size, condition) {
  const targetRoute = {
    name: 'PlaceBid',
    params: { listingId: listingId },
    query: { size: size, condition: condition },
  }
  return navigateWithAuth(targetRoute)
}

export function redirectToAdminDashboard() {
  const adminCheck = (store) => store.isLoggedIn && store.role === 'admin'
  return navigateWithAuth('/admin', adminCheck)
}
