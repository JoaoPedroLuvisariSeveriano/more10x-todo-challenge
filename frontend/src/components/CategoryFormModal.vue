<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  open: { type: Boolean, required: true },
  category: { type: Object, default: null },
  saving: { type: Boolean, default: false },
  error: { type: String, default: '' },
})
const emit = defineEmits(['submit', 'close'])

const name = ref('')

watch(
  () => props.open,
  (isOpen) => {
    if (isOpen) name.value = props.category?.name ?? ''
  },
  { immediate: true },
)

function onSubmit() {
  emit('submit', { name: name.value.trim() })
}
</script>

<template>
  <div
    v-if="open"
    class="fixed inset-0 z-10 flex items-center justify-center bg-slate-900/50 p-4"
    @keydown.esc="emit('close')"
  >
    <form class="w-full max-w-md rounded-lg bg-white p-6 shadow-xl" @submit.prevent="onSubmit">
      <h2 class="mb-4 text-xl font-semibold">
        {{ category ? 'Editar categoria' : 'Nova categoria' }}
      </h2>

      <label class="mb-1 block text-sm font-medium" for="category-name">Nome</label>
      <input
        id="category-name"
        v-model="name"
        type="text"
        required
        autofocus
        maxlength="100"
        class="w-full rounded border border-slate-300 px-3 py-2 focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500"
      />

      <p v-if="error" class="mt-2 text-sm text-red-600" role="alert">{{ error }}</p>

      <div class="mt-6 flex justify-end gap-2">
        <button
          type="button"
          class="rounded border border-slate-300 px-4 py-2 text-sm hover:bg-slate-100"
          :disabled="saving"
          @click="emit('close')"
        >
          Cancelar
        </button>
        <button
          type="submit"
          class="rounded bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
          :disabled="saving || !name.trim()"
        >
          {{ saving ? 'Salvando...' : 'Salvar' }}
        </button>
      </div>
    </form>
  </div>
</template>