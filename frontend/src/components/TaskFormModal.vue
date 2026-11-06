<script setup>
import { reactive, watch } from 'vue'
import { PRIORITIES, STATUSES } from '../utils/labels'

const props = defineProps({
  open: { type: Boolean, required: true },
  task: { type: Object, default: null },
  categories: { type: Array, required: true },
  saving: { type: Boolean, default: false },
  error: { type: String, default: '' },
})
const emit = defineEmits(['submit', 'close'])

const form = reactive({
  title: '',
  description: '',
  status: 'pending',
  priority: 'medium',
  due_date: '',
  category_id: '',
})

watch(
  () => props.open,
  (isOpen) => {
    if (!isOpen) return
    form.title = props.task?.title ?? ''
    form.description = props.task?.description ?? ''
    form.status = props.task?.status ?? 'pending'
    form.priority = props.task?.priority ?? 'medium'
    form.due_date = props.task?.due_date ?? ''
    form.category_id = props.task?.category_id ?? props.categories[0]?.id ?? ''
  },
  { immediate: true },
)

function onSubmit() {
  emit('submit', {
    ...form,
    title: form.title.trim(),
    due_date: form.due_date || null,
  })
}

const inputClass =
  'w-full rounded border border-slate-300 px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500'
</script>

<template>
  <div v-if="open" class="fixed inset-0 z-10 flex items-center justify-center overflow-y-auto bg-slate-900/50 p-4">
    <form class="w-full max-w-lg space-y-4 rounded-lg bg-white p-6 shadow-xl" @submit.prevent="onSubmit">
      <h2 class="text-xl font-semibold">{{ task ? 'Editar tarefa' : 'Nova tarefa' }}</h2>

      <label class="block text-sm">
        <span class="mb-1 block font-medium">Título</span>
        <input v-model="form.title" type="text" required maxlength="150" :class="inputClass" />
      </label>

      <label class="block text-sm">
        <span class="mb-1 block font-medium">Descrição</span>
        <textarea v-model="form.description" rows="3" :class="inputClass" />
      </label>

      <div class="grid gap-3 sm:grid-cols-2">
        <label class="block text-sm">
          <span class="mb-1 block font-medium">Categoria</span>
          <select v-model="form.category_id" required :class="inputClass">
            <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
        </label>

        <label class="block text-sm">
          <span class="mb-1 block font-medium">Vencimento</span>
          <input v-model="form.due_date" type="date" :class="inputClass" />
        </label>

        <label class="block text-sm">
          <span class="mb-1 block font-medium">Status</span>
          <select v-model="form.status" :class="inputClass">
            <option v-for="s in STATUSES" :key="s.value" :value="s.value">{{ s.label }}</option>
          </select>
        </label>

        <label class="block text-sm">
          <span class="mb-1 block font-medium">Prioridade</span>
          <select v-model="form.priority" :class="inputClass">
            <option v-for="p in PRIORITIES" :key="p.value" :value="p.value">{{ p.label }}</option>
          </select>
        </label>
      </div>

      <p v-if="error" class="text-sm text-red-600" role="alert">{{ error }}</p>

      <div class="flex justify-end gap-2">
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
          :disabled="saving || !form.title.trim() || !form.category_id"
        >
          {{ saving ? 'Salvando...' : 'Salvar' }}
        </button>
      </div>
    </form>
  </div>
</template>