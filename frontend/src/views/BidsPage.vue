<template>
  <div class="bids-container">
    <main class="bids-content">
      <header class="page-header">
        <h1 class="page-title">My Active Bids</h1>
        <p>Here are the items you are currently bidding on.</p>
      </header>

      <div v-if="loading" class="loading-indicator">
        <p>Loading your bids...</p>
      </div>

      <div v-else-if="bids.length === 0 && !loading" class="empty-state">
        <h2>No Bids Found</h2>
        <p>You don't have any active bids at the moment.</p>
        <router-link :to="{ name: 'SearchResults' }" class="btn-shop">Start Shopping</router-link>
      </div>

      <div v-else-if="bids.length > 0 && !loading" class="bids-grid">
        <div v-for="bid in bids" :key="bid.bidId" class="bid-card">
          <div class="bid-card-image">
            <img :src="bid.itemImageUrl" :alt="bid.itemName" />
          </div>
          <div class="bid-card-details">
            <h3 class="product-name">{{ bid.itemName }}</h3>
            <p class="product-size">Size: {{ bid.itemSize }}</p>
            <p class="product-condition">Condition: {{ bid.itemCondition }}</p>
            <div class="bid-info">
              <p><strong>Your Bid:</strong> {{ formatCurrency(bid.userBidAmount) }}</p>
              <p><strong>Fee:</strong> {{ formatCurrency(bid.transactionFee) }}</p>
              <p><strong>Total:</strong> {{ formatCurrency(bid.totalBidAmount) }}</p>
            </div>
          </div>
          <div class="bid-card-right-panel">
            <div class="bid-card-status">
              <span class="status-badge" :class="`status-${bid.bidStatus.toLowerCase()}`">
                {{ bid.bidStatus }}
              </span>
            </div>
            <div class="bid-card-actions">
              <button
                @click.prevent="openChangeBidModal(bid)"
                class="action-btn"
                title="Change bid"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897L16.863 4.487Zm0 0L19.5 7.125"
                  />
                </svg>
              </button>
              <button
                @click.prevent="openDeleteBidModal(bid)"
                class="action-btn"
                title="Delete bid"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"
                  />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <div v-if="showChangeModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Change Your Bid</h3>
        <div class="modal-grid">
          <div class="modal-section modal-current">
            <div class="section-title">Current</div>
            <div class="section-row"><span class="label">Item</span><span class="value">{{ bidToChange.itemName }}</span></div>
            <div class="section-row"><span class="label">Bid</span><span class="value">{{ formatCurrency(bidToChange.userBidAmount) }}</span></div>
            <div class="section-row"><span class="label">Fee</span><span class="value">{{ formatCurrency(bidToChange.transactionFee) }}</span></div>
            <div class="section-row"><span class="label">Total</span><span class="value">{{ formatCurrency(bidToChange.totalBidAmount) }}</span></div>
          </div>
          <div class="modal-section modal-new">
            <div class="section-title">New (preview)</div>
            <div class="section-row"><span class="label">New Bid</span><span class="value">{{ newBidAmount ? formatCurrency(newBidAmount) : '—' }}</span></div>
            <div class="section-row"><span class="label">Buyer Fee</span><span class="value">{{ feeInfo ? formatPercentage(feeInfo.buyer_fee_percentage) : '—' }}</span></div>
            <div class="section-row"><span class="label">Estimated Fee</span><span class="value">{{ !isBidUnchanged && feeInfo ? formatCurrency(estimateFee(newBidAmount)) : '---' }}</span></div>
            <div class="section-row"><span class="label">Estimated Total</span><span class="value">{{ !isBidUnchanged && feeInfo ? formatCurrency(estimateTotal(newBidAmount)) : '---' }}</span></div>
          </div>
        </div>
        <div class="input-group">
          <label for="new-bid-amount">New Bid Amount</label>
          <input id="new-bid-amount" v-model="newBidAmount" type="text" placeholder="Enter new amount" @input="handleAmountInput" />
        </div>
        <div class="modal-actions">
          <button class="btn btn-secondary" @click="closeModals">Cancel</button>
          <button class="btn btn-success" :disabled="!isNewBidValid" @click="confirmChangeBid">
            Submit New Bid
          </button>
        </div>
      </div>
    </div>

    <div v-if="showDeleteModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Confirm Deletion</h3>
        <p>Are you sure you want to delete your bid on <strong>{{ bidToDelete?.itemName }}</strong>? This action cannot be undone.</p>
        <div class="modal-actions">
          <button class="btn btn-secondary" @click="closeModals">Cancel</button>
          <button class="btn btn-danger" @click="confirmDeleteBid">Confirm Delete</button>
        </div>
      </div>
    </div>

    <!-- Success Modal -->
    <div v-if="showSuccessModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="success-header">Success</h3>
        <p>{{ modalMessage }}</p>
        <div class="modal-actions">
          <button class="btn btn-success" @click="closeModals">OK</button>
        </div>
      </div>
    </div>

    <!-- Error Modal -->
    <div v-if="showErrorModal" class="modal-overlay">
      <div class="modal-content">
        <h3 class="error-header">Error</h3>
        <p>{{ modalMessage }}</p>
        <div class="modal-actions">
          <button class="btn btn-secondary" @click="closeModals">Close</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '@/stores/authStore.js'
import { fetchFromAPI, postToAPI, deleteFromAPI } from '@/utils/index.js'
import router from '@/router/index.js'
import { getBuyerFee } from '@/utils/fees.js'

const bids = ref([])
const loading = ref(true)
const message = ref('')
const messageType = ref('info')
const authStore = useAuthStore()

const showChangeModal = ref(false)
const showDeleteModal = ref(false)
const showSuccessModal = ref(false)
const showErrorModal = ref(false)
const modalMessage = ref('')

const bidToChange = ref(null)
const bidToDelete = ref(null)
const newBidAmount = ref('')
const feeInfo = ref(null)

const isBidUnchanged = computed(() => {
  if (!bidToChange.value) return false
  const currentBid = Number(bidToChange.value.userBidAmount)
  const newBid = parseFloat(newBidAmount.value)
  return currentBid === newBid
})

function formatCurrency(value) {
  const n = Number(value)
  if (Number.isFinite(n))
    return `$${n.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
  return '$0.00'
}

function formatPercentage(p) {
  const n = Number(p)
  if (!Number.isFinite(n)) return '0%'
  return `${(n * 100).toFixed(2)}%`
}

function estimateFee(amount) {
  const a = Number(amount) || 0
  const pct = Number(feeInfo.value?.buyer_fee_percentage) || 0
  return a * pct
}

function estimateTotal(amount) {
  const a = Number(amount) || 0
  return a + estimateFee(a)
}

function openChangeBidModal(bid) {
  bidToChange.value = bid
  newBidAmount.value = (typeof bid.userBidAmount === 'number' ? bid.userBidAmount : parseFloat(bid.userBidAmount)).toFixed(2)
  showChangeModal.value = true
}

function openDeleteBidModal(bid) {
  bidToDelete.value = bid
  showDeleteModal.value = true
}

function closeModals() {
  showChangeModal.value = false
  showDeleteModal.value = false
  showSuccessModal.value = false
  showErrorModal.value = false
  bidToChange.value = null
  bidToDelete.value = null
  newBidAmount.value = ''
  modalMessage.value = ''
}

function handleAmountInput(event) {
  let value = event.target.value
  value = value.replace(/[^\d.]/g, '')
  value = value.replace(/(\..*)\./g, '$1')
  const parts = value.split('.')
  if (parts[1] && parts[1].length > 2) {
    parts[1] = parts[1].substring(0, 2)
    value = parts.join('.')
  }
  if (parseFloat(value) > 1000000) {
    value = '1000000.00'
  }
  newBidAmount.value = value
}

const isNewBidValid = computed(() => {
  const amount = parseFloat(newBidAmount.value)
  return !isNaN(amount) && amount >= 0.1 && !isBidUnchanged.value
})

async function confirmChangeBid() {
  if (!isNewBidValid.value) return

  try {
    const payload = {
      new_bid_amount: parseFloat(newBidAmount.value),
      fee_structure_id: feeInfo.value?.id ?? null,
    }
    const response = await postToAPI(`/bids/${authStore.uuid}/${bidToChange.value.bidId}/edit`, payload)
    const updatedBid = response?.data ?? response

    const index = bids.value.findIndex((b) => b.bidId === bidToChange.value.bidId)
    if (index !== -1) {
      bids.value[index].userBidAmount = Number(updatedBid.bid_amount)
      bids.value[index].transactionFee = Number(updatedBid.transaction_fee)
      bids.value[index].totalBidAmount = Number(updatedBid.total_bid_amount)
    }

    modalMessage.value = `Your bid for "${bidToChange.value.itemName}" has been successfully updated to ${formatCurrency(updatedBid.bid_amount)}.`
    showChangeModal.value = false
    showSuccessModal.value = true

  } catch (err) {
    console.error('Failed to update bid:', err)
    modalMessage.value = err.data?.message || 'Failed to update bid. Please try again later.'
    showChangeModal.value = false
    showErrorModal.value = true
  }
}

async function confirmDeleteBid() {
  if (!bidToDelete.value) return;

  try {
    await deleteFromAPI(`/bids/${authStore.uuid}/${bidToDelete.value.bidId}`);
    bids.value = bids.value.filter(b => b.bidId !== bidToDelete.value.bidId);
    modalMessage.value = `Your bid for "${bidToDelete.value.itemName}" has been successfully deleted.`
    showDeleteModal.value = false
    showSuccessModal.value = true
  } catch (err) {
    console.error('Failed to delete bid:', err);
    modalMessage.value = err.data?.message || 'Failed to delete bid. Please try again later.';
    showDeleteModal.value = false
    showErrorModal.value = true
  }
}

async function retrieveUserBids(){
  try {
    const userBidsResponse = await fetchFromAPI(`/bids/${authStore.uuid}/active`)
    if (userBidsResponse && userBidsResponse.length > 0) {
      bids.value = userBidsResponse.map((apiBid) => ({
        bidId: apiBid.bid_id,
        itemId: apiBid.product_id,
        itemName: apiBid.name,
        itemImageUrl: apiBid.image_url,
        userBidAmount: Number(apiBid.bid_amount),
        transactionFee: Number(apiBid.transaction_fee || 0),
        totalBidAmount: Number(apiBid.total_bid_amount ?? (apiBid.bid_amount + (apiBid.transaction_fee || 0))),
        bidStatus: apiBid.bid_status,
        itemSize: apiBid.size_value,
        itemCondition: apiBid.product_condition,
      }))
    } else {
      bids.value = []
    }
  } catch (err) {
    console.error('Failed to fetch active bids:', err)
    message.value = err.data?.message || 'Could not load your bids. Please try again later.'
    messageType.value = 'error'
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  if (!authStore.isLoggedIn || !authStore.uuid) {
    await router.push('/login')
    return
  }
  try {
    const feeData = await getBuyerFee()
    feeInfo.value = feeData || null
  } catch (feeErr) {
    console.warn('Failed to load buyer fee:', feeErr)
    feeInfo.value = null
  }
  await retrieveUserBids()
})
</script>

<style scoped>
h1, h2, h3 { color: #ffffff; font-family: Spectral, sans-serif; font-weight: 600; }
p { color: #cccccc; line-height: 1.6; }
.action-btn { background: transparent; border: none; cursor: pointer; padding: 0.25rem; }
.action-btn svg { height: 20px; stroke: #888; transition: stroke 0.2s ease; width: 20px; }
.action-btn:hover svg { stroke: #ffffff; }
.api-message { border-radius: 8px; font-weight: 600; margin: 2rem auto; max-width: 800px; padding: 1rem 1.5rem; text-align: center; }
.api-message.error { background: #5a1414; border: 1px solid #3e0b0b; color: #f8d7da; }
.api-message.info { background: #1f3a47; border: 1px solid #2a4e5f; color: #a6dce7; }
.bid-card { align-items: center; background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; display: grid; gap: 1rem; grid-template-columns: 100px 1fr auto; padding: 1rem; }
.bid-card-actions { align-items: center; display: flex; gap: 0.5rem; }
.bid-card-details .bid-info p { color: #aaa; font-size: 0.9rem; margin: 0.25rem 0; }
.bid-card-details .bid-info strong { color: #ccc; }
.bid-card-image img { border-radius: 8px; height: auto; max-width: 100%; }
.bid-card-right-panel { align-items: center; display: flex; gap: 1rem; justify-content: flex-end; }
.bids-container { color: #ffffff; }
.bids-content { margin: 0 auto; max-width: 1200px; padding: 4rem 5%; }
.bids-grid { display: grid; gap: 1.5rem; }
.btn { border: none; border-radius: 8px; cursor: pointer; font-family: inherit; font-size: 1rem; font-weight: 600; padding: 0.75rem 1.5rem; transition: all 0.2s ease-in-out; }
.btn-danger { background-color: #5a1414; border: 1px solid #842029; color: #f8d7da; }
.btn-danger:hover { background-color: #842029; }
.btn-secondary { background-color: #4a4a4a; border: 1px solid #666; color: #e0e0e0; }
.btn-secondary:hover { background-color: #5a5a5a; }
.btn-shop { background-color: #6ef0a3; border-radius: 8px; color: #121212; display: inline-block; font-weight: bold; margin-top: 1.5rem; padding: 0.8rem 1.5rem; text-decoration: none; transition: background-color 0.3s; }
.btn-shop:hover { background-color: #8affbe; }
.btn-success { background-color: #1a5e3a; border: 1px solid #2a7e4a; color: #e0ffe0; }
.btn-success:hover { background-color: #2a7e4a; border-color: #3cb063; }
.btn:disabled { cursor: not-allowed; opacity: 0.6; }
.empty-state { padding: 4rem 0; text-align: center; }
.empty-state h2 { font-size: 1.8rem; }
.error-header { color: #f8d7da; }
.input-group { display: flex; flex-direction: column; margin: 1.5rem 0; }
.input-group input { background-color: #252525; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-size: 1rem; padding: 0.75rem; }
.input-group label { color: #aaa; font-size: 0.9rem; margin-bottom: 0.5rem; }
.label { color: #aaa; font-size: 0.9rem; }
.loading-indicator { color: #888; font-size: 1.2rem; text-align: center; }
.modal-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; }
.modal-content { background-color: #1a1a1a; border: 1px solid #333; border-radius: 12px; max-width: 720px; padding: 2rem; width: 90%; }
.modal-grid { display: grid; gap: 1.5rem; grid-template-columns: 1fr 1fr; margin-bottom: 1.5rem; }
.modal-overlay { align-items: center; background-color: rgba(0, 0, 0, 0.75); bottom: 0; display: flex; justify-content: center; left: 0; position: fixed; right: 0; top: 0; z-index: 1000; }
.modal-section { border: 1px solid #333; border-radius: 8px; padding: 1rem; }
.modal-section.modal-new { background-color: rgba(30, 80, 40, 0.2); border-color: #2a7e4a; }
.page-header { border-bottom: 1px solid #333; margin-bottom: 3rem; padding-bottom: 1.5rem; }
.page-title { font-size: 2.2rem; text-align: left; }
.section-row { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 0.6rem 0; }
.section-row .value { color: #ffffff; font-family: 'Inter', sans-serif; font-weight: 600; }
.section-row:last-child { border-bottom: none; }
.section-title { color: #e0e0e0; font-size: 0.85rem; font-weight: 700; letter-spacing: 0.6px; margin-bottom: 0.75rem; text-transform: uppercase; }
.status-badge { border-radius: 9999px; font-size: 0.75rem; font-weight: 700; letter-spacing: 0.5px; padding: 0.25rem 0.75rem; text-transform: capitalize; }
.status-badge.status-active { background-color: #1a4a32; border: 1px solid #2a7e4a; color: #6ef0a3; }
.success-header { color: #6ef0a3; }
@media (max-width: 600px) {
  .modal-grid { grid-template-columns: 1fr; }
}
@media (max-width: 768px) {
  .bid-card { grid-template-columns: 80px 1fr; }
  .bid-card-right-panel { align-items: center; display: flex; grid-column: 2; justify-content: space-between; margin-top: 0.5rem; }
}
</style>

