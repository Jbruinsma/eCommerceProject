<template>
  <div class="manage-funds-container">
    <main class="manage-funds-content">
      <header class="page-header">
        <h1>Manage User Funds</h1>
        <p>Search for a user by ID or email to view and edit their balance.</p>
      </header>

      <UserSearch
        title="Find User Account"
        v-model="searchQuery"
        :loading="loading"
        @submit="searchUser"
      />

      <div v-if="message && messageType === 'error'" :class="['api-message', messageType]">
        {{ message }}
      </div>

      <section v-if="user.id" class="card user-details-card">
        <div class="user-info">
          <h2>User Information</h2>
          <p><strong>Name:</strong> {{ user.name }}</p>
          <p><strong>Email:</strong> {{ user.email }}</p>
          <p><strong>User ID:</strong> {{ user.id }}</p>
        </div>
        <div class="balance-info">
          <h2>Current Balance</h2>
          <p :class="['balance-amount', balanceClass]">{{ formatCurrency(user.balance) }}</p>
          <div v-if="lastTransaction" class="card" style="margin-top: 1rem; padding: 1rem">
            <h3 style="margin-bottom: 0.5rem">Last Transaction</h3>
            <p style="margin: 0.25rem 0">
              <strong>ID:</strong> {{ lastTransaction.transaction_id }}
            </p>
            <p style="margin: 0.25rem 0">
              <strong>Amount:</strong> {{ formatCurrency(lastTransaction.amount) }}
            </p>
            <p style="margin: 0.25rem 0">
              <strong>Status:</strong> {{ lastTransaction.transaction_status }}
            </p>
            <p style="margin: 0.25rem 0">
              <strong>Purpose:</strong> {{ lastTransaction.payment_purpose }}
            </p>
            <p style="margin: 0.25rem 0">
              <strong>Created:</strong> {{ lastTransaction.created_at }}
            </p>
          </div>
          <form @submit.prevent="openConfirmationModal" class="modify-balance-form">
            <h3>Modify Balance</h3>
            <div class="input-group">
              <label for="amount">Amount (use a negative value to subtract)</label>
              <input
                type="text"
                id="amount"
                v-model="amountToModify"
                @input="handleAmountInput"
                placeholder="e.g., 50.00 or -25.50"
                required
              />
            </div>
            <div class="input-group">
              <label for="reason">Reason for Modification</label>
              <select id="reason" v-model="modificationReason" required>
                <option value="" disabled>Select a reason...</option>
                <option value="sale_proceeds">Sale Proceeds</option>
                <option value="purchase_funds">Purchase Funds</option>
                <option value="refund">Refund</option>
                <option value="fee">Fee</option>
                <option value="balance_adjustment">Balance Adjustment</option>
              </select>
            </div>
            <div class="button-group">
              <button
                type="submit"
                class="btn btn-primary"
                :disabled="
                  !amountToModify || parseFloat(amountToModify) === 0 || !modificationReason
                "
              >
                Preview Balance Change
              </button>
            </div>
          </form>
        </div>
      </section>
    </main>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="confirm-text">Confirm Balance Change</h3>
        <div class="confirmation-details">
          <p><strong>User:</strong> {{ user.email }}</p>
          <p>
            <strong>Action:</strong>
            <span :class="actionText.toLowerCase()"
            >{{ actionText }} {{ formatCurrency(Math.abs(amountToModify)) }}</span
            >
          </p>
          <p><strong>Reason:</strong> {{ formattedReason }}</p>
          <hr />
          <p><strong>Old Balance:</strong> {{ formatCurrency(user.balance) }}</p>
          <p><strong>New Balance:</strong> {{ formatCurrency(newBalancePreview) }}</p>
        </div>
        <div class="modal-actions">
          <button @click="closeConfirmationModal" class="btn btn-secondary">Cancel</button>
          <button @click="confirmAndUpdateBalance" class="btn btn-success">Confirm & Submit</button>
        </div>
      </div>
    </div>

    <div
      aria-hidden="true"
      style="position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0)"
    >
      <span class="add" style="display: none"></span>
      <span class="subtract" style="display: none"></span>
      <div class="api-message error" style="display: none"></div>
      <button class="btn btn-danger" style="display: none"></button>
      <span class="balance-positive" style="display: none"></span>
      <span class="balance-negative" style="display: none"></span>
      <span class="balance-zero" style="display: none"></span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'
import { authenticateAdmin } from '@/utils/authenticateUser.js'
// UPDATED: Import the new component
import UserSearch from '@/components/UserSearch.vue'

const searchQuery = ref('')
const loading = ref(false)
const message = ref('')
const messageType = ref('info')
const user = ref({})
const amountToModify = ref('')
const modificationReason = ref('')
const showModal = ref(false)
const lastTransaction = ref(null)

onMounted( async() => {
  await authenticateAdmin();
})

function formatCurrency(value) {
  const n = Number(value)
  if (!Number.isFinite(n)) return '$0.00'
  const abs = Math.abs(n)
  const formatted = abs.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
  return n < 0 ? `-$${formatted}` : `$${formatted}`
}

const balanceClass = computed(() => {
  const n = Number(user.value.balance)
  if (!Number.isFinite(n) || n === 0) return 'balance-zero'
  return n < 0 ? 'balance-negative' : 'balance-positive'
})

function handleAmountInput(event) {
  let value = event.target.value
  value = value.replace(/[^-?\d.]/g, '')
  value = value.replace(/(\..*)\./g, '$1').replace(/(?!^)-/g, '')
  const parts = value.split('.')
  if (parts[1] && parts[1].length > 2) {
    parts[1] = parts[1].substring(0, 2)
    value = parts.join('.')
  }
  amountToModify.value = value
}

async function searchUser() {
  if (!searchQuery.value) {
    message.value = 'Please enter a User ID or Email.'
    messageType.value = 'error'
    return
  }
  loading.value = true
  user.value = {}
  message.value = ''
  lastTransaction.value = null

  try {
    const searchResponse = await fetchFromAPI(`/admin/${searchQuery.value}/balance`)
    if (searchResponse && searchResponse.uuid) {
      user.value = {
        id: searchResponse.uuid,
        name:
          searchResponse.first_name +
          (searchResponse.last_name ? ' ' + searchResponse.last_name : ''),
        email: searchResponse.email,
        balance: searchResponse.balance,
      }
    } else {
      message.value = 'User not found.'
      messageType.value = 'error'
    }
  } catch (err) {
    console.error('Error searching user:', err)
    message.value = 'An error occurred while searching for the user.'
    messageType.value = 'error'
  }
  loading.value = false
  searchQuery.value = '' // This was in your original, keeps the search bar clean
}

function openConfirmationModal() {
  const amount = parseFloat(amountToModify.value)
  if (isNaN(amount) || amount === 0) {
    message.value = 'Please enter a valid, non-zero amount to modify.'
    messageType.value = 'error'
    return
  }
  if (!modificationReason.value) {
    message.value = 'Please select a reason for the modification.'
    messageType.value = 'error'
    return
  }
  showModal.value = true
}

function closeConfirmationModal() {
  showModal.value = false
}

async function confirmAndUpdateBalance() {
  loading.value = true
  closeConfirmationModal()

  const changeAmount = parseFloat(amountToModify.value)

  try {
    const modificationResponse = await postToAPI(`/admin/${user.value.id}/balance`, {
      uuid: user.value.id,
      change: changeAmount,
      reason: modificationReason.value,
    })

    if (modificationResponse && typeof modificationResponse.newBalance !== 'undefined') {
      user.value.balance = modificationResponse.newBalance
      lastTransaction.value = modificationResponse.transaction || null
      message.value = `Successfully updated ${user.value.name}'s balance.`
      messageType.value = 'success'
    }
  } catch (err) {
    console.error('Error updating balance:', err)
    message.value = err?.data?.message || 'Failed to update balance. Please try again.'
    messageType.value = 'error'
  }

  amountToModify.value = ''
  modificationReason.value = ''
  loading.value = false
}

const actionText = computed(() => (parseFloat(amountToModify.value) > 0 ? 'Add' : 'Subtract'))
const newBalancePreview = computed(() => {
  const current = Number(user.value.balance) || 0
  const change = parseFloat(amountToModify.value || 0)
  if (!Number.isFinite(current) || !Number.isFinite(change)) return current
  return current + change
})
const formattedReason = computed(() => {
  if (!modificationReason.value) return ''
  return modificationReason.value.replace(/_/g, ' ').replace(/\b\w/g, (l) => l.toUpperCase())
})
</script>

<style scoped>
h1, h2, h3 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
h1 { font-size: 2.8rem; margin-bottom: 0.5rem; }
h2 { border-bottom: 1px solid #333; font-size: 1.5rem; margin-bottom: 1.5rem; padding-bottom: 1rem; }
h3 { font-size: 1.2rem; margin-bottom: 1rem; }
hr { border-color: #333; border-style: solid; border-width: 1px 0 0 0; margin: 1rem 0; }
p { color: #cccccc; line-height: 1.6; }
.add { color: #4ade80; font-weight: 600; }
.api-message { border-radius: 8px; font-weight: 600; margin: 2rem 0; padding: 1rem 1.5rem; text-align: center; }
.api-message.error { background: #5a1414; border: 1px solid #3e0b0b; color: #f8d7da; }
.balance-amount { color: #4ade80; font-size: 2.5rem; font-weight: 700; margin-bottom: 2rem; text-align: center; }
.balance-info { flex: 1; min-width: 300px; }
.balance-negative { color: #f06e6e; }
.balance-positive { color: #4ade80; }
.balance-zero { color: #ffffff; }
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
.confirmation-details { margin-top: 1.5rem; }
.confirmation-details p { margin: 0.5rem 0; }
.input-group { display: flex; flex-direction: column; margin-bottom: 1.5rem; }
.input-group input, .input-group select { background-color: #252525; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem; }
.input-group label { color: #aaa; font-size: 0.9rem; margin-bottom: 0.5rem; }
.manage-funds-container { color: #ffffff; }
.manage-funds-content { margin: 0 auto; max-width: 900px; padding: 4rem 5%; }
.modal-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; }
.modal-content { background-color: #1a1a1a; border: 1px solid #333; border-radius: 12px; max-width: 500px; padding: 2rem; width: 90%; }
.modal-overlay { align-items: center; background-color: rgba(0, 0, 0, 0.7); display: flex; height: 100%; justify-content: center; left: 0; position: fixed; top: 0; width: 100%; z-index: 1000; }
.modify-balance-form h3 { text-align: center; }
.page-header { margin-bottom: 3rem; text-align: center; }
.page-header p { color: #888; font-size: 1.1rem; }
.subtract { color: #f87171; font-weight: 600; }
.user-details-card { display: flex; flex-wrap: wrap; gap: 2rem; }
.user-info { flex: 1; min-width: 300px; }
.user-info p { margin-bottom: 0.75rem; }
@media (max-width: 640px) {
  .page-header { padding: 1rem 3%; }
}
</style>
