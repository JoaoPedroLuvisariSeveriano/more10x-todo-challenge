<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { categoriesService } from '../services/categories'
import { tasksService } from '../services/tasks'
import { extractErrorMessage } from '../services/api'
import { formatDate, isOverdue, priorityMeta, statusMeta } from '../utils/labels'
import TaskFilters from './TaskFilters.vue'
import TaskFormModal from './TaskFormModal.vue'

const emptyFilters = () => ({ category_id: '', status: '', priority: '' })

const categories = ref([])
const tasks = ref([])
const counts = ref({})
const filters = reactive(emptyFilters())

const loading = ref(false)
const error = ref('')

const modalOpen = ref(false)
const editing = ref(null)
const saving = ref(false)
const formError = ref('')
const deletingId = ref(null)

let requestId = 0

async function loadTasks() {
  const current = ++requestId
  loading.value = true
  error.value = ''
  try {
    // The list uses every active filter; the counters ignore the status filter
    // so the user can still see how many tasks exist in each status.
    const { status, ...withoutStatus } = filters
    const [list, forCounts] = await Promise.all([
      tasksService.list({ ...filters }),
      status ? tasksService.list(withoutStatus) : null,
    ])
    if (current !== requestId) return // a newer request superseded this one
    tasks.value = list
    counts.value = countByStatus(forCounts ?? list)
  } catch (e) {
    if (current === requestId) error.value = extractErrorMessage(e)
  } finally {
    if (current === requestId) loading.value = false
  }
}

function countByStatus(list) {
  return list.reduce((acc, t) => ({ ...acc, [t.status]: (acc[t.status] || 0) + 1 }), {})
}

function setFilters(next) {
  Object.assign(filters, next)
}

function clearFilters() {
  Object.assign(filters, emptyFilters())
}

function openCreate() {
  editing.value = null
  formError.value = ''
  modalOpen.value = true
}

function openEdit(task) {
  editing.value = task
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
      await tasksService.update(editing.value.id, payload)
    } else {
      await tasksService.create(payload)
    }
    modalOpen.value = false
    await loadTasks()
  } catch (e) {
    formError.value = extractErrorMessage(e)
  } finally {
    saving.value = false
  }
}

async function remove(task) {
  if (!window.confirm(`Excluir a tarefa "${task.title}"?`)) return

  deletingId.value = task.id
  error.value = ''
  try {
    await tasksService.remove(task.id)
    await loadTasks()
  } catch (e) {
    error.value = extractErrorMessage(e)
  } finally {
    deletingId.value = null
  }
}

watch(filters, loadTasks)

onMounted(async () => {
  try {
    categories.value = await categoriesService.list()
  } catch (e) {
    error.value = extractErrorMessage(e)
  }
  await loadTasks()
})
</script>

<template>
  <section class="space-y-4 rounded-lg bg-white p-6 shadow">
    <div class="flex items-center justify-between">
      <h2 class="text-xl font-semibold">Tarefas</h2>
      <button
        class="rounded bg-indigo-600 px-4 py-2 text-sm font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
        :disabled="!categories.length"
        :title="categories.length ? '' : 'Crie uma categoria primeiro'"
        @click="openCreate"
      >
        + Nova tarefa
      </button>
    </div>

    <TaskFilters
      :filters="filters"
      :categories="categories"
      :counts="counts"
      @update:filters="setFilters"
      @clear="clearFilters"
    />

    <p v-if="error" class="rounded bg-red-50 p-3 text-sm text-red-700" role="alert">{{ error }}</p>

    <p v-if="!categories.length && !loading" class="rounded bg-amber-50 p-3 text-sm text-amber-800">
      Cadastre ao menos uma categoria na aba "Categorias" para criar tarefas.
    </p>

    <p v-if="loading" class="py-6 text-center text-slate-500">Carregando tarefas...</p>

    <p v-else-if="!tasks.length && !error" class="py-6 text-center text-slate-500">
      Nenhuma tarefa encontrada para os filtros atuais.
    </p>

    <ul v-else class="divide-y divide-slate-200">
      <li v-for="task in tasks" :key="task.id" class="flex flex-col gap-2 py-4 sm:flex-row sm:items-start sm:justify-between">
        <div class="min-w-0">
          <p class="font-medium" :class="task.status === 'completed' ? 'text-slate-400 line-through' : ''">
            {{ task.title }}
          </p>
          <p v-if="task.description" class="mt-1 text-sm text-slate-600">{{ task.description }}</p>
          <div class="mt-2 flex flex-wrap items-center gap-2 text-xs">
            <span class="rounded bg-indigo-50 px-2 py-0.5 text-indigo-700">{{ task.category?.name }}</span>
            <span class="rounded px-2 py-0.5" :class="statusMeta(task.status)?.badge">{{ statusMeta(task.status)?.label }}</span>
            <span class="rounded px-2 py-0.5" :class="priorityMeta(task.priority)?.badge">
              Prioridade {{ priorityMeta(task.priority)?.label.toLowerCase() }}
            </span>
            <span :class="isOverdue(task) ? 'font-semibold text-red-600' : 'text-slate-500'">
              Vence: {{ formatDate(task.due_date) }}<template v-if="isOverdue(task)"> (atrasada)</template>
            </span>
          </div>
        </div>
        <div class="flex shrink-0 gap-2">
          <button
            class="rounded border border-slate-300 px-3 py-1 text-sm hover:bg-slate-100"
            :disabled="deletingId === task.id"
            @click="openEdit(task)"
          >
            Editar
          </button>
          <button
            class="rounded border border-red-300 px-3 py-1 text-sm text-red-600 hover:bg-red-50 disabled:opacity-50"
            :disabled="deletingId === task.id"
            @click="remove(task)"
          >
            {{ deletingId === task.id ? 'Excluindo...' : 'Excluir' }}
          </button>
        </div>
      </li>
    </ul>

    <TaskFormModal
      :open="modalOpen"
      :task="editing"
      :categories="categories"
      :saving="saving"
      :error="formError"
      @submit="save"
      @close="closeModal"
    />
  </section>
</template>