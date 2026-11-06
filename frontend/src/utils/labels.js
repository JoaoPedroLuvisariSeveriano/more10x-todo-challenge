export const STATUSES = [
  { value: 'pending', label: 'Pendente', badge: 'bg-slate-200 text-slate-700' },
  { value: 'in_progress', label: 'Em andamento', badge: 'bg-blue-100 text-blue-800' },
  { value: 'completed', label: 'Concluída', badge: 'bg-green-100 text-green-800' },
]

export const PRIORITIES = [
  { value: 'low', label: 'Baixa', badge: 'bg-green-100 text-green-800' },
  { value: 'medium', label: 'Média', badge: 'bg-yellow-100 text-yellow-800' },
  { value: 'high', label: 'Alta', badge: 'bg-red-100 text-red-800' },
]

export const statusMeta = (value) => STATUSES.find((s) => s.value === value)
export const priorityMeta = (value) => PRIORITIES.find((p) => p.value === value)

/** Formats an ISO date (YYYY-MM-DD) without timezone shifts. */
export function formatDate(iso) {
  if (!iso) return '—'
  const [year, month, day] = iso.split('-')
  return `${day}/${month}/${year}`
}

export function isOverdue(task) {
  if (!task.due_date || task.status === 'completed') return false
  const today = new Date()
  const iso = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
  return task.due_date < iso
}