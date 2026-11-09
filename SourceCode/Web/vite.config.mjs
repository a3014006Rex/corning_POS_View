import { fileURLToPath, URL } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const target = env.TC_API_PROXY_TARGET || 'http://127.0.0.1:5181'
  return {
    plugins: [vue()],
    base: './',
    resolve: { alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) } },
    server: {
      host: '127.0.0.1',
      port: 5180,
      strictPort: true,
      watch: { ignored: ['**/.vs/**', '**/*.vsidx'] },
      proxy: {
        '/api': { target, changeOrigin: true },
        '/health': { target, changeOrigin: true },
      },
    },
    preview: { host: '127.0.0.1', port: 4180, strictPort: true },
    build: { outDir: 'dist', emptyOutDir: true },
    test: {
      environment: 'jsdom',
      clearMocks: true,
      restoreMocks: true,
    },
  }
})
