<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { categoriesService } from '../services/categories'
import { tasksService } from '../services/tasks'
import { extractErrorMessage } from '../services/api'
import { formatDate, isOverdue, priorityMeta, statusMeta } from '../utils/labels'
import TaskFilters from './TaskFilters.vue'

const emptyFilters = () => ({ category_id: '', status: '', priority: '' })

const categories = ref([])
const tasks = ref([])
const counts = ref({})
const filters = reactive(emptyFilters())

const loading = ref(false)
const error = ref('')

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
    <h2 class="text-xl font-semibold">Tarefas</h2>

    <TaskFilters
      :filters="filters"
      :categories="categories"
      :counts="counts"
      @update:filters="setFilters"
      @clear="clearFilters"
    />

    <p v-if="error" class="rounded bg-red-50 p-3 text-sm text-red-700" role="alert">{{ error }}</p>

    <p v-if="loading" class="py-6 text-center text-slate-500">Carregando tarefas...</p>

    <p v-else-if="!tasks.length && !error" class="py-6 text-center text-slate-500">
      Nenhuma tarefa encontrada para os filtros atuais.
    </p>

    <ul v-else class="divide-y divide-slate-200">
      <li v-for="task in tasks" :key="task.id" class="py-4">
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
      </li>
    </ul>
  </section>
</template>