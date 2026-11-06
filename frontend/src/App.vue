<script setup>
import CategoryManager from './components/CategoryManager.vue'
import TaskManager from './components/TaskManager.vue'
</script>

<template>
  <main class="mx-auto max-w-3xl space-y-6 p-6">
    <h1 class="text-3xl font-bold">More10x - Task Manager</h1>
    <TaskManager />
    <CategoryManager />
  </main>
</template>