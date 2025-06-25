# kubeship/microservices/frontend/Dockerfile
# Added to test docker image push 9


# ---- Build Stage ----
FROM node:20-alpine AS build

ARG VITE_API_URL=/v1/auth
ENV VITE_API_URL=${VITE_API_URL}

WORKDIR /app

# 1. Copy package files & install deps
COPY microservices/frontend/package*.json ./
RUN npm ci

# 2. Copy shared code
COPY shared/ ./shared

# 3. Copy frontend code
COPY microservices/frontend/ ./

# 4. Build static site
RUN npm run build

# ---- Production Stage ----
FROM nginx:alpine

# 5. Copy built frontend to NGINX public dir
COPY --from=build /app/dist /usr/share/nginx/html

# 6. Optional: Custom nginx.conf for fallback routing
COPY microservices/frontend/nginx.server.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
