import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      // Local dev only - lets `npm run dev` on your laptop talk to a
      // locally-running backend without CORS issues, mirroring what
      // nginx does in production via the Dockerfile/nginx.conf.
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      }
    }
  }
})
