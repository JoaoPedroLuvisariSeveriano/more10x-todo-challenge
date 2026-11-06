import api from './api'

export const categoriesService = {
  list: () => api.get('/categories').then((r) => r.data),
  create: (payload) => api.post('/categories', { category: payload }).then((r) => r.data),
  update: (id, payload) => api.put(`/categories/${id}`, { category: payload }).then((r) => r.data),
  remove: (id) => api.delete(`/categories/${id}`),
}