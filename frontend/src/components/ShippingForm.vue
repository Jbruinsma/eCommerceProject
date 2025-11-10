<template>
  <div class="form-grid">
    <div class="form-group full-width">
      <label for="name">Full Name</label>
      <input type="text" id="name" v-model="name" />
    </div>
    <div class="form-group full-width">
      <label for="address_line_1">Address Line 1</label>
      <input type="text" id="address_line_1" v-model="address_line_1" />
    </div>
    <div class="form-group full-width">
      <label for="address_line_2">Address Line 2 (Optional)</label>
      <input type="text" id="address_line_2" v-model="address_line_2" />
    </div>
    <div class="form-group">
      <label for="city">City</label>
      <input type="text" id="city" v-model="city" />
    </div>
    <div class="form-group">
      <label for="state">State</label>
      <select id="state" v-model="state">
        <option :value="null" disabled>Select a state</option>
        <option
          v-for="s in usStates"
          :key="s.abbreviation"
          :value="s.abbreviation"
        >
          {{ s.name }}
        </option>
      </select>
    </div>
    <div class="form-group">
      <label for="zip_code">Zip Code</label>
      <input type="text" id="zip_code" v-model="zip_code" />
    </div>
    <div class="form-group">
      <label for="country">Country</label>
      <input type="text" id="country" v-model="country" disabled />
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true,
  },
})

const emits = defineEmits(['update:modelValue'])

// Helper function to create a v-model-like computed prop for each field
const createComputed = (fieldName) => {
  return computed({
    get: () => props.modelValue[fieldName],
    set: (value) => {
      emits('update:modelValue', { ...props.modelValue, [fieldName]: value })
    },
  })
}

// Create computed props for each field in shippingInfo
const name = createComputed('name')
const address_line_1 = createComputed('address_line_1')
const address_line_2 = createComputed('address_line_2')
const city = createComputed('city')
const state = createComputed('state')
const zip_code = createComputed('zip_code')
const country = createComputed('country')

const usStates = ref([
  { name: 'Alabama', abbreviation: 'AL' },
  { name: 'Alaska', abbreviation: 'AK' },
  { name: 'Arizona', abbreviation: 'AZ' },
  { name: 'Arkansas', abbreviation: 'AR' },
  { name: 'California', abbreviation: 'CA' },
  { name: 'Colorado', abbreviation: 'CO' },
  { name: 'Connecticut', abbreviation: 'CT' },
  { name: 'Delaware', abbreviation: 'DE' },
  { name: 'Florida', abbreviation: 'FL' },
  { name: 'Georgia', abbreviation: 'GA' },
  { name: 'Hawaii', abbreviation: 'HI' },
  { name: 'Idaho', abbreviation: 'ID' },
  { name: 'Illinois', abbreviation: 'IL' },
  { name: 'Indiana', abbreviation: 'IN' },
  { name: 'Iowa', abbreviation: 'IA' },
  { name: 'Kansas', abbreviation: 'KS' },
  { name: 'Kentucky', abbreviation: 'KY' },
  { name: 'Louisiana', abbreviation: 'LA' },
  { name: 'Maine', abbreviation: 'ME' },
  { name: 'Maryland', abbreviation: 'MD' },
  { name: 'Massachusetts', abbreviation: 'MA' },
  { name: 'Michigan', abbreviation: 'MI' },
  { name: 'Minnesota', abbreviation: 'MN' },
  { name: 'Mississippi', abbreviation: 'MS' },
  { name: 'Missouri', abbreviation: 'MO' },
  { name: 'Montana', abbreviation: 'MT' },
  { name: 'Nebraska', abbreviation: 'NE' },
  { name: 'Nevada', abbreviation: 'NV' },
  { name: 'New Hampshire', abbreviation: 'NH' },
  { name: 'New Jersey', abbreviation: 'NJ' },
  { name: 'New Mexico', abbreviation: 'NM' },
  { name: 'New York', abbreviation: 'NY' },
  { name: 'North Carolina', abbreviation: 'NC' },
  { name: 'North Dakota', abbreviation: 'ND' },
  { name: 'Ohio', abbreviation: 'OH' },
  { name: 'Oklahoma', abbreviation: 'OK' },
  { name: 'Oregon', abbreviation: 'OR' },
  { name: 'Pennsylvania', abbreviation: 'PA' },
  { name: 'Rhode Island', abbreviation: 'RI' },
  { name: 'South Carolina', abbreviation: 'SC' },
  { name: 'South Dakota', abbreviation: 'SD' },
  { name: 'Tennessee', abbreviation: 'TN' },
  { name: 'Texas', abbreviation: 'TX' },
  { name: 'Utah', abbreviation: 'UT' },
  { name: 'Vermont', abbreviation: 'VT' },
  { name: 'Virginia', abbreviation: 'VA' },
  { name: 'Washington', abbreviation: 'WA' },
  { name: 'West Virginia', abbreviation: 'WV' },
  { name: 'Wisconsin', abbreviation: 'WI' },
  { name: 'Wyoming', abbreviation: 'WY' },
])
</script>

<style scoped>
.form-grid { display: grid; gap: 1rem; grid-template-columns: 1fr 1fr; }
.form-group { display: flex; flex-direction: column; }
.form-group input, .form-group select { background-color: #2c2c2c; border: 1px solid #444; border-radius: 6px; color: #ffffff; font-size: 1rem; padding: 0.75rem; }
.form-group input:disabled { background-color: #2c2c2c; color: #777; cursor: not-allowed; }
.form-group input:focus, .form-group select:focus { border-color: #ffffff; outline: none; }
.form-group label { color: #aaa; font-size: 0.9rem; margin-bottom: 0.5rem; }
.form-group select { -webkit-appearance: none; appearance: none; }
.form-group select:hover { cursor: pointer; }
.form-group.full-width { grid-column: 1 / -1; }
.form-group input:focus { border-color: #ffffff; outline: none; }
</style>
