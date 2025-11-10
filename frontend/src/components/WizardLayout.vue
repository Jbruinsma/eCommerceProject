<template>
  <div class="wizard-card">
    <div v-if="isLoading" class="loading-overlay">
      <div class="spinner"></div>
      <p>{{ loadingText }}</p>
    </div>

    <div v-else-if="submissionResult" class="submission-result-screen">
      <slot name="result"></slot>
    </div>

    <template v-else>
      <div class="progress-bar">
        <div class="progress" :style="{ width: progressWidth }"></div>
      </div>
      <div class="wizard-header">
        <h2>{{ title }}</h2>
        <p>Step {{ currentStep }} of {{ totalSteps }}: {{ stepTitles[currentStep - 1] }}</p>
      </div>

      <slot></slot>

      <div class="wizard-footer">
        <button v-if="currentStep > 1" @click="$emit('prev')" class="btn btn-secondary">
          Back
        </button>
        <button
          v-if="currentStep < totalSteps"
          @click="$emit('next')"
          :disabled="!isStepValid"
          class="btn btn-primary"
        >
          Next
        </button>
        <button
          v-if="currentStep === totalSteps"
          @click="$emit('submit')"
          :disabled="!isStepValid"
          class="btn btn-primary"
        >
          {{ submitButtonText }}
        </button>
      </div>
    </template>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  isLoading: { type: Boolean, default: false },
  loadingText: { type: String, default: 'Loading...' },
  submissionResult: { type: Object, default: null },
  title: { type: String, required: true },
  currentStep: { type: Number, required: true },
  totalSteps: { type: Number, required: true },
  stepTitles: { type: Array, required: true },
  isStepValid: { type: Boolean, default: false },
  submitButtonText: { type: String, default: 'Submit' },
})

defineEmits(['prev', 'next', 'submit'])

const progressWidth = computed(() => {
  if (props.totalSteps <= 1) return '100%'
  return ((props.currentStep - 1) / (props.totalSteps - 1)) * 100 + '%'
})
</script>

<style scoped>
a { color: #ffffff; text-decoration: none; }
.btn { border: 1px solid transparent; border-radius: 8px; cursor: pointer; font-size: 0.9rem; font-weight: bold; padding: 0.75rem 1.5rem; transition: all 0.3s ease; }
.btn-primary { background-color: #ffffff; color: #121212; }
.btn-secondary { background-color: #2c2c2c; border-color: #444; color: #ffffff; margin-right: auto; }
.btn:disabled { background-color: #333; border-color: #444; color: #888; cursor: not-allowed; }
h2 { font-size: 1.8rem; margin-bottom: 0.5rem; text-align: left; }
.loading-overlay { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 400px; padding: 2rem; }
.loading-overlay p { color: #888; font-weight: bold; margin-top: 1rem; }
.logo { font-size: 1.5rem; font-weight: bold; letter-spacing: 2px; }
.page-header { align-items: center; border-bottom: 1px solid #2a2a2a; display: flex; justify-content: space-between; padding: 1.5rem 5%; }
.progress { background-color: #ffffff; height: 100%; transition: width 0.3s ease; }
.progress-bar { background-color: #2c2c2c; height: 8px; width: 100%; }
.result-icon { height: 80px; margin-bottom: 1rem; width: 80px; }
.result-icon.error { color: #f06e6e; }
.result-icon.success { color: #6ef0a3; }
.result-summary { background-color: #121212; border-radius: 8px; margin: 1.5rem 0; max-width: 350px; padding: 1rem; text-align: left; width: 100%; }
.result-summary p { margin: 0.5rem 0; }
.spinner { animation: spin 1s linear infinite; border: 4px solid #333; border-radius: 50%; border-top: 4px solid #ffffff; height: 50px; width: 50px; }
.submission-result-screen { align-items: center; display: flex; flex-direction: column; justify-content: center; min-height: 400px; padding: 2rem; text-align: center; }
.submission-result-screen h2 { border-bottom: none; font-size: 2rem; }
.submission-result-screen p { color: #aaa; max-width: 400px; }
.wizard-card { background-color: #1a1a1a; border: 1px solid #2a2a2a; border-radius: 12px; max-width: 800px; overflow: hidden; width: 100%; }
.wizard-footer { align-items: center; background-color: #121212; border-top: 1px solid #2a2a2a; display: flex; justify-content: flex-end; padding: 1.5rem 2rem; }
.wizard-header { padding: 2rem 2rem 1rem; }
.wizard-header p { color: #888; margin: 0; }

@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }

@media (max-width: 768px) {
  .step-content { padding: 1rem 1.5rem; }
  .wizard-footer { padding: 1rem 1.5rem; }
  .wizard-header { padding: 1.5rem; }
}
@media (max-width: 480px) {
  .step-content { padding: 1rem; }
  .wizard-footer { padding: 1rem; }
  .wizard-header { padding: 1rem; }
}
</style>
