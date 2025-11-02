<template>
  <section class="card search-card">
    <h2>{{ title }}</h2>
    <form @submit.prevent="handleSubmit" class="search-form">
      <label for="search-query">User Email or UUID</label>
      <input
        type="text"
        id="search-query"
        :value="modelValue"
        @input="$emit('update:modelValue', $event.target.value)"
        placeholder="e.g., user@example.com or a UUID"
      />
      <button type="submit" class="btn btn-primary" :disabled="loading">
        {{ loading ? '...' : 'Search' }}
      </button>
    </form>
  </section>
</template>

<script setup>
defineProps({
  modelValue: {
    type: String,
    required: true,
  },
  loading: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    required: true,
  },
})

const emit = defineEmits(['update:modelValue', 'submit'])

function handleSubmit() {
  emit('submit')
}
</script>

<style scoped>
h2 { border-bottom: 1px solid #333; color: #ffffff; font-family: Spectral, sans-serif; font-size: 1.5rem; font-weight: 600; margin-bottom: 1.5rem; padding-bottom: 1rem; }
label { color: #ffffff; display: block; font-size: 0.9rem; font-weight: 600; margin-bottom: 0.5rem; }
.card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; margin-bottom: 2rem; padding: 2rem; }
.search-form { display: flex; flex-direction: column; }
.search-card { margin-left: auto; margin-right: auto; max-width: 550px; }
#search-query { background-color: #2c2c2c; border: 1px solid #444; border-radius: 8px; box-sizing: border-box; color: #ffffff; font-size: 1rem; margin-bottom: 1rem; outline: none; padding: 0.85rem 1rem; transition: border-color 0.2s ease; width: 100%; }
#search-query:focus { border-color: #ffffff; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 1rem; font-weight: bold; padding: 0.75rem 1.5rem; text-align: center; transition: all 0.3s ease; width: 100%; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-primary:hover:not(:disabled) { background-color: #cccccc; }
.btn:disabled { background-color: #555; color: #999; cursor: not-allowed; }
</style>
