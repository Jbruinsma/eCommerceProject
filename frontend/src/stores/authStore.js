import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    isLoggedIn: false,
    uuid: null,
    email: null,
  }),
  actions: {

    login(userData) {

      const { uuid, email, role } = userData;

      if (!uuid || !email || !(role === 'admin' || role === 'user')) {
        throw new Error(`Invalid user data: ${uuid}, ${email}, ${role}`);
      }

      this.isLoggedIn = true;
      this.uuid = uuid;
      this.email = email;
      this.role = role;

      console.log(`Logged in: ${uuid}, ${email}, ${role}`)
    },

    logout() {
      this.isLoggedIn = false;
      this.uuid = null;
      this.email = null;
      this.role = null;

      console.log('Logged out')
    },
  },
  persist: true,
});
