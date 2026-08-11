import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    // 构建产物将打包进壳工程，使用相对路径
    base: './',
  },
  server: {
    port: 5173,
    // 允许壳工程 WebView 访问
    host: '0.0.0.0',
  },
});