import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    isLoggedIn: false,
    uuid: null,
    email: null,
  }),
  actions: {

    login(userData) {
      this.isLoggedIn = true;
      this.uuid = userData.uuid;
      this.email = userData.email;

      console.log("Login Successful")
    },

    logout() {
      this.isLoggedIn = false;
      this.uuid = null;
      this.email = null;
    },
  },
  persist: true,
});
