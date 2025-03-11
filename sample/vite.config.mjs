import { defineConfig } from 'vite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig({
  root: path.resolve(__dirname, 'src'),
  base: './',
  publicDir: path.resolve(__dirname, 'public'),
  resolve: {
    extensions: ['.js'],
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },

  build: {
    outDir: '../dist',
    assetsDir: 'assets',
    emptyOutDir: true,
    rollupOptions: {
      external: ['maplibre-gl'],
      output: {
        entryFileNames: '[name].bundle.js',
        chunkFileNames: 'js/[name].js',
        assetFileNames: `assets/[name].[ext]`,
      },
    },
  },

  define: {
    MAPHOST: JSON.stringify(`http://localhost:8080`),
  },
});
