<script setup>
import { ref } from 'vue'
import CategoryManager from './components/CategoryManager.vue'
import TaskManager from './components/TaskManager.vue'

const tabs = [
  { id: 'tasks', label: 'Tarefas' },
  { id: 'categories', label: 'Categorias' },
]
const active = ref('tasks')
</script>

<template>
  <main class="mx-auto max-w-4xl space-y-6 p-6">
    <h1 class="text-3xl font-bold">More10x - Task Manager</h1>

    <nav class="flex gap-2 border-b border-slate-200" aria-label="Seções">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        class="-mb-px border-b-2 px-4 py-2 text-sm font-medium"
        :class="active === tab.id ? 'border-indigo-600 text-indigo-600' : 'border-transparent text-slate-500 hover:text-slate-700'"
        @click="active = tab.id"
      >
        {{ tab.label }}
      </button>
    </nav>

    <!-- v-if remounts the view, so categories are always fresh after edits. -->
    <TaskManager v-if="active === 'tasks'" />
    <CategoryManager v-else />
  </main>
</template>