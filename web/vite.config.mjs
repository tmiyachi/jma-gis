import { defineConfig } from 'vite';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default defineConfig(({ mode }) => {
  return {
    root: path.resolve(__dirname, 'src'),
    base: './',
    publicDir:
      mode === 'production'
        ? path.resolve(__dirname, 'public')
        : path.resolve(__dirname, '../'),
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
        output: {
          entryFileNames: '[name]-[hash].bundle.js',
          chunkFileNames: 'js/[name]-[hash].js',
          assetFileNames: `assets/[name]-[hash].[ext]`,
          manualChunks(id) {
            if (id.includes('node_modules')) {
              return 'vendor';
            }
            return null;
          },
        },
      },
    },

    server: {
      port: 8080,
      proxy: {},
      fs: {
        allow: ['.', '../tiles'],
      },
    },
  };
});
