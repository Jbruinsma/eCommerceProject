import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    isLoggedIn: false,
    uuid: null,
    email: null,
  }),
  actions: {

    login(userData) {

      const uuid = userData.uuid;
      const email = userData.email;
      const role = userData.role;

      if (!uuid || !email || !(role in {admin: 1, user: 1})) {
        throw new Error('Invalid user data');
      }

      this.isLoggedIn = true;
      this.uuid = uuid;
      this.email = email;
      this.role = role;
    },

    logout() {
      this.isLoggedIn = false;
      this.uuid = null;
      this.email = null;
    },
  },
  persist: true,
});
