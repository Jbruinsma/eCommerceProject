import { useAuthStore } from '@/stores/authStore.js'

export async function authenticateUser(email, uuid, role){
  const authStore = useAuthStore();
  await authStore.login({
    email: email,
    uuid: uuid,
    role: role,
  })
}
