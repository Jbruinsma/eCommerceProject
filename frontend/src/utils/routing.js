import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'

export async function redirectToProfile() {
  const authStore = useAuthStore()
  if (authStore.isLoggedIn) await router.push('/profile')
  else await router.push('/login')
}

export async function redirectToOrders() {
  const authStore = useAuthStore()
  if (authStore.isLoggedIn) await router.push('/orders')
  else await router.push('/login')
}

export async function redirectToAdminDashboard() {
  const authStore = useAuthStore()
  if (authStore.isLoggedIn && authStore.role === 'admin') await router.push('/admin')
  else await router.push('/login')
}
