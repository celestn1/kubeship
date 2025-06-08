// kubeship/microservices/frontend/vite.config.ts
/// <reference types="node" />

import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
  // Load environment variables
  process.env = { ...process.env, ...loadEnv(mode, process.cwd()) };

  return {
    plugins: [react()],

    resolve: {
      alias: {
        // Alias '@shared' to the shared directory at the repo root
        '@shared': path.resolve(__dirname, '../../shared'),
      },
    },

    server: {
      port: parseInt(process.env.VITE_PORT || '3000', 10),
      fs: {
        // Allow serving files from both the shared directory and the frontend root
        allow: [
          path.resolve(__dirname, '../../shared'),
          path.resolve(__dirname),
        ],
      },
    },
  };
});
