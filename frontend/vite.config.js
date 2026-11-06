import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    // Expose the dev server outside the container.
    host: '0.0.0.0',
    port: 5173,
    // Polling is required for HMR on bind mounts (Docker on Windows/macOS).
    watch: { usePolling: true },
  },
})