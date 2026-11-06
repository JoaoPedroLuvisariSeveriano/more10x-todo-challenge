<script setup>
import { onMounted, ref } from 'vue'
import { categoriesService } from '../services/categories'
import { extractErrorMessage } from '../services/api'
import CategoryFormModal from './CategoryFormModal.vue'

const categories = ref([])
const loading = ref(false)
const listError = ref('')

const modalOpen = ref(false)
const editing = ref(null)
const saving = ref(false)
const formError = ref('')
const deletingId = ref(null)

async function load() {
  loading.value = true
  listError.value = ''
  try {
    categories.value = await categoriesService.list()
  } catch (e) {
    listError.value = extractErrorMessage(e)
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editing.value = null
  formError.value = ''
  modalOpen.value = true
}

function openEdit(category) {
  editing.value = category
  formError.value = ''
  modalOpen.value = true
}

function closeModal() {
  if (!saving.value) modalOpen.value = false
}

async function save(payload) {
  saving.value = true
  formError.value = ''
  try {
    if (editing.value) {
      await categoriesService.update(editing.value.id, payload)
    } else {
      await categoriesService.create(payload)
    }
    modalOpen.value = false
    await load()
  } catch (e) {
    formError.value = extractErrorMessage(e)
  } finally {
    saving.value = false
  }
}

async function remove(category) {
  const confirmed = window.confirm(
    `Excluir a categoria "${category.name}"? Todas as tarefas dela também serão excluídas.`,
  )
  if (!confirmed) return

  deletingId.value = category.id
  listError.value = ''
  try {
    await categoriesService.remove(category.id)
    categories.value = categories.value.filter((c) => c.id !== category.id)
  } catch (e) {
    listError.value = extractErrorMessage(e)
  } finally {
    deletingId.value = null
  }
}

onMounted(load)
</script>

<template>
  <section class="rounded-lg bg-white p-6 shadow">
    <div class="mb-4 flex items-center justify-between">
      <h2 class="text-xl font-semibold">Categorias</h2>
      <button
        class="rounded bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700"
        @click="openCreate"
      >
        + Nova categoria
      </button>
    </div>

    <p v-if="listError" class="mb-3 rounded bg-red-50 p-3 text-sm text-red-700" role="alert">
      {{ listError }}
    </p>

    <p v-if="loading" class="py-6 text-center text-slate-500">Carregando categorias...</p>

    <p v-else-if="!categories.length && !listError" class="py-6 text-center text-slate-500">
      Nenhuma categoria cadastrada ainda.
    </p>

    <ul v-else class="divide-y divide-slate-200">
      <li v-for="category in categories" :key="category.id" class="flex items-center justify-between py-3">
        <span class="font-medium">{{ category.name }}</span>
        <div class="flex gap-2">
          <button
            class="rounded border border-slate-300 px-3 py-1 text-sm hover:bg-slate-100"
            :disabled="deletingId === category.id"
            @click="openEdit(category)"
          >
            Editar
          </button>
          <button
            class="rounded border border-red-300 px-3 py-1 text-sm text-red-600 hover:bg-red-50 disabled:opacity-50"
            :disabled="deletingId === category.id"
            @click="remove(category)"
          >
            {{ deletingId === category.id ? 'Excluindo...' : 'Excluir' }}
          </button>
        </div>
      </li>
    </ul>

    <CategoryFormModal
      :open="modalOpen"
      :category="editing"
      :saving="saving"
      :error="formError"
      @submit="save"
      @close="closeModal"
    />
  </section>
</template>