<template>
  <div class="manage-users-container">
    <div v-if="message" :class="['api-message', messageType]">{{ message }}</div>

    <main class="manage-users-content">
      <header class="page-header">
        <h1>Manage Users & Roles</h1>
        <p>Search for a user by ID or email to view and edit their details.</p>
      </header>

      <section class="card search-card">
        <h2>Find User Account</h2>
        <form @submit.prevent="searchUser" class="search-form">
          <div class="input-group">
            <label for="search-query">User ID or Email</label>
            <input
              type="text"
              id="search-query"
              v-model="searchQuery"
              placeholder="e.g., user@example.com or UUID"
            />
          </div>
          <button type="submit" class="btn btn-primary" :disabled="loading">
            {{ loading ? 'Searching...' : 'Search' }}
          </button>
        </form>
      </section>

      <form v-if="user.uuid" @submit.prevent="openConfirm('save')" class="settings-form">
        <div class="form-section">
          <div class="form-header">
            <h3>User Information</h3>
            <span class="user-id">UUID: {{ user.uuid }}</span>
          </div>

          <div class="form-grid">
            <div class="form-group">
              <label for="first_name">First Name</label>
              <input type="text" id="first_name" v-model="user.first_name" placeholder="First name" />
              <div class="field-error" v-if="errors.first_name">{{ errors.first_name }}</div>
            </div>

            <div class="form-group">
              <label for="last_name">Last Name</label>
              <input type="text" id="last_name" v-model="user.last_name" placeholder="Last name" />
              <div class="field-error" v-if="errors.last_name">{{ errors.last_name }}</div>
            </div>

            <div class="form-group">
              <label for="email">Email Address</label>
              <input type="email" id="email" v-model="user.email" placeholder="user@example.com" />
              <div class="field-error" v-if="errors.email">{{ errors.email }}</div>
            </div>

            <div class="form-group">
              <label for="location">Location</label>
              <input type="text" id="location" v-model="user.location" placeholder="New York, NY" />
              <div class="field-error" v-if="errors.location">{{ errors.location }}</div>
            </div>

            <div class="form-group">
              <label for="birth_date">Birth Date</label>
              <input type="date" id="birth_date" v-model="user.birth_date" />
              <div class="field-error" v-if="errors.birth_date">{{ errors.birth_date }}</div>
            </div>

            <div class="form-group">
              <label for="role">User Role</label>
              <select id="role" v-model="user.role">
                <option value="user">User</option>
                <option value="admin">Admin</option>
              </select>
              <div class="field-error" v-if="errors.role">{{ errors.role }}</div>
            </div>
          </div>
        </div>

        <div class="form-section info-section">
          <h3>Account Details</h3>
          <div class="info-grid">
            <div class="info-item">
              <strong>Created At:</strong>
              <span>{{ formatTimestamp(user.created_at) }}</span>
            </div>
            <div class="info-item">
              <strong>Last Updated:</strong>
              <span>{{ formatTimestamp(user.updated_at) }}</span>
            </div>
            <div class="info-item balance-item">
              <strong>Account Balance:</strong>
              <span :class="balanceClass">{{ formatCurrency(user.balance) }}</span>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" class="btn-funds" @click="goToManageFunds">Manage Funds</button>
          <div class="spacer"></div>
          <button type="button" class="btn-secondary" @click="openConfirm('cancel')">Cancel</button>
          <button type="submit" class="btn-primary">Save Changes</button>
        </div>
      </form>
    </main>

    <div v-if="modalVisible" class="modal-overlay" @click.self="closeModal()">
      <div class="modal">
        <h3>{{ modalTitle }}</h3>
        <p>{{ modalMessage }}</p>
        <div class="modal-actions">
          <button class="btn-secondary" @click="closeModal">Back</button>
          <button class="btn-primary" @click="confirmModal" :disabled="modalProcessing">
            Confirm
          </button>
        </div>
      </div>
    </div>

    <div aria-hidden="true" style="position: absolute; width:1px; height:1px; overflow:hidden; clip:rect(0 0 0 0);">
      <span class="balance-positive" style="display:none;"></span>
      <span class="balance-negative" style="display:none;"></span>
      <span class="balance-zero" style="display:none;"></span>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import router from '@/router/index.js'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'

const searchQuery = ref('');
const loading = ref(false);
const message = ref('');
const messageType = ref('');

const user = ref({});
const errors = ref({});
let originalUser = {};

function formatTimestamp(dateStr) {
  if (!dateStr) return 'N/A';
  const d = new Date(dateStr);
  if (Number.isNaN(d.getTime())) return dateStr;
  return d.toLocaleString();
}

function formatCurrency(value) {
  const n = Number(value);
  if (!Number.isFinite(n)) return '$0.00';
  const abs = Math.abs(n);
  const formatted = abs.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  return n < 0 ? `-$${formatted}` : `$${formatted}`;
}

const balanceClass = computed(() => {
  const n = Number(user.value.balance);
  if (!Number.isFinite(n) || n === 0) return 'balance-zero';
  return n < 0 ? 'balance-negative' : 'balance-positive';
});

async function searchUser() {
  if (!searchQuery.value) {
    message.value = 'Please enter a User ID or Email.';
    messageType.value = 'error';
    return;
  }
  loading.value = true;
  user.value = {};
  message.value = '';
  errors.value = {};

  try {
    const searchResponse = await fetchFromAPI(`/admin/users/${searchQuery.value}`);

    user.value = searchResponse;
    originalUser = JSON.parse(JSON.stringify(searchResponse));
    message.value = 'User found. You may now edit their details.';
    messageType.value = 'success';

  } catch (err) {
    console.error('Error searching user:', err);
    user.value = {};
    message.value = err?.data?.message || 'User not found or an error occurred.';
    messageType.value = 'error';
  }

  loading.value = false;
  if (messageType.value === 'success') {
    setTimeout(() => { message.value = ''; messageType.value = '' }, 3000);
  }
}

const modalVisible = ref(false);
const modalAction = ref('');
const modalProcessing = ref(false);

const openConfirm = (action) => {
  modalAction.value = action;
  modalVisible.value = true;
};

const closeModal = () => {
  modalVisible.value = false;
  modalProcessing.value = false;
};

const modalTitle = computed(() =>
  modalAction.value === 'save' ? 'Confirm Save' : 'Discard Changes?',
);

const modalMessage = computed(() =>
  modalAction.value === 'save'
    ? "Are you sure you want to save these changes? This will update the user's account."
    : 'Are you sure you want to discard your changes? Any unsaved edits will be lost.',
);

const confirmModal = async () => {
  modalProcessing.value = true;
  if (modalAction.value === 'save') {
    await handleSaveChangesConfirmed();
  } else if (modalAction.value === 'cancel') {
    handleCancelConfirmed();
  }
  closeModal();
};

async function handleSaveChangesConfirmed() {
  modalProcessing.value = true;
  errors.value = {};
  message.value = '';

  try {
    const payload = { ...user.value };
    delete payload.balance;

    const response = await postToAPI(`/admin/users/${user.value.uuid}/`, payload);

    user.value = response;
    if (typeof response.balance === 'undefined') {
      response.balance = originalUser.balance;
    }

    originalUser = JSON.parse(JSON.stringify(response));

    message.value = "User details saved successfully.";
    messageType.value = 'success';

  } catch (err) {
    errors.value = {};
    if (err && err.data && Array.isArray(err.data.detail)) {
      err.data.detail.forEach((d) => {
        const field = d.loc && d.loc.length > 1 ? d.loc[1] : 'body';
        errors.value[field] = d.msg;
      });
      message.value = 'Please fix the highlighted fields.';
      messageType.value = 'error';
    } else {
      message.value = err?.data?.message || 'Failed to save settings.';
      messageType.value = 'error';
    }
  } finally {
    modalProcessing.value = false;
    setTimeout(() => { if (messageType.value === 'success') { message.value = ''; } }, 3000);
  }
}

function handleCancelConfirmed() {
  user.value = JSON.parse(JSON.stringify(originalUser));
  errors.value = {};
  message.value = 'Changes discarded.';
  messageType.value = 'info';
  setTimeout(() => { message.value = ''; messageType.value = '' }, 2000);
}

function goToManageFunds() {
  if (!user.value.uuid) return;
  router.push(`/admin/funds?search=${encodeURIComponent(user.value.email || user.value.uuid)}`);
}
</script>

<style scoped>
h1, h2, h3 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.8rem; margin-bottom: 0.5rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.5rem; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { color: #ffffff; font-size: 1.2rem; margin-bottom: 1.5rem; }
p { color: #cccccc; line-height: 1.6; }
.manage-users-container { color: #ffffff; }
.manage-users-content { margin: 0 auto; max-width: 900px; padding: 4rem 5%; }
.page-header { margin-bottom: 3rem; text-align: center; }
.page-header p { color: #888; font-size: 1.1rem; }

.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin-bottom: 2rem; padding: 2rem; }
.search-form { align-items: flex-end; display: flex; gap: 1rem; }
.search-form .input-group { flex-grow: 1; margin-bottom: 0; }

.settings-form { display: flex; flex-direction: column; gap: 2rem; }
.form-section { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.form-grid { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.form-group { display: flex; flex-direction: column; }
.form-header { align-items: flex-start; border-bottom: 1px solid #333; display: flex; justify-content: space-between; margin-bottom: 1.5rem; padding-bottom: 1rem; }
.form-header h3 { margin-bottom: 0; }
.user-id { background-color: #2c2c2c; border: 1px solid #444; border-radius: 6px; color: #aaa; font-family: monospace; font-size: 0.8rem; padding: 0.25rem 0.5rem; }
.form-actions { align-items: center; display: flex; gap: 1rem; justify-content: flex-start; margin-top: 1rem; }
.spacer { flex-grow: 1; }

.info-section h3 { border-bottom: 1px solid #333; padding-bottom: 1rem; }
.info-grid { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.info-item { display: flex; flex-direction: column; gap: 0.25rem; }
.info-item strong { color: #888; font-size: 0.9rem; }
.info-item span { color: #ccc; font-size: 1rem; }
.balance-item span { font-size: 1.1rem; font-weight: 600; }
.balance-negative { color: #f06e6e; }
.balance-positive { color: #4ade80; }
.balance-zero { color: #ffffff; }

input[type='text'], input[type='email'], input[type='date'], input[type='password'], select { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-family: inherit; font-size: 1rem; padding: 0.75rem; transition: border-color 0.3s ease; }
input[type='text']:focus, input[type='email']:focus, input[type='date']:focus, input[type='password']:focus, select:focus { border-color: #ffffff; outline: none; }
label { display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.5rem; }

.btn-primary, .btn-secondary, .btn-funds { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-primary:hover { background-color: #cccccc; }
.btn-primary:disabled { background-color: #555; color: #999; cursor: not-allowed; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.btn-secondary:hover { background-color: #383838; border-color: #666; }
.btn-funds { background-color: #1a5e3a; border-color: #2a7e4a; color: #e0ffe0; }
.btn-funds:hover { background-color: #2a7e4a; border-color: #3cb063; }

.modal-overlay { align-items: center; background: rgba(0,0,0,0.6); display: flex; inset: 0; justify-content: center; position: fixed; z-index: 1000; }
.modal { background: #0f0f0f; border: 1px solid #2a2a2a; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.6); max-width: 520px; padding: 1.5rem; width: 92%; }
.modal h3 { color: #fff; margin-top: 0; }
.modal p { color: #ccc; margin-bottom: 1.5rem; }
.modal-actions { display: flex; gap: 1rem; justify-content: flex-end; }
.modal .btn-primary:disabled { background-color: #555; color: #999; }

.api-message { border-radius: 8px; font-weight: 600; margin: 0 auto 2rem auto; max-width: 900px; padding: 1rem 1.5rem; text-align: center; }
.api-message.success { background: #0f5132; border: 1px solid #0b2f1f; color: #d1e7dd; }
.api-message.error { background: #5a1414; border: 1px solid #3e0b0b; color: #f8d7da; }
.api-message.info { background: #0c5460; border: 1px solid #0a424a; color: #d1ecf1; }

.field-error { color: #ffb3b3; font-size: 0.85rem; margin-top: 0.4rem; }

@media (max-width: 640px) {
  .search-form { align-items: stretch; flex-direction: column; gap: 1rem; }
  .info-grid { grid-template-columns: 1fr; }
  .form-actions { flex-wrap: wrap; }
  .spacer { display: none; }
}
</style>

