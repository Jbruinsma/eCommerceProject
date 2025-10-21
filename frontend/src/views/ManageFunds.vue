<template>
  <div class="manage-funds-container">
    <main class="manage-funds-content">
      <header class="page-header">
        <h1>Manage User Funds</h1>
        <p>Search for a user by ID or email to view and edit their balance.</p>
      </header>

      <section class="card search-card">
        <h2>Find User Account</h2>
        <form @submit.prevent="searchUser" class="search-form">
          <div class="input-group">
            <label for="search-query">User ID or Email</label>
            <input type="text" id="search-query" v-model="searchQuery" placeholder="e.g., 12345 or user@example.com" />
          </div>
          <button type="submit" class="btn btn-primary" :disabled="loading">
            {{ loading ? 'Searching...' : 'Search' }}
          </button>
        </form>
      </section>


      <div v-if="message && messageType === 'error'" :class="['api-message', messageType]">{{ message }}</div>

      <section v-if="user.id" class="card user-details-card">
        <div class="user-info">
          <h2>User Information</h2>
          <p><strong>Name:</strong> {{ user.name }}</p>
          <p><strong>Email:</strong> {{ user.email }}</p>
          <p><strong>User ID:</strong> {{ user.id }}</p>
        </div>
        <div class="balance-info">
          <h2>Current Balance</h2>
          <p class="balance-amount">{{ formatCurrency(user.balance) }}</p>
          <form @submit.prevent="openConfirmationModal" class="modify-balance-form">
            <h3>Modify Balance</h3>
            <div class="input-group">
              <label for="amount">Amount</label>
              <input type="number" id="amount" v-model.number="amountToModify" placeholder="e.g., 50.00" step="0.01" required />
            </div>
            <div class="input-group">
              <label for="reason">Reason for Modification</label>
              <select id="reason" v-model="modificationReason" required>
                <option value="" disabled>Select a reason...</option>
                <option value="sale_proceeds">Sale Proceeds</option>
                <option value="purchase_funds">Purchase Funds</option>
                <option value="refund">Refund</option>
                <option value="fee">Fee</option>
              </select>
            </div>
            <div class="button-group">
              <button type="submit" @click="modificationType = 'add'" class="btn btn-success" :disabled="!amountToModify || !modificationReason">Add to Balance</button>
              <button type="submit" @click="modificationType = 'subtract'" class="btn btn-danger" :disabled="!amountToModify || !modificationReason">Subtract from Balance</button>
            </div>
          </form>
        </div>
      </section>

    </main>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="confirm-text">Confirm Balance Change</h3>
        <p class="confirm-text">{{ confirmationMessage }}</p>
        <p class="confirm-text">This transaction will be tracked.</p>
        <div class="modal-actions">
          <button @click="closeConfirmationModal" class="btn btn-secondary">Cancel</button>
          <button @click="confirmAndUpdateBalance" class="btn btn-success">Confirm</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { fetchFromAPI, postToAPI } from '@/utils/index.js'

// --- Reactive State ---
const searchQuery = ref('');
const loading = ref(false);
const message = ref('');
const messageType = ref('info'); // 'info', 'success', 'error'
const user = ref({}); // Will hold the found user's data
const amountToModify = ref(null);
const modificationType = ref('add'); // 'add' or 'subtract'
const modificationReason = ref(''); // NEW: For the dropdown
const showModal = ref(false);

// --- Methods ---

function formatCurrency(value) {
  const n = Number(value);
  if (Number.isFinite(n)) return `$${n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  return '$0.00';
}

async function searchUser() {
  if (!searchQuery.value) {
    message.value = 'Please enter a User ID or Email.';
    messageType.value = 'error';
    return;
  }
  loading.value = true;
  user.value = {}; // Clear previous user
  message.value = '';

  try {
    const searchResponse = await fetchFromAPI(`/admin/${searchQuery.value}/balance`);
    if (searchResponse && searchResponse.uuid) {
      user.value = {
        id: searchResponse.uuid,
        name: searchResponse.first_name + (searchResponse.last_name ? ' ' + searchResponse.last_name : ''),
        email: searchResponse.email,
        balance: searchResponse.balance,
      };
    } else {
      message.value = 'User not found. Please check the ID or email and try again.';
      messageType.value = 'error';
    }
  } catch (err) {
    message.value = 'An error occurred while searching for the user.';
    messageType.value = 'error';
  }
  loading.value = false;
  searchQuery.value = '';
}

function openConfirmationModal() {
  // MODIFIED: Added check for modificationReason
  if (!amountToModify.value || amountToModify.value <= 0) {
    message.value = 'Please enter a valid, positive amount to modify.';
    messageType.value = 'error';
    return;
  }
  if (!modificationReason.value) {
    message.value = 'Please select a reason for the modification.';
    messageType.value = 'error';
    return;
  }
  showModal.value = true;
}

function closeConfirmationModal() {
  showModal.value = false;
}

async function confirmAndUpdateBalance() {
  loading.value = true;
  closeConfirmationModal();

  const changeAmount = modificationType.value === 'add' ? amountToModify.value : -1 * amountToModify.value;

  const payload = {
    uuid: user.value.id,
    change: changeAmount,
    reason: modificationReason.value
  }

  console.log('Submitting payload:', payload);
  try {

    const modificationResponse = await postToAPI(`/admin/${user.value.uuid}/balance`, {
      uuid: user.value.id,
      change: changeAmount,
      reason: modificationReason.value
    })

    console.log('Modification response:', modificationResponse);

  if (modificationType.value === 'add') {
    user.value.balance += amountToModify.value;
  } else {
    user.value.balance -= amountToModify.value;
  }

    message.value = `Successfully updated ${user.value.name}'s balance. New balance is ${formatCurrency(user.value.balance)}.`;
    messageType.value = 'success';

  } catch (err) {
     message.value = 'Failed to update balance. Please try again.';
     messageType.value = 'error';
  }

  amountToModify.value = null;
  modificationReason.value = '';
  loading.value = false;
}

// --- Computed Properties ---

const confirmationMessage = computed(() => {

  const name = user.value.name ? user.value.name + "'s" : "this user's";
  const action = modificationType.value === 'add' ? 'add' : 'subtract';
  return `Are you sure you want to ${action} ${formatCurrency(amountToModify.value)} ${action === 'add' ? 'to' : 'from'} ${name} account?`;
});

</script>

<style scoped>
/* --- Styles are alphabetized and on a single line --- */
h1,h2,h3 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.8rem; margin-bottom: 0.5rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.5rem; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { font-size: 1.2rem; margin-bottom: 1rem; }
p { color: #cccccc; line-height: 1.6; }
.api-message { border-radius: 8px; font-weight: 600; margin: 2rem 0; padding: 1rem 1.5rem; text-align: center; }
.api-message.error { background: #5a1414; border: 1px solid #3e0b0b; color: #f8d7da; }
.balance-amount { color: #4ade80; font-size: 2.5rem; font-weight: 700; margin-bottom: 2rem; text-align: center; }
.balance-info { flex: 1; min-width: 300px; }
.btn { border: none; border-radius: 8px; cursor: pointer; font-family: inherit; font-size: 1rem; font-weight: 600; padding: 0.75rem 1.5rem; transition: all 0.2s ease-in-out; }
.btn-danger { background-color: #5a1414; border: 1px solid #842029; color: #f8d7da; }
.btn-danger:hover { background-color: #842029; }
.btn-primary { background-color: #333; border: 1px solid #555; color: #ffffff; }
.btn-primary:hover { background-color: #444; border-color: #666; }
.btn-secondary { background-color: #4a4a4a; border: 1px solid #666; color: #e0e0e0; }
.btn-secondary:hover { background-color: #5a5a5a; }
.btn-success { background-color: #1a5e3a; border: 1px solid #2a7e4a; color: #e0ffe0; }
.btn-success:hover { background-color: #2a7e4a; border-color: #3cb063; }
.btn:disabled { cursor: not-allowed; opacity: 0.6; }
.button-group { display: flex; gap: 1rem; justify-content: center; }
.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin-bottom: 2rem; padding: 2rem; }
.confirm-text { text-align: center; }
.input-group { display: flex; flex-direction: column; margin-bottom: 1.5rem; }
.input-group input, .input-group select { background-color: #252525; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem; } /* MODIFIED */
.input-group label { color: #aaa; font-size: 0.9rem; margin-bottom: 0.5rem; }
.manage-funds-container { color: #ffffff; }
.manage-funds-content { margin: 0 auto; max-width: 900px; padding: 4rem 5%; }
.modal-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; }
.modal-content { background-color: #1a1a1a; border: 1px solid #333; border-radius: 12px; max-width: 500px; padding: 2rem; width: 90%; }
.modal-overlay { align-items: center; background-color: rgba(0, 0, 0, 0.7); display: flex; height: 100%; justify-content: center; left: 0; position: fixed; top: 0; width: 100%; z-index: 1000; }
.modify-balance-form h3 { text-align: center; }
.page-header { margin-bottom: 3rem; text-align: center; }
.page-header p { color: #888; font-size: 1.1rem; }
.search-form { align-items: flex-end; display: flex; gap: 1rem; }
.search-form .input-group { flex-grow: 1; margin-bottom: 0; }
.user-details-card { display: flex; flex-wrap: wrap; gap: 2rem; }
.user-info { flex: 1; min-width: 300px; }
.user-info p { margin-bottom: 0.75rem; }
</style>
