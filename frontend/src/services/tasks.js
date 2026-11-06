import api from './api'

/** Drops empty values so only active filters become query params. */
function cleanParams(params = {}) {
  return Object.fromEntries(Object.entries(params).filter(([, v]) => v !== '' && v != null))
}

export const tasksService = {
  // params: { category_id, status, priority }
  list: (params) => api.get('/tasks', { params: cleanParams(params) }).then((r) => r.data),
  create: (payload) => api.post('/tasks', { task: payload }).then((r) => r.data),
  update: (id, payload) => api.put(`/tasks/${id}`, { task: payload }).then((r) => r.data),
  remove: (id) => api.delete(`/tasks/${id}`),
}