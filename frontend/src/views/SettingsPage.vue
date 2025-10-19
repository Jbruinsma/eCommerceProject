<template>
  <div class="settings-container">
    <div v-if="message" :class="['api-message', messageType]">{{ message }}</div>

    <main class="settings-content">
      <h2>Account Settings</h2>
      <p class="subtitle">Manage your personal information and account credentials.</p>

      <form @submit.prevent="openConfirm('save')" class="settings-form">
        <div class="form-section">
          <h3>Personal Information</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="first_name">First Name</label>
              <input
                type="text"
                id="first_name"
                v-model="user.first_name"
                placeholder="First name"
              />
              <div class="field-error" v-if="errors.first_name">{{ errors.first_name }}</div>
            </div>
            <div class="form-group">
              <label for="last_name">Last Name</label>
              <input
                type="text"
                id="last_name"
                v-model="user.last_name"
                placeholder="Last name"
              />
              <div class="field-error" v-if="errors.last_name">{{ errors.last_name }}</div>
            </div>
            <div class="form-group">
              <label for="birth_date">Birth Date</label>
              <input type="date" id="birth_date" v-model="user.birth_date" />
              <div class="field-error" v-if="errors.birth_date">{{ errors.birth_date }}</div>
            </div>
            <div class="form-group">
              <label for="location">Location</label>
              <input
                type="text"
                id="location"
                v-model="user.location"
                placeholder="New York, NY"
              />
              <div class="field-error" v-if="errors.location">{{ errors.location }}</div>
            </div>
          </div>
        </div>

        <div class="form-actions">
          <button type="button" class="btn-secondary" @click="openConfirm('cancel')">Cancel</button>
          <button type="submit" class="btn-primary">Save Changes</button>
        </div>
      </form>

      <!-- Confirmation modal -->
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
    </main>

    <footer class="site-footer"></footer>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import router from '@/router/index.js'
import { useAuthStore } from '@/stores/authStore.js'
import { fetchFromAPI, postToAPI } from '@/utils/index.js'

const authStore = useAuthStore()
const user = ref({})
const errors = ref({})

onMounted(async () => {
  if (!authStore.isLoggedIn) {
    await router.push('/login')
    return
  }

  try {
    user.value = await fetchFromAPI(`/users/${authStore.uuid}/settings`)
    // capture a snapshot after we have the real user object
    originalUser = JSON.parse(JSON.stringify(user.value))
  } catch (error) {
    await router.push('/login')
    return
  }
})


let originalUser = {}

const modalVisible = ref(false)
const modalAction = ref('')
const modalProcessing = ref(false)

const openConfirm = (action) => {
  modalAction.value = action
  modalVisible.value = true
}

const closeModal = () => {
  modalVisible.value = false
  modalProcessing.value = false
}

const modalTitle = computed(() =>
  modalAction.value === 'save' ? 'Confirm Save' : 'Discard Changes?',
)
const modalMessage = computed(() =>
  modalAction.value === 'save'
    ? 'Are you sure you want to save these changes? This will update your account information.'
    : 'Are you sure you want to discard your changes? Any unsaved edits will be lost.',
)

const confirmModal = async () => {
  modalProcessing.value = true
  if (modalAction.value === 'save') {
    await handleSaveChangesConfirmed()
  } else if (modalAction.value === 'cancel') {
    handleCancelConfirmed()
  }
  closeModal()
}

const handleSaveChangesConfirmed = async () => {
  // Build explicit plain payload matching UpdatedUser to avoid missing-field validation
  modalProcessing.value = true
  errors.value = {}
  try {
    const payload = {
      uuid: authStore.uuid || user.value.uuid || null,
      email: user.value.email ?? null,
      first_name: user.value.first_name ?? null,
      last_name: user.value.last_name ?? null,
      location: user.value.location ?? null,
      birth_date: user.value.birth_date ?? null,
      role: user.value.role ?? null,
      created_at: user.value.created_at ?? null,
      updated_at: user.value.updated_at ?? null,
    }

    console.debug('Settings payload', payload)

    const response = await postToAPI(`/users/${authStore.uuid}/settings`, payload)

    originalUser = JSON.parse(JSON.stringify(response))

    errors.value = {}
    message.value = 'Settings saved successfully.'
    messageType.value = 'success'
    setTimeout(() => { message.value = ''; messageType.value = '' }, 3000)
  } catch (err) {
    errors.value = {}

    if (err && err.data && Array.isArray(err.data.detail)) {
      err.data.detail.forEach((d) => {
        const loc = Array.isArray(d.loc) ? d.loc : []
        const field = loc.length >= 2 ? loc[1] : (loc[0] || 'body')
        const key = field
        errors.value[key] = d.msg
      })
      message.value = 'Please fix the highlighted fields.'
      messageType.value = 'error'
    } else {
      let errMsg = (err && err.message) || 'Failed to save settings.'
      if (err && err.data && err.data.message) errMsg = err.data.message
      message.value = errMsg
      messageType.value = 'error'
    }
  } finally {
    modalProcessing.value = false
  }
}

const handleCancelConfirmed = () => {
  Object.assign(user.value, JSON.parse(JSON.stringify(originalUser || {})))
}


const handleSaveChanges = () => openConfirm('save')
const handleCancel = () => openConfirm('cancel')


const message = ref('')
const messageType = ref('')
</script>

<style scoped>
/* Layout and typography */
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.settings-container { color: #ffffff; font-family: Spectral, sans-serif; }
.settings-content { margin: 0 auto; max-width: 900px; padding: 4rem 5%; }

/* Headings */
h2 { border-bottom: 1px solid #333; font-size: 1.8rem; margin-bottom: 0.5rem; padding-bottom: 1rem; text-align: left; }
h3 { color: #ffffff; font-size: 1.2rem; margin-bottom: 1.5rem; }

.subtitle { color: #888; margin-bottom: 3rem; }

/* Form layout */
.settings-form { display: flex; flex-direction: column; gap: 3rem; }
.form-section { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; padding: 2rem; }
.form-grid { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); }
.form-group { display: flex; flex-direction: column; }
.form-actions { align-items: center; display: flex; gap: 1rem; justify-content: flex-end; }

/* Inputs */
input[type='text'], input[type='email'], input[type='date'], input[type='password'] { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; color: #ffffff; font-family: inherit; font-size: 1rem; padding: 0.75rem; transition: border-color 0.3s ease; }
input[type='text']:focus, input[type='email']:focus, input[type='date']:focus, input[type='password']:focus { border-color: #ffffff; outline: none; }
label { display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.5rem; }

/* Buttons */
.btn-primary, .btn-secondary { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-primary:hover { background-color: #cccccc; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; }
.btn-secondary:hover { background-color: #383838; border-color: #666; }

/* Modal */
.modal-overlay { align-items: center; background: rgba(0,0,0,0.6); display: flex; inset: 0; justify-content: center; position: fixed; z-index: 1000; }
.modal { background: #0f0f0f; border: 1px solid #2a2a2a; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.6); max-width: 520px; padding: 1.5rem; width: 92%; }
.modal h3 { color: #fff; margin-top: 0; }
.modal p { color: #ccc; margin-bottom: 1rem; }
.modal-actions { display: flex; gap: 1rem; justify-content: flex-end; }
.modal .btn-primary { min-width: 120px; }

/* API message */
.api-message { border-radius: 6px; font-weight: 600; margin: 1rem auto; max-width: 900px; padding: 0.75rem 1rem; text-align: center; }
.api-message.success { background: #0f5132; border: 1px solid #0b2f1f; color: #d1e7dd; }
.api-message.error { background: #5a1414; border: 1px solid #3e0b0b; color: #f8d7da; }

.field-error { color: #ffb3b3; font-size: 0.85rem; margin-top: 0.4rem; }

@media (max-width: 640px) {
  .page-header { padding: 1rem 3%; }
}
</style>
