import { useAuthStore } from '@/stores/authStore.js'
import router from '@/router/index.js'

export async function authenticateUser(email, uuid, role){
  const authStore = useAuthStore();
  await authStore.login({
    email: email,
    uuid: uuid,
    role: role,
  })
}


export async function authenticateAdmin(){
  const authStore = useAuthStore();
  if ((!authStore.isLoggedIn) || authStore.role !== 'admin') { await router.push('/login'); }
}
