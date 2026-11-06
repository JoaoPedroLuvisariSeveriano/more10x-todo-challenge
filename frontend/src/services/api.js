import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1',
  headers: { 'Content-Type': 'application/json' },
})

/**
 * Extracts a human readable message from an axios error.
 * Handles the API's `{ errors: { field: [..] } }` and `{ error: "..." }` shapes.
 */
export function extractErrorMessage(error) {
  const data = error.response?.data
  if (data?.errors) {
    return Object.entries(data.errors)
      .map(([field, messages]) => `${field} ${[].concat(messages).join(', ')}`)
      .join('; ')
  }
  if (data?.error) return data.error
  return error.message || 'Erro inesperado'
}

export default api