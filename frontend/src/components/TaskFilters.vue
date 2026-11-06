<script setup>
import { computed } from 'vue'
import { PRIORITIES, STATUSES } from '../utils/labels'

const props = defineProps({
  filters: { type: Object, required: true },
  categories: { type: Array, required: true },
  counts: { type: Object, required: true },
})
const emit = defineEmits(['update:filters', 'clear'])

const hasActiveFilters = computed(() => Object.values(props.filters).some((v) => v !== ''))
const totalCount = computed(() => STATUSES.reduce((sum, s) => sum + (props.counts[s.value] || 0), 0))

function update(key, value) {
  emit('update:filters', { ...props.filters, [key]: value })
}

const selectClass =
  'w-full rounded border border-slate-300 bg-white px-3 py-2 text-sm focus:border-indigo-500 focus:outline-none focus:ring-1 focus:ring-indigo-500'
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap gap-2" aria-label="Contadores de status">
      <button
        type="button"
        class="rounded-full border px-3 py-1 text-sm"
        :class="filters.status === '' ? 'border-indigo-600 bg-indigo-600 text-white' : 'border-slate-300 bg-white hover:bg-slate-100'"
        @click="update('status', '')"
      >
        Todas <strong>{{ totalCount }}</strong>
      </button>
      <button
        v-for="s in STATUSES"
        :key="s.value"
        type="button"
        class="rounded-full border px-3 py-1 text-sm"
        :class="filters.status === s.value ? 'border-indigo-600 bg-indigo-600 text-white' : 'border-slate-300 bg-white hover:bg-slate-100'"
        @click="update('status', s.value)"
      >
        {{ s.label }} <strong>{{ counts[s.value] || 0 }}</strong>
      </button>
    </div>

    <div class="grid gap-3 sm:grid-cols-4">
      <label class="text-sm">
        <span class="mb-1 block font-medium">Categoria</span>
        <select :value="filters.category_id" :class="selectClass" @change="update('category_id', $event.target.value)">
          <option value="">Todas</option>
          <option v-for="c in categories" :key="c.id" :value="String(c.id)">{{ c.name }}</option>
        </select>
      </label>

      <label class="text-sm">
        <span class="mb-1 block font-medium">Status</span>
        <select :value="filters.status" :class="selectClass" @change="update('status', $event.target.value)">
          <option value="">Todos</option>
          <option v-for="s in STATUSES" :key="s.value" :value="s.value">{{ s.label }}</option>
        </select>
      </label>

      <label class="text-sm">
        <span class="mb-1 block font-medium">Prioridade</span>
        <select :value="filters.priority" :class="selectClass" @change="update('priority', $event.target.value)">
          <option value="">Todas</option>
          <option v-for="p in PRIORITIES" :key="p.value" :value="p.value">{{ p.label }}</option>
        </select>
      </label>

      <div class="flex items-end">
        <button
          type="button"
          class="w-full rounded border border-slate-300 px-3 py-2 text-sm hover:bg-slate-100 disabled:cursor-not-allowed disabled:opacity-50"
          :disabled="!hasActiveFilters"
          @click="emit('clear')"
        >
          Limpar filtros
        </button>
      </div>
    </div>
  </div>
</template>